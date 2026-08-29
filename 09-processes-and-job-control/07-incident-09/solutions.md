# 09/07 — Solutions

Answer key. `PID` below means the PID of `bin/door-summariser`, which changes every time the lab is
seeded. Get it once and keep it:

```
p=$(pgrep -u ops-bot -f door-summariser)
```

**The flag is `KESTREL{nobody_ever_stopped_it}`.** It is not written in any file in this lab, or in
the container image. It is four variables in the environment of a running process.

---

## Warmup

**1.** Observation: her rebuild takes eleven minutes instead of four. Correlation: it got slow in the
week the student was assigned to deck 05. Instruction: find out what is running before switching
anything off. She is asking you to test the *cause*, not the timing — she already knows the timing.

**2.** It is not false. It asserts that two things happened in the same week, which is true and
checkable in `logs/`. It does not assert that one caused the other, and she does not claim it does.

**3.** Four minutes through 2187-06-08, then 9.6 on 06-09 and ten to eleven minutes every night
after. First slow night: **2187-06-09**.

**4.** Yes. `2187-06-08  cadet assigned to deck 05`. The rebuild slowed the following night. The
correlation is exact and it is not her imagination.

**5.** Something like: two things changing in the same week is a reason to look, not a finding; the
finding is whatever is still true after you have looked.

**6.** Nothing. There is no scheduler on the station, so there is no job table to search and no
"what runs this" to answer. Everything long-running was typed by a person.

**7.** "On average, between one and two processes wanted to run." Not a percentage of anything.

**8.** `nproc` is 24. A load around 1 is roughly one CPU out of twenty-four busy — about 4%. That is
nothing as a capacity number. It is not nothing as a *fact* about a station where everyone is asleep.

## What is awake

**9.** Around forty. Useless alone: it tells you nothing about what any of them is doing.

**10.**

```
$ ps -eo pid,user,ni,pcpu,etime,args --sort=-pcpu | head -8
    PID USER      NI %CPU     ELAPSED COMMAND
    117 ops-bot    0 49.5       04:12 bash /labs/.../bin/door-summariser --tag lr-07 --since 2186-10-06
    120 ops-bot    0  0.0       04:12 bash /labs/.../bin/panel-poller --tag lr-03
    124 ops-bot   11  0.0       04:12 bash /labs/.../bin/index-sweeper --tag lr-05
```

One process at ~50%, everything else at zero.

**11.** `top`'s `%CPU` is the same instantaneous figure as `pcpu`. `TIME+` is cumulative CPU time
consumed since the process started — a different thing, and the one that grows without bound.

**12.** No. 50% of one CPU is about 2% of a 24-CPU station. rhea's rebuild is slower, but a single
spinner on an idle machine cannot account for more than doubling her wall-clock time on its own; what
it can do is guarantee the machine never rests, and it is the only unexplained thing running. Say
that, and say it is a partial explanation.

**13.** Overloaded: no. Ever idle: no, not once this week. The second is the finding.

**14.**

```
$ ps -o pid,ppid,stat,tty,args -p $p
    PID    PPID STAT TT       COMMAND
    117       1 S    ?        bash .../door-summariser --tag lr-07 --since 2186-10-06
```

Parent 1, no terminal, `S` — sleeping right now, because the loop calls `sleep 0.05` between bursts.

**15.** Either its parent exited and it was reparented to init (lesson 05, orphaned background job),
or it was started with `setsid`/`nohup`-style detachment and never had a parent to lose. You cannot
tell them apart from `ps` alone.

**16.** `etime` is time since *this process* started, and the lab's jobs restart when it is seeded.
It is good for ranking — everything here started at the same moment — and useless for dating. Do not
report it as the age of the incident.

**17.** The launch record in `records/`; the job's own environment; the modification time of anything
it has written; the shift log. Not `etime`.

**18.** `pgrep -c -u ops-bot` gives a count including the short-lived `sleep` children. `pgrep -a`
adds the command lines, which is what lets you tell the three real jobs from their children.

## Whose job is this

**19.** `bash` is the interpreter (lesson 06: `argv[0]` of a script is the shell). The script is
`bin/door-summariser`. `--tag lr-07 --since 2186-10-06` are arguments the script was given by whoever
started it.

**20.** The arguments are separated by NUL bytes, which the terminal does not render. `tr '\0' '\n'`
makes them lines.

**21.** `records/lr-07.txt`.

**22.** Tag, start date, job description, a note that the note itself lives in the environment, and
`authorised . (blank)`. Blank means nobody completed the record. It does not mean anybody hid
anything, and it does not name a person — there is no name to find here.

**23.** `lr-07.txt` is dated 2186-10-06, `lr-05` 2187-01-20, `lr-03` 2187-02-11 — mtimes and
`started` fields agree. lr-07 is the oldest by four months.

**24.** The note is passed to the job in its environment as numbered fields, one word each, and it
lives exactly as long as the process does.

**25.** The job's own environment. Nothing else holds it.

