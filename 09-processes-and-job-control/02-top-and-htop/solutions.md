# 09/02 — Solutions

Answer key. Every command below was run in the lab container. **Every number in `top` moves** — the
values here are one measured reading each, quoted so you can recognise the shape, not so you can
match them.

## Warmup

**1.** rhea's two questions: which number means something, and whether small `free` is bad. Correct
short answers: neither the load average nor the task count means much on its own — load must be
divided by the CPU count, and on this station it is the host's load anyway; and small `free` is
normal, `avail Mem` is the number that would be alarming.

**2.** Line 1 uptime and load; line 2 task counts by state; line 3 CPU time split by category; lines
4–5 memory and swap.

**3.** In order: 1-minute, 5-minute, 15-minute. Measured on one reading: `0.80, 1.10, 1.08` — the
1-minute is *below* the 15-minute, so load is falling.

**4.** Measured: `nproc` = 24. A 1-minute load of 0.8 on 24 CPUs is 3% of the machine's capacity to
run things. Nothing is queuing.

**5.** Measured: `0.80 1.10 1.08 1/4867 2444`. The fourth field is `running/total` kernel-schedulable
entities, the fifth is the most recently created pid. The fourth is the useful one — and note it
counts the *host's* threads, 4867 of them, which is your first hint about what the load average is
really describing.

**6.** Measured: `Tasks: 6 total, 1 running, 3 sleep, 0 stopped, 2 zombie`. Almost everything on any
machine is asleep waiting for something. `running` counts what is on a CPU or queuing for one.

**7.** Measured 2, both `sleep <defunct>`. Leave them.

**8.** Measured: `1.6 us, 0.2 sy, 0.0 ni, 65.8 id, 32.4 wa`. `id` is largest, as it should be on an
idle machine. This container is 32% `wa` because the *host* is doing disk work.

**9.** "The CPU is not busy; it is waiting for storage. This is an I/O problem, not a CPU problem." No
process tool helps much — `top` will show you processes in state `D` at best. You want disk tools,
which this course does not cover.

**10.** `free` is memory not used for anything at all; `avail Mem` is memory a new process could get,
including cache the kernel would evict for it. Quote `avail Mem`. Measured: `10155.0 free` and
`11054.7 avail` — the second is larger, which is the whole point.

**11.** Measured: `MiB Mem: 31185.0 total` — about 30 GiB, and `MiB Swap: 101376.0 total`, about 99
GiB of swap. Not the container's, and not a habitat computer's either. The load average, the memory
lines and the `%Cpu(s)` line are the host's; only the process list is ours.

## The process list

**12.** `PID USER PR NI VIRT RES SHR S %CPU %MEM TIME+ COMMAND`. `PR` is scheduling priority and `NI`
is the nice value — 09/06.

**13.** `%CPU`, descending. Prove it by starting `bin/load 2 15 &` and watching the burners move to
the top without you touching anything.

**14.** `VIRT` is always ≥ `RES`: it is address space mapped, most of which may never be touched.
`RES` goes in the report.

**15.** `%MEM` is a percentage of the *host's* 31 GB. A process holding 32 MB is 0.1% of that and
rounds to `0.0`. Use `RES` (or `ps -o rss`) in absolute numbers.

**16.** `S` is interruptible sleep — blocked, costing nothing. `R` is runnable. `S` is normal;
measured, the only `R` processes in this lab are ones you started to be `R`.

## Watching something happen

**17.** Measured, with four burners up: `Tasks: 12 total, 4 running, 6 sleep, 0 stopped, 2 zombie` —
`running` went from 1 to 4.

**18.** Measured:

```
   3706 cadet  ... R  69.8  0.0   0:02.20 bash
   3709 cadet  ... R  64.8  0.0   0:02.19 bash
   3710 cadet  ... S  64.8  0.0   0:02.19 bash
   3707 cadet  ... R  59.8  0.0   0:02.19 bash
```

Roughly 60–70% each, not 100%. And note one of them is `S` at the instant of the sample — a busy
process is not on a CPU every microsecond.

**19.** `bin/load`'s inner loop runs `seq 1 20000` each pass. That is a fork and an exec, so a burner
spends real time creating and reaping a child process instead of spinning, and some of its `%CPU`
shows up as the child's. The burner is busy; it is not *purely* busy.

