# 05/02 — Validation rubric

For the validating agent. No auto-grader. Ask for commands and output together; in this lesson an
answer without the command behind it is worthless, because almost every wrong brace expression
produces plausible-looking output.

## The one thing that must be true

The student must be able to say that **a brace expression consults nothing**. It is string
arithmetic performed before any command runs and before the filesystem is touched, and it produces
names that exist and names that do not with equal confidence.

Test it: "What does `echo panel-{01,02,99}.log` print in `01-globs/panels`, and how many of those
files exist?" Three names, two files. A student who says the shell "found" three has not got it, and
no amount of correct deck-building compensates.

## Must be able to do

1. **Build the deck-05 tree in one command** (ex 18), producing 39 directories with all three gaps
   honoured, and **explain the count as a sum** (ex 19).
2. **Read `{,.bak}` on sight** and write out the command it expands to (ex 29), including that it
   overwrites an existing backup silently (ex 31).
3. **State the ordering rule**: brace expansion is the first expansion, before parameter expansion
   and before globbing. And use it to explain `echo {1..$n}` printing `{1..$n}` (ex 36) and
   `rm -rf $BASE/{logs,tmp}` becoming `rm -rf /logs /tmp` (ex 47).
4. **Distinguish brace from glob** in one sentence using *string* and *filesystem* (ex 28), and show
   the difference on the same paths (ex 26 vs 27).
5. **Get padding right**: `{01..12}` not `0{1..12}` (ex 17), and say why padding matters for sorting
   (ex 42).
6. **Recognise a non-expansion**: name at least three of the five forms in exercise 13 and say why
   each is left literal.

## Should be able to do

- Predict combination counts by multiplication rather than by running the command (ex 10, 44, 45).
- Say why `panel-{03,05,09}` cannot be written as a sequence (ex 21, 49).
- Give a reason `eval` is last in the ranking at exercise 37.

## Common wrong answers, and what each one means

- **"`{01..05}` gives five numbers and `{1..5}` gives five numbers, so they are the same."** Ask for
  `ls` of a directory containing both `run-1` and `run-001` (ex 41 makes twenty directories for
  exactly this reason).
- **"`bay-0{1..12}` is fine."** Have them run it. `bay-010` is the answer.
- **"Quoting fixes `rm -rf $BASE/{logs,tmp}`."** It does not — measured, `"$B"/{logs,tmp}` still
  produces `/logs /tmp`. Require `${BASE:?}` or `set -u`. This is the most common confidently-wrong
  answer in the lesson.
- **"`cp panel-{09,11}.cfg{,.bak}` backs both up."** It expands to four words and `cp` reads the last
  as a destination directory. Exit 1, nothing copied. Make them run it.
- **"The empty combination in `{a,}{b,}` is an empty argument."** No — it is removed before the
  command sees it. `set -- {a,}{b,}; echo $#` gives 3.
- **"Braces are POSIX."** `dash -c 'echo a{b,c}d'` prints `a{b,c}d`.

## Red flags

- Any `mkdir` run without an `echo` dry run first. This is the habit the lesson exists to build, and
  a student who has not built it has failed the lesson regardless of their answers.
- A student who fixed bay-06 and stopped, reporting success with 34 or 37 directories. Ask for the
  count.
- Claims about bash behaviour not measured in this container.

## Sign-off question

> Write one command that would create a file named for a panel that does not exist on this station,
> without typing that panel's number and without using a wildcard. Then say what you would look at,
> on a real filesystem, to tell such a file apart from one that had always been there.

The first half tests that they can produce non-existent names deliberately — the lesson's core idea
turned around. The second half wants `stat`: mtime shared to the second with its siblings, and a
neighbouring inode number. A student who says "you couldn't tell" has not understood that bulk
creation leaves a signature.
