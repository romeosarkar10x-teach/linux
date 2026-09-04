# 12/01 — validation

Rubric for the validating agent. No scripts, no auto-grading. Read the
student's terminal history and their files.

## Must demonstrate

- [ ] Ran one file all three ways and can account for the variable that did not
      survive `bash script.sh` but did survive sourcing — in terms of processes,
      not in terms of "sourcing keeps things".
- [ ] States the shebang rule correctly: the **kernel** reads it, only when the
      file is **executed**, and it is a **path** with no PATH search.
- [ ] Distinguishes 126 from 127 and can produce each deliberately.
- [ ] Diagnosed all five broken scripts with the cause, not just the fix.
- [ ] Wrote `scratch/decks.sh` with a shebang, an exec bit, a non-obvious
      comment, and a path that survives being run from `/tmp`.
- [ ] Explains that a script's status is its last command's status by default,
      and showed it changing by adding a line.

## Strong answers look like

- Exercise 35: the student names both interpreters — bash's own fallback for a
  shebang-less file, versus `execvp`'s fallback to `/bin/sh` (dash) — and says
  the danger is the silent change of interpreter, not the absence of one.
- Exercise 36: `no-shebang.sh` placed last, with "it works today" as the reason.
- Exercise 40: a sentence about what the caller believes.
- Exercise 51: `file` reads content, distinct from mode and from extension.
- Exercise 53: `.` on PATH described as a write-permission problem, not a
  typo problem.

## Red flags

- "Always use `#!/bin/bash`" with no account of why `env` exists.
- Treating `Permission denied` as a problem with the file's *contents*.
- Fixing `broken/wrong-shell.sh` by rewriting the array instead of naming the
  interpreter. Both work; only one shows they read the shebang.
- Editing anything under `ops/`. Nothing in this lesson asks for it.
- Claiming `ops/tidy.sh` is fine because it exits 0. That is the failure the
  lesson exists to prevent.

## Not required

- Any use of `set -e`, `trap`, or `shellcheck` — those are 12/07.
- Argument handling. `$1` has not been taught yet; a student reaching for it is
  ahead, not wrong.

## Follow-up questions

1. "You ran it with `bash` and it worked. What did that skip?"
2. "Your script exits 0. Name one thing that could have gone wrong inside it
   without changing that."
3. "Why is `/usr/bin/env` in the shebang instead of bash's own path?"
