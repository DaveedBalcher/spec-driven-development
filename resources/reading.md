# Reading

Articles, docs, and repositories behind the lessons. The official Claude Code
docs are the source for every mechanical claim about the tool itself (checked
2026-09-22); everything below is grouped by the day it belongs to. Talks and
videos have their own list at `resources/videos.md` — this file is the
reading: writing you can go back to, not something you have to press play on.

## Day 1: From chat to spec

| Title | Link | Notes |
| --- | --- | --- |
| Sequoia Ascent 2026 (Karpathy's own recap) | https://karpathy.bearblog.dev/sequoia-ascent-2026/ | The summary and cleaned-up transcript Karpathy posted of the talk Day 1's opener is cut from: "vibe coding raises the floor, agentic engineering raises the ceiling," with agentic engineering as the discipline of coordinating fallible agents without lowering the quality bar. |
| A Fireside Chat with Cat and Thariq from the Claude Code team | https://simonwillison.net/2026/Jul/21/cat-and-thariq/ | Simon Willison's edited transcript of the fireside chat Day 2's opener is cut from: two people from the Claude Code team on how Anthropic splits work between Claude Code, for complex interactive tasks, and Claude Tag, a Slack-based agent that works proactively on a team's behalf. |
| Auto mode is now the default in Claude Code for Pro, Max, and Team plans | https://simonwillison.net/2026/aug/8/auto-mode/ | Covers the mode behind one of plan mode's three approval choices, worth reading before a lesson asks you to pick "auto" versus "manually approve edits." |
| How to Use Claude Code Like the People Who Built It | https://every.to/podcast/how-to-use-claude-code-like-the-people-who-built-it | Cat Wu and Boris Cherny, two of Claude Code's founding engineers, on how they use it inside Anthropic, as a podcast episode and a written article. |
| How to write a good spec for AI agents | https://addyo.substack.com/p/how-to-write-a-good-spec-for-ai-agents | A practical structure for a spec an agent can execute, with three tiers of action boundaries: always, ask first, never. Day 1 Lessons 4 and 5 point to its "ask first" tier when it lists manual criteria apart from automated ones. |
| Boris Cherny at YC Startup School: Unhobbling Claude, Deleting Prompts, and Verification | https://www.barath.ai/learnings/boris-cherny-yc-startup-school-2026 | Notes from the talk where Claude Code's own team describes cutting most of its system prompt by testing each line instead of assuming it earns its place — the source anecdote behind the CLAUDE.md-trimming exercise. |
| Effective context engineering for AI agents | https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents | Anthropic's engineering post on context as a finite resource with an "attention budget," and on techniques for spending it well: right-altitude prompts, just-in-time retrieval, compaction. |
| How Long Contexts Fail | https://www.dbreunig.com/2025/06/22/how-contexts-fail-and-how-to-fix-them.html | Four named ways a long context fails — poisoning, distraction, confusion, clash — each illustrated from published research on long contexts rather than on instruction files like CLAUDE.md. |
| Context Engineering for AI Agents: Lessons from Building Manus | https://manus.im/blog/Context-Engineering-for-AI-Agents-Lessons-from-Building-Manus | Production lessons from the Manus agent: keep the prompt prefix stable, "keep the wrong stuff in" so the agent sees its own failed actions, and use the file system as context rather than the prompt. |
| Prompt Design at Scale (arXiv) | https://arxiv.org/abs/2607.19257 | A controlled study, on a synthetic corpus across five models, of instruction-following decaying as the rules in a prompt grow from 10 to 160. It does not test CLAUDE.md files, and Day 1 Lesson 6 leaves open whether a long file is followed less closely. |

## Day 2: Loops and your environment

| Title | Link | Notes |
| --- | --- | --- |
| Autonomous Development Loops | https://docs.bmad-method.org/build/autonomous-development-loops/ | BMAD's documentation of `bmad-build-auto`, its unattended worker: a status field in the spec's frontmatter drives each run, `blocked` halts it, and it can be told to stop at `ready-for-dev` for a human before implementing. A documented example of the stop conditions and gates Day 2 Lesson 2 teaches. |
| Context engineering with Dex Horthy | https://newsletter.pragmaticengineer.com/p/context-engineering-with-dex-horthy | Includes a first-person account of a fully unattended agent pipeline that failed, a cautionary case for why a loop needs a gate rather than no human at all. |
| SE Radio 730: Birgitta Böckeler on Harness Engineering for AI Agents | https://se-radio.net/2026/07/se-radio-730-birgitta-boeckeler-on-harness-engineering-for-ai-agents/ | Splits a harness into "guides" (CLAUDE.md and similar forward-feeding instructions) and "sensors" (tests, linters, review layers that let an agent self-correct) — the vocabulary Day 1 Lessons 4 and 5 and Day 2 Lesson 1 use. |
| Skill Issue: Harness Engineering for Coding Agents | https://www.humanlayer.dev/blog/skill-issue-harness-engineering-for-coding-agents | Mitchell Hashimoto's definition of harness engineering, quoted by HumanLayer: each time an agent makes a mistake, engineer a fix so it never makes that mistake again. Day 2 Lesson 3's routing of findings into a criterion or a CLAUDE.md line is one way to do that. |
| Server configuration (GitHub MCP server) | https://github.com/github/github-mcp-server/blob/main/docs/server-configuration.md | The actual read-only, toolset-scoping, and lockdown flags for the GitHub MCP server, the primary reference for setting up a read-only connector. |
| Introduction (Figma MCP Server) | https://developers.figma.com/docs/figma-mcp-server/ | Figma's own MCP docs: the server reads design context and can also write to the canvas, so check which of its tools your team's setup allows before you call it read-only. |
| Restricting Coding Agents' CLI GitHub Write Access | https://honnibal.dev/blog/locking-down-gh | A concrete pattern for a sanctioned write path — separate read and write tokens, the write token gated behind the OS keychain — worth reading before extending this course's own write script. |
| gh pr comment | https://cli.github.com/manual/gh_pr_comment | The flags for posting a top-level pull-request comment, part of the write surface Day 2 Lesson 4 approves; that lesson's settings deny the command to the agent, which writes only through the vetted script. |
| REST API endpoints for pull request review comments | https://docs.github.com/en/rest/pulls/comments#create-a-review-comment-for-a-pull-request | The endpoint for a comment on a line of the diff, which `gh api` reaches with the same fields when the write script needs an inline comment rather than a top-level one. |
| How to Share Claude Code Skills With Your Team (2026) | https://www.agensi.io/learn/how-to-share-claude-code-skills-with-team | The pattern for committing `.claude/skills/` to the repository so everyone who pulls gets the same skills, the way a committed `.claude/settings.json` shares permissions. |

## Day 3: Choose your adventure

| Title | Link | Notes |
| --- | --- | --- |
| Spec Kit vs BMAD vs OpenSpec: Choosing an SDD Framework in 2026 | https://dev.to/willtorber/spec-kit-vs-bmad-vs-openspec-choosing-an-sdd-framework-in-2026-d3j | A practitioner's side-by-side of the mechanics this day cares about, OpenSpec's proposal/apply/archive gate included — a useful starting map, not a verdict. |
| From Prompt to Process (arXiv) | https://arxiv.org/pdf/2606.04967 | An academic process taxonomy comparing six such frameworks, OpenSpec and BMAD among them (LID is not), a check against any one framework's own marketing. |
| Understanding Spec-Driven-Development: Kiro, spec-kit, and Tessl | https://martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html | The spec-first / spec-anchored / spec-as-source distinction this course uses to sort what OpenSpec, LID, and BMAD are each actually optimizing for. |
| Why Spec-Driven Development Tools Fail in the Enterprise | https://martinelli.ch/why-spec-driven-development-tools-fail-in-the-enterprise/ | An argument that most SDD tooling assumes greenfield work and over-builds a spec for a one-line brownfield fix — read skeptically, since the author is also pitching his own approach. |
| Set up your project (OpenSpec) | https://openspec.dev/docs/setup | OpenSpec's own install and `openspec init` walkthrough, the primary reference for the OpenSpec track. |
| OpenSpec: Getting Started | https://raw.githubusercontent.com/Fission-AI/OpenSpec/main/docs/getting-started.md | The explore/propose/apply/archive workflow and the exact Claude Code slash commands (`/opsx:propose` and the rest) behind it. |
| OpenSpec: Concepts | https://raw.githubusercontent.com/Fission-AI/OpenSpec/main/docs/concepts.md | The delta-spec grammar — ADDED/MODIFIED/REMOVED requirements, Given/When/Then scenarios — that OpenSpec archives into the living spec. |
| LID: AGENTS.md | https://raw.githubusercontent.com/jszmajda/lid/main/AGENTS.md | The arrow-of-intent chain (HLD to LLDs to EARS to tests to code) and the exact `@spec` annotation format, straight from the file LID itself is governed by. |
| LID: Setup and Tool Adapters | https://raw.githubusercontent.com/jszmajda/lid/main/docs/setup.md | How LID wires into CLAUDE.md versus AGENTS.md (a symlink or an `@AGENTS.md` import), plus adapters for other tools. The brownfield path, `/arrow-maintenance:map-codebase`, is in the repository README listed below. |
| Your Code Doesn't Remember What You Meant | https://loki.ws/code/2026/05/18/your-code-doesnt-remember-what-you-meant.html | Jess Szmajda's post formalizing the thinking behind LID, with the production bug that motivates it: code used plain rounding where the design doc specified banker's rounding, and the tests passed because they were written against the code rather than the intent. Read it before Day 3 Lesson 3's LID panel. |
| How to Install BMad | https://docs.bmad-method.org/start/install-bmad/ | The install command and the runtime prerequisites — Node, `uv` — that BMAD now hard-requires. |
| Build your first change (BMAD) | https://docs.bmad-method.org/start/build-your-first-change/ | The minimal path through BMAD for a single change, the fastest way to see what the framework does before comparing it to the other two. |

## Docs

Official Claude Code pages the lessons cite directly.

| Topic | URL | Used in |
| --- | --- | --- |
| Best practices | https://code.claude.com/docs/en/best-practices | Day 2 |
| CLAUDE.md and memory | https://code.claude.com/docs/en/memory | All days |
| Permission modes (plan mode) | https://code.claude.com/docs/en/permission-modes | All days |
| Commands (`/context`, `/clear`, `/compact`) | https://code.claude.com/docs/en/commands | All days |
| Context window | https://code.claude.com/docs/en/context-window | All days |
| Skills | https://code.claude.com/docs/en/skills | Day 2 |
| Subagents | https://code.claude.com/docs/en/subagents | Day 2 |
| Model configuration | https://code.claude.com/docs/en/model-config | Day 2 |
| Checkpointing and `/rewind` | https://code.claude.com/docs/en/checkpointing | Day 2 |
| Scheduled tasks (`/loop`) | https://code.claude.com/docs/en/scheduled-tasks | Day 2 |
| Routines | https://code.claude.com/docs/en/routines | Day 2 |
| Permissions | https://code.claude.com/docs/en/permissions | Day 2, Day 3 |
| Settings and precedence | https://code.claude.com/docs/en/settings | All days |
| Sandboxing | https://code.claude.com/docs/en/sandboxing | Day 2 |
| MCP | https://code.claude.com/docs/en/mcp | Day 2 |
| Changelog | https://code.claude.com/docs/en/changelog | Version notes |

## Repositories

- Fission-AI/OpenSpec — https://github.com/Fission-AI/OpenSpec — the framework's own repository, MIT-licensed, at v1.13.1 as of this course; the canonical source for the explore/propose/apply/archive workflow.
- jszmajda/lid — https://github.com/jszmajda/lid — Linked-Intent Development's home repository, MIT-licensed, including an intent-only example project (`examples/urlshort/`) with no code, meant to be regenerated by an agent.
- bmad-code-org/BMAD-METHOD — https://github.com/bmad-code-org/BMAD-METHOD — BMAD's home repository, at v6.12.0 as of this course; check its changelog before relying on a skill name, since 6.11.0 renamed two of them (Day 3 Lesson 3 names both).

## A note on dates

Links were sourced on 2026-09-22 and checked to resolve at that time. Claude
Code ships frequent point releases and the Day 3 frameworks move too, so treat
every command and flag above as current as of that date, not as fixed — keep
the linked reference open rather than trust a remembered version.
