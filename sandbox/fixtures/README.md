# LedgerKit fixtures

`transactions.tsv` is the single source of the sample ledger. Both lanes get a
byte-identical copy of it in their own test-fixture folder (Swift
`Tests/LedgerKitTests/Fixtures/`, Kotlin `src/test/resources/`), and the
table-driven golden test in each lane reads it row by row.

Tab-separated, UTF-8, LF line endings, one header row and 20 data rows. Fields
are never quoted and never contain a tab.

## Columns

| Column | What it holds |
| --- | --- |
| `id` | Stable transaction identifier (`LK-001` … `LK-020`); test failures name it, so it never changes once shipped. |
| `postedAt` | ISO-8601 instant, UTC (`Z`), when the transaction settled; for a pending row it is the instant it is expected to settle. |
| `authorizedAt` | ISO-8601 instant, UTC (`Z`), when the transaction was authorized; on several rows this falls on the day *before* `postedAt`. |
| `merchant` | Merchant name exactly as it arrives from the network, including diacritics and shouty upper case; filter matching is case- and diacritic-insensitive, so the stored form is deliberately inconsistent. |
| `amountMinor` | Signed integer in the currency's minor units — negative is a debit (money leaving), positive is a credit (money coming back). No decimal point ever appears in this column. |
| `currency` | ISO 4217 code: `USD`, `EUR`, `GBP`, `JPY`, `BHD`. |
| `status` | One of `pending`, `posted`, `declined`. |
| `category` | One of `groceries`, `transport`, `dining`, `bills`, `other`. |
| `expectedAmountText` | What a **correct** `TransactionFormatter.amountText` prints for this row: sign, then symbol, then the grouped number with that currency's decimal places. This is the golden column — it does not describe the shipped code, which still has LEDGER-7. |
| `expectedDay` | The day bucket `LedgerSummary.byDay` must put this row in: the calendar date of `postedAt` in UTC, `YYYY-MM-DD`. |

## What `expectedAmountText` encodes

- Decimal places come from the currency: `JPY` 0, `USD` / `EUR` / `GBP` 2,
  `BHD` 3.
- Thousands are grouped with commas in the integer part only.
- The sign comes first, then the symbol, then the digits: `-$84.99`,
  `+$2,500.00`, `-€12,345.67`, `-¥128,000`, `-BD12.500`.
- Symbols are `$`, `€`, `£`, `¥` and `BD`.
- Everything is hand-rolled. No `NumberFormatter`, no
  `java.text.NumberFormat`, no ICU, no locale lookups — that is what lets one
  fixture hold the expected strings for both lanes.

The shipped code disagrees with this column on exactly one row: `LK-014`, the
`JPY` row, because `Money.decimalPlaces` returns 2 for every currency. See
`KNOWN-ISSUES.md` in either lane.

## Coverage the rows are chosen for

- Every status and every category appears.
- Five currencies, with exactly one `JPY` row and exactly one `BHD` row, so the
  decimal-place bug and the three-decimal case each have a single, nameable
  failing case.
- 2026-03-02 carries a `USD` row and two `EUR` rows — same day, different
  currencies, for the per-currency breakdown.
- 2026-03-03 carries posted rows plus one `pending` and one `declined` row, for
  the totals rule that excludes declined but still lists it.
- `LK-009`, `LK-010` and `LK-011` were authorized late on 2026-03-03 and posted
  in the small hours of 2026-03-04, so authorized-day and posted-day grouping
  give different answers.
- `LK-013`, `LK-019` and `LK-020` are credits, so the `+` sign is exercised.
- `LK-018` and `LK-020` cross 1,000 units, so grouping is exercised on both a
  debit and a credit.
- `Café Müller`, `CAFÉ MÜLLER KIOSK`, `ZÜRICH TRANSIT`, `Zürich Transit
  Authority` and `Nørrebro Bakeri` exercise case- and diacritic-insensitive
  merchant matching.
