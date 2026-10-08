import XCTest
@testable import LedgerKit

/// The assertions the late requirement adds, Swift lane.
///
/// A cycle whose start day moves from the 5th to the 20th on 2026-04-01. Both
/// tests are red against an implementation that reads one rule and green once
/// the rule in force on a date decides where the next period opens. Run them
/// before you make the change as well as after: an assertion you never saw fail
/// has not been proved to bite.
final class ChangeCLateChangeTests: XCTestCase {

    /// The 5th until 2026-04-01, the 20th from then on.
    private func movedCycle() -> StatementCycle {
        StatementCycle(rules: [
            CycleRule(effectiveFrom: "2026-01-01", startDay: 5),
            CycleRule(effectiveFrom: "2026-04-01", startDay: 20),
        ])
    }

    private func transaction(id: String, posted: String) throws -> Transaction {
        Transaction(
            id: id,
            postedAt: try XCTUnwrap(ISO8601.instant(from: posted)),
            authorizedAt: try XCTUnwrap(ISO8601.instant(from: posted)),
            merchant: "Fixture Merchant",
            amountMinor: -1000,
            currency: "USD",
            status: .posted,
            category: .other
        )
    }

    private func ledger() throws -> [Transaction] {
        [
            try transaction(id: "T-MAR", posted: "2026-03-06T09:00:00Z"),
            try transaction(id: "T-APR", posted: "2026-04-10T09:00:00Z"),
            try transaction(id: "T-LATE", posted: "2026-04-25T09:00:00Z"),
        ]
    }

    func testStartDayMovesOnTheEffectiveDate() throws {
        let periods = StatementPeriods.periods(for: try ledger(), cycle: movedCycle())

        XCTAssertEqual(periods[0].start, "2026-04-20", "from 2026-04-01 the cycle opens on the 20th")
        XCTAssertEqual(periods[0].end, "2026-05-19")
        XCTAssertEqual(periods[0].transactions.map(\.id), ["T-LATE"])

        let earlierDay = StatementCycle(rules: [
            CycleRule(effectiveFrom: "2026-01-01", startDay: 5),
            CycleRule(effectiveFrom: "2026-04-03", startDay: 2),
        ])
        XCTAssertEqual(
            StatementPeriods.periods(for: try ledger(), cycle: earlierDay).map { "\($0.start)..\($0.end)" },
            ["2026-03-05..2026-05-01"],
            "a move to the 2nd on 2026-04-03 first opens on 2026-05-02: 2026-04-02 is before the change"
        )
    }

    func testPeriodsBeforeTheChangeKeepTheOldStartDay() throws {
        let periods = StatementPeriods.periods(for: try ledger(), cycle: movedCycle())

        XCTAssertEqual(periods[1].start, "2026-03-05", "the period that opened under the old day keeps its start date")
        XCTAssertEqual(
            periods[1].end,
            "2026-04-19",
            "and runs to the day before the first boundary the new start day produces"
        )
        XCTAssertEqual(periods[1].transactions.map(\.id), ["T-MAR", "T-APR"], "the change splits no period in two")
    }
}
