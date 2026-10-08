# Comparison card: <your track>

The card you hand your team. Eight questions, eight answers, each of them one
bullet that starts with `- ` and runs at least a sentence. Fill it from what
you observed today, not from the course pages, and leave a question unanswered
rather than guessing at it.

Your self-check counts the answers, from inside `day3-work`:

```bash
grep -c '^- .\{40,\}' ../work/comparison-card.md
```

It returns `8` when every question has an answer longer than a phrase, and it
returns the count of finished answers before that.

## 1. What does it install, and what does that require?

## 2. Where do specs live?

## 3. What command creates a spec?

## 4. What command implements one?

## 5. What happens to a spec after its change ships?

## 6. How did it handle a requirement that arrived late?

## 7. What is the one thing it did that you would not want on your team?

## 8. Which failure from Lesson 4 would you adopt it to fix?
