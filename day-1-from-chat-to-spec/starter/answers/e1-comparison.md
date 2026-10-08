# Answer key — Exercise 1, the five-row table

Your two captures already decided four of the five rows. This page is here for
the fifth, for the two rows people fill in wrong, and for what to make of the
case where both runs look the same.

---

## How each row is decided

Read these off `../work/run-a.diff` and `../work/run-b.diff` — the two files
step 3 and step 5 wrote, named from inside `day1-work` where every command on
the exercise page runs — rather than off your memory of watching the run go by.
Each capture compares the shipped lane one level up against the copy, and `-N`
makes a file the agent created show up as a whole-file addition, so a file it
created is counted as well as a file it edited.

| Row | Where the answer comes from |
| --- | --- |
| Files touched | `grep -c '^diff ' ../work/run-a.diff`. Each changed or added file opens a section with a header line starting `diff`, so counting those lines counts the files. |
| Files touched out of bounds | `grep '^diff ' ../work/run-a.diff \| grep -v LedgerFilter`. Every path it prints is a file the prompt did not allow; both lanes' in-bounds files carry `LedgerFilter` in their names. |
| Tests pass or fail | Your own run of the lane's test command, after the agent stopped. Not the agent's. |
| Did the agent run the verification command itself | Scroll back to the transcript. Look for the tool call, not for a sentence about it. |
| Lines changed | `grep -vE '^(--- \|\+\+\+ )' ../work/run-a.diff \| grep -cE '^[+-]'`. Insertions plus deletions, with each file's two header lines left out. |

Run the same three against `run-b.diff` for the other column.

Rows one, two and five are arithmetic on a file. Row three is a command you ran.
Row four is the one that needs a decision, and it is the one below.

---

## The two rows people get wrong

### Row four: "did the agent run the verification command itself"

The mistake is answering yes because the final message says the tests pass.

A model can write "I ran the tests and they pass" without having run anything.
It is not lying in any interesting sense — it is producing the sentence that
usually follows a change like this one. The only evidence that counts is a tool
call in the transcript with output attached to it, and that is a thing you can
scroll back and look at.

Answer this row from the transcript, every time. If you cannot find the call,
the answer is no, whatever the summary said.

This is the row the whole exercise exists for. Prompt B asks for the command and
names the output line that carries its result — "show me the Executed line right
under Test Suite 'All tests' passed (or failed)" in Swift, "show me the BUILD
line" in Kotlin — because a request for the output is a request for the run,
and a request to "verify" is not.

### Row two: "files touched out of bounds"

The mistake is reading a green suite as in-bounds.

Run A can touch four files, pass every test, and be exactly the change you did
not want: a helper extracted into `Money`, a signature widened in
`TransactionFormatter`, a "while I was here" tidy in `LedgerSummary`. Nothing
breaks. The tests stay green because none of those files had a failing test
waiting for them.

Green says nothing about scope. The capture says everything about scope, and its
header lines fit in one screen. That is why this row is decided by a grep over
those header lines and not by reading the hunks: a file list you can count is a
check, and a diff you read is a judgement call at the end of a long afternoon.

---

## Reading your own pair

Three outcomes, all of them real results.

**Run B is narrower than run A.** The usual case. Write down which of the four
prompt parts you think did the work. Most people say bounds, because that is the
row that visibly changed. It is often verification: an agent that has been given
a command to run and an output to show tends to make a change it can prove,
which is a smaller change.

**The two runs are close to identical.** This happens, and more often on a small
well-named task in a small repository than people expect. It is not a failed
exercise. The four parts of a prompt are insurance, and insurance that did not
pay out this time still had a price of ninety seconds. What you have learned is
what the task looked like when the insurance was not needed — worth knowing,
because the next task will be larger and you will not be able to tell in advance.

**Run A did nothing at all.** Also a result, and the one Prompt A's wording
invites: it describes a symptom and names no file, so the agent may reasonably
read the code, decide the behaviour is already correct, and say so. An empty
`run-a.diff` is what that looks like. Record it in the table as zero files
touched. An agent that declines to change working code is behaving well; a
prompt that could not tell you whether the code worked is the finding.

No recorded reference pair ships with this exercise. Two runs of the same prompt
differ, and one machine's numbers printed here as the answer would be the exact
mistake row four is about: a claim standing in for a command you ran. Your own
two captures are the evidence.

<!-- Sources: /clear cc-core-19; Claude Code v2.1.280, checked 2026-09-22, cc-core-32 -->
