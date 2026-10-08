# Answer key — Exercise 3, the reference spec for Change B

Compare this with what you wrote. It is a reference, not the only correct
answer: a spec whose four criteria are falsifiable, bounded and non-overlapping
has passed, whatever order they are in.

Day 2 hands a sharpened version of this spec to a runner (it adds a Shape
section and orders the per-currency totals by currency code), so the file below
is written to be handed over nearly as it stands.

---

# Spec: pending-aware daily summary

## Goal

`LedgerSummary.byDay` returns day sections that a customer could reconcile by
hand: declined transactions are listed but excluded from every total, pending
amounts are carried as their own total beside the posted one, and a day holding
more than one currency reports its totals per currency rather than adding
different currencies together.

## Non-goals

- **No currency conversion.** No rate is fetched, stored or applied, and no
  combined figure in a single currency is produced. A day with three currencies
  reports three sets of totals.
- **No change to filtering.** `LedgerFilter` and its `Query` value are untouched.
  If day grouping needs a predicate, it gets its own.
- **No change to the rendered strings.** `TransactionFormatter` and `Money` keep
  their current behaviour, LEDGER-7 included. Totals are exposed as signed
  minor-unit integers; rendering them is someone else's change.
- **Nothing about the screen.** Section headers, spacing, empty states and
  labels are out of this module.

## Acceptance criteria

1. A declined transaction appears in its day's `transactions` list and
   contributes to no total on that day.
2. Each day reports a pending total separately from its posted total, and a
   transaction contributes to exactly one of the two.
3. Day sections are returned newest day first, and a day with no transactions is
   not returned at all.
4. A day holding more than one currency reports a posted total and a pending
   total per currency, and never sums two currencies into one figure.

### Criterion-to-command grid

The test names are written the Swift lane's way. In the Kotlin lane each is a
backticked sentence in `LedgerSummaryTest`, like the existing
`` `days come out oldest first with no gaps invented` ``.

| # | Command that fails if this is broken | Test or assertion |
| --- | --- | --- |
| 1 | `swift test` / `./gradlew test` | `LedgerSummaryTests.testDeclinedIsListedButNotTotalled` — 2026-03-03 lists `LK-006` among its transactions, and no total on that day includes `-13999`. |
| 2 | `swift test` / `./gradlew test` | `LedgerSummaryTests.testPendingHasItsOwnTotal` — 2026-03-03's USD pending total is `-1725` and its USD posted total is `0`. |
| 3 | `swift test` / `./gradlew test` | `LedgerSummaryTests.testDaysAreNewestFirstWithNoGaps` — for the whole fixture the returned days are exactly `2026-03-06, 2026-03-05, 2026-03-04, 2026-03-03, 2026-03-02`, in that order; and for the fixture with 2026-03-04's five rows removed, the result has four sections and no `2026-03-04`. |
| 4 | `swift test` / `./gradlew test` | `LedgerSummaryTests.testPerCurrencyTotalsOnAMixedDay` — 2026-03-03 reports EUR, GBP and USD separately; its EUR posted total is `-4890`. |

Every row names a different assertion and a different fixture fact. That is the
check on the four: if two rows named the same assertion, one of the criteria
would not be doing any work.

## Bounds

**In bounds — may change:**

- Swift: `Sources/LedgerKit/LedgerSummary.swift`,
  `Tests/LedgerKitTests/LedgerSummaryTests.swift`
- Kotlin: `src/main/kotlin/ledgerkit/LedgerSummary.kt`,
  `src/test/kotlin/ledgerkit/LedgerSummaryTest.kt`

**Out of bounds — must not change:**

- The fixture: `Tests/LedgerKitTests/Fixtures/transactions.tsv` (Swift),
  `Fixtures/transactions.tsv` (Kotlin)
- `Money`, `TransactionFormatter`, `LedgerFilter` and their tests
- `CLAUDE.md`

## Verification

```bash
swift test        # Swift lane. Success: the run reports 0 failures.
./gradlew test    # Kotlin lane. Success: the run ends with BUILD SUCCESSFUL.
```

The known-issue gate is not part of this change. `LEDGER-7` is a formatting bug
and no criterion here touches a rendered string.

## Stop conditions

- A change is needed in a file listed as out of bounds: stop, name the file and
  the reason, change nothing.
