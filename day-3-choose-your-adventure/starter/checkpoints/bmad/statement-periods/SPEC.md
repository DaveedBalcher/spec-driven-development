---
title: 'Statement periods'
type: 'feature'
created: '2026-09-22'
status: 'ready-for-dev'
route: 'dispatch'
review_loop_iteration: 0
context:
  - '{project-root}/change-c-brief.md'
---

> **Status note.** The five planning questions were answered by the human on
> 2026-09-22. Each answer is recorded under **Decided** in the frozen block
> below, and the matrix rows that depended on them are now settled. The frozen
> block is locked; only a human changes it. Nothing has been implemented.
>
> **Scope gate.** This file runs above the 1,600-token guide; the overage is
> the edge-case matrix, which was requested. The two story files are the units
> an implementer actually loads.

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** The app groups transactions by posted day. At month end the
question customers ask is "is this on the statement I am about to pay?", and a
day tells them nothing about that.

**Approach:** Add a statement-period grouping beside the day grouping. Parse a
customer's cycle configuration from a small TSV table, then bucket their
transactions by posted day into back-to-back statement periods cut on the
cycle's start day, newest period first, using the public surface fixed in
`change-c-brief.md`.

## Boundaries & Constraints

**Always:**
- Use the exact names and parameters from the brief's Swift block:
  `CycleRule`, `StatementCycle.parse(tsv:named:)`, `StatementPeriod`,
  `StatementPeriods.periods(for:cycle:)`. The brief fixes the surface even
  where it disagrees with `CLAUDE.md` style (an `enum` namespace, no `LK`
  prefix). Extra conformances (`Sendable`, `Hashable`) may be added.
- Dates are `YYYY-MM-DD` text derived through `UTCDay`; day arithmetic uses
  `ISO8601.daysSinceEpoch` and `UTCDay(daysSinceEpoch:)`. No `Calendar`,
  `DateFormatter`, `Locale` or ICU anywhere.
- `end` is the last day covered. Periods are contiguous with no gap or
  overlap from the period holding the oldest transaction to the one holding
  the newest. Empty middle periods appear with `transactions: []`.
- Output order: newest period first; inside a period oldest `postedAt`
  instant first, ties keeping input order.
- Every transaction appears regardless of `status`, including `declined`.
- Code changes stay inside `Sources/LedgerKit/` and `Tests/LedgerKitTests/`.
- Every behaviour gets a test; run `swift test` and quote the summary line.

**Decided** (human answers of 2026-09-22 to the planning questions):
- **Membership by posted day.** A transaction belongs to the period holding
  its posted day (`Transaction.postedDay`). The authorized date never decides
  membership or order. LK-015 (authorized 2026-03-04, posted 2026-03-05)
  belongs to the period that opens on 2026-03-05; LK-011 (posted 2026-03-04)
  belongs to the period that ends that day.
- **Clamp a start day the month lacks** to the last day of that month. Only
  the short month is affected. With `startDay` 31 the February 2026 period
  opens on 2026-02-28, the period before it runs 2026-01-31 through
  2026-02-27, and March still opens on 2026-03-31.
- **One rule governs the whole list:** the rule with the latest
  `effectiveFrom` on or before the newest transaction's posted day, else the
  rule with the earliest `effectiveFrom`. Every configuration shipped today
  carries exactly one rule.
- **A malformed row is skipped, not fatal.** `parse` returns the rows under
  the requested name that do parse, in file order, and returns `nil` only when
  no usable row carries that name.
- **`README.md` stays untouched.** Its stale test count and file list are a
  doc-only follow-up outside this change.

**Never:**
- Touch `LedgerSummary`, `DaySection`, `LedgerFilter`, `Money`,
  `TransactionFormatter` or `Transaction`. Day grouping keeps working as is.
- Compute totals of any kind. A period carries transactions only.
- Model a rule transition. A cycle whose rules would change the start day
  part-way through the list is out of scope; the one selected rule cuts every
  period.
- Fix or reference LEDGER-7; it stays open.
- Edit `Tests/LedgerKitTests/Fixtures/transactions.tsv` or
  `Tests/LedgerKitTests/Fixtures/cycle-config.tsv`. Read them as given.
- Add merchant cleanup, caching, laziness or a Kotlin lane (no
  `src/main/kotlin` exists in this repository).
