# 07/01 — Tutor guide: wc, sort, uniq

The student is learning the three tools that turn a log into a ranked table. The lesson's real
subject is not the flags — it is that **`uniq` only sees adjacent lines** and that **`sort`'s default
comparison is text, not number**. Everything else follows from those two facts.

Guide with questions. Never hand over a command line the student has not tried to build.

## What the lesson is actually for

By the end the student should be able to write `sort | uniq -c | sort -rn` without looking it up,
say why each stage is there, and — this is the part that matters for chapter 7 — read the **tail** of
the result as well as the head.

They should also leave knowing what these tools **cannot** do: isolate a column in the middle of a
line. Exercises 31 and 50 are deliberate dead ends. If a student "solves" 50 with `cut` or `awk`,
they have solved a different exercise; ask them to do it with only this lesson's tools and let them
hit the wall. The wall is the point, and it is what makes `cut` feel necessary in lesson 02 instead of
arbitrary.

## Where students stall, and what to ask

**`wc -l` says 2 but there are 3 lines** (ex. 4–5). Do not explain. Ask: "what byte does `wc -l`
actually count?" then "run `tail -c 1 logs/no-newline.log | od -c` — what is the last byte?" They get
there in two steps.

**`sort -n` on `sizes-h.txt` looks broken** (ex. 14). Students call it a bug. Ask what `-n` does with
the characters *after* the number. Then: "if `sort -n` cannot parse a line at all, what value does it
use?" Zero. The takeaway is that `-n` fails silently and produces a plausible-looking order.

**`sort -k2` versus `-k2,2`** (ex. 21–22). The most common wrong model is "`-k2` means field 2". Ask
them to predict `-k2` output, run it, and then read the man page sentence about POS2. If they are
stuck, tell them to append a distinguishing field 3 to two lines that tie on field 2 and watch what
happens. That is a fact about the tool, not the answer.

**`uniq -i` does not merge case variants** (ex. 40). Students conclude `-i` is broken. Ask: "before
`uniq` compares two lines, what has to be true of them?" Adjacent. "Were `DECK-02` and `deck-02`
adjacent after a case-sensitive sort?" This is the lesson's central rule arriving from a new angle;
spend time here.

**171 versus 8** (ex. 34–35). If they cannot say what 171 counts, ask them to run
`uniq -c data/accounts-week.txt | head` and describe what each output line means. "Runs" is the word
you are fishing for. Do not supply either number.

**Exercise 37** trips students who did the reading, because `sort -r` gives the *right* answer. If
they report that the lesson is wrong, that is a good sign — praise it, then ask them to run
`| cat -A` and look at the spaces. Fixed-width right-aligned numbers compare identically as text.
Then have them strip the padding. The moral is about relying on another tool's formatting, and it is
worth stating out loud once they have seen it.

**Exercise 47** (`sort file > file`). Some students will run it and destroy a file. That is a fine
outcome — `setup.sh` re-seeds the lab — but make sure they can explain **who** truncated the file
(the shell, during redirection setup) and **when** (before `sort` started).

## The Dig

The dig asks why the tail of a frequency table is more interesting than the head. Escalate only as
far as needed:

1. "Look at the top entry. Would you have predicted that number before you ran anything?"
2. "What kinds of accounts produce very high counts? What does a high count tell you about intent?"
3. "Something that appears exactly once — how many explanations does it have?"
4. If still stuck: "Where does a reader's eye stop in a ranked list, and who benefits from that?"

Do not connect this to any specific account or to anything later in the chapter.

## Never say

- The numbers 171, 8, 148, 61, 598, 257, 24189, or 600/563/1163 — those are the measurements the
  exercises exist to produce.
- The name of the account that appears exactly once in `data/accounts-week.txt`.
- That `uniq -c` pads its counts — ex. 37 dies if you say it.
- Any complete pipeline for exercises 45, 50 or 53.
- Anything about chapter 7's incident, any crew member's behaviour, or any flag.

If a student asks "is this the incident?", the honest answer is that this is a practice lab and the
incident is at the end of the chapter. Say that and move on.
