import XCTest
@testable import LedgerKit

// Rewritten by the run. Every test here passes against the implementation the
// run produced, which is exactly why a green suite is not the end of the job.
final class LedgerSummaryTests: XCTestCase {

    private func section(_ day: String) throws -> DaySection {
        let sections = LedgerSummary.byDay(try Fixture.transactions())
        return try XCTUnwrap(sections.first { $0.day == day })
    }

    func testOneSectionPerPostedDay() throws {
        let sections = LedgerSummary.byDay(try Fixture.transactions())
        XCTAssertEqual(Set(sections.map(\.day)).count, 5)
    }

    func testNoEmptyDayAppears() throws {
        let sections = LedgerSummary.byDay(try Fixture.transactions())
        XCTAssertTrue(sections.allSatisfy { !$0.transactions.isEmpty })
        XCTAssertTrue(LedgerSummary.byDay([]).isEmpty)
    }

    func testDeclinedTransactionsAreStillListed() throws {
        let third = try section("2026-03-03")
        XCTAssertTrue(third.transactions.contains { $0.id == "LK-006" })
    }

    func testEachDayHasPerCurrencyTotals() throws {
        let third = try section("2026-03-03")
        XCTAssertEqual(Set(third.totals.map(\.currency)), ["EUR", "GBP", "USD"])
        XCTAssertEqual(third.totals.first { $0.currency == "EUR" }?.postedMinor, -4_890)
    }

    func testPendingIsReportedSeparately() throws {
        let third = try section("2026-03-03")
        let usd = try XCTUnwrap(third.totals.first { $0.currency == "USD" })
        XCTAssertEqual(usd.pendingMinor, -1_725)
    }

    func testEveryTransactionLandsInExactlyOneSection() throws {
        let all = try Fixture.transactions()
        let sections = LedgerSummary.byDay(all)
        let placed = sections.flatMap { $0.transactions.map(\.id) }
        XCTAssertEqual(placed.count, all.count)
        XCTAssertEqual(Set(placed), Set(all.map(\.id)))
    }
}
