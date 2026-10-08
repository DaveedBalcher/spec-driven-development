# Spec Delta

## Purpose

Cuts a customer's transactions into statement periods the way the card issuer
cuts them, so a ledger can be read as "which statement is this on" rather than
"which day did this happen". Sits beside the existing day grouping and does not
replace it.

In every scenario below, "a transaction on `D`" means a transaction whose
posted date is `D`; its authorized date is also `D` unless the scenario says
otherwise. "The cycle starts on the Nth" means a cycle with exactly one rule,
effective from `2026-01-01`, with start day N. Multi-rule cycles are out of
scope for this change (see the rule-combination requirement below).

## ADDED Requirements

### Requirement: A transaction is placed by its posted date
The date that decides which period a transaction belongs to SHALL be the UTC
calendar date of its `postedAt`, the same date the existing day grouping uses.
The authorized date SHALL never decide membership. This applies to every
status: a pending or declined transaction is placed by its `postedAt` like any
other.

#### Scenario: Fixture row LK-015 is placed by its posted date
- **WHEN** the twenty transactions of `transactions.tsv` are grouped with the
  `standard` cycle from the shipped cycle table
- **THEN** `LK-015` (authorized `2026-03-04`, posted `2026-03-05`) is in the
  period starting `2026-03-05` and ending `2026-04-04`, not in the period
  ending `2026-03-04`

#### Scenario: The fixture splits at the start day under the standard cycle
- **WHEN** the twenty transactions of `transactions.tsv` are grouped with the
  `standard` cycle from the shipped cycle table
- **THEN** exactly two periods come back: first `2026-03-05` through
  `2026-04-04` holding `LK-014` through `LK-020` in that order, then
  `2026-02-05` through `2026-03-04` holding `LK-001` through `LK-013` in that
  order

#### Scenario: A transaction authorized before the start day and posted on it opens the new period
- **WHEN** the cycle starts on the 5th and there is one transaction authorized
  on `2026-05-04` and posted on `2026-05-05`
- **THEN** one period comes back, starting `2026-05-05` and ending `2026-06-04`

#### Scenario: A declined transaction is placed by its posted date too
- **WHEN** the cycle starts on the 5th and there is one declined transaction
  authorized on `2026-05-04` and posted on `2026-05-05`
- **THEN** one period comes back, starting `2026-05-05` and ending `2026-06-04`

### Requirement: A statement period runs from the start day to the day before the next start day
For a cycle whose start day is `S`, a statement period SHALL begin on day `S` of
a calendar month and SHALL end on the day before day `S` of the following
month. The period that holds a calendar date `D` SHALL begin on day `S` of
`D`'s month when `D`'s day of month is `S` or later, and on day `S` of the
month before `D`'s month otherwise. Periods SHALL follow the UTC calendar date
of each transaction, as the existing day grouping does. When a month has fewer
than `S` days, the clamping requirement below applies.

#### Scenario: A date on or after the start day belongs to the period opening that month
- **WHEN** the cycle starts on the 5th and there is one transaction on
  `2026-05-12`
- **THEN** one period comes back, starting `2026-05-05` and ending `2026-06-04`

#### Scenario: A date before the start day belongs to the period that opened the previous month
- **WHEN** the cycle starts on the 5th and there is one transaction on
  `2026-05-02`
- **THEN** one period comes back, starting `2026-04-05` and ending `2026-05-04`

#### Scenario: A start day of 1 gives calendar months
- **WHEN** the cycle starts on the 1st and there is one transaction on
  `2026-03-15`
- **THEN** one period comes back, starting `2026-03-01` and ending `2026-03-31`

#### Scenario: A period crosses a year boundary
- **WHEN** the cycle starts on the 5th and there is one transaction on
  `2026-12-20`
- **THEN** one period comes back, starting `2026-12-05` and ending `2027-01-04`

#### Scenario: A January date before the start day falls in the previous December's period
- **WHEN** the cycle starts on the 5th and there is one transaction on
  `2027-01-03`
- **THEN** one period comes back, starting `2026-12-05` and ending `2027-01-04`

#### Scenario: The start day itself opens a new period
- **WHEN** the cycle starts on the 5th and there are transactions on
  `2026-05-04` and `2026-05-05`
- **THEN** two periods come back, and `2026-05-04` is in the period ending
  `2026-05-04` while `2026-05-05` is in the period starting `2026-05-05`

