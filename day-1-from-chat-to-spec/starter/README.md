# Day 1 starter files

Everything Day 1's exercises copy, plus the answer keys they reveal. Nothing
here is a working Claude Code configuration: there is no `.claude/` directory,
and the one rules file ships as a plain document that Exercise 4 copies into
place. That is deliberate — a live configuration in the repository would be
loaded by any session started here, including the one you are about to compare
against.

Every path below is written from the **course root**. The exercises run from
inside `day1-work`, the copy of your lane that Exercise 1's setup block makes,
so a setup line reads `cp day-1-from-chat-to-spec/starter/<file> day1-work/` and
ends by putting you back in the copy.

## What copies where

| File | Copied by | To |
| --- | --- | --- |
| `tickets/LEDGER-7.md` | Exercise 2 setup | `day1-work/LEDGER-7.md` |
| `plan-checklist.md` | Exercise 2 setup | `work/plan.md` |
| `change-b-brief.md` | nothing — Exercise 3 step 1 reads it in place | — |
| `specs/TEMPLATE.md` | Exercise 3 setup | `day1-work/specs/daily-summary.md` |
| `rules/EXAMPLE-formatting.md` | Exercise 4 setup, then step 4 | `work/`, then `day1-work/.claude/rules/formatting.md` |
| `prompts/*.txt` | nothing — read or paste as you like | — |

Two directories, and the difference matters all day. `day1-work` is the code you
edit and reset. `work` is where your answers go, and no reset on any Day 1 page
deletes it.

## The files

**`tickets/LEDGER-7.md`** — the bug ticket for Exercise 2, written the way a
ticket actually arrives: a symptom, a screenshot description, no acceptance
criteria. It carries two extra complaints that are not part of the fix; the
wrap-up challenges pick one of them up.

**`plan-checklist.md`** — your working file for Exercise 2. Six questions to ask
of a proposed plan, and headings for the before line, the rejections, the
approved plan and the after line. Fill it in as you go.

**`change-b-brief.md`** — the pending-aware daily summary, in product's words.
No criteria, no file names, and two open questions it does not answer. Exercise 3
turns it into a spec.

**`specs/TEMPLATE.md`** — the same spec skeleton both sandbox lanes ship, with
both lanes' commands in it. Delete the lane that is not yours after you copy it.

**`spec-template.md`** — the template again, annotated section by section: what
each one is for, what a filled version looks like, and the specific way each one
gets filled badly. Read it before Exercise 3.

**`prompts/`** — every prompt Day 1 asks you to type, one file per prompt, so
you can paste from a file rather than from the page. `e1-prompt-b.txt` is the
Swift lane's wording; `e1-prompt-b-kotlin.txt` is the same prompt with the
Kotlin paths. The other four prompts are identical in both lanes.

**`rules/EXAMPLE-formatting.md`** — a path-scoped rules file: YAML frontmatter
with a `paths:` glob, then one line of body. A rules file loads only when the
agent reads a file the glob matches, which is why Exercise 4 uses one for the
lines that are worth having sometimes and not worth paying for every turn. The
glob shipped here is the Swift lane's; the Kotlin lane's is
`paths: ["src/main/kotlin/ledgerkit/*.kt"]`. <!-- Sources: cc-core-15 -->

**`answers/`** — the reveals. Open them when the exercise says to, not before.
The revealed answer to Exercise 2 stops at the minor-unit table: the fix itself
is not in this repository, because typing it is the exercise.

## Resetting

Quit Claude Code, then from inside `day1-work`:

**Swift lane**

```bash
cd .. && rm -rf day1-work && cp -R sandbox/swift day1-work && cd day1-work
```

**Kotlin lane**

```bash
cd .. && rm -rf day1-work && cp -R sandbox/kotlin day1-work && cd day1-work
```

That replaces the copy with a fresh one from the shipped lane, so everything an
agent created goes with it, including the ticket and the spec you copied in. It
does not touch `work`. When Day 1 is finished, delete the copy from the course
root with `rm -rf day1-work`. Keep `work`: Day 2 and Day 3 write there too, and
the Day 3 wrap-up removes it when you are done for good.
