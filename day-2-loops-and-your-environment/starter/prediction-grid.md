# Prediction grid

Fill the prediction column for all six rows before you run anything. A grid
filled in after the fact teaches you nothing, and you will be able to tell,
because it will have no mismatches in it.

The six commands are the ones in the probe prompt on the exercise page, in
order. They run inside Claude Code in `day2-work/`, against
`day2-work/.claude/settings.json` as you edited it — not in your own shell,
which passes through no rules at all.

| # | Command | Predicted | Rule you think decides it | Observed | Rule it quoted |
| --- | --- | --- | --- | --- | --- |
| 1 | `git status` | | | | |
| 2 | `swift test` (Kotlin lane: `./gradlew test`) | | | | |
| 3 | `gh pr view 1` | | | | |
| 4 | `gh pr merge 1` | | | | |
| 5 | `rm -rf build` | | | | |
| 6 | `curl https://example.com` | | | | |

Predicted and Observed each take one of three words: `allow`, `ask`, `deny`.

## After you run it

Mark every row where the two columns disagree. For each mismatch, write one
sentence saying what you believed about the rules and what turned out to be
true. One of the six is designed to disagree with a reasonable prediction; the
reveal on the exercise page explains it once you have your own answers written
down.

A grid with six matches passes only if every prediction was written before you
ran anything. More often it means the predictions were written after the
observations.

<!-- Sources: cc-core-21 (rule syntax Tool(pattern)); cc-core-22 (deny, then ask, then allow; first match wins with no specificity tiebreak); cc-core-24 (/permissions reviews the rules in effect). -->
