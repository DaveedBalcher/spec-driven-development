# Arrow: statement-period

Groups posted transactions into statement periods from a cycle configuration (Change C).

## Status

**MAPPED** — not yet audited. Design and 22 EARS specs written 2026-09-22; no tests and no code.

## References

### HLD
- docs/high-level-design.md (System Design, the statement-period leaf)

### LLD
- docs/intent/statement-period/statement-period-design.md

### EARS
- docs/intent/statement-period/statement-period-specs.md (22 specs, LK-PERIOD-001 to LK-PERIOD-022)

### Tests
- (none yet) planned: Tests/LedgerKitTests/StatementPeriodsTests.swift

### Code
- Tests/LedgerKitTests/Fixtures/cycle-config.tsv (fixture only)
- (none yet) planned: Sources/LedgerKit/StatementCycle.swift, Sources/LedgerKit/StatementPeriods.swift

## Architecture

**Purpose:** parse the cycle configuration, then place each transaction in the period that holds its posted day.

**Key Components:**
1. StatementCycle — the parsed configuration (start day, clamping rule)
2. StatementPeriods — the grouping over the transaction list

## Spec Coverage

| Category | Spec IDs | Implemented | Deferred | Gaps |
|----------|----------|-------------|----------|------|
| Cycle configuration | LK-PERIOD-001 to LK-PERIOD-009 | 0 | 0 | 9 |
| Period membership and order | LK-PERIOD-010 to LK-PERIOD-022 | 0 | 0 | 13 |

**Summary:** 0 of 22 active specs implemented; the arrow has reached requirements and not tests.

## Key Findings

1. **Membership is by posted date** — LK-PERIOD-013; fixture row LK-015 separates the two readings.
2. **Short months clamp to their last day** — LK-PERIOD-008; a start day of 31 opens February 2026 on 2026-02-28.

## Work Required

### Must Fix
1. Tests for every LK-PERIOD spec, then code, each carrying `@spec` annotations (LK-PERIOD-001 to LK-PERIOD-022).

### Should Fix
2. Nothing yet.

### Nice to Have
3. Nothing yet.
