package ledgerkit

import kotlin.math.absoluteValue

/**
 * Renders an amount as the text a transaction row shows.
 *
 * The shape is always: sign, then symbol, then the grouped digits.
 * `-$84.99`, `+$2,500.00`, `-€12,345.67`, `-BD12.500`.
 *
 * Hand-rolled, for the reason spelled out in [Money]: no formatter classes, no
 * locale. The only inputs are the signed minor-unit amount and the currency code.
 */
object TransactionFormatter {

    /** Convenience over [amountText] for a whole row. */
    fun amountText(transaction: Transaction): String =
        amountText(transaction.amountMinor, transaction.currency)

    fun amountText(amountMinor: Long, currency: String): String {
        val sign = if (amountMinor < 0) "-" else "+"
        val places = Money.decimalPlaces(currency)

        // Digits only, no sign. Pad so there is at least one digit left of the point.
        var digits = amountMinor.absoluteValue.toString()
        while (digits.length <= places) {
            digits = "0" + digits
        }

        val whole = digits.substring(0, digits.length - places)
        val fraction = digits.substring(digits.length - places)

        val grouped = group(whole)
        val number = if (places == 0) grouped else "$grouped.$fraction"

        return sign + Money.symbol(currency) + number
    }

    /** Commas every three digits, counting from the right. Integer part only. */
    private fun group(whole: String): String {
        val out = StringBuilder(whole.length + whole.length / 3)
        for ((index, digit) in whole.withIndex()) {
            val remaining = whole.length - index
            if (index > 0 && remaining % 3 == 0) {
                out.append(',')
            }
            out.append(digit)
        }
        return out.toString()
    }
}
