# 11/06 — Incident: two people, one directory, two answers

> cass ran `ls` and counted five sections. The engineer beside her ran `ls` and
> counted four. They ran it three times. Once they swapped chairs.

Nothing is deleted. You can prove that before you start, and you should: every
file in `archive/` is present, readable and unchanged since the 2186
reorganisation. Check the timestamps. Check the permissions. Nothing there is
the answer.

What differs is the shell — and a shell is configured per account. The account
whose view is wrong is `homes/dorn`, and you do not need to be anybody to look
at it. You have `HOME`, and lesson 03 told you exactly what a login shell does
with it:

    HOME=$PWD/homes/dorn bash -l

That is a login shell reading that account's startup files, running as you, in a
directory you can walk out of. `exit` gets you back.

## What this lesson uses

- **Lesson 01** — a variable in your shell is not a variable in a program's
  environment, and `HOME` is the one the startup files read.
- **Lesson 03** — the whole of it. Which file a login shell reads, what it
  sources, and the fact that a file can source a file that sources a file.
  `grep` in `.bashrc` will find nothing. Follow what it sources.
- **Lesson 04** — an alias is a nickname, `\ls` and `command ls` are not the
  same escape hatch, and an alias is invisible in a script unless
  `expand_aliases` is on.
- **Lesson 05** — options and variables change what a glob *means*, and the
  last assignment in a file wins.
- **Chapter 03** — `stat`. A comment inside a file is a claim about when it was
  written. The file's timestamp is a record.
- **Chapters 5–6** — `find` and `grep` see the filesystem; they do not go
  through your shell's globbing. That difference is the whole incident.

## The rules of repair

Read `notes/rules.txt` first. The short version:

- do **not** delete `.config/kestrel/env.sh`
- do **not** delete, comment out or edit the lines inside it that cause this
- do **not** chmod anything, and do not move the archive
- you **are** expected to edit `.bashrc`

The checker takes a checksum of the generated file and refuses a repair that
changed it. That is not spite: the file says in its own first line that it is
regenerated on upgrade. A repair by deletion breaks again silently, at a time
nobody is watching, on a machine where somebody already learned that a
generated file is the one place nobody diffs.

## Four checkpoints

    bin/compare-view <section>            name what one account cannot see
    bin/name-mechanism <VAR> <file>       name what hides it, and where that lives
    bin/verify-repair                     prove a fresh login shell sees it all
    bin/incident-close <token> <date>     close it, and get the flag

Each prints `STAGE{...}` when you have done the thing and says loudly when you
have not. **Stage tokens are not flags** — `kestrel flags submit` will reject
them, by design.

## The flag

One flag, registered as `11/06`:

    kestrel flags submit 'KESTREL{...}'

It is not written in any file. `grep -r KESTREL .` will not close this incident
for you; the last checkpoint assembles it once you have earned it.

## Reset

    kestrel reset 11/06

Resetting throws away your repair as well as your mistakes.
