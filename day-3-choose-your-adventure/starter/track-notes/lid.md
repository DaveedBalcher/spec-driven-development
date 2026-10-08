# LID: the commands this day uses

Every command here is typed inside Claude Code, started in `day3-work` — the
copy of your lane at the course root, the directory holding `CLAUDE.md` and the
package manifest. Every command the exercises run or name is here, and nothing
else. Exercises 2 and 3 start their changes as an ordinary message, not a
command: the `## LID` section the mapper adds to `CLAUDE.md` sends any change
through the `linked-intent-dev` skill, which walks it from the high-level design
down to tests and code, stopping after each phase (the skill's own text at
commit `831c1959`, in this starter folder's
`vendored/lid-831c1959/lid/plugins/linked-intent-dev/skills/linked-intent-dev/SKILL.md`).

| Command | What it is for | Ledger id |
| --- | --- | --- |
| `/plugin marketplace add jszmajda/lid` | Adds the LID plugin marketplace. | lid-01 |
| `/plugin install linked-intent-dev@jszmajda-lid` | Installs the core workflow plugin. | lid-02 |
| `/plugin install arrow-maintenance@jszmajda-lid` | Installs the arrow-maintenance overlay plugin. | lid-03 |
| `/arrow-maintenance:map-codebase` | Bootstraps the arrow overlay from an existing codebase. This is the one Exercise 1 runs: LedgerKit already has source and tests. | lid-08 |
| `/linked-intent-dev:update-lid` | Reconciles drift or changes mode on a project that already has LID documents. Named, not run: Exercises 2 and 3 say it is not how a change starts. | lid-06 |
| `/arrow-maintenance:arrow-maintenance` | Audits spec-to-code coherence. Named, not run: Exercise 1's reference map gives it as the later audit. | lid-09 |

## What the exercises read, beyond the commands

Code carries its requirement IDs in a line comment on the topmost function that
owns the behavior, comma-separated: `// @spec AUTH-UI-001, AUTH-UI-002`
(lid-11). Exercise 2 asks for the prefix `LK-PERIOD` on the new requirements,
which is the flat `FEATURE-NNN` form of LID's semantic IDs; a nested design tree
extends the path per level, as in `PEVAL-RUN-014` (lid-13). Requirement status
is marked in place: `[x]` implemented, `[ ]` gap, `[D]` deferred (lid-12).

The course's notes were taken against commit `831c1959`, dated 2026-08-12
(lid-25).

## What is not settled

The exact wording LID adds to `CLAUDE.md`. On the build machine the mapper
appended a 29-line `## LID` section with no marker comments (lid-obs-05), but
that run could not load the plugin's own skill body and worked from the
command's description (lid-obs-07), so your run may write a different block.
Exercise 1's diff against the shipped lane is how you find out what landed on
your machine, and a `Files … CLAUDE.md differ` line is the one to read first.

Sources: lid-01, lid-02, lid-03, lid-06, lid-08, lid-09, lid-11, lid-12, lid-13, lid-25; observed on the build machine on 2026-09-22: lid-obs-05, lid-obs-07.
