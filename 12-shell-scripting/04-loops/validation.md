# 12/04 — validation

For the AI tutor. No scripts, no auto-grading. Ask, listen, follow up.

## What the student must be able to do

- Explain that `for` walks a list of words that was built **before** the loop
  started, and that globbing produces one word per file while command
  substitution produces text that then gets split.
- Show the failure of `for f in $(ls *.log)` on `cargo hold.log`, and say that no
  `ls` option can fix it because the split happens after `ls` exits.
- Write `while IFS= read -r line; do ... done < file` from memory and name what
  each of the four parts is protecting against.
- Explain the unterminated-last-line rule and give the `|| [ -n "$line" ]` fix.
- Diagnose `bin/tally`: data right, counting right, answer lost at the pipe.
- Offer at least two fixes for it and defend a choice between them.

## Questions that separate understanding from recall

- "You said don't loop over `ls`. `ls -Q` quotes the names. Does that fix it?"
  A student who has only memorised the rule says yes or hesitates. A student who
  understands says no and can say why — quote removal already happened.
- "`IFS=$'\n'` made all six names come back. Why isn't that the answer?"
  Looking for: it works here, it fails on a newline in a filename, and it
  changes splitting for everything else in that shell.
- "`wc -l` says 3, the file has 4 lines. Which one is wrong?" Neither — both
  count terminators. This is the answer to look for.
- "Your `lastpipe` fix worked. Show me it working in your interactive shell."
- "Where did the count go?" Not "the loop is in a subshell" recited, but the
  child-process explanation, ideally linked back to `export` or to a script that
  `cd`s.

## Strong answers look like

- The rule stated without naming `ls`: loop over the glob, never over the output
  of a command that prints filenames.
- Choosing `faults=$(grep -l FAULT *.log | wc -l)` over the fixed loop, with the
  reason that the loop had no other job.
- Noticing that `bin/count-decks-ls` has been right about four decks out of five
  since 2186, and saying why that is worse than being wrong about all five.

## Common wrong turns

- Believing the `for` loop splits its list. It does not; the list was already
  words.
- Adding quotes inside `$(ls "*.log")` and expecting them to survive.
- Thinking the missing last line is a `read` bug rather than a definition of
  "line".
- "Fixing" the subshell by moving the assignment outside the loop, which changes
  nothing.
- Treating `bin/tally`'s exit status 0 as evidence it worked.

## Connections

- 12/01 — execute vs source: the same parent/child boundary.
- 12/02 — `"$@"` and word-splitting; exercise 9 is the same fact.
- 11/01 — `export` only travels downward.
- 08 — redirection; `< file` on a compound command is the same redirection rule.
- 11/05 — `nullglob`.
