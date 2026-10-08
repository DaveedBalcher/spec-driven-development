# Statement periods — EARS specs

- Segment prefix: `LK-PERIOD`
- Design: `docs/intent/statement-period/statement-period-design.md`
- Code entry points: `StatementCycle.parse(tsv:named:)`,
  `StatementPeriods.periods(for:cycle:)` (not yet written)

IDs are stable. Revise text, never renumber; do not reuse a deleted ID.
`Verified by` names the test that goes red when the spec is broken.
`(no test yet)` means the tests phase of Change C has not run; every spec
here is an active gap until it does.

The specs cover a cycle carrying exactly one rule. What a cycle with two or
more rules means, and what happens to a posted day before the rule's
`effectiveFrom`, is an open question in the design doc and has no spec.

## Public surface

**LK-PERIOD-001** The module shall expose `CycleRule` (`effectiveFrom`
text, `startDay` integer), `StatementCycle` (`rules`), `StatementPeriod`
(`start`, `end`, `transactions`) and `StatementPeriods.periods(for:cycle:)`
as public, with memberwise public initializers on the three value types and
`Equatable` conformance on each.
Verified by: (no test yet).

## Cycle configuration

**LK-PERIOD-002** The cycle parser shall accept a cycle configuration table
as UTF-8, tab-separated text with one header row followed by one data row
per rule, each data row carrying exactly three unquoted fields in the order
`name`, `effectiveFrom`, `startDay`.
Verified by: (no test yet).

**LK-PERIOD-003** When given a configuration name, the cycle parser shall
return a cycle whose rules are built from every data row whose `name`
field equals the given name exactly (case-sensitive, no trimming), in the
order the rows appear in the table.
Verified by: (no test yet).

**LK-PERIOD-004** The cycle parser shall build each rule with
`effectiveFrom` equal to the row's second field as text, unchanged, and
`startDay` equal to the row's third field read as a base-10 integer.
Verified by: (no test yet).

**LK-PERIOD-005** If no data row's `name` field equals the given name, then
the cycle parser shall return `nil`.
Verified by: (no test yet).

## Start day and period boundaries

**LK-PERIOD-006** When the cycle carries exactly one rule, the
statement-period grouping shall use that rule's `startDay` as the start day
of every period it produces.
Verified by: (no test yet).

**LK-PERIOD-007** When a calendar month has at least as many days as the
cycle's start day, the statement-period grouping shall open that month's
period on the start day.
Verified by: (no test yet).

**LK-PERIOD-008** When a calendar month has fewer days than the cycle's
start day, the statement-period grouping shall open that month's period on
the last day of that month, and shall leave every other month's opening
day unchanged (a start day of 31 opens the February 2026 period on
2026-02-28 and the March 2026 period on 2026-03-31).
Verified by: (no test yet).

**LK-PERIOD-009** The statement-period grouping shall end each period on
the day before the following month's opening day, so that consecutive
periods share no day and leave no day between them (with a start day of
31, the period opening 2026-01-31 ends 2026-02-27 and the period opening
2026-02-28 ends 2026-03-30).
Verified by: (no test yet).

**LK-PERIOD-010** The statement-period grouping shall treat December as
followed by January of the next year when finding the following month's
opening day.
Verified by: (no test yet).

**LK-PERIOD-011** The statement-period grouping shall take the length of a
month from the proleptic Gregorian calendar, counting February as 29 days
in a year divisible by 4 except a century year not divisible by 400, and
28 days otherwise.
Verified by: (no test yet).

**LK-PERIOD-012** The statement-period grouping shall compute month lengths
and period boundaries by integer arithmetic on civil dates and day numbers,
without consulting `Calendar`, `TimeZone`, `Locale`, `DateFormatter` or any
locale-sensitive API.
Verified by: (no test yet).

## Membership

**LK-PERIOD-013** The statement-period grouping shall place each
transaction in the period whose `start` and `end` days, both inclusive,
contain the transaction's `postedDay` (the UTC calendar day of
`postedAt`), and shall never use `authorizedDay` to decide membership
(fixture row `LK-015`, authorized 2026-03-04 and posted 2026-03-05,
belongs on a start-day-5 cycle to the period that opens on 2026-03-05).
Verified by: (no test yet).

**LK-PERIOD-014** The statement-period grouping shall place every input
transaction in exactly one period, whether its status is `pending`,
`posted` or `declined`.
Verified by: (no test yet).

## Range and order

**LK-PERIOD-015** The statement-period grouping shall return every period
from the one containing the oldest `postedDay` in the input through the
one containing the newest, with no period missing between them; a period
in that range holding no transaction shall be returned with an empty
transaction list.
Verified by: (no test yet).

**LK-PERIOD-016** The statement-period grouping shall return no period
earlier than the one containing the oldest `postedDay` and no period later
than the one containing the newest.
Verified by: (no test yet).

**LK-PERIOD-017** The statement-period grouping shall order periods newest
first, descending by `start`.
Verified by: (no test yet).

**LK-PERIOD-018** Within a period, the statement-period grouping shall
order transactions by `postedAt`, oldest first.
Verified by: (no test yet).

**LK-PERIOD-019** When the input contains no transactions, the
statement-period grouping shall return an empty list.
Verified by: (no test yet).

## Output shape

**LK-PERIOD-020** The statement-period grouping shall render a period's
`start` and `end` as `YYYY-MM-DD` text, the year zero-padded to four
digits and the month and day to two, where `start` is the first day the
period covers and `end` is the last day it covers.
Verified by: (no test yet).

**LK-PERIOD-021** A statement period shall carry its `start`, its `end` and
its transactions, and no total.
Verified by: (no test yet; absence of API).

## Acceptance example

**LK-PERIOD-022** When given, on a cycle with a single rule of start day 5,
three transactions each authorized and posted on 2026-05-02, 2026-05-12
and 2026-05-30, the statement-period grouping shall return exactly two
periods: first 2026-05-05 through 2026-06-04 holding the 12 May transaction
then the 30 May transaction, and second 2026-04-05 through 2026-05-04
holding the 2 May transaction.
Verified by: (no test yet).
