# Answer key — Exercise 2, the plan checklist

What a passing answer looks like for each of the six items, the two rejection
sentences the reference run sent, and the minor-unit table the fix needs.

**The fix is not here.** You have everything you need to write it in one line.

---

## The six items, with what "yes" looks like

### 1. Does it name the file it will change?

**Yes looks like:** `Sources/LedgerKit/Money.swift` — or
`src/main/kotlin/ledgerkit/Money.kt` — written out, once, as a path.

**No looks like:** "update the money formatting logic", "modify the currency
table". Both are true. Neither tells you whether the plan is about to touch one
file or three, which is the only reason you asked.

A plan that names two files is not automatically failing this item. A plan that
names two files *and does not say what each one gets* is.

### 2. Does it name each currency and its minor-unit count?

**Yes looks like:** the five codes with their counts, in the plan text, before
any code is written.

**No looks like:** "give JPY zero decimal places". That fixes the ticket and
leaves you no way to tell whether the other four are about to be changed by
accident. This is the item most first plans fail, because the ticket only
mentions one currency and the plan mirrors the ticket.

Ask for all five. It costs the plan one line and it is the difference between a
change you can review in ten seconds and one you have to read the diff for.

### 3. Does it name the exact verification command?

**Yes looks like:** `swift test` or `./gradlew test`, spelled out, plus what
counts as success — the line reporting zero failures, or `BUILD SUCCESSFUL`.

**No looks like:** "run the tests to confirm", "verify the suite passes". A plan
that says this can be satisfied by a sentence in the final message, and a
sentence about a test run is an opinion.

### 4. Does it say how the gated test gets run?

**Yes looks like:** `LEDGER_RUN_KNOWN_ISSUES=1 swift test`, or
`LEDGER_RUN_KNOWN_ISSUES=1 ./gradlew test`, named as a separate step from the
plain run.

**No looks like:** silence. This is the second-most-failed item, and it is the
one that matters most here: the whole suite is green before the fix and green
after it, so a plan that only runs `swift test` has verified nothing at all. The
plain run is the guard against breaking the other four currencies. The gated
run is the only thing that proves the bug is gone.

Both runs, in the plan, before you approve it.

### 5. Does it stay out of `LedgerSummary` and the fixture?

**Yes looks like:** no step touches either, and ideally the plan says so.

**No looks like:** a step that edits `Fixtures/transactions.tsv`, or one that
"updates the expected value" anywhere. The fixture holds the correct answer
already. A plan proposing to change it has decided the bug is in the test.

Also watch for a step that edits the assertion in the known-issue test. The
prompt rules it out in as many words, so a plan that includes it is a plan that
dropped a bound — worth rejecting on its own.

### 6. Does it say what it will **not** change?

**Yes looks like:** one line naming the neighbours it is leaving alone —
`TransactionFormatter`, `LedgerSummary`, the fixture, `CLAUDE.md`.

**No looks like:** nothing. Most plans have no such section unless the prompt
asks for one, which is why the prompt asks for one. It is the cheapest signal
you get about whether the agent understood the boundary or is about to discover
it halfway through.

---

## The two reference rejection sentences

Both were sent in the reference run. The second is the interesting one.

**Rejection 1**, against a plan that failed item 4:

> Item 4: the plan verifies with `swift test` only, which is green before and
> after the fix. Name the gated command as a separate step and say what its
> output is before the change and after it.

**Rejection 2**, against a plan that had already passed all six:

> Item 2: you list JPY at zero but not the other four. Put USD, EUR, GBP and
> BHD in the plan with their counts so I can see at review time that the table
> is complete rather than patched.

That second one is the skill this exercise is teaching. The plan was not wrong.
It was reviewable-in-principle rather than reviewable-in-ten-seconds, and the
cost of saying so was one sentence. If your first plan passes all six items,
reject it on the weakest one anyway and write the sentence down — a rejection
you had to go looking for still counts.

A rejection that does not name an item number and a missing thing is not a
rejection, it is a mood. "This needs more detail" sends the agent to guess which
detail.

---

## The minor-unit table the fix needs

| Currency | Minor units | Renders as |
| --- | --- | --- |
| USD | 2 | `-$84.99` |
| EUR | 2 | `-€23.50` |
| GBP | 2 | `-£12.99` |
| JPY | 0 | `-¥128,000` |
| BHD | 3 | `-BD12.500` |

These five are the currencies the fixture uses, and the `expectedAmountText`
column already holds every string in the right-hand column. The BHD row is the
one people are surprised by twice: three decimal places is correct, and the
ticket's second complaint is about how it reads, not about whether it is right.

Two notes on shape, not on the fix.

The rendering path already handles a zero-decimal currency — it skips the
decimal point and prints the grouped digits — so the change is to the currency
facts, not to the formatter. If your plan proposes a special case inside
`TransactionFormatter`, that is a currency fact in the rendering path, which is
where the next zero-decimal currency will not be found.

The fallback that JPY currently lands on exists for codes the module has never
heard of. Making that fallback cleverer hides the next missing entry instead of
surfacing it, which is the bug you are fixing, one level up.

---

## After the run

Two things to check that are not on the checklist, because they are checks on
you rather than on the plan.

The diff against the shipped lane — `diff -ruN -x .build ../sandbox/swift . |
grep '^diff '`, or `diff -ruN -x build -x .gradle -x .kotlin ../sandbox/kotlin
. | grep '^diff '` in the Kotlin lane — should name the ticket and one source
file. If it names the test file too, read that hunk before you accept it: a
changed assertion is the bug argued away rather than fixed.

The suite is green with the gate set *and* without it, and the test count is the
same in both runs. The gate changes whether the known-issue case is skipped, not
how many tests exist.

<!-- Sources: plan mode via Shift+Tab cc-core-01 and claude --permission-mode plan cc-core-03; plan editing Ctrl+G cc-core-04; approval options cc-core-05; Claude Code v2.1.280, checked 2026-09-22 cc-core-32 -->
