# 09/07 — Incident: nobody stopped it

> Sixty people asleep, and the station has not been idle once this week. Something is awake, and it
> has been awake since before anybody currently on this deck was assigned to it.

Six lessons have been about the same fact from six directions: a process is a live thing, and
everything you can learn about it you learn *while it is alive*. Its command line, its working
directory, its open files, its environment — none of that is written down anywhere else, and none of
it survives the process. Lesson 06 said so in one sentence: *"I could not find out what it was doing"
and *"I killed it first" are usually the same sentence.*

This lesson is that sentence with something at stake.

rhea's nightly panel rebuild used to take four minutes. This week it takes eleven. She has noticed
that this is also the week you were assigned to deck 05, and she has said so. She is not accusing you
of breaking anything — she is telling you that the timing lines up, because the timing is the only
evidence she has. **She is right about the timing and wrong about the cause**, and the only way to
show her that is to find the actual cause and hand it to her.

Something under the `ops-bot` automation account has been running for a long time. Nothing scheduled
it — there is no scheduler on this station, which is the whole reason it survived — and nothing has
ever stopped it either.

## The rule for this lab

**Trace it before you signal it.**

The record of *why* this job was started exists in exactly one place: the environment of the process
itself. There is no copy on disk, in this lab or in the image. If you kill the process before you
read it, the evidence is gone and your only recourse is `kestrel reset 09/07`, which starts you over.

That is not a puzzle constraint invented for the lesson. It is the actual property of a running
process that Chapter 9 has been teaching, applied to a case where somebody would like you to be quick.

## What this lesson uses

- **Lesson 01–02** — process, PID, parent, and reading load and `%CPU` without confusing them. The
  load average is not a percentage, and the busiest process on this station is using about half of
  one CPU out of twenty-four.
- **Lesson 03–04** — signals, and `pgrep`/`pkill` by user and by full command line. You will send
  exactly one signal in this lab before the end, and it will be `SIGUSR1`.
- **Lesson 05** — what an orphaned background job looks like: parent `1`, no controlling terminal,
  invisible to every `jobs` on the station.
- **Lesson 06** — the whole of it. `/proc/<pid>/cmdline`, `cwd`, `fd`, `environ`, and `ps -o ni`.

Chapters 1–8 remain fair game: `find`, `grep -c`, `sort`, and the fact that a redirection is
performed by *your* shell and not by `sudo`.

## The flag

`KESTREL{...}`, one flag, registered as `09/07`. Submit with:

```
kestrel flags submit 'KESTREL{...}'
```

**The flag is written in no file.** `grep -r KESTREL .` returns nothing, and so does grepping the
image, because the words were never on disk anywhere: they were passed to the job in its environment
when somebody started it by hand, and they have been sitting in that process's memory ever since.
`notes/launch-records.txt` tells you the convention for reading them. Reading them at all needs
`sudo`, because the process is not yours.

## The Dig

Four receipts, `STAGE{...}`, one per skill: `ps` on a command line, one signal, one file descriptor,
one nice value. They do not register with `kestrel flags`. Stage one is solvable by anyone who has
read this page and `notes/launch-records.txt`.

## Reset

`kestrel reset 09/07` — it re-seeds the tree **and restarts the four jobs**. Use it if you killed
something you should not have. Use it without embarrassment; the mistake it fixes is the mistake the
lesson is about.
