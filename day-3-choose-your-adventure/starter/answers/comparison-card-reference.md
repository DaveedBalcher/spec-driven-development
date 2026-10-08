# Reference comparison card: OpenSpec

Exercise 3's page embeds all three reference cards, OpenSpec, LID and BMAD, in
its "Reference answers" section. Those cards are authoritative: where this file
and the page differ, the page is right. This file is the OpenSpec card on its
own, the one the page shows a learner who ran LID; there is no separate file
for the LID or BMAD card.

Read it the way the exercise asks you to read your own: an answer you cannot
say without saying "it depends" is an answer nobody observed. Every line below
is traceable to a ledger id or to OpenSpec 1.13.1's own command text in this
course's snapshot, and says so where it was observed on the build machine on
2026-09-22 rather than documented. A line marked as a judgement is the card's
opinion.

## 1. What does it install, and what does that require?

- A global CLI: `npm install -g @fission-ai/openspec@latest` puts `openspec` on your PATH, needs Node 20.19.0 or later, and the notes here are pinned to version 1.13.1. On the build machine `openspec init`, choosing Claude Code, wrote fifteen files: `openspec/config.yaml`, two `.gitkeep` placeholders under `openspec/`, and six commands and six skills under `.claude/`. It wrote nothing into `CLAUDE.md` or `AGENTS.md`. <!-- ledger: openspec-01, openspec-03, openspec-04, openspec-obs-02, openspec-obs-03 -->

## 2. Where do specs live?

- In `openspec/specs/`, inside the `openspec/` directory `openspec init` scaffolds; a change in flight lives in `openspec/changes/<name>/`, which on the build machine for Change C held `proposal.md`, `design.md`, `tasks.md`, `.openspec.yaml` and one delta spec per capability. <!-- ledger: openspec-05, openspec-06, openspec-obs-07 -->

## 3. What command creates a spec?

- `/opsx:propose <feature description>`, typed in Claude Code, which produces the proposal and the delta specs rather than a single file. <!-- ledger: openspec-08 -->

## 4. What command implements one?

- `/opsx:apply`, which works the task list the proposal produced; the delta specs are what it implements against. <!-- ledger: openspec-09 -->

## 5. What happens to a spec after its change ships?

- `/opsx:archive` moves the change into `changes/archive/` under a date-prefixed folder name. In 1.13.1 it offers to sync the delta specs into `openspec/specs/` first, so the change folder expires while the requirement it carried stays. <!-- ledger: openspec-10, openspec-20; vendored: openspec-1.13.1/project-files/.claude/commands/opsx/archive.md -->

## 6. How did it handle a requirement that arrived late?

- The documented path is a second proposal whose delta sits under `## MODIFIED Requirements` against the requirement already shipped, then `/opsx:apply`, then `/opsx:archive`. The archive's sync updates the shipped requirement in place in `openspec/specs/`, keeping the scenarios the delta does not mention. Not run on the build machine. <!-- ledger: openspec-14, openspec-09, openspec-10; vendored: openspec-1.13.1/project-files/.claude/commands/opsx/sync.md -->

## 7. What is the one thing it did that you would not want on your team?

- Telemetry is on unless each machine turns it off, with `openspec config set telemetry.enabled false` or `OPENSPEC_TELEMETRY=0`, which a regulated team has to remember on every machine. A judgement. <!-- ledger: openspec-19 -->

## 8. Which failure from Lesson 4 would you adopt it to fix?

- Lesson 4's second question: a shipping codebase that changes a ticket at a time, where every spec attempt grows into a document about the whole system. The delta-against-a-living-spec shape is the one that fits. <!-- ledger: openspec-13, openspec-14 -->

## What this card does not settle

The published sources disagree about whether `openspec init` writes anything
into `AGENTS.md` or `CLAUDE.md` when Claude Code is selected. On the build
machine it wrote into neither (openspec-obs-03), which is one version on one
machine, not a ruling. A learner comparing cards should answer that one from
their own Exercise 1 diff.

Sources: openspec-01, openspec-03, openspec-04, openspec-05, openspec-06, openspec-08, openspec-09, openspec-10, openspec-13, openspec-14, openspec-19, openspec-20; observed on the build machine on 2026-09-22: openspec-obs-02, openspec-obs-03, openspec-obs-07; OpenSpec 1.13.1's `archive.md` and `sync.md` in `starter/vendored/openspec-1.13.1/project-files/.claude/commands/opsx/`.
