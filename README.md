# 3 Days of Spec-Driven Development

Three self-paced days, three hours each, for iOS and Android engineers who use
AI chat every day and want the agentic workflow that comes next: specs an agent
can execute, plan mode, a runner that loops until a gate, a critic that audits
the result, and a spec framework the whole team can share. The tool is Claude
Code in the terminal, used concretely (`CLAUDE.md`, plan mode, permissions,
subagents, skills, MCP). The sandbox is a small transactions module with the
same spec in Swift and Kotlin; you pick a lane.

The format borrows from Paul Hudson's 100 Days of Swift: each day opens with a
short video, then five or six short lessons (each with a video segment, about
six minutes of reading, and a two-question quick check), three or four hands-on
exercises that check themselves, and a wrap-up with a recap, review questions,
and exactly three challenges with no solutions. Each day stands alone.

## Who it is for

Mobile engineers on a feature team at a large, regulated company. You already
use AI daily, as chat or one-shot code generation. You have not yet run an
agent against a repo with a plan, a spec, a subagent, or a loop. This is not a
prompting-tips course and not a tour of every Claude Code feature.

## The three days

| Day | Theme | You build |
| --- | --- | --- |
| [Setup](setup.html) | Twenty minutes before Day 1: confirm Claude Code runs, pick a lane, copy the sandbox, run the tests once. | A green test run in your lane. |
| [1. From chat to spec](day-1-from-chat-to-spec/index.html) | What an agent has that chat does not, prompting in four parts, and plan mode. Then the prompt becomes a spec: acceptance criteria that can fail, and context as a budget. | Two diffs from the same task under two prompts; a plan you rejected once and then ran to green on the seeded bug; a spec with four criteria the tests can fail; a `CLAUDE.md` cut from 180 lines to under 40 with the before-and-after context numbers. |
| [2. Loops and your environment](day-2-loops-and-your-environment/index.html) | Where drift gets in. A runner with stop conditions and gates. Self-critique with a fresh-context subagent. Your locked-down environment as part of the spec: permissions, read paths, write paths. | A runner skill run to green with a gate you answered; an auditor run scored against six reference drift findings and a net-zero `CLAUDE.md` revision; an environment profile and a permissions file you predicted before observing; a vetted write script extended with one guardrail and its test. |
| [3. Choose your adventure](day-3-choose-your-adventure/index.html) | Why a framework at all. What OpenSpec, LID, and BMAD share and where they differ. One track, run against one feature brief with two deliberate ambiguities. How to choose, and how to adopt without a rewrite. | One framework installed and mapped; the statement-periods feature run through it and graded by the shared acceptance suite; a late change and an eight-question comparison card for your team. |

## Prerequisites

- Claude Code 2.1.x installed and signed in. Mechanical claims were checked
  against the official docs on 2026-09-22 at v2.1.280.
- Swift lane: Swift 6.2 (Xcode 26 or the Swift toolchain). Kotlin lane: a JDK
  17 or later; the Gradle wrapper is included.
- `python3` (Day 2 Exercise 3 runs `python3 -m json.tool`; it also serves the
  site locally).
- Day 3, by track: OpenSpec needs Node 20.19.0 or later and `npm`; BMAD needs
  Node 20.12 or later and `uv` with Python 3.11 or later; LID needs the Claude
  Code plugin marketplace. A "network blocked?" box on each track points at a
  vendored snapshot.

## How to use it

1. Open the site. Three ways, same files: the hosted page, or from this
   folder (the one holding this README) `python3 -m http.server 8000` and open
   `http://localhost:8000/`, or open this folder's `index.html` in a browser
   (progress ticks do not persist over `file://` in Safari).
2. Do [Setup](setup.html) before Day 1.
3. Each day: watch the opener, read the lessons in order, do each exercise
   right after its lesson, then the wrap-up. Each day works in one copy of the
   sandbox at the course root (`day1-work`, `day2-work`, `day3-work`), made by
   its first exercise; later exercises continue in it.
4. Three hours per day. Days can be spread over weeks; each stands alone.

## Course layout

```
README.md                              this file, the syllabus
index.html, setup.html                 the site's front door and the Day 0 setup
assets/                                one stylesheet, one script, one per-team env profile
day-1-from-chat-to-spec/               index, lessons/, exercises/, wrap-up, starter/
day-2-loops-and-your-environment/      same shape
day-3-choose-your-adventure/           same shape, with one tab per framework
sandbox/                               LedgerKit in swift/ and kotlin/, shared fixtures/
resources/videos.md                    every video with its date and channel
resources/reading.md                   articles, docs, and repositories
```

The authoring repository also holds `INTENT.md` (the brief: audience, scope,
style, success criteria) and `build/` (authoring tooling and checks). Neither
is course material, and a published copy of the course leaves them out.

## A note on accuracy

Every mechanical claim about Claude Code carries a citation to the official
documentation as read on 2026-09-22 (Claude Code v2.1.280). Framework
commands were checked against OpenSpec 1.13.1, the LID repository, and BMAD
6.12.0 on the same date. The docs and the frameworks move; where a lesson
describes a command or a flag, keep the linked reference open. Every video
link was verified when the course was built and is re-checked by
`build/checks/check-videos.sh`.
