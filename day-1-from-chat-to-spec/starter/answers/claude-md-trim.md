# Answer key — trim the context

The sandbox ships a `CLAUDE.md` of about 180 lines. Six of those lines are doing
work. The rest is either true and useless, useless and true, or false.

The lines below are quoted from the Kotlin lane. The two lanes carry the same
six facts but not the same sentences, and they organise the file differently —
the Swift lane's six are quoted in full further down, and its section headings
are named alongside the false keeps. Check your answer against your own lane.

## The six lines that must survive

1. **The test command.**
   `- Run the whole suite with ./gradlew test from this directory. That is the only test command.`
   Without it the agent guesses, and a guessed test command that happens to
   succeed is worse than one that fails, because you believe it.

2. **The fixture path.**
   `- The golden fixture is Fixtures/transactions.tsv, read from the project directory. Never edit it: it is shared byte-for-byte with the other lane.`
   It tells the agent where the expected answers live *and* that editing them to
   make a test pass is out of bounds. Both halves earn their place.

3. **The minor-units convention.**
   `- amountMinor is a signed integer in the currency's minor units. It never holds a decimal point, and no code may turn it into a floating-point number.`
   This is the fact that cannot be recovered by reading one file. An agent that
   does not know it reaches for `Double` within about a minute.

4. **The sign convention.**
   `- Negative is a debit and renders with a leading -; positive is a credit and renders with a leading +. The sign always comes before the currency symbol.`
   Ordering — sign, then symbol, then digits — is the part that is genuinely
   arbitrary and therefore genuinely worth writing down.

5. **The no-locale-APIs rule.**
   `- Never use a locale-aware API for formatting: no java.text.NumberFormat, no DateTimeFormatter, no ICU, no Locale. All formatting in this module is hand-rolled.`
   The single highest-value line in the file. It names the wrong move, by name,
   before the agent makes it, and it is the one rule the whole fixture rests on.

6. **Run the tests before claiming done.**
   `- Run the tests before you say you are done, and quote the last line of the output rather than summarising it.`
   "Quote" rather than "summarise" is what makes the line falsifiable. A summary
   of a test run is an opinion.

Six lines, about 700 characters. Everything else in the file can go.

## The same six in the Swift lane

Verbatim, in file order. Same six facts, and worth reading side by side with the
Kotlin set above, because two of them are weaker here.

1. `Run the tests with swift test from the package root.` (§ Testing)
2. `The fixture at Tests/LedgerKitTests/Fixtures/transactions.tsv is the source of truth for expected strings.` (§ Fixtures)
3. `amountMinor is an integer in the currency's minor units; a decimal point never appears in stored data.` (§ Money)
4. `Negative amountMinor is a debit and prints with -; zero or positive is a credit and prints with +.` (§ Money)
5. `Never use NumberFormatter, Locale, ICU or any locale API: all formatting is hand-rolled.` (§ Money)
6. `Run the tests before you say you are done, and quote the final summary line.` (§ Testing)

Three of those are worth improving as you cut, which is a legitimate thing to do
to a line you are keeping.

- Line 2 says where the fixture is and not that editing it is out of bounds. The
  Kotlin lane's version carries both halves. Add the second half.
- Line 3 says a decimal point never appears in stored data, which does not
  forbid a `Double` in the middle of a calculation. The rule you want is the
  Kotlin one: no code turns `amountMinor` into a floating-point number. The
  Swift file does say `Amounts are never floating point` — three sections away,
  in a paragraph about ISO 4217 codes. Fold it into line 3 and cut that
  paragraph.
- Line 6 names the output by position. Both test runners print banners after
  the result, so "the last line" is a banner in either lane (Gradle's is a
  configuration-cache hint). Name the line by what it carries: the `Executed`
  line in Swift, the `BUILD` line in Kotlin.

A trim is not only deletion. Two lines merged into one that is stronger than
either is a cut, and it is the kind that survives Day 2.

## The four classic false keeps

These are the sections people preserve on the first pass, in the order they
usually get preserved. Each one feels responsible. None of them changes what the
agent does.

1. **The generic coding standards** — "write clean, readable code", "follow
   SOLID", "don't repeat yourself", "keep functions short". Fourteen lines that
   describe every codebase ever written. A model that needed to be told to write
   readable code would not be able to act on the instruction. Cut the section
   whole; nothing in it is specific to LedgerKit.

2. **The style guide** — and this one is not merely useless, it is wrong. It
   asks for two-space indentation, no trailing commas, wildcard imports,
   companion objects instead of top-level `object`, block bodies instead of
   expression bodies, no string templates, and lowerCamelCase test names. The
   code in `src/` does the opposite of every one of those. Keeping it means
   paying tokens every turn for instructions that contradict the file the agent
   is about to edit, which is how you get a diff that reformats the module. If
   a style rule matters, a formatter enforces it; if no formatter enforces it,
   it did not matter.

3. **The three paragraphs about LedgerSync** — the nightly reconciliation
   service, its YAML fields, its command-line tool. It is accurate, it is
   interesting, somebody clearly wrote it after a painful week, and none of it
   is in this repository. Background about a system you cannot touch from here
   is a document, not an instruction. Move it to a wiki page and link it.