### Requirement: A start day the month does not have is clamped to the month's last day
When a calendar month has fewer than `S` days, the period that would open on
day `S` of that month SHALL open on the last day of that month instead. The
clamp SHALL affect only the month that is short: the following month, if it
has day `S`, opens on day `S` as usual. A date `D` in a short month SHALL
belong to the period opening in that month when `D` is the clamped opening day
or later, and to the period that opened the previous month otherwise. The
number of days in a month SHALL be derived from the calendar, so leap years
clamp to the 29th of February.

#### Scenario: February clamps a start day of 31 to the 28th
- **WHEN** the cycle starts on the 31st and there is one transaction on
  `2026-02-10`
- **THEN** one period comes back, starting `2026-01-31` and ending `2026-02-27`

#### Scenario: The clamped day opens the short month's period
- **WHEN** the cycle starts on the 31st and there is one transaction on
  `2026-02-28`
- **THEN** one period comes back, starting `2026-02-28` and ending `2026-03-30`

#### Scenario: The month after a short month still opens on the start day
- **WHEN** the cycle starts on the 31st and there is one transaction on
  `2026-03-31`
- **THEN** one period comes back, starting `2026-03-31` and ending `2026-04-29`

#### Scenario: A thirty-day month clamps a start day of 31 to the 30th
- **WHEN** the cycle starts on the 31st and there is one transaction on
  `2026-04-30`
- **THEN** one period comes back, starting `2026-04-30` and ending `2026-05-30`

#### Scenario: Clamped periods stay contiguous across several months
- **WHEN** the cycle starts on the 31st and there are transactions on
  `2026-02-10` and `2026-04-30` only
- **THEN** exactly four periods come back, in this order: `2026-04-30` through
  `2026-05-30` holding the `2026-04-30` transaction; `2026-03-31` through
  `2026-04-29` holding nothing; `2026-02-28` through `2026-03-30` holding
  nothing; `2026-01-31` through `2026-02-27` holding the `2026-02-10`
  transaction

#### Scenario: A start day of 29 clamps in a non-leap February
- **WHEN** the cycle starts on the 29th and there are transactions on
  `2026-02-27` and `2026-02-28`
- **THEN** two periods come back: `2026-02-28` through `2026-03-28` holding
  the `2026-02-28` transaction, then `2026-01-29` through `2026-02-27` holding
  the `2026-02-27` transaction

#### Scenario: A leap-year February clamps to the 29th
- **WHEN** the cycle starts on the 31st and there are transactions on
  `2028-02-28` and `2028-02-29`
- **THEN** two periods come back: `2028-02-29` through `2028-03-30` holding
  the `2028-02-29` transaction, then `2028-01-31` through `2028-02-28` holding
  the `2028-02-28` transaction

#### Scenario: The fixture under the month-end cycle
- **WHEN** the twenty transactions of `transactions.tsv` are grouped with the
  `month-end` cycle from the shipped cycle table
- **THEN** exactly one period comes back, starting `2026-02-28` and ending
  `2026-03-30`, holding all twenty transactions with `LK-001` first and
  `LK-020` last

### Requirement: A cycle's single rule governs every period
Every configuration shipped today carries exactly one rule, and this change
specifies single-rule cycles only. For a cycle with one rule, that rule's start
day SHALL govern every period the grouping returns, whatever the transaction
dates: a transaction posted before the rule's `effectiveFrom` SHALL still be
placed in a period generated by that rule, and `effectiveFrom` SHALL NOT cut a
period short or bound the result. For a cycle with zero rules the result SHALL
be an empty list. Behaviour for a cycle with two or more rules is out of scope
for this change and is not specified here; no scenario in this delta uses one.

#### Scenario: A transaction before the rule's effective date is still placed by that rule
- **WHEN** the cycle has one rule effective from `2026-01-01` with start day 5
  and there is one transaction on `2025-12-20`
- **THEN** one period comes back, starting `2025-12-05` and ending `2026-01-04`

#### Scenario: A cycle with zero rules yields no periods
- **WHEN** a cycle built from an empty list of rules is used to group any
  non-empty list of transactions
- **THEN** the result is an empty list

### Requirement: Period dates are `YYYY-MM-DD` text and the end is inclusive
A period's start and end SHALL be rendered as `YYYY-MM-DD` text, zero-padded,
in the same shape the day sections use. The end SHALL be the last calendar day
the period covers, not the first day of the next period.

