# 12/06 — validation

For the AI tutor. No scripts, no auto-grading.

## What the student must be able to do

- Use `read` with `-r`, `-p`, an `IFS=` prefix and several names, and state the
  last-variable-gets-the-rest rule.
- Validate input before doing arithmetic on it, and say why that is a security
  matter and not only a correctness one.
- State that shell arithmetic is 64-bit integer, truncating toward zero, and
  silently wrapping.
- Recognise a leading zero as octal, and fix it with `10#$v`.
- Diagnose `bin/margin-check` completely: which decks were tested, which were
  skipped, why the exit status is 0, and why the log looks healthy.
- Use `"${a[@]}"`, `${#a[@]}`, `${!a[@]}`, and explain sparseness.

## Questions that separate understanding from recall

- "`bin/margin-check` is missing two decks. Which two, and how would you have
  found that without me telling you?" The good answer redirects stderr, or
  compares the data against the output by hand.
- "Its exit status is 0. Is that a bug in the script or correct behaviour?"
  Correct behaviour — a failed `(( ))` in an `if` is a false condition — which is
  what makes it dangerous.
- "You fixed it with `10#`. Now which other script on this station reads numbers
  out of a file?" Looking for the student to go and check, not to answer.
- "`$(( n + 1 ))` with `n=abc` gives 1. Defend that or condemn it."
- "Show me arithmetic that runs a command." `x[$(...)]`.
- "Why `mapfile -t` and not `arr=( $(cat f) )`?" Counts: 5 versus 10.
- "Your array has 4 elements. What is the highest index?" Unknown without
  `${!a[@]}`.

## Strong answers look like

- Noticing unprompted that ` 4` passes `ask-safe`'s validation because `read`
  stripped the space first — two guards, and the outer one hid the inner one.
- Explaining that `07` is the most dangerous value in `margins.txt` because it is
  *valid* octal and therefore silent.
- Choosing `awk` and saying where the line is, rather than scaling integers for
  six decimal places out of stubbornness.

## Common wrong turns

- Editing `data/margins.txt` to remove the zeros. The data is what the sensor
  writes; the script is what is wrong.
- `10#margin` without the `$`.
- Believing `$(( ))` rounds, or that `-7/2` is `-4`.
- Looping `for ((i=0;i<${#a[@]};i++))` over a sparse array.
- Forgetting `declare -A` and not noticing, because nothing errors.
- Trusting an exit status of 0 as evidence that the work was done.

## Connections

- 12/02 — `"$@"` vs `"$*"` is `"${a[@]}"` vs `"${a[*]}"`.
- 12/04 — `IFS=`, `-r`, and keeping the loop out of a subshell.
- 12/05 — `case` for validation; `${1:-default}`.
- 12/07 — `set -u` turns the silent zero in exercise 27 into a stop.
- 07 — `awk`, for when the arithmetic outgrows the shell.
