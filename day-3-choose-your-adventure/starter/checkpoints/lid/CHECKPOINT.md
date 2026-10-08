# LID checkpoint: the design addition and the LK-PERIOD EARS block for Change C

Copy these in at Exercise 2's 25-minute checkpoint if your planning phase has
overrun. Taking the checkpoint is not failing the exercise; it exists so that a
slow planner still gets to run the implementation and grade it.

From inside `day3-work`:

```sh
cp -R ../day-3-choose-your-adventure/starter/checkpoints/lid/docs/intent/statement-period docs/intent/
```

Then copy in the arrow doc, which is the per-segment file LID's overlay keeps
beside the index:

```sh
cp ../day-3-choose-your-adventure/starter/checkpoints/lid/docs/arrows/statement-period.md docs/arrows/
```

Then do three small things by hand, because they land in files that already
hold your own mapping run's output and a copy would overwrite it:

1. Paste the entry from
   `checkpoints/lid/docs/arrows/index-LK-PERIOD-segment.yaml` into your
   `docs/arrows/index.yaml`. The file holds two shapes: an `arrows:` entry,
   which is what LID's skill writes (schema in the vendored snapshot under
   `arrow-maintenance/references/index-schema.md`), and a `segments:` entry,
   which is the shape the build machine's run wrote. Open your `index.yaml`,
   match the shape it uses, and keep the two-space indentation.
2. Add the statement-period leaf to `docs/high-level-design.md` as
   `checkpoints/lid/docs/high-level-design-addition.md` describes: one line
   under System Design, one under Key Design Decisions. LID reads the HLD
   before it implements, and a leaf the HLD does not name can stop it there.
3. Add `PERIOD` to the leaf list in the `## LID` block at the bottom of your
   `CLAUDE.md`. It is a one-word edit to one line.

Then carry on at the implementation step: continue down the arrow to tests and
then code, with `@spec` annotations citing the `LK-PERIOD` IDs.

If your own mapping run chose a different prefix or different leaf names,
these files will not line up with your tree. Read them, then write your own — that is five minutes and it keeps your
tree coherent, which is the whole point of LID.

## What is here

```
docs/intent/statement-period/statement-period-design.md   the low-level design addition
docs/intent/statement-period/statement-period-specs.md    22 EARS specs, LK-PERIOD-001..022
docs/arrows/statement-period.md                           the arrow doc, in LID's template
docs/arrows/index-LK-PERIOD-segment.yaml                  the overlay entry to paste, in both shapes
docs/high-level-design-addition.md                        the two lines to add to the HLD
```

Every spec is marked `(no test yet)`, which is the correct state at the end of
planning: the arrow has reached requirements and has not reached tests.

## How it was produced

LID's own `update-lid` workflow, run on the build machine on 2026-09-22 in a
fresh copy of the Swift lane with both LID plugins installed and the design tree
already mapped from the existing code. Handed Exercise 2's LID planning prompt
and the two answers below, it wrote the new leaf design doc and the EARS block,
extended the high-level design and the arrow overlay to match, and added one
word to `CLAUDE.md`. It stopped before tests and code, as asked.

The two leaf documents and the `segments:` entry came out of that run
untouched. The `arrows:` entry, the arrow doc and the HLD addition were written
on 2026-09-24 from the vendored snapshot's own templates, because the build
run's mapping step did not load the skill body and so wrote an overlay in a
shape the skill does not. Three things about that run are worth knowing,
because they change what you should expect from your own:

- The mapping run that preceded it wrote `docs/arrows/index.yaml` as a
  `segments:` list. Your Exercise 1 run, with the skill loaded, writes
  `arrows:` entries instead; that is why the overlay snippet carries both.
- The run could not stop for a human at each phase boundary, so it was told to
  continue and to say at each boundary what it would have asked. Your run will
  stop and ask.
- Cascade stops at a segment boundary, so three sibling documents from the
  mapping run still carry text that the new decisions contradict — the
  transaction design doc says statement periods "will need authorized", which
  decision one reverses. That is LID working as designed, not a defect: the
  arrow only runs downward, and a sibling is not downstream. Fixing them is a
  separate pass.

## The two ambiguities, and how these artifacts resolve them

The hidden acceptance suite decides both one way. These specs decide them the
same way, so an implementation that satisfies them passes:

- **Membership is by posted date.** `LK-PERIOD-013` says the grouping places a
  transaction by the UTC calendar day of `postedAt` and "shall never use
  `authorizedDay` to decide membership", and names the fixture row that
  separates the two readings: `LK-015`, authorized 2026-03-04 and posted
  2026-03-05, belongs to the period that opens on 2026-03-05.
- **A start day the month does not have is clamped to that month's last day.**
  `LK-PERIOD-008` says a month with fewer days than the start day opens its
  period on its own last day and leaves every other month unchanged — a start
  day of 31 opens February 2026 on 2026-02-28 and March 2026 on 2026-03-31.
  `LK-PERIOD-007` is the ordinary case and `LK-PERIOD-009` is what makes the
  periods run back to back.

Nine further questions stayed open and carry no spec, listed under the design
doc's open questions. The largest is what a cycle with more than one rule means
— which is precisely what Exercise 3's late change arrives to answer.
