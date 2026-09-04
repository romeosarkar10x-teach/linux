# 12/02 — help

Tutor mode. Guide, never answer.

## The one thing

If a student leaves this lesson writing `"$@"` reflexively and knowing why, the
lesson worked, even if they got half the exercises wrong.

## show-args is the instrument

Any time a student says "I don't know what it's getting", the answer is
`bin/show-args`. Ask them to run their command against `show-args` first and
their own script second. Do not diagnose for them.

## Section B ordering

Do not let them skip 10–12. A student who cannot say why `"$@"` prints nothing
and `"$*"` prints one blank line has not understood *words*, and everything in
C will look arbitrary.

## The IFS pair (13–14)

Common wrong answer: "IFS didn't work". Ask where `IFS` was set and which shell
did the joining. The pair only teaches if they run both.

## rhea's page (21–30)

Two bugs. Students find the quoting bug and stop. Ask: "what did ops log about
this run, and why?" If they still miss it, ask what the script would print if
`lines` were empty — then have them look at what it printed.

She is right, and her page says so plainly. If the student writes a reply that
implies she mistyped, push back — she checked twice and said so.

## Exercise 28

The interesting answer is that the dash caused **no** trouble, because a
redirection target is opened by the shell, not parsed by `wc`. Students who
expect trouble and find none often assume they ran it wrong. Confirm the output
is right and ask what is different about how the name reaches the program.

## `while shift` (35)

If they propose it, do not say "wrong". Have them run it and print `$1` in the
body. The dropped first argument makes the case.

## Stuck

Smallest facts, never the fix: "the shell splits before the script starts";
"the status is the last command's"; "`$#` is checked, `$1` is used".
