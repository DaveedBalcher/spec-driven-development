# Tasks

Bounds for every task: code changes only under `Sources/LedgerKit/` and
`Tests/LedgerKitTests/`. Do not edit `Tests/LedgerKitTests/Fixtures/*.tsv`,
`Package.swift`, `CLAUDE.md`, `KNOWN-ISSUES.md` or any existing source file
under `Sources/LedgerKit/`. The four questions the brief left open (OQ-1
through OQ-4) are decided in `proposal.md`, "Decisions on what the brief left
open"; nothing below is blocked. Expected strings in the tasks come from the
scenarios in `specs/`, which are the source of truth if the two ever differ.

## 1. Cycle configuration and parser

- [ ] 1.1 Add `Sources/LedgerKit/StatementCycle.swift` with `CycleRule` and `StatementCycle` exactly as the brief declares them (plus `Hashable`, `Sendable`), and verify `swift build` succeeds
- [ ] 1.2 Add the internal `UTCDay(text:)` failable initializer at the bottom of `StatementCycle.swift` under a `// MARK: -`, and verify with a test that `"2026-05-05"` round-trips through `.text` and that `"2026-5-5"` and `"2026/05/05"` yield nil
- [ ] 1.3 Add `Fixture.cycleConfigText()` to `GoldenFixtureTests.swift`, locating `Fixtures/cycle-config.tsv` next to the test source like `Fixture.url` does, and verify a test reads three data rows from it
- [ ] 1.4 Implement `StatementCycle.parse(tsv:named:)` for well-formed rows: positional fields, header skipped, blank lines ignored, exact name match, table order kept, nil when no row matches; verify with `StatementCycleTests` covering the `standard`, `month-end` and `first-of-month` names, an absent name, a case-mismatched name, a header-only table, and a two-row name returned in order (one assertion per test)
- [ ] 1.5 Verify the cycle-configuration equality scenario: two cycles built from the same single rule compare equal (`StatementCycleTests`)
- [ ] 1.6 Implement malformed-row skipping in `parse` per design D6 (decision OQ-4) and verify with `StatementCycleTests`: a two-field row `broken\t2026-01-01` parsed for `broken` gives nil; two `mixed` rows with dates `2026-1-1` and `2026-02-01` parsed for `mixed` give exactly one rule (`2026-02-01`, 7); start day `32` parsed for its name gives nil; start day `five` gives nil; a well-formed `standard` row followed by a two-field `other` row parsed for `standard` still gives the one `standard` rule

## 2. Statement periods for a single rule where every month has the start day

These tasks use transactions whose `authorizedAt` and `postedAt` are the same
instant, and cycles with one rule whose start day exists in every month the
test touches. Placement is by the UTC day of `postedAt` (decision OQ-1) from
task 2.2 onward; group 3 adds the tests where the two dates differ.

- [ ] 2.1 Add `Sources/LedgerKit/StatementPeriods.swift` with `StatementPeriod` and the `StatementPeriods` namespace exactly as the brief declares them, and verify `swift build` succeeds
- [ ] 2.2 Implement period-start and next-period-start on day numbers per design D4 (including the `min(S, daysIn(month))` opening-day rule), placing each transaction by the UTC day of its `postedAt`, and verify with tests: `2026-05-12` on start day 5 gives `2026-05-05..2026-06-04`; `2026-05-02` gives `2026-04-05..2026-05-04`; start day 1 gives the calendar month `2026-03-01..2026-03-31`; `2026-12-20` gives `2026-12-05..2027-01-04`; `2027-01-03` gives `2026-12-05..2027-01-04`; `2026-04-07` renders exactly `2026-04-05` and `2026-05-04`
- [ ] 2.3 Implement the grouping per design D5 (first rule, bucket, fill, sort by `postedAt`, reverse) and verify with the brief's worked example: three transactions on `2026-05-02`, `2026-05-12`, `2026-05-30` with start day 5 yield exactly `[2026-05-05..2026-06-04 (12th, 30th), 2026-04-05..2026-05-04 (2nd)]`
- [ ] 2.4 Verify contiguity: transactions on `2026-03-02` and `2026-05-12` with start day 5 give three periods with the middle one (`2026-04-05..2026-05-04`) empty, and a property test asserts each period's start is the day after the next-older period's end
- [ ] 2.5 Verify ordering: transactions supplied newest first produce the same result as the worked example; inside a period they read oldest first; two transactions with the same `postedAt` keep input order
- [ ] 2.6 Verify the boundary day: transactions on `2026-05-04` and `2026-05-05` with start day 5 land in different periods, and the 5th opens the new one
- [ ] 2.7 Verify status inclusion: three transactions on `2026-05-12` (pending, posted, declined) are all on the single period; and the twenty fixture rows grouped with `first-of-month` land in exactly one period each with no id repeated or missing
- [ ] 2.8 Verify empty input returns an empty list

