# reference/after-e1

A finished Exercise 1 result, for the learner who ran out of time. Copying it in
gives Exercise 2 the same starting point everybody else has: a Change B
implementation that a runner produced, a suite that is green, and a run log that
says how it got there.

It is not a reference implementation. It is wrong in six places, and finding
them is Exercise 2.

## Copying it in

This is Exercise 2's catch-up block. If your Exercise 1 run did not finish,
paste your lane's line from inside `day2-work`, after Exercise 2's setup block,
which leaves you there. It uses no git.

Swift lane:

```bash
cp -R ../day-2-loops-and-your-environment/starter/reference/after-e1/swift/. . && cp ../day-2-loops-and-your-environment/starter/reference/after-e1/run-log.md . && ls Sources/LedgerKit/LedgerSummary.swift
```

Kotlin lane:

```bash
cp -R ../day-2-loops-and-your-environment/starter/reference/after-e1/kotlin/. . && cp ../day-2-loops-and-your-environment/starter/reference/after-e1/run-log.md . && ls src/main/kotlin/ledgerkit/LedgerSummary.kt
```

## Checking it landed

From inside `day2-work`. Swift lane: `swift test` prints
`Executed 32 tests, with 1 test skipped and 0 failures (0 unexpected) in … (…) seconds`.
Kotlin lane: `./gradlew test` prints `BUILD SUCCESSFUL in …`.

Green, and still wrong. That is the whole lesson.

## What is in it

| Path | What it is |
| --- | --- |
| `run-log.md` | Four iterations and one gate, in the format `run-log.template.md` describes |
| `swift/Sources/LedgerKit/LedgerSummary.swift` | The implementation the run produced |
| `swift/Tests/LedgerKitTests/LedgerSummaryTests.swift` | The tests the run rewrote, all passing |
| `kotlin/src/main/kotlin/ledgerkit/LedgerSummary.kt` | Same, Kotlin lane |
| `kotlin/src/test/kotlin/ledgerkit/LedgerSummaryTest.kt` | Same, Kotlin lane |
