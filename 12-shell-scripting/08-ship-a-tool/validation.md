# 12/08 — validation

For the AI tutor. No scripts, no auto-grading.

## What the student must be able to do

- Explain and demonstrate 126 versus 127, including 127's second cause.
- Put a shebang on line 1, set `x`, and install to a directory on PATH.
- Say why `~/.local/bin` was not on PATH, in terms of the `if` **and** of when
  `~/.profile` is read.
- Use `command -v`, `type -a`, `hash -r`, and say what each is for.
- Ship a `--help` that goes to stdout with status 0, and a usage error that goes
  to stderr with 64.
- Distinguish an error status from a result status, in writing, in the tool.
- Take the data path from the environment with a default.
- Produce a `shellcheck`-clean `stationctl` that behaves identically from any
  directory.

## Questions that separate understanding from recall

- "`broken/bad-shebang` exists and is executable. Why 127?"
- "You created `~/.local/bin` and PATH did not change. Nothing is broken.
  Explain."
- "You edited your tool's location and the old one keeps running. What is
  remembering it, and how do you know?"
- "`deckinfo` with no argument printed all five decks and exited 0. Where in its
  source is that decision made?" (It is not made anywhere — that is the answer.)
- "`deckinfo deck-99` exits 1. Is that correct behaviour?" Looking for:
  accidentally correct, produced by `grep`, undocumented, fragile.
- "Your `check` exits 1. How does a caller tell that from a crash?"
- "Which of your statuses is a result and which is an error, and where did you
  write that down?"

## Strong answers look like

- Proving stdout versus stderr with redirection instead of asserting it.
- Writing the exit codes in a comment block **and** `--help`, unprompted.
- Choosing `[ $# -gt 0 ] && shift` over a bare `shift` under `set -e`, and being
  able to say why.
- Refusing to call `deckinfo`'s substring matching a feature.
- Scoring their own tool against `notes/shipping.txt` and finding a real gap.

## Common wrong turns

- `--help` on stderr, or exiting non-zero from it.
- No unknown-command branch, so a typo does nothing and exits 0.
- Hard-coding the data path with no way to override it.
- Relative paths, so the tool works from the lab directory and nowhere else.
- Treating `which` as equivalent to `command -v`.
- Adding `#!/usr/bin/env bash -euo pipefail` and being surprised.

## Connections

- 11/02 — PATH and the hash table; this is that lesson with a deliverable.
- 11/03 — login versus non-login shells; the `~/.profile` `if`.
- 12/02 — `sysexits` conventions, `usage()`, `$#`.
- 12/05 — `case` dispatch and functions.
- 12/07 — the header, quoting, `shellcheck`.
- 12/09 — the incident: the tool you write there is judged by this lesson's six.
