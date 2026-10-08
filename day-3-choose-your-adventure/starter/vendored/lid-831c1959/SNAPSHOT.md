# LID at commit 831c1959 — offline snapshot

- **Commit:** `831c19591cc879b66df40106da8fe72062e85cf0`, authored 2026-08-11,
  the tip of `main` on the capture date
- **Plugin versions in this commit:** `linked-intent-dev` 1.3.0,
  `arrow-maintenance` 1.2.0, `lid-experimental` 0.2.0
- **Captured:** 2026-09-22
- **Command that produced it:** `git clone https://github.com/jszmajda/lid.git`,
  then the `.git/` folder was deleted

## The install commands, verbatim from the repository's own README

Typed inside Claude Code. These four lines are the Quickstart block at the top
of `lid/README.md`, copied without edits:

```
/plugin marketplace add jszmajda/lid
/plugin install linked-intent-dev@jszmajda-lid
/plugin install arrow-maintenance@jszmajda-lid
/linked-intent-dev
```

The marketplace name on the right of the `@` is `jszmajda-lid` with a hyphen,
and it comes from `lid/.claude-plugin/marketplace.json`, not from the GitHub
path `jszmajda/lid` with a slash that you feed to `marketplace add`. Getting
those two the wrong way round is the usual first-try failure.

The optional third plugin, which Day 3 does not use:

```
/plugin install lid-experimental@jszmajda-lid
```

## What is here

```
lid/                          the repository, .git removed
lid/README.md                 the methodology and both walkthroughs
lid/AGENTS.md                 the directive block LID applies to itself
lid/plugins/linked-intent-dev/   3 skills: linked-intent-dev, update-lid, lid-coach
lid/plugins/arrow-maintenance/   2 commands and 2 skills: map-codebase, arrow-maintenance
lid/plugins/lid-experimental/    1 command and 1 skill: bidirectional-differential
lid/docs/                     LID's own design tree, applied to itself
lid/examples/urlshort/        a project specified as intent only, no code
```

`lid/CLAUDE.md` and `lid/CHANGELOG.md` are symlinks inside the repository, the
way the project ships them. They are kept because deleting them would change
what the repository looks like.

## What a learner does with it

**If the plugin marketplace will not resolve.** Point Claude Code at the plugin
folders on disk instead of at GitHub. From inside `day3-work`:

```sh
claude --plugin-dir ../day-3-choose-your-adventure/starter/vendored/lid-831c1959/lid/plugins/linked-intent-dev \
       --plugin-dir ../day-3-choose-your-adventure/starter/vendored/lid-831c1959/lid/plugins/arrow-maintenance
```

That loads both plugins for that session only and leaves nothing behind, so the
slash commands are spelled exactly as the day's pages spell them. Start the
session this way every time for the rest of Day 3; a plain `claude` will not
have them.

**If you cannot load plugins at all.** The methodology still works, because it
is text. `lid/AGENTS.md` is the directive block LID puts in front of an agent:
read it, and the arrow — high-level design to low-level designs to EARS
requirements to tests to code — is fully specified. `lid/examples/urlshort/`
shows a finished design tree at a size you can read in ten minutes, which is
the fastest way to see what an EARS requirement with a semantic ID looks like.
You will be doing by hand what the skill would have walked you through, and the
comparison card has a line for exactly that.

## What was stripped

The `.git/` folder, 2.2 MB of history. Nothing else: no `node_modules/` and no
build output existed in the repository. The working tree is 1.9 MB across 142
files. Because history is gone, `git log` will not tell you the commit — the
commit hash at the top of this file is the record.

## Staleness

`linked-intent-dev` is 1.3.0 in the plugin's own manifest and 1.2.0 in the
marketplace listing at this commit; the plugin manifest is the number that
matters. If you install from the live marketplace and `claude plugin list`
shows something newer, expect the skill text to have moved before the command
names do.
