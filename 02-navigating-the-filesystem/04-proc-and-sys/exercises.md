# 02/04 — Exercises

Lab: `/labs/02-navigating-the-filesystem/04-proc-and-sys`

Seed or reset from the VM with `kestrel seed 02/04` / `kestrel reset 02/04`.

Everything under `/proc` and `/sys` is **read-only for you**. Two exercises ask you to try writing
anyway; the refusal is the point. Written answers go in `answers.md`.

---

## Warmup

**1.** List `/proc`. Describe its contents in one line — there are two obviously different kinds of
entry.

**2.** Print the kernel's own version string. Then print how long the machine has been up, in
seconds.

**3.** Print the short name of the process that is doing the reading, using `/proc/self`.

---

## Core

**4.** How many processors does this machine have? Answer it twice — once from `/proc` and once
from `/sys` — and give both paths.

**5.** Report the machine's total memory from `/proc/meminfo`. State the units the file uses; do not
assume.

**6.** Using only files under `/proc` and `/sys`, establish three facts about this machine that you
could not have got from `ls` or `cd`. Write each fact into `answers.md` **with the exact path you
read it from**.

**7.** `/proc/loadavg` has five fields. Read `man 5 proc` (it is enormous — search inside it) and
say what each field is. Two of them are not what a first guess would suggest.

**8.** List the process directory for PID 1. Then print PID 1's command line and its short name.
Say what PID 1 is on this station, and why that is different from what it would be on the Ubuntu VM
outside.

---

## Your own process

`waiter.sh` in the lab starts a process and holds it for fifteen minutes. Start it in the background
with a distinctive argument:

```bash
./waiter.sh deck-3 &
```

It prints its own PID when it starts. Use that number for the next several exercises. If you lose
it, `jobs` and `ps` will find it again (Chapter 9 covers both properly).

**9.** List the `/proc` directory belonging to your `waiter.sh` process.

**10.** Print that process's working directory and the executable it is running, using the two
symlinks in its `/proc` directory. The executable will surprise you — say what it actually is.

**11.** Print that process's command line. It will not look like what you typed. Say why, in one
line.

**12.** From its `status` file, report its state, its parent process's PID, and how many threads it
has.

**13.** Look at its open file descriptors. Report what descriptors 0, 1 and 2 point at, and say
which of the three you would have predicted.

**14.** Kill it — `kill <pid>` — and then run your exercise-9 command again. Record what happens and
what the error says.

---

## The container is not the machine

**15.** Print the first line of `/etc/os-release` and the whole of `/proc/version`. They name two
different Linux distributions. Record both in `answers.md`.

**16.** Explain the disagreement in exercise 15 in three lines. Then find a **second** piece of
evidence for the same underlying fact somewhere else in `/proc` — a file whose contents describe
something outside this container. Name the file and quote the give-away.

---

## Experiment

**17.** **Predict first, in writing.** Write down what you expect from each of these before running
any of them:

```bash
ls -l /proc/cpuinfo
wc -l /proc/cpuinfo
ls -l /proc/self/comm
cat /proc/self/comm
cat /proc/self/cmdline
```

Run them. Two results contradict each other in a way that would be a bug in any ordinary
filesystem. Explain what `ls` is asking, what `cat` is asking, and why procfs can answer them
differently. Then explain the fifth line separately — it is a different phenomenon.

**18.** **Predict first, in writing.** Run `cat /proc/self/comm` and `cat /proc/self/cmdline` twice
each, and predict the PID you would see in `ls -l /proc/self` between runs. Then run
`ls -ld /proc/self` twice. Explain what `self` resolves to and why the answer changes between two
commands you typed one after the other.

---

## Stretch

**19.** Start `waiter.sh` again. Without using `ps`, and using only `/proc`, find its PID by
searching the process directories for one whose command line contains your distinctive argument.
You do not have `grep` or `find` yet — do it by reading. Say how many directories you had to open,
and what that tells you about why `grep -r` exists.

**20.** In `answers.md`, answer this: a Chapter 6 exercise will ask you to find every file on the
system larger than 100 KB. What will that search report about `/proc/cpuinfo`, and is the answer
correct? Two lines.

**21.** Compare `/proc/mounts` against the output of `df` from `02/02`. Find one filesystem that
appears in one and not the other, and offer an explanation.

---

## Dig

**22.** Try to change a kernel setting by writing to a file under `/proc/sys`. Pick one — anything
— and record the exact error. Then explain which of two possible causes produced it: your
permissions, or how the filesystem was mounted. `/proc/mounts` has the evidence.

**23.** `/proc/self/limits` lists this process's resource limits. Find the one governing how many
files a process may have open at once, report the soft and hard values, and then find the builtin
that reports the same number without reading `/proc`. (It is a bash builtin; `help` is your route,
not `man`.)

**24.** `/proc` contains a file describing the arguments the **kernel** was booted with. Find it,
read it, and name one thing in it that is clearly about the host machine's disks rather than about
this container. Then say why an unprivileged user being able to read this is arguably a problem.