#### Scenario: Single-digit months and days are zero-padded
- **WHEN** the cycle starts on the 5th and there is one transaction on
  `2026-04-07`
- **THEN** the period's start is the exact text `2026-04-05` and its end is the
  exact text `2026-05-04`

### Requirement: Periods are returned newest first and are contiguous
The result SHALL list periods newest first. The periods SHALL run back to back,
with no gap and no overlap, from the period holding the oldest transaction
through the period holding the newest: each period's start SHALL be the day
after the next-older period's end. A period between those two that holds no
transaction SHALL still appear, with an empty transaction list.

#### Scenario: The worked example from the brief
- **WHEN** the cycle starts on the 5th and there are three transactions, on
  `2026-05-02`, `2026-05-12` and `2026-05-30`
- **THEN** exactly two periods come back: first `2026-05-05` through
  `2026-06-04` holding the `2026-05-12` and `2026-05-30` transactions in that
  order, then `2026-04-05` through `2026-05-04` holding the `2026-05-02`
  transaction

#### Scenario: An empty period in the middle is still listed
- **WHEN** the cycle starts on the 5th and there are transactions on
  `2026-03-02` and `2026-05-12` only
- **THEN** exactly three periods come back, in this order: `2026-05-05`
  through `2026-06-04` holding the `2026-05-12` transaction; `2026-04-05`
  through `2026-05-04` holding no transactions; `2026-02-05` through
  `2026-03-04` holding the `2026-03-02` transaction

#### Scenario: Adjacent periods leave no gap and do not overlap
- **WHEN** any result holds two or more periods
- **THEN** for every pair of neighbouring periods, the later one's start is the
  calendar day immediately after the earlier one's end

#### Scenario: Input order does not affect output order
- **WHEN** the three transactions of the worked example are supplied newest
  first instead of oldest first
- **THEN** the result is identical to the worked example's result

### Requirement: Transactions inside a period read oldest first by posted instant
Within a period, transactions SHALL be ordered by `postedAt`, oldest first, as
the day sections are. The authorized instant SHALL NOT affect the order. Two
transactions with the same `postedAt` SHALL keep the order in which they were
supplied.

#### Scenario: Oldest first inside a period
- **WHEN** the cycle starts on the 5th and there are transactions on
  `2026-05-30`, `2026-05-12` and `2026-05-20`, supplied in that order
- **THEN** the single period lists them as `2026-05-12`, `2026-05-20`,
  `2026-05-30`

#### Scenario: Posted order wins over authorized order
- **WHEN** the cycle starts on the 5th and there are two transactions: A
  authorized on `2026-05-10` and posted on `2026-05-13`, and B authorized on
  `2026-05-11` and posted on `2026-05-12`, supplied as A then B
- **THEN** the single period lists B before A

#### Scenario: Equal posted instants keep input order
- **WHEN** the cycle starts on the 5th and there are two transactions with the
  same `postedAt` on `2026-05-12`, supplied as X then Y
- **THEN** the single period lists X before Y

### Requirement: Every transaction appears exactly once whatever its status
Every supplied transaction SHALL appear in exactly one period. Pending,
posted and declined transactions SHALL all be included; no status is filtered
out.

#### Scenario: A declined transaction is on its period
- **WHEN** the cycle starts on the 5th and there are three transactions on
  `2026-05-12`, one pending, one posted and one declined
- **THEN** the single period holds all three

#### Scenario: Every fixture row lands in exactly one period
- **WHEN** the twenty transactions of `transactions.tsv` are grouped with the
  `first-of-month` cycle from the shipped cycle table
- **THEN** the set of transaction ids across all periods equals the set of
  fixture ids and no id appears twice

### Requirement: No transactions means no periods
When no transactions are supplied, the result SHALL be an empty list.

#### Scenario: Empty input
- **WHEN** an empty list of transactions is grouped with any cycle
- **THEN** the result is an empty list

### Requirement: The existing day grouping is unchanged
Adding statement periods SHALL NOT change the behaviour of the day grouping:
the day sections, their order, their membership and their totals stay exactly
as they are.

#### Scenario: Day sections still match the fixture
- **WHEN** the fixture transactions are grouped by day after this change
- **THEN** every existing day-grouping assertion in the suite still passes
  with no change to the fixture
