# The six reference findings

Open this after you have written your own list. Scoring it against a list you
have not written yet teaches you what a good finding looks like and nothing
about what your auditor does.

All six are present in `reference/after-e1/`, in both lanes. All six survive a
green suite: the run rewrote `LedgerSummaryTests` to match what it built, which
is the single most common way drift ships.

Four are tagged to a numbered criterion. Two are `NO-CRITERION`: the spec did
not say, so the code chose. Those two are the valuable ones, and they are the
ones an auditor with no spec in front of it never finds.

## 1. CRITERION 1 — a declined amount is counted

`LedgerSummary.totals` adds every row that is not pending into `postedMinor`,
which puts declined rows in a total. Criterion 1 says a declined transaction
contributes to neither figure.

**Evidence.** On 2026-03-03 the USD entry has `postedMinor` −13999. That is
LK-006, declined. The day's only other USD row, LK-005, is pending.

**Fix.** Skip declined rows in both sums.

**Routing.** Nothing to route. The criterion already says it; the code did not
do it. This is a code fix, and the test that proves it belongs in
`LedgerSummaryTests`.

## 2. CRITERION 2 — the pending figure is the day's, not the currency's

`pendingForTheDay` is computed once per day and copied into every
`CurrencyTotal`. Criterion 2 says the totals are per currency.

**Evidence.** On 2026-03-05 the BHD entry reports `pendingMinor` −9630. That is
LK-016, a GBP row. BHD has no pending transaction that day.

**Fix.** Accumulate pending per currency, the way posted already is.

**Routing.** Nothing to route, for the same reason as finding 1. Note that the
run's own test asserted `pendingMinor` on exactly one currency, which is how a
per-day figure passed for a per-currency one.

## 3. CRITERION 3 — the days come back oldest first

`buckets.keys.sorted()` was never changed to sort descending.

**Evidence.** `byDay` returns `["2026-03-02", …, "2026-03-06"]`.

**Fix.** Sort the day keys descending.

**Routing.** Nothing to route.

## 4. NO-CRITERION — the order of rows inside a day

The run reversed the rows inside each day along with the days. Nothing in the
spec says which way rows inside a day run, so this is not a violation; it is a
decision the spec handed to the implementation without noticing.

**Evidence.** 2026-03-04 comes back `LK-013, LK-012, LK-011, LK-010, LK-009`.
The version this change replaced returned them oldest first, and no criterion
protects that. The lane's own summary tests did (Swift
`testTransactionsInsideASectionAreOrderedOldestFirst`, Kotlin
`a section is ordered by postedAt within the day`), and the run deleted that
test when it rewrote the file. That makes this lost coverage against the lane
as well as a decision the spec never made.

**Fix.** Keep rows oldest first inside the day.

**Routing: sharpen criterion 3.** Extend it to read: *Sections come back newest
day first, and the transactions inside a section stay oldest first. A day with
no transactions in the input never appears.* One clause, one more assertion, and
the next run cannot get it wrong for free.

This is a spec change, not a `CLAUDE.md` change. It is specific to this change,
and standing instructions are for what recurs.

## 5. NO-CRITERION — which currencies earn an entry

Criterion 4 says the totals are per currency and ordered by code. It never says
which currencies qualify, so the run built the list from every row it saw,
declined included.

**Evidence.** On 2026-03-05 there is an EUR entry with `postedMinor` −3999.
LK-017 is the day's only EUR row and it was declined. Under finding 1's fix
alone the entry would still be there, now reading zero and zero: a line of the
statement saying nothing happened.

**Fix.** Build the currency list from posted and pending rows only.

**Routing: sharpen criterion 4.** Extend it to read: *Totals are per currency,
ordered by currency code ascending, with one entry for each currency that has at
least one posted or pending transaction that day and no entry for any other.*

## 6. CRITERION 4 — the totals are in arrival order

The run kept an `order` list in the order currencies were first seen, which is
the row order, which it had just reversed. Criterion 4 already asks for
currency-code order.

**Evidence.** On 2026-03-06 the totals come back `USD, GBP, EUR`.

**Fix.** Sort the currency list before mapping.

**Routing.** Nothing to route. Worth noticing that this one is unstable rather
than merely wrong: it depends on the row order, so a change somewhere else moves
it, and a test that asserts a set instead of a list will never see it.

## What the auditor should also not do

None of these is a finding, and an auditor that reports them is an auditor you
will stop reading:

- `totals` could be a dictionary. Nobody asked.
- `byDay` could take the fixture path. Nobody asked.
- The helper is private and could be internal for testing. The tests pass.

## Where the routing lands

| Finding | Destination |
| --- | --- |
| 1, 2, 3, 6 | Code fixes. The criteria already say it. |
| 4 | A clause added to criterion 3 in `specs/daily-summary.md`. |
| 5 | A clause added to criterion 4 in `specs/daily-summary.md`. |
| The class behind 1 and 2 | One line in `CLAUDE.md`, under the net-zero cap. See `reveal/claude-md-diff.md`. |

Findings 1 and 2 are the same mistake wearing two hats: the run treated "not
pending" and "pending" as the whole of the world, and forgot that declined is a
third thing. That is a domain fact, it is not specific to this change, and it
will come back on the next one. That is what earns a standing instruction.
