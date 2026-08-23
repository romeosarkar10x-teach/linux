# 05/03 — Validation (agent eyes only)

> For the validator agent. Read `solutions.md` for the measured answers. This file says what
> *counts as understanding* rather than what the outputs are.

## The one thing that must be true

The student must be able to say **which layer a character is dangerous to**. A `*` is dangerous to
the shell, a leading `-` is dangerous to the command, and a `$` is dangerous only to the shell and
only when unquoted. Quoting is the tool for exactly one of those layers.

If they leave believing "quote everything and you are safe", they have half the lesson and will be
bitten by `-report.txt`. If they leave believing "quoting does not really help", they have none of
it. The correct summary is: **quoting decides what the shell does with text; it says nothing about
how the command reads its own arguments.**

## Must be able to do

1. State what each of the three quoting forms suppresses, without notes. Single: everything. Double:
   globbing, word splitting, brace expansion, tilde — but not `$`, `` ` ``, `\`, `!`. Backslash: the
   next character only.
2. Produce a string containing a literal single quote, from a single-quoted start
   (`'it'\''s'`) — exercises 3 and 56.
3. Handle every name in `names/` — read it, copy it, delete it. In particular `-report.txt` via
   `--` or `./`, and the tab name via `Ctrl-V Tab` or `$'…'`.
4. Explain why `ls`, `ls -b` and `find -printf .` give 11, 10 and 10 for the same directory, and
   name a counting method they would trust in a script.
5. Explain exercise 51: `f='*.txt'; echo $f` globs. Parameter expansion runs before pathname
   expansion, so an unquoted variable's *contents* are globbed after substitution.
6. Fix `report.sh` and say which of the three bugs `echo` hides.
7. Diagnose the `grep "$SPEC_DIR"` case (exercise 29) as the most dangerous of the three, because it
   *succeeds*.

## Should be able to do

- Distinguish the shell's `*` from grep's `*` (exercise 34) in one sentence each.
- Say why `find . -name *.txt` works in an empty directory and fails in a full one.
- Find the fourth, non-quoting bug in `backup.sh` — `$f` is a path, not a basename.

## Common wrong answers

| What they say | What is actually true |
|---|---|
| "Quoting `-report.txt` fixes it." | The shell strips the quotes before `ls` runs. `ls "-report.txt"` fails identically. Needs `--` or `./`. This is the single most important correction in the lesson. |
| "Single and double quotes are basically the same." | Ask them to print `$HOME` literally. Then ask them to print the *value* of `$HOME` with a glob character next to it. |
| "`ls \| wc -l` counts the files." | Push them to `names/`. Eleven lines, ten files. |
| "The `for f in $DIR/*.txt` glob is fine, globs do not word split." | Glob **results** are not split, but `$DIR` is expanded and split *before* the glob is formed. Both quoted forms are needed for different reasons. |
| "`report.sh` has one bug" (the `*`). | Three. `$NAME` and `$MSG` are broken too; `echo` rejoins the words and hides `$NAME`. |
| "Command substitution is safe because I quoted inside it." | Exercise 49. The quoting inside applies inside; the result lands unquoted on the outer line and is globbed there. |

## Red flags

- Fixing `DIR=$1` to `DIR="$1"` and calling that the quoting bug. Harmless, but it means they are
  pattern-matching on `$` rather than reasoning about word splitting.
- Using `rm -f` anywhere to get past `-report.txt`. `-f` does not help and they should be able to say
  why (it suppresses prompts and missing-file errors, not argument parsing).
- Reporting a count from `ls | wc -l` after exercise 13.
- Any claim about who chose the sweep patterns. `comms.log` names rhea and cass; nothing attributes
  the pattern list to anyone, and the validator must not either.

## Sign-off question

> There is a file in `names/` you cannot delete with `rm *.txt`, and because of it none of the other
> nine get deleted either. Which file, and at which layer does it stop the command — the shell's or
> `rm`'s?

A pass names `-report.txt`, says the **glob matched it fine** and it was `rm` that refused, and can
give a working deletion. The word *option* — or a description of `rm` reading the name as an option
bundle — must appear. "It has a special character in it" is a fail: it does not.
