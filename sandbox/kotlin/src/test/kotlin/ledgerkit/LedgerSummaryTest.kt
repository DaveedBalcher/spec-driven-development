package ledgerkit

import java.time.Instant
import kotlin.test.Test
import kotlin.test.assertEquals

class LedgerSummaryTest {

    private val sections = LedgerSummary.byDay(Fixture.transactions)

    @Test
    fun `the day key is the UTC calendar date of postedAt`() {
        assertEquals("2026-03-04", LedgerSummary.day(Instant.parse("2026-03-04T03:12:44Z")))
        assertEquals("2026-03-06", LedgerSummary.day(Instant.parse("2026-03-06T23:59:59Z")))
    }

    @Test
    fun `days come out oldest first with no gaps invented`() {
        assertEquals(
            listOf("2026-03-02", "2026-03-03", "2026-03-04", "2026-03-05", "2026-03-06"),
            sections.map { it.day },
        )
    }

    @Test
    fun `every transaction lands in exactly one section`() {
        assertEquals(20, sections.sumOf { it.transactions.size })
        assertEquals(listOf(3, 5, 5, 4, 3), sections.map { it.transactions.size })
    }

    @Test
    fun `a section is ordered by postedAt within the day`() {
        val day = sections.first { it.day == "2026-03-04" }
        assertEquals(
            listOf("LK-009", "LK-010", "LK-011", "LK-012", "LK-013"),
            day.transactions.map { it.id },
        )
    }

    @Test
    fun `the total is the plain sum of every amount in the day`() {
        assertEquals(-12724, sections.first { it.day == "2026-03-02" }.totalMinor)
    }

    @Test
    fun `the naive total counts declined transactions too`() {
        // LK-006 is declined, for -13999, and still lands in the total.
        // A later change takes it out of the total while keeping it in the list.
        val day = sections.first { it.day == "2026-03-03" }
        assertEquals(-21913, day.totalMinor)

        val withoutDeclined = day.transactions
            .filter { it.status != TransactionStatus.DECLINED }
            .sumOf { it.amountMinor }
        assertEquals(-7914, withoutDeclined)
    }

    @Test
    fun `grouping an empty ledger produces no sections`() {
        assertEquals(emptyList(), LedgerSummary.byDay(emptyList()))
    }
}
