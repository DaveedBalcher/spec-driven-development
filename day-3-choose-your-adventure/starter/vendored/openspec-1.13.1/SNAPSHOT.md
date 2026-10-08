# OpenSpec 1.13.1 — offline snapshot

- **Version:** 1.13.1 (`openspec --version` on the build machine)
- **Captured:** 2026-09-22
- **Commands that produced it:**
  - `npm install -g @fission-ai/openspec@latest`
  - `openspec init --tools claude --no-animation` (run inside a fresh copy of
    `sandbox/swift`; `--tools claude` is the non-interactive spelling of
    choosing Claude Code at the prompt)
  - `npm pack @fission-ai/openspec`

## What is here

```
package/fission-ai-openspec-1.13.1.tgz   the npm tarball, 523 KB
project-files/openspec/                  the openspec/ folder init creates
project-files/.claude/commands/opsx/      six slash commands init writes
project-files/.claude/skills/openspec-*/  six skills init writes
```

`project-files/` is a byte copy of everything `openspec init` put in the
project, and nothing else. The install and the init together touched no other
file: `CLAUDE.md` was not modified and no `AGENTS.md` was created. That is worth
knowing before you copy anything in, because it means this snapshot cannot
collide with your lane's standing instructions.

## What a learner does with it

**If the network is blocked and you cannot run `npm install -g`.** This copy
shows you the layout only: the slash commands and the folder `openspec init`
writes, without the CLI. From inside `day3-work`:

```sh
cp -R ../day-3-choose-your-adventure/starter/vendored/openspec-1.13.1/project-files/. .
```

`/opsx:propose`, `/opsx:apply` and `/opsx:archive` need the `openspec` CLI. Each
declares `allowed-tools: Bash(openspec:*)` and runs an `openspec` command before
it writes anything; `/opsx:propose`'s second step runs `openspec context --json`
and stops on any failure. Without the CLI you cannot plan Exercise 2's change,
so pick another track on Exercise 1's page.

**If npm can reach a local mirror but not the public registry.** Install from
the tarball and you get the CLI too:

```sh
npm install -g ../day-3-choose-your-adventure/starter/vendored/openspec-1.13.1/package/fission-ai-openspec-1.13.1.tgz
```

Then run `openspec init` yourself in `day3-work` and ignore
`project-files/` entirely — a real init is always better than a copy.

## What was stripped

Nothing. The tarball is exactly what `npm pack` produced (401 files), and
`project-files/` is the complete init output at 15 files. There was no
`node_modules/`, no `.git/` and no build output to remove.

## Staleness

This is one version on one date. `openspec --version` is the first thing to
check if a command here behaves differently from the day's pages: the four core
command names have been stable, but the six-versus-twelve command count depends
on the profile, and `openspec config profile` can change it.
