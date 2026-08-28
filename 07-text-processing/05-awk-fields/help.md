# 07/05 — Tutor guide: `awk` fields

`awk` is the point where the chapter stops being about commands and starts being about programs. The
risk is not that the student cannot follow — it is that they try to learn all of `awk`, or that they
learn to reach for it for everything. Hold them to the six lines in `notes/awk.txt`.

The four things this lesson must install:

1. Fields are named, not counted by separator. This is why `awk` beats `cut` on real files.
2. `END` is where reports come from.
3. `c[key]++` plus `END` is one-pass counting.
4. Nothing warns you when `awk` misreads a file. `NF` is how you check.

Never give an answer. Every result is one command from being checked.

## Where students stall, and what to ask

**Exercise 1.** Put lesson 04 exercise 48 and this one side by side on the screen. Ask which one they
could modify to print field 4 instead. That is the whole argument and it takes ten seconds.

**Exercise 7** (no comma). Students read `print $3 $5` as a typo for `print $3, $5`. Let it run. Then:
"`awk` did exactly what you asked — what did you ask?" Concatenation-by-adjacency is unusual and needs
one deliberate encounter.

**Exercises 8–13** (ragged, and `-F' '`). Exercise 12 makes people angry. Let it. Ask them to predict
first so the surprise lands, then ask what a single space would have to mean for `awk`'s default to be
expressible at all. The answer they should reach: `-F' '` had to mean something, and the default was
worth more than the literal.

**Exercise 15.** The trap is quiet. If they say "so the default separator is fine for TSV", agree,
then ask what happened to row 7 and how they would have found out on a file with ten thousand rows.
Steer them to `NF` (exercise 3) as the standing check.

**Exercise 19** (CSV). Do not let them leave with "`awk -F,` parses CSV". Ask what a quoted comma is,
then what `awk` would have to know to handle it. Then ask what they would do in real life. Acceptable:
use tabs, or use a real parser. Not acceptable: a longer regular expression.

**Exercise 34** (running total). If they printed inside the main block and shrugged at the wall of
numbers, ask which line of that output is the answer, and how they would find it in a script.

**Exercises 37–38** (silent wrong totals). This pair is the honest part of the lesson. Ask what would
have told them. Push until they name a **cross-check** — a count they already know, a previous
figure, an order of magnitude — rather than "I would be careful".

**Exercise 40** (array order). Some students will run it five times, see the same order, and conclude
it is guaranteed. Ask where the guarantee would be written down. Then ask what `sort` costs them here.
The habit — pipe to `sort` and stop thinking about it — is cheaper than the argument.

**Exercise 45** (header in the pipeline). If they are baffled that the header sorted, ask what `sort`
knows about headers. Nothing. This generalises to every chapter after this one.

**Exercise 47.** They will read the top of the table because everyone does. Make them read the bottom
and say out loud what a count of 1 means. Do not connect it to the incident; leave it.

**Exercise 55.** If they answer "nothing, `awk` can do it all", they are technically right and have
missed the lesson. Ask what a colleague reading the script at 3 a.m. would rather see for a plain
substitution.

## Questions that work when they are stuck

- "How many fields does `awk` think that line has? Check."
- "Which block is that in — main or `END`? How many times does it run?"
- "What is the value of that variable on the first line?"
- "Is that a pattern or an action?"
- "What would this do to a line with a missing field?"

## Do not

- Do not teach `gsub`, `getline`, user functions or multi-dimensional arrays. If they ask, say it
  exists, name it, move on. The chapter's argument is that six percent is enough.
- Do not let them replace `grep`, `sort`, `wc` and `sed` with `awk` because they now can.
- Do not explain `$1=$1` before exercise 49 has failed to change anything.
- Do not accept "it worked" as evidence a separator is right; ask for the `NF` check.
