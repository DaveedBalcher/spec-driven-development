# Statement periods

The app groups a customer's transactions by day. That reads well for the last
few days and badly at the end of the month, because the question people ask is
"is this on the statement I am about to pay?" A day tells them nothing about
that. We want the ledger grouped into statement periods, the way the card
issuer cuts them.

This is written the way the ticket arrived. It says what we want, not how to
build it, and it does not tell you when you are finished. Turning it into
something checkable is the job.

## How a statement cycle works

A statement cycle has a start day: the day of the month a new period opens. A
customer whose cycle starts on the 5th has a period that runs from the 5th of
one month to the day before the 5th of the next. Operations set the start day
per customer and can set it to any day from the 1st to the 31st.

A cycle configuration reaches us as a small tab-separated table with a header
row and three columns: the name of the configuration, the date a rule takes
effect, and the start day that rule uses. Every configuration we ship today
carries one rule.

## What we want back

Given a customer's transactions and their cycle configuration, give us the
statement periods those transactions fall into. For each period: the date it
starts, the date it ends, and the transactions on it. Dates are text in the
`YYYY-MM-DD` shape the day sections already use, and the end date is the last
day the period covers, not the first day of the next one.

The newest period comes first, the way a statement list reads. The periods run
back to back, no gap and no overlap, from the period holding the oldest
transaction through to the period holding the newest; a period in the middle
with nothing on it still appears, with an empty list of transactions. Inside a
period the transactions read oldest first. Every transaction appears whatever
its status — a declined attempt is one of the things customers go looking for.

A transaction carries an authorized date and a posted date, and on plenty of
rows those are not the same day.

## The names to use

Other people's tests are written against this surface, so these names and
parameters are fixed. Everything behind them is yours.

```swift
public struct CycleRule: Equatable {
    public var effectiveFrom: String   // YYYY-MM-DD
    public var startDay: Int           // 1 through 31
    public init(effectiveFrom: String, startDay: Int)
}

public struct StatementCycle: Equatable {
    public var rules: [CycleRule]
    public init(rules: [CycleRule])
    public static func parse(tsv: String, named name: String) -> StatementCycle?
}

public struct StatementPeriod: Equatable {
    public var start: String           // YYYY-MM-DD, the first day covered
    public var end: String             // YYYY-MM-DD, the last day covered
    public var transactions: [Transaction]
    public init(start: String, end: String, transactions: [Transaction])
}

public enum StatementPeriods {
    public static func periods(for transactions: [Transaction], cycle: StatementCycle) -> [StatementPeriod]
}
```

```kotlin
data class CycleRule(val effectiveFrom: String, val startDay: Int)

data class StatementCycle(val rules: List<CycleRule>) {
    companion object {
        fun parse(tsv: String, name: String): StatementCycle?
    }
}

data class StatementPeriod(
    val start: String,
    val end: String,
    val transactions: List<Transaction>,
)

object StatementPeriods {
    fun periods(transactions: List<Transaction>, cycle: StatementCycle): List<StatementPeriod>
}
```

`parse` is handed the whole table as text and the name of one configuration. It
hands back that configuration's rules, and nothing when the table holds no rows
under that name. Reading the file from disk is the caller's problem, not yours.

## A worked example

A customer on a cycle that starts on the 5th has three transactions, each of
them authorized and posted on the same day: 2 May 2026, 12 May 2026 and
30 May 2026.

Two periods come back. First in the list: 2026-05-05 through 2026-06-04,
holding the 12 May and the 30 May transactions in that order. Second:
2026-04-05 through 2026-05-04, holding the 2 May one.

## Not in this change

No totals. The per-day totals we already compute stay where they are, and a
statement period carries transactions only. The day grouping keeps working
exactly as it does now — this sits beside it. LEDGER-7 stays open; it is not
yours to fix here.
