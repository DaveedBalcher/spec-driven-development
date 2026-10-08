import XCTest
@testable import LedgerKit

final class TransactionFormatterTests: XCTestCase {

    func testDebitsTakeAMinusSign() {
        XCTAssertEqual(TransactionFormatter.amountText(amountMinor: -8_499, currency: "USD"), "-$84.99")
    }

    func testCreditsTakeAPlusSign() {
        XCTAssertEqual(TransactionFormatter.amountText(amountMinor: 8_499, currency: "USD"), "+$84.99")
    }

    func testZeroIsTreatedAsACredit() {
        XCTAssertEqual(TransactionFormatter.amountText(amountMinor: 0, currency: "USD"), "+$0.00")
    }

    func testThousandsAreGroupedWithCommas() {
        XCTAssertEqual(
            TransactionFormatter.amountText(amountMinor: -1_234_567, currency: "EUR"),
            "-\u{20AC}12,345.67"
        )
        XCTAssertEqual(
            TransactionFormatter.amountText(amountMinor: 250_000, currency: "USD"),
            "+$2,500.00"
        )
    }

    func testGroupingIsOnlyAppliedToTheIntegerPart() {
        XCTAssertEqual(
            TransactionFormatter.amountText(amountMinor: -100_000_000, currency: "GBP"),
            "-\u{A3}1,000,000.00"
        )
    }

    func testThreeDecimalCurrencyKeepsThreeDecimals() {
        XCTAssertEqual(TransactionFormatter.amountText(amountMinor: -12_500, currency: "BHD"), "-BD12.500")
    }

    func testFractionIsZeroPadded() {
        XCTAssertEqual(TransactionFormatter.amountText(amountMinor: -5, currency: "USD"), "-$0.05")
        XCTAssertEqual(TransactionFormatter.amountText(amountMinor: -5, currency: "BHD"), "-BD0.005")
    }

    func testUnknownCurrencyPrintsItsCode() {
        XCTAssertEqual(TransactionFormatter.amountText(amountMinor: -100, currency: "XTS"), "-XTS1.00")
    }

    func testDecimalPlacesComeFromTheCurrency() {
        XCTAssertEqual(Money.decimalPlaces(for: "USD"), 2)
        XCTAssertEqual(Money.decimalPlaces(for: "EUR"), 2)
        XCTAssertEqual(Money.decimalPlaces(for: "GBP"), 2)
        XCTAssertEqual(Money.decimalPlaces(for: "BHD"), 3)
        // JPY is missing from the table on purpose. See KNOWN-ISSUES.md.
    }

    func testSymbols() {
        XCTAssertEqual(Money.symbol(for: "USD"), "$")
        XCTAssertEqual(Money.symbol(for: "EUR"), "\u{20AC}")
        XCTAssertEqual(Money.symbol(for: "GBP"), "\u{A3}")
        XCTAssertEqual(Money.symbol(for: "JPY"), "\u{A5}")
        XCTAssertEqual(Money.symbol(for: "BHD"), "BD")
    }
}
