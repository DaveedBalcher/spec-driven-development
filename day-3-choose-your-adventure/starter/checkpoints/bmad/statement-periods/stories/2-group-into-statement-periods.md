---
title: 'Story 2: Group transactions into statement periods'
type: 'feature'
created: '2026-09-22'
status: 'ready-for-dev'
route: 'dispatch'
review_loop_iteration: 0
context:
  - '{project-root}/change-c-brief.md'
  - '{project-root}/_bmad-output/implementation-artifacts/statement-periods/SPEC.md'
---

> **Unblocked.** The membership-date, short-month and several-rules questions
> were answered by the human on 2026-09-22 and are recorded under **Decided**
> in the parent `SPEC.md`. Depends on story 1 for `CycleRule` and
> `StatementCycle`. Nothing has been implemented.

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** Transactions can be grouped by day but not by the statement
period the issuer will bill them on.

**Approach:** Add `StatementPeriod` and
`StatementPeriods.periods(for:cycle:)` per `change-c-brief.md`: contiguous
periods cut on the cycle's start day, each transaction placed by its posted
day, newest period first, oldest posted instant first inside each, empty
middle periods included, every status included.

## Boundaries & Constraints

**Always:**
- Surface is fixed: `public struct StatementPeriod: Equatable { start: String;
  end: String; transactions: [Transaction]; init(start:end:transactions:) }`
  and `public enum StatementPeriods { static func periods(for: [Transaction],
  cycle: StatementCycle) -> [StatementPeriod] }`.
- `start`/`end` are `YYYY-MM-DD` via `UTCDay.text`; `end` is the last day
  covered (next start minus one day).
- A transaction belongs to the period holding its posted day
  (`Transaction.postedDay`); `authorizedAt` never decides membership or
  order. LK-015 (authorized 03-04, posted 03-05) sits in the period opening
  2026-03-05; LK-011 (posted 03-04) in the period ending that day.
- A start day the month lacks is clamped to that month's last day; only the
  short month is affected. With start day 31, February 2026 opens on 02-28,
  the period before runs 01-31…02-27, and March still opens on 03-31.
- One rule governs the whole list: the rule with the latest `effectiveFrom`
  on or before the newest transaction's posted day, else the rule with the
  earliest `effectiveFrom`. Rule transitions are out of scope.
- Periods run back to back from the oldest transaction's period to the
  newest's; a middle period with nothing on it appears with `[]`.
- Newest period first. Inside a period, oldest `postedAt` instant first;
  equal instants keep input order (sort by `(postedAt, input index)` or a
  stable sort).
- Empty input → `[]`. Empty `rules` → `[]`, never a trap.
- Day arithmetic only through `UTCDay` and `ISO8601.daysSinceEpoch`; no
  `Calendar`, `DateComponents`, `Locale`.
- Linear work with an array and a dictionary; nothing lazy or cached.

**Never:**
- Compute a total or any derived amount.
- Touch `LedgerSummary`, `DaySection`, or any existing file or fixture.
- Add merchant cleanup or filtering.
- Model a rule transition; the one selected rule cuts every period.

## I/O & Edge-Case Matrix

See the parent `SPEC.md` matrix, every row not beginning `parse,`. All are
settled.

</frozen-after-approval>

## Code Map

- `Sources/LedgerKit/Transaction.swift` -- `Transaction.postedDay` places a
  transaction (`authorizedDay` is never used); `UTCDay(year:month:day:)`,
  `UTCDay(daysSinceEpoch:)`, `.text`, `Comparable`;
  `ISO8601.daysSinceEpoch(year:month:day:)`. Month length =
  `daysSinceEpoch(y, m+1, 1) - daysSinceEpoch(y, m, 1)`, rolling month 13 to
  January of `y+1`. Do not modify.
- `Sources/LedgerKit/StatementCycle.swift` -- story 1's `CycleRule` /
  `StatementCycle`; selecting the one governing rule happens here in story 2.
- `Sources/LedgerKit/LedgerSummary.swift` -- `byDay` bucketing and
  oldest-first sort pattern to mirror. Do not modify.
- `Tests/LedgerKitTests/GoldenFixtureTests.swift` -- `Fixture.transactions()`
  for fixture-driven cases; `ISO8601.instant(from:)` for hand-built rows. Do
  not modify.

## Tasks & Acceptance

**Execution:**
- [ ] `Sources/LedgerKit/StatementPeriods.swift` -- add `StatementPeriod` and
  `StatementPeriods.periods`: select the one governing rule, compute each
  transaction's period start from its posted day (`min(startDay,
  monthLength)` in its month, else previous month), walk contiguous starts
  oldest→newest building periods, reverse.
- [ ] `Tests/LedgerKitTests/StatementPeriodsTests.swift` -- one behaviour per
  test: the brief's worked example; empty middle period; year boundary;
  fixture × `first-of-month` is one period; fixture × `standard` splits at
  03-04/03-05 with LK-011 in the older period and LK-015 in the newer; LK-014
  before LK-015 by posted instant; fixture × `month-end` is one period
  `02-28…03-30`; start day 31 across April; start day 31 across February
  2026; leap February 2028; declined rows present; same-day ordering; empty
  input; empty rules; two-rule cycle picks the later effective rule;
  all-future rules pick the earliest. A small test helper builds a
  `Transaction` from an id and two ISO instants.

**Acceptance Criteria:**
- Given start day 5 and transactions on 2026-05-02, 05-12 and 05-30, when
  periods are requested, then the result is `[2026-05-05…2026-06-04: [05-12,
  05-30]], [2026-04-05…2026-05-04: [05-02]]`.
- Given transactions on 2026-01-10 and 2026-03-20 with start day 5, when
  periods are requested, then three periods return and the middle one has an
  empty list, with each `end` one day before the previous element's `start`.
- Given the 20 fixture transactions and `first-of-month`, when periods are
  requested, then exactly one period `2026-03-01…2026-03-31` holds all 20.
- Given the 20 fixture transactions and `standard`, when periods are
  requested, then LK-001…LK-013 fill `2026-02-05…2026-03-04` and
  LK-014…LK-020 fill `2026-03-05…2026-04-04`, each list oldest posted
  instant first.
- Given start day 31 and transactions posted 2026-02-10 and 2026-03-01, when
  periods are requested, then the result is `[2026-02-28…2026-03-30: [03-01]],
  [2026-01-31…2026-02-27: [02-10]]`.
- Given rules `(2026-01-01, 5)` and `(2026-03-01, 15)` and a newest
  transaction posted 2026-03-20, when periods are requested, then every
  period is cut on the 15th.
- Given `swift test`, when run, then the summary shows `0 failures`.

## Implementation Notes

## Spec Change Log

## Review Triage Log

## Verification

**Commands:**
- `swift test` -- expected: `0 failures (0 unexpected)`, 1 skipped, count
  above the story 1 total.
- `git status --short -- Sources Tests` -- expected: only story 1's and this
  story's new files, plus the pre-existing untracked `cycle-config.tsv`.
- `grep -rn "Calendar\|DateComponents\|Locale" Sources/` -- expected: no
  matches.
