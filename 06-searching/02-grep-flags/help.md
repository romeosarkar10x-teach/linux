# 06/02 — Tutor Notes: `grep` Flags

The student has lesson 01: pattern, file, exit status, quoting. This lesson adds fifteen flags. The
risk is memorisation without a model — a cadet who can recite `-L` but cannot say which of the three
questions it answers will misuse it within a week.

**Never give a command that answers an exercise.** Ask for the question first, the flag second.

## Three facts to hold

1. Every flag answers one of three questions: **what matches** (`-i -w -x -v -F`), **what you see**
   (`-n -c -o -l -L -h -H -A -B -C`), **where it looks** (`-r --include --exclude --exclude-dir -I`).
   Getting a student to sort a flag into a bucket is worth more than any explanation.
2. `-c` counts **lines**, always, no matter what else is on the command line. It beats `-o`. It
   ignores context.
3. Context output contains lines `grep` invented: `--` separators, and `-` instead of `:` on
   context lines under `-n`. Any pipeline that counts context output must account for them.

## Rungs

1. **"Why is `-lv` not `-L`?"** — "Read `-l` out loud: which files have a matching line? Now with
   `-v`, what is a matching line?"
2. **"The context output has the wrong number of lines."** — "Run it again with `-n`. Now read the
   line numbers. Are any two blocks touching?"
3. **"`-o` and `-c` disagree."** — "Write down the two questions in English. Which one did you ask?"
4. **"`-r` found things I did not want."** — "Was it the wrong kind of file, or the wrong place in
   the tree? There is a different flag for each."
5. **"`-w` did not do what I expected."** — "Which characters are on either side of the match? Is a
   dash a letter?"

## Level-5 near-miss

A strong student will nail the merged context blocks in exercise 26 and then over-fit: they conclude
that `-A2` output is always `matches × 3 − overlaps + separators` and start computing it. It is not
a formula worth carrying — the counts depend on how the blocks fall. Push them to `-n` and reading,
not to arithmetic. If they insist on the formula, give them exercise 28.

## Never say

- Never name a flag the student has not described the behaviour of first.
- Never say which two files exercise 31 turns up beyond the reports, and never say why `notes.txt`
  matched — exercise 32 is the whole point of exercise 31.
- Never say that `-c` beats `-o` (exercise 45) or that the last of `-l`/`-L` wins (exercise 50).
  Both are "run it and report".
- Never say where the `--` separator comes from (exercises 24, 25).
- Never explain why the deck-04 half of exercise 55 cannot be verified. If they are stuck: "how many
  fault lines does deck-04 have?"
- Never say whether the two entry-007 faults in exercise 56 are the same fault. Nobody knows, the lab
  does not say, and a student who is told will stop distinguishing evidence from conclusion.
- Never confirm or deny anything about who normalised the case in `archive/`. It is not in the lab.
