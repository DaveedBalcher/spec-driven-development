import Foundation

/// Turns a signed minor-unit amount into the string a statement row shows.
///
/// Hand-rolled on purpose. The output must be byte-identical to the Kotlin
/// lane's, so nothing here may consult a locale, a `NumberFormatter` or ICU.
public enum TransactionFormatter {
    /// Renders `amountMinor` in `currency`.
    ///
    /// The shape is always sign, then symbol, then the grouped digits:
    /// `-$84.99`, `+$2,500.00`, `-\u{20AC}12,345.67`, `-BD12.500`.
    /// A debit takes `-`, a credit (and zero) takes `+`.
    public static func amountText(amountMinor: Int, currency: String) -> String {
        let sign = amountMinor < 0 ? "-" : "+"
        let magnitude = amountMinor.magnitude
        let places = Money.decimalPlaces(for: currency)

        var scale: UInt = 1
        for _ in 0..<places { scale *= 10 }

        let wholeUnits = magnitude / scale
        let fraction = magnitude % scale

        var text = sign + Money.symbol(for: currency) + grouped(wholeUnits)
        if places > 0 {
            text += "." + padded(fraction, width: places)
        }
        return text
    }

    /// Renders one transaction's amount.
    public static func amountText(_ transaction: Transaction) -> String {
        amountText(amountMinor: transaction.amountMinor, currency: transaction.currency)
    }

    /// Digits with a comma every three places, counted from the right.
    private static func grouped(_ value: UInt) -> String {
        let digits = Array(String(value))
        var out = ""
        for (offset, digit) in digits.enumerated() {
            if offset > 0 && (digits.count - offset) % 3 == 0 {
                out.append(",")
            }
            out.append(digit)
        }
        return out
    }

    /// Zero-padded digits for the fractional part.
    private static func padded(_ value: UInt, width: Int) -> String {
        var digits = String(value)
        while digits.count < width { digits = "0" + digits }
        return digits
    }
}
