# 08/06 — Incident: fourteen months of nominal

> The tool has been telling somebody every single night. Nobody was on the other end of the pipe.

You have spent five lessons on the fact that a command speaks on two channels and that a caller
chooses, in the command line itself, which of them survives. This lesson is what that costs when the
choice was made once, in 2186, by somebody who was right at the time.

`bin/summarise` reads fourteen months of panel readings and prints a report. The report is clean.
Every reading above 1.000 is out of range, so the tool clamps it to 1.000 and — correctly, by the
convention of Chapter 8 lesson 01 — says so on **standard error**, because a clamp is a diagnostic
about the run and not part of the report.

`bin/nightly` has run it every night since:

```
bin/summarise > "logs/summarise-$DATE.log" 2>/tmp/summarise.err
```

The report is kept. Standard error goes to `/tmp`, which is recycled. So `logs/` contains fourteen
months of clean reports, and every clean report is *true*: the tool really did produce that output on
fd 1. What it does not contain is the other thing the tool said, which it said every night, at
length, to a file that no longer exists.

cass has read the logs. She is not asking you to read them again. She is asking whether the summary
is the whole of what the tool says — and the only way to answer that is to **run the tool and keep
the stream the wrapper throws away**.

## What this lesson uses

Everything in Chapter 8, and this is the point of putting it last:

- `2>file` and `2>&1` and the ordering rule, from lesson 02 — you will need
  `bin/summarise 2>&1 >/dev/null | …`, and if you write it the other way round
  (`>/dev/null 2>&1`) you will get nothing at all and conclude the tool is quiet.
- `&>` and `tee`, from lessons 02 and 04, for the run where you want both streams and a copy.
- `<<<` and here-documents, from lesson 03, for a program that reads a phrase on standard input.
- `$?`, `&&` and `||`, from lesson 05, for a tool that answers with its exit status.

Chapters 1–7 are fair game throughout: `grep -c` and ERE from Chapter 6, `sort | uniq -c` from
Chapter 7, `find` when `ls` will not do.

## The flag

`KESTREL{...}`, one flag, registered as `08/06`. Submit with:

```
kestrel flags submit 'KESTREL{...}'
```

**The flag is written in no file in this lab.** Not in `logs/`, not in `notes/`, not in `data/`, not
in `bin/`. `grep -r KESTREL .` returns nothing, and so does grepping for any word of it. It exists
only while the tool is running, on the channel nobody kept. You will assemble it from four words that
the tool says out loud, in the order it first says them.

That is the whole lesson expressed as a puzzle: a file is a record of a stream somebody chose to
keep.

## The Dig

Four receipts, `STAGE{...}`, one per skill: the stderr split, the combined count, standard input, and
the exit status. They do not register with `kestrel flags`. `notes/dig.txt` starts you off, and stage
one is solvable by anyone who has read this page.

## Reset

`kestrel reset 08/06`. Run it if you have overwritten anything under `logs/`. Nothing in the lab is
destroyed by running `bin/summarise` — it only reads.
