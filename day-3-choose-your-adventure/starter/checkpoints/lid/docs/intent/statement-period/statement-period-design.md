# Statement periods — Low-Level Design

- Segment prefix: `LK-PERIOD`
- Parent: `docs/high-level-design.md`
- Specs: `docs/intent/statement-period/statement-period-specs.md`
- Code: `Sources/LedgerKit/StatementCycle.swift` (`CycleRule`,
  `StatementCycle`), `Sources/LedgerKit/StatementPeriods.swift`
  (`StatementPeriod`, `StatementPeriods`); neither file exists yet
- Tests: `Tests/LedgerKitTests/StatementPeriodsTests.swift` (not yet
  written), `Tests/LedgerKitTests/Fixtures/cycle-config.tsv`

> Designed 2026-09-22 from the Change C brief (`change-c-brief.md`). The
> public surface below is fixed by the brief because other people's tests
> are written against it; everything behind it is this module's choice.

## Purpose

Groups a customer's transactions into the statement periods their card
issuer cuts, so the app can answer "is this on the statement I am about to
pay?" A period carries the first day it covers, the last day it covers, and
its transactions oldest first. It sits beside the day grouping and replaces
nothing.

## Scope

**In:** the cycle rule and cycle configuration values, parsing a
configuration out of the tab-separated table, the calendar arithmetic that
turns a start day into period boundaries, and the grouping itself.