**20.** Measured: 1-minute load went from `0.80` to `1.03` over three seconds of four burners — barely
moved. Load is an exponentially-weighted average over a minute; a six-second burst is mostly averaged
away, and a burst that ends is still visible a minute later. Load is a lagging indicator in both
directions. Never use it to catch something short.

**21.** The live view shows the *transition* — processes appearing, climbing, and vanishing when
their timer expires. Three snapshots taken by hand at random moments can miss all of that, and you
have no way of knowing you missed it.

**22.** `1` splits `%Cpu(s)` into one line per CPU. You want it when you suspect one core is pinned
while the average looks fine — a single-threaded runaway on a 24-core box is 4% of the average and
100% of one core.

**23.** `c` toggles between `comm` and the full command line. Measured, pid 1 goes from `sleep` to
`sleep infinity`. The full form is the one that distinguishes four `bash` burners from each other —
though in this lab they are subshells with no arguments, which is its own lesson about how little
`args` sometimes carries.

**24.** `V` is forest view: the same parent/child structure `pstree -p` draws, inside a live display.
`pstree` is better for reading a shape once; `V` is better for watching a shape change.

**25.** `u cadet` restricts to that user; `u` then Enter with an empty answer clears the filter. Note
that it *filters the display*, it does not re-run anything.

**26.** `o COMMAND=bash` filters on a field; `=` clears all filters. It beats `grep` because you keep
the header, the sort, the refresh and the ability to change your mind — a pipe gives you one dead
snapshot.

## Sorting

**27–28.** Under `P` the burners are on top; the `quiet` process is at the bottom with `0.0`. Under
`T` the ordering is by total CPU consumed since start, which puts long-lived consumers first
regardless of what they are doing now. `P` answers "what is busy"; `T` answers "what has been
expensive".

**29.** Measured: `bin/hog 30 32` climbs while it builds the string, holds, then vanishes when it
exits. `M` is the sort that shows it; under `P` it is invisible after the first second.

**30.** Measured `RSS 36516`, in kilobytes — about 35.7 MiB for a 32 MiB request. The extra is bash
itself plus the copy `tr` produced on the way in. `RSS` counts everything the process has resident,
not the thing you asked for.

**31.** No: `%MEM` reads `0.0` for 35 MB against a 31 GB host total. Use `RES`/`RSS`.

**32.** It is a process that has been running for a very long time doing a small amount of work
continuously — or that did a lot of work earlier and is idle now. Sorting by `%CPU` will never show
it to you, because its `%CPU` is genuinely near zero. **This is the incident in this chapter.**

**33.** A parent that has been running for eight months at a fraction of a percent would sit at the
bottom of a `%CPU` sort with `0.0`, and at the very top of a `TIME+` sort with a number in hours.
Nobody sorts by `TIME+`. That is why nobody found it.

**34.** On a clean station, pid 1 is at the top of a `TIME+` sort with `0:00.01` — it is the oldest
and it has consumed essentially nothing. Old is not suspicious; old *and* expensive is. Check `etime`
against `time`: a large gap is normal, a small gap is a machine being eaten.

## Batch mode

**35.** Only `-b` can be piped. Interactive `top` wants a terminal and produces control sequences.

**36.** As given. Note that with `-w 200` you get the full command line and can tell processes apart.

**37.** Measured: `-o -%MEM` sorted *ascending*, putting the two zombies (RES 0) first. The leading
minus reverses the sort. Useful when you want the smallest — for example the processes with the least
accumulated CPU time, when you are looking for something that has just started.

**38.** Measured: `top -b -n 1 -p 99999` prints the full header, then `Tasks: 0 total`, an empty
process list, and **exits 0**. Contrast with `ps -p 99999`, which exits 1. `top` is not a test; do not
use it in an `if`.

**39.** Measured: empty. It proves no *running* process is owned by root in this container's
namespace right now. It does not prove no root process ever ran, and it says nothing about the host —
which does run root processes you cannot see.

**40.** Without `-w`, measured: `sleep i+`. The `+` marks truncation at terminal width. In a pipe there
is no terminal width, so `top` guesses 80 and silently cuts your evidence in half.

**41.** `top -b -n 1 -o TIME+ -w 200 | sed -n '8,12p' | awk '{print $1, $11, $12}'` works, and is
fragile — column positions depend on the field set. The `ps` version,
`ps -eo pid,time,comm --sort=-time | head -6`, has no header parsing, no iteration semantics, and a
sane exit status. Put `ps` in the script. `top` is for looking, not for parsing.

