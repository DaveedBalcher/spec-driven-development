# BMAD: the commands this day uses

Every command here runs from inside `day3-work`, the copy of your lane at the
course root, the directory holding `CLAUDE.md` and the package manifest.
The installer is typed in a shell; the rest are typed inside Claude Code.
Nothing on this page is a command the exercises do not use, and nothing the
exercises use is missing from it. The notes are pinned to version 6.12.0.

| Command | What it is for | Ledger id |
| --- | --- | --- |
| `npx bmad-method install` | Installs BMAD and runs its own prompts to completion. | bmad-01 |
| `/bmad-build "<what you want built>"` | The build entry point; Exercise 2 hands it the brief, and Exercise 3 hands it the updated spec. | bmad-07 |
| `bmad-sprint-planning`, then `bmad-build`, then `bmad-code-review` | The documented phase-4 chain. Exercise 2's repair prompt re-enters it at `bmad-code-review`; Exercise 3 does not run it. | bmad-11 |

Check the runtimes before you install, not after. BMAD needs Node.js 20.12 or
later (bmad-05) and `uv` with Python 3.11 or later; without `uv`, `bmad-build`
and `bmad-build-auto` halt (bmad-06). That is the one prerequisite an offline
snapshot cannot supply for you.

## What the exercises read, beyond the commands

A spec's frontmatter `status` drives the loop, through the values `draft`,
`ready-for-dev`, `in-progress`, `in-review`, `done` and `blocked` (bmad-12).
Exercise 3 sets a shipped spec back to `ready-for-dev` and hands it to
`/bmad-build`, which in 6.12.0 routes a `ready-for-dev` spec to implementation,
then review, without `bmad-sprint-planning` or `bmad-code-review`
(`bmad-build/step-01-clarify-and-route.md` in the vendored snapshot). Setting a
shipped spec back is this course's path, not a documented one.

Work is dispatched from `<spec-folder>/SPEC.md`, `<spec-folder>/stories.yaml`
and `<spec-folder>/stories/<id>-<slug>.md` (bmad-13). `bmad-build`'s own step
file names a spec it takes as new work
`<implementation-artifacts>/spec-<slug>.md` (the same vendored file); on the
build machine on 2026-09-22, a run handed Exercise 2's prompt wrote a
`statement-periods/` folder in the dispatch layout instead (bmad-obs-11). Configuration is layered
in this order: `_bmad/config.toml`, then `config.user.toml`, then
`custom/config.toml`, then `custom/config.user.toml` (bmad-18).

## What is not settled

The installed footprint of a fresh install is not documented in the sources this
course cites; on the build machine 6.12.0 wrote 235 files and left `CLAUDE.md`
alone, with no `AGENTS.md` (bmad-obs-05). That is one observation on one
machine, so Exercise 1's own diff against the shipped lane is the only listing
you should trust. The managed project-context region in a repository's root
`AGENTS.md`, `<!-- bmad:context --> ... <!-- /bmad:context -->` (bmad-19), comes
from search synthesis rather than a page that was fetched: check whether your
run wrote one, and treat the marker as unverified until you see it.

Sources: bmad-01, bmad-05, bmad-06, bmad-07, bmad-11, bmad-12, bmad-13, bmad-18, bmad-19; observed on the build machine on 2026-09-22: bmad-obs-05, bmad-obs-11; BMAD 6.12.0's `bmad-build` skill text in `vendored/bmad-6.12.0/project-files/.claude/skills/bmad-build/`.