**Out:** totals of any kind (a period carries transactions only; day totals
stay in `LK-SUMMARY`), the day grouping (`LK-SUMMARY`, unchanged by this
leaf), rendering an amount (`LK-MONEY`), choosing which transactions to
show (`LK-FILTER`), reading the configuration file from disk (the caller's
job; in the test target, `LK-FIXTURE`'s locator pattern), and the
merchant-descriptor or ingestion questions that `ledger-sync` owns.

## Design

### Public surface

Four public types, named and shaped by the brief.

- `CycleRule { effectiveFrom: String, startDay: Int }`, `Equatable`,
  memberwise init. `effectiveFrom` is `YYYY-MM-DD` text and is stored as
  the text it arrived as. `startDay` is the day of the month a period opens,
  1 through 31.
- `StatementCycle { rules: [CycleRule] }`, `Equatable`, memberwise init,
  plus `static func parse(tsv:named:) -> StatementCycle?`.
- `StatementPeriod { start: String, end: String, transactions: [Transaction] }`,
  `Equatable`, memberwise init. `start` and `end` are `YYYY-MM-DD` and
  `end` is the last day covered, never the first day of the next period.
- `StatementPeriods.periods(for:cycle:) -> [StatementPeriod]`, a static
  function on an `enum` used as a namespace, as the brief prescribes.

### Parsing a cycle configuration

`parse` is handed the whole table as text and one configuration name. The
table is UTF-8, tab-separated and unquoted, with one header row and then
one data row per rule: `name`, `effectiveFrom`, `startDay`. The parser
splits the text into lines, drops the first line as the header without
inspecting it, and keeps every data row whose `name` field is exactly the
given name: no case folding and no trimming, because `ledger-sync` and the
platform configuration own the shape of what arrives here. Each kept row
becomes one `CycleRule` with `effectiveFrom` carried as text and `startDay`
read as a base-10 integer, and the rules come back in file order. When no
row carries the name, the result is `nil`; a header-only table therefore
yields `nil` for every name.

What the parser does with a row it cannot read (wrong field count,
non-integer `startDay`, a value outside 1 through 31, an `effectiveFrom`
that is not `YYYY-MM-DD`), with blank lines, and with `\r\n` line endings
is not settled; see Open Questions. The fixture `cycle-config.tsv` is
well-formed, `\n`-terminated, and carries one rule per name.

### The start day and where a period opens

Every calendar month has exactly one opening day. When the month has at
least `startDay` days the period opens on `startDay`; when it has fewer,
the period opens on the month's last day. Clamping touches only the short
month: a start day of 31 opens the February 2026 period on 2026-02-28 and
the March 2026 period on 2026-03-31, so the period that opened on
2026-01-31 runs through 2026-02-27 and the one that opened on 2026-02-28
runs through 2026-03-30.

A period runs from its month's opening day through the day before the
following month's opening day. Because an opening day is never later than
its month's last day and never earlier than the 1st, a period is always
between 28 and 31 days long, consecutive periods share no day, and no day
falls between them. A start day of 1 makes every period a calendar month.

### Calendar arithmetic

No `Calendar`, `TimeZone`, `Locale` or formatter, as everywhere in the
module. The leaf works in the two representations `LK-TXN` already
provides: a civil date `(year, month, day)` and a day number since
1970-01-01, converted by `UTCDay(daysSinceEpoch:)` and
`ISO8601.daysSinceEpoch(year:month:day:)`.

The length of a month is the day number of the 1st of the following month
minus the day number of its own 1st, stepping December into January of the
next year. That derives leap years, including the century rule, from the
one civil-date algorithm both language lanes already share, rather than
introducing a second month-length table that could disagree with it.

Given a posted day `(y, m, d)`: if `d` is on or after the opening day of
`(y, m)` the transaction's period opens in `(y, m)`; otherwise it opens in
the month before. The period's `start` is that opening day and its `end` is
the day number of the next month's opening day minus one, rendered through
`UTCDay.text`.

### Grouping

Membership is decided by `postedDay` (the UTC day of `postedAt`) and never
by `authorizedDay`. Fixture row `LK-015`, authorized 2026-03-04 and posted
2026-03-05, belongs on a start-day-5 cycle to the period that opens on
2026-03-05. Every transaction is placed whatever its status: a declined
attempt is one of the things a customer goes looking for on a statement.

The grouping finds the period containing the oldest posted day and the
period containing the newest, walks forward one opening at a time until
both are covered, and emits one `StatementPeriod` per step. A period with
no transaction on it is still emitted with an empty list, so the result is
contiguous from oldest to newest. Inside a period the transactions are
sorted by `postedAt` ascending; the list of periods is returned newest
first, the way a statement list reads. An empty input has no oldest posted
day and yields an empty list.

A stray `postedAt` far in the past or future makes the walk long, one empty
period per month; that is an ingestion problem, not one this leaf guards
against, in line with the module's performance notes.

For a cycle with exactly one rule, that rule's `startDay` governs every
period and its `effectiveFrom` is not consulted. What a cycle with two or
more rules means, and what a posted day before the earliest
`effectiveFrom` means, is not settled; see Open Questions.

### Worked examples

From the brief: start day 5, three transactions authorized and posted on
2026-05-02, 2026-05-12 and 2026-05-30. Two periods, in this order:
2026-05-05 through 2026-06-04 holding 12 May then 30 May; 2026-04-05
through 2026-05-04 holding 2 May.

Every row of `transactions.tsv` posts between 2026-03-02 and 2026-03-06,
which gives one expected result per configuration in `cycle-config.tsv`:

| Configuration | Start day | Periods, newest first |
| --- | --- | --- |
| `standard` | 5 | 2026-03-05 through 2026-04-04 holding `LK-014` to `LK-020`; 2026-02-05 through 2026-03-04 holding `LK-001` to `LK-013` |
| `month-end` | 31 | one period, 2026-02-28 through 2026-03-30, holding all twenty rows |
| `first-of-month` | 1 | one period, 2026-03-01 through 2026-03-31, holding all twenty rows |

The fixture never exercises a leap year; a test for 2028-02-29 needs rows
of its own.

## Interfaces

| Symbol | Kind | Notes |
| --- | --- | --- |
| `CycleRule.init(effectiveFrom:startDay:)` | public | memberwise |
| `StatementCycle.init(rules:)` | public | memberwise |
| `StatementCycle.parse(tsv:named:)` | public static | `nil` when the name has no rows |
| `StatementPeriod.init(start:end:transactions:)` | public | memberwise |
| `StatementPeriods.periods(for:cycle:)` | public static | the grouping, newest period first |

## Decisions & Alternatives

| Decision | Alternatives considered | Rationale |
| --- | --- | --- |
| Membership by posted day, never authorized day | Authorized day; the earlier of the two | Decided for Change C. A statement shows posting dates, and the day grouping and the filter already key on posted, so one date decides placement everywhere in the module. |
| Clamp a missing start day to the month's last day, in that month only | Roll the opening into the 1st of the next month; shorten every month to the shortest one | Decided for Change C. It matches how issuers cut a 31st cycle and keeps every other month opening on the configured day. |
| Derive month length from the existing day-number arithmetic | A twelve-entry table plus a hand-written leap rule | One calendar algorithm in the module; both lanes already have it, so February 2028 and the year 2100 come out the same everywhere without a second rule to test. |
| Keep the month arithmetic private to this leaf | Add a month-length helper to `UTCDay` in `LK-TXN` | Nothing else needs it yet, and adding it would cascade a change into a segment this brief does not touch. |
| Enumerate every period between oldest and newest, empty ones included | Emit only periods that hold a transaction | The brief asks for a contiguous list so a reader can see a quiet month; this is the opposite of the day grouping, which omits empty days, and the two are meant to differ. |
| Newest period first, transactions inside oldest first | Oldest period first (the day grouping's order today) | The brief fixes both orders: a statement list reads newest first, and a statement reads down the page. |
| Exact, case-sensitive name match with no trimming | Case-insensitive match; trim whitespace | Upstream owns shape; the transactions fixture loader is equally strict, and a loose match would hide a configuration typo until finance saw it. |
| Header row dropped without inspection | Validate the header's column names | Same as the transactions fixture loader; a wrong header is a fixture bug that the row parse would surface anyway. Open to reversal, see Open Questions. |
| `effectiveFrom` stored as text, not parsed to a day | Parse to a `UTCDay` at parse time | The single-rule grouping never reads it, and the brief fixes the property as `String`; parsing it belongs with the multi-rule decision. |
| Two source files, `StatementCycle.swift` and `StatementPeriods.swift` | Four files, one per public type; one file for the whole leaf | Follows the `LedgerSummary.swift` precedent of a value type beside the function that produces it, while keeping the input side (the cycle) apart from the output side (the periods). |
| No total on a period | Sum `amountMinor` as `DaySection` does | The brief excludes totals from this change, and the day grouping's totals are being redone under Change B; a period total would inherit that debate. |

## Open Questions & Future Decisions

Each of these is a behaviour the brief does not determine. None is decided
here; the specs cover only the cases the brief and the two Change C
decisions settle, and the code should not be written until these have an
answer.

1. **A cycle with more than one rule.** `rules` is an array and the table
   allows several rows per name, yet the brief only says every shipped
   configuration carries one rule. When a later rule with a different start
   day takes effect, how do the periods change over? Candidates: a day is an
   opening day when it is the opening day under the rule in force that day,
   which gives a longer or shorter transition period with no gap; or the
   old period closes the day before `effectiveFrom` and the new rule opens
   a period there; or `parse` and `periods` reject more than one rule
   until this is designed. Which rule is "in force" (latest `effectiveFrom`
   on or before the day) also needs stating.
2. **A posted day before the single rule's `effectiveFrom`.** The fixture
   never has one. Is the rule applied anyway, is the transaction dropped,
   or is that an error?
3. **`StatementCycle(rules: [])`.** The public init allows it and `parse`
   never produces it. Empty list, or a precondition failure?
4. **`startDay` outside 1 through 31.** Reachable through `CycleRule.init`
   and through a table row. Clamping would silently accept 0 or 40;
   rejecting it means `parse` returns `nil` and `periods` needs a defined
   response too.
5. **Rows the parser cannot read.** Wrong field count, non-integer
   `startDay`, `effectiveFrom` not shaped `YYYY-MM-DD`, or a blank line
   between rows. Skip the row, return `nil` for the whole table, or fail
   loudly? The transactions fixture loader skips and fails the calling
   test, but that loader lives in the test target and this parser is
   production code with no error channel beyond `nil`.
6. **Line endings and empty input.** `\r\n` would leave a `\r` on every
   `startDay`; an empty string has no header to drop. Is `\n` the only
   supported ending, as it is for the transactions fixture?
7. **Whether to validate the header row** rather than drop the first line
   blind, so a table with no header does not lose its first rule silently.
8. **Ties on `postedAt` inside a period.** The day grouping leaves this to
   whatever `sorted` produces; both lanes should agree, so a tie-breaker
   (fixture order, or `id`) may be wanted here and there together.
9. **Expected periods in the fixture.** The transactions fixture is fixed at
   ten fields, so per-row expected period columns would change
   `LK-FIXTURE-002` and the Kotlin loader. The alternative is for the period
   tests to carry the expectations in the table above.

## Verification

Specs in `statement-period-specs.md`. No test exists yet; the tests phase
should cover the brief's worked example, each configuration in
`cycle-config.tsv` against the transactions fixture, the 31st-in-February
clamp, a leap-year February, a December-to-January boundary, an empty
middle period, `LK-015`'s posted-versus-authorized placement, and the
`nil` from an unknown configuration name.
