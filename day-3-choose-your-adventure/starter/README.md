# Day 3 starter files

There is no single `cp` line that installs all of this. Each exercise copies the
one file it needs at the moment it needs it, because the day's central claim —
that your framework never saw Change C's acceptance suite while it was planning
or repairing — has to be true. A suite sitting in `day3-work` from the start
would make it false. The late-change tests are the exception: Exercise 3's
setup copies them in before the framework plans, so it can read them, and the
red at step 3, before any code changes, is what proves they bite.

Everything here is copied into `day3-work`, the copy of your lane that
Exercise 1's setup block makes at the course root, or into `../work/` for the
files you fill in. Every copy line runs from inside `day3-work` and reaches this
folder as `../day-3-choose-your-adventure/starter/`. The shipped `sandbox/` is
never edited.

| File | Copied in by | Where it lands |
| --- | --- | --- |
| `change-c-brief.md` | Exercise 1 setup | `day3-work` |
| `map-template.md` | Exercise 1 setup, renamed to `map.md` | `../work/` |
| `fixtures/cycle-config.tsv` | Exercise 2 setup | Swift `Tests/LedgerKitTests/Fixtures/`, Kotlin `src/test/resources/` |
| `acceptance/ChangeCAcceptanceTests.swift` | Exercise 2 step 9 | `Tests/LedgerKitTests/` |
| `acceptance/ChangeCAcceptanceTest.kt` | Exercise 2 step 9 | `src/test/kotlin/` |
| `late-change.md` | Exercise 3 setup | `day3-work` |
| `acceptance/ChangeCLateChangeTests.swift` | Exercise 3 setup | `Tests/LedgerKitTests/` |
| `acceptance/ChangeCLateChangeTest.kt` | Exercise 3 setup | `src/test/kotlin/` |
| `comparison-card.md` | Exercise 3 step 7, never over a card you have started | `../work/` |

Two folders are page material and are never copied into `day3-work`:
`track-notes/`, the per-track command box with a ledger id on every command,
and `answers/`, which holds the OpenSpec reference card as a standalone file.
Exercise 3's page embeds all three reference cards, and where they differ the
page is authoritative. Keeping the reference cards out of `day3-work` is
deliberate: a learner's own track's card is never sitting on disk next to the
card they are filling in.

## The brief and the late change

`change-c-brief.md` is written the way a ticket arrives. It pins the public
surface — the type names, the entry point, and its parameters — so a test file
written against it compiles, and it pins nothing else. There are no acceptance
criteria in it; producing them is the framework's job. It carries two
ambiguities and does not mark them, and the exercise reveal names them
afterwards.

`late-change.md` is three sentences that arrive after the feature has shipped.
It states the new behavior plainly, because it is a requirement rather than a
second ambiguity exercise.

## The acceptance suites

Six tests for Change C in each lane, same names and same assertions on both
sides, plus two more for the late change. Two of the six carry the ambiguities:
`testAuthorizedVsPostedMembership` reads period membership from the posted date,
and `testFebruaryCycleStart` holds a day-31 cycle start inside February. A red
result on either one says which way your framework decided. It is a result, not
a defeat, and the card has a line for it.

The two late-change assertions are red against an implementation that reads one
cycle rule and green once the rule in force on a date decides where the next
period opens. Exercise 3 runs them at step 3, once the framework has updated its
artifacts and before any code changes, and again at step 5: an assertion you
never saw fail has not been proved to bite.

Both suites use only the surface the brief pins. If they do not compile, the
framework named something differently from the brief — fix that through the
framework's own artifact and let it cascade, rather than editing the test file.

## The cycle fixture

`fixtures/cycle-config.tsv` is tab-separated with a header row and three
columns: `name`, `effectiveFrom`, `startDay`. It carries three single-rule
configurations — `standard` starting on the 5th, `month-end` on the 31st, and
`first-of-month` on the 1st. Both lanes read the same bytes, the way
`transactions.tsv` already works.

The Kotlin lane reads it off the test classpath, so it is copied into
`src/test/resources/`, which the lane ships as an empty directory for that
purpose. The Swift lane reads it from a path beside the test file, so it is
copied into `Tests/LedgerKitTests/Fixtures/`.

## The checkpoints and the offline snapshots

`checkpoints/openspec/`, `checkpoints/lid/` and `checkpoints/bmad/` hold the
planning artifacts each framework produced for Change C on the build machine on
2026-09-22 — the mid-point artifact Exercise 2 has you copy in if your planning
phase overruns the 25-minute mark. Each folder carries a `CHECKPOINT.md` saying
what is in it, the copy line for that track, how it was produced, and how it
resolves the brief's two ambiguities. They are copied into the framework's own
folder at that checkpoint and never by the day's setup, so a framework cannot
read its own reference plan while it is planning.

`vendored/openspec-1.13.1/`, `vendored/lid-831c1959/` and
`vendored/bmad-6.12.0/` are the offline snapshots the "network blocked?" box on
each tab points at. Each carries a `SNAPSHOT.md` with the version or commit, the
date, the command that produced it, what a learner does with it, and what it
cannot supply — the BMAD snapshot cannot supply `uv`, which is why Exercise 1
checks for `uv` before it installs anything. They stay outside `day3-work` and
are only copied in on the blocked-network path.

The BMAD snapshot is named for 6.12.0, the version `npx bmad-method install`
gave the build machine on the capture date and the version the pages pin. The
`SNAPSHOT.md` says so.

## The reference cards

The completed comparison cards behind Exercise 3's cross-track reveal, one per
track, are embedded in that page's "Reference answers" section, which is where
a learner reads them. `answers/comparison-card-reference.md` is the OpenSpec
card as a file; there is no separate file for the LID or BMAD card.
