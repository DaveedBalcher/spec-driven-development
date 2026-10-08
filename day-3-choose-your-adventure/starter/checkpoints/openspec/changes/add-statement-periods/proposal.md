# Proposal

## Why

The app groups a customer's ledger by posted day, which answers "what happened
on Tuesday" but not the question people ask at the end of the month: "is this on
the statement I am about to pay?" The card issuer cuts statements into cycles
that start on a configured day of the month, and the ledger needs to be
groupable the same way. The brief is `change-c-brief.md` at the package root.

## What Changes

- Add a **statement cycle configuration** value: an ordered list of rules, each
  carrying the date the rule takes effect (`YYYY-MM-DD`) and the day of the
  month a period opens (1 through 31).
- Add a **parser** that takes a whole tab-separated cycle table as text plus
  the name of one configuration and hands back that configuration's rules, or
  nothing when the table holds no usable rows under that name. A row that does
  not parse is skipped. Reading the file from disk stays the caller's job.
- Add a **statement period** value: a start date, an end date (both
  `YYYY-MM-DD` text, the end being the last day covered) and the transactions
  on it.
- Add a **grouping function** that, given transactions and a cycle, returns
  the statement periods they fall into: newest period first, back to back with
  no gap and no overlap from the period holding the oldest transaction through
  the period holding the newest, empty periods in the middle included,
  transactions inside a period oldest first, every status present. A
  transaction belongs to the period holding its **posted** date. A start day
  the month does not have is clamped to that month's last day. The cycle's
  single rule governs every period; multi-rule cycles are out of scope.
- The public names and parameters are fixed by the brief because other
  people's tests are written against them: `CycleRule`, `StatementCycle`,
  `StatementCycle.parse(tsv:named:)`, `StatementPeriod` and
  `StatementPeriods.periods(for:cycle:)`.
- Nothing about the existing day grouping changes. `LedgerSummary.byDay` and
  `DaySection` keep working exactly as they do now; statement periods sit
  beside them.

Not in this change: totals of any kind on a period, changes to the per-day
totals, behaviour of a cycle with two or more rules (see OQ-3 below), and
LEDGER-7 (the JPY decimal-places bug stays open and gated).

## Capabilities

### New Capabilities

- `statement-cycle`: what a cycle configuration is and how one is read out of
  the tab-separated cycle table by name.
- `statement-periods`: how a customer's transactions are cut into statement
  periods for a given cycle: period boundaries, ordering, contiguity, and
  which transactions appear.

### Modified Capabilities

None. The project has no main specs yet (`openspec list --specs` is empty), and
the existing day-grouping behaviour is untouched.

## Impact

- **New source files** under `Sources/LedgerKit/`: one for the cycle
  configuration and its parser, one for the period value and the grouping
  function. No existing source file needs to change.
- **New test files** under `Tests/LedgerKitTests/`, plus a small addition to the
  fixture loader in `GoldenFixtureTests.swift` so tests can read the cycle
  table the same way they read the transactions fixture.
- **Fixtures**: `Tests/LedgerKitTests/Fixtures/cycle-config.tsv` already exists
  (untracked) with three configurations: `standard` (start day 5),
  `month-end` (start day 31) and `first-of-month` (start day 1). This change
  reads it and does not edit it. `transactions.tsv` is not touched.
- **Package manifest**: no change. `Package.swift` already excludes the
  `Fixtures` directory from resource processing.
- **Dependencies**: none added. Date arithmetic reuses the existing
  hand-rolled `UTCDay` and `ISO8601.daysSinceEpoch` helpers; no `Calendar`,
  `DateFormatter`, `Locale` or ICU anywhere, per the module rule.
- **Lane**: this checkout is the Swift lane only (there is no
  `src/main/kotlin/` here), so every code change lands in
  `Sources/LedgerKit/` and `Tests/LedgerKitTests/`. The Kotlin lane is a
  separate checkout and is not part of this change.
- **Public API**: additive only. No existing signature changes.

## Decisions on what the brief left open

The brief left four behaviours undetermined. They were raised as open
questions OQ-1 through OQ-4 and have been decided as follows. The identifiers
are kept so that `design.md` and `tasks.md` can refer to them. Each decision is
pinned by scenarios in the delta specs; nothing in this change is blocked.

### OQ-1. Placement date: the posted date

A transaction belongs to the period that contains its **posted** date (the UTC
calendar date of `postedAt`, the same date the day grouping uses). The
authorized date never decides membership, for any status. Inside a period,
transactions are ordered by `postedAt`. Fixture row `LK-015`, authorized
`2026-03-04` and posted `2026-03-05`, belongs to the `standard` period that
opens on `2026-03-05` (`2026-03-05..2026-04-04`). Pinned in
`specs/statement-periods/spec.md`, "A transaction is placed by its posted
date".

### OQ-2. Short months: clamp the start day to the month's last day

A start day the month does not have is clamped to the last day of that month.
A cycle with start day 31 opens its February 2026 period on `2026-02-28`, and
the period before it runs `2026-01-31` through `2026-02-27`. Clamping only
affects the month that is short: March still opens on the 31st, so the
February period runs `2026-02-28` through `2026-03-30`. Leap years clamp to
`02-29`. Under the shipped `month-end` configuration every fixture row falls
in `2026-02-28..2026-03-30`. Pinned in `specs/statement-periods/spec.md`, "A
start day the month does not have is clamped to the month's last day".

### OQ-3. Rule combination: single rule only

Every configuration shipped today carries exactly one rule, and this change
specifies the single-rule behaviour only. That rule's start day governs every
period whatever the transaction dates: a transaction dated before the rule's
`effectiveFrom` still falls in a period generated by that rule, and
`effectiveFrom` never cuts a period short. A configuration with zero rules
parses to nothing (the parser never returns an empty rule list), and grouping
with a hand-built zero-rule cycle returns an empty list. Cycles with two or
more rules are out of scope for this change: no behaviour is specified or
tested for them. Pinned in `specs/statement-periods/spec.md`, "A cycle's
single rule governs every period".

### OQ-4. Malformed table rows: skip the row

A row that does not parse (other than three fields, an `effectiveFrom` that is
not `YYYY-MM-DD`, a start day that is not an integer from 1 through 31) is
skipped and does not affect the rows around it. A name with no usable rows
yields nothing, exactly as a name with no rows does. Pinned in
`specs/statement-cycle/spec.md`, "A configuration is read from the cycle table
by name".
