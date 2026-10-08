package ledgerkit

import kotlin.test.Test
import kotlin.test.assertEquals

/**
 * Unit tests for the rendering rules, independent of the fixture.
 * The JPY case lives in `KnownIssueTest`, not here: see `KNOWN-ISSUES.md`.
 */
class TransactionFormatterTest {

    @Test
    fun `a debit gets a minus sign and the currency symbol`() {
        assertEquals("-$84.99", TransactionFormatter.amountText(-8499, "USD"))
    }

    @Test
    fun `a credit gets a plus sign`() {
        assertEquals("+$84.99", TransactionFormatter.amountText(8499, "USD"))
    }

    @Test
    fun `zero is rendered as a credit of nothing`() {
        assertEquals("+$0.00", TransactionFormatter.amountText(0, "USD"))
    }

    @Test
    fun `amounts below one unit keep a leading zero`() {
        assertEquals("-$0.05", TransactionFormatter.amountText(-5, "USD"))
    }

    @Test
    fun `thousands are grouped with commas in the integer part only`() {
        assertEquals("+$2,500.00", TransactionFormatter.amountText(250000, "USD"))
        assertEquals("-€12,345.67", TransactionFormatter.amountText(-1234567, "EUR"))
    }

    @Test
    fun `the symbol comes from the currency code`() {
        assertEquals("-£12.99", TransactionFormatter.amountText(-1299, "GBP"))
    }

    @Test
    fun `a three decimal currency keeps three decimals`() {
        assertEquals("-BD12.500", TransactionFormatter.amountText(-12500, "BHD"))
        assertEquals("-BD1,234.567", TransactionFormatter.amountText(-1234567, "BHD"))
    }

    @Test
    fun `an unknown currency prints its own code as the symbol`() {
        assertEquals("-CHF1.00", TransactionFormatter.amountText(-100, "CHF"))
    }

    @Test
    fun `the row overload agrees with the amount overload`() {
        val row = Fixture.row("LK-018").transaction
        assertEquals(
            TransactionFormatter.amountText(row.amountMinor, row.currency),
            TransactionFormatter.amountText(row),
        )
    }
}
