# 08/02 — Tutor guide: redirection

Read `docs/TUTOR_PROTOCOL.md`. Guide with questions. Never state which entry in `notes/wrong.txt` is
the correct one, and never hand over the assignment trace — make them write it.

## What the lesson is actually for

One idea: **a redirection is an assignment to the fd table, and several of them happen left to
right, before the program runs.** Everything else in the lesson is a consequence:

- `> f 2>&1` vs `2>&1 > f` — consequence of order.
- `sort f > f` — consequence of "before the program runs".
- `> f 2> f` clobbering itself — consequence of two independent opens.
- `>` vs `>>` — consequence of a flag at open time.

A student who has memorised the two forms but cannot trace a third one has not learned it. The test
is exercise 52 (`> o1 2>&1 > o2 2> o3`), which nobody has memorised.

## The single best question in this lesson

> "What was fd 1 pointing at *at the moment* that `2>&1` ran?"

Ask it every time. It resolves exercises 4, 5, 17, 18, 25, 42 and 52 without you saying anything
else.

## Where students stall

**Exercise 5 (`>/dev/null 2>&1 | wc -l` prints 0).** They believe stderr "went to stdout" and
stdout "went to null", so stderr should survive. Ask what `2>&1` copied. Do not explain; ask.

**Exercise 21 (`> s.txt 2> s.txt`).** Genuinely surprising. Let them look at the mangled line
themselves — `els, 3 banks` is more convincing than any explanation. Then ask: *how many times was
that file opened?*

**Exercise 28 (`sort f > f`).** Some students will not believe it until they do it. Good — that is
why the exercise says to copy first. Afterwards, ask *when* the truncation happened, and keep asking
until the answer is "before sort started".

**Exercise 30.** Most predict a hang or an infinite file. It gives 40 lines. If they predicted wrong,
that is the exercise working; ask what `sort` has to do before it can emit its first line.

**Exercise 39–41 (the shift board).** Students race to run them. Insist on written predictions
first; a student who runs first has converted a comprehension exercise into a typing exercise. If
they ask which entry is not a mistake, ask them which one they would have written on purpose.

**Exercise 35 (who produced the error).** Many answer "wc" confidently. Ask them what the message
was prefixed with, and then whether `wc` ever ran.

## Common wrong models to catch

- "`2>&1` merges the streams." Ask what a merge would mean for two descriptors.
- "`>` overwrites." Ask what happens to a 100-line file when you write 3 lines to it with `>`.
- "Redirecting hides the failure." Exercise 16 disproves it; make them run it.
- "`noclobber` makes redirection safe." Ask about `>>` and about the next machine they log into.

## Never say

- The values 12 and 5 before exercises 2 and 3.
- Which entry in `notes/wrong.txt` is correct (C), or that A writes two useful files.
- The answer to rhea's page (`>` should be `>>`) — exercise 12 is a one-character diagnosis and
  handing it over removes the only diagnostic moment in the lesson.
- Anything about `/var/tmp`, recycled paths, or the chapter's incident. Exercise 57 is deliberately
  left as an unanswered hypothetical.
