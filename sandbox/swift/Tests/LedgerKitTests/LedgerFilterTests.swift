import XCTest
@testable import LedgerKit

final class LedgerFilterTests: XCTestCase {

    private func transactions() throws -> [Transaction] {
        try Fixture.transactions()
    }

    private func ids(_ transactions: [Transaction]) -> [String] {
        transactions.map(\.id)
    }

    func testEmptyQueryKeepsEverything() throws {
        let all = try transactions()
        XCTAssertEqual(LedgerFilter.apply(LedgerFilter.Query(), to: all).count, all.count)
    }

    func testEmptyStatusSetKeepsNothing() throws {
        let all = try transactions()
        let query = LedgerFilter.Query(statuses: [])
        XCTAssertTrue(LedgerFilter.apply(query, to: all).isEmpty)
    }

    func testStatusNarrowsTheResult() throws {
        let all = try transactions()
        let declined = LedgerFilter.apply(LedgerFilter.Query(statuses: [.declined]), to: all)
        XCTAssertEqual(ids(declined), ["LK-006", "LK-017"])
    }

    func testCategoryNarrowsTheResult() throws {
        let all = try transactions()
        let bills = LedgerFilter.apply(LedgerFilter.Query(categories: [.bills]), to: all)
        XCTAssertEqual(ids(bills), ["LK-012", "LK-016", "LK-017"])
    }

    func testDateRangeIsInclusiveAtBothEnds() throws {
        let all = try transactions()
        let from = ISO8601.instant(from: "2026-03-05T00:00:00Z")
        let through = ISO8601.instant(from: "2026-03-05T23:59:59Z")
        let query = LedgerFilter.Query(postedFrom: from, postedThrough: through)
        XCTAssertEqual(ids(LedgerFilter.apply(query, to: all)), ["LK-014", "LK-015", "LK-016", "LK-017"])
    }

    func testMerchantMatchIgnoresCase() throws {
        let all = try transactions()
        let query = LedgerFilter.Query(merchant: "tesco")
        XCTAssertEqual(ids(LedgerFilter.apply(query, to: all)), ["LK-007", "LK-019"])
    }

    func testMerchantMatchIgnoresDiacritics() throws {
        let all = try transactions()
        let query = LedgerFilter.Query(merchant: "cafe muller")
        XCTAssertEqual(ids(LedgerFilter.apply(query, to: all)), ["LK-003", "LK-009", "LK-010"])
    }

    func testMerchantMatchIgnoresCaseAndDiacriticsTogether() throws {
        let all = try transactions()
        let query = LedgerFilter.Query(merchant: "ZURICH")
        XCTAssertEqual(ids(LedgerFilter.apply(query, to: all)), ["LK-004", "LK-011", "LK-018"])
    }

    func testMerchantMatchIsASubstringMatch() throws {
        let all = try transactions()
        let query = LedgerFilter.Query(merchant: "market")
        XCTAssertEqual(ids(LedgerFilter.apply(query, to: all)), ["LK-001", "LK-006", "LK-013", "LK-020"])
    }

    func testFoldingHandlesLettersWithNoDecomposition() {
        XCTAssertEqual(LedgerFilter.fold("N\u{F8}rrebro Bakeri"), "norrebro bakeri")
        XCTAssertEqual(LedgerFilter.fold("CAF\u{C9} M\u{DC}LLER"), "cafe muller")
        XCTAssertEqual(LedgerFilter.fold("Stra\u{DF}e"), "strasse")
    }

    func testPartsOfAQueryCombineWithAnd() throws {
        let all = try transactions()
        let query = LedgerFilter.Query(
            statuses: [.posted],
            categories: [.dining],
            merchant: "cafe"
        )
        XCTAssertEqual(ids(LedgerFilter.apply(query, to: all)), ["LK-003", "LK-009", "LK-010"])
    }
}