4. **The project overview, history and directory layout** — three refactors, a
   fourth that was never scheduled, and an ASCII tree of six directories. The
   agent can list the directory faster and more accurately than the file can
   describe it, and it will, because the tree in a standing instructions file is
   stale the first time somebody adds a folder. History belongs in git.

### The same four in the Swift lane

The sections are named differently and the argument is unchanged.

| # | Kotlin lane | Swift lane |
| --- | --- | --- |
| 1 | § Coding standards | § Engineering principles, § Working agreements |
| 2 | § Style guide | § Style |
| 3 | § Working with LedgerSync | § The ledger-sync tool |
| 4 | § Project overview and history, § Directory layout | § About this project, § History |

The Swift lane carries four more sections the Kotlin lane does not — code
review, performance notes, accessibility, security — and every one of them is a
paragraph of good advice about a concern this module does not have. They go for
the same reason as the four above: read the section, try to name the mistake its
absence would cause, and cut when you cannot.

The Swift lane's glossary is a fifth candidate and the Kotlin lane's is buried
lower down. Both go to `README.md`.

## What to do with the rest

Not everything cut has to be deleted.

- The domain rules that are not in the six — `authorizedAt` versus `postedAt`,
  the three statuses, the five categories, merchant matching being
  case-insensitive — are real facts, but they are already visible in the types
  and in `README.md`. Cut them from `CLAUDE.md`. If one of them turns out to
  cause a repeated mistake, that is exactly the observation Day 2 routes back
  into the file, and there will be room for it.
- The git and review workflow belongs in `CONTRIBUTING.md`.
- The glossary belongs in `README.md`.

The measure is not "shorter". The measure is: every remaining line changes what
the agent does, and you can say how.

## The reference trimmed file

Fifteen lines, Kotlin lane. Under the forty the exercise asks for, and the
slack is deliberate: the room is there so that Day 2's self-critique has
somewhere to route a finding without the file starting to grow again.

```markdown
# CLAUDE.md — LedgerKit

## Testing

- Run the whole suite with `./gradlew test` from this directory. That is the only test command.
- The golden fixture is `Fixtures/transactions.tsv`, read from the project directory. Never edit it: it is shared byte-for-byte with the other lane.

## Domain

- `amountMinor` is a signed integer in the currency's minor units. It never holds a decimal point, and no code may turn it into a floating-point number.
- Negative is a debit and renders with a leading `-`; positive is a credit and renders with a leading `+`. The sign always comes before the currency symbol.

## Before you say you are done

- Run the tests before you say you are done, and quote the BUILD line rather than summarising it.
```

The Swift lane's copy is the same shape, built from its own six lines above —
`swift test`, `Tests/LedgerKitTests/Fixtures/transactions.tsv`, and the two
merges named there — with the Swift class names in the rules file below.

Three things about that file are worth naming.

**The headings are load-bearing and nearly free.** Four short headings cost four
lines and make the file skimmable by the person who has to defend it in six
weeks. They are the one piece of formatting that survives the line test, because
the mistake they prevent is yours, not the agent's.

**The no-locale-APIs rule is not in it.** It moved to the rules file. That is the
one genuinely surprising move on this page, and the next section is about why.

**Nothing in it points at a second file.** The domain rules you cut —
`authorizedAt` versus `postedAt`, the statuses, the categories, the merchant
matching — are already visible in the types and in `README.md`, so they are cut
rather than filed somewhere for later. The one line that moves rather than goes
is the file-specific formatting rule, and the next section is where it lands.

## The reference rules file

`.claude/rules/formatting.md`, in the lane copy, Swift lane:

```markdown
---
paths: ["Sources/LedgerKit/*.swift"]
---

Formatting in this module is hand-rolled: never introduce a locale-aware API (`NumberFormatter`, `DateFormatter`, `Locale`, ICU) into these files.
```

The Kotlin lane's glob is `paths: ["src/main/kotlin/ledgerkit/*.kt"]` and the
API names are `java.text.NumberFormat`, `DateTimeFormatter`, `Locale` and ICU.

A path-scoped rules file is loaded when the agent reads a file its glob
matches, rather than at the start of every session. <!-- Sources: cc-core-15 -->
So the rule is present in the only turns where it can prevent anything — the
turns that edit the formatting code — and absent from the turns that read a
ticket, list a directory or write a spec.

This is the move that makes "the single highest-value line in the file" not a
line in the file, and it is worth being uncomfortable about for a minute. The
argument for keeping it in `CLAUDE.md` is that an agent can reach for
`NumberFormatter` while editing a test, or a new file the glob does not cover.
The argument against is that a rule paid for on every turn and needed on a tenth
of them is exactly the tax this exercise is teaching you to see. Either answer
is defensible; what is not defensible is not knowing which one you chose.

If you kept it in `CLAUDE.md` and still came in under forty lines, you have
passed. Write down which of the two arguments you were making.

## Checking your own answer

Not "did you match this page". Three questions:

1. Is it under forty lines? `wc -l CLAUDE.md` answers it.
2. For every line still in the file, can you name the specific mistake its
   absence would cause? That is the line test, applied to what survived rather
   than to what you cut.
3. Did the Exercise 1 re-run stay in bounds and stay green? If it went
   out of bounds, you cut a line that was doing work. Put it back and note which
   one — that is the most useful thing this exercise can tell you, and it is
   worth more than matching the file above.
