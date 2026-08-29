# 09/05 — Solutions

Answer key. Every command here was run in the container. Where output is quoted it is verbatim.

## Warmup

**1.** The two sentences that will not land yet: a background job that tries to read the terminal is
stopped with SIGTTIN, and `huponexit` needs a login shell.

**2.** Thirty seconds with no prompt. `quiet-work: finished after 30s`.

**3.** `Ctrl-C` sends SIGINT. `echo $?` → **130** = 128 + 2.

**4.** `[1] 4210`: `[1]` is this shell's job number, `4210` is the pid of the job's leader.

**5.** `$!` is the pid of the most recently backgrounded job — the second number, not the job number.

**6.**
```
[1]+  9562 Running                 bin/quiet-work 60 &
```
Job number with `+`/`-` marker, pid, state, command as typed.

**7.** `jobs -p` prints pids only, one per line — the form you can feed to `kill`, `ps -p` or `xargs`.

**8.**
```
[1]-  Running                 bin/quiet-work 60 &
[2]+  Running                 bin/quiet-work 60 &
```
`+` is the *current* job (what `fg` picks with no argument), `-` is the previous. The newest running
job takes `+`; the one it displaced takes `-`.

**9.** No — each job has its own pgid, and each pgid equals the leader's pid:
```
   9584    9584 S    bash bin/quiet-work 40
   9585    9585 R    bash bin/quiet-work 41
```
That is what job control *is*: one process group per job, so the shell can signal a whole pipeline
at once. It also means `kill -TERM -<pgid>` from an interactive shell hits one job — unlike lesson
04, where a script's jobs all shared the script's group and the script killed itself.

**10.** SIGTERM. Proof: `bin/hupper 30 scratch/x.log & kill %1` then `wait %1; echo $?` → **143** =
128 + 15. (Or run `bin/catcher` from lesson 03 and read what it says it caught.)

**11.** First `jobs`: `[1]- Terminated bin/quiet-work 60`. Second `jobs`: the line is gone. The shell
reports a job's death once and then forgets it. This is why "it is still there" is so often just a
`jobs` run half a second too early.

## Stopping and resuming

**12–13.** `jobs` → `[1]+ Stopped bin/talker 60 deck`. `ps` → state **T**:
```
    PID STAT COMMAND
   9585 T    /usr/bin/env bash bin/quiet-work 41
```
Same `T` as `kill -STOP` in lesson 03.

**14.** `Ctrl-Z` sends **SIGTSTP**, signal **20**. `Ctrl-C` sends SIGINT, signal 2. TSTP is the
catchable stop; STOP (19) is not catchable.

**15–16.** `fg` prints the command line and resumes it in the foreground. `bg` prints
`[1]+ bin/talker 60 deck &` and resumes it in the background — the output keeps coming, but you have
your prompt.

**17.** The job's output lands in the middle of your typed line. Your line is intact — the terminal
driver still holds the characters you typed and Enter still runs the command you meant — but it is
unreadable. The terminal is shared and there is no arbitration. Chatty programs get redirected.

**18.** Because `&` gives you the prompt and redirection gives you the prompt back *usable*. `&` and
`>` are two halves of one habit.

**19.** `kill %1 %2`, or `kill %?talker` twice.

**20.**
```
[1]+  Stopped (tty input)     bin/reader
```
**SIGTTIN**. A background job is not the terminal's foreground process group, and the kernel will not
let a process outside that group read from the terminal; instead of an error it stops the process.
The parenthesis is the whole diagnosis.

**21.** `fg`, type a line: `reader: got [whatever you typed]`. `kill %1` would have destroyed a job
that was working correctly and waiting for something you could have given it in one keystroke. The
message says what it wants.

## Job specs

**22.** `bash: jobs: %quiet: no such job`. The spec matches the beginning of the command **as you
typed it**, and you typed `bin/quiet-work`. The job's command starts with `bin/`.

**23.** `bash: jobs: bin: ambiguous job spec`. `%bin` is a legal prefix for *both* jobs, so the shell
refuses to guess. Note it prints both an ambiguity error and a `no such job` error; the exit status
is 1 either way.

**24.** `%?count` works: `%?` matches a substring anywhere in the command, `%prefix` only at the
start. `%?uiet` with two `quiet-work` jobs is ambiguous for the same reason as 23.

**25.** `%%` and `%+` are the same job — the current one, the newest running. `%-` is the previous.

**26.** Yes. Stopping a job makes it the current job: a stopped job jumps to `+` because it is the
one you most likely want to `fg`. `%%` now names the counter.

**27.** `-r` lists running jobs only, `-s` stopped only. `jobs -s` on a clean shell prints nothing and
exits 0 — absence of output, not an error.

**28.** `jobs -n` lists only jobs whose state has *changed since the last report*. Run it twice and
the second is empty, because the first run was the report. It is what a shell prompt would use to
tell you "job 2 finished" without re-listing everything.

**29.** The file keeps growing, so the process is doing work — `jobs` only tells you the shell's view
of its state. For a disowned or setsid'd process, the file is the *only* evidence you have.

