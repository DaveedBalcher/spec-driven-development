# The run log format

The runner writes `run-log.md` in the working directory. This file describes
what goes in it; it is documentation, not the log.

`run-log.md` holds a title, the two-line table header below, and nothing else
but rows:

```markdown
# Run log

| pass | changed | tests said | next |
| --- | --- | --- | --- |
```

One row per pass through the loop, appended the moment the test command
returns. Four pipe-separated cells, under 200 characters, and the first cell is
the word `iteration` and its number, so `grep -c` over the log counts the
passes and nothing else:

```markdown
| iteration 2 | split posted and pending per currency | 1 failure: totals order is not stable | sort the currency list |
```

A gate adds two rows whose first cell is `GATE` and then `ANSWER`. Neither is a
pass through the loop, so neither carries the word, and neither is counted.

The final line of the log is prose, not a row, and names the exit that ended
the run: green, the cap, or a gate.

That is the whole format. The log is the run's memory; the conversation is not.
A compaction or a fresh session loses the transcript and keeps this file, which
is why the runner writes to it after every test command rather than summarising
at the end.