**26.** Nothing on the Kestrel stops a job it did not start, and nothing on the Kestrel starts jobs at
all — so a process that nobody stops runs until the station is rebooted, and that is a property of the
station, not a decision anybody made.

## What it is doing

**27.** `/labs/.../07-incident-09/spool/door` — the door-log spool. Not its own directory; the
summariser lives in `bin/`.

**28.** The process is owned by `ops-bot`. `ps` reads `/proc/<pid>/cmdline` and `stat`, which are
world-readable; `cwd`, `fd` and `environ` are the owner's business and the kernel checks them as it
would a debugger's read.

**29.** 0, 1 and 2 are `/dev/null` — it was started detached, with nowhere to speak. 255 is the script
file itself, which is how bash reads a script.

**30.**

```
9 -> /labs/.../spool/door/summary-2186-10-06.txt (deleted)
```

The name was removed while the file was open. The file still exists; it has no directory entry.

**31.** `ls` lists names. The file has none. Its inode, its bytes and its size are all still there
because this process holds a descriptor on it, and it will exist until that descriptor closes.

**32.** A door-log summary: one line per night, entries counted and entries summarised, running back
to when the job started.

**33.** 2187-05-13 and 2187-05-14, both `0 0`. The file says the log was present and normally sized
and that nothing parsed.

**34.** They are the same two nights Chapter 8's clamps fell on. The supportable sentence: *the two
nights on which the door-log summariser counted nothing are the two nights on which panel p-07
clamped.* Stop there. Anything past that is invention.

**35.** You copied bytes out of a file with no name, through the only handle left in the universe, and
gave them a name again. Killed instead, the last descriptor closes, the kernel frees the inode, and
the bytes are gone — not deleted from a place you could look, gone.

**36.** `lsof` prints `(deleted)` at the end of the `NAME` column; `SIZE/OFF` gives the real size.

**37.** It is a few kilobytes. Watching `df` would show nothing, and space is not the point: the point
is the file, not the free space. `sudo stat -c %s /proc/$p/fd/9` reports 64 — the size of the symlink
— so read the size from `lsof`, or `stat -L`.

**38.** One thread. `pstree` shows `bash(117)---sleep(NNNN)`: the short-lived child is the
`sleep 0.05` at the bottom of the spin loop, and its PID changes every time you look.

## Do not kill it

**39.**

```
$ kill $p
bash: kill: (117) - Operation not permitted
```

You are `cadet`; the process is `ops-bot`'s. Signalling it needs matching credentials or root.

**40.** Honestly: an accident. Nobody chose the account boundary as a safety measure; it is a side
effect of the job running under an automation account. It happens to have protected the evidence.

**41.** The four `LR_NOTE_*` fields — the record of *why* this was started. They exist in this
process's memory and in no file, no log and no backup. A reset gives you the lab back, not the
answer you would have skipped.

**42.** "Trace it before you signal it," or "no process is killed before its environment is read."

**43.** You would have: a launch record with a blank authorisation field, three log files, and a spool
directory whose interesting file no longer exists in any form. You could tell rhea what the job was
called. You could not tell her what it was for.

**44.** `SIGTERM` and `SIGKILL` both end it. `SIGKILL` cannot be caught, blocked or ignored.

## The note

**45.** `Permission denied`, and `-r-------- 1 ops-bot ops-bot` — mode 0400, owner only, and the owner
is not you.

**46.**

```
$ sudo tr '\0' '\n' < /proc/$p/environ
bash: /proc/117/environ: Permission denied
```

Your shell performed the redirection before `sudo` ever ran, so the file was opened as `cadet`.
Chapter 8 lesson 02: redirection is the shell's work, and it happens first.

**47.** `sudo cat … | tr '\0' '\n'`. Put there deliberately: `LR_TAG`, `LR_STARTED`, `LR_OUTPUT` and
the four `LR_NOTE_*`. Ordinary inheritance: `PATH`, `HOME`, `LANG`, `HOSTNAME`, `PWD`, `SHLVL`, `_`.

**48.** `LR_STARTED=2186-10-06`, which agrees with `records/lr-07.txt`. That is the date, and it came
from the process, not from a file.

**49.**

```
LR_NOTE_1=nobody
LR_NOTE_2=ever
LR_NOTE_3=stopped
LR_NOTE_4=it
```

The environment is stored unordered; `sort` on the variable names puts the fields in numeric order
because they are numbered. Reading them any other way gives you a word salad.

**50.** `kestrel flags submit 'KESTREL{nobody_ever_stopped_it}'`.

**51.** Both return rc 1. An environment is a block of memory in a process, copied to it at `exec`.
It was never written to a file, so no tool that searches files can find it, and it stops existing when
the process does.

**52.** They carry `LR_TAG` and `LR_STARTED` and no note fields — their launch records were completed
on disk. lr-07 is the one whose only record of purpose is in memory, which is exactly why it is the
one nobody has looked at in eight months.

## Reporting

