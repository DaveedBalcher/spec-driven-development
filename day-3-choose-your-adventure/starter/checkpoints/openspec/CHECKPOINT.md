# OpenSpec checkpoint: the planning artifacts for Change C

Copy these in at Exercise 2's 25-minute checkpoint if your planning phase has
overrun. Taking the checkpoint is not failing the exercise; it exists so that a
slow planner still gets to run the implementation and grade it.

> **The `git status` line.** Task 4.2 in `tasks.md` runs `git status --short`
> and `git diff --stat`. That is what OpenSpec wrote, kept as recorded output.
> It does not work in `day3-work`: in a clone of the course, git reports on the
> whole course and ignores this folder, and a download has no repository at
> all. Use the exercise page's `diff -ruN` line against the shipped lane
> instead, and tick 4.2 when that diff lists only the paths the task names.
> Exercise 3's archive step continues past this task with `--yes` for the same
> reason.

From inside `day3-work`:

```sh
cp -R ../day-3-choose-your-adventure/starter/checkpoints/openspec/changes/. openspec/changes/
```

Then carry on at the implementation step with `/opsx:apply`. If you already have
a change of your own under `openspec/changes/`, delete it first or you will be
working two plans at once.

## What is here

A complete `add-statement-periods` change folder, exactly as OpenSpec 1.13.1
lays one out:

```
changes/add-statement-periods/proposal.md                    why, what changes, decisions
changes/add-statement-periods/design.md                      the technical approach
changes/add-statement-periods/tasks.md                       the numbered checklist /opsx:apply works
changes/add-statement-periods/specs/statement-cycle/spec.md  delta spec: parsing the cycle table
changes/add-statement-periods/specs/statement-periods/spec.md delta spec: the periods themselves
changes/add-statement-periods/.openspec.yaml                 the change's own metadata
```

`openspec validate add-statement-periods` reports it valid.

## How it was produced

Two steps, both run by OpenSpec's own workflow on the build machine on
2026-09-22, against a fresh copy of the Swift lane with OpenSpec 1.13.1
installed and `openspec init` run in it:

1. **`/opsx:propose`**, handed Exercise 2's planning prompt verbatim. It wrote
   all five artifacts and stopped, with four open questions blocking the task
   list. Two of those four were the brief's two deliberate ambiguities — it
   found both on its own and named the fixture row that exposes the first one.
2. **`/opsx:update`**, handed the four answers. It folded them into the
   proposal, both delta specs, the design note and the task list, turned the
   "Open questions" heading into "Decisions on what the brief left open", and
   unblocked every task.

Nothing here was written by hand. No implementation code was produced at either
step, and none is included.

## The two ambiguities, and how these artifacts resolve them

The hidden acceptance suite decides both one way. These artifacts decide them
the same way, so an implementation that follows them passes:

- **Membership is by posted date.** The requirement
  `A transaction is placed by its posted date` says so, and a scenario pins the
  fixture row that separates the two readings: `LK-015`, authorized 2026-03-04
  and posted 2026-03-05, belongs to the period that opens on 2026-03-05.
  The authorized date never decides membership.
- **A start day the month does not have is clamped to that month's last day.**
  The requirement
  `A start day the month does not have is clamped to the month's last day`
  says so, and its scenarios pin February 2026: a cycle with `startDay` 31
  opens its February period on 2026-02-28, and the period before it runs
  2026-01-31 through 2026-02-27. Clamping touches only the short month — March
  still opens on the 31st.

The delta specs also settle two things the brief leaves open that the suite does
not test: a row that does not parse is skipped, and multi-rule configurations
are out of scope for this change. That second one is what Exercise 3's late
change arrives to modify, which is the point.

## What to do with it

Read it before you copy it. The five-minute version: `proposal.md` for the
shape, then the `### Requirement:` headings in
`specs/statement-periods/spec.md`, then `tasks.md`, which is the file
`/opsx:apply` actually works through. Then your card's question about where a
decision ends up living has an answer you can point at.
