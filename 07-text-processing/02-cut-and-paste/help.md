# 07/02 — Tutor guide: `cut` and `paste`

The student is learning to take one column out of a line and to put columns back together. The flags
take twenty minutes. The rest of the lesson — and the reason it is here — is that **`cut` fails
silently**, and every one of its failures produces output that looks like data.

Guide with questions. Do not hand over pipelines.

## What the lesson is actually for

Three things should survive:

1. `cut -d' ' -f3 log | sort | uniq -c | sort -rn` — the chapter's workhorse.
2. `cut` cannot reorder, cannot collapse repeated delimiters, and cannot parse quoting.
3. The three silent failure modes (exercise 56). Ask for that list at the end even if the student
   skipped the stretch section; it is the most useful thing in the lesson.

## Where students stall, and what to ask

**`cut -f2 roster.csv` prints whole lines** (ex. 2). Students think `cut` broke. Ask: "how many tabs
are in that file?" Then: "what does `cut` do with a line that has no delimiter?" Let them find that
rule now, because exercises 28–30 depend on it.

**`cut -f5,3` does not reorder** (ex. 4–5). Almost everyone predicts a swap. Do not pre-empt it — the
failed prediction is the teaching. After they run it, ask *why* `cut` might be built that way. The
answer (one pass, left to right, no buffering) is worth drawing out because it explains the
`--output-delimiter` asymmetry in exercise 12 and the 40 GB question in exercise 55.

**`cut -d' ' -f2 aligned.txt` prints blank lines** (ex. 22). Ask them to run `cat -A` first if they
have not. Then: "how many spaces are between `account` and `deck`, and what is between the first and
the second one?" Resist supplying `tr -s`; exercise 27 gives it to them one step later.

**The ragged file** (ex. 25–26). Some students will not spot the bad line because it reads like a
value. If they report "works fine", ask them to diff it against exercise 24's output, or just: "read
line 3 out loud and tell me what column it is supposed to be." Then spend a real minute on exercise
26 — an error you cannot ignore is better than a string you can.

**Exercise 49** is the one worth protecting. The naive command returns fourteen names, which is
obviously wrong, and the student's instinct is to assume they typed something incorrectly. Ask: "look
at the fourteen. Do you see any name twice?" They will see `Rhea` and `rhea`. Do not give them
`tr 'A-Z' 'a-z'`; ask what would have to be true of the two lists for the comparison to be
meaningful. If they get to "the two files spell the same thing differently", they have the whole
lesson.

**Exercise 45** stumps students who want to strip the leading spaces from the counts and find nothing
in this lesson can do it. That is correct. Tell them the padding stays for now and ask which lesson
they think will fix it.

**Exercise 52** is not a Unix question and students skip it. Do not let them. Make them write the
three unspecified things down in a file. It is asked again in lesson 07 and in the incident, and a
student who has the answer already will find the finale much easier than one who does not.

## Never say

- Any of the counts: 412, 96, 54, 21, 12, 4, 1; 300/150/150; 150 per deck; 600.
- That the answer to exercise 49 is fourteen, or that it collapses to zero once folded.
- The words "`tr -s`" before exercise 27, or "`sed`" at all.
- The character positions `11-20`, `1-7`, `9-`, or `12-19`.
- Which two rows of `ragged.txt` are misaligned.
- Anything about the chapter's incident. If asked whether `maintenance` appearing once is
  significant: it is practice data, and no.

## If a student is far ahead

Give them exercise 55 and then this: "you have a tab-separated file where exactly one value contains
a tab. What in this lesson detects that, and what does it do instead?" (Nothing detects it; the row
gains a column and everything to its right shifts. Same failure as the CSV, no quoting to blame.)
