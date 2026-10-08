# LedgerKit: the course sandbox

LedgerKit is a small transactions module — the kind of thing that sits behind a
transaction list on a phone, with the phone part removed. It has no UI
framework, no third-party dependencies and no locale APIs, so its tests run
headless on any machine in seconds and every exercise in this course has
something real to fail against.

It ships twice, from one spec:

| Lane | Directory | Toolchain |
| --- | --- | --- |
| Swift | `sandbox/swift/` | Swift Package Manager, XCTest |
| Kotlin | `sandbox/kotlin/` | Gradle (wrapper committed), JUnit 5 |

The two lanes are the same module: same types, same behaviour (each lane's own tests pin it), same output strings, same seeded bug. Pick one in Setup and stay in it for three
days. Nothing in the course works better in one lane than the other.

## What is in a lane

- `Money` and `TransactionFormatter` — `amountText` renders a signed
  minor-unit amount as text.
- `LedgerFilter` — a `Query` value (status set, category set, date range,
  merchant substring); merchant matching is case- and diacritic-insensitive.
- `LedgerSummary` — `byDay` groups transactions into day sections with per-day
  totals. This is the naive version; Day 1 specifies its replacement and Day 2
  runs it.
- `Fixtures/` (Swift: `Tests/LedgerKitTests/Fixtures/`; Kotlin:
  `Fixtures/`) — the lane's copy of the shared fixture.
- `README.md`, `KNOWN-ISSUES.md`, `specs/TEMPLATE.md`, and a `CLAUDE.md` that is
  about 180 lines long on purpose.
- `.claude/settings.json`, with two keys that keep a session to the lane.
  `claudeMdExcludes` skips any `CLAUDE.md` or `CLAUDE.local.md` above your
  `dayN-work` folder, such as one at the root of the repository you cloned, and
  `autoMemoryEnabled: false` keeps one day's auto memory out of the next, since
  Claude Code keeps auto memory per git repository and a reset does not clear
  it.

## One fixture, both lanes

`fixtures/transactions.tsv` is the single source of the sample ledger: 20 rows
with the expected rendered amount and the expected day bucket in the last two
columns. It is copied verbatim into each lane's fixture folder, and each lane's
table-driven golden test walks it row by row, asserting the rendered amount,
filter membership and the day bucket.

That only works because **formatting is hand-rolled**. No `NumberFormatter`, no
`java.text.NumberFormat`, no ICU, no locale lookups anywhere in either lane. A
locale API would make the output depend on the machine it ran on, and the
fixture's expected strings would stop being true. If an agent reaches for one,
that is a bounds violation, not a style preference. `fixtures/README.md`
describes every column.

## Running the tests

Run from inside your lane directory, or from inside the working copy you made of
it.

**Swift lane**

```bash
swift test
```

**Kotlin lane**

```bash
./gradlew test
```

Both suites ship green.

### The known issue

`KNOWN-ISSUES.md` in each lane describes LEDGER-7: `Money.decimalPlaces`
returns 2 for every currency, so `JPY` renders with two decimal places it should
not have. The test that proves it is skipped by default, so the suite stays
green, and it runs when you set one environment variable:

```bash
LEDGER_RUN_KNOWN_ISSUES=1 swift test      # Swift lane
LEDGER_RUN_KNOWN_ISSUES=1 ./gradlew test  # Kotlin lane
```

With the variable set, exactly one test fails — the `JPY` row — and the failure
message names the expected string and the string the code actually produced. In
the Swift lane the case is an `XCTSkip` inside `KnownIssueTests`; in the Kotlin
lane it is `KnownIssueTest`, gated with
`@EnabledIfEnvironmentVariable(named = "LEDGER_RUN_KNOWN_ISSUES", matches = "1")`,
and `build.gradle.kts` forwards the variable into the test JVM. If the gated
test is still reported as skipped, the variable did not reach the test process.

## Copy a lane before you touch it

You never edit `sandbox/` itself. Every exercise starts from a fresh copy, which
is what makes an exercise repeatable and a mistake cheap. Give the copy a git
baseline of its own so every diff you measure is against a known-clean tree.

The day pages each give you their own copy-paste block: Day 1 works in
`day1-work/`, Day 2 in `day2-work/`, Day 3 in `day3-work/`, all at the course
root and all excluded by `.gitignore`. Setup's one-time test run uses a
throwaway `setup-work/` in the same place. The shape is always this, from the
course folder:

**Swift lane**

```bash
cp -R sandbox/swift day1-work && cd day1-work
swift test
```

**Kotlin lane**

```bash
cp -R sandbox/kotlin day1-work && cd day1-work
./gradlew test
```

### Measuring and resetting

No git: a copy is measured against the lane it came from. From inside the copy,
`diff -ruN -x .build ../sandbox/swift .` (Kotlin: `diff -ruN -x build -x .gradle
-x .kotlin ../sandbox/kotlin .`) shows everything that changed, and adding
`| grep '^diff '` lists the files.

To put the copy back exactly as it shipped, quit Claude Code, then from inside
the copy (Kotlin lane: `sandbox/kotlin`; use the day's folder name):

```bash
cd .. && rm -rf day1-work && cp -R sandbox/swift day1-work && cd day1-work
```

Your answers in `work/` at the course root are outside the copy and survive
it.

## Toolchain notes

**Swift lane.** Swift 6.2, from Xcode 26 or a standalone toolchain. Check with
`swift --version`.

**Kotlin lane.** A JDK 17 or later — check with `java -version`. You do not
install Gradle: the wrapper is committed, and `./gradlew` fetches the
distribution it needs. That first run downloads the Gradle distribution and the
test libraries, so it needs network access and takes a few minutes; later runs
are seconds. A failure like `Could not resolve all files`, or a timeout against
a distribution URL, is the network and not your code — run it once where
downloads are allowed, or ask your platform team which internal mirror to point
it at. A run that fails on an unsupported class file version means the JDK on
your `PATH` is older than 17; point `JAVA_HOME` at a newer one.

## What is deliberately not here

- **No exercise configuration in `.claude/`.** It holds one file,
  `settings.json`, which isolates the session and configures nothing an
  exercise teaches. Everything an exercise installs — rules files, skills,
  subagents, permission rules — ships as a plain file under a day's `starter/`
  folder and is copied into place by the step that needs it, so the
  sandbox you copy is never already configured.
- **No locale APIs, no dependencies, no UI.** See above; this is the constraint
  the whole fixture rests on.
- **No fix for LEDGER-7.** The bug is the point. Leave it there until an
  exercise tells you to take it out.
