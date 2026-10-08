import Foundation

/// Facts about the currencies LedgerKit handles.
///
/// Everything here is a table lookup. There is no `NumberFormatter`, no ICU and
/// no locale anywhere in this module, because the same fixture file holds the
/// expected output strings for both language lanes of the course sandbox: the
/// moment output depends on the machine, the fixture stops being true.
public enum Money {
    /// The currencies the fixture uses, in ISO 4217 form.
    public static let supportedCurrencies = ["USD", "EUR", "GBP", "JPY", "BHD"]

    /// How many decimal places a currency's minor units occupy.
    ///
    /// LEDGER-7: this table has no entry for JPY, so JPY falls through to the
    /// two-decimal default and every yen amount renders with two decimal
    /// places it should not have. The bug is deliberate — see KNOWN-ISSUES.md —
    /// and it stays until an exercise tells you to remove it.
    private static let decimalPlacesByCurrency: [String: Int] = [
        "USD": 2,
        "EUR": 2,
        "GBP": 2,
        "BHD": 3,
    ]

    /// The number of decimal places to print for `currency`.
    public static func decimalPlaces(for currency: String) -> Int {
        decimalPlacesByCurrency[currency] ?? 2
    }

    /// The symbol printed in front of an amount.
    ///
    /// An unknown currency prints its own code, which is ugly on purpose: it is
    /// visible in a test failure rather than silently plausible.
    public static func symbol(for currency: String) -> String {
        switch currency {
        case "USD": return "$"
        case "EUR": return "\u{20AC}"
        case "GBP": return "\u{A3}"
        case "JPY": return "\u{A5}"
        case "BHD": return "BD"
        default: return currency
        }
    }
}
