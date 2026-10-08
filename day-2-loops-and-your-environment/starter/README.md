# Day 2 starter files

Everything Day 2's four exercises copy into place. Nothing here is live: there
is no `.claude/` directory in this folder, and no file in it affects a session
until an exercise copies it. That is deliberate — you should see each file
arrive and know why it is there.

Day 2 works in `day2-work/`, a full copy of your lane's sandbox made by
Exercise 1's setup block. It is not Day 1's `work/` scratch folder, and the name
is different on purpose so the two days cannot collide. Every command below runs
from inside `day2-work`.

## Which exercise copies what

| File or directory | Copied to | By |
| --- | --- | --- |
| `skills/run-spec/SKILL.md` | `day2-work/.claude/skills/run-spec/SKILL.md` | Exercise 1 setup |
| `specs/daily-summary.md` | `day2-work/specs/daily-summary.md` | Exercise 1 setup |
| `run-log.template.md` | `day2-work/run-log.template.md` | Exercise 1 setup |
| `reference/after-e1/` | `day2-work/` | Exercise 2 catch-up block, only if Exercise 1 was not finished |
| `agents/spec-auditor.md` | `day2-work/.claude/agents/spec-auditor.md` | Exercise 2 setup |
| `acceptance/change-b/swift/` | `day2-work/Tests/LedgerKitTests/` | Exercise 2, step 7 |
| `acceptance/change-b/kotlin/` | `day2-work/src/test/kotlin/` | Exercise 2, step 7 |
| `env-profile.md` | `day2-work/env-profile.md` | Exercise 3 setup |
| `prediction-grid.md` | `day2-work/prediction-grid.md` | Exercise 3 setup |
| `settings.example.json` | `day2-work/.claude/settings.json` | Exercise 3 setup |
| `scripts/` | `day2-work/scripts/` | Exercise 4 setup |
| `fixtures/` | `day2-work/fixtures/` | Exercise 4 setup |
| `answers/`, `reveal/` | nowhere | read in place, after you have written your own answer |

## The files, one by one

### `skills/run-spec/SKILL.md`

The runner. A skill is a Markdown file with YAML frontmatter at
`.claude/skills/<name>/SKILL.md`, and you invoke it by name with an argument:
`/run-spec specs/daily-summary.md`. The body is the procedure: read the spec,
implement, run the tests, repair on red, and stop on green, on iteration five,
or at a gate. It appends one line per iteration to `run-log.md`.

Read it before you run it. Exercise 1 asks you to write down the three exits and
the iteration cap from the file itself, before the loop starts, and that is the
whole point of the step. <!-- cc-automation-01, cc-automation-03 -->

### `specs/daily-summary.md`

The reference Change B spec: four numbered criteria, bounds, a line budget,
verification commands for both lanes, stop conditions, and a definition of done.
It is Day 1's Exercise 3 reference answer sharpened for the runner, with a Shape
section the Exercise 2 acceptance suite compiles against. Run this one even if
you wrote your own on Day 1, and compare yours with it afterwards.

### `run-log.template.md`

The format the runner appends to: one line per iteration, four pipe-separated
fields. The log is the run's memory. The conversation is not, which is why
`/clear` between attempts costs you nothing you needed. <!-- cc-core-19 -->

### `agents/spec-auditor.md`

The fresh-context auditor. A subagent is a Markdown file with YAML frontmatter
under `.claude/agents/`. Its `tools:` line is `Read, Glob, Grep`, so it can
report and not edit, and its `model:` line is set explicitly rather than left to
a default. Invoke it by name; do not hope it gets picked up.

A subagent starts with a fresh, isolated context window whatever you do, and
does not see your conversation, the skills you invoked, or the files Claude
already read (a fork, which inherits the conversation, is the documented
exception). What reaches it is a delegation message composed by the session you
sit in. Exercise 2 runs `/clear` before the audit, and that is not what isolates
the auditor: `/clear` empties that session, so the message comes from your
prompt.
<!-- cc-core-25, cc-core-26, cc-core-27, cc-core-28, cc-core-38 -->

