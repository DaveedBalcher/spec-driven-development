import XCTest
@testable import LedgerKit

/// The hidden acceptance suite for Change B.
///
/// Written against `specs/daily-summary.md` and the two sharpenings the
/// reference audit routes into it, not against anybody's implementation. Six
/// assertions, one per reference finding, in finding order. A failure here
/// names the finding you did not route.
///
/// Copy this file into the lane's test directory after your own run:
///
///     cp -R day-2-loops-and-your-environment/starter/acceptance/change-b/swift/. \
///           day2-work/Tests/LedgerKitTests/
final class ChangeBAcceptanceTests: XCTestCase {

    private func section(_ day: String) throws -> DaySection {
        let sections = LedgerSummary.byDay(try Fixture.transactions())
        return try XCTUnwrap(
            sections.first { $0.day == day },
            "no day section for \(day); byDay returned \(sections.map(\.day))"
        )
    }

    private func total(_ currency: String, on day: String) throws -> CurrencyTotal? {
        try section(day).totals.first { $0.currency == currency }
    }

    /// Finding 1, criterion 1: a declined amount is in no total.
    /// LK-006 is a declined USD row for -13999 on 2026-03-03. The only other
    /// USD row that day, LK-005, is pending, so the posted figure is zero.
    func testAcceptance1_DeclinedAmountsAreInNoTotal() throws {
        let third = try section("2026-03-03")
        XCTAssertTrue(
            third.transactions.contains { $0.id == "LK-006" },
            "criterion 1: the declined row is still listed"
        )
        XCTAssertEqual(
            try total("USD", on: "2026-03-03")?.postedMinor, 0,
            "criterion 1: LK-006 (-13999, declined) must not be counted"
        )
    }

    /// Finding 2, criterion 2: the pending figure is per currency, not per day.
    /// On 2026-03-05 the only pending row is LK-016, in GBP.
    func testAcceptance2_PendingTotalsArePerCurrency() throws {
        XCTAssertEqual(
            try total("GBP", on: "2026-03-05")?.pendingMinor, -9_630,
            "criterion 2: GBP carries its own pending sum"
        )
        XCTAssertEqual(
            try total("BHD", on: "2026-03-05")?.pendingMinor, 0,
            "criterion 2: BHD has no pending row, so its pending figure is zero"
        )
        XCTAssertEqual(
            try total("GBP", on: "2026-03-05")?.postedMinor, 0,
            "criterion 2: a pending row is never counted as posted"
        )
    }

    /// Finding 3, criterion 3: sections come back newest day first.
    func testAcceptance3_SectionsAreNewestDayFirst() throws {
        let days = LedgerSummary.byDay(try Fixture.transactions()).map(\.day)
        XCTAssertEqual(
            days,
            ["2026-03-06", "2026-03-05", "2026-03-04", "2026-03-03", "2026-03-02"],
            "criterion 3: newest day first, and no day without transactions"
        )
    }

    /// Finding 4, routed into criterion 3: rows inside a day stay oldest first.
    func testAcceptance4_RowsInsideADayAreOldestFirst() throws {
        XCTAssertEqual(
            try section("2026-03-04").transactions.map(\.id),
            ["LK-009", "LK-010", "LK-011", "LK-012", "LK-013"],
            "criterion 3, sharpened: the day flips, the rows inside it do not"
        )
    }

    /// Finding 5, routed into criterion 4: a currency whose only row that day
    /// was declined has no money to report and gets no entry.
    /// LK-017 is the only EUR row on 2026-03-05, and it was declined.
    func testAcceptance5_ADeclinedOnlyCurrencyHasNoEntry() throws {
        let fifth = try section("2026-03-05")
        XCTAssertTrue(
            fifth.transactions.contains { $0.id == "LK-017" },
            "the declined row is still listed"
        )
        XCTAssertNil(
            try total("EUR", on: "2026-03-05"),
            "criterion 4, sharpened: no entry for a currency with no posted or pending row"
        )
    }

    /// Finding 6, criterion 4: totals are ordered by currency code ascending,
    /// and no two currencies are added together.
    func testAcceptance6_TotalsAreInCurrencyCodeOrder() throws {
        let sixth = try section("2026-03-06")
        XCTAssertEqual(
            sixth.totals.map(\.currency), ["EUR", "GBP", "USD"],
            "criterion 4: ordered by code, not by the order the rows arrived in"
        )
        XCTAssertEqual(try total("EUR", on: "2026-03-06")?.postedMinor, -1_234_567)
        XCTAssertEqual(try total("GBP", on: "2026-03-06")?.postedMinor, 1_299)
        XCTAssertEqual(try total("USD", on: "2026-03-06")?.pendingMinor, 250_000)
    }
}
