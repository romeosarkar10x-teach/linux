# 08/04 — Validation rubric: pipes, properly

For the validating agent. No auto-grader. Sections 1, 2 and 4 are **must-pass**.

## 1. What a pipe is (must pass)

The student can state that both stages run **concurrently as separate processes** with a kernel
buffer between them, and can cite evidence they ran — the 1-second `read` wait in exercise 5, the
`pipe:[…]` from `/proc/self/fd`, or the subshell result in exercise 26.

Fail if they describe it as "run the first, then feed the second".

## 2. Only fd 1 (must pass)

The student can explain why `bin/noisy | wc -l` is 6 and `bin/noisy 2>&1 | wc -l` is 12, and can say
why `2>&1` must be **left** of the `|`. They diagnose rhea's filter complaint correctly.

Bonus, not required: they produce `2>&1 >/dev/null |` to pipe stderr alone.

## 3. Exit status

The student knows the pipeline reports the last stage's status; has read `PIPESTATUS` correctly
(`4 0` for `bin/failmid | wc -l`) and knows it is destroyed by the next command; and has run
`pipefail`. Accept any explanation of exercise 25 that identifies `set -e` acting on the pipeline
status.

## 4. Buffering (must pass)

The student has **run** both halves of exercise 38/39 and can state the rule: a program's C library
line-buffers to a terminal and block-buffers to a pipe. They can name at least two fixes
(`--line-buffered`, `sed -u`, `awk fflush`, `stdbuf -oL`).

Critically: they distinguish buffering from `wc -l`/`sort`, which cannot produce partial output at
all. A student who thinks `stdbuf` would make `wc -l` stream has not got it.

Fail if they claim output was lost, or that pipes are slow.

## 5. SIGPIPE

The student explains 141 as 128 + 13, knows the reader's exit is what kills the writer, and has seen
the truncated `tee` file in exercise 34. They can name a case where this loses data and one where it
is the desired behaviour.

## 6. Reporting

The reply to rhea (exercise 56) treats the two complaints as separate mechanisms, names each, and
gives a fix for each. A reply that unifies them into one cause is wrong unless the argument is
unusually good.

## Red flags

- Exit statuses or timings asserted without a transcript.
- Requiring exercise 34's exact line count (it is timing-dependent; "about ten thousand" is the right
  shape of answer).
- Any search for the chapter's incident: exercise 71 is a reasoning question and there is no flag in
  this lesson.
- Editing anything under `bin/`. Work belongs in `scratch/`.

## Good signs

- They tested the two crosses (buffering fix on the stderr problem and vice versa) before deciding
  rhea's complaints were unrelated.
- They noticed that `bin/countdown`'s completion line never prints under `head -1`.
- They objected to `producer | tee audit.log | head -20` unprompted.
