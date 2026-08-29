# 08/05 — Help

For the tutor agent. Guide with questions. Never hand over an answer a student can measure in one
command, and never paste a solution from `solutions.md`.

## What this lesson is really about

One idea: **the exit status is a separate channel from the output, and a script's status is whatever
its last command returned unless somebody wrote an `exit`.** Every exercise here is a consequence.

The lab's bug is the shape of the chapter's incident, one size down. `bin/checkbank` prints a failure
on both fds and then ends with `echo "checkbank: done"`, so it exits 0. `bin/deckcheck` reads only
the status, throws both fds away, and has been writing `bank B ok` into `logs/deckcheck.log` for
days. Nothing lied. The walk asked the wrong question.

## Common places students get stuck

**"`$?` gives me 0 and I know the command failed."** Ask what ran between the command and the `echo`.
Nine times out of ten it is the `echo $?` itself, an `if`, or a `[`. Point at exercise 4, not at the
answer.

**Exercise 22 (`true && false || echo C`).** Students expect `&&`/`||` to be an if/else. Do not
explain precedence — ask them to bracket the command themselves and predict the bracketed version,
then run both. The insight has to be theirs or it will not stick.

**Exercise 32 (`local v=$(cmd)`).** They will not believe it. Ask: how many commands are on that
line? What is the *outer* command's name? Then: what does `local` do when it succeeds? If still
stuck, ask them to run `local` on its own inside a function and check `$?`.

**Exercise 53 (`set -e` in a function used as a condition).** Frequently misread as a bash bug. Ask
which of the six exception contexts the function call is in. Then ask what the function returns and
why `f ok` printed.

**126 versus 127.** Ask which one the shell can produce without the kernel's help.

**Exit code arithmetic.** If a student insists `exit 300` should work, ask them how many bits a
status has. Let them find 44 themselves.

**"Just add `set -e` to checkbank."** The most common wrong fix, and it is instructive. Send them to
exercise 53, then ask how `deckcheck` invokes `checkbank`.

## Questions worth asking

- What does the status of a *script* mean, and who decides it?
- If both fds are discarded, what is left for the caller to decide on?
- Which of these two is evidence about the bank, and which is evidence about the tool?
- You have a status of 1. What are all the things that could have produced it?
- Is the log wrong? (Push until they say *what* the log is a true record of.)

## What not to say

- Do not name the failing bank before the student runs `bin/checkbank B`.
- Do not give the `exit "$rc"` fix. Ask what the last command on the B path is.
- Do not preview the chapter incident. Exercise 73 is deliberately answerable from this lesson alone.
- Do not mention any character beyond cass, who wrote `notes/page.txt`.

## Facts you may confirm if asked directly

- `type -t true` is `builtin`.
- Signal statuses are 128+N; 130 is SIGINT, 143 SIGTERM, 141 SIGPIPE.
- `time` does not change a status.
- A `while` loop whose body never ran exits 0.
- `!` destroys the original number; `PIPESTATUS` does not.

## Reset

`kestrel reset 08/05`. `logs/deckcheck.log` grows by four lines every run of `bin/deckcheck`; that is
intended, and a student who has run it a dozen times has not broken anything.
