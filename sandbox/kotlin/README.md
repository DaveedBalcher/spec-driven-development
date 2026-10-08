# LedgerKit — Kotlin lane

LedgerKit is a small transactions module: the logic that sits behind a
transaction list on a phone, with the phone part removed. No UI framework, no
third-party dependencies, no locale APIs. It is the sandbox every exercise in
this course runs against.

This is the Kotlin lane. The Swift lane in `../swift` is the same module — same
types, same behaviour (each lane's own tests pin it), same output
strings, same seeded bug.
Pick one lane in Setup and stay in it for three days.

## Running the tests

From this directory:

```bash
./gradlew test
```

The suite ships green: 85 tests, one of them skipped on purpose (see
[Known issue](#known-issue)).

You do not install Gradle. The wrapper is committed, and `./gradlew` fetches the
distribution it needs on the first run — that run needs network access and takes
a couple of minutes; later runs are seconds.

### Toolchain

Any JDK 17 or newer. Check with `java -version`.

`build.gradle.kts` pins the Kotlin JVM target and Java source/target
compatibility to 17 instead of declaring a `jvmToolchain`. That is deliberate:
a toolchain block asks Gradle to find or download a specific JDK, which fails on
a locked-down machine, and the newest JDKs are often ahead of the Kotlin
compiler's highest supported target. Pinning to 17 means the project builds on
whatever recent JDK you already have and downloads no extra one.

## Known issue

`Money.decimalPlaces` is wrong for JPY, so the JPY row renders with two decimal
places it should not have. `KNOWN-ISSUES.md` has the detail. The test that
proves it does not run by default, which is why the suite is green; it runs when
you set one environment variable:

```bash
LEDGER_RUN_KNOWN_ISSUES=1 ./gradlew test
```

With the variable set, exactly one test fails — `KnownIssueTest` — and the
message names the string the fixture expects and the string the code produced.
`build.gradle.kts` forwards the variable into the test JVM. If the test is still
reported as skipped, the variable did not reach the test process.

## The no-locale-APIs rule

Every rendered string in this module is built by hand. No
`java.text.NumberFormat`, no `DateTimeFormatter`, no ICU, no `Locale` lookups,
anywhere in `src/main` or `src/test`.

This is not a style preference. `Fixtures/transactions.tsv` holds one expected
output string per row, and the Swift lane reads the same bytes and must produce
the same strings. A locale-aware API would make the output depend on the machine
the tests ran on, and the fixture's expected column would stop being true. If an
agent reaches for one, that is a bounds violation.

## What is in here

| Path | What it is |
| --- | --- |
| `src/main/kotlin/ledgerkit/Transaction.kt` | The model: `Transaction`, `TransactionStatus`, `Category`. |
| `src/main/kotlin/ledgerkit/Money.kt` | Decimal places and symbol per currency. Holds the seeded bug. |
| `src/main/kotlin/ledgerkit/TransactionFormatter.kt` | `amountText`: sign, symbol, grouped digits. |
| `src/main/kotlin/ledgerkit/LedgerFilter.kt` | `Query` and matching; merchant match ignores case and diacritics. |
| `src/main/kotlin/ledgerkit/LedgerSummary.kt` | `byDay`: day sections with per-day totals. The naive version. |
| `src/test/kotlin/ledgerkit/` | Unit tests per unit, the table-driven golden test, the gated known-issue test. |
| `Fixtures/transactions.tsv` | The lane's copy of the shared fixture, read from the project directory. |
| `specs/TEMPLATE.md` | The spec skeleton the exercises fill in. |
| `CLAUDE.md` | The standing instructions. About 180 lines, and that is a problem you fix on Day 1. |
| `.claude/settings.json` | Two keys that keep a session to this lane: `claudeMdExcludes` skips any `CLAUDE.md` or `CLAUDE.local.md` above your `dayN-work` folder, such as one at the root of the repository you cloned, and `autoMemoryEnabled: false` keeps one day's auto memory out of the next. No permission rules; Day 2 adds those. |

## Copy before you touch it

You never edit `sandbox/kotlin` itself. Each day copies it to a working folder
at the course root and works there. From the course folder:

```bash
cp -R sandbox/kotlin day1-work && cd day1-work
./gradlew test
```

### Measuring and resetting

No git: a copy is measured against the lane it came from. From inside the copy,
`diff -ruN -x build -x .gradle -x .kotlin ../sandbox/kotlin .` shows everything
that changed, and adding `| grep '^diff '` lists the files.

To put the copy back exactly as it shipped, quit Claude Code, then from inside
it:

```bash
cd .. && rm -rf day1-work && cp -R sandbox/kotlin day1-work && cd day1-work
```

Anything you saved outside the copy, such as `work/` at the course root,
survives it.

## What is deliberately not here

- **No exercise configuration in `.claude/`.** It holds one file,
  `settings.json`, which isolates the session and configures nothing an
  exercise teaches. Everything an exercise installs — rules files, skills,
  subagents, permission rules — ships as a plain file under a day's `starter/`
  folder and is copied into place by the step that needs it.
- **No fix for the known issue.** The bug is the point. Leave it until an
  exercise tells you to take it out.
