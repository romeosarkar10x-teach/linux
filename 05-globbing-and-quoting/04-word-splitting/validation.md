# 05/04 — Validation (agent eyes only)

> For the validator agent. `solutions.md` has the measured answers; this file says what counts as
> understanding.

## The one thing that must be true

The student must be able to describe word splitting as a **step in a sequence**: substitute, split,
glob. Not "quotes are safer" — a position in an ordering. If they have that, every result in the
lesson is derivable; if they do not, they have memorised a list of idioms that will fail them the
first time the data is shaped differently.

The second non-negotiable is the `IFS` rule: whitespace separators collapse, non-whitespace
separators do not. It is one rule, it explains both `a   b` → 2 and `a:::b` → 4, and a student who
states it as two unrelated facts has not got it.

## Must be able to do

1. Predict the four `$@`/`$*` counts for `'a b' c` — 2, 3, 1, 3 — and say why `"$@"` is the only
   correct form.
2. State the `IFS` collapsing rule in one sentence and apply it to both directions.
3. Write `while IFS= read -r line; do … done < file` from memory and say what each of the three
   parts protects against — whitespace stripping, backslash escapes, and the subshell.
4. Explain the difference between an empty argument and no argument (exercise 35), and connect it to
   why `[ $e = x ]` fails with `unary operator expected`.
5. Say why `[[ $v = 'a b' ]]` works and `[ $v = 'a b' ]` does not: `[[ ]]` is syntax parsed before
   expansion, `[` is a command receiving already-split arguments.
6. Fix `tally.sh` (`$*` → `"$@"`) and `deploy.sh` (`IFS= read -r`, quote both expansions, `--`), and
   verify by argument count rather than by the output looking right.
7. Name at least three contexts where splitting does not happen: `[[ ]]`, `case`, `$(( ))`,
   assignment RHS, glob results.

## Should be able to do

- Explain why `for p in $(cat paths.txt)` gives 9 for a 5-line file, arithmetically.
- Say what `-print0`/`-d ''` buys and why NUL specifically.
- Handle the no-final-newline case (exercise 56).
- Notice that `IFS=$'\t'` does not give TSV semantics, because tab is still whitespace.

## Common wrong answers

| What they say | What is actually true |
|---|---|
| "`$@` and `"$@"` are the same, the quotes are style." | 3 versus 2. Make them run it. This is the commonest and the most damaging. |
| "`IFS=` and `unset IFS` do the same thing." | Opposite. Empty disables splitting; unset restores the default. |
| "Quote the variable and the loop is safe." | Not if a path starts with a dash — that is `cp`'s parsing, not the shell's. Lesson 3's point, re-run. |
| "`read -r` preserves leading whitespace." | `-r` is about backslashes. `IFS=` is what preserves whitespace. They are independent and students routinely swap them. |
| "The trailing empty field is kept." | `a:b:` gives 2, not 3. Interior empties are kept, trailing ones are not. |
| "`echo` proved the spacing was preserved." | `echo` rejoins with one space and hides everything. Push them to `printf '[%s]\n'`. |
| "`wc -w` and `set -- $(cat f); echo $#` always agree." | They agree on `spaced.txt` by coincidence — no glob characters in it. |

## Red flags

- Any use of `cat file | while read` after exercise 19 without noticing the subshell.
- Fixing `deploy.sh` by adding `IFS=$'\n'` at the top of the script rather than `IFS=` on the
  `read`. It appears to work and leaks into everything after it — see exercise 54.
- Claiming `set -x` output shows the pre-expansion command. It shows post-expansion, requoted.
- Any statement about who wrote `deploy.sh` or `paths.txt`. The lab does not say and the validator
  must not either.

## Sign-off question

> `v='* x'` in a directory containing two files. `bash scripts/count.sh $v` gives three arguments,
> `bash scripts/count.sh "$v"` gives one. Walk me through the two expansions in order, naming each
> step.

A pass names **parameter expansion** first (producing the string `* x`), then **word splitting**
(two words, `*` and `x`), then **pathname expansion** applied to each word (the `*` becoming the
file list). For the quoted case they must say that the quotes suppress steps two and three, and that
a quoted word is never globbed. A student who gets the right numbers but describes globbing as
happening first has failed the sign-off, however confident they sound.
