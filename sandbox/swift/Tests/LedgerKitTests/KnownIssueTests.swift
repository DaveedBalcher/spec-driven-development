import XCTest
@testable import LedgerKit

/// Tests for bugs LedgerKit ships with on purpose.
///
/// These are skipped by default so the suite is green, and they run when you
/// ask for them:
///
///     LEDGER_RUN_KNOWN_ISSUES=1 swift test
///
/// Every case here is listed in KNOWN-ISSUES.md. A case that starts passing is
/// a bug that got fixed: move the assertion into the unit's own test file and
/// delete the entry.
final class KnownIssueTests: XCTestCase {

    private func skipUnlessRequested() throws {
        try XCTSkipUnless(
            ProcessInfo.processInfo.environment["LEDGER_RUN_KNOWN_ISSUES"] == "1",
            "Known-issue tests are off. Set LEDGER_RUN_KNOWN_ISSUES=1 to run them."
        )
    }

    /// LEDGER-7: JPY has no entry in the decimal-places table, so it falls
    /// through to the two-decimal default and yen amounts render with two
    /// decimal places that do not exist in the currency.
    func testLEDGER7_JPYRendersWithTwoDecimalPlaces() throws {
        try skipUnlessRequested()

        let row = try XCTUnwrap(
            Fixture.rows().first { $0.transaction.currency == "JPY" },
            "the fixture should carry exactly one JPY row"
        )
        let actual = TransactionFormatter.amountText(row.transaction)

        XCTAssertEqual(
            actual,
            row.expectedAmountText,
            """
            LEDGER-7: \(row.id) (\(row.transaction.currency)) rendered the wrong amount.
              expected: \(row.expectedAmountText)
              actual:   \(actual)
            JPY has no minor unit, so Money.decimalPlaces(for: "JPY") should be 0 and is \
            \(Money.decimalPlaces(for: "JPY")). See KNOWN-ISSUES.md.
            """
        )
    }
}
