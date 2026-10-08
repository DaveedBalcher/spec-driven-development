# OpenSpec: the commands this day uses

Every command here runs from inside `day3-work`, the copy of your lane at the
course root, the directory holding `CLAUDE.md` and the package manifest.
That is where the framework gets initialized and where every test command runs.
Nothing on this page is a command the exercises do not use, and nothing the
exercises use is missing from it.

The slash commands are typed inside Claude Code. The `openspec` commands are
typed in a shell.

| Command | What it is for | Ledger id |
| --- | --- | --- |
| `npm install -g @fission-ai/openspec@latest` | Installs the CLI globally. | openspec-01 |
| `openspec init` | Initializes the project; asks which tools to wire up. | openspec-05 |
| `openspec list` | Lists changes. An empty list with no error is a freshly initialized project. | openspec-18 |
| `openspec validate <name>` | Checks a change's files; Exercise 2 runs it on the change `openspec list` names. | openspec-18 |
| `/opsx:propose <feature description>` | Produces the proposal and the delta specs for a change. | openspec-08 |
| `/opsx:apply` | Works the task list and implements the change. | openspec-09 |
| `/opsx:archive` | Archives a change once it has shipped. Exercise 3 runs it once, on Exercise 2's change, before proposing the late one, and stops before archiving the late one. | openspec-10 |

Exercise 1 also checks the runtime before installing anything: OpenSpec's
package requires Node `>=20.19.0` (openspec-03), and the version this course
pinned its notes to is 1.13.1 (openspec-04).

## What the exercises read, beyond the commands

`openspec init` scaffolds `openspec/config.yaml`, `openspec/specs/` and
`openspec/changes/archive/` (openspec-06). A delta spec adds requirements under
`## ADDED Requirements` and changes a shipped one under `## MODIFIED
Requirements` (openspec-13, openspec-14) — Exercise 3's late change is the
second of those. A requirement is a `### Requirement: [Name]` entry
(openspec-16) with `#### Scenario: [Name]` blocks under it carrying GIVEN,
WHEN and THEN lines (openspec-17). An archived change lands in
`changes/archive/` under a date-prefixed folder name (openspec-20). In 1.13.1,
`/opsx:archive` offers to sync the delta specs into `openspec/specs/`, and that
sync updates a MODIFIED requirement in place, keeping the scenarios the delta
does not mention, while an ADDED one under a new name lands beside the old
(OpenSpec's own command text, `archive.md` and `sync.md` in
`vendored/openspec-1.13.1/project-files/.claude/commands/opsx/`). Exercise 3
needs that sync: a MODIFIED delta has nothing to modify in an empty
`openspec/specs/`.

## What is not settled

The published sources disagree about whether `openspec init` writes anything
into `AGENTS.md` or `CLAUDE.md` when you pick Claude Code, and this course does
not pick a side. On the build machine, 1.13.1 wrote into neither (openspec-obs-03),
which is one version on one machine, not a ruling. Exercise 1 has you diff
`day3-work` against the shipped lane after the install so you record what your
own run did. Treat that diff, not this
page, as the answer for your machine.

Sources: openspec-01, openspec-03, openspec-04, openspec-05, openspec-06, openspec-08, openspec-09, openspec-10, openspec-13, openspec-14, openspec-16, openspec-17, openspec-18, openspec-20; observed on the build machine on 2026-09-22: openspec-obs-03; OpenSpec 1.13.1's `archive.md` and `sync.md` in `vendored/openspec-1.13.1/project-files/.claude/commands/opsx/`.
