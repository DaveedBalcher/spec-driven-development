import XCTest
@testable import LedgerKit

final class LedgerSummaryTests: XCTestCase {

    func testOneSectionPerPostedDay() throws {
        let sections = LedgerSummary.byDay(try Fixture.transactions())
        XCTAssertEqual(
            sections.map(\.day),
            ["2026-03-02", "2026-03-03", "2026-03-04", "2026-03-05", "2026-03-06"]
        )
    }

    func testSectionsAreOrderedOldestFirst() throws {
        let sections = LedgerSummary.byDay(try Fixture.transactions())
        XCTAssertEqual(sections.map(\.day), sections.map(\.day).sorted())
    }

    func testTransactionsInsideASectionAreOrderedOldestFirst() throws {
        let sections = LedgerSummary.byDay(try Fixture.transactions())
        for section in sections {
            let instants = section.transactions.map(\.postedAt)
            XCTAssertEqual(instants, instants.sorted(), "section \(section.day) is out of order")
        }
    }

    func testEveryTransactionLandsInExactlyOneSection() throws {
        let all = try Fixture.transactions()
        let sections = LedgerSummary.byDay(all)
        let placed = sections.flatMap { $0.transactions.map(\.id) }
        XCTAssertEqual(placed.count, all.count)
        XCTAssertEqual(Set(placed), Set(all.map(\.id)))
    }

    func testGroupingUsesThePostedDayNotTheAuthorizedDay() throws {
        let all = try Fixture.transactions()
        let sections = LedgerSummary.byDay(all)
        let fourth = sections.first { $0.day == "2026-03-04" }
        // LK-009, LK-010 and LK-011 were authorized on the 3rd and posted on the 4th.
        XCTAssertNotNil(fourth)
        XCTAssertTrue(fourth?.transactions.contains { $0.id == "LK-009" } ?? false)
        XCTAssertTrue(fourth?.transactions.contains { $0.id == "LK-010" } ?? false)
        XCTAssertTrue(fourth?.transactions.contains { $0.id == "LK-011" } ?? false)
    }

    // The naive behaviour Change B replaces. These tests document what ships
    // today; they are not an argument that it is right.

    func testTotalIncludesDeclinedTransactions() throws {
        let sections = LedgerSummary.byDay(try Fixture.transactions())
        let third = try XCTUnwrap(sections.first { $0.day == "2026-03-03" })
        let sum = third.transactions.reduce(0) { $0 + $1.amountMinor }
        XCTAssertEqual(third.totalMinor, sum)
        XCTAssertTrue(third.transactions.contains { $0.status == .declined })
    }

    func testTotalAddsDifferentCurrenciesTogether() throws {
        let sections = LedgerSummary.byDay(try Fixture.transactions())
        let second = try XCTUnwrap(sections.first { $0.day == "2026-03-02" })
        XCTAssertEqual(Set(second.transactions.map(\.currency)), ["USD", "EUR"])
        XCTAssertEqual(second.totalMinor, -8_499 - 2_350 - 1_875)
    }

    func testEmptyInputProducesNoSections() {
        XCTAssertTrue(LedgerSummary.byDay([]).isEmpty)
    }
}
