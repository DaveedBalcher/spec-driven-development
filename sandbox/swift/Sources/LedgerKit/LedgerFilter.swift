import Foundation

/// Selects transactions with a `Query` value.
public enum LedgerFilter {
    /// What to keep.
    ///
    /// Every field is optional and an unset field means "do not narrow on
    /// this". An empty set is not the same as `nil`: an empty set matches
    /// nothing, which is what a UI with every checkbox cleared should do.
    public struct Query: Equatable, Sendable {
        /// Keep only these statuses. `nil` keeps every status.
        public var statuses: Set<TransactionStatus>?
        /// Keep only these categories. `nil` keeps every category.
        public var categories: Set<TransactionCategory>?
        /// Keep only transactions posted on or after this instant.
        public var postedFrom: Date?
        /// Keep only transactions posted on or before this instant.
        public var postedThrough: Date?
        /// Keep only merchants containing this substring, matched loosely.
        public var merchant: String?

        public init(
            statuses: Set<TransactionStatus>? = nil,
            categories: Set<TransactionCategory>? = nil,
            postedFrom: Date? = nil,
            postedThrough: Date? = nil,
            merchant: String? = nil
        ) {
            self.statuses = statuses
            self.categories = categories
            self.postedFrom = postedFrom
            self.postedThrough = postedThrough
            self.merchant = merchant
        }
    }

    /// Whether one transaction satisfies every part of the query.
    public static func matches(_ transaction: Transaction, _ query: Query) -> Bool {
        if let statuses = query.statuses, !statuses.contains(transaction.status) {
            return false
        }
        if let categories = query.categories, !categories.contains(transaction.category) {
            return false
        }
        if let from = query.postedFrom, transaction.postedAt < from {
            return false
        }
        if let through = query.postedThrough, transaction.postedAt > through {
            return false
        }
        if let needle = query.merchant, !needle.isEmpty {
            if !fold(transaction.merchant).contains(fold(needle)) {
                return false
            }
        }
        return true
    }

    /// The matching transactions, in the order they were given.
    public static func apply(_ query: Query, to transactions: [Transaction]) -> [Transaction] {
        transactions.filter { matches($0, query) }
    }

    /// Case- and diacritic-insensitive form of a merchant name or a query.
    ///
    /// `Caf\u{E9} M\u{FC}ller`, `CAF\u{C9} M\u{DC}LLER KIOSK` and `cafe muller` all fold to the
    /// same text, so a learner typing plain ASCII finds the row. Done by
    /// decomposing to NFD and dropping the combining marks, plus a short table
    /// for the letters that have no decomposition. No locale is consulted:
    /// `lowercased()` is the full Unicode mapping, not a locale-sensitive one.
    public static func fold(_ text: String) -> String {
        var out = ""
        for scalar in text.lowercased().decomposedStringWithCanonicalMapping.unicodeScalars {
            // Combining diacritical marks, left behind by the decomposition.
            if scalar.value >= 0x0300 && scalar.value <= 0x036F { continue }
            switch scalar {
            case "\u{F8}": out += "o"   // o with stroke
            case "\u{E6}": out += "ae"  // ae ligature
            case "\u{DF}": out += "ss"  // sharp s
            case "\u{111}": out += "d"  // d with stroke
            case "\u{142}": out += "l"  // l with stroke
            default: out.unicodeScalars.append(scalar)
            }
        }
        return out
    }
}
