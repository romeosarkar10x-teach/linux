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

---

## Core — the files everyone reads

**25.** Read `/proc/stat`'s first line. Name its ten numbers from `man 5 proc`, and say which unit
they are counted in — it is not seconds.

*Done looks like:* ten names and the unit.

**26.** From `/proc/stat`, report how many `cpuN` lines there are and check the count against
exercise 4's answer.

*Done looks like:* the count and the check.

**27.** `/proc/filesystems` lists what the kernel can mount. Report how many entries it has and what
the `nodev` in the first column means.

*Done looks like:* the count and the meaning.

**28.** Read `/proc/self/statm`. It has seven numbers and no header at all. Name them from the man
page, and say what unit they are in.

*Done looks like:* seven names and the unit.

**29.** `/proc/self` has two symlinks that both look like they answer "where am I": `cwd` and
`root`. Print both and say what would make them differ.

*Done looks like:* both targets and the condition.

**30.** Report the machine's free and available memory from `/proc/meminfo`, and say why the two
numbers differ and which one a person should act on.

*Done looks like:* both numbers and the answer.

**31.** Read `/proc/uptime`'s two numbers. The second is bigger than the first. Explain how that is
possible, using exercise 4's answer.

*Done looks like:* both numbers and the explanation.

---

## Core — /sys is shaped differently

**32.** Give three ways `/sys` differs in *shape* from `/proc`, from listing both. Do not say
"it has device information" — say what the directory structure does.

*Done looks like:* three structural differences.

**33.** `/sys/class` and `/sys/devices` describe the same hardware two ways. Take one entry in
`/sys/class` and follow it to its `/sys/devices` path. Report the link and say which of the two
trees is the real one.

*Done looks like:* the entry, the target, and the answer.

**34.** Report the set of online CPUs from `/sys/devices/system/cpu/online`. Say what format that
string is in, and what a machine with one offline CPU would show.

*Done looks like:* the string, the format, and the hypothetical.

**35.** Find a file under `/sys` whose entire contents are a single number with no units and no
label, and say how you would ever know what it meant. Name the documentation route.

*Done looks like:* the path and the route.

**36.** `/sys/fs/cgroup` exists here. List it, and say — without going further, since Chapter 9 owns
this — what kind of thing it is describing.

*Done looks like:* a few entries and one sentence.

---

## Experiment — predict before you run

**37.** **Predict first.** Predict what `cat /proc/self/cgroup` prints inside a container. Then run
it, and say whether the answer tells you more about the container or the host.

*Done looks like:* the prediction, the output, and the judgement.

**38.** **Predict first.** Predict whether two consecutive `cat /proc/uptime` runs give the same
first number. Run them. Then predict whether two consecutive `cat /proc/version` runs do.

*Done looks like:* two predictions and two results.

**39.** **Predict first.** Predict what `wc -c /proc/meminfo` reports, and what `ls -l` reports for
the same file. Run both and reconcile them.

*Done looks like:* the two numbers and the reconciliation.

**40.** **Predict first.** Predict what `cp /proc/cpuinfo ~/cpuinfo.txt` produces — whether it
works, and what size the copy is. Run it and check.

*Done looks like:* the prediction and the resulting size.

**41.** **Predict first.** Predict whether the file you copied in exercise 40 still changes when the
machine's state changes. Say what that proves about what `/proc` files are.

*Done looks like:* the prediction and the conclusion.

---

## Stretch

**42.** Using 02/01: `/proc/self` is a symlink whose target changes per reader. Say what
`realpath /proc/self` reports and why running it twice can give two answers.

*Done looks like:* two runs and the explanation.

**43.** Using 02/02: `ls -l /proc/1` shows a link count and a size of 0 for its files. Say which
column in that listing is still meaningful, and what it tells you.

*Done looks like:* the column and the reading.

**44.** Start `waiter.sh` again and report, from `/proc/<pid>/status`, the numeric user and group it
runs as. Then say what would be different if the same file were read for PID 1.

*Done looks like:* the numbers and the comparison.

**45.** From `/proc/<pid>/stat` for your waiter, report field 3 (the state character) and field 4
(the parent PID), and check both against `status`. Say why two files carry the same facts.

*Done looks like:* both readings and the reason.

**46.** Write down, in two lines, why "everything is a file" is a design decision and not just a
slogan — using one thing you did in this lesson that would otherwise have needed a special-purpose
tool.

*Done looks like:* two lines.

---

## Dig

**47.** `/proc/self/mountinfo` is more detailed than `/proc/mounts`. Read the first line and report
one field in it that names a path on the **host** rather than inside this container. Say what that
leaks.

*Done looks like:* the field quoted and the judgement.

**48.** Find the file under `/proc` that reports the kernel's compile-time configuration, and say
what would let you read it. It is not plain text — say what it is.

*Done looks like:* the path and the format.

**49.** Compare the soft and hard limits for open files from exercise 23 against
`/proc/sys/fs/file-max`. Report both, and explain what the two numbers are limiting differently.

*Done looks like:* both numbers and the distinction.

**50.** `/proc/<pid>/environ` exists. Read your own, and say what separates the entries. Then say
why reading *another user's* would be a security problem and what stops you.

*Done looks like:* the separator and the two answers.

**51.** Establish whether the PIDs you see in `/proc` are the same numbers the host would see for
the same processes. Say what mechanism decides this and how you could tell from inside.

*Done looks like:* the answer and the mechanism.

**52.** Write, in `answers.md`, the three-line rule you would give another cadet for reading
`/proc`: what it is good for, what it costs, and the one mistake to avoid.

*Done looks like:* three lines.
