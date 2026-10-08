# Change B — a daily summary people can trust

*From product, after the March round of customer interviews. Written the way it
arrived: no criteria, no file names, no commands.*

## The problem

The transaction list groups by day and puts a total at the top of each day. In
six of the nine interviews, somebody read that total, did the arithmetic on the
rows underneath it, and got a different answer. Two of them thought the app had
lost a transaction.

It has not. The total is counting things people do not think of as money that
moved.

## What we want instead

A day total that matches what a customer would add up if they did it by hand,
and enough context next to it that nobody has to.

**Declined transactions.** A declined charge never took any money. It is in the
list because customers want to see that the attempt happened — one interviewee
checked three times a day after a card was cloned — but it should not be inside
the day's total. Keep showing it, stop counting it.

**Pending transactions.** These are the opposite problem. The money is not gone
yet, but it is spoken for, and every customer we spoke to treats it as gone. We
want the pending amount called out as its own number on the day, next to the
posted total, rather than mixed into one figure. Two numbers, both labelled.

**Order.** The list opens on the oldest day, which is wrong for a feed people
check daily. Newest day first. And a day with nothing on it should never be
rendered. The summary does not do that today, and we want it kept that way when
the order changes: a quiet weekend must not turn into a run of empty headers.

**Currencies.** This one came from the two people who travel. Today a day's
total adds a euro charge to a dollar charge and prints one number, which is not
a number that means anything. We would like a day that has more than one
currency in it to break its totals out per currency rather than pretend.

## What we are not asking for

No conversion. We are not fetching a rate and we are not showing an
approximation in the customer's home currency — that is a separate piece of work
with a compliance conversation attached to it. If a day has three currencies, we
show three sets of totals.

Nothing about the screen. Spacing, headers, the empty state, where the labels
go: not this change.

## Open questions we do not have answers to

- Does a day with only declined transactions still appear? Interviews split
  about evenly and we do not have a strong view.
- Should the pending number include a pending refund, which is money arriving
  rather than leaving? Nobody asked about it.

---

*Exercise 3 turns this into a spec. Nothing on this page is a criterion yet:
"matches what a customer would add up" cannot fail a command. Your job is to
write the four that can, and to give each open question its destination, as
Lessons 4 and 5 list them: a numbered criterion when you can decide it, folded
into an existing criterion's assertion or input so the count stays at four, a
non-goal when the answer is no, and a stop condition when deciding it changes
what a test asserts and nobody has decided it; when nobody can, it goes back to
whoever can. You can decide it when the answer follows from a convention
already in the module.*
