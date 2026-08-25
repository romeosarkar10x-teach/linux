# 06/02 — `grep` Flags

> Fifteen flags. Three of them change what counts as a match, four change what gets printed, two
> change how much of the tree gets read, and the rest are conveniences you will use every day.

## What this lesson is

Lesson 01 was `grep pattern file`. That is the whole tool. Everything in this lesson is a modifier
on one of three questions: **what matches**, **what you see**, and **where it looks**.

Sorting the flags by which question they answer is worth more than memorising them, because the
mistakes come from mixing the categories up — asking for a count and getting a count of the wrong
thing, or asking for context and not noticing that the context ran together.

## What matches

`-i` ignores case. `-w` requires the match to be a whole word — bounded on both sides by something
that is not a letter, digit or underscore. `-x` requires the match to be the whole **line**, start
to finish.

These stack in a way that is easy to get wrong. In a nine-line word list, `bay` matches eight lines,
`-w bay` matches five, and `-x bay` matches one. And `-w` uses the underscore rule, not the English rule, which
is why `bay-01` counts as a word match for `bay` (the dash is a boundary) while `subbay` does not.

`-v` inverts the whole decision: print the lines that did **not** match. `-v` combined with `-c`
is the single most useful pair in the flag set — "how many lines are not ok" is a question you will
ask constantly — and `-v` combined with `-l` is a trap, because it means "files with at least one
non-matching line", which is nearly every file.

## What you see

`-n` prefixes the line number. `-c` replaces the output with a count of matching **lines**. `-o`
prints only the matched part of the line, one per line — so `-o` and `-c` disagree whenever a
pattern matches twice on one line, and `grep -o … | wc -l` is how you count matches rather than
lines.

`-l` prints the names of files that matched and stops reading each one at the first hit. `-L` prints
the names of files that did **not** match. `-L` is the flag people forget exists and then reinvent
badly with a loop; "which of these hundred logs is missing the heartbeat line" is one command.

`-A n`, `-B n`, `-C n` print n lines after, before, or around each match. Two things to know before
you trust the output. First, `grep` inserts a `--` line between non-adjacent blocks, and that line
is not from your file. Second, if two matches are close enough that their context overlaps, the
blocks **merge** and no separator appears — so the number of output lines is not
`matches × (n+1)`, and counting them will mislead you.

## Where it looks

`-r` walks a directory tree instead of reading one file. It follows the tree from the paths you give
it, and if you give it none it starts at `.` — which is a good way to search your entire home
directory by accident.

`--include='*.log'` restricts `-r` to matching filenames; `--exclude` is the mirror image, and
`--exclude-dir=.cache` prunes a whole directory without descending into it. The difference between
`--exclude` and `--exclude-dir` is real work: excluding files still reads the directory and still
costs you the walk, while excluding the directory does not enter it at all.

`-I` skips binary files. `-s` suppresses unreadable-file messages, and lesson 01 already told you
what that hides.

## The shape of the lab

`reports/` holds three run reports and a quiet one. The reports number their own entries — remember
that. Two of them have `FAULT` lines, one has none at all, and in the deck-03 reports each fault is
followed by exactly two detail lines, which is what makes `-A`/`-B`/`-C` measurable.

`archive/` holds older copies of the same reports, one of them with the fault marker in lower case,
plus `.cache/` full of junk that matches everything and belongs in no answer.

`words.txt` and `codes.txt` exist for `-w` and `-x`. `readings.csv` has two columns with the same
header name, which is what `-o` is for. `scratch/` is yours.

## Rules of engagement

Every count in this lesson has a right answer, and most of them have a plausible wrong answer that
differs by one or two. When two flags give different numbers, the interesting question is never
"which is right" — it is "what were the two questions".

## What "solved" looks like

You can put any of these fifteen flags into one of the three categories without looking it up. You
can explain why `-c` and `-o | wc -l` differ, and construct a file where they agree. You can predict
the line count of a `-C1` output before running it, including the separators. And you can restrict a
recursive search to the files you meant without piping it through a second `grep`.

## Before you move on

Lesson 03 is regular expressions, where the patterns get their own grammar. Everything you learned
here about `-i`, `-w`, `-x` and `-o` applies to those patterns unchanged — which means a sloppy
pattern will now be sloppy in more directions.
