# 01/01 — Exercises

Seed and enter the lab first:

```bash
kestrel seed 01/01      # in the VM
kestrel enter
lab 01/01               # inside the container
```

Keep written answers in `~/01-01-answers.md`.

---

## Warmup

**1.** Report which tty you are on, what your shell's PID is, and what program that PID is.

*Done looks like:* three commands, three outputs, recorded.

**2.** Print your username two different ways — the short answer and the complete one — and say what
the complete one tells you that the short one does not.

*Done looks like:* both outputs and one sentence.

**3.** Show every process attached to your tty.

*Done looks like:* a listing that includes at least your shell and the listing command itself.

---

## Core

**4.** Run `tty` normally. Then run it so that it prints `not a tty`. Then explain, in one sentence,
what changed about the environment the program was running in — not about the program.

*Done looks like:* both outputs and the sentence.

**5.** In the lab, run `ls consoles`. Then run it so that its output goes through a pipe to `cat`.
The two outputs differ. Write down how, and why a program would deliberately behave differently
depending on where its output is going.

*Done looks like:* both outputs recorded and the reason stated.

**6.** Start a child shell. Prove it is a different process from the one you started in. Then get
back to the original and prove *that*.

*Done looks like:* four PID readings — before, inside, and after — with the two outer ones equal.

**7.** Go three shells deep. From the innermost, list the processes on your tty. Then get all the
way back out to your original shell, counting how many `exit`s it takes.

*Done looks like:* the process listing showing the nesting, and the count.

**8.** `$SHELL` and `ps -p $$` can disagree. Make them disagree, and record both readings at the
moment they do.

*Done looks like:* the two readings side by side, plus one sentence on which one you would trust in
a bug report and why.

**9.** Find the tty device file itself in the filesystem and show that it is a file. Then say what
kind of file it is — the listing tells you, in its first character.

*Done looks like:* a long listing of your own tty device, and the type named.

---

## Experiment

**10.** **Predict first, then run.** Two shells, two windows — or two `kestrel enter` sessions. In
each, run `tty` and `echo $$`.

Write down, *before running anything*: will the two ttys be the same or different? Will the two PIDs
be the same or different?

Then run it. Then explain any difference between your prediction and reality.

*Done looks like:* prediction, observation, explanation. The explanation matters more than being
right.

**11.** **Predict first, then run.** In one shell, note your PID. Start a child shell and note its
PID. Now, from the child, run `exit` — but predict first what `ps` in the *parent* will show
afterwards, and whether the child's PID will ever be reused while you watch.

*Done looks like:* prediction, observation, one sentence on what happened to the child process.

---

## Stretch

**12.** Using only what Chapter 0 gave you plus this lesson, write a single line in your answers
file that identifies this machine completely enough that someone reading it three weeks later could
tell it apart from any other shell session on the station: user, host, shell, tty, PID.

*Done looks like:* one line containing all five facts, and the commands you used to get each.

**13.** `deck-roster.txt` lists which decks have consoles. Your session is on a pseudo-terminal, not
one of those. Write two sentences explaining the difference between the `tty3` in that file and the
`/dev/pts/N` you are actually sitting on.

*Done looks like:* two sentences that get the hardware/software distinction right.

---

## Dig

**14.** `ps -p $$` shows four columns. Make it show the parent process ID as well, so you can see
what started your shell. The flag for that is not in the notes.

*Done looks like:* a `ps` invocation showing your shell's PID *and* its parent's, plus the name of
the parent process.

**15.** `who` and `w` both report who is logged in, and both show tty names. One of them also shows
what each session is currently running. Find out which, and say what the difference is between the
two commands in one sentence each.

*Done looks like:* both outputs and the two sentences.
