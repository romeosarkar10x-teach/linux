# 09/02 — Exercises: top and htop

```
cd /labs/09-processes-and-job-control/02-top-and-htop
ls -F
```

Chapters 1–8 plus 09/01. `kestrel reset 09/02` if you wreck it. `top` quits with `q`; if you get
stuck in `htop`, `q` there too.

Numbers in this lab move. Never copy a value out of `top` into a report without saying when you took
it.

---

## Warmup — the header, before the list

**1.** `cat notes/page.txt`. rhea asks two questions. Write the one-sentence answer you *currently*
believe for each, before you read anything else. You will check them at exercise 45.

**2.** `top -b -n 1 | head -5`. Five header lines, no interaction. Name what each line is about.

**3.** Line 1: read the three load numbers. Which is 1-minute, which is 15-minute? Is load rising or
falling right now?

**4.** `nproc`. How many CPUs does this machine claim? Divide your 1-minute load by it. What does the
result say?

**5.** `cat /proc/loadavg`. The same three numbers plus two more fields. What are the last two, and
which of them is the more useful?

**6.** Line 2, `Tasks:`. Total, running, sleeping, zombie. What is `running` right now, and why is
that number so much smaller than `total`?

**7.** If you see a non-zero `zombie` count, that is left over from 09/01 exercise 29 — you killed a
parent. Do not chase it here; 09/03 explains it. Write down the count now so you can compare later.

**8.** Line 3, `%Cpu(s)`. Read `us`, `sy`, `id` and `wa`. Which is largest?

**9.** Suppose you found `us 2.0, wa 60.0`. Write the one-sentence diagnosis, and say which tool from
this chapter would *not* help you with it.

**10.** Lines 4 and 5. What is `free`, and what is `avail Mem`? Which one would you quote to somebody
asking whether the station is about to run out of memory?

**11.** `cat notes/station.txt`. Then compare `top`'s memory total with what a station of sixty
people plausibly has. Which numbers in this container's `top` are not the container's?

## The process list

**12.** `top -b -n 1 -w 200 | sed -n '7,15p'`. Name every column in the header row.

**13.** Which column is sorted by default? Prove it rather than assuming.

**14.** `VIRT` versus `RES` for the same process. Which is bigger, always? Which would you put in a
report?

**15.** `%MEM` for every process in this container reads `0.0` or close to it. Explain why, using
`notes/station.txt`, and say what you will use instead.

**16.** The `S` column. Find one `S` and, if you can, one `R`. What is the difference, and which one
is normal?

## Watching something happen

**17.** `bin/load 4 20 &`. It prints five pids: its own and four burners. Immediately run
`top -b -n 1 -w 200 | head -3`. What changed in `Tasks:` compared with exercise 6?

**18.** While it still runs: `top -b -n 1 -o %CPU -w 200 | sed -n '7,12p'`. What `%CPU` does each
burner get, and do the four add up to what you expected?

**19.** They do not each get 100%. Read `bin/load` and explain where the rest of each burner's time
goes.

**20.** Does the 1-minute load average move while the burners run? Take a reading now and another 30
seconds after they finish. Explain the lag from the word "average".

**21.** Now run `top` interactively (no `-b`). Watch the burners appear and disappear. What does the
live view show you that the three snapshots did not?

**22.** In interactive `top`: press `1`. What happened to the `%Cpu(s)` line, and when is that view
the one you want?

**23.** Press `c`. What changed in the `COMMAND` column? Which of the two forms would have told you
which burner was which?

**24.** Press `V`. Describe what you get, and how it compares with `pstree -p` from 09/01.

**25.** Press `u`, type `cadet`, Enter. Then `u`, Enter with nothing. What did the filter do, and what
does the empty answer do?

**26.** Press `o` and enter `COMMAND=bash`. Now everything else is hidden. Press `=` to clear it. When
is `o` better than piping `top -b` into `grep`?

## Sorting is the whole skill

**27.** `bin/quiet 300 &` and `bin/load 2 15 &` at the same time. In interactive `top`, press `P`.
Which is at the top?

**28.** Press `T` — sort by `TIME+`. Different answer? Explain what question each of the two sorts is
answering.

**29.** Press `M`. Now start `bin/hog 30 32 &` and watch. Which process climbs, and what does it do
at the end?

**30.** `ps -o pid,rss,vsz,comm -p <the hog's pid>`. Measured in the lab: `RSS 36516`. What unit is
that, and does it agree with the 32 you asked for? Where does the difference come from?

