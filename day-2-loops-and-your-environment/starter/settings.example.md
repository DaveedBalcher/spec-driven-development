# Notes on settings.example.json

JSON carries no comments, so the rule-by-rule reading lives here. Copy
`settings.example.json` to `day2-work/.claude/settings.json`, edit it there, and
open this file once your predictions are written: it explains every rule, so
reading it first gives the answers away.

Read the file deny first, then ask, then allow. That is the order the engine
evaluates in, and the first rule that matches ends the decision — a later,
narrower rule does not overrule an earlier, broader one. Writing the file in
evaluation order means you read it the way it runs.

## The two keys above `permissions`

They are not permission rules. They are the two keys every lane ships in its
own `.claude/settings.json`, copied here so this file does not drop them when it
replaces that one.

| Key | Why |
| --- | --- |
| `claudeMdExcludes` | Claude Code loads every `CLAUDE.md` and `CLAUDE.local.md` in the folder it starts in and in each folder above it. This pattern skips any that is not in a folder whose name starts with `day` and ends with `-work`, such as `day2-work`, or in a `.claude` folder, such as one at the root of the repository you cloned the course from. The session then reads the lane's `CLAUDE.md` and your personal files only. |
| `autoMemoryEnabled: false` | In a clone, all three days share one auto memory folder, because Claude Code keeps it per git repository, and a reset does not clear it. Turning it off keeps each day's session to itself. Your own projects keep the default. |

## `defaultMode: "acceptEdits"`

The posture before any rule matches: reads, file edits and common filesystem
commands go through without a prompt. It is the mode this sandbox is designed
for, because the whole point of a runner is that nobody is sitting there
approving edits. `plan` is the value a team picks when it wants every session to
start read-only.

## The deny list, written first

| Rule | Why |
| --- | --- |
| `Bash(rm:*)` | No run in this sandbox needs to delete anything. This is the rule Exercise 3's fifth probe runs into; leave it where it is. |
| `Bash(gh pr merge:*)`, `Bash(gh pr close:*)`, `Bash(gh release:*)` | Three actions other people see immediately. None of them is ever the right move for an unattended loop. |
| `Bash(git push:*)` | Pushing is a decision a person makes, never a step in an unattended loop. |
| `Bash(curl:*)`, `Bash(wget:*)`, `WebFetch` | The sandbox has no egress, and a rule that says so out loud saves the planning iteration that assumes it does. `WebFetch` with no parentheses is the bare-tool form: the tool is removed rather than narrowed. |
| `Read(./.env)`, `Read(./**/*.pem)` | Nothing in LedgerKit has a secret in it. The rules are here so the pattern is in front of you when you write the file for a repository that does. |

Starting from deny gives you a list of things you decided were never acceptable
here. Starting from allow gives you a list of things you happened to think of.

## The ask list

| Rule | Why |
| --- | --- |
| `Bash(gh:*)` | Everything the deny list did not already refuse. Reading a pull request is usually fine and occasionally not, and "usually" is exactly what an ask rule is for. |
| `Bash(git commit:*)` | A commit inside a run is a checkpoint you want to know about. |

A "Yes, and don't ask again" at one of these prompts saves its rule to
`.claude/settings.local.json`, usually at the root of the git repository
(Exercise 3's reveal lists the exceptions), not to the file you edited. That
file is personal and uncommitted, so the rule you just created is yours and not
your team's. Promoting it is a deliberate edit to `.claude/settings.json`.

## The allow list

| Rule | Why |
| --- | --- |
| `Bash(git status)`, `Bash(git diff:*)`, `Bash(git log:*)` | Read-only: each reports on a repository and changes nothing. The runner does not use them: `day2-work` has no repository of its own, so the runner measures its diff with `diff -ruN` against the shipped lane. They are here for the repository you take this file to. |
| `Bash(swift test:*)`, `Bash(./gradlew test)` | The verification command from the spec. A runner that has to ask to run the tests is not a runner. |
| `Bash(rm -rf build)` | Deliberately contradictory, and left in on purpose. It looks reasonable — clearing a build directory is housekeeping — and it does nothing, because `Bash(rm:*)` in the deny list is evaluated first and the first match wins. |
| `Read(./**)` | Reads inside the working copy. Generous on purpose: a read that goes wrong costs tokens, a write that goes wrong is visible to other people. |
| `Edit(./Sources/**)`, `Edit(./src/**)`, `Edit(./Tests/**)` | Both lanes' source and test trees. Everything the spec puts in bounds and nothing else. |
| `Edit(./run-log.md)` | The runner's own log. Without it, every iteration line is a prompt. |

## What these rules are not

They are policy for one tool's behaviour, not a wall around your machine. The
real boundary is the connector's own configuration, the sandbox's network
setting, and the service account's permissions on the far side. These rules keep
an honest agent inside the lines.

<!-- Sources: cc-core-21 (rule syntax Tool(pattern)); cc-core-22 (deny, then ask, then allow; first match wins regardless of specificity); cc-core-23 (settings file locations and precedence); cc-core-06 (defaultMode in .claude/settings.json); cc-core-07 (the permission-mode values); cc-core-24 (/permissions); enterprise-07 (Tool(specifier) form); enterprise-09 (a bare tool in deny removes the tool entirely); enterprise-11 (shared .claude/settings.json versus personal .claude/settings.local.json); cc-core-39 (a "Yes, and don't ask again" approval saves to .claude/settings.local.json at the root of the git repository, or beside .claude/settings.json outside one); cc-core-43 (claudeMdExcludes skips ancestor CLAUDE.md files by glob, at any settings layer); cc-core-44 (auto memory is shared by every subdirectory of one git repository; autoMemoryEnabled turns it off per project). -->
