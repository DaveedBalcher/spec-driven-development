# The six reference findings, in one page

The scoring sheet for Exercise 2. Write your own list first, then count.

| # | Tag | One line | Where it shows |
| --- | --- | --- | --- |
| 1 | CRITERION 1 | A declined amount is counted: every row that is not pending is added into `postedMinor` | 2026-03-03, USD `postedMinor` is −13999 (LK-006, declined) |
| 2 | CRITERION 2 | The pending figure is the day's, copied into every currency | 2026-03-05, BHD `pendingMinor` is −9630 (LK-016, a GBP row) |
| 3 | CRITERION 3 | Days come back oldest first | `byDay` returns 2026-03-02 first |
| 4 | NO-CRITERION | The order of rows inside a day: the spec never said, the lane's own test did, and the run deleted that test and reversed the rows | 2026-03-04 comes back LK-013 first |
| 5 | NO-CRITERION | Which currencies earn a totals entry was never specified, so declined-only currencies get one | 2026-03-05 has an EUR entry from LK-017, declined |
| 6 | CRITERION 4 | Totals come back in arrival order, not currency-code order | 2026-03-06 totals read USD, GBP, EUR |

Four tagged, two `NO-CRITERION`. If your auditor found the four and none of the
two, its instructions are working and its reading is shallow: it is checking the
spec and not noticing what the spec left out. If it found more than six, check
whether the extras have a file and a line; an opinion with no locator is not a
finding.

A lost-coverage finding is real, not invented: the deleted test that kept rows
inside a day oldest first, the grid's four test names missing from the
rewritten summary tests, or checks that compare sets where a criterion asks for
an order. That is how findings 3, 4 and 6 stayed green, so count it with those
rows.

The evidence, the fixes, and the routing decision for each one are in
`../reveal/findings-change-b.md`. The `CLAUDE.md` revision the routing produces
is in `../reveal/claude-md-diff.md`.

## Scoring

- **Caught 6, invented 0.** Run the auditor against a clean copy before you
  celebrate; an auditor that finds six things everywhere finds nothing.
- **Caught 4, missed both NO-CRITERION.** The usual result. The auditor is
  comparing code to criteria and stopping there. Add the third question to its
  instructions: what did the spec not say that the code had to decide?
- **Caught fewer than 4.** Check that you gave it the spec path and that its
  `tools:` line lets it read the files it needs.
- **Found things on a clean copy.** Fix that first. Until a clean run returns
  nothing, the iteration count you measure afterwards means nothing.