- Edit `CLAUDE.md`, `README.md`, `KNOWN-ISSUES.md` or `Package.swift`.

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|--------------|---------------------------|----------------|
| Brief's worked example | start 5; txns 2026-05-02, 05-12, 05-30 | `[05-05…06-04: [05-12, 05-30]], [04-05…05-04: [05-02]]` | N/A |
| Empty middle period | start 5; txns 2026-01-10, 2026-03-20 | 3 periods newest first; `02-05…03-04` has `[]` | N/A |
| Year boundary | start 15; txns 2025-12-20, 2026-01-10 | one period `2025-12-15…2026-01-14` | N/A |
| Start day 1 | fixture txns, `first-of-month` | one period `2026-03-01…2026-03-31` holding all 20 | N/A |
| Fixture, `standard` (5) | all 20 fixture txns | `03-05…04-04` = LK-014…LK-020; `02-05…03-04` = LK-001…LK-013 | N/A |
| Posted day decides membership | LK-011 (posted 03-04) and LK-015 (auth 03-04, posted 03-05), start 5 | LK-011 in `02-05…03-04`; LK-015 in `03-05…04-04` | N/A |
| Posted instant decides order | LK-014 (auth 03-05 02:26, posted 03-05 02:27) and LK-015 (auth 03-04, posted 03-05 07:33), start 5 | LK-014 before LK-015 inside `03-05…04-04` | N/A |
| Fixture, `month-end` (31) | all 20 fixture txns | one period `2026-02-28…2026-03-30` holding all 20 | N/A |
| Start day > month length | start 31; txns 2026-04-29, 2026-04-30 | `04-30…05-30` and `03-31…04-29` | N/A |
| Clamp only in the short month | start 31; txns 2026-02-10, 2026-03-01 | `02-28…03-30` and `01-31…02-27` | N/A |
| Leap February | start 30; txn 2028-02-29 | period `2028-02-29…2028-03-29` | N/A |
| Declined included | LK-006, LK-017 in input | both present in their periods | N/A |
| Same-day order | two txns same posted day, later posted instant listed first | oldest posted instant first inside the period | N/A |
| No transactions | `[]`, any cycle | `[]` | N/A |
| Empty rules | `StatementCycle(rules: [])` | `[]` | no trap |
| Several rules | rules `(2026-01-01, 5)`, `(2026-03-01, 15)`; newest txn posted 2026-03-20 | every period cut on 15 | N/A |
| Rules all in the future | rules `(2027-01-01, 5)`, `(2027-06-01, 15)`; newest txn posted 2026-03-20 | every period cut on 5 (earliest `effectiveFrom`) | N/A |
| parse, name present | fixture TSV, `"standard"` | `StatementCycle(rules: [CycleRule("2026-01-01", 5)])` | N/A |
| parse, other names | fixture TSV, `"month-end"` | only that name's rows, file order | N/A |
| parse, name absent | fixture TSV, `"gold"` | `nil` | N/A |
| parse, header only / empty text | `"name\teffectiveFrom\tstartDay\n"` or `""` | `nil` | N/A |
| parse, CRLF or trailing newline | rows end in `\r\n` | parses as if `\n` | N/A |
| parse, bad row under the name | `standard 2026-01-01 5` plus a malformed `standard` row (startDay `0`, `32`, `x`; 2 or 4 columns; `effectiveFrom` not a valid `YYYY-MM-DD`) | `StatementCycle(rules: [CycleRule("2026-01-01", 5)])`; bad row skipped | never traps |
| parse, only bad rows under the name | the sole `gold` row has startDay `x` | `nil` | never traps |
| parse, bad row under another name | malformed row for `"other"`, asking `"standard"` | `standard` still parses | N/A |

</frozen-after-approval>

## Code Map

- `Sources/LedgerKit/Transaction.swift` -- `Transaction.postedDay` gives the
  `YYYY-MM-DD` that places a transaction (`authorizedDay` is never used);
  `UTCDay(year:month:day:)`, `UTCDay(daysSinceEpoch:)`, `.text`,
  `Comparable`; `ISO8601.daysSinceEpoch` for day numbers. Reuse for every
  date step; do not modify. Days in a month =
  `daysSinceEpoch(y, m+1, 1) - daysSinceEpoch(y, m, 1)` (roll m+1 = 13 to
  January of y+1), so no leap table is needed.
- `Sources/LedgerKit/LedgerSummary.swift` -- pattern to mirror: result struct
  plus `enum` namespace in one file, doc comments, `Equatable, Sendable`. Do
  not modify.
- `Tests/LedgerKitTests/GoldenFixtureTests.swift` -- `Fixture.url` /
  `Fixture.transactions()` (module-internal, reachable from other test files).
  Add a `Fixture.cycleConfigText()` helper as an extension in the new test
  file rather than editing this one.
