# BMAD checkpoint: the spec and story set for Change C

Copy these in at Exercise 2's 25-minute checkpoint if your planning phase has
overrun. Taking the checkpoint is not failing the exercise; it exists so that a
slow planner still gets to run the implementation and grade it.

> **The `git status` lines.** `statement-periods/SPEC.md` and both story files
> list `git status --short -- Sources Tests` as a verification step. That is
> what BMAD wrote, kept as recorded output. It does not work in `day3-work`: in
> a clone of the course, git reports on the whole course and ignores this
> folder, and a download has no repository at all. Use the exercise page's
> `diff -ruN` line against the shipped lane instead, and treat the git step as
> satisfied when that diff lists only the files the story names.

From inside `day3-work`:

```sh
mkdir -p _bmad-output/implementation-artifacts
cp -R ../day-3-choose-your-adventure/starter/checkpoints/bmad/statement-periods _bmad-output/implementation-artifacts/
```

That is where BMAD puts implementation artifacts on a default install — check
`_bmad/config.toml` if you changed the output folder, and use whatever
`implementation_artifacts` says there instead. If your own run already made a
spec folder, delete it first or you will have two.

Then carry on at the implementation step. The spec's status is already
`ready-for-dev`, which is the value that tells the build chain it may start, so
`/bmad-build` picks it up from the spec folder and story `1`.

## What is here

```
statement-periods/SPEC.md                              the parent spec, status ready-for-dev
statement-periods/stories.yaml                         two stories in execution order
statement-periods/stories/1-parse-cycle-configuration.md
statement-periods/stories/2-group-into-statement-periods.md
```

`SPEC.md` carries the frontmatter BMAD drives the loop with — `status:
'ready-for-dev'`, `route: 'dispatch'`, `review_loop_iteration: 0` — a frozen
decision block, a 25-row edge-case matrix, a code map, tasks, acceptance
criteria and verification commands. Story 2 depends on story 1.

The spec notes that it runs above BMAD's own 1,600-token guide for a spec file,
because of the size of the matrix. That is deliberate and it is flagged in the
file: the two story files are the units an implementer actually loads, and both
are within range.

## How it was produced

BMAD 6.12.0's own workflow, run on the build machine on 2026-09-22 in a fresh
copy of the Swift lane, in two steps:

1. **`/bmad-build`**, handed Exercise 2's planning prompt verbatim, told to
   write the spec and halt after planning. It produced all four files, set the
   status to `ready-for-dev`, and put five clarifying questions in the spec
   under a heading marking them unanswered, each with options, consequences and
   a recommendation. Two of the five were the brief's two deliberate
   ambiguities, and its recommendation on each matched the way the hidden suite
   decides it.
2. A second pass, handed the five answers, which moved each one into the frozen
   block, resettled the matrix rows that depended on them, removed the
   unanswered-questions section, unblocked both stories and updated
   `stories.yaml` and both story files.

Nothing here was authored by hand.

One thing about that run will differ from yours: `/bmad-build` normally asks its
clarifying questions in conversation and waits. The build run could not answer
in-session, so it was told to write the questions into the spec instead. Your
run will ask you. Answer in the spec anyway — Exercise 2 step 5 is the whole
point, and an answer that lives only in the chat is gone at the next `/clear`.

## The two ambiguities, and how these artifacts resolve them

The hidden acceptance suite decides both one way. The frozen block decides them
the same way, so an implementation that follows it passes:

- **Membership is by posted day.** "A transaction belongs to the period holding
  its posted day (`Transaction.postedDay`). The authorized date never decides
  membership or order." The matrix names the row that separates the two
  readings: LK-015, authorized 2026-03-04 and posted 2026-03-05, lands in
  `03-05…04-04`, while LK-011, posted 2026-03-04, lands in `02-05…03-04`.
- **A start day the month does not have is clamped to that month's last day.**
  With `startDay` 31, the February 2026 period opens on 2026-02-28 and the
  period before it runs 2026-01-31 through 2026-02-27. The matrix also pins the
  whole fixture under the `month-end` configuration into a single period,
  2026-02-28 through 2026-03-30.

The frozen block also settles two things the suite does not test: a malformed
row is skipped rather than fatal, and one rule governs the whole list, with
multi-rule transitions named as out of scope. That second one is what
Exercise 3's late change arrives to reopen, which is the point.

## A note on the version

These artifacts came out of BMAD 6.12.0, the version the Day 3 pages pin;
`npx bmad-method install` gives you that version or later. The spec's
shape — frontmatter status, a frozen block, `stories.yaml`, per-story Markdown —
did not change between those two releases, but skill names are the thing BMAD
renames. `ls .claude/skills` in your own project settles it in one second.
