# Late requirement: the start day can move

This one arrived after statement periods shipped. Push it through your
framework's update path, not around it.

A customer's cycle start day can change: a configuration may carry more than
one rule, and each rule names the date from which its start day applies. A date
opens a new statement period when its day of the month matches the start day of
the rule in force on that date, so a period that opened before a change keeps
the start date it already had and ends the day before the first boundary the
new start day produces. No rule applies before the date it takes effect, and a
change never splits a period in two — it moves where the next period begins,
and nothing else. A date before every rule is the one exception to the first
of those: it uses the earliest rule, and no test here holds such a date.
