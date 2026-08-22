# 01/07 — Incident 01: the command he didn't finish

> Your predecessor's account still has a shell history. The last line in it stops in the middle of
> a word. Three weeks, and nobody has looked.

This is the chapter's incident. There are no new commands in it. Everything you need is in lessons
01/01 through 01/06, and the point is to find out whether those six lessons are actually in your
hands or merely in your notes.

## What you have

A copy of `dorn`'s history file has been placed in this lesson's lab, along with the directory he
was working in when the session ended. That is all. There is no ticket, no bug report, and nobody
left to ask.

```bash
kestrel seed 01/07
kestrel enter
lab 01/07
```

## The constraint

**The history file is evidence. Do not modify it.**

It is the only record of a departed crew member's account, and you do not get to be the second
person to write to it. It has been set read-only for you; leave it that way. The validator checks.

You may read it, copy from it, and reconstruct from it as much as you like.

## What "solved" looks like

You reconstruct the command the session ended in the middle of, run the completed version, and it
prints a `KESTREL{...}` token. Submit it:

```bash
kestrel flags submit 'KESTREL{...}'     # from the VM
```

Then write the debrief. The debrief is graded — see below.

## How to approach it

Some honest advice, because this is the first incident and the habits you form here carry.

**Read the whole file first.** All of it, in order, before forming a theory. The last line is where
the story ends, not where the information is.

**Two of the lines in there are not clues.** They are a person doing their job. Working out which is
part of the exercise, and being wrong about it costs you nothing except time.

**You need the shape of the truncated command, not its output.** You are not trying to work out what
dorn saw. You are trying to work out what he typed.

**If something fails, read the failure.** Everything in this lab fails informatively. A wrong guess
tells you it is wrong and why, and that is a legitimate way to make progress.

**Do not brute-force it.** You can, and if you do you will get the token without learning anything,
which is a poor trade. If you find yourself guessing, go back to 01/06 exercise 9.

## The debrief

Write three sentences in `~/01-07-debrief.md`:

1. What was the truncated command doing?
2. How did you know where it had been cut, and what the missing part was?
3. Why is the last line of a history file so often incomplete?

Repairing something you cannot explain is a pass-with-notes at best. This is the part that
distinguishes "I got the flag" from "I can do this again next time".

## A note on the tools

You may read `check-sample-integrity.sh`. It is not hidden and there is nothing in it that will hand
you the answer — it shows you a method, not a result. It uses three commands you have not been
taught yet (`sed`, `grep`, `awk`); those are Chapters 6 and 7, and you are not expected to
understand them. Run it, do not write it.

## Before you move on

This is the last lesson of Chapter 1. Before Chapter 2, you should be able to:

- Say which shell you are in and prove it, without using `$SHELL`.
- Find out whether a word is a builtin, a program, an alias, or a keyword.
- Read a variable safely, and tell unset from empty.
- Get to the start of a long line, and reuse the previous line's last argument, without arrow keys.
- Search your own history for something you ran an hour ago.
- Explain why a history file's last line is often unfinished.
