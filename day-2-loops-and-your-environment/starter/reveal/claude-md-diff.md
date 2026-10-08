# The reference CLAUDE.md revision

One line in, two lines out, in both lanes. The rule is not "keep it short"; the
rule is that the file does not grow, so adding something means deciding what it
outranks.

From inside `day2-work`, `wc -l CLAUDE.md` is the number. Same or lower
afterwards is a pass. Higher is a failed exercise even when the tests are green.

## What goes in

Findings 1 and 2 are the same mistake: the run split the world into pending and
not-pending, and a declined row landed in a total because of it. That is a
domain fact, it is not specific to Change B, and the next change that touches
money will meet it again. Standing instructions are for what recurs.

The sentence is the same in both lanes:

```text
A declined transaction is still listed and counted in no total; pending money is reported separately from settled money.
```

What pays for it is whatever each lane's file was already spending two lines on.

## Swift lane

The Swift `CLAUDE.md` has no statuses line to sharpen. The new rule goes under
`## Money`, where the other domain rules already are, and two items leave
`## Engineering principles`: principles that name no specific mistake.

```diff
 ## Engineering principles
 ...
-9. Leave the campsite cleaner than you found it.
 ...
-11. Premature optimization is the root of all evil.
 ...
 ## Money
+A declined transaction is still listed and counted in no total; pending money is reported separately from settled money.
```

## Kotlin lane

In `## Domain rules`, the two-line statuses bullet is replaced by a one-line
version:

```diff
-- Statuses are `pending`, `posted` and `declined`. A declined transaction is
-  still a transaction and is still shown to the customer.
+- Statuses are `pending`, `posted` and `declined`. A declined transaction is still listed and counted in no total; pending money is reported separately from settled money.
```

The bullet that comes out is true, and it is the half of the fact the code does
not get wrong. The half it gets wrong is the money.

Two lines out, one line in, in each lane. `wc -l CLAUDE.md` goes down by one,
which is why net-zero is written as "same or lower" and not as "exactly equal".

## Why not a rule file instead

A path-scoped rule file under `.claude/rules/` with `paths:` globs in its
frontmatter would also hold this sentence. It is the right move when the
guidance is long or applies to one corner of a big repository. For one sentence
about the files this module mostly edits, it buys a file and saves nothing.

## What did not go in, and why

- **"Days are ordered newest first."** That is criterion 3. It belongs to this
  change, not to every change, and it is already asserted by a test. Putting a
  spec criterion in `CLAUDE.md` is how the file gets to 180 lines.
- **"Sort currency lists by code."** Same reason, criterion 4.
- **"Do not reverse rows inside a day."** This is an instruction shaped like a
  bug report. The sharpened criterion 3 in the spec catches it, and the spec is
  where this change's decisions live.

## How you find out whether the line earns its place

Take it out and run the spec again from a fresh copy. If the mistake comes back,
the line was doing work. If it does not, you paid tokens every turn for a
sentence. That is one observation, on one spec, in one lane, which is exactly
how much you may claim.
