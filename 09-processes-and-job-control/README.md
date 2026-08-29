# Chapter 9 — Processes & Job Control

> Sixty people asleep, and the station has not been idle once this week. The job that is keeping it
> awake was started by hand in 2186 and nobody has thought about it since.

## Incident briefing

Chapter 8 was about where a program's words go. This chapter is about the program itself: a running
thing with an identity, a parent, an owner, a priority, a set of open files, and a copy of an
environment it was handed at birth. Every one of those exists *only while the process does*. That is
the fact the whole chapter is built on, and it is why this chapter's incident can be failed in one
keystroke.

So it goes in order. What a process is, and what a PID actually identifies. Then the two tools
everybody reaches for and half of everybody misreads — `top` and `htop`, where load is not CPU, CPU
is not memory, and the number on the first line is a count of processes that wanted to run. Then
signals: fifteen ways to interrupt something, one of which cannot be caught, and the difference
between asking a program to stop and removing it. Then addressing processes by name with `pgrep` and
`pkill`, which is fast and occasionally hits something you did not mean. Then job control — `&`,
`jobs`, `fg`, `bg`, `disown`, `nohup`, `setsid` — and the exact conditions under which a background
job survives the shell that started it, which are narrower than almost everyone believes. Then
`/proc`, `lsof` and `nice`, where you can read a running process's command line, working directory,
open descriptors and environment straight out of the kernel.

The incident is a door-log summariser that somebody started by hand on 2186-10-06 and never stopped.
Nothing schedules jobs on this station — that is not an oversight in the story, it is the mechanism —
so it has simply run ever since, spinning, keeping the load off zero for eight months. rhea's nightly
rebuild has gone from four minutes to eleven, and it got slow the week you were assigned to the deck.
She says so. She is right about the timing and wrong about the cause, and she will update the moment
you show her why.

The record of why that job was started exists in one place: the environment of the process itself.
Kill it first and the answer is gone.

## Learning objectives

- [ ] Define a process, and say what a PID identifies and what it does not
- [ ] Read `ps` in both syntaxes, choose columns with `-o`, and sort deliberately
- [ ] Explain the parent/child relationship, orphans, reparenting to PID 1, and zombies
- [ ] Read `top`: load average, `%CPU`, `%MEM`, `TIME+`, and the state letters
- [ ] State why load average is not a percentage, and interpret it against `nproc`
- [ ] Distinguish `top`, `htop`, `ps` and `uptime` by what question each one answers
- [ ] Name the signals that matter — HUP, INT, QUIT, TERM, KILL, STOP, CONT, USR1/2 — and their numbers
- [ ] Explain which signals can be caught, blocked or ignored, and which two cannot
- [ ] Trap a signal in a shell script, and say what a trap cannot do
- [ ] Send signals with `kill`, `pkill` and `killall`, and select processes with `pgrep`
- [ ] Explain why `pkill -f` is both the useful form and the dangerous one
- [ ] Background and foreground jobs with `&`, `jobs`, `fg`, `bg`, and address them by job spec
- [ ] State the exact conditions under which `huponexit` sends SIGHUP to your jobs
- [ ] Use `nohup`, `disown` and `setsid`, and say precisely what each one changes
- [ ] Read `/proc/<pid>/`: `cmdline`, `environ`, `exe`, `cwd`, `fd`, `status` and `stat`
- [ ] Recover a deleted-but-open file through `/proc/<pid>/fd`, and say why that works
- [ ] List a process's open files with `lsof` and find a file's users with `fuser`
- [ ] Read and change scheduling priority with `nice` and `renice`, and explain the ratchet
- [ ] State what dies with a process, and order an investigation so that nothing is lost

## Prerequisites

- Chapter 1 — the shell as a program, and exit status
- Chapter 2 — paths, so `/proc/<pid>/cwd` means something
- Chapter 3 — file types and permissions; `/proc/<pid>/environ` is mode 0400 for a reason
- Chapter 5 — quoting, for every pattern you hand to `pgrep -f`
- Chapter 6 — `grep` and `find`, used throughout
- Chapter 7 — `sort`, `awk` and `cut`, for reading `ps` output as data
- Chapter 8 — redirection. The incident turns on the fact that `sudo cmd < file` opens the file as you

## Lessons

- [`01-what-is-a-process`](01-what-is-a-process/readme.md) — PIDs, parents, `ps`, and what a process actually is
- [`02-top-and-htop`](02-top-and-htop/readme.md) — load, `%CPU`, memory, and the numbers everybody misreads
- [`03-signals`](03-signals/readme.md) — asking a program to stop, and the two signals that do not ask
- [`04-kill-pkill-pgrep`](04-kill-pkill-pgrep/readme.md) — addressing processes by name, and what that costs
- [`05-job-control`](05-job-control/readme.md) — `&`, `jobs`, `fg`, `bg`, `nohup`, `disown`, `setsid`
- [`06-process-inspection`](06-process-inspection/readme.md) — `/proc`, `lsof`, `fuser`, `nice`: reading a live process
- [`07-incident-09`](07-incident-09/readme.md) — **the incident.** Eight months, and nobody stopped it.

## Flags in this chapter

**1** — in `07-incident-09`, plus a four-stage chain of `STAGE{...}` receipts that do not register
with `kestrel flags`.

The flag is not written in the lab, and this time it is not written *anywhere*: it is four numbered
fields in the environment of a process that is running right now. `grep -r KESTREL` returns nothing,
and neither does grepping for the words, because an environment is memory and was never a file.
Reading it needs `sudo`, the right order of operations, and a process that is still alive when you get
there.

The chain's four stages use a command line, one signal, one file descriptor and one nice value — one
skill each. The last exercise asks what it would have cost to kill the process at each stage.
