# 12/07 — validation

For the AI tutor. No scripts, no auto-grading.

## What the student must be able to do

- Write the header from memory and say what each option does.
- Name all four places `set -e` is disabled, and demonstrate one.
- Explain `-u` as unset-not-empty, and use `${v:-}` and `${v:?}`.
- Explain `pipefail` and the 141, and decide what to do about it.
- Quote every expansion; use `cd "$dir" || exit` and `--`.
- Use `trap ... EXIT` with single quotes and `mktemp`, in that order.
- Read `shellcheck` output, fix findings, and justify any disable.

## Questions that separate understanding from recall

- "`bin/e-in-if` has `set -e` and a `false` on the first line of the function.
  Why did the script exit 0?" The whole lesson is in this answer.
- "Then when does `-e` fire on a function?" When it is called as a plain command
  — same function, two behaviours, decided by the caller.
- "You added the header to `bin/margin-check` from 12/06. Did it catch the octal
  bug?" No — the failing `(( ))` is a condition. Measured: status 0.
- "Did it catch 12/04's `tally`?" No — nothing failed; the answer was lost.
- "So what is the header for?" Looking for: unanticipated failures, not wrong
  answers.
- "Why is `/tmp/x.$$` unsafe? Give me the attack, not the inconvenience."
- "Why single quotes in `trap`?"
- "`rm *` in a directory containing a file named `-rf` did nothing and exited 0.
  Explain."

## Strong answers look like

- Refusing to treat `set -euo pipefail` as a safety guarantee, and being able to
  say precisely what is left over.
- Putting the `trap` on the line immediately after `mktemp`, unprompted, and
  saying why the order matters.
- Reading a `shellcheck` wiki page and coming back with the reasoning rather than
  the fix.
- Connecting SC2115 to the `cd` rule: both are about a script running with the
  wrong idea of where it is.

## Common wrong turns

- "`set -e` makes my script safe."
- Disabling `pipefail` because of the 141, rather than guarding the one pipeline.
- Double-quoting the trap body.
- Putting cleanup at the bottom of the script instead of in a trap.
- Blanket `# shellcheck disable=` at the top of a file.
- Treating `-u` as protection against empty values.

## Connections

- 12/02 — exit-code conventions, usage before first use of `$1`.
- 12/03 — conditions and status; `[` versus `[[`.
- 12/04 — subshells; why `tally` is not caught by the header.
- 12/05 — SC2155 and the `local` status trap.
- 12/06 — the octal bug the header does not catch.
- 12/08 — everything here becomes the standard `stationctl` is held to.
