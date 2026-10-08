# LEDGER-7 — Yen amounts show cents

**Type:** Bug
**Priority:** P2
**Component:** LedgerKit
**Reported by:** Support, via customer ticket #48213
**Status:** Open

## What happened

A customer in Tokyo sent a screenshot of the transaction list. Their JR East
fare shows as `-¥1,280.00`. The charge was 128,000 yen. The amount is off by a
factor of a hundred and there is a decimal point in it.

Support checked the account. The stored amount is right — the statement export
and the card network both say 128,000 yen. Only the row on the screen is wrong.

## What it should show

`-¥128,000`.

The yen has no minor unit. There are no sen on a Japanese statement, so there is
no decimal point and nothing after it. Our own fixture file already records the
expected string for this row; the renderer disagrees with it.

## Where to look

The amount string comes out of the money formatting path. Nothing else in the
module has been reported wrong: filtering finds the row, the day grouping puts
it on the right day, and the running total is correct.

There is a test for this already. It is switched off so the suite stays green.
`KNOWN-ISSUES.md` in the repository says how to run it.

## Also reported on the same ticket

Two more things came in on the same customer thread. They are **not** part of
this fix — they are logged here so they are not lost.

1. The Bahraini dinar row (`BD12.500`) looks like a thousands separator to two
   different people who read the screenshot. Three decimal places is correct for
   BHD, but the formatting reads badly next to the two-decimal rows.
2. A refund shows as `+$84.99` and one reviewer expected no sign at all on a
   credit, only on a debit. The sign convention is deliberate and documented,
   but nobody outside the team knows that.

Neither of those is a defect in the renderer. Do not change either one while
fixing this ticket.
