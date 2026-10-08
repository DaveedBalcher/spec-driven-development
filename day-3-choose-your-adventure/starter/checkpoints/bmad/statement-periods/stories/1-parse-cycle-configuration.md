---
title: 'Story 1: Parse a cycle configuration from TSV'
type: 'feature'
created: '2026-09-22'
status: 'ready-for-dev'
route: 'dispatch'
review_loop_iteration: 0
context:
  - '{project-root}/change-c-brief.md'
  - '{project-root}/_bmad-output/implementation-artifacts/statement-periods/SPEC.md'
---

> **Unblocked.** The malformed-row question was answered by the human on
> 2026-09-22 and is recorded under **Decided** in the parent `SPEC.md`: a
> malformed row is skipped, never fatal. Nothing has been implemented.

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** A customer's statement cycle arrives as a three-column TSV table
and nothing in LedgerKit can read it.

**Approach:** Add `CycleRule` and `StatementCycle` with
`StatementCycle.parse(tsv:named:)` exactly as fixed in `change-c-brief.md`,
returning the named configuration's well-formed rules or `nil` when no usable
row carries the name.

## Boundaries & Constraints

**Always:**
- Surface is fixed: `public struct CycleRule: Equatable { effectiveFrom:
  String; startDay: Int; init(effectiveFrom:startDay:) }` and
  `public struct StatementCycle: Equatable { rules: [CycleRule];
  init(rules:); static func parse(tsv: String, named name: String) ->
  StatementCycle? }`. `Sendable`/`Hashable` may be added.
- Split on `\n`, strip a trailing `\r`, ignore empty lines, split fields on
  `\t`. The first non-empty line is the header and is skipped, not validated.
- Rules come back in file order. Hand-rolled parsing only; no `Scanner`,
  `DateFormatter`, `Locale` or regex.
- `effectiveFrom` must be ten characters `YYYY-MM-DD`, all digits in place,
  month 1…12, day within that month (use `ISO8601.daysSinceEpoch` to get
  month length). `startDay` must parse as `Int` in 1…31.
- A row that fails those checks, or has other than three fields, is skipped.
  `parse` returns the rows under the requested name that do parse, in file
  order, and `nil` only when no usable row carries that name. A malformed row
  never traps.

**Never:**
- Read from disk inside the library; the caller passes the text.
- Modify any existing source or test file, or either fixture.
- Interpret `effectiveFrom` or choose between rules; that is story 2.

## I/O & Edge-Case Matrix

See the parent `SPEC.md` matrix rows beginning `parse,`. All are settled.

</frozen-after-approval>

## Code Map

- `Sources/LedgerKit/LedgerSummary.swift` -- style to mirror (doc comments,
  `Equatable, Sendable`, `enum`/`struct` in one file). Do not modify.
- `Sources/LedgerKit/Transaction.swift` -- `ISO8601.daysSinceEpoch(year:
  month:day:)` for month-length validation. Do not modify.
- `Tests/LedgerKitTests/GoldenFixtureTests.swift` -- `Fixture.url` pattern
  (`#filePath` → `Fixtures/`). Add `Fixture.cycleConfigText()` as an extension
  in the new test file. Do not modify.
- `Tests/LedgerKitTests/Fixtures/cycle-config.tsv` -- three configs:
  `standard`→5, `month-end`→31, `first-of-month`→1, all `2026-01-01`.

## Tasks & Acceptance

**Execution:**
- [ ] `Sources/LedgerKit/StatementCycle.swift` -- add `CycleRule` and
  `StatementCycle` with `parse` -- the brief's fixed surface.
- [ ] `Tests/LedgerKitTests/StatementCycleTests.swift` -- one behaviour per
  test: each fixture name parses to its rule; unknown name is `nil`; header
  only and empty text are `nil`; CRLF parses; other-name malformed rows do not
  poison the requested name; a malformed row under the requested name is
  skipped (one case per malformation in the matrix row); a name whose only
  row is malformed is `nil`.

**Acceptance Criteria:**
- Given the fixture TSV, when `parse(tsv:named:"standard")` runs, then the
  result equals `StatementCycle(rules: [CycleRule(effectiveFrom:
  "2026-01-01", startDay: 5)])`.
- Given the fixture TSV, when asked for `"gold"`, then the result is `nil`.
- Given text holding `standard 2026-01-01 5` and a malformed `standard` row,
  when asked for `"standard"`, then the result equals the fixture result
  above; given text whose only `gold` row is malformed, when asked for
  `"gold"`, then the result is `nil`.
- Given text whose rows end in `\r\n`, when parsed, then the result equals
  the `\n` result.
- Given `swift test`, when run, then the summary shows `0 failures`.

## Implementation Notes

## Spec Change Log

## Review Triage Log

## Verification

**Commands:**
- `swift test` -- expected: `0 failures (0 unexpected)`, 1 skipped, count
  above the 34 baseline.
- `git status --short -- Sources Tests` -- expected: only the two new files
  and the pre-existing untracked `cycle-config.tsv`.
