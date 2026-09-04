# 12/05 — validation

For the AI tutor. No scripts, no auto-grading.

## What the student must be able to do

- Write a `case` dispatcher with alternation, a catch-all, usage on stderr and a
  non-zero exit.
- State first-match-wins and locate the dead branches in `bin/dispatch` without
  running it.
- Say that `case` patterns are globs anchored at both ends, and that the word is
  expanded but not split or globbed.
- Distinguish `;;`, `;&` and `;;&` using an input that matches only the first
  pattern.
- Define functions, know `type -t` / `declare -f` / `unset -f`, and know that a
  function shadows PATH.
- Explain `local`, dynamic scope, and the `local x=$(cmd)` status trap.
- Choose deliberately between answering by status and answering by output, and
  say why `return "$count"` is wrong.

## Questions that separate understanding from recall

- "`bin/dispatch deck-01` prints the generic line. Fix it — but first, tell me
  which branches can ever run." Recall says "reorder"; understanding names both
  dead branches.
- "`*.log` comes before `*.log.gz` and yet `b.log.gz` is right. Why?" Looking
  for: whole-word matching. A student who says "luck" or "bash is smart" has not
  got it.
- "Show me an input where `;&` and `;;&` differ." Must pick one that matches only
  the first pattern; `ax` proves nothing.
- "Your function returns 300 files. What does the caller see?" 44.
- "Why is `local n; n=$(cmd)` better than `local n=$(cmd)` even when you ignore
  the status?" Looking for: the day someone adds `set -e` or an `if`.
- "Is `case "$x"` quoting necessary?" No — and the good answer still quotes.

## Strong answers look like

- Noticing that `shellcheck` reported the `deck-01` collision but not the dead
  `status` branch, and drawing the right conclusion about linters.
- Reading `ops/housekeeping.sh` and counting four modes in the `case` against
  three in the usage, unprompted.
- Spotting `"${1:-prune}"` and saying that the default mode is not documented.
- Reaching for a function rather than a fourth copy of a three-line block.

## Common wrong turns

- Believing `case` word-splits its word, and over-defending against it.
- Treating `|` in a pattern as a pipe.
- Expecting `*.log` to match `x.log.gz` (thinking in `grep`).
- Using `return` to carry a value.
- Omitting `local` and blaming the loop.
- "Fixing" `ops/housekeeping.sh`. It is not this lesson's job, and the student
  should be told to write down what they noticed instead.

## Connections

- 11/01 — `${1:-default}`.
- 11/04 — function/alias/builtin/file lookup order; `command`.
- 12/01 — source versus execute, which is why `lib/deck.sh` has no shebang.
- 12/03 — `[` splits its arguments; `case` does not.
- 12/04 — keep the counter out of a pipeline (exercise 51).
- 12/07 — `set -e` and `shellcheck`, where the `local` trap starts to bite.
