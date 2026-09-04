# Chapter 11 — Environment & Shell Configuration

> "I would rather be wrong on purpose than right by accident." — rhea

## Incident briefing

For ten chapters the shell has been a window you looked through. This chapter is
about the window: who set it, what it filters, and the fact that nobody checks.

It goes in order. A variable your shell knows and a variable your programs know
are two different things, and the gap between them explains most "it works when
I type it" complaints. Then `PATH` — when you type a command, something decides
which file that means; it is a list, it is in order, and anybody who can edit it
can decide what `ls` means to you. Then the startup files: four of them, three
kinds of shell, and a set of rules nobody remembers correctly, which is why
lesson 03 makes you prove which runs when rather than trusting anyone's summary,
including this one's. Then aliases and functions — one of the two can lie to you
convincingly, and it is not the one people worry about. Then the prompt and the
option flags, where a default nobody chose turns a failed command into a
reported success for forty cycles.

Then the incident. Two people run the same command in the same directory and see
different things, and both of them are right. Nothing has been deleted, nothing
has been chmodded, and nothing in the archive has been touched since 2186. What
has been touched is a generated file in one account's home — the one place on
the station that nothing reads back and nothing compares against anything else.

The repair is constrained: you may not delete the file, and you may not delete
or edit the lines that cause it. Not as a puzzle rule — the file regenerates on
upgrade, and a repair an upgrade undoes is a delay. You are going to fix it the
way the shell itself decides things, which is what the whole chapter has been
about.

## Learning objectives

- [ ] Distinguish a shell variable from an environment variable, and say what `export` changes
- [ ] Predict what a child process inherits, and what a subshell does not send back
- [ ] Read `PATH` as an ordered list, and explain shadowing with `type -a` and `command -v`
- [ ] Explain the hash table, when it goes stale, and what flushes it
- [ ] State which startup file each of the three kinds of shell reads, and prove it by experiment
- [ ] Explain why a login shell does not read `.bashrc`, and what Debian's `.profile` does about it
- [ ] Use `--noprofile`, `--norc` and `--rcfile`, and get the option order right
- [ ] Write an alias and a function, and say which one can take an argument in the middle
- [ ] Bypass an alias with `\name` and `command name`, and inspect one with `type -a`
- [ ] Explain why `expand_aliases` makes aliases invisible in scripts
- [ ] Read `PS1` as a string re-expanded before every prompt, and diagnose a prompt missing `\[ \]`
- [ ] Distinguish `PS1`, `PS2`, `PS4` and `PROMPT_COMMAND`
- [ ] Use `set -o` and `shopt` with the right sign, after reading the state you are about to change
- [ ] Predict which failure shapes `set -e` reacts to, and demonstrate `pipefail` changing a status
- [ ] Explain a script that exits 0 with a wrong answer, in terms of each command's exit status
- [ ] Use `globstar`, `dotglob`, `nocaseglob`, `nullglob`, `failglob`, and say which is dangerous
- [ ] Explain `HISTCONTROL`, `histappend`, and a history that disappeared
- [ ] Follow a sourcing chain three files deep, and grep for a setting in the file that actually holds it
- [ ] Diagnose a directory that is present, readable, and absent from one account's view
- [ ] Repair a configuration downstream of a generated file, and defend that choice

## Prerequisites

- Chapter 1 — what a shell is, and that it is a program with state
- Chapter 2 — paths; the incident's archive is a directory tree and nothing more
- Chapter 3 — `stat`, because a comment is a claim and an mtime is a record
- Chapter 5 — globbing and quoting; lesson 05 and the incident both turn on who expands what
- Chapter 6 — `find` and `grep -r`, the two instruments that do not go through your shell's globbing
- Chapter 8 — redirection and exit status, without which lesson 05's audit bug is invisible
- Chapter 9 — a process has an environment, and it is fixed at exec time
- Chapter 10 — ownership; the incident's file is owned by the account, and nobody audits it

## Lessons

- [`01-env-vars`](01-env-vars/readme.md) — shell variable versus environment variable, and what a child inherits
- [`02-path`](02-path/readme.md) — the ordered list that decides what a command name means
- [`03-startup-files`](03-startup-files/readme.md) — four files, three kinds of shell, proved by experiment
- [`04-aliases-and-functions`](04-aliases-and-functions/readme.md) — a nickname, a replacement, and which one lies
- [`05-prompt-and-options`](05-prompt-and-options/readme.md) — `PS1`, `set -o`, `shopt`, and a default nobody chose
- [`06-incident-10`](06-incident-10/readme.md) — **the incident.** One directory, two answers, both correct

## Roleplay

`06-incident-10/scene.md` — **cass, and a thing she does not believe.** She has
already ruled out the typo, the deletion and the terminal, and swapped chairs to
rule out the seat. She is stuck at the one step her training never suggested:
suspecting her own tools. She wants to know whether to file against the archive
or against the terminal, and the answer is neither. Her closing question —
*then how would anyone ever notice?* — has no comforting answer and the student
should not invent one.

## Flags in this chapter

**1** — in `06-incident-10`, behind a four-stage chain of `STAGE{...}` receipts
that do not register with `kestrel flags`.

The flag is not greppable and is written in no file; the last checkpoint
assembles it once the repair has been verified.

The four stages are: name the directory one account cannot see; name the
variable that hides it and the file three levels down that holds it; repair it
without touching that file, in a way that survives regeneration; and close the
report with a date that exists only as a timestamp. **Stage 2 is the cliff**,
and not for the reason students expect — there are two mechanisms, not one, and
finding either of them feels like finishing.
