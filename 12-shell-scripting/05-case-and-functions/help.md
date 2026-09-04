# 12/05 — help

Read only as far as you need.

## "My `case` branch never runs"

Read the branches **above** it, one at a time, and ask of each: could this
pattern match my input? The first one that can, does, and the rest are not
tested. `shellcheck` will tell you outright.

## "The pattern looks right but does not match"

`case` patterns must match the whole word. `*.log` will not match `x.log.gz`,
and `deck-[0-9][0-9]` will not match `deck-011`. There is no anchoring to add —
it is already anchored at both ends. That is the opposite of `grep`.

## "Should I quote the word in `case "$x" in`?"

You do not have to; `case` does not split or glob it. Quote it anyway. The rule
"quote every expansion" is worth more than the exception.

## "My function changed a variable I did not expect"

Print the variable before the call, inside the function, and after. Then look for
a missing `local`. `bin/leaky` is the two-line version of your bug.

## "The status from my function is always 0"

Look for `local x=$(command)` on one line. Compare `bin/status-trap`'s two
functions — they run the same command and report different things.

## "How do I return a number from a function?"

You do not `return` it. `return` carries a status, 0–255, taken mod 256. Print
the number and capture it: `n=$(f)`. Keep `return` for yes/no.

## "`f: command not found` and I definitely defined it"

Did you *source* the file, or run it? Running it defines the function in a child
that then exits. 12/01.

## "shellcheck won't stop complaining about my dispatcher"

Read the wiki link it prints; each check has a page with the fix. If you decide
a warning is wrong, disable that one check on that one line with a comment
saying why — never globally.

## "I read `housekeeping.sh` and something is off"

Good. Do not fix it, do not run it with an argument you have not read the body
of, and write down what you noticed. You will need it.
