# LedgerKit — project instructions

This file is loaded on every turn of every session started in this directory.
It has grown the way these files grow: someone added a line after a bad review,
someone else pasted in a section from another repo, and nobody ever took
anything out. Read it with that in mind.

## About this project

LedgerKit is the transactions module. It models a transaction, formats an
amount, filters a list and groups a list by day. It has no user interface, no
network layer, no persistence and no dependencies. It is a library and it is
meant to stay one.

The module is small on purpose. If a change makes it feel large, the change is
probably in the wrong place.

## Glossary

- **Transaction** — one line on a statement.
- **Posted** — the transaction has settled against the account.
- **Pending** — authorized, not yet settled; the amount may still change.
- **Declined** — the authorization was refused; no money moved.
- **Authorization** — the merchant's request to hold funds.
- **Settlement** — the movement of funds that follows an authorization.
- **Minor unit** — the smallest denomination of a currency.
- **Major unit** — what a person calls the currency: dollars, euros, pounds.
- **Debit** — money leaving the account.
- **Credit** — money returning to the account.
- **Merchant descriptor** — the merchant name as the card network sends it.
- **MCC** — merchant category code, a four-digit classification.
- **Interchange** — the fee paid between issuer and acquirer.
- **Chargeback** — a disputed transaction reversed by the issuer.
- **Statement period** — the window a statement covers.
- **Cycle day** — the day of the month a statement period begins.
- **Ledger** — the ordered record of transactions on an account.
- **Reconciliation** — checking a ledger against an external record.
- **Descriptor override** — a manual correction to a merchant name.
- **Posting date** — the calendar date a transaction settled on.
- **Authorization hold** — funds reserved while a charge is pending.

## Engineering principles

1. Simple is better than clever.
2. Make it work, make it right, make it fast, in that order.
3. Code is read far more often than it is written.
4. Explicit is better than implicit.
5. A function should do one thing.
6. Prefer composition over inheritance.
7. Don't repeat yourself.
8. You aren't gonna need it.
9. Leave the campsite cleaner than you found it.
10. The best code is the code you didn't have to write.
11. Premature optimization is the root of all evil.
12. If it isn't tested, it's broken.

## Working agreements

Write descriptive commit messages in the imperative mood. Keep pull requests
small. Ask for review from at least one other engineer. Update documentation in
the same change as the code it describes. Prefer small, frequent merges over
long-lived branches. Do not merge on a Friday afternoon.

Be careful. Think about edge cases. Consider performance implications. Handle
errors gracefully. Write code that is easy to delete. Name things well. Avoid
magic numbers. Keep functions short. Keep files short. Keep classes focused.

## Style

Types are prefixed `LK` (`LKTransaction`, `LKMoney`), one public type per file,
and the file is named after the type it holds. Do not use an `enum` as a
namespace for static methods; use a `struct` with a private initializer, or
free functions in a file named for the area. Indent with tabs, width 4. Wrap at
80 columns. Put the opening brace on its own line. Mark every type `final`
unless it is designed for subclassing. Prefer classes to structs for anything
with more than three stored properties.

`swift-format` enforces the wrapping, the brace placement and the indentation,
so do not spend review comments on them.

Use `// MARK: -` to divide a file into sections. Put extensions at the bottom of
the file. Order members: stored properties, initializers, public methods,
private methods. Alphabetize import statements.

## Testing

Run the tests with `swift test` from the package root.

Every new behaviour gets a test. Every bug fix gets a test that fails before the
fix and passes after it. Prefer one assertion per test. Name tests for the
behaviour, not the method. Do not test private methods directly. Do not mock
what you do not own. Keep tests fast; a test that takes longer than a second is
doing something it should not.

Run the tests before you say you are done, and quote the final summary line.

## Money

amountMinor is an integer in the currency's minor units; a decimal point never appears in stored data.

Negative amountMinor is a debit and prints with `-`; zero or positive is a credit and prints with `+`.

Never use NumberFormatter, Locale, ICU or any locale API: all formatting is hand-rolled.

Currency codes are ISO 4217 and uppercase. Amounts are never floating point.
Rounding is not a concern in this module because nothing here divides.

## Fixtures

The fixture at Tests/LedgerKitTests/Fixtures/transactions.tsv is the source of truth for expected strings.

The file is tab-separated and UTF-8. Fields are never quoted. Rows are stable:
a transaction id, once shipped, never changes, because test failures name it.

## The ledger-sync tool

`ledger-sync` is the ingestion command that pulls raw authorization and
settlement records from the card network feed and normalizes them into the row
shape this module consumes. It runs on a schedule, writes into the staging
table, and emits one summary line per run. If you are debugging a transaction
that looks wrong, start there rather than here: the great majority of "the
amount is wrong" reports turn out to be an ingestion problem, not a formatting
problem.

The tool takes a `--since` argument in ISO-8601 and a `--dry-run` flag that
prints the rows it would write without writing them. Its configuration lives in
the platform repository under `config/ledger-sync/`, with one file per
environment. Changing a mapping there requires a review from the payments
platform team, because the same mapping feeds the reconciliation job and a
mistake is visible to finance the next morning.

`ledger-sync` also owns the merchant descriptor cleanup: stripping store
numbers, collapsing whitespace, and applying the descriptor override table. If
a merchant name arrives here in an odd shape, that is where the shape was
decided. Do not add cleanup logic to this module to compensate; file it against
the tool instead, or the two cleanups will disagree and the disagreement will be
invisible until a filter stops finding something.

## History

- 2024-11 — module extracted from the app target as `LedgerCore`.
- 2025-01 — renamed to `LedgerKit` after the platform naming review.
- 2025-02 — `Money` split out of `TransactionFormatter`.
- 2025-04 — filtering moved from the view model into `LedgerFilter`.
- 2025-06 — day grouping added for the grouped-list redesign.
- 2025-07 — third-party currency dependency removed; formatting hand-rolled.
- 2025-09 — fixture consolidated into a single tab-separated file.
- 2025-11 — `authorizedAt` added alongside `postedAt`.
- 2026-01 — test target split into one file per unit.
- 2026-02 — known-issue gating added so the suite can ship green.

## Code review

Look at the diff before the description. Check the test that would have failed
without the change. Ask whether the change belongs in this module at all.
Approve on evidence, not on effort.

## Performance notes

The module is not performance sensitive. A statement page holds at most a few
hundred transactions and everything here is linear. Do not add caching, do not
add laziness, and do not reach for a data structure more complicated than an
array and a dictionary. If a profile ever says otherwise, bring the profile.

## Accessibility

There is no user interface in this module, so there is nothing here to make
accessible. Rendered strings are read aloud by the app layer; keep them plain
and avoid characters a screen reader will not announce sensibly.

## Security

There are no credentials, no network calls and no personal data in this module
beyond a merchant name. Do not add any. Do not log transaction amounts.

## When you are unsure

Ask. A question costs a minute; a wrong assumption baked into a diff costs an
afternoon. If the answer is not in this file and not in the code, say what you
would assume and why, and let a human confirm it before you build on it.