**30.** `wait %1` blocks until job 1 exits; the shell does nothing else meanwhile. `$?` is the job's
exit status — 0 for a clean `quiet-work`.

**31.** `wait` returns when *all* jobs are done — 40 seconds. `wait -n` returns when the *first* one
finishes — 5 seconds — with that job's status.

**32.** `wait %1` → **143**. Same rule as lesson 03: 128 + 15 for a TERM death. `wait` is how you read
the status of a background job at all; `$?` right after `kill` is the status of `kill`, not of the job.

## What survives

**33.** `huponexit      	off`. It is a `shopt` option — the second family of shell options, distinct
from `set -o` flags.

**34.** Rule 2: bash sends SIGHUP to its jobs on exit **only if `huponexit` is set** *and* **the shell
is an interactive login shell**.

**35.** `scratch/a.log` contains only the start line. No HUP. Interactive yes (`-i`), login no,
option off — so nothing was ever going to send it.

**36.** `scratch/b.log`: still only the start line. The job survives with the option *on*. That proves
rule 2 is not "the option decides"; the option is necessary and not sufficient.

**37.**
```
hupper: pid 9905 started 10:57:18, logging to scratch/L.log
hupper: pid 9905 caught HUP at 10:57:19
```
The missing condition was **login**: `bash -lic` instead of `bash -ic`.

**38.** `pgrep -af bin/hupper` then `pkill -f bin/hupper`. Every one of those processes' shells has
exited. Nothing about them says so.

**39.** "Yes, it is still running: on this station `huponexit` is off and it would not fire on exit
anyway unless the shell were a login shell, so a plain `&` job outlives the shell that started it —
which is why anything you actually want to keep should be started with `nohup` or `setsid`, and
anything you do not should be killed before you leave."

## nohup, disown, setsid

**40.** `nohup: ignoring input and appending output to 'nohup.out'`. The file is **0 bytes** (nothing
written yet) and mode **`-rw-------`** — 0600, because nohup creates it with restrictive permissions
by design.

**41.** `SigIgn: 0000000000000005` = bits 0 and 2 = signals **1** and **3** = HUP and QUIT. `nohup`
added **SIGHUP**.

**42.** Plain background job from an interactive shell: `SigIgn: 0000000000000004` — QUIT only. QUIT
is set in both because the shell sets QUIT to ignored in background jobs (lesson 03, exercise 23;
from a *non*-interactive shell you saw `6` = INT and QUIT, because there INT is ignored too). The bit
that differs is HUP, and that is the entirety of what `nohup` did.

**43.** `nohup: ignoring input and redirecting standard error to standard output`, and there is **no**
`nohup.out`. The rule: nohup redirects stdout to `nohup.out` *only if stdout is a terminal*, and
redirects stderr onto stdout *only if stderr is a terminal*. Redirect it yourself and nohup leaves it
alone.

**44.** No. `nohup` sets HUP to ignored and fixes up the streams; it does not background anything.
`nohup cmd` with no `&` blocks exactly like `cmd`.

**45.** After `disown %1`, `jobs` prints nothing — the shell has forgotten it. `pgrep -af bin/counter`
still finds it and `scratch/d.log` is still growing. Nothing happened to the process.

**46.** `bash: kill: %1: no such job`. You gave up **the job spec** — the shell's handle on it — and
with it `fg`, `bg`, `wait` and `jobs`. You did not give up anything the kernel knows: `kill <pid>`
works fine, and `pgrep` finds it.

**47.** `disown -h %1` leaves the job listed in `jobs`, so `%1`, `fg` and `kill %1` all still work; it
only marks the job as not-to-be-HUPed on exit. `disown` removes the entry; `disown -h` keeps the entry
and clears the HUP.

**48.** Because `setsid` forks. It creates a new session with a new leader and returns immediately;
the child is not your shell's child at all, so there is nothing for your shell to wait for.

**49.**
```
    PID    PPID    PGID     SID TT       STAT COMMAND
   9680       1    9680    9680 ?        Ss   bash bin/counter 20 scratch/c1.log
```
ppid **1** — its parent exited immediately and init adopted it. TT is **`?`** — no controlling
terminal, so nothing can HUP it when a terminal dies. The **`s`** in `Ss` means **session leader**;
the `S` is ordinary interruptible sleep.

**50.** No shell owns it. `jobs` in any shell on the station shows nothing, because a job is a shell's
private bookkeeping and no shell has a record. This is not hiding — `ps` shows it plainly — but it is
the end of the trail for the question "who started this".

**51.** Least to most: `disown` changes only the shell's table; `nohup` changes the process's signal
dispositions; `setsid` changes what the process *is* — new session, no terminal, ppid 1. `setsid`
leaves no record of the starting shell, and `nohup`-then-exit gets you to the same place a moment
later, when the parent goes away and init adopts the child.

## Scripts

