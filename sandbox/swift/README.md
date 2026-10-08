# LedgerKit — Swift lane

A small transactions module: the logic that would sit behind a transaction list
on a phone, with the phone part removed. No UI framework, no third-party
dependencies, no locale APIs. It builds and tests in seconds on any machine with
a Swift toolchain, and it ships with one deliberate bug for you to find.

This is the Swift lane of the course sandbox. The Kotlin lane in
`sandbox/kotlin/` is the same module: same types, same behaviour (each lane's own
tests pin it), same output strings, same bug.

## What is in it

| File | What it holds |
| --- | --- |
| `Sources/LedgerKit/Transaction.swift` | The `Transaction` model, its `status` and `category` enums, and UTC date arithmetic. |
| `Sources/LedgerKit/Money.swift` | Per-currency facts: symbol and decimal places. Holds LEDGER-7. |
| `Sources/LedgerKit/TransactionFormatter.swift` | `amountText` — a signed minor-unit amount rendered as text. |
| `Sources/LedgerKit/LedgerFilter.swift` | A `Query` value and the matching, including case- and diacritic-insensitive merchant search. |
| `Sources/LedgerKit/LedgerSummary.swift` | `byDay` — day sections with per-day totals. The naive version. |
| `Tests/LedgerKitTests/Fixtures/transactions.tsv` | The shared fixture: 20 rows, with the expected rendered amount and expected day bucket in the last two columns. |
| `.claude/settings.json` | Two keys that keep a session to this lane: `claudeMdExcludes` skips any `CLAUDE.md` or `CLAUDE.local.md` above your `dayN-work` folder, such as one at the root of the repository you cloned, and `autoMemoryEnabled: false` keeps one day's auto memory out of the next. No permission rules; Day 2 adds those. |

## Running the tests

From this directory:

```bash
swift test
```

It ships green. From anywhere else, name the package:

```bash
swift test --package-path sandbox/swift
```

A healthy run reports this under `Test Suite 'All tests'`:

```
Test Suite 'All tests' passed at ...
	 Executed 34 tests, with 1 test skipped and 0 failures (0 unexpected) in ...
```

The skipped test is the known issue. See below.

### The known issue

`KNOWN-ISSUES.md` describes LEDGER-7. The test that proves it lives in
`Tests/LedgerKitTests/KnownIssueTests.swift` and is skipped by default, so the
suite stays green. Set one environment variable to run it:

```bash
LEDGER_RUN_KNOWN_ISSUES=1 swift test
```

Exactly one test then fails — the `JPY` row — and the failure message names the
string that was expected and the string the code produced.

## The rule this module rests on

**Formatting is hand-rolled. No `NumberFormatter`, no `Locale`, no ICU, no
locale lookups anywhere.**

The fixture file holds the expected output strings for *both* lanes of this
sandbox. A locale API would make the output depend on the machine that ran it,
and those expected strings would stop being true. If a change reaches for one,
that is a bounds violation, not a style preference — the golden test will catch
it, and so should a review.

Date parsing is hand-rolled for the same reason: `ISO8601.instant(from:)` reads
the one shape the fixture uses, and `UTCDay` derives a calendar date by
arithmetic on seconds since the epoch rather than through `Calendar`, so the
answer never depends on the machine's time zone.

## Working on a copy, and resetting it

You never edit `sandbox/swift` itself. Each day copies it to a working folder at
the course root and works there:

```bash
cp -R sandbox/swift day1-work && cd day1-work
swift test
```

No git: a copy is measured against the lane it came from. From inside the copy,
`diff -ruN -x .build ../sandbox/swift .` shows everything that changed, and
adding `| grep '^diff '` lists the files.

To put the copy back exactly as it shipped, quit Claude Code, then from inside
it:

```bash
cd .. && rm -rf day1-work && cp -R sandbox/swift day1-work && cd day1-work
```

Anything you saved outside the copy, such as `work/` at the course root,
survives it.

## Toolchain

Swift 6.2, from Xcode 26 or a standalone toolchain. Check with `swift --version`.
The package declares `swift-tools-version:5.9`, so older toolchains work too.
