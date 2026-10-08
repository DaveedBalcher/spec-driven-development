---
name: run-spec
description: Implement a spec file to green without stopping to chat. Reads the spec path given as the argument, implements it, runs the lane's test command, repairs on red, and stops on green, on the fifth iteration, or at a gate. Appends one line per iteration to run-log.md.
argument-hint: <path to the spec file>
---

# run-spec

You are running a spec to completion. The argument is a path to a spec file,
relative to the working directory. Read it first. Everything below is the
procedure; the spec is the content.

Do not ask the person anything except at a gate. Between gates you implement,
run the tests, read the failure, and repair. A question that is not a gate is
an interruption you are paying for.

## The loop

1. Read the spec at the path given as the argument. Take from it: the numbered
   acceptance criteria, the in-bounds and out-of-bounds file lists, the
   verification command, the line budget, and the definition of done.
2. Read the files the spec lists as in bounds. Read nothing else unless a
   failure sends you there.
3. Implement the smallest change that satisfies the criteria you have not
   satisfied yet.
4. Run the verification command from the spec, exactly as the spec writes it.
5. Append one row to `run-log.md` in the working directory. The format is in
   `run-log.template.md`; if `run-log.md` does not exist yet, create it with
   the title and the two-line table header that file shows, and nothing else.
6. Decide: green, cap, gate, or another iteration. Then act on the decision
   below.

## The three exits

Stop at the first of these that is true. Say which one fired and quote the
evidence.

- **Green.** The verification command exited zero and its summary line says
  so, in the words the spec gives for success (Swift: the `Executed … tests`
  line with 0 failures; Kotlin: `BUILD SUCCESSFUL in …`). Print that line and
  the last line of `run-log.md`, then stop.
- **The cap.** `MAX_ITERATIONS = 5`. Iteration five is the last one you run.
  If it ends red, stop anyway, print the failure, and say the cap fired. Five
  passes that did not converge is information, not a reason for a sixth.
- **A gate.** One of the three conditions below became true. Stop mid-repair
  and ask.

You do not have a fourth exit. "It is close enough" is not an exit; neither is
rewriting the spec so the current code passes.

## The three gate conditions

- **A file outside the spec's bounds must change, or is the better home for
  the change.** Including a test file the spec does not list. Do not widen
  the bounds yourself, and do not quietly take the in-bounds route either:
  offer it as an answer.
- **The same failure twice, byte for byte.** Compare the failure text from this
  iteration with the previous one. Identical text means the repair changed
  nothing the test can see, and a third attempt will not either.
- **The diff exceeds the spec's line budget.** Measure against the shipped
  lane this copy came from (`../sandbox/swift` when this folder has
  `Package.swift`, `../sandbox/kotlin` otherwise), added plus deleted:
  `diff -ruN -x .build -x build -x .gradle -x .kotlin -x .claude -x specs -x run-log.md ../sandbox/swift . | grep -vE '^(--- |\+\+\+ )' | grep -cE '^[+-]'`
  (Kotlin: the same with `../sandbox/kotlin`). If the spec states no budget,
  treat 200 changed lines as the budget and say so at the gate.

## What a gate looks like

A gate is three things, in this order, and nothing else:

1. **The question**, in one sentence, answerable without reading the code.
2. **The evidence**: the failing assertion, the offending diff hunk, or the
   changed-line count from that diff. Quote it; do not describe it.
3. **Two or three answers**, each a sentence the person can say back to you.

Example shape:

```text
GATE: criterion 4 asks for the totals in currency-code order, and the tidiest
home for that comparator is Sources/LedgerKit/Transaction.swift, which the spec
lists as out of bounds.

Evidence:
  the failure that sent me there, quoted whole: the totals order is not
  stable across runs, from this iteration's test output

Answers:
  A. Widen the bounds to include Transaction.swift.
  B. Keep the sort private inside LedgerSummary.swift.
  C. Stop here; I will re-scope the spec.
```

Then stop. Do not pick an answer for the person, and do not keep working while
you wait.

## The run log

`run-log.md` is the run's memory, not the conversation. Append one row per pass
through the loop, immediately after the test command returns and before you
start the next repair. A compaction, a `/clear`, or a new session must not lose
the history of the run, and this file is why it does not.

One row, four pipe-separated cells, under 200 characters: the word `iteration`
and its number, what you changed, what the tests said, what you decided next.
When a gate fires, add a `GATE` row, and once the person answers, an `ANSWER`
row carrying their decision and their reason in one sentence. Finish the file
with one line of prose naming the exit.

## When this is the wrong tool

Run a spec this way only when a command can tell you that you are done. If a
criterion is a judgement call — "the API reads naturally", "performance is
acceptable" — this loop will converge on something green and wrong, because
green is the only signal it has. Send those criteria back to the spec before
you start.

Do not run git. This folder is a plain copy of the shipped lane: in a clone of
the course, git reports on the whole course and ignores this folder, and a
download has no repository at all. The recovery path for an unattended run is
the reset: the person quits Claude Code, saves `run-log.md` to `../work/`, and
re-copies the lane.

<!-- Sources: cc-automation-01 (project skill at .claude/skills/<name>/SKILL.md), cc-automation-03 (invoking a skill with an argument), cc-automation-04 (the description is surfaced up front and is truncated at 1,536 characters). -->
