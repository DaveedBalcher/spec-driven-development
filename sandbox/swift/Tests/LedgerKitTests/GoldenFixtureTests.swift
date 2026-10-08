import XCTest
@testable import LedgerKit

/// One row of `Fixtures/transactions.tsv`.
struct FixtureRow {
    var transaction: Transaction
    var expectedAmountText: String
    var expectedDay: String

    var id: String { transaction.id }
}

/// Reads the shared fixture.
///
/// The file is found from `#filePath` — the compiler records the path of this
/// source file, and the fixture sits next to it. That keeps `swift test` and
/// `swift test --package-path <copy>` both working, and it keeps the fixture
/// out of the resource bundle, so there is one obvious path and no
/// `Bundle.module` machinery to explain.
enum Fixture {
    static var url: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .appendingPathComponent("Fixtures")
            .appendingPathComponent("transactions.tsv")
    }

    static func rows(file: StaticString = #filePath, line: UInt = #line) throws -> [FixtureRow] {
        let text = try String(contentsOf: url, encoding: .utf8)
        var rows: [FixtureRow] = []

        for (index, rawLine) in text.split(separator: "\n", omittingEmptySubsequences: true).enumerated() {
            if index == 0 { continue }  // header
            let fields = rawLine.split(separator: "\t", omittingEmptySubsequences: false).map(String.init)
            guard fields.count == 10 else {
                XCTFail("row \(index) has \(fields.count) fields, expected 10", file: file, line: line)
                continue
            }
            guard let postedAt = ISO8601.instant(from: fields[1]),
                  let authorizedAt = ISO8601.instant(from: fields[2]),
                  let amountMinor = Int(fields[4]),
                  let status = TransactionStatus(rawValue: fields[6]),
                  let category = TransactionCategory(rawValue: fields[7])
            else {
                XCTFail("row \(index) (\(fields[0])) did not parse", file: file, line: line)
                continue
            }
            rows.append(
                FixtureRow(
                    transaction: Transaction(
                        id: fields[0],
                        postedAt: postedAt,
                        authorizedAt: authorizedAt,
                        merchant: fields[3],
                        amountMinor: amountMinor,
                        currency: fields[5],
                        status: status,
                        category: category
                    ),
                    expectedAmountText: fields[8],
                    expectedDay: fields[9]
                )
            )
        }
        return rows
    }

    static func transactions() throws -> [Transaction] {
        try rows().map(\.transaction)
    }
}

/// The table-driven test that walks every fixture row.
///
/// This is the spine of the suite: the fixture's last two columns say what a
/// correct LedgerKit prints and where it files each row, so a change that
/// breaks either one fails here by transaction id.
final class GoldenFixtureTests: XCTestCase {

    func testFixtureLoads() throws {
        let rows = try Fixture.rows()
        XCTAssertEqual(rows.count, 20, "the fixture should carry 20 data rows")
        XCTAssertEqual(Set(rows.map(\.id)).count, 20, "transaction ids should be unique")
    }

    func testAmountTextMatchesTheFixture() throws {
        for row in try Fixture.rows() {
            // LEDGER-7: the one JPY row is the bug's only casualty, and
            // KnownIssueTests owns it. Everything else is asserted here.
            if row.transaction.currency == "JPY" { continue }

            XCTAssertEqual(
                TransactionFormatter.amountText(row.transaction),
                row.expectedAmountText,
                "\(row.id) rendered the wrong amount"
            )
        }
    }

    func testDayBucketMatchesTheFixture() throws {
        let rows = try Fixture.rows()
        let sections = LedgerSummary.byDay(rows.map(\.transaction))

        for row in rows {
            XCTAssertEqual(
                row.transaction.postedDay,
                row.expectedDay,
                "\(row.id) has the wrong posted day"
            )
            let section = sections.first { $0.transactions.contains(where: { $0.id == row.id }) }
            XCTAssertEqual(
                section?.day,
                row.expectedDay,
                "\(row.id) landed in the wrong day section"
            )
        }
    }

    func testFilterMembershipMatchesTheFixture() throws {
        let rows = try Fixture.rows()
        let all = rows.map(\.transaction)

        for row in rows {
            let transaction = row.transaction

            // Typed in plain uppercase ASCII: the folding has to find it anyway.
            let needle = LedgerFilter.fold(transaction.merchant).uppercased()
            let matching = LedgerFilter.Query(
                statuses: [transaction.status],
                categories: [transaction.category],
                postedFrom: transaction.postedAt,
                postedThrough: transaction.postedAt,
                merchant: needle
            )
            XCTAssertTrue(
                LedgerFilter.apply(matching, to: all).contains { $0.id == row.id },
                "\(row.id) should be kept by a query built from its own fields"
            )

            let otherStatuses = Set(TransactionStatus.allCases).subtracting([transaction.status])
            let excluding = LedgerFilter.Query(statuses: otherStatuses)
            XCTAssertFalse(
                LedgerFilter.apply(excluding, to: all).contains { $0.id == row.id },
                "\(row.id) should be dropped by a query that excludes its status"
            )
        }
    }
}
