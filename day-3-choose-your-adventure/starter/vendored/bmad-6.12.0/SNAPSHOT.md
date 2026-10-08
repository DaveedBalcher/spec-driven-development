# BMAD 6.12.0 — offline snapshot

- **Version:** 6.12.0. `npm view bmad-method version` returned `6.12.0` on the
  capture date, and the installer wrote `version: 6.12.0` into
  `_bmad/_config/manifest.yaml` for the installation and for both modules.
  Day 3's pages pin the same version, so this snapshot matches them on the
  capture date; see "Staleness" below before you trust a command name later.
- **Captured:** 2026-09-22
- **Command that produced it:**
  `npx bmad-method install --yes --directory "$PWD" --modules bmm --tools claude-code`,
  run inside a fresh copy of `sandbox/swift`

That is the non-interactive spelling of `npx bmad-method install` with the
default module selection and Claude Code chosen at the tool prompt. It is what
this snapshot is a copy of.

## What is here

```
project-files/_bmad/            the framework: config, scripts, module data
project-files/.claude/skills/   29 skills, one folder each, bmad-* names
```

The installer wrote 235 files, 2.1 MB. `project-files/` holds all 235, and the
installer wrote nothing else: `CLAUDE.md` was not modified, and no `AGENTS.md`
was created.

Four things about the copy:

- The three HTML assets the installer writes (`.claude/skills/bmad-brainstorming/assets/brain-selector.html`, `.claude/skills/bmad-prd/assets/validation-report-template.html` and `.claude/skills/bmad-ux/assets/validation-report-template.html`) are here, copied on 2026-09-24 from the `bmad-method@6.12.0` npm package (`src/core-skills/bmad-brainstorming/assets/` and `src/bmm-skills/plan/bmad-{prd,ux}/assets/`), the same files the installer copies. The course uses none of those three skills; the course's page checks skip `vendored/`, so these files are not read as course pages.

- The empty `_bmad-output/` directory the installer also creates is not here,
  because an empty folder cannot travel in a repository. Run
  `mkdir -p _bmad-output` after you copy.
- The installer writes your system username into three files as `user_name`.
  The build machine's name was replaced with `you` in
  `_bmad/config.user.toml`, `_bmad/core/config.yaml` and `_bmad/bmm/config.yaml`.
  It is only what BMAD's agents call you; change it or leave it.
- `_bmad/custom/config.user.toml` carries BMAD's own `*.user.toml` ignore rule
  from `_bmad/custom/.gitignore`, so git may drop it when this course is
  committed. It is a three-line comment header with no settings in it. If it is
  missing after you copy, nothing breaks; the installer writes it again on a
  real install.

`_bmad/render/` is a cache, empty here and ignored by BMAD's own rule. The first
time you invoke a skill it fills with that skill's rendered workflow — about
fifteen files for `bmad-build` alone. That is expected and is not part of the
install.

The install left `installShims: false` in `_bmad/_config/manifest.yaml`. The
deprecated skill names — `bmad-quick-dev`, `bmad-dev-auto` — are therefore not
present; only `bmad-build` and `bmad-build-auto` are. Passing `--shims` to the
installer would have added them.

## What a learner does with it

**If the network is blocked and `npx` cannot reach the registry.** From inside
`day3-work`:

```sh
cp -R ../day-3-choose-your-adventure/starter/vendored/bmad-6.12.0/project-files/. .
mkdir -p _bmad-output
```

The skills are Markdown and they work from this copy, so `/bmad-build`,
`/bmad-spec`, `/bmad-sprint-planning` and `/bmad-code-review` are all there. The
project name in `_bmad/config.toml` reads `project` because the installer takes
it from the folder it ran in on the build machine; edit that line if it bothers
you.

**What this snapshot cannot give you is `uv`.** BMAD's skills call
`uv run _bmad/scripts/...` on activation, and `bmad-build` and `bmad-build-auto`
halt when `uv` is not on your PATH. No copy of files fixes that. This is why
Exercise 1 checks `uv --version` before the install rather than after: if `uv`
is missing and you cannot install it on this machine, the honest move is to
switch tabs.

## What was stripped

Nothing from the install output: the snapshot holds all 235 installed files.
There was no `node_modules/`, no `.git/` and no build output in the install
footprint — BMAD installs Markdown, TOML, YAML, CSV and five short Python
scripts, and nothing that needs compiling. The npm package itself is not
vendored here; `npx` downloads a 60 MB package to run an installer that writes
2 MB, and the 2 MB is the part you need.

## What could not be captured

The installer's own interactive prompts could not be driven to completion from
the build harness, which has no terminal attached: the run reached
`Installation directory:` and stopped there, because that prompt reads a line
from the keyboard. What the build machine did observe verbatim, before that
point, was the ASCII banner, a block stating that `uv` is REQUIRED and that
"Without it, bmad-build and bmad-build-auto halt on activation", the line
`✅ Python UV check pass (uv 0.11.0 detected).`, and then the directory prompt
pre-filled with the current folder. The prompts after it, read out of the
installer's own source rather than seen on screen, are: `Install to this
directory?`, `Select official modules to install:`, `Do you want to install
custom or community modules (Git URL or local path)?`, `Integrate with:` — the
tool picker where you choose Claude Code — and, on a re-run over an existing
install, `How would you like to proceed?`, `Create backup before updating?` and
`Preserve local customizations?`. Treat that list as the installer's source
code says it, not as a transcript.

## Staleness

Two things to re-check before you trust anything here. First, the version: the
day's pages and this snapshot both say 6.12.0, and BMAD ships roughly monthly
with breaking renames. Second, the skill names: BMAD renamed `bmad-quick-dev` to
`bmad-build` and `bmad-dev-auto` to `bmad-build-auto`, and says the compatibility
shims for the old names last only until its v7 cut. `ls .claude/skills` in your
own project is the authority, and it takes one second.
