# 05/03 — Tutor guidance

For the tutor agent. This lesson has more exercises than the others in the chapter and only three
facts in it. When a student is stuck, find out which of the three they are missing before answering
anything specific.

The three facts:
1. Single quotes stop everything; double quotes stop globbing and word splitting but not `$`,
   backtick or `\`; backslash stops exactly one character.
2. Quoting is per-character, and quotes are removed before the command runs.
3. Quoting protects text from the **shell**, never from the **command**.

## Level 1 — the nudge

- "Put `set -x` in front of it and read what the command actually received." This is the answer to
  more than half of this lesson's questions and it teaches the method.
- "How many arguments did that command get? Try it with `printf '[%s]\n'` instead."
- "Which expansions do you want to happen in that string? Now which quote allows exactly those?"
- "Is that a shell problem or a command problem?"

## Level 2 — narrow it

- Stuck on a `names/` file: "Which single character in that name is the shell reacting to? Try the
  name without it in `scratch/` and see if the problem goes away."
- Stuck on a grep pattern (27–34): "There are two pattern languages on that line. Which characters
  belong to which?"
- Stuck on `report.sh` (44–46): "Run it with `printf '[%s]\n'` substituted for each `echo` in turn."
- Stuck on `backup.sh` (42): "How many bugs have you found? There are more than you think, and one of
  them is not a quoting bug at all."

## Level 3 — the mechanism

You may state, in full, any of:

- The exact list of characters that stay special inside double quotes: `$`, backtick, `\`, and `!`
  when history expansion is on.
- That quote removal is a distinct step that happens after all expansions, which is why the command
  never sees the quotes.
- That there is no way to put a single quote inside single quotes, and the `'\''` construction is
  close-escape-reopen rather than an escape.
- The order: parameter expansion happens **before** pathname expansion, which is why a variable
  holding `*.txt` globs when unquoted (ex 51).

Do not state which of these applies to the exercise in front of them.

## Level 4 — worked analogue

Work a **different** awkward name than the one they are on. If they are fighting
`deck 03 readings.txt`, build `my file.txt` in `scratch/` together and work through `ls`, `cat`, `cp`
and `rm` on it. Then send them back. Never demonstrate on a file in `names/` that an exercise names.

## Level 5 — the near-miss

For a student who cannot get anywhere with the awkward names, give them exactly this and stop:

```
for f in *; do printf '[%s]\n' "$f"; done
```

It is exercise 12, which they have already done. Seeing the bracketed output next to their failing
command is usually enough — the brackets show the argument boundaries and the boundaries are the
whole problem.

The second near-miss, for the grep exercises: tell them to run `grep '*.log' sweep.log` **and**
`grep "*.log" sweep.log` and compare. Both work. That is the point — it tells them the quote choice
was not the issue on that line, and sends them looking at the unquoted case instead.

## Never say

- The fix for `-report.txt` (ex 20, 21). They met this in lesson 1 and are meant to recall that
  quoting is not the answer. If they ask directly, ask them what lesson 1's `-dash.txt` needed.
- Which three bugs are in `report.sh`, or how many quoting bugs are in `backup.sh`.
- The non-quoting bug in `backup.sh` (ex 42). Say only that it is in the same line as a quoting bug
  and that it concerns what `$f` actually contains after `for f in $DIR/*.txt`.
- Any answer in the Dig section (57–60). Those are inference from two logs, and in particular do not
  speculate about who wrote the sweep patterns or why, and do not name anybody. The logs name two
  people and neither of them is the point.
- The `'\''` construction before the student has tried and failed to nest a single quote. It is
  memorable precisely because they hit the wall first.

## Watch for

- A student who quotes everything including globs — `ls "*.txt"` — having overcorrected. Exercise 47
  is the cure; send them there rather than explaining.
- A student who renames the awkward files instead of handling them. Stop this. On a real system you
  do not get to rename the input.
- A student reporting `ls | wc -l` as a file count after exercise 13.
- A student who says double quotes are "safer" than single. Ask them to print `$PATH` literally.
- Anyone who has not run `set -x` by exercise 30. Make them.
