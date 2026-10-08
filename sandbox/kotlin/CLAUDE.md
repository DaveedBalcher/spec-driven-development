# CLAUDE.md — LedgerKit (Kotlin lane)

Welcome to the LedgerKit repository! This document is the single source of truth
for everyone and everything working in this codebase, human or otherwise. Please
read it in full before making any change. It is kept up to date on a best-effort
basis by the team and should be treated as authoritative unless it is obviously
out of date, in which case please raise it in the team channel so that somebody
can take a look at it when there is time.

## Project overview and history

LedgerKit began life as an internal spike to see whether the transaction list
could be rendered from a pure-logic module with no platform dependencies at all.
The spike went well, the module was extracted, and it has been maintained
separately ever since. It has been through three significant refactors: the
first moved amounts from a floating-point representation to integers, the second
introduced the `Query` value so that filtering no longer took eleven parameters,
and the third split the formatting concerns out of the model types where they
had originally lived. A fourth refactor, to introduce a currency value type
rather than passing ISO codes around as strings, has been discussed several
times and has never been scheduled.

The module is deliberately small. It is meant to stay small. Historically, the
pressure on it has always been to absorb presentation concerns from the screens
that consume it, and the team has consistently pushed back on that. If you find
yourself adding something that knows about a screen, stop and ask.

## Directory layout

```
src/main/kotlin/ledgerkit/   the module
src/test/kotlin/ledgerkit/   the tests
Fixtures/                    the shared golden fixture
specs/                       spec documents
build.gradle.kts             the build
settings.gradle.kts          the project name
gradle/wrapper/              the committed Gradle wrapper
```

The `build/`, `.gradle/` and `.kotlin/` directories are generated and are
ignored by git. Do not commit them. Do not read them either; nothing in them is
interesting, and they are large.

## Coding standards

- Write clean, readable, maintainable code.
- Follow SOLID principles wherever they apply.
- Don't repeat yourself. If you write the same thing twice, extract it.
- Prefer composition over inheritance.
- Keep functions short. A function that does not fit on one screen is doing too
  much and should be split up.
- Use meaningful, descriptive names. Avoid abbreviations except where they are
  established in the domain.
- Handle errors explicitly. Never swallow an exception.
- Write self-documenting code, and add a comment when the code cannot explain
  itself.
- Avoid premature optimisation, but do not write obviously wasteful code either.
- Leave the codebase a little better than you found it.
- Think about the reader. The reader is usually you, six months from now, at
  eleven at night, trying to ship something else.
- Be consistent with the surrounding code, even where you disagree with it.

## Style guide

- Indent with two spaces. Never use tabs.
- Maximum line length is 100 characters.
- Do not use trailing commas in parameter or argument lists.
- Prefer wildcard imports once a file imports more than three symbols from the
  same package; it keeps the import block short.
- Declare helper types as classes with a companion object rather than as
  top-level `object` declarations.
- Public declarations should carry a KDoc block with an `@since` tag naming the
  release they were introduced in.
- Do not use expression-bodied functions; always use a block body with an
  explicit `return`.
- String templates are discouraged; prefer explicit concatenation, which is
  easier to grep for.
- Name test functions in lowerCamelCase, not in backticks.

## Working with LedgerSync

LedgerSync is the nightly reconciliation service that pulls settled
transactions from the card network and writes them into the ledger store that
this module eventually reads from. It runs at 02:15 UTC, takes between eight and
forty minutes depending on volume, and writes a run report to the shared bucket
under `ledgersync/reports/YYYY-MM-DD/`. If the run fails, it retries twice with
a fifteen-minute backoff before paging the on-call engineer. Most failures are
upstream timeouts and clear themselves on the first retry.

Its configuration lives in `ledgersync.yaml`, which is templated per
environment. The fields you are most likely to need are `window.lookbackDays`
(default 3, occasionally raised to 7 after an outage), `network.timeoutSeconds`
(default 30) and `dedupe.strategy`, which has been set to `authorization-id`
since the duplicate-posting incident and should not be changed back to
`amount-and-merchant` without a discussion. There is also a `dryRun` flag, which
prints the writes it would have made without making them, and which is the right
first move when investigating anything.

