import XCTest
@testable import LedgerKit

/// The hidden acceptance suite for Change C, Swift lane.
///
/// It is written from the brief and nothing else, it is identical in intent to
/// the Kotlin lane's copy, and it stays outside the repository until the
/// exercise copies it in, so no framework can read it while it plans or
/// repairs. Two of the six tests encode the brief's two ambiguities: a red
/// result there says which way your framework decided, not that you failed.
final class ChangeCAcceptanceTests: XCTestCase {

    // MARK: - The cycle fixture

    /// `Fixtures/cycle-config.tsv`, found next to this file the same way the
    /// golden test finds the transactions fixture.
    private func cycleTable() throws -> String {
        let url = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .appendingPathComponent("Fixtures")
            .appendingPathComponent("cycle-config.tsv")
        return try String(contentsOf: url, encoding: .utf8)
    }

    private func cycle(named name: String) throws -> StatementCycle {
        try XCTUnwrap(
            StatementCycle.parse(tsv: try cycleTable(), named: name),
            "the cycle table should carry a configuration named \(name)"
        )
    }

    private func transaction(id: String, posted: String, authorized: String) throws -> Transaction {
        Transaction(
            id: id,
            postedAt: try XCTUnwrap(ISO8601.instant(from: posted)),
            authorizedAt: try XCTUnwrap(ISO8601.instant(from: authorized)),
            merchant: "Fixture Merchant",
            amountMinor: -1000,
            currency: "USD",
            status: .posted,
            category: .other
        )
    }

    // MARK: - The six

    func testCycleConfigLoadsFromTheFixture() throws {
        let table = try cycleTable()

        let standard = try XCTUnwrap(StatementCycle.parse(tsv: table, named: "standard"))
        XCTAssertEqual(standard.rules.count, 1, "the standard configuration ships one rule")
        XCTAssertEqual(standard.rules.first?.effectiveFrom, "2026-01-01")
        XCTAssertEqual(standard.rules.first?.startDay, 5)

        let monthEnd = try XCTUnwrap(StatementCycle.parse(tsv: table, named: "month-end"))
        XCTAssertEqual(monthEnd.rules.first?.startDay, 31)

        XCTAssertNil(
            StatementCycle.parse(tsv: table, named: "no-such-configuration"),
            "a name that is not in the table has no configuration"
        )
    }

    func testPeriodBoundariesForTheStandardCycle() throws {
        let periods = StatementPeriods.periods(for: try Fixture.transactions(), cycle: try cycle(named: "standard"))

        XCTAssertEqual(periods.count, 2, "the fixture spans two periods of a cycle starting on the 5th")
        XCTAssertEqual(periods[0].start, "2026-03-05", "newest period first")
        XCTAssertEqual(periods[0].end, "2026-04-04", "the end date is the last day covered")
        XCTAssertEqual(periods[1].start, "2026-02-05")
        XCTAssertEqual(periods[1].end, "2026-03-04", "periods run back to back with no gap")
    }

    func testEveryTransactionLandsInExactlyOnePeriod() throws {
        let all = try Fixture.transactions()
        let periods = StatementPeriods.periods(for: all, cycle: try cycle(named: "standard"))

        let placed = periods.flatMap { $0.transactions.map(\.id) }
        XCTAssertEqual(placed.count, all.count, "every transaction is placed once and only once")
        XCTAssertEqual(Set(placed), Set(all.map(\.id)))
        XCTAssertEqual(periods[0].transactions.count, 7)
        XCTAssertEqual(periods[1].transactions.count, 13)
    }

    /// Ambiguity one. `LK-015` was authorized on 2026-03-04, inside the period
    /// that ends that day, and posted on 2026-03-05, the first day of the next
    /// one. This suite reads membership from the posted date.
    func testAuthorizedVsPostedMembership() throws {
        let periods = StatementPeriods.periods(for: try Fixture.transactions(), cycle: try cycle(named: "standard"))
        let newest = periods[0].transactions.map(\.id)
        let older = periods[1].transactions.map(\.id)

        XCTAssertTrue(
            newest.contains("LK-015"),
            "LK-015 posted on 2026-03-05 and belongs to the period that opens that day"
        )
        XCTAssertFalse(newest.contains("LK-011"), "LK-011 posted on 2026-03-04, inside the earlier period")
        XCTAssertTrue(older.contains("LK-011"), "LK-011 was authorized on 2026-03-03 and posted on 2026-03-04")
        XCTAssertFalse(older.contains("LK-015"))
    }

    /// Ambiguity two. A cycle that starts on day 31 has no 31st in February, so
    /// this suite holds the start day inside the month: 2026-02-28.
    func testFebruaryCycleStart() throws {
        let transactions = [
            try transaction(id: "T-FEB", posted: "2026-02-15T12:00:00Z", authorized: "2026-02-15T12:00:00Z"),
            try transaction(id: "T-MAR", posted: "2026-02-28T12:00:00Z", authorized: "2026-02-28T12:00:00Z"),
        ]
        let periods = StatementPeriods.periods(for: transactions, cycle: try cycle(named: "month-end"))

        XCTAssertEqual(periods.count, 2)
        XCTAssertEqual(periods[0].start, "2026-02-28", "February is 28 days long in 2026, so day 31 lands on the 28th")
        XCTAssertEqual(periods[0].end, "2026-03-30")
        XCTAssertEqual(periods[0].transactions.map(\.id), ["T-MAR"])
        XCTAssertEqual(periods[1].start, "2026-01-31")
        XCTAssertEqual(periods[1].end, "2026-02-27")
        XCTAssertEqual(periods[1].transactions.map(\.id), ["T-FEB"])
    }

    func testPeriodListsEveryStatusOldestFirst() throws {
        let periods = StatementPeriods.periods(for: try Fixture.transactions(), cycle: try cycle(named: "standard"))
        let newest = periods[0].transactions

        XCTAssertEqual(
            newest.map(\.id),
            ["LK-014", "LK-015", "LK-016", "LK-017", "LK-018", "LK-019", "LK-020"],
            "inside a period the transactions read oldest first"
        )
        let statuses = Set(newest.map(\.status))
        XCTAssertTrue(statuses.contains(.pending), "a pending row belongs on the statement it posted to")
        XCTAssertTrue(statuses.contains(.declined), "so does a declined one")
    }
}
