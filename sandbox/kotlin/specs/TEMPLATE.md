# Spec: <short name of the change>

> Copy this file, rename it after the change, and fill every section. The agent
> reads this instead of guessing. Anything you leave vague, it will decide for
> you, and it will not tell you that it did.

## Goal

One or two sentences. What is true after this change that is not true now,
stated as behaviour, not as an implementation.

## Non-goals

What this change deliberately does not do. Each line here is a decision the
agent will otherwise make on its own.

- …
- …

## Acceptance criteria

Numbered, binary, and each one traceable to a command that can fail. A criterion
that cannot make a command exit non-zero is a hope, not a criterion.

1. …
2. …
3. …
4. …

### Criterion → check

| # | The command that fails when this is not true |
| --- | --- |
| 1 | … |
| 2 | … |
| 3 | … |
| 4 | … |

## Bounds

**May change**

- …

**Must not change**

- `Fixtures/transactions.tsv` — the golden fixture. If a change needs the
  fixture edited, that is a different change.
- …

## Verification

The exact commands, in order, with the output that counts as a pass.

```bash
./gradlew test
```

Pass: the run ends with `BUILD SUCCESSFUL`.

## Definition of done

- [ ] Every acceptance criterion is met and its check was run.
- [ ] Nothing outside **May change** was modified (the diff against the shipped
      lane names no other file).
- [ ] The verification commands were run and their output is quoted in the
      final message, not summarised.
- [ ] No locale API was introduced (see `README.md`).
