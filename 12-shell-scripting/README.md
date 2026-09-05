# Chapter 12 — Shell Scripting

> "Everything you have typed twice this month is a script you have not written
> yet."

## Incident briefing

Eleven chapters of commands, typed one at a time, each one gone the moment it
finished. This chapter is about the file that keeps them.

A script is not a new language. It is the same commands you have been typing,
read top to bottom, by the same shell. What is new is everything around them:
which interpreter runs the file, how the file receives an argument, how it says
whether it succeeded, and what it does when a step in the middle fails.

It goes in order. First a file that runs — the shebang, the executable bit, and
the difference between running a script and sourcing it. Then arguments, because
a script that only works on one file is a note to yourself. Then conditionals,
where three different spellings of the same test behave differently and the
station's older scripts use all three. Then loops, where reading a file line by
line breaks on the first filename with a space in it — and where a counter can
die in a subshell without anybody noticing. Then `case` and functions, which are
how a script with four modes stays readable, and also how a script hides a
fourth mode nobody reads down to. Then `read` and arithmetic, which are limited
and awkward, and where knowing exactly where they stop keeps you from writing
something worse than the problem. Then the four lines at the top that turn a
silent wrong answer into a loud failure, and the tool that catches most of what
they miss. Then you ship one: `stationctl`, executable, on your `PATH`, with a
`--help` that answers the question people actually ask.

Then the incident. There is a housekeeping script in the ops tree. It is named
for cleaning up. For five nights it has logged `cleanup complete, 0 files
removed`, and that line has never been false — it counts removals, and says
nothing about writes. Two deck inspections have found margins outside tolerance
on nights the summary reported them inside it.

Your job is an audit, not a repair. You are not allowed to fix the script before
the audit is attested, because the moment you fix it you have destroyed the
thing you were asked to describe. You will write a tool that reads six scripts
and reports which of them write to a fixed path under `data/` — including one
that never redirects anything, and one that writes nothing at all.

## Learning objectives

- [ ] Write a script that runs: shebang, executable bit, and invocation by path
- [ ] Explain the difference between running a script and sourcing it, in terms of which shell holds the result
- [ ] Use `$1`, `$@`, `$#`, and say why `"$@"` and `$*` are not the same
- [ ] Quote every expansion that could contain a space, and defend each one you left unquoted
- [ ] Read `if` as "run this command and check its status", not as "test this value"
- [ ] Distinguish `[`, `[[` and `test`, and name one thing `[[` does that `[` cannot
- [ ] Write a `for` loop over a glob and a `while read -r` loop over lines, and say when each is wrong
- [ ] Explain why a variable set inside a piped `while` loop is empty afterwards
- [ ] Write a `case` with more than two branches, and read one someone else wrote
- [ ] Write a function with `local` variables, and say what happens without `local`
- [ ] Use `read -r` and `read -p`, and predict what happens on end of input
- [ ] Do integer arithmetic with `(( ))` and `$(( ))`, and state the two things shell arithmetic will not do
- [ ] Explain why `(( 09 > 5 ))` fails and `[ 09 -gt 5 ]` does not
- [ ] Use `set -euo pipefail`, and name a failure shape it does not catch
- [ ] Clean up with `trap`, and create temporary files with `mktemp`
- [ ] Run `shellcheck` and either fix or justify every finding
- [ ] Ship a tool: `--help` on stdout exiting 0, documented exit codes, no unoverridable path
- [ ] Distinguish exit status 126 from 127, and say what each one is telling you
- [ ] Explain why a `~/.local/bin` addition in `.profile` does not take effect in the shell you are in
- [ ] Read a script and report what it writes, without running it
- [ ] Recognise a write performed by `mv` or `sed -i` rather than by a redirect
- [ ] Attribute a write to the scheduled script that causes it, not only to the script that performs it
- [ ] Distinguish a log line that is false from one that is true and incomplete

## Prerequisites

- Chapter 1 — the shell is a program with state, and a script is that program reading a file
- Chapter 2 — paths; a script's argument is a path and usually a relative one
- Chapter 3 — `stat` and mtime, because a comment is a claim and a timestamp is a record
- Chapter 5 — globbing and quoting; lesson 04's loops turn entirely on who expands what
- Chapter 6 — `find` and `grep`, which are how lesson 09's audit tool reads six files
- Chapter 8 — redirection and exit status; without both, `set -e` and `pipefail` mean nothing
- Chapter 9 — a process has an environment fixed at exec time, which is why a script cannot change yours
- Chapter 10 — the executable bit, and what happens to a file that does not have it
- Chapter 11 — `PATH`, the hash table, and which startup file runs when; lesson 08 depends on all three

## Lessons

- [`01-first-script`](01-first-script/readme.md) — a file that runs: shebang, the `x` bit, and sourcing versus running
- [`02-arguments`](02-arguments/readme.md) — `$1`, `"$@"`, `$#`, and the four characters that make a script reusable
- [`03-conditionals`](03-conditionals/readme.md) — `if` runs a command; `[`, `[[` and `test` are three answers to one question
- [`04-loops`](04-loops/readme.md) — `for` and `while read -r`, and a counter that died in a subshell
- [`05-case-and-functions`](05-case-and-functions/readme.md) — four modes that stay readable, and a fourth nobody reads down to
- [`06-input-and-arithmetic`](06-input-and-arithmetic/readme.md) — `read`, `(( ))`, and a margin check that skipped two decks
- [`07-robust-scripts`](07-robust-scripts/readme.md) — `set -euo pipefail`, `trap`, `mktemp`, and what the header does not catch
- [`08-ship-a-tool`](08-ship-a-tool/readme.md) — `stationctl`: `--help`, exit codes, the `x` bit, and `PATH`
- [`09-incident-11`](09-incident-11/readme.md) — **the incident.** Six scripts, one log line, and an audit you are not allowed to turn into a repair

## Roleplay

`09-incident-11/scene.md` — **ops-bot.** It runs the nightly job and writes the
log line, and it will tell you, accurately, that the last five runs exited 0 and
removed zero files. It has no opinions, no manners, and no theory. It records
timestamp, mode, exit status and files removed, and nothing else — so every
question about what *changed* comes back as "not recorded". The scene exists for
one turn: the moment the student stops asking about status and starts asking
about state. If they ask what to do next: `QUERY NOT UNDERSTOOD.`

## Flags in this chapter

**1** — in `09-incident-11`, behind a four-stage chain of `STAGE{...}` receipts
that do not register with `kestrel flags`.

The flag is not written in any file. It is stored base64-encoded inside
`bin/audit-attest` and printed only once the student's report is correct, so the
lab is not greppable and reading the checker does not shortcut the work.

The stages are: count the scripts in the ops tree; name the mode the usage text
does not list; say how many records that mode quietly lowered; and attest a
report naming all three offenders and neither of the two innocents. **Stage 3 is
the cliff.** Students answer seven, because seven records were rewritten, and
the question asks how many were *lowered* — and the ones that were skipped were
skipped because they were already under the threshold, not because of the
leading zero they are primed by Chapter 12/06 to blame.