**52.**
```
bash: line 4: bg: no job control
```
`&`, `jobs` and `wait` work in a script; `fg`, `bg` and `Ctrl-Z` do not, because a non-interactive
shell does not set up process groups per job or hand the terminal around. There is no terminal to
hand around and nobody to press Ctrl-Z, so bash does not pay for it.

**53.** With `set -m` first, `jobs` still works and `bg %1` now reports `job 1 already in background`
rather than `no job control` — job control is on. Each job gets its own group:
```
  10207   10207 sleep 5
```

**54.** With `set -m`, each background job in the script is its own process group, so
`kill -TERM -<pgid>` of a job would kill that job and not the script. Without it, they all share the
script's group and the script kills itself — which is exactly what happened in 04/37b (rc 143).

**55.** "Start it with `setsid`, or with `nohup … &`, and redirect both streams to a file you name
yourself — never to `nohup.out`, because `nohup.out` lands in whatever directory the script happened
to be in and tells nobody which run wrote it. Then log the pid somewhere a human will look."

## Reporting

**56.** "Nothing records it. `ps -o user` gives the account it runs as, which on this station is
often a shared automation account rather than a person; `ps -o lstart` gives when it started; and
`/proc/<pid>/environ` gives the environment it was handed, which sometimes names the shell or the job
that launched it. None of that is an audit trail — it is the process's own memory, and it dies with
the process."

**57.** It tells you: the parent exited before the child, so this process was adopted by init. It does
**not** tell you whether that was `setsid`, `nohup … &` followed by a logout, a double fork, or a
parent that simply crashed; it does not tell you when the parent went away; and it does not tell you
who the parent was. `?` in TT adds that it has no controlling terminal, which makes `setsid`-like
starts more likely and still does not prove one.

**58.** `pgrep -au $USER` — or, more precisely, `ps -o pid,ppid,lstart,args -u $USER --no-headers`,
looking for anything whose ppid is 1 or which is not a child of your current shell. It misses anything
running under a *different* account, which is the whole of lesson 07.

## Experiment

**59.** `for i in $(seq 20); do bin/quiet-work 60 & done` and `jobs` lists twenty. There is no small
limit. When jobs finish, their numbers are not reused until the shell has reported them; new jobs take
the next number above the highest live one, so numbering climbs and gaps appear. It is a per-shell
counter, not a slot table.

**60.** The job keeps running — `exec bash` replaces the shell's *program*, not its process, and the
child was never the shell's to kill on the way out. The new shell's `jobs` is empty: the job table
lived in the memory that `exec` just overwrote. The pid still exists, and now has a parent that has
no idea it is a parent.

**61.** Two processes, one job.
```
[4]+ 10276 Running                 bin/talker 20 p
     10277                       | grep --color=auto -c tick &
```
`jobs -l` prints the pid of the **first** process in the pipeline; `ps` shows both sharing pgid 10276.
Killing `%4` signals the group, which is why `kill %n` on a pipeline does the right thing and
`kill <the pid you happened to note>` often does not.

**62.** No — the log gains nothing while the process is stopped. `kill -CONT` and the trap fires
immediately:
```
hupper: pid 10284 caught HUP at 10:58:58
```
Same rule as TERM in lesson 03: a signal sent to a stopped process is *pending*, and delivery happens
when it runs again.

## Stretch

**63.**
```bash
holdover() {
  ps -u "$USER" -o pid=,ppid=,lstart=,args= | awk '$2 == 1'
}
```
Sort by start time with `ps --sort=lstart`, or `ps -u "$USER" -o pid=,ppid=,etimes=,args= | awk '$2==1' | sort -k3 -nr`
to put the oldest first. Lesson 07 is this, run against a different account.

**64.** **No, it cannot.** `nohup` sets HUP to ignored before exec, and a bash script started that way
inherits SIG_IGN for HUP — and bash refuses to install a trap for a signal it inherited as ignored
(lesson 03, exercise 23). Measured:
```
SigIgn:	0000000000000005
SigCgt:	0000000000010002
```
`SigCgt` has bits for signals 2 and 17 (INT and CHLD) — no HUP bit, so the `trap … HUP` in
`bin/hupper` never took. `kill -HUP` on it does nothing at all and the process stays alive. So
`nohup` does not mean "handle HUP yourself"; it means "HUP is off the table", including for the
program's own author.

**65.** You cannot do it from outside. `disown` edits the shell's job table, which is memory inside
the shell process — no kernel object corresponds to a "job". The nearest you can get is arranging for
the *effect*: start the process under `nohup` or `setsid` so nothing will HUP it. You still cannot
make `jobs` forget it, because the forgetting is the whole feature.

**66.** First: it does not address rule 1. If the terminal dies rather than the shell exiting cleanly,
the kernel sends HUP to the foreground process group and `huponexit` was never consulted. Second: it
has no effect on anything already `nohup`ed, `disown`ed or `setsid`ed — and those are precisely the
things that get left behind for months, because somebody chose to make them survive. It also breaks
the legitimate case: a long job you deliberately backgrounded now dies when you close the window.