### `acceptance/change-b/`

The hidden suite. Six assertions, one per reference finding, written against the
spec and its two routed sharpenings — not against anybody's implementation.
Do not read it before your own run. Exercise 2, step 7 copies it in, from inside
`day2-work`:

```bash
# Swift lane
cp -R ../day-2-loops-and-your-environment/starter/acceptance/change-b/swift/. Tests/LedgerKitTests/
# Kotlin lane
cp -R ../day-2-loops-and-your-environment/starter/acceptance/change-b/kotlin/. src/test/kotlin/
```

### `reference/after-e1/`

A finished Exercise 1 result for the learner who ran out of time: the
implementation a runner produced, the tests it rewrote, and a `run-log.md` with
four iterations and one gate. The suite is green and the implementation is wrong
in six places. `reference/after-e1/README.md` has the copy commands per lane.

### `env-profile.md`

Six rows describing your environment: connectors and their direction, egress,
sanctioned write commands, available models, where shared configuration lives,
and the sandbox limits. The defaults match the keys in `assets/env-profile.js`,
so a team that fills both has the pages and the file saying the same thing.
Generic on purpose: no employer, no system name, no repository name.

### `prediction-grid.md`

Six commands, predicted before they are observed. Fill the prediction column
first. One of the six is designed to disagree with a reasonable prediction.

### `settings.example.json`

A permissions file with the deny list written first, then ask, then allow —
the order the engine evaluates in, first match winning regardless of how
specific a later rule is. JSON carries no comments, so the rule-by-rule reading
lives beside it in `settings.example.md`.

Leave the deny rule covering `rm` where it is. Exercise 3's fifth probe runs
`rm -rf build`, and that rule is what stands between the probe and your lane's
build directory. <!-- cc-core-21, cc-core-22, cc-core-23 -->

### `scripts/` and `fixtures/`

The vetted write wrapper and the directory it writes to.

Exercise 4's setup block copies them in; from inside `day2-work` the copy is:

```bash
cp -R ../day-2-loops-and-your-environment/starter/scripts ../day-2-loops-and-your-environment/starter/fixtures .
chmod +x scripts/*.sh
```

- `post-pr-comment.sh` — the wrapper. Five properties: the credential is read in
  one function, only an allowlisted action runs, `--dry-run` prints the exact
  request and sends nothing, a real send needs an explicit confirmation, and
  every send writes one log line. <!-- enterprise-12, enterprise-13, enterprise-14 -->
- `allowlist.txt` — the repositories the wrapper may write to. It is loaded and
  then never checked. Making it binding is Exercise 4.
- `post-pr-comment.test.sh` — the self-test. Seven checks, green as shipped,
  ending in one `PASS 7 checks` line with a matching exit status. Exercise 4
  adds the eighth.
- `selftest.sh` — a stable entry point that runs the same checks, so the course's
  own build checks and a person at a terminal run the same thing.
- `fixtures/local-repo/` — a directory pretending to be a repository. Out of the
  box the wrapper has no network path at all: it appends to a file here.

Nothing in Day 2 can reach a real repository.

### `answers/` and `reveal/`

Read in place, after your own answer exists.

- `answers/reference-findings.md` — the six findings as a scoring sheet.
- `reveal/findings-change-b.md` — the same six with evidence, fixes and routing.
- `reveal/claude-md-diff.md` — the net-zero `CLAUDE.md` revision: what went in,
  what came out, and what did not go in.

## Resetting

Every Day 2 exercise resets the same way: quit Claude Code, then from inside
`day2-work` run your lane's line:

```bash
# Swift lane
cd .. && rm -rf day2-work && cp -R sandbox/swift day2-work && cd day2-work
# Kotlin lane
cd .. && rm -rf day2-work && cp -R sandbox/kotlin day2-work && cd day2-work
```

That replaces the copy with a fresh one from the shipped lane and leaves `work/`
alone. A fresh copy has none of the day's installs, so re-run the setup block of
the exercise you are on before you continue.