**53.** Model answer: *A door-log summariser started by hand on 2186-10-06 is still running under
`ops-bot`; it spins continuously, which is why the station's load has not returned to zero. It is the
only unexplained process on the deck and it is consuming CPU every second of every night, though on a
24-CPU station it does not on its own account for the whole of the rebuild going from four minutes to
eleven. I propose to capture its environment and its open output first, then stop it — after which its
launch note, which exists nowhere else, will be gone.*

**54.** Something like: *You were right that it changed the week I arrived, and it was not me — it was
already running. Here is what is.*

**55.** *The launch record for this job has no authorising signature. The record was never completed;
there is no evidence in the lab as to who started it.*

**56.** Tonight: capture the environment and copy the open descriptor, then stop the job — cheap,
minutes, and it costs the note if you skip the capture. Longer term: a check that lists every process
whose parent is 1 and compares it against the launch records in `records/`, flagging anything
without one. Cheap to write, needs somebody to read its output, and it is the "expensive" half
because it needs a habit rather than a script.

**57.** `sudo cat /proc/$p/environ > env.txt`? No — the redirection is yours. In order:

```
sudo cat /proc/$p/cmdline | tr '\0' '\n'  > scratch/cmdline.txt
sudo cat /proc/$p/environ | tr '\0' '\n'  > scratch/environ.txt
sudo readlink /proc/$p/cwd                > scratch/cwd.txt
sudo cp /proc/$p/fd/9 scratch/recovered.txt
```

## Experiment

**58.** The environment is readable for as long as the process is; after `kill`, `/proc/<pid>` is gone
within milliseconds and `pgrep` finds nothing. There is no window. That is the whole point.

**59.** No. A child gets a *copy* of the environment at `exec`; the parent changing its own copy
afterwards changes nothing. Measured in lesson 06.

**60.** Because it is your process: `/proc/<pid>/fd` is readable by its owner without any extra
privilege. `sudo` was needed only because the runaway is `ops-bot`'s.

**61.** Two spinners on 24 CPUs do not slow each other at all — measured in lesson 06 as 3233 versus
3223 iterations. It would take more runnable processes than CPUs before anyone lost time. So one
runaway does not explain eleven minutes by itself: report it as a real cause with an honest limit,
and say what else you would measure.

**62.** Up is allowed, down is not: `renice 19` succeeds, `renice 0` on the same process gives
`renice: failed to set priority ...: Permission denied`. Niceness is a ratchet for anyone but root.

## Stretch

**63.** Sketch:

```bash
whose-job() {
  local p=$1
  [ -d "/proc/$p" ] || { echo "no such process: $p" >&2; return 1; }
  ps -o pid,user,ppid,lstart,ni,args -p "$p"
  echo "cwd: $(sudo readlink /proc/$p/cwd)"
  sudo cat "/proc/$p/environ" | tr '\0' '\n' | grep '^LR_' | sort
}
```

**64.** `ps -eo pid,ppid,user,args | awk '$2 == 1'`. The judgement is which of those are the
container's own furniture and which are jobs; any answer that hard-codes a list is making that call
in advance, and should say so in a comment rather than pretending it is a rule.

**65.** A daily list of processes with parent 1, joined against `records/lr-*.txt` by the `--tag`
argument on the command line, printing anything with no matching record. It does not stop anything.
Its whole value is that "a job with no launch record" becomes a line somebody reads.

**66.** Opening `/proc/<pid>/fd/9` opens the underlying file afresh, with your own offset starting at
0 — you are not sharing the writer's offset. So you always read from the beginning, and a second read
a minute later returns the same content plus whatever was appended in between.

## Dig

**67.** Stage 1 — `records/lr-07.txt`: `STAGE{first_stage_by_its_own_name}`. Found from `--tag lr-07`
in the command line, which is what `ps` shows anybody.

**68.** Stage 2 — `pkill -USR1 -f bin/warden`, then `cat records/warden.log`:
(Interactively that is safe. Inside a script, or via `bash -c`, the pattern matches the shell's own
command line and the shell signals itself — lesson 04's warning, and worth demonstrating once.)
`STAGE{second_stage_asked_politely}`. `SIGUSR1` is safe because it has no default action the warden
did not choose; `SIGTERM` is trapped and logs `warden: terminated before it was asked anything`
before exiting, and `SIGKILL` just kills it. Either needs a reset.

**69.** Stage 3 — in the deleted-but-open file on fd 9: `STAGE{third_stage_still_open}`.

**70.** Stage 4 — `ps -eo pid,ni,args -u ops-bot` shows nice 0, 0 and **11**;
`sed -n 11p records/index-d.txt` gives `STAGE{fourth_stage_low_priority}`. Any other line says
`STAGE{wrong_priority_read_it_again}`.

**71.** You were never allowed to signal the summariser. At stage 1 it would have cost you the command
line and so the tag; at stage 3 the open descriptor and the eight months of output in it; at stage 4
the nice value is on a different process, so killing the summariser would have left you able to finish
the chain and unable to finish the incident — which is the worst of the four outcomes, because you
would not have noticed.
