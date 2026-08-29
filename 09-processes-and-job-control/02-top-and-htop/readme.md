# 09/02 — top and htop

> Load is a number. It is not a percentage, and it is not a verdict.

`ps` gives you a photograph. `top` gives you a film. That is the whole difference and it is the
reason both exist: some questions ("what is running") are answered by a snapshot, and some ("what is
*changing*") are not answerable by any number of snapshots you can take by hand.

Most of this lesson is the header. `top`'s process list is easy and everybody reads it; the five
lines above it are where the diagnosis usually is, and they are the lines people skip. The most
misread of them is the first.

**Load average is a queue length, not a percentage.** It counts processes that were runnable —
wanting a CPU — or blocked on disk, averaged over one, five and fifteen minutes. A load of 4 on a
24-core machine is quiet. A load of 4 on a single core means three things are waiting their turn at
all times. The number alone means nothing until you divide it by the number of CPUs, and the three
numbers are worth more compared with each other than read individually: 1-minute above 15-minute
means rising.

**`%CPU` is a rate, `TIME+` is a total.** A process at 0.3% CPU with nine hours of accumulated CPU
time is not busy now and has been expensive for a very long time. That gap is the shape of this
chapter's incident, and it is invisible if you only ever sort by `%CPU` — which is what `top` does by
default, and what everyone leaves it doing.

**`RES` is real memory, `VIRT` is mostly noise,** and small `free` is not a problem. The kernel
spends idle memory on cache and hands it back when asked. The number that answers "am I about to run
out" is `avail Mem`.

Then there is one thing about this station specifically, and `notes/station.txt` says it plainly:
Kestrel's habitat computing runs in a container. The process list you see is ours. **The load
average, the memory totals and the `%Cpu(s)` line belong to the host machine we share.** That is not
a lab quirk; it is true of almost every container anyone will ever hand you, and it is why `%MEM`
will read `0.0` in this lab for a process holding thirty-two megabytes. Judge our processes by their
own `RES` and `TIME+`. Treat the load average as weather.

Finally, `top` is interactive, and its keys are worth twenty minutes: `P`, `M`, `T` to sort, `u` and
`o` to filter, `c` for the full command line, `V` for the tree, `1` to split the CPU line per core,
`k` to kill and `r` to renice. For scripts, none of that — `top -b -n 1` gives you one snapshot as
plain text with no terminal at all. `htop` is the same job with colour and a mouse, and it will not
run in a pipe.

## What you will be able to do

- [ ] Name all five header lines and the question each one answers
- [ ] Explain load average as a queue length, and interpret it against the CPU count
- [ ] Read the 1/5/15 numbers as a trend rather than as three separate facts
- [ ] Distinguish `us`, `sy`, `wa` and `st`, and say what high `wa` with low `us` means
- [ ] Distinguish `VIRT`, `RES` and `SHR`, and explain why small `free` is not a problem
- [ ] Distinguish `%CPU` from `TIME+`, and describe the process that is quiet and expensive
- [ ] Sort and filter inside `top` with `P`, `M`, `T`, `u`, `o`, `c` and `V`
- [ ] Kill and renice from inside `top`, and say why you would rather not
- [ ] Use `top -b -n 1` in a script, with `-o`, `-u`, `-p` and `-w`
- [ ] Use `htop`, and say what it gives you that `top` does not and where it cannot go
- [ ] State which of this container's numbers describe the container and which describe the host

## Files

```
bin/load N SECS     N CPU burners in parallel, prints their pids
bin/hog SECS [MB]   holds MB megabytes so you can watch RES
bin/quiet SECS      old and idle: large elapsed, no CPU time
notes/top.txt       the header, line by line
notes/keys.txt      interactive keys, and batch mode for scripts
notes/station.txt   which numbers here are the container's and which are the host's
notes/page.txt      rhea, and two questions she has been given two answers to
scratch/            yours
```