**31.** With the hog running, is `%MEM` a useful column on this station? Answer with a number.

**32.** Here is the exercise that matters. A process with `%CPU 0.0` and a very large `TIME+` — what
is it, in one sentence, and would sorting by `%CPU` ever show it to you?

**33.** Construct one, roughly: run `bin/load 1 20`, wait for it to finish, and look at the parent's
`TIME+` before it exits. Then say what a version of that with eight months of runtime would look
like in a `P`-sorted `top`.

**34.** Sort by `TIME+` on this station right now. What is at the top, and is that suspicious? (Look
at its `etime` in `ps` too before you answer.)

## Batch mode, for scripts

**35.** `top -b -n 1` versus interactive `top`. Which one can you pipe? Prove it.

**36.** `top -b -n 1 -o %MEM -w 200 | sed -n '7,10p'`. Top three by memory.

**37.** Now try `-o -%MEM` with the minus sign. Measured: it puts the zombies first. What did the
minus do, and when would you want it?

**38.** `top -b -n 1 -p 1 -w 200 | tail -2`. One process by pid. What does `top -b -n 1 -p 99999`
give you, and what is its exit status?

**39.** `top -b -n 1 -u root -w 200 | sed -n '7,9p'`. Measured on this station: nothing. What does an
empty answer prove here, and what does it not?

**40.** Why `-w 200`? Run the same command without it and compare the `COMMAND` column for pid 1.

**41.** Write a one-liner that prints the pid and `TIME+` of the five processes with the most
accumulated CPU time, no headers. Compare it with the `ps` equivalent from 09/01. Which would you put
in a script, and why?

**42.** `top -b -n 2 -d 1 | tail -20`. Two iterations, one second apart. Why is the *first* iteration
of any `top` run untrustworthy for `%CPU`?

## htop

**43.** `htop`. Describe the three bars at the top. Which one has no equivalent single line in `top`?

**44.** In `htop`: `F5` tree, `F6` sort, `F4` filter, `F9` signal, `F10` quit. Try the first three.
Which of them was easier here than the `top` equivalent, and which was not?

**45.** `htop | head` — try it. Read the error. Why can `top` do a thing `htop` cannot, and which of
the two belongs in a script?

## Reporting

**46.** Go back to your exercise-1 answers. Rewrite both, now, for rhea. Neither answer should
contain a number without a unit and a time.

**47.** rhea will ask "so is the station fine?". Write the two sentences: what you can say from `top`
alone, and what `top` alone cannot tell you.

**48.** You are asked to leave a monitoring note for the next shift. Write the single `top -b`
command you would tell them to run, and say what a *bad* result of it would look like.

## Experiment

**49.** Run `bin/load 24 20` — one burner per CPU. Watch the load average for the next two minutes.
How long does it take to reflect the burst, and how long to forget it?

**50.** Run `bin/load 1 30` and `bin/hog 30 64` together. Which one shows up under `P`, which under
`M`, and what would you have missed by only ever using the default sort?

**51.** In interactive `top`, press `d` and set the delay to `0.5`, then to `10`. What does a very
long delay do to your ability to see a short-lived process, and what does that imply about using
`top` to catch something that runs for two seconds?

**52.** Press `k`, give it a burner's pid, accept the default signal. What happened? Now do the same
to `bin/load` itself and describe what happened to the burners. (09/01 exercise 29 predicted this.)

**53.** Press `H`. Threads instead of processes. Does anything in this container have more than one?
What would that view be for on a real server?

**54.** Press `W`, then quit and restart `top`. What persisted, and where did it get written? Find the
file.

## Stretch

**55.** Write `cpuhogs N` — prints the N processes with the highest `%CPU`, from `top -b`, with no
header, as `pid command percent`. Then write the same thing from `ps`. Which is correct more often,
and why does the answer depend on the word "sampled"?

**56.** `top -b -n 1` reports `%CPU` for the first iteration differently from later ones. Read
`man top` on this and write two sentences explaining what the first sample is actually measuring.

**57.** Design the check you would run every morning on this station to catch a process that is
quietly accumulating CPU time. It must not use `%CPU`, it must survive a reboot changing all the
pids, and it must produce nothing at all on a normal day.

**58.** Argue the other side: give one realistic case where a load average of 40 is fine and one where
a load average of 2 is an emergency. Both must be about a specific machine.
