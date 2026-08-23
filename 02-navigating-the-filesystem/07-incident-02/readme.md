# 02/07 — Incident: the stowaway

> Disk accounting says a directory holds forty megabytes. `ls` says it holds nothing.

No `find`, no `grep` — those are Chapter 6. This one is solved by looking properly.

## The page

cass sends you one line at 06:20:

> "`/labs/02-navigating-the-filesystem/07-incident-02/maintenance` is eating 40 megs and there is
> nothing in it. Either the disk is lying or I am. Tell me which."

That is the whole briefing. There is no ticket, no log, no error message. There is a number that
does not match another number, and you have Chapter 2.

## What this lesson is

Everything you need you already have. This lesson introduces no new command. It asks you to use
six chapters' worth of looking:

- `ls` shows you what it is willing to show you. `ls -a` changes what it is willing to show you.
- `du` counts bytes on disk. It does not care what `ls` is willing to show.
- A directory name is bytes. Some bytes are invisible when printed and still have to be typed.
- `LC_ALL=C ls -b` prints those bytes as escapes.
- `stat -c %N` quotes a name the way you would have to type it.
- Tab completion types names you cannot.
- `--` stops option parsing. `./` disarms a leading dash.

## The two numbers

The whole incident is one disagreement:

```
$ ls maintenance
$ du -sh maintenance
40M	maintenance
```

`ls` printed nothing and exited 0. That is not an error. That is `ls` telling you the truth about
a question you did not ask.

> **The question `ls` answers.** Not "what is in this directory". It is "what is in this
> directory, excluding entries whose name begins with a dot". Every time those two questions have
> different answers, someone chose the name.

## Rules of engagement

1. **In-chapter tools only.** `ls`, `cd`, `pwd`, `stat`, `file`, `tree`, `du`, `df`, `cat`, `head`,
   `tail`, `wc`, `echo`, `printf`, and `/proc`. If you reach for `find` or `grep`, stop — they are
   Chapter 6 and the incident is designed to fall without them.
2. **Do not `chmod`, `mv`, or `rm` anything.** This is evidence. You are reading it, not tidying it.
3. **Do not open `setup.sh`.** It is the answer key.
4. **Record what you tried, including what failed.** The failures are the finding here. A `cd` that
   refuses is data.

## What "solved" looks like

You will be able to state, in one sentence each:

- why `ls` showed nothing,
- why `du` showed forty megabytes,
- what the forty megabytes actually is,
- and what a filename is, given that you have now met one you cannot type.

There is a flag. It is not in a file. Read `exercises.md`.

## Before you move on

- `ls` printing nothing is not the same as a directory being empty.
- `du` and `ls` disagree constantly and neither is broken.
- Any byte can be in a filename except `/` and NUL — including bytes that print as nothing.
- When a name resists typing, stop typing it: complete it, quote it, or copy it from `stat -c %N`.
