# Known issues

Bugs this module ships with on purpose. Each one has a test that proves it,
skipped by default so the suite is green, and run on demand:

```bash
LEDGER_RUN_KNOWN_ISSUES=1 swift test
```

Do not fix anything listed here unless an exercise tells you to.

---

## LEDGER-7 — yen amounts render with two decimal places

**Symptom.** A `JPY` transaction of 128,000 yen renders as `-¥1,280.00`. It
should render as `-¥128,000`. The yen has no minor unit: there are no sen on a
statement, so there is no decimal point and no fractional part to print.

**Cause.** `Money.decimalPlaces(for:)` is a table lookup with a two-decimal
default, and the table has no entry for `JPY`. Every yen amount therefore falls
through to two decimal places, and `TransactionFormatter.amountText` divides the
minor-unit amount by 100 before printing it.

**Where it shows.** Only in the rendered string. Nothing stores a wrong number:
`amountMinor` is correct, totals are correct, filtering and day grouping are
correct. It is a presentation bug on one currency.

**The test that proves it.**
`Tests/LedgerKitTests/KnownIssueTests.swift`, the test
`testLEDGER7_JPYRendersWithTwoDecimalPlaces` in `KnownIssueTests`. It reads the one `JPY` row from
the fixture (`LK-014`), renders it, and compares against the fixture's
`expectedAmountText` column. With the environment variable set it fails and
prints both strings.

**Why the suite is still green.** The golden test
(`GoldenFixtureTests.testAmountTextMatchesTheFixture`) skips the amount
assertion for the one `JPY` row and asserts it for every other row, because the
known-issue test owns that case. Everything else about the `JPY` row — its day
bucket, its filter membership — is asserted like any other row.

**When it is fixed.** The known-issue test passes with the variable set, which
means it has stopped being a known issue: move the assertion into
`TransactionFormatterTests`, delete this entry, and let the golden test assert
the `JPY` row like every other row.
