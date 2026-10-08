# Spec: pending-aware daily summary (Change B)

This is Day 1's Exercise 3 reference answer, sharpened for the runner: it adds a
Shape section (the types the Day 2 acceptance suite compiles against), orders
the per-currency totals by currency code, and states a line budget. Run this
one, even if you wrote your own on Day 1, and compare yours with it afterwards;
the acceptance suite in Exercise 2 will not compile against a different shape.

Both lanes are covered. Where a path or a command differs, the Swift lane comes
first and the Kotlin lane follows in brackets.

## Goal

A day section on the statement list tells you three things it cannot tell you
today: what has actually settled, what is still pending, and in which currency.
Declined transactions stay visible in the list and stop counting toward money.

## Non-goals

- Rendering. Nothing here changes `TransactionFormatter` or `Money`, and no
  string in this change is user-facing text.
- LEDGER-7. The JPY decimal-places bug is out of scope and stays as it is.
- Filtering. `LedgerFilter` is not touched, and no new query field is added.
- Multi-currency conversion. Two currencies are reported side by side, never
  converted into one.

## Shape

The change replaces `DaySection` and adds `CurrencyTotal`. These names and
member names are part of the contract, because the tests are written against
them.

```swift
public struct CurrencyTotal: Equatable, Sendable {
    public var currency: String      // ISO 4217, as it appears on the transaction
    public var postedMinor: Int      // signed minor units, posted rows only
    public var pendingMinor: Int     // signed minor units, pending rows only
}

public struct DaySection: Equatable, Sendable {
    public var day: String                 // YYYY-MM-DD, UTC, from postedAt
    public var transactions: [Transaction] // every row that posted that day
    public var totals: [CurrencyTotal]
}

public enum LedgerSummary {
    public static func byDay(_ transactions: [Transaction]) -> [DaySection]
}
```

```kotlin
data class CurrencyTotal(
    val currency: String,
    val postedMinor: Long,
    val pendingMinor: Long,
)

data class DaySection(
    val day: String,
    val transactions: List<Transaction>,
    val totals: List<CurrencyTotal>,
)

object LedgerSummary {
    fun byDay(transactions: List<Transaction>): List<DaySection>
    fun day(instant: Instant): String   // unchanged
}
```

`DaySection.totalMinor` goes away. It added amounts in different currencies
together, which is the behaviour this change exists to remove.

## Acceptance criteria

1. A declined transaction appears in its day's `transactions` and contributes
   to no total: neither `postedMinor` nor `pendingMinor`.
2. Each day section reports, per currency, a posted total and a pending total,
   kept separate. A pending row is never counted in `postedMinor`, and a posted
   row is never counted in `pendingMinor`.
3. Sections come back newest day first. A day with no transactions in the input
   never appears.
4. Totals are per currency: an amount in one currency is never added to an
   amount in another, and `totals` is ordered by currency code ascending.

### Criterion-to-command grid

| # | Command that fails if this is broken | Test or assertion |
| --- | --- | --- |
| 1 | `swift test` [`./gradlew test`] | `LedgerSummaryTests.testDeclinedIsListedButNotCounted` [`LedgerSummaryTest."a declined row is listed and counted nowhere"`] |
| 2 | `swift test` [`./gradlew test`] | `LedgerSummaryTests.testPendingAndPostedAreSeparate` [`LedgerSummaryTest."pending and posted totals are separate"`] |
| 3 | `swift test` [`./gradlew test`] | `LedgerSummaryTests.testSectionsAreNewestDayFirst` [`LedgerSummaryTest."days come out newest first"`] |
| 4 | `swift test` [`./gradlew test`] | `LedgerSummaryTests.testTotalsAreOnePerCurrencyInCodeOrder` [`LedgerSummaryTest."totals are one per currency in code order"`] |

## Bounds

**In bounds — may change:**

- `Sources/LedgerKit/LedgerSummary.swift`
  [`src/main/kotlin/ledgerkit/LedgerSummary.kt`]
- `Tests/LedgerKitTests/LedgerSummaryTests.swift`
  [`src/test/kotlin/ledgerkit/LedgerSummaryTest.kt`]

**Out of bounds — must not change:**

- `Tests/LedgerKitTests/Fixtures/transactions.tsv` [`Fixtures/transactions.tsv`]
- `Tests/LedgerKitTests/GoldenFixtureTests.swift`
  [`src/test/kotlin/ledgerkit/GoldenFixtureTest.kt`]
- `Tests/LedgerKitTests/KnownIssueTests.swift`
  [`src/test/kotlin/ledgerkit/KnownIssueTest.kt`]
- `Sources/LedgerKit/Money.swift`, `TransactionFormatter.swift`,
  `LedgerFilter.swift`, `Transaction.swift`
  [the matching files under `src/main/kotlin/ledgerkit/`]
- `CLAUDE.md`, `README.md`, `KNOWN-ISSUES.md`, `specs/`
- `Package.swift` [`build.gradle.kts`, `settings.gradle.kts`]

## Line budget

250 changed lines, added plus deleted, in the diff against the shipped lane
(the runner skill gives the command). Past
that, stop and ask: a rewrite this size is a design decision, not an
implementation detail.

## Verification

Swift lane:

```bash
swift test
```

Kotlin lane:

```bash
./gradlew test
```

Success is the `Executed <n> tests, with … 0 failures (0 unexpected)` line
[`BUILD SUCCESSFUL in …`].

The known-issue gate stays where it is. This command must still report the JPY
case as the only failure, and the change must not alter that:

```bash
LEDGER_RUN_KNOWN_ISSUES=1 swift test
```

```bash
LEDGER_RUN_KNOWN_ISSUES=1 ./gradlew test
```

## Stop conditions

- A file listed as out of bounds must change: stop, name the file and the
  compiler error or assertion that sent you there, change nothing.
- The same test fails twice with byte-identical output: stop and show both.
- The diff against the shipped lane passes 250 changed lines: stop and show the count.

## Definition of done

- [ ] Every numbered criterion has a test that fails without the change.
- [ ] `swift test` [`./gradlew test`] is green.
- [ ] The diff against the shipped lane names only the two files listed as in bounds,
      plus `run-log.template.md`, which setup copies in.
- [ ] No locale or number-formatting API was introduced anywhere.
- [ ] The fixture file is unchanged.
- [ ] `run-log.md` has one line per iteration and a final line naming the exit.
