# Known issues

One entry. It is here on purpose, it is not a mistake in the sandbox, and the
suite is green in spite of it.

## LEDGER-7 — JPY amounts render with two decimal places

**Symptom.** `TransactionFormatter.amountText` prints `-¥1,280.00` for a
transaction of −128,000 minor units in JPY. The correct rendering is
`-¥128,000`: the yen has no minor unit, so a JPY amount has no decimal point and
no decimal digits at all, and the minor-unit figure *is* the number of yen.

**Cause.** `Money.decimalPlaces` in `src/main/kotlin/ledgerkit/Money.kt` has no
entry for the zero-decimal currencies. JPY falls through to the two-place
default, the formatter splits the last two digits off into a fraction, and the
grouping commas then land in the wrong place as well.

**The test that proves it.** `KnownIssueTest` in
`src/test/kotlin/ledgerkit/KnownIssueTest.kt`, one test, asserting the
`expectedAmountText` column of fixture row `LK-014`. It is annotated

```kotlin
@EnabledIfEnvironmentVariable(named = "LEDGER_RUN_KNOWN_ISSUES", matches = "1")
```

so it does not run in a normal `./gradlew test`. To watch it fail:

```bash
LEDGER_RUN_KNOWN_ISSUES=1 ./gradlew test
```

Exactly one test fails, and the message names both strings:

> LEDGER-7: LK-014 is -128000 minor units of JPY. The fixture expects
> "-¥128,000" and TransactionFormatter.amountText produced "-¥1,280.00".

`GoldenFixtureTest` walks every row of the fixture but skips the `amountText`
assertion for `LK-014`, because this file's test owns that assertion. Every
other assertion about `LK-014` — its day bucket, its filter membership — still
runs.

**Scope.** Only rendering is affected. Stored amounts, filtering, day grouping
and totals are all done in minor units and are unaffected.
