import Foundation

/// One day's worth of transactions.
public struct DaySection: Equatable, Sendable {
    /// The UTC calendar date of `postedAt`, as `YYYY-MM-DD`.
    public var day: String
    /// The transactions that posted on that day, oldest first.
    public var transactions: [Transaction]
    /// The sum of every `amountMinor` in `transactions`.
    public var totalMinor: Int

    public init(day: String, transactions: [Transaction], totalMinor: Int) {
        self.day = day
        self.transactions = transactions
        self.totalMinor = totalMinor
    }
}

/// Groups transactions for a statement list.
///
/// This is the naive version, and it is naive in ways the course names out
/// loud: it sums declined transactions into the day total, it adds amounts in
/// different currencies together as if they were the same unit, it exposes no
/// separate pending total, and it orders days oldest first. Change B replaces
/// it, and the spec for that change is what Day 1 has you write.
public enum LedgerSummary {
    /// Day sections, oldest day first.
    public static func byDay(_ transactions: [Transaction]) -> [DaySection] {
        var buckets: [String: [Transaction]] = [:]
        for transaction in transactions {
            buckets[transaction.postedDay, default: []].append(transaction)
        }

        return buckets.keys.sorted().map { day in
            let rows = buckets[day]!.sorted { $0.postedAt < $1.postedAt }
            let total = rows.reduce(0) { $0 + $1.amountMinor }
            return DaySection(day: day, transactions: rows, totalMinor: total)
        }
    }
}