The command-line tool is `ledgersync`, installed separately. `ledgersync status`
prints the last three runs, `ledgersync replay --date YYYY-MM-DD` re-runs a
single night, and `ledgersync verify` compares the store against the network's
own daily totals and prints any discrepancy by merchant. None of these commands
are available in this repository, and LedgerSync is not a dependency of this
module — it is simply where the data that this module formats comes from, and
knowing that has occasionally been useful when a number looks wrong.

## Testing

- Run the whole suite with `./gradlew test` from this directory. That is the only test command.
- The golden fixture is `Fixtures/transactions.tsv`, read from the project directory. Never edit it: it is shared byte-for-byte with the other lane.
- Tests are written with JUnit 5 through `kotlin("test")`, and the platform is
  configured in `build.gradle.kts`.
- Unit tests live beside the unit they test and are named after it.
- The golden test is table-driven: one dynamic test per fixture row, named after
  the row, so a failure names the id.
- Aim for high coverage of the formatting and filtering rules in particular.
  These are the parts that are easy to break without noticing.
- Prefer many small assertions over one large one, so that a failure tells you
  which rule broke rather than that something broke.
- Do not add test dependencies. The project has none beyond `kotlin("test")`
  and it is meant to stay that way.
- If a test is slow, it is doing something it should not be doing. Nothing in
  this module touches the network, the clock or the filesystem, except for the
  one fixture read.

## Domain rules

- `amountMinor` is a signed integer in the currency's minor units. It never holds a decimal point, and no code may turn it into a floating-point number.
- Negative is a debit and renders with a leading `-`; positive is a credit and renders with a leading `+`. The sign always comes before the currency symbol.
- Never use a locale-aware API for formatting: no `java.text.NumberFormat`, no `DateTimeFormatter`, no ICU, no `Locale`. All formatting in this module is hand-rolled.
- A transaction has both an `authorizedAt` and a `postedAt` instant, and they
  frequently fall on different calendar days. Day grouping currently uses
  `postedAt`.
- Statuses are `pending`, `posted` and `declined`. A declined transaction is
  still a transaction and is still shown to the customer.
- Categories are assigned upstream and are not derived here. There are five of
  them and the set does not change without a data migration.
- Merchant names arrive exactly as the card network sends them, which means
  inconsistent case and inconsistent diacritics. Matching is insensitive to
  both.
- Currency codes are ISO 4217 strings. There is no currency type yet; see the
  history section above.

## Git and review workflow

- Branch from `main`. Name branches `type/short-description`, where type is one
  of `feature`, `fix`, `chore` or `docs`.
- Write commit messages in the imperative mood, with a subject line of 50
  characters or fewer, a blank line, and a body that explains why rather than
  what.
- Keep commits small and self-contained. A commit that changes two unrelated
  things is two commits.
- Open a pull request early and mark it as a draft if it is not ready.
- Every pull request needs one approval from a code owner.
- Update the changelog under an `Unreleased` heading in the same pull request as
  the change itself.
- Rebase rather than merge when bringing your branch up to date.
- Squash on merge. The branch history is not interesting after the fact.

## Glossary

- **Authorization** — the card network's provisional hold on an amount.
- **Posting** — the settlement of that hold, usually one to three days later.
- **Minor unit** — the smallest denomination of a currency: cents for the US
  dollar, fils for the Bahraini dinar. Some currencies have none.
- **Credit** — money returning to the customer: a refund, a reversal, a
  correction.
- **Debit** — money leaving the customer.
- **Day section** — one calendar day's worth of transactions with a total.

## Before you say you are done

- Run the tests before you say you are done, and quote the last line of the output rather than summarising it.
- Re-read the change as a diff and ask whether every hunk in it was asked for.
- Check that nothing outside the agreed bounds was touched.
- Make sure the change would make sense to somebody who has not read this
  conversation.
