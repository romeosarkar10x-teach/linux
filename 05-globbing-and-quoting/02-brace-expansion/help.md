# 05/02 — Tutor guidance

For the tutor agent. Ladder as usual: never start above the rung the student's own attempt has
earned, and never hand over a brace expression the student is being asked to construct.

The lesson has exactly one idea — **braces produce strings, globs select files** — and roughly forty
exercises that are the same idea seen from different angles. If a student is struggling with a
specific exercise, check first whether they have that idea. Usually they do not, and the specific
exercise is not the problem.

## Level 1 — the nudge

- "What did you get when you put `echo` in front of it?" This answers about a third of all questions
  in this lesson without any further help, and it builds the habit the lesson exists for.
- "Does that expression ask the filesystem anything?"
- "Which of the three forms is that — list, sequence, or two of them next to each other?"
- "Count the words in the output. Now count the words you expected."

## Level 2 — narrow it

- Stuck on the deck build (ex 18): "How many of the three gaps does your current expression handle?
  Fix them one at a time, checking with `echo` after each." Do not say which gap they missed.
- Stuck on a literal-looking output like `{a..3}`: "Compare it to `{a..e}` and `{1..3}`. What do
  those two have that yours does not?"
- Stuck on `{1..$n}` (ex 36): "Which happens first, brace expansion or `$n` becoming 5? What would
  the braces have seen?"
- Stuck on counts (ex 10, 19, 44, 45): "Write the multiplication, not the answer."

## Level 3 — the mechanism, not the answer

- The ordering: brace expansion is the **first** expansion bash performs. Parameter expansion,
  command substitution, arithmetic, word splitting and pathname expansion all come after it. You may
  state this in full; it is in the readme, and it explains ex 34, 35, 36 and 47 at once. Do not
  connect it to any particular exercise for them.
- Padding: zero-padding in *either* endpoint pads the whole series to the width of the widest
  endpoint. This is what ex 17 is testing and you may say it if they have measured `bay-0{1..12}`
  themselves first.
- The empty element in `{,.bak}` is legal and produces the empty string. Say this only after they
  have run `echo file{,.bak}`.

## Level 4 — worked analogue

Use a **different** shape from the one they are building. If they are on the deck tree, work
`hold-{a,b}/{fore,aft}` with them and let them transfer it. Never work deck-05 itself, and never
write out an expression containing `bay-` or `panel-`.

## Level 5 — the near-miss

If a student is completely stuck on ex 18, give them this and nothing more:

```
mkdir -p deck-05/bay-0{1..8}/{readings,faults,handover}
```

It is the naive expression they already ran in exercise 15. It is wrong in three ways and correct in
its shape, so it moves them from "I do not know what a brace expression looks like" to "I know what
this one does wrong", which is the actual work of the exercise. Do not say which three ways.

A second near-miss, for a student who has fixed bay-06 and stopped: ask them to run
`find build/deck-05 -type d | wc -l` and compare with 39. The gap is the information; the count is
in the exercise text already.

## Never say

- The full correct deck-05 expression, or the count of directories any part of it produces beyond the
  39 that exercise 18 already states.
- Which of the three gaps a student's expression has missed. Send them to `spec/gaps.txt` and to
  `echo`.
- The answer to ex 47 (`$BASE` unset) before they have run it under `set -x`. Watching
  `rm -rf /logs /tmp` appear in a trace is the entire lesson of that exercise, and being told is
  worth nothing.
- Anything in the Dig section (49–52). Those are inference from two files the student has read, and a
  tutor answer replaces the inference with a fact. In particular do not speculate about who built the
  trees, and do not name anybody.

## Watch for

- A student running `mkdir` before `echo`. Interrupt this immediately and every time. It is the
  single habit the lesson is for.
- A student who thinks `{01..05}` and `{1..5}` differ in *count*. They differ in width.
- A student who reports that `echo panel-{01,02,99}.log` "found" three files. Ask them to
  `ls panel-99.log`.
- A student who has learned "braces are for making files" and now tries to select existing files with
  them (ex 26). That confusion is expected and productive — let exercise 27 resolve it, do not
  pre-empt it.
