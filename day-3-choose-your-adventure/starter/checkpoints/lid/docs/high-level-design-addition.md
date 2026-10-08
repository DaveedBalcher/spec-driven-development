# Addition to docs/high-level-design.md

LID's skill reads the high-level design before it implements, so the new leaf
has to appear there or the pre-implementation check may stop on a leaf the
tree does not know. Paste by hand; a copy would overwrite the HLD your mapping
run wrote.

Under `## System Design`, beside the lines that name your other leaves (the
build machine's HLD listed one line per leaf there; if yours lists them in
another section, follow yours), add:

```markdown
- **Statement periods** (`statement-period`, prefix `LK-PERIOD`) — parses the
  cycle configuration and groups posted transactions into statement periods;
  depends on the transaction leaf. Design:
  `docs/intent/statement-period/statement-period-design.md`. Added by Change C.
```

Under `## Key Design Decisions`, add one line, because the decision belongs to
the whole module and not only to the leaf:

```markdown
- **Statement-period membership is by posted date, never by authorized date.**
  A transaction sits in the period that holds the UTC calendar day of
  `postedAt`; see LK-PERIOD-013. Chosen so the grouping matches the statement
  the customer receives, not the day the merchant asked.
```
