# 05/04 — Word Splitting

> The shell takes a line of text and decides where the arguments are. You do not get a vote unless
> you quote. This is the lesson where `"$var"` stops being superstition.

## What this lesson is

Lesson 3 told you to quote every expansion and showed you what breaks when you do not. This lesson
is the mechanism underneath: **word splitting**, the step where the shell chops the result of an
expansion into separate arguments.

It runs after parameter expansion, command substitution and arithmetic expansion, and before
pathname expansion. That ordering is the whole subject. A variable's *value* is one string. What
the command receives may be one argument or nine, and the difference is a pair of quotes.

## IFS

`IFS` — the Internal Field Separator — is a variable holding the characters the shell splits on. Its
default value is space, tab, newline. You can see it: `printf '%q\n' "$IFS"` prints `$' \t\n'`.

Two rules, and the second one catches everybody:

- **Whitespace characters in `IFS` collapse.** `a   b` splits into two words, not four. Runs of
  space/tab/newline are one separator, and leading and trailing runs are discarded.
- **Non-whitespace characters in `IFS` do not collapse.** With `IFS=:`, the string `a:::b` splits
  into **four** fields — `a`, empty, empty, `b`. Two adjacent colons mean an empty field, which is
  exactly what you want for a CSV and exactly what surprises you the first time.

Set `IFS` to the empty string and splitting is turned off entirely. Unset it and the shell behaves
as if it held the default.

## What splitting does and does not touch

Splitting happens to **unquoted expansions**. It does not happen to:

- literal text you typed (`echo a   b` prints one space, but only because `echo` rejoins — the
  splitting did happen);
- the right-hand side of an assignment: `w=$v` copies the whole string, no quotes needed;
- inside `[[ ]]`, `case`, or `$(( ))` — none of them split;
- the results of pathname expansion. A glob that matches `bay 03` produces one word.

The classic failure is `[ $v = 'a b' ]`, which becomes `[ a b = a b ]` and dies with
`[: too many arguments`, exit 2. With `$v` unset it becomes `[ = x ]` and dies differently:
`[: =: unary operator expected`. `[ "$v" = x ]` is correct and returns a real answer.

## `"$@"` is not `$@`

Inside a script, `"$@"` expands to one argument per original argument, with the boundaries intact.
Everything else in that family is a trap:

| form | given `'a b'` and `c` |
|---|---|
| `"$@"` | 2 arguments: `a b`, `c` |
| `$@` | 3 arguments — split |
| `"$*"` | 1 argument: `a b c`, joined by the first character of `IFS` |
| `$*` | 3 arguments — split |

`"$@"` is the only one that passes your arguments through unchanged. Write it with the quotes,
always, and do not think about it again.

## Reading files line by line

`for f in $(cat list.txt)` is wrong and it is wrong in two ways at once: it splits every line into
words, and then it globs the pieces. On this lab's `data/paths.txt` — five lines — it produces
**nine** iterations.

The correct shape is:

```
while IFS= read -r line; do
    …
done < list.txt
```

Three parts, each doing a separate job. `IFS=` for this command only turns off splitting, so leading
and trailing whitespace survives. `-r` stops `read` from treating backslash as an escape — without
it a line ending in `\` silently swallows the next line. And the redirect at the `done` feeds the
loop without a subshell.

## The shape of the lab

`data/` holds `crew.csv` (colon-separated), `paths.txt` (five paths, two containing spaces),
`bad-line.txt` (a trailing backslash, a real tab, leading spaces) and `spaced.txt` (every awkward
whitespace arrangement). `bays/` has eight directories, three of which have spaces in their names.
`scripts/` holds `count.sh` — your measuring instrument, it prints its argument count and each
argument in brackets — plus `deploy.sh` and `tally.sh`, both broken. `scratch/` is yours.

## Rules of engagement

Use `count.sh`. Every question of the form "how many arguments is that" has an experimental answer
and guessing is a waste of your time. `set -x` is the other instrument: it prints the command
**after** expansion, with quotes showing you where the argument boundaries fell.

## What "solved" looks like

You can predict the argument count for any of the four `$@`/`$*` forms without running them. You can
read a colon-separated file into fields correctly, including an empty field. You can say why
`IFS= read -r` has three separate pieces and what breaks when each is missing. And you have seen a
loop over `$(cat file)` produce more iterations than the file has lines.

## Before you move on

Next is the incident, and it is the chapter's CTF. Everything from all four lessons is on the table
and the names are hostile on purpose.
