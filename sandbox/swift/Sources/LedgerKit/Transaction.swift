import Foundation

/// Where a transaction is in its lifecycle.
public enum TransactionStatus: String, CaseIterable, Hashable, Sendable {
    case pending
    case posted
    case declined
}

/// The spending bucket a transaction falls in.
public enum TransactionCategory: String, CaseIterable, Hashable, Sendable {
    case groceries
    case transport
    case dining
    case bills
    case other
}

/// One line on a statement.
///
/// `amountMinor` is an integer in the currency's minor units — cents for USD,
/// fils for BHD, whole yen for JPY. Negative is a debit (money leaving the
/// account), positive is a credit (money coming back). A decimal point never
/// appears in this value; it only appears in rendered text.
public struct Transaction: Equatable, Hashable, Sendable {
    public var id: String
    public var postedAt: Date
    public var authorizedAt: Date
    public var merchant: String
    public var amountMinor: Int
    public var currency: String
    public var status: TransactionStatus
    public var category: TransactionCategory

    public init(
        id: String,
        postedAt: Date,
        authorizedAt: Date,
        merchant: String,
        amountMinor: Int,
        currency: String,
        status: TransactionStatus,
        category: TransactionCategory
    ) {
        self.id = id
        self.postedAt = postedAt
        self.authorizedAt = authorizedAt
        self.merchant = merchant
        self.amountMinor = amountMinor
        self.currency = currency
        self.status = status
        self.category = category
    }

    /// The UTC calendar date of `postedAt`, as `YYYY-MM-DD`.
    public var postedDay: String {
        UTCDay(instant: postedAt).text
    }

    /// The UTC calendar date of `authorizedAt`, as `YYYY-MM-DD`.
    public var authorizedDay: String {
        UTCDay(instant: authorizedAt).text
    }
}

/// A calendar date in UTC.
///
/// Derived by arithmetic on seconds-since-epoch rather than through `Calendar`,
/// so the answer never depends on the machine's time zone or locale.
public struct UTCDay: Equatable, Hashable, Comparable, Sendable {
    public var year: Int
    public var month: Int
    public var day: Int

    public init(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day
    }

    public init(instant: Date) {
        let seconds = Int(instant.timeIntervalSince1970.rounded(.down))
        // Floor division: -1 second is still the day before the epoch.
        var days = seconds / 86_400
        if seconds % 86_400 < 0 { days -= 1 }
        self = UTCDay(daysSinceEpoch: days)
    }

    /// Civil date from a day number, counting days from 1970-01-01.
    public init(daysSinceEpoch: Int) {
        let z = daysSinceEpoch + 719_468
        let era = (z >= 0 ? z : z - 146_096) / 146_097
        let dayOfEra = z - era * 146_097
        let yearOfEra =
            (dayOfEra - dayOfEra / 1_460 + dayOfEra / 36_524 - dayOfEra / 146_096) / 365
        let y = yearOfEra + era * 400
        let dayOfYear = dayOfEra - (365 * yearOfEra + yearOfEra / 4 - yearOfEra / 100)
        let mp = (5 * dayOfYear + 2) / 153
        let d = dayOfYear - (153 * mp + 2) / 5 + 1
        let m = mp < 10 ? mp + 3 : mp - 9
        self.year = m <= 2 ? y + 1 : y
        self.month = m
        self.day = d
    }

    /// `YYYY-MM-DD`, zero-padded by hand.
    public var text: String {
        "\(UTCDay.pad(year, width: 4))-\(UTCDay.pad(month, width: 2))-\(UTCDay.pad(day, width: 2))"
    }

    public static func < (lhs: UTCDay, rhs: UTCDay) -> Bool {
        (lhs.year, lhs.month, lhs.day) < (rhs.year, rhs.month, rhs.day)
    }

    private static func pad(_ value: Int, width: Int) -> String {
        var digits = String(value)
        while digits.count < width { digits = "0" + digits }
        return digits
    }
}

/// Parsing for the ISO-8601 instants the fixture stores.
///
/// Only the shape the fixture uses is supported: `YYYY-MM-DDTHH:MM:SSZ`.
/// Parsing is hand-rolled so the two lanes agree on every boundary without
/// either of them consulting a locale.
public enum ISO8601 {
    public static func instant(from text: String) -> Date? {
        let scalars = Array(text.unicodeScalars)
        guard scalars.count == 20, scalars[19] == "Z",
              scalars[4] == "-", scalars[7] == "-", scalars[10] == "T",
              scalars[13] == ":", scalars[16] == ":"
        else { return nil }

        guard let year = number(scalars, 0, 4),
              let month = number(scalars, 5, 7),
              let day = number(scalars, 8, 10),
              let hour = number(scalars, 11, 13),
              let minute = number(scalars, 14, 16),
              let second = number(scalars, 17, 19)
        else { return nil }

        let days = daysSinceEpoch(year: year, month: month, day: day)
        let seconds = days * 86_400 + hour * 3_600 + minute * 60 + second
        return Date(timeIntervalSince1970: TimeInterval(seconds))
    }

    /// Day number for a civil date, counting days from 1970-01-01.
    public static func daysSinceEpoch(year: Int, month: Int, day: Int) -> Int {
        let y = month <= 2 ? year - 1 : year
        let era = (y >= 0 ? y : y - 399) / 400
        let yearOfEra = y - era * 400
        let mp = month > 2 ? month - 3 : month + 9
        let dayOfYear = (153 * mp + 2) / 5 + day - 1
        let dayOfEra = yearOfEra * 365 + yearOfEra / 4 - yearOfEra / 100 + dayOfYear
        return era * 146_097 + dayOfEra - 719_468
    }

    private static func number(_ scalars: [Unicode.Scalar], _ start: Int, _ end: Int) -> Int? {
        var value = 0
        for index in start..<end {
            let scalar = scalars[index].value
            guard scalar >= 48, scalar <= 57 else { return nil }
            value = value * 10 + Int(scalar - 48)
        }
        return value
    }
}
