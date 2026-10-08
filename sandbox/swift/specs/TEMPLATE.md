# Spec: <change name>

> Copy this file, fill every section, delete the guidance in angle brackets.
> A section you cannot fill is a decision you have not made yet — make it here,
> where it costs a sentence, rather than in a review, where it costs a rewrite.

## Goal

<One or two sentences, in behaviour terms: what will be true after this change
that is not true now. Name the observable thing, not the code you imagine
writing. "Day sections show a pending total alongside the posted total" is a
goal. "Refactor LedgerSummary" is not.>

## Non-goals

<Two or more bullets. At least one should name the thing sitting right next to
this change that you are deliberately not touching — that is the one an agent
will wander into.>

- <not this>
- <and not this either>

## Acceptance criteria

<Numbered. Each one is a single statement that a command can fail. If you cannot
say which assertion goes red when it is broken, it is not a criterion yet: it is
a hope. Rewrite it until it is checkable.>

1. <criterion>
2. <criterion>
3. <criterion>
4. <criterion>

### Criterion-to-command grid

<One row per criterion. If a row has no command, that criterion is not
falsifiable and must be rewritten before this spec is worth handing to anyone.>

| # | Command that fails if this is broken | Test or assertion |
| --- | --- | --- |
| 1 | `swift test` | `<TestClass>.<testName>` |
| 2 | `swift test` | `<TestClass>.<testName>` |
| 3 | `swift test` | `<TestClass>.<testName>` |
| 4 | `swift test` | `<TestClass>.<testName>` |

## Bounds

<Paths, not prose. "Be careful around Money" is not a bound.>

**In bounds — may change:**

- `Sources/LedgerKit/<file>.swift`
- `Tests/LedgerKitTests/<file>Tests.swift`

**Out of bounds — must not change:**

- `Tests/LedgerKitTests/Fixtures/transactions.tsv`
- `CLAUDE.md`
- <the neighbouring source files this change must not reach into>

## Verification

<The exact commands, in the order they are run, with what counts as success.
"Run the tests" is not verification; the command and its output line are.>

```bash
swift test
```

Success is `Executed <n> tests, with 0 failures`.

<If the change touches a known issue, say how the gated test gets run:>

```bash
LEDGER_RUN_KNOWN_ISSUES=1 swift test
```

## Stop conditions

<What ends the run without a finished change. An agent that has no way to stop
will keep going until something is green, which is not the same as correct.>

- A change is needed in a file listed as out of bounds: stop, name the file and
  the reason, change nothing.
- The same test fails twice in the same way: stop and show the failure.
- <the condition specific to this change>

## Definition of done

- [ ] Every numbered criterion has a test that fails without the change.
- [ ] `swift test` is green.
- [ ] The diff against the shipped lane names only files listed as in bounds.
- [ ] No locale or number-formatting API was introduced anywhere.
- [ ] The fixture file is unchanged.
