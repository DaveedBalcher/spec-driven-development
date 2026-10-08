package ledgerkit

import org.junit.jupiter.api.condition.EnabledIfEnvironmentVariable
import kotlin.test.Test
import kotlin.test.assertEquals

/**
 * LEDGER-7, the seeded bug. This class does not run unless you ask for it:
 *
 *     LEDGER_RUN_KNOWN_ISSUES=1 ./gradlew test
 *
 * With the variable set, exactly one test fails — the JPY row — and the message
 * names the string the fixture expects and the string the code produced.
 * `build.gradle.kts` forwards the variable into the test JVM; if this class is
 * still reported as skipped, the variable did not reach the test process.
 */
@EnabledIfEnvironmentVariable(named = "LEDGER_RUN_KNOWN_ISSUES", matches = "1")
class KnownIssueTest {

    @Test
    fun `LEDGER-7 the JPY row renders with decimal places it should not have`() {
        val row = Fixture.row("LK-014")
        val actual = TransactionFormatter.amountText(row.transaction)
        assertEquals(
            row.expectedAmountText,
            actual,
            "LEDGER-7: LK-014 is ${row.transaction.amountMinor} minor units of " +
                "${row.transaction.currency}. The fixture expects " +
                "\"${row.expectedAmountText}\" and TransactionFormatter.amountText produced " +
                "\"$actual\". Money.decimalPlaces returns 2 for JPY; JPY has no minor unit.",
        )
    }
}
