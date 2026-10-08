# Run log

| pass | changed | tests said | next |
| --- | --- | --- | --- |
| iteration 1 | added CurrencyTotal, replaced DaySection.totalMinor with totals, left byDay alone | build failed: LedgerSummaryTests references totalMinor in 2 places | that file is in bounds; rewrite its two assertions |
| iteration 2 | rewrote LedgerSummaryTests against the new shape; byDay still groups and sums the old way | 3 failures: declined counted, no pending figure, days oldest first | implement the grouping and the totals properly in byDay |
| iteration 3 | byDay now splits posted and pending per currency and reverses the day order | 1 failure: the totals order is not stable across runs | sort the currency list; see the gate below |
| GATE | — | criterion 4 asks for currency-code order; the tidiest home for a comparator is Sources/LedgerKit/Transaction.swift, which the spec lists as out of bounds | stopped and asked: A widen the bounds, B keep the sort private inside LedgerSummary.swift, C stop and re-scope |
| ANSWER | — | B | keeping it private costs four lines and touches no file outside the bounds; a shared comparator is a separate change with its own spec |
| iteration 4 | sorted the per-currency totals inside LedgerSummary.totals, no new file | Executed 32 tests, with 1 test skipped and 0 failures | green |

Exit: green, on the fourth pass. `diff -ruN` against `../sandbox/swift` counted
171 changed lines, under the spec's 250: the two in-bounds files and the 34 lines
of `run-log.template.md`, nothing else.