**42.** `top`'s first sample computes `%CPU` over the process's whole lifetime, not over an interval —
it has no previous sample to subtract. So `top -b -n 1` gives you an average-since-start, which for an
old idle process is near zero and for a two-second-old process is near its true recent load. With
`-n 2`, the second iteration is a real interval measurement. If `%CPU` matters, take two.

## htop

**43.** Per-CPU meters, a memory bar and a swap bar. The per-CPU meters are `top`'s `1` view; the
memory bar with its colour segments (used / buffers / cache) has no single-line `top` equivalent.

**44.** Sorting and filtering are easier in `htop` — they are menus, not remembered letters. Tree view
is comparable. Signalling is easier and correspondingly easier to do to the wrong row.

**45.** Measured: `ncurses: cannot initialize terminal type ($TERM="unknown"); exiting`. `htop` is a
full-screen curses program with no batch mode. `top -b` was designed to be piped. `top` goes in the
script; `htop` goes on your screen.

## Reporting

**46.** For example: "Load average was 1.1 at 06:10, on a machine reporting 24 CPUs — that is about
4% of its capacity, and on this station the load average is the host's, not ours. Free memory being
small is normal: the kernel caches with it. The number that would worry me is `avail Mem`, and at
06:10 it was about 11 GB."

**47.** "From `top` I can say nothing is currently burning CPU and nothing is short of memory. `top`
cannot tell me whether something has been quietly consuming CPU for months, because its default sort
is by current usage — I need to sort by accumulated CPU time to answer that, and I am going to."

**48.** `top -b -n 1 -o TIME+ -w 200 | sed -n '7,12p'` — and a bad result is any process near the top
whose accumulated time is large *and* whose name nobody on the shift recognises.

## Experiment

**49.** 24 burners for 20 seconds moves the 1-minute average visibly and the 15-minute average
hardly at all; the 1-minute figure keeps rising for a while after the burners stop, then decays over
a few minutes. Exactly the lag from exercise 20, larger.

**50.** The load shows under `P`, the hog under `M`. With the default sort alone you see one of the
two problems and can write a confident, half-wrong report.

**51.** With `d 10`, a process that lives two seconds may never appear in a sample. Long delays make
`top` blind to short-lived work, which is why "I watched top and saw nothing" is not evidence. For
short-lived things you want a loop, or the accumulated-time view, or logging.

**52.** `k` on a burner kills that burner; the others continue and `bin/load` stays in `wait`. `k` on
`bin/load` kills the parent and the burners **keep running**, re-parented to pid 1 — exactly 09/01
exercise 29. This is why 09/04 spends a whole lesson on selecting the right target.

**53.** `H` shows threads. Nothing in this container is multi-threaded, so the view is identical.
On a real server it is how you tell "one process at 800%" from "eight threads at 100% each", which
changes what you would do about it.

**54.** `W` writes `~/.config/procps/toprc`. Sort order, visible fields, filters and delay persist.
Find it with `ls -l ~/.config/procps/`.

## Stretch

**55.**

```bash
cpuhogs() { ps -eo pid=,comm=,%cpu= --sort=-%cpu | head -"${1:-5}"; }
```

The `ps` version is a *lifetime average* of CPU usage; `top -b -n 2`'s second iteration is a real
interval sample. So `ps` is right about "expensive since it started" and wrong about "busy now",
which is the opposite of what most people assume when they use it.

**56.** From `man top`: the first iteration has no prior sample, so `%CPU` is computed against the
process's total elapsed time. It is measuring the average over the process's whole life, not over the
last interval. Any script that takes one `top` snapshot and reports `%CPU` is reporting a different
statistic from the one its author meant.

**57.** Record `pid`, `etime`, `time` and `args` for every process daily; compare each process against
its own previous reading by identity, not by pid — the pair (start time, args) survives a reboot in a
way a pid does not. Report only processes whose accumulated CPU time grew by more than a threshold
since yesterday and whose age exceeds some limit. Silent on a normal day; loud about exactly the
thing this chapter is about.

**58.** Load 40 is fine on a 64-core build server where every one of those tasks is a compiler and the
queue is doing what it is for. Load 2 is an emergency on a single-core flight controller with a 10 ms
deadline, because a queue length of 2 means something missed its slot. The number is meaningless
until you name the machine.

## Flag

None. The chapter's flag is in `07-incident-09`.
