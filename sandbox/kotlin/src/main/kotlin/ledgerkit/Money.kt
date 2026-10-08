package ledgerkit

/**
 * What a currency code means for rendering: how many decimal places it has and
 * what symbol goes in front of the digits.
 *
 * Everything here is hand-rolled on purpose. No `java.text.NumberFormat`, no ICU,
 * no locale lookups anywhere in this module: the golden fixture holds one expected
 * string per row for both language lanes, and a locale-aware API would make that
 * string depend on the machine the tests ran on.
 */
object Money {

    /**
     * How many digits sit after the decimal point for [currency].
     *
     * KNOWN ISSUE — LEDGER-7. The table below has no entry for the zero-decimal
     * currencies, so JPY falls through to the two-place default and renders as
     * `-¥1,280.00` instead of `-¥128,000`. See `KNOWN-ISSUES.md`.
     */
    fun decimalPlaces(currency: String): Int = when (currency) {
        "BHD" -> 3
        else -> 2
    }

    /** The symbol printed immediately before the digits. An unknown code prints itself. */
    fun symbol(currency: String): String = when (currency) {
        "USD" -> "$"
        "EUR" -> "€"
        "GBP" -> "£"
        "JPY" -> "¥"
        "BHD" -> "BD"
        else -> currency
    }
}
