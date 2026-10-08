# Plan checklist — LEDGER-7

Exercise 2's setup copies this file to `work/plan.md` at the course root. It is
your working file: fill it in as you go, and it is the deliverable at the end of
the exercise.
Every path below is relative to `day1-work`, the copy of your lane at the course
root, which is where every Day 1 command runs; from there this file is
`../work/plan.md`.

Your lane's gated command:

```bash
LEDGER_RUN_KNOWN_ISSUES=1 swift test      # Swift lane
LEDGER_RUN_KNOWN_ISSUES=1 ./gradlew test  # Kotlin lane
```

---

## Before

Paste the summary line of the failing gated run here, before you start Claude Code.
Swift: the line beginning `Executed 34 tests`. Kotlin: the `85 tests completed,
1 failed` line and the `BUILD FAILED` verdict line.
This is half of your evidence and it stops being available the moment the bug is
fixed.

```text
```

Plain test command, before:

```text
```

---

## The six items

Run these against the plan Claude Code proposes, in this order. Each one is
answered yes or no by pointing at a line of the plan — if you have to infer it,
the answer is no.

| # | Question | Pass? | The line in the plan that answers it |
| --- | --- | --- | --- |
| 1 | Does it name the file it will change? | | |
| 2 | Does it name each currency and its minor-unit count? | | |
| 3 | Does it name the exact verification command? | | |
| 4 | Does it say how the gated test gets run? | | |
| 5 | Does it stay out of `LedgerSummary` and the fixture? | | |
| 6 | Does it say what it will **not** change? | | |

A plan that passes five of six is a plan you reject on the sixth. The point of
the list is that it is answered from the text in front of you, not from how
confident the plan sounds.

---

## Rejection 1

One sentence naming the specific defect. Not "this needs more detail" — name the
item number and what is missing.

```text
```

## Rejection 2 (if you sent one)

```text
```

---

## The approved plan

Paste the plan you approved, after your `Ctrl+G` edits.

```text
```

---

## After

The gated run once the fix is in. Swift: the same `Executed` line, now with 0 failures.
Kotlin: the `BUILD SUCCESSFUL` line and the `skipped="0"` that step 9's grep prints, which
shows the gated test ran. Both commands must be green: the plain one and the gated one.

```text
```

Plain test command, after:

```text
```

---

## Done, as Lesson 1 defined it

- [ ] A failing command, quoted, from before the change.
- [ ] At least one written rejection with a named defect.
- [ ] The approved plan.
- [ ] The same command, quoted, passing after the change.
- [ ] Step 10's diff against the shipped lane names only the ticket, the money
      formatting path and its tests.
- [ ] The gated test's assertion is unchanged.

<!-- Sources: plan mode entered with Shift+Tab cc-core-01 or claude --permission-mode plan cc-core-03; plan edited before approval with Ctrl+G cc-core-04; approval options cc-core-05; checked against Claude Code v2.1.280 cc-core-32 -->