- `Tests/LedgerKitTests/Fixtures/cycle-config.tsv` -- header
  `name effectiveFrom startDay`; rows `standard 2026-01-01 5`,
  `month-end 2026-01-01 31`, `first-of-month 2026-01-01 1`. Read-only input.
- `Tests/LedgerKitTests/Fixtures/transactions.tsv` -- 20 rows, posted days
  2026-03-02…06; rows with authorized ≠ posted day: LK-002, LK-009, LK-010,
  LK-011, LK-015. Read-only.
- `change-c-brief.md` -- the fixed public surface and worked example.

## Tasks & Acceptance

**Execution:**
- [ ] `Sources/LedgerKit/StatementCycle.swift` -- add `CycleRule` and
  `StatementCycle` with `parse(tsv:named:)` per the matrix, skipping malformed
  rows and returning `nil` only when no usable row carries the name -- story 1.
- [ ] `Tests/LedgerKitTests/StatementCycleTests.swift` -- behaviour-named
  tests for every `parse` row of the matrix, reading `cycle-config.tsv` via a
  `Fixture` extension -- story 1.
- [ ] `Sources/LedgerKit/StatementPeriods.swift` -- add `StatementPeriod` and
  `StatementPeriods.periods(for:cycle:)`: select the one governing rule, find
  each transaction's period start from its posted day (clamped start day in
  its month, else previous month), walk contiguous starts from oldest to
  newest, reverse -- story 2.
- [ ] `Tests/LedgerKitTests/StatementPeriodsTests.swift` -- tests for every
  grouping row of the matrix, hand-built transactions via
  `ISO8601.instant(from:)` plus fixture-driven cases -- story 2.

**Acceptance Criteria:**
- Given the brief's three May transactions and a start day of 5, when periods
  are requested, then exactly the two periods in the brief come back in that
  order with those transactions in that order.
- Given transactions two months apart, when periods are requested, then the
  intervening period is present with an empty transaction list and no period
  overlaps or leaves a gap.
- Given the 20 fixture transactions and `standard`, when periods are
  requested, then LK-001…LK-013 fill `2026-02-05…2026-03-04` and
  LK-014…LK-020 fill `2026-03-05…2026-04-04`, each list oldest posted
  instant first.
- Given start day 31 and transactions posted 2026-02-10 and 2026-03-01, when
  periods are requested, then the periods are `2026-02-28…2026-03-30` and
  `2026-01-31…2026-02-27`, in that order.
- Given the fixture TSV, when `parse` is asked for `standard`, then one rule
  `(2026-01-01, 5)` returns; when asked for an unknown name, then `nil`.
- Given a TSV whose `standard` rows are one well-formed and one malformed,
  when `parse` is asked for `standard`, then only the well-formed rule
  returns; given a name whose only row is malformed, then `nil`.
- Given the full suite, when `swift test` runs, then the summary reads
  `0 failures` with the pre-existing 1 skipped test and every new test counted.

## Implementation Notes

## Spec Change Log

## Review Triage Log

## Design Notes

Period start for a posted day D with start day S: let `L` be the length of
D's month and `s = min(S, L)`. If `D.day >= s` the period starts on `D` with
day `s`; otherwise it starts in the previous month on `min(S, L_prev)`. The
next start is `min(S, L_next)` in the following month; `end = next - 1 day`.
Walking starts from the oldest transaction's period to the newest is linear
and needs only an array and a dictionary keyed by start text.

Rule selection happens once, before any period is cut: pick the rule with the
latest `effectiveFrom` on or before the newest transaction's posted day; if
no rule qualifies, the one with the earliest `effectiveFrom`. Equal
`effectiveFrom` values resolve to the later row in file order.

Decisions the user would not notice, made by the planner: header line is
skipped, never validated; rules keep file order; time zone is UTC as in the
rest of the module; two source files (`StatementCycle.swift` holding
`CycleRule` + `StatementCycle`, `StatementPeriods.swift` holding
`StatementPeriod` + `StatementPeriods`), mirroring `LedgerSummary.swift`;
4-space indentation like the neighbouring files. The working tree carried
untracked inputs (`change-c-brief.md`, `cycle-config.tsv`, BMAD tooling) at
planning time; nothing tracked was modified.

## Verification

**Commands:**
- `swift test` -- expected: `Executed N tests, with 1 test skipped and 0
  failures (0 unexpected)` where N ≥ 34 + new tests; baseline is
  `Executed 34 tests, with 1 test skipped and 0 failures`.
- `git status --short -- Sources Tests` -- expected: only the four new files
  listed under Tasks (plus the pre-existing untracked `cycle-config.tsv`).
- `grep -rn "Calendar\|DateFormatter\|Locale\|NumberFormatter" Sources/` --
  expected: no matches.
