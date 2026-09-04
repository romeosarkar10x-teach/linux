# 12/07 — help

## "`set -e` didn't stop my script"

Look at where the failing command sits. Is it in an `if`, `while` or `until`
condition? On the left of `&&` or `||`? Inverted with `!`? In any of those,
`-e` is off — deliberately. Run `bin/e-limits`.

## "It's inside a function, though"

The function was called from a condition, so `-e` is off for its whole body.
`bin/e-in-if` is that exact case in nine lines.

## "How do I make a failure stop the script, then?"

Check it: `cmd || { echo "..." >&2; exit 1; }`. `-e` is the floor for the things
you forgot, not the mechanism for the things you know matter.

## "`unbound variable` but I did set it"

`-u` fires on unset, not empty — so if you are seeing it, the name really is
unset in that shell. Check the spelling, and check whether the assignment
happened in a subshell (12/04).

## "My pipeline exits 141"

`kill -l 141` … 128 + 13, SIGPIPE. Something downstream (`head`, `grep -q`) quit
early and the upstream writer died. Under `pipefail` that becomes your script's
status. Either avoid the early-exit pipeline or handle it explicitly, with a
comment.

## "My cleanup didn't run"

Single-quote the trap body, set it on the line right after you create the thing,
and use `EXIT` rather than putting the `rm` at the bottom of the script. Then
test it by adding an `exit 1` in the middle.

## "My trap printed an empty variable"

Double quotes expand when the trap is *set*. Use single quotes.

## "Is `/tmp/thing.$$` really that bad?"

Ask what happens if the file already exists, who owns it, and what happens if
your script exits between creating it and removing it. Then run
`bin/tempfile-bad` with an `exit 1` in the middle and look in `/tmp`.

## "shellcheck is complaining about something I meant to do"

Read the wiki page it printed. If you still disagree, disable that one check on
that one line with a comment saying why. If you cannot write the why in one
sentence, it is not intended, it is a bug.

## "The header didn't catch my bug"

Correct, and worth sitting with. `set -euo pipefail` catches failures. Both bugs
you fixed this chapter returned status 0 with a wrong answer.
