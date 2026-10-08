# The spec template, annotated

`specs/TEMPLATE.md` is the file you copy and fill. This page is the same
template with a note on each section: what it is for, what a filled version
looks like, and the specific way each one gets filled badly.

Read it once before Exercise 3 and keep it open while you write. The examples
all come from Change B, the pending-aware daily summary.

---

## `# Spec: <change name>`

A name a teammate would recognise in a list of eight files. "Pending-aware daily
summary" works. "LedgerSummary changes" names the file, not the change, and two
of those in one folder are indistinguishable.

---

## `## Goal`

**What it is for.** It tells the agent what to aim at when a detail is missing
from the criteria, which one always is.

**Filled well:**

> Day sections show two totals — posted and pending — with declined
> transactions listed but excluded from both, and a per-currency breakdown on
> any day that holds more than one currency.

**Filled badly:** "Improve `LedgerSummary`." That is a direction, not a
destination, and an agent will happily improve it in a direction you did not
want. The test is whether someone could tell you the goal was met without
reading the diff.

Keep it to two sentences. A goal that needs a paragraph is two changes.

---

## `## Non-goals`

**What it is for.** This is the section that earns its keep fastest. An agent
reading a spec about day totals will find the currency conversion question on
its own, and it will make a decision about it, and it will not tell you that it
did.

**Filled well:**

- No currency conversion. A day with three currencies shows three sets of
  totals.
- No change to `LedgerFilter` or the `Query` value.

**Filled badly:** one bullet reading "not a rewrite". Write down the thing
sitting next to the change — the neighbouring file, the tempting generalisation,
the second feature in the brief. The one you are least sure about is the one to
write.

---

## `## Acceptance criteria`

**What it is for.** These are the statements a command decides. Everything else
in the spec is context; this is the contract.

**Filled well:** one behaviour per number, stated as an outcome.

> 3. Day sections are returned newest day first, and a day with no transactions
>    is not returned at all.

**Filled badly, three ways.**

- *Unfalsifiable.* "The summary is accurate." Accurate against what? No
  assertion can go red for this.
- *Two criteria in one number.* "Declined rows are excluded from totals and
  pending has its own total." When it fails you cannot tell which half broke.
- *Implementation instead of behaviour.* "Add a `pendingTotalMinor` field to
  `DaySection`." That is a plan step. If a better shape exists, this sentence
  forbids it for no reason.

Four is the right number for Change B. It is not a magic number; it is how many
distinct behaviours the brief describes.

---

## `### Criterion-to-command grid`

**What it is for.** It is the check on the section above it. Filling the grid is
how you find out that criterion 2 and criterion 4 are the same criterion, or
that criterion 1 cannot fail.

**Filled well:**

| # | Command that fails if this is broken | Test or assertion |
| --- | --- | --- |
| 3 | `swift test` | `LedgerSummaryTests.testDaysAreNewestFirst` |

The test name does not have to exist yet. You are naming the assertion someone
will write, which is a commitment that it can be written.

**Filled badly:** a row that says `swift test` and nothing else. The command is
the same on every row; the assertion is the information. A row you cannot
complete is the signal to go back and rewrite the criterion, which is the whole
reason the grid is in the template.

---

## `## Bounds`

**What it is for.** Paths, so that "did it stay in bounds" is answered by
the file list of the diff against the shipped lane and not by reading the diff.

**Filled well:**

```text
In bounds:  Sources/LedgerKit/LedgerSummary.swift
            Tests/LedgerKitTests/LedgerSummaryTests.swift
Out:        Tests/LedgerKitTests/Fixtures/transactions.tsv
            Sources/LedgerKit/Money.swift
            CLAUDE.md
```

**Filled badly:** "be careful around the formatter". An agent cannot diff
against carefulness. Name the file.

The out-of-bounds list is worth more than the in-bounds list, because it is the
one that catches the fix you did not want: the fixture edited so a test passes,
the standing instructions quietly relaxed.

---

## `## Verification`

**What it is for.** "Done" is a command you ran and its output. This section is
where you write down which command, before anyone has an interest in the answer.

**Filled well:**

```bash
swift test
```

Success is the run reporting `0 failures`. The Kotlin lane's is `./gradlew test`
and success is `BUILD SUCCESSFUL`.

**Filled badly:** "run the tests and make sure they pass". That sentence can be
satisfied by a summary, and a summary of a test run is an opinion. Ask for the
line that carries the verdict, quoted.

If your change touches a gated test, the gated command belongs here too —
otherwise it does not get run, which is the point of a gate.

---

## `## Stop conditions`

**What it is for.** An agent with no way to stop keeps going until something is
green, and green is not the same as correct. Two of these are generic and
belong in every spec you write:

- A change is needed in an out-of-bounds file: stop, name it, change nothing.
- The same test fails twice in the same way: stop and show the failure.

The third is specific to the change. For Change B it is the question the brief
left open — a day holding only declined transactions — and the stop condition
reads: if the answer changes what the tests assert, stop and ask rather than
picking one.

Day 2 turns this section into a runner's exit conditions. It is worth writing
well now.

---

## `## Definition of done`

**What it is for.** The checklist someone else could run without you in the
room. Every line is a thing they can see, not a thing they would have to judge.

The five in the template cover most changes. Add one when your change has a
specific way of being faked — for Change B, that is "no transaction was dropped
from a day section, only excluded from a total", because the fastest way to make
the totals right is to stop listing the declined rows, and that is the opposite
of what the brief asked for.

---

## What the template does not do

It does not make the change good. A spec with four falsifiable criteria can
still describe the wrong feature, and no grid will tell you so. The template
catches vagueness, not wrongness. Wrongness is caught by the brief, by the
person who wrote it, and by the question you send back — which is why the
Change B brief ends with two open questions rather than an invitation to guess.

It is also not documentation. Nobody reads it after the change lands. It is
written to be consumed once, by an agent, and then to sit in the repository as
the record of what was agreed. If you find yourself polishing prose in it, stop:
the grid is the part that matters.
