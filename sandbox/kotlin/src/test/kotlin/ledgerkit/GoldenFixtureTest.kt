package ledgerkit

import java.io.File
import java.time.Instant
import org.junit.jupiter.api.DynamicTest
import org.junit.jupiter.api.TestFactory
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertTrue

/** One line of `Fixtures/transactions.tsv`, with the two expected columns kept beside the row. */
data class FixtureRow(
    val transaction: Transaction,
    val expectedAmountText: String,
    val expectedDay: String,
)

/**
 * Loads the shared fixture. The path is relative to the project directory, which is
 * where Gradle runs the tests from, and the file is a byte-identical copy of
 * `sandbox/fixtures/transactions.tsv` — the same bytes the Swift lane reads.
 */
object Fixture {

    const val PATH: String = "Fixtures/transactions.tsv"

    val rows: List<FixtureRow> by lazy { load() }

    val transactions: List<Transaction> get() = rows.map { it.transaction }

    fun row(id: String): FixtureRow =
        rows.firstOrNull { it.transaction.id == id } ?: error("no fixture row with id $id")

    private fun load(): List<FixtureRow> {
        val file = File(PATH)
        check(file.isFile) {
            "fixture not found at ${file.absolutePath} - run the tests from the project directory"
        }
        val lines = file.readText().trim('\n').split("\n")
        return lines.drop(1).map { line ->
            val field = line.split("\t")
            check(field.size == 10) { "expected 10 columns, got ${field.size} in: $line" }
            FixtureRow(
                transaction = Transaction(
                    id = field[0],
                    postedAt = Instant.parse(field[1]),
                    authorizedAt = Instant.parse(field[2]),
                    merchant = field[3],
                    amountMinor = field[4].toLong(),
                    currency = field[5],
                    status = TransactionStatus.fromWire(field[6]),
                    category = Category.fromWire(field[7]),
                ),
                expectedAmountText = field[8],
                expectedDay = field[9],
            )
        }
    }
}

/**
 * LEDGER-7. The shipped code renders this row's amount wrong, so the golden test
 * leaves its `amountText` assertion alone and `KnownIssueTest` owns it instead.
 * Everything else about the row is still asserted here.
 */
private val KNOWN_ISSUE_ROW_IDS = setOf("LK-014")

/**
 * The spine of the suite: every row of the fixture, checked three ways.
 * One dynamic test per row, named after the row, so a failure names the id.
 */
class GoldenFixtureTest {

    @Test
    fun `the fixture has twenty rows`() {
        assertEquals(20, Fixture.rows.size)
    }

    @TestFactory
    fun `every row renders its expected amount`(): List<DynamicTest> =
        Fixture.rows
            .filterNot { it.transaction.id in KNOWN_ISSUE_ROW_IDS }
            .map { row ->
                DynamicTest.dynamicTest("${row.transaction.id} ${row.transaction.currency}") {
                    assertEquals(
                        row.expectedAmountText,
                        TransactionFormatter.amountText(row.transaction),
                        "${row.transaction.id}: wrong rendered amount",
                    )
                }
            }

    @TestFactory
    fun `every row lands in its expected day bucket`(): List<DynamicTest> =
        Fixture.rows.map { row ->
            DynamicTest.dynamicTest("${row.transaction.id} -> ${row.expectedDay}") {
                val sections = LedgerSummary.byDay(listOf(row.transaction))
                assertEquals(1, sections.size)
                assertEquals(
                    row.expectedDay,
                    sections.single().day,
                    "${row.transaction.id}: wrong day bucket",
                )
            }
        }

    @TestFactory
    fun `every row is found by its own query and excluded by the others`(): List<DynamicTest> =
        Fixture.rows.map { row ->
            DynamicTest.dynamicTest(row.transaction.id) {
                val transaction = row.transaction
                val own = Query(
                    statuses = setOf(transaction.status),
                    categories = setOf(transaction.category),
                    // Upper-cased on purpose: matching is case- and diacritic-insensitive.
                    merchantContains = transaction.merchant.uppercase(),
                )
                assertTrue(
                    LedgerFilter.apply(Fixture.transactions, own).contains(transaction),
                    "${transaction.id}: its own query did not find it",
                )

                val otherStatuses = TransactionStatus.entries.toSet() - transaction.status
                assertFalse(
                    LedgerFilter.matches(transaction, Query(statuses = otherStatuses)),
                    "${transaction.id}: matched a query for the other two statuses",
                )
            }
        }
}