- The same test fails twice in the same way: stop and show the failure.
- A day in the fixture holds only declined transactions, and whether it should
  appear changes what a test asserts: stop and ask. The brief does not answer
  this and neither does this spec.

## Definition of done

- [ ] Every numbered criterion has a test that fails without the change.
- [ ] The verification command is green, and the line that reports its result is
      quoted rather than summarised.
- [ ] The diff against the shipped lane names only `LedgerSummary` and its test file.
- [ ] No transaction was dropped from a day section — only excluded from a
      total. Every fixture row still appears in exactly one day.
- [ ] No locale or number-formatting API was introduced.
- [ ] The fixture file is unchanged.

---

## Notes on the four

**Why declined and pending are two criteria and not one.** They look like the
same idea — "transactions that are not settled money" — and they are opposite
requirements. A declined transaction is shown and not counted. A pending
transaction is shown and counted, in its own column. Merging them gives you one
criterion that fails for two different reasons, and a failure that does not tell
you which.

**Why criterion 3 carries two clauses.** Ordering and empty days are one
behaviour of one function — what the list of days is — and both are decided by
reading the returned day strings. Splitting them would give you two rows naming
the same kind of assertion, which the grid is there to catch.

Note what filling that row forced you to notice: the fixture's five days are
consecutive, so nothing in it can make the no-empty-days clause fail. The
assertion has to remove a day's rows and check that the gap does not come back
as a section. A criterion whose grid row you can only fill by inventing an input
is not a bad criterion — but you have to invent that input now, in the spec,
rather than discovering on Day 2 that the runner went green without ever testing
it.

**Where the brief's two open questions went.** The day-of-only-declined question
became a stop condition, because it changes what a test asserts and nobody has
decided it. The pending-refund question was answered instead of deferred: the
pending total is a signed sum, so a pending credit raises it, which is the same
arithmetic every other total in the module uses. An answer that follows from an
existing convention can be made in the spec. One that does not, goes back.

**On `postedAt`.** Day grouping stays on `postedAt`, unchanged. The fixture has
three transactions authorized on 2026-03-03 and posted on 2026-03-04 (`LK-009`,
`LK-010`, `LK-011`), which is the trap: a criterion phrased "transactions are
grouped by the day they happened" moves those three rows and breaks the golden
test's `expectedDay` column. Change B does not change day membership.

---

## The two unfalsifiable criteria, and their rewrites

These are the two almost everybody writes. Both are reasonable sentences. Neither
can make a command exit non-zero.

### "The summary is accurate."

Accurate against what? There is no oracle. An agent reading this cannot tell
whether it has satisfied it, and neither can you, so it will be marked done by
whoever is holding the diff.

**Rewritten:**

> For every day in the fixture, the posted total for a currency equals the sum
> of the `amountMinor` values of that day's posted transactions in that
> currency, and equals nothing else.

Now there is a number on each side, taken from a file that is in the repository,
and a test can compute both.

### "Performance is acceptable for large ledgers."

Acceptable to whom, at what size, measured with what? A criterion with no
threshold and no measurement has no red state, and a criterion with no red state
is a hope.

**Rewritten, if you want it at all:**

> `byDay` makes one pass over the input and allocates no more than one bucket
> per distinct day, verified by a test that asserts the result for a 10,000-row
> synthetic input and completes within the suite's existing time budget.

Read that and notice how much you had to invent to make it checkable: the row
count, the pass count, the budget. That is the tell. For a module this size the
right move is to delete the criterion and write a non-goal instead — "no
performance work; the input is one statement period" — because a criterion you
had to invent numbers for is a criterion nobody asked for.

---

## Two more that fail for a different reason

Not unfalsifiable, but not criteria either. Worth recognising, because the audit
prompt will not flag them — a command *can* fail for both.

- **"Add a `pendingTotalMinor` field to `DaySection`."** That is a plan step. It
  is checkable and it forbids a better shape for no reason. Criteria say what is
  true afterwards; plans say how.
- **"Refactor `byDay` for readability."** Checkable only by opinion, and it is a
  second change riding along with the first. If it is worth doing it is worth
  its own spec.

<!-- Sources: no mechanical Claude Code claim on this page. Fixture facts are from sandbox/fixtures/transactions.tsv, read 2026-09-22. -->
