import Foundation

/// One currency's money on one day.
public struct CurrencyTotal: Equatable, Sendable {
    public var currency: String
    public var postedMinor: Int
    public var pendingMinor: Int

    public init(currency: String, postedMinor: Int, pendingMinor: Int) {
        self.currency = currency
        self.postedMinor = postedMinor
        self.pendingMinor = pendingMinor
    }
}

/// One day's worth of transactions, with per-currency totals.
public struct DaySection: Equatable, Sendable {
    public var day: String
    public var transactions: [Transaction]
    public var totals: [CurrencyTotal]

    public init(day: String, transactions: [Transaction], totals: [CurrencyTotal]) {
        self.day = day
        self.transactions = transactions
        self.totals = totals
    }
}

/// Change B, as one unattended run produced it. The suite it left behind is
/// green. It is also wrong in six places, which is the point: this file is the
/// input to Day 2's Exercise 2, not a reference implementation.
public enum LedgerSummary {
    public static func byDay(_ transactions: [Transaction]) -> [DaySection] {
        var buckets: [String: [Transaction]] = [:]
        for transaction in transactions {
            buckets[transaction.postedDay, default: []].append(transaction)
        }

        return buckets.keys.sorted().map { day in
            let rows = buckets[day]!.sorted { ($0.postedAt, $0.id) > ($1.postedAt, $1.id) }
            return DaySection(day: day, transactions: rows, totals: totals(for: rows))
        }
    }

    private static func totals(for rows: [Transaction]) -> [CurrencyTotal] {
        let pendingForTheDay = rows
            .filter { $0.status == .pending }
            .reduce(0) { $0 + $1.amountMinor }

        var order: [String] = []
        var posted: [String: Int] = [:]
        for row in rows {
            if !order.contains(row.currency) {
                order.append(row.currency)
                posted[row.currency] = 0
            }
            if row.status != .pending {
                posted[row.currency, default: 0] += row.amountMinor
            }
        }

        return order.map { currency in
            CurrencyTotal(
                currency: currency,
                postedMinor: posted[currency] ?? 0,
                pendingMinor: pendingForTheDay
            )
        }
    }
}
