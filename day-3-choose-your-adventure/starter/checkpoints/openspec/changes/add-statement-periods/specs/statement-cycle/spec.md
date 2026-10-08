# Spec Delta

## Purpose

Describes a customer's statement cycle configuration: the rules that say on
which day of the month a statement period opens, and how one configuration is
read by name out of the tab-separated cycle table that operations ship.

## ADDED Requirements

### Requirement: A cycle configuration is an ordered list of rules
A statement cycle SHALL consist of an ordered list of cycle rules. Each rule
SHALL carry the date it takes effect, as `YYYY-MM-DD` text, and a start day,
the day of the month on which a new statement period opens, in the range 1
through 31. Two cycles with the same rules in the same order SHALL compare
equal.

#### Scenario: A cycle built from one rule holds that rule
- **WHEN** a cycle is built from the single rule (effective from `2026-01-01`,
  start day 5)
- **THEN** the cycle's rules are exactly that one rule, and it equals another
  cycle built from the same rule

### Requirement: A configuration is read from the cycle table by name
The parser SHALL accept the whole cycle table as text together with the name of
one configuration. The table SHALL be tab-separated, UTF-8, with a header row
followed by data rows of three fields in this order: configuration name, the
date the rule takes effect (`YYYY-MM-DD`), and the start day. Fields are never
quoted. The parser SHALL return the rules whose name field matches the given
name exactly (case-sensitive), in the order they appear in the table, and
SHALL return nothing when no data row carries that name. Blank lines SHALL be
ignored. Reading the table from disk is the caller's responsibility.

A data row that does not parse SHALL be skipped and SHALL NOT affect the rows
around it. A row does not parse when it has other than three fields, when its
second field is not `YYYY-MM-DD` text (four digits, hyphen, two digits,
hyphen, two digits), or when its third field is not an integer in the range 1
through 31. A name whose rows are all skipped SHALL yield nothing, exactly as a
name with no rows does; the parser SHALL never return a cycle with zero rules.

#### Scenario: The named configuration is present
- **WHEN** the shipped table (`Tests/LedgerKitTests/Fixtures/cycle-config.tsv`)
  is parsed for the name `standard`
- **THEN** the result is a cycle with exactly one rule, effective from
  `2026-01-01` with start day 5

#### Scenario: Each shipped configuration parses to one rule
- **WHEN** the shipped table is parsed for `month-end` and for `first-of-month`
- **THEN** `month-end` yields one rule (effective from `2026-01-01`, start day
  31) and `first-of-month` yields one rule (effective from `2026-01-01`, start
  day 1)

#### Scenario: The name is not in the table
- **WHEN** the shipped table is parsed for the name `weekly`
- **THEN** the result is nothing

#### Scenario: The name is matched exactly
- **WHEN** the shipped table is parsed for the name `Standard`
- **THEN** the result is nothing

#### Scenario: A table with only a header row
- **WHEN** a table consisting of the header line alone is parsed for any name
- **THEN** the result is nothing

#### Scenario: More than one row under a name comes back in table order
- **WHEN** a table holds two data rows named `stepped`, the first effective from
  `2026-01-01` with start day 5 and the second effective from `2026-07-01`
  with start day 20, and it is parsed for `stepped`
- **THEN** the result is a cycle whose rules are those two, in that order

#### Scenario: A row with too few fields is skipped
- **WHEN** a table holds one data row `broken`, `2026-01-01` and nothing else,
  and it is parsed for `broken`
- **THEN** the result is nothing

#### Scenario: A row whose date is not `YYYY-MM-DD` is skipped
- **WHEN** a table holds two data rows named `mixed`, the first with effective
  date `2026-1-1` and start day 5, the second with effective date `2026-02-01`
  and start day 7, and it is parsed for `mixed`
- **THEN** the result is a cycle with exactly one rule, effective from
  `2026-02-01` with start day 7

#### Scenario: A row whose start day is out of range is skipped
- **WHEN** a table holds one data row named `big` with effective date
  `2026-01-01` and start day `32`, and it is parsed for `big`
- **THEN** the result is nothing

#### Scenario: A row whose start day is not a number is skipped
- **WHEN** a table holds one data row named `word` with effective date
  `2026-01-01` and start day `five`, and it is parsed for `word`
- **THEN** the result is nothing

#### Scenario: A malformed row under another name does not affect the named configuration
- **WHEN** a table holds the data row `standard`, `2026-01-01`, `5` followed by
  the two-field row `other`, `2026-01-01`, and it is parsed for `standard`
- **THEN** the result is a cycle with exactly one rule, effective from
  `2026-01-01` with start day 5
