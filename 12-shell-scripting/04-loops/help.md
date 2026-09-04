# 12/04 — help

Stuck is fine. Read only as far as you need.

## "The loop over `$(ls)` looks right to me"

Stop looking at `ls` and look at what happens to its output. Run
`ls *.log | cat -A` in `decks/`. Then ask: after the command substitution
finishes, what does the shell have in its hands — a list, or a string?

## "I can't tell which of the three `read` variants changed a line"

Do them one at a time on one line. `printf '  a\\b  \n' | while read x; do echo
"[$x]"; done`, then with `-r`, then with `IFS=`. Four bytes are at stake; look
at each.

## "My loop drops the last line"

Look at the last byte of the file: `tail -c 1 file | xxd`. Then ask what `read`
returns when it hits end-of-input with a partial line in hand, and what a
`while` loop does with a false condition.

## "The counter is zero and I've checked the arithmetic"

The arithmetic is fine. Print the counter *inside* the loop body as well as
after it. Then say which process each of those two `echo`s ran in. `12/01` had
the same shape: execute versus source.

## "I fixed the counter with `lastpipe` and it worked"

Test it two ways: inside a script, and by pasting it into your interactive
shell. Compare. Then read what `help shopt` says `lastpipe` requires.

## "`tally` says 0 and I don't see the bug"

Run its `grep -l FAULT *.log` by itself. Is the data wrong? Now run the loop
with an `echo` inside. Is the counting wrong? If both are right and the answer
is still wrong, the bug is in neither — it is in the pipe between them.

## "`|| true` hung my terminal"

Ctrl-C. Then ask what `read` set `$line` to on the failing attempt, and whether
anything ever changes it again.

## "Which fix should I ship?"

Ask what the loop body is for. If it exists only to count, delete the loop. If
it does real work per line, keep it and feed it with `< file` or `< <(cmd)`.
