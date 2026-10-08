# Design

## Context

See `proposal.md` for motivation. What shapes the approach:

- **The public surface is fixed by the brief.** `CycleRule`, `StatementCycle`
  (with `parse(tsv:named:)`), `StatementPeriod` and `StatementPeriods`
  (with `periods(for:cycle:)`) are the names other people's tests use.
  Everything behind them is ours.
- **No locale, calendar or formatting API.** The module rule (README, "The
  rule this module rests on") forbids `Calendar`, `DateFormatter`, `Locale`,
  `NumberFormatter` and ICU. `Transaction.swift` already provides
  hand-rolled `UTCDay` (civil date from a day number and back, plus `text`
  as `YYYY-MM-DD`) and `ISO8601.daysSinceEpoch(year:month:day:)`. Both are
  public and are the only date arithmetic this change needs.
- **Existing grouping precedent.** `LedgerSummary.swift` holds a value type
  (`DaySection`) and an `enum` namespace with one static function
  (`byDay`). It buckets by `Transaction.postedDay` and sorts each bucket by
  `postedAt`.
- **Fixtures.** `Tests/LedgerKitTests/Fixtures/cycle-config.tsv` already
  exists with three configurations. `GoldenFixtureTests.swift` owns the
  `Fixture` loader, which finds files next to the test source via
  `#filePath`. `Package.swift` excludes the `Fixtures` directory, so a new
  fixture file needs no manifest change.
- **Style.** `CLAUDE.md` asks for `LK`-prefixed type names, no `enum`
  namespaces, tabs and braces on their own line. None of the shipped code
  does any of that (4-space indent, K&R braces, `enum LedgerSummary`,
  unprefixed `Transaction`), the file describes itself as stale, and the
  brief's fixed names would violate it anyway. New code follows the shipped
  code and the brief, and this is called out so a reviewer does not spend
  comments on it.
- **Baseline.** The README documents the suite as
  `Executed 34 tests, with 1 test skipped and 0 failures`. The skipped test
  is the LEDGER-7 gate and stays skipped.

## Goals / Non-Goals

**Goals:**
- Add the four public types with exactly the brief's signatures, in new
  files, without touching any existing source file.
- Reuse the existing day-number arithmetic so period boundaries are
  time-zone- and locale-independent by construction.
- Keep the algorithm linear in the number of transactions plus the number
  of periods spanned, using only arrays and a dictionary.

**Non-Goals:**
- Any change to `LedgerSummary`, `DaySection`, `LedgerFilter`, `Money` or
  `TransactionFormatter`.
- Totals on a period (the brief excludes them).
- Reading files from disk inside the library.
- Cycles with two or more rules. `proposal.md` (OQ-3) scopes this change to
  the single-rule cycles that ship today; nothing here specifies, tests or
  special-cases a multi-rule cycle.

## Decisions

### D1. Two new source files, mirroring `LedgerSummary.swift`

- `Sources/LedgerKit/StatementCycle.swift` holds `CycleRule` and
  `StatementCycle` (including `parse`).
- `Sources/LedgerKit/StatementPeriods.swift` holds `StatementPeriod` and the
  `StatementPeriods` namespace.

Rationale: the shipped module already pairs a result value with its grouping
namespace in one file, and the parser belongs with the type it produces.
Alternative considered: one file per type (four files) per `CLAUDE.md`. Rejected
because the shipped code does not do it and it spreads forty lines over four
files.

### D2. Both structs conform to `Equatable`, `Hashable` and `Sendable`, like `Transaction`

The brief requires `Equatable`. Adding `Hashable` and `Sendable` costs nothing
(every stored property already conforms) and matches `Transaction` and
`DaySection`. Alternative: `Equatable` only. Rejected as needlessly narrower
than the neighbours.

### D3. `YYYY-MM-DD` parsing is a small internal `UTCDay` extension in `StatementCycle.swift`

A hand-rolled failable initializer `UTCDay(text:)` accepts exactly ten
characters, `dddd-dd-dd`, digits only, in the style of `ISO8601.instant(from:)`,
and is declared `internal` (not public) at the bottom of
`StatementCycle.swift` under `// MARK: -`. It is needed to read `effectiveFrom`
and by tests to build dates from the strings the spec uses.

Alternative considered: adding it to `Transaction.swift` beside `ISO8601`.
Rejected so the diff stays inside new files; it can move later if a third
caller appears. Alternative: parse with `DateFormatter`. Forbidden by the
module rule.

The same initializer is what decides whether a table row's `effectiveFrom`
parses (OQ-4): `parse` feeds the second field through it, and a `nil` result
means the row is skipped (see D6). The check is shape-only, ten characters in
the `dddd-dd-dd` pattern; it does not reject an impossible calendar date such
as `2026-02-30`, and no scenario asks it to.

### D4. Periods are computed on day numbers, not on `Date` or on strings

Internally a period is a pair of day numbers (`ISO8601.daysSinceEpoch`
counting from 1970-01-01). For a start day `S`:

1. The opening day of month `(y, m)` is `min(S, daysIn(y, m))`, where
   `daysIn(y, m)` is `daysSinceEpoch(next month, 1) - daysSinceEpoch(y, m, 1)`.
   That single `min` is the whole of the short-month rule (OQ-2): a month
   that lacks day `S` opens on its last day, a month that has it opens on
   `S`, and leap years fall out of the subtraction without a table.
2. The start of the period holding day number `n`: convert `n` to a
   `UTCDay`; if its `day >= opening(year, month)`, the start is
   `daysSinceEpoch(year, month, opening(year, month))`, otherwise the same
   for the previous month, wrapping December to the previous year.
3. The next period start is `opening` applied to the following month.
4. The end of a period is the next period's start minus one day.

Worked through for `S = 31`: January 2026 opens on the 31st, February 2026 on
the 28th, March on the 31st, April on the 30th, so the periods are
`01-31..02-27`, `02-28..03-30`, `03-31..04-29`, `04-30..05-30`, which is what
the clamping scenarios in `specs/statement-periods/spec.md` assert.

Rendering happens once, at the end, via `UTCDay(daysSinceEpoch:).text`.
Comparing day numbers is what makes "no gap, no overlap" a single subtraction
in a test rather than string arithmetic.

Alternative considered: work in `Date` and compare instants. Rejected because a
period is a calendar concept and the day-number form makes the boundary
arithmetic exact and time-zone-free. Alternative for short months: roll the
opening forward to the 1st of the next month. Rejected by decision OQ-2, and
it would make a `month-end` cycle skip February entirely.

### D5. The grouping algorithm

1. If the input is empty, or the cycle has no rules, return `[]`.
2. Take `S` from the cycle's first rule (see D9).
3. For each transaction, take its placement day number: the UTC day of
   `postedAt`, computed as `UTCDay(instant: postedAt)` and therefore the same
   day `Transaction.postedDay` renders (decision OQ-1). `authorizedAt` is not
   read anywhere in the grouping.
4. Find the smallest and largest placement day numbers. Compute the period
   start for the smallest; walk forward month by month generating
   `(start, end)` pairs until a period's start is past the largest.
5. Bucket transactions by period start (a dictionary keyed by day number).
6. For each period in forward order, sort its bucket by `postedAt` with a
   stable sort (ties keep input order; Swift's `sort` is stable, and the test
   for the tie case pins that), build the `StatementPeriod`, then reverse the
   list so the newest is first.

Placement and ordering by `postedAt` is the same choice `LedgerSummary.byDay`
already makes, so a statement period and the day sections inside it always
agree about which transactions they hold. Alternative considered: place by
`authorizedAt`, or by `authorizedAt` for declined rows only. Rejected by
decision OQ-1; the fixture test on `LK-015` fails if either creeps in.

Cost is linear in transactions plus periods spanned. No caching, no laziness,
per the performance note in `CLAUDE.md`.

### D6. The parser is positional and forgiving about blank lines only

`parse` splits on `\n`, drops empty lines, skips the first non-empty line as
the header, splits each remaining line on `\t`, and considers rows whose
first field equals `name` exactly. A considered row is kept only when it has
exactly three fields, its second field passes `UTCDay(text:)` (D3), and its
third field parses as an `Int` in `1...31`; any other row is skipped and the
rows around it are unaffected (decision OQ-4). It returns `nil` when no row
was kept, so a cycle with zero rules never comes out of `parse`. This is the
same reading discipline `Fixture.rows` uses for `transactions.tsv`
(positional fields, header skipped by index).

Rationale: the brief fixes the column order, so matching by header text would
add a failure mode without a use. Alternative considered: match columns by
header name. Rejected for that reason. Alternative for malformed rows: return
`nil` for the whole table. Rejected by decision OQ-4; skipping keeps one bad
line in an operations file from taking every configuration down with it.
Rows under other names are not validated, since nothing reads them.

### D7. Tests read the cycle table through the shared `Fixture` loader

Add `Fixture.cycleConfigText()` (a `static func` returning the file's contents
as `String`) next to `Fixture.url` in `GoldenFixtureTests.swift`, so both
fixture files are located the same way. Tests then call
`StatementCycle.parse(tsv: text, named: "standard")`.

Alternative: a private loader in the new test file. Rejected because the
`Fixture` enum is where fixture location already lives.

### D8. Test files and naming

- `Tests/LedgerKitTests/StatementCycleTests.swift`
- `Tests/LedgerKitTests/StatementPeriodsTests.swift`

Tests are named for behaviour (`testDateBeforeStartDayFallsInPreviousPeriod`),
one assertion each where practical, using small hand-built transactions whose
`authorizedAt` and `postedAt` are the same instant unless the test is
specifically about placement or ordering by posted date, in which case the
two dates are deliberately different and the test name says so. Dates in
tests come from `ISO8601.instant(from:)` with a `T12:00:00Z` time so they sit
well away from a day boundary.

### D9. Only the first rule is read

The grouping reads `cycle.rules.first` for its start day and ignores that
rule's `effectiveFrom` (decision OQ-3): the single shipped rule governs every
period, including periods before its effective date, so a transaction posted
before `effectiveFrom` is still placed. An empty `rules` list returns `[]`
from `periods(for:cycle:)`; `parse` never produces one (D6), so this only
arises from the public initializer. A cycle with two or more rules is out of
scope: the code reads the first rule and does nothing else, no test pins
that, and a later change that adds rule transitions owns the behaviour.

Alternative considered: `precondition` on a multi-rule cycle. Rejected because
the brief's public initializer accepts any list and a library should not trap
on input it was told to accept.

## Risks / Trade-offs

- [Placement date regresses to `authorizedAt` in a later edit] → the test on
  fixture row `LK-015` with the `standard` cycle (task 3.1) pins the posted
  date visibly, so a wrong field fails by transaction id.
- [Short-month arithmetic off by one] → the clamping scenarios cover a
  28-day, a 29-day and a 30-day month plus the month after each, and the
  four-period contiguity scenario for start day 31 (task 3.2) catches a
  clamp that leaks into the following month.
- [Multi-rule cycles are out of scope but constructible] → D9 reads the first
  rule and states that nothing else is specified; the proposal's "Not in this
  change" list says so, so a reviewer is not surprised by the absence of a
  test.
- [Style conflict between `CLAUDE.md` and shipped code] → follow the shipped
  code and the brief; noted above so it is not relitigated in review.
- [Stable-sort assumption for equal instants] → a test with two transactions
  on the same instant asserts input order is preserved.
- [Kotlin lane parity] → the Kotlin lane is not in this checkout. Behaviour
  is specified in the delta specs in lane-neutral terms so the same tests can
  be written there later.