## 3. Placement date, short months, rule handling

- [ ] 3.1 Pin the posted-date placement (decision OQ-1) in `StatementPeriodsTests`: the fixture grouped with the `standard` cycle puts `LK-015` (authorized `2026-03-04`, posted `2026-03-05`) in `2026-03-05..2026-04-04`; the same grouping yields exactly two periods, `2026-03-05..2026-04-04` holding `LK-014` through `LK-020` in order and `2026-02-05..2026-03-04` holding `LK-001` through `LK-013` in order; a hand-built transaction authorized `2026-05-04` and posted `2026-05-05` on start day 5 lands in `2026-05-05..2026-06-04`, and so does a declined one with the same dates; two transactions A (authorized `2026-05-10`, posted `2026-05-13`) and B (authorized `2026-05-11`, posted `2026-05-12`) supplied as A then B come back as B then A
- [ ] 3.2 Pin the short-month clamp (decision OQ-2) in `StatementPeriodsTests`, all with one rule: start day 31 with a transaction on `2026-02-10` gives `2026-01-31..2026-02-27`; on `2026-02-28` gives `2026-02-28..2026-03-30`; on `2026-03-31` gives `2026-03-31..2026-04-29`; on `2026-04-30` gives `2026-04-30..2026-05-30`; transactions on `2026-02-10` and `2026-04-30` give exactly four periods `[2026-04-30..2026-05-30, 2026-03-31..2026-04-29 (empty), 2026-02-28..2026-03-30 (empty), 2026-01-31..2026-02-27]`; start day 29 with transactions on `2026-02-27` and `2026-02-28` gives `[2026-02-28..2026-03-28, 2026-01-29..2026-02-27]`; start day 31 with transactions on `2028-02-28` and `2028-02-29` gives `[2028-02-29..2028-03-30, 2028-01-31..2028-02-28]`; the fixture grouped with `month-end` gives exactly one period `2026-02-28..2026-03-30` holding all twenty rows with `LK-001` first and `LK-020` last. Adjust the D4 implementation from 2.2 if any of these fail
- [ ] 3.3 Pin single-rule handling (decision OQ-3, design D9) in `StatementPeriodsTests`: a rule effective from `2026-01-01` with start day 5 and a transaction on `2025-12-20` gives `2025-12-05..2026-01-04`; a cycle built from an empty rule list with a non-empty transaction list gives `[]`. Add no test for a cycle with two or more rules; that case is out of scope and the design says so
- [ ] 3.4 Confirm every group-2 test still passes after 3.1 through 3.3 with no assertion changed

## 4. Verification

- [ ] 4.1 Run `swift test` from the package root and confirm the summary line reads `Executed <n> tests, with 1 test skipped and 0 failures` where `<n>` is 34 plus the number of tests added; quote that line
- [ ] 4.2 Run `git status --short` and `git diff --stat` and confirm the only changed or added paths are `Sources/LedgerKit/StatementCycle.swift`, `Sources/LedgerKit/StatementPeriods.swift`, `Tests/LedgerKitTests/StatementCycleTests.swift`, `Tests/LedgerKitTests/StatementPeriodsTests.swift`, `Tests/LedgerKitTests/GoldenFixtureTests.swift`, and the openspec change directory
- [ ] 4.3 Run `grep -rnE 'Calendar|DateFormatter|NumberFormatter|Locale|ISO8601DateFormatter' Sources/LedgerKit/` and confirm the only hits are in pre-existing comments, none in new code
- [ ] 4.4 Run `grep -n authorizedAt Sources/LedgerKit/StatementPeriods.swift` and confirm it has no hits, so the grouping cannot be reading the authorized date
- [ ] 4.5 Confirm `LEDGER_RUN_KNOWN_ISSUES=1 swift test` still fails exactly one test (the LEDGER-7 JPY case) and no new one, so the known-issue gate is untouched
