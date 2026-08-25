# 06/01 — Validation: `grep` Basics

You are validating a cadet's work on the first `grep` lesson. Judge understanding, not transcript
completeness. There is no grading script and there never will be; you are the rubric.

## The one thing that must be true

**The student can say, without running anything, what `grep` will treat as the pattern and what it
will treat as a file — and they check `$?` before they believe an empty result.**

Everything else in this lesson is detail. A student who reads a `grep` command left to right, finds
the first non-flag word, and calls it the pattern has the skill the rest of the chapter is built on.
A student who reports "no errors in the log" without having looked at the exit status does not,
however many exercises they completed.

## Must have done

1. **Named the three exit statuses and what each means** (0 matched, 1 did not match, 2 error), and
   shown they know 1 and 2 are different — exercises 5, 6, 25.
2. **Explained exercise 7** — that `grep comms ERROR file` is a search for `comms` in two files —
   and given at least one correct rewrite.
3. **Explained `-F` in terms of what it switches off**, using either the `0.06` or the
   `deck-0[13]` case, and said which count answers the question that was actually asked.
4. **Handled the leading dash** (exercise 12/13) with `-e` or `--`, and said why the terminal
   appeared to hang.
5. **Quoted the binary-file message** and located it on stderr, not stdout (exercises 20, 26, 38).
6. **Explained the multi-file filename prefix** as something `grep` adds when given more than one
   file — and connected it to exercise 19, where redirection removes it.
7. **Reported that the empty pattern matches everything** (exercise 31 or 32) and said why a blank
   line in a pattern file is dangerous rather than harmless.

## Should have done

- Noticed that `-i` gives 60 and had an opinion, with numbers, about whether that is the right
  number to report (exercise 3).
- Built the exercise-38 file and shown the no-final-newline guess failing first.
- Said clearly which half of exercise 51's claim `grep` cannot check, and why.

## Common wrong answers

- **"`grep` returns true or false."** Two statuses, not three. Push on the missing file.
- **"`-F` makes `grep` faster."** It does, marginally, but that is not what it is for and not what
  the exercises measure (exercise 41 exists to kill this).
- **"`.` matches a dot."** In a glob it does; in a regex it does not. This confusion is the single
  biggest predictor of trouble in lesson 03.
- **"The count and `wc -l` always agree."** They agree on text; exercise 38 is the counter-example.
- **"`grep -c ''` is `wc -l`."** Close enough to be dangerous; they differ on a file with no final
  newline. A student who says "the same, roughly" should be asked what "roughly" is hiding.
- **"`grep -r` found 22 lines with `-I` and 22 without, so `-I` does nothing."** `-I` removes the
  stderr notice, not lines. Half-credit; ask where the message went.
- **"Exercise 46: `Panel 0*3` is wrong."** It is right. If they say it is wrong, they have read `*`
  as a glob. This is the diagnostic question of the whole lesson — do not let it pass.

## Red flags

- Answers with numbers that do not match the seeded lab (20/20/20, 60, 80, 240, 16, 44). Either the
  lab was modified or the answers were guessed. Ask them to re-run one in front of you.
- Any claim about *who* wrote the overnight report of exercise 47, or where it is. The lab does not
  say and the student cannot know yet.
- Certainty about `$`, `^`, `\?` or `.*` beyond what exercises 43–46 forced them to guess. Those
  belong to lesson 03; a confident wrong model now is worse than an admitted gap.

## Sign-off question

> Here is a script line: `if grep -q "$pat" "$file"; then alert; fi`. Name three separate ways this
> can silently do the wrong thing, and give the fix for each.

A student who is ready gives: (1) `$file` missing or unreadable — status 2 is not 1, so no alert
fires and no one is told the log is gone; capture `$?` and branch on all three. (2) `$pat` is empty
or comes from a file with a blank line — the empty pattern matches every line, so the alert always
fires; guard the pattern, and pass it with `-e "$pat"`. (3) `$pat` begins with a dash or contains a
regex metacharacter — `grep` reads it as an option, or as a pattern that is broader than intended;
`-e` fixes the first, `-F` the second, and which one you want depends on whether the caller was
supposed to be able to write a regex at all.
