# 09/03 — Solutions: Signals

Numbers below are from this container. Pids will differ; everything else should not.

---

## Warmup — the table

**1.** *Default* — the kernel's built-in action, no code in the process involved. *Ignored* —
delivered and discarded, still no code. *Handled* — the process runs its own function instead, and
that is the only one of the three that requires the program to contain anything.

**2.** `kill -l | wc -w` gives 124, two words per entry: **62 signals**, numbered 1–31 and 34–64.
32 and 33 are reserved by the threading library and bash will not show them.

**3.**
```
$ kill -l 15 9 2
TERM
KILL
INT
$ kill -l TERM KILL INT
15 9 2
```
Both directions, same command.

**4.** `kill -l 137` prints `KILL`. It subtracted 128 for you, because a status above 128 is
conventionally a signal death and 137 − 128 = 9. That is the whole of the arithmetic in exercises
10–12, done by the tool.

**5.** **KILL (9)** and **STOP (19)**. KILL exists so there is always a way to remove a process no
matter what its author wrote; STOP exists so there is always a way to freeze one. Both would be
useless if a program could opt out, which is exactly why a program cannot.

**6.** `man kill`: "the default signal for kill is TERM". Worth checking rather than remembering,
because the shell builtin and `/usr/bin/kill` are different programs with different manuals — you saw
that pair in lesson 01's `type -a`.

**7.** rc=0. Signal 0 is not sent; the kernel performs the permission-and-existence check and skips
the delivery. It is the standard way to ask "is this pid still alive and may I signal it".

**8.**
```
bash: kill: (99999) - No such process
rc=1
```
The two failures are **no such process** and **permission denied** — and both give rc 1, which is why
`kill -0` answers "can I signal it", not "does it exist".

## Default behaviour

**9.** It died silently. You sent TERM, the default, and `bin/plain` installs no traps, so the
kernel's default action for TERM applied: terminate.

**10.** `rc=143`.

**11.** 143 − 128 = 15 = TERM. `kill -9` gives **137**, because 128 + 9.

**12.** `kill -INT` gives **130**. Chapter 8's Ctrl-C at a pipeline gave you 130 and its `SIGPIPE`
deaths gave 141 = 128 + 13.

**13.**
```
plain: pid 7712, no traps, up for 3s
plain: finished normally
exit 0 (not a signal death)
```

**14.** You killed the `plain`, not the reporter — `pkill -f 'bin/plain'` matches on the full command
line and the reporter's is `bin/signal-report bin/plain 30`, which *also* contains that string. On
this container both matched, so read the report carefully; a tighter pattern is
`pkill -f '^bin/plain'`. That is lesson 04's subject and it is worth meeting it as a mistake first.

**15.** That an exit status is a convention, not a fact. `128+N` is what the *shell* reports for a
signalled child, and a program is free to `exit 143` for its own reasons. The status narrows the
possibilities; it does not close them. To be certain you need the waiter's own account — `wait`'s
status in the shell that started it, or an entry in a log.

## Handlers

**16.** `trap 'CODE' SIG` tells the shell: when SIG arrives, run CODE instead of the default action.
The disposition becomes *handled*.

**17.**
```
catcher: caught TERM, ignoring it
```
It printed and carried on. TERM asked; the program declined.

**18.** Every time. A handler is a standing disposition, not a one-shot — it stays installed until
the process changes it with another `trap` or `trap - SIG`.

**19.** HUP prints its own line and it survives that too. QUIT does nothing at all, which is not what
the table predicts — QUIT's default is terminate. Exercises 23 and 24 are the explanation and it is
not about QUIT.

**20.** `kill -9` and it is gone, rc 137, with nothing printed. There is no handler it could have
written: KILL is not deliverable to user code. Nothing in the script, in bash, or in any language
could have survived it.

**21.** `trap` alone prints the traps installed in *this* shell. After `trap 'echo ouch' USR1`,
`kill -USR1 $$` prints `ouch`. Your interactive shell is a process like any other and you have just
installed a handler in it.

**22.** `trap - USR1` restores the default, and USR1's default is **terminate** — so `kill -USR1 $$`
closes that shell. That is why the exercise says to do it in a throwaway `bash`. USR1 and USR2 are
"the program decides" signals, and if the program decided nothing, they kill it.

**23.** Backgrounded from this non-interactive script, the INT handler never runs. Under `bash -ic`
it prints `catcher: caught INT, ignoring it`. Same script, same signal, different outcome.

**23a.**
```
$ bin/catcher 60 & grep -E 'SigIgn|SigCgt' /proc/$!/status
SigIgn:	0000000000000006
SigCgt:	0000000000014001
```
`0x6` is binary `110`: bits 1 and 2, which are signals **2 and 3 — INT and QUIT**. The script asked
for neither. It inherited them.

**23b.** `0x14001` is bits 0, 14 and 16: signals **1, 15 and 17 — HUP, TERM and CHLD**. CHLD is
bash's own; the script's own three `trap` lines wanted HUP, TERM and INT, and **INT did not take**.
The `trap` line ran, printed no error, and installed nothing.

**24.** `trap -p INT` in the child prints:
```
trap -- '' SIGINT
```
An empty action — the inherited ignore — not the handler that was just requested. bash honours an
inherited SIG_IGN and refuses to override it, silently.

**24a.** Ctrl-C at your terminal goes to the whole foreground process group. Without this rule, a
script that backgrounds a long job would have that job flattened by a Ctrl-C aimed at the script, and
"press Ctrl-C to stop watching" would mean "and also destroy the thing you were watching".

**25.** Use **TERM**. It is deliverable in every context, it is `kill`'s default, and no shell
quietly disarms it behind your back. A handler that relies on INT works from a keyboard and stops
working the moment your script is called by another script — which is the day it matters.

## What 9 costs

**26.** Before: `scratch/tidy-8112.work`. After `kill $!`:
```
tidy: caught TERM, removing /labs/.../scratch/tidy-8112.work and exiting
```
and the directory is clean.

**27.** With `-9` the work file is still there, and nothing was printed. **`kill -9` does not stop a
program politely; it stops the program before the cleanup code, so the mess it was going to tidy up
is now yours.**

**28.** TERM: rc **0** — it caught the signal, cleaned up and exited deliberately, so it reports
success. KILL: rc **137**. The 0 is the one that says "left properly", and note that it is
indistinguishable from a normal finish, which is what the author intended.

**29.**
```
scratch/tidy-8140.work
scratch/tidy-8146.work
scratch/tidy-8152.work
```
A year of this is a directory with a few hundred stale files, each named after a pid that was reused
long ago, none of them removable by any rule you can write without knowing which pids were real. It
fills a filesystem slowly and it destroys the meaning of "there is a work file, so a job is running".

**30.** `rm scratch/tidy-*.work`. What would have cleaned up automatically is TERM plus the patience
to wait for it — usually under a second. That is the entire cost.

**31.** Concretely: it does not flush a buffered write, so the last few kilobytes of a log or a data
file are lost. It does not remove a lock file or a pid file, so the next start refuses to run. It
does not finish a half-written record, so a file that was valid before is now truncated mid-line and
the reader downstream fails on a line nobody wrote.

**32.** TERM; wait five to ten seconds, because that is longer than any sane cleanup; TERM again in
case the first was missed; wait again; then KILL, and write down that you had to. Escalation with a
wait between steps is the whole idea — sending TERM and KILL in the same second means you sent KILL.

## Stopping and continuing

**33.** `T`. Stopped, by a signal, not scheduled.

**34.** `TIME+` does not advance — it counts CPU time and a stopped process gets none. It **does**
hold its memory: RSS in `top` is unchanged. It **does** hold its open files: `ls -l /proc/<pid>/fd`
still lists them. Stopping frees exactly one resource.

**35.** `S` — sleeping, its normal state, and it resumes where it was.

**36.** Nothing visible happens: the process is still `T`. The TERM is recorded as pending, and it is
delivered the instant you `CONT` it — the process dies immediately on resume, having never run
between the two signals. A stopped process cannot act on anything, including its own death.

**37.** Ctrl-Z sends **TSTP (20)**, which is catchable — so an editor or a pager can save state,
restore the terminal, and *then* stop. STOP is uncatchable and reserved for when you do not care what
the program thinks. A keyboard key should be the polite one.

**38.** No CPU, all of its memory. Which is why "suspend it and deal with it later" is a fix for a
process eating the processor and no fix at all for one eating RAM.

## Families

**39.** A signal goes to the process you named. Not to its children, not to its group unless you
asked for a group. Killing a parent leaves the children running.

**40.**
```
orphan-demo: pid 7715
orphan-demo: child is 7716, and I am leaving now
  child: pid 7716 ppid 7709
$ ps -o pid,ppid,stat,args -p 7716
   7716     1 S    bash bin/orphan-demo 6
```
ppid is now **1**. The parent exited and the kernel re-parented the orphan.

**41.**
```
   7716     1 Z    [bash] <defunct>
```
State **Z**. It is a **zombie**: the process is dead, and all that remains is its entry in the table,
holding its exit status for a parent that has not asked.

**42.** rc 0 and nothing changed. Both halves are correct: the send succeeded — pid 7716 exists as a
table entry and you had permission — and the delivery was meaningless, because there is no process
left to act on it. A zombie is already dead. There is nothing there to kill.

**43.** 14, and it climbs every time you run `bin/orphan-demo`. On this station they never go down.

**44.**
```
      1 sleep           sleep infinity
```
pid 1 here is not an init. It is a placeholder that keeps the container alive, and it never calls
`wait()`, so every orphan that dies stays in the table until the container restarts.

**45.** The **parent reading the exit status** — `wait()` in C, `wait` in the shell. That is the only
thing that clears a zombie. If the parent is gone, the job passes to pid 1, and if pid 1 does not do
it, nothing does. Time does not help; `kill` cannot help.

**46.** Bookkeeping. A zombie holds no memory and no CPU — just a slot in the process table and its
pid. The resource that runs out is **pids**, and when it does, `fork()` starts failing across the
whole machine and the symptom looks nothing like the cause.

**47.** After TERM to the outer `bash`, both `plain` processes are still there with **ppid 1**. They
are pid 1's children now, doing exactly what they were doing. "I killed it" was true and did not
mean what it sounded like.

## Reporting

**48.** "It was killed: status 137 is 128 + 9, so something sent it SIGKILL. The status does not say
who or why — it could be an operator, the OOM killer, or a supervisor's timeout — so I would look at
what else on the box logs at that timestamp before I say more."

**49.** From `notes/page.txt`, the five claims:
- *"-9 is just the strong version"* — **false**, and the most expensive kind of false. It is the
  version that skips the program's own shutdown.
- *"-9 always works"* — **true but dangerous**. It works on a running process, and it does nothing at
  all to a zombie or to a process stuck in uninterruptible sleep (`D`), which is when people usually
  reach for it.
- *"-9 leaves things behind"* — **true**, and the reason for the whole lesson.
- *"never use -9"* — **false**, and unhelpful. Sometimes there is nothing else, and pretending
  otherwise means people use it in a panic instead of on purpose.
- *"if you have to use -9, something else is wrong"* — **true**, and the useful one. It is a
  diagnosis, not a rule.

**50.** "Reach this line only after TERM has been sent twice with at least ten seconds between them
and the process is still in state `S` or `R`. If it is in `Z` this line will not help. If it is in
`D` this line will not help either. Record the pid and the full command line before you run it."

## Experiment

**51.** The second TERM arrives while the handler is running. Bash does not queue standard signals:
the handler is not re-entered, and the second TERM is remembered as *pending* and runs the handler
once more after the first one returns. So you get the message twice, thirty seconds apart, not two
overlapping handlers. Sending it five times still gets you exactly one extra run.

**52.** `trap 'echo bye' EXIT` fires on a normal exit, and it fires on TERM too — bash runs the EXIT
trap after the signal handler, and the status is still 143. It cannot fire on **KILL**. Nothing can.
That is the same fact as exercise 20, wearing a different hat.

**53.** `sleep` is blocked in a system call the kernel can interrupt, so delivery is immediate: TERM
arrives, the default action runs, done. `bin/catcher` does `sleep 1 & wait $!` rather than `sleep 1`
because **bash does not run a trap while it is waiting on a foreground child** — it finishes the
child first. With `wait`, the signal interrupts `wait` itself, the handler runs at once, and the
worst case delay is the remaining second.

**54.** `kill -TERM 1` returns 0 and pid 1 is untouched. The protection also covers **STOP** — the
kernel will not deliver a default-disposition stop to pid 1 either, because a frozen pid 1 is a
system that never reaps anything again and can never be resumed by anything inside it. KILL is the
exception with no exception: pid 1 can be killed by the kernel, and when it is, the container or the
machine goes down with it. That is the same rule stated from the other side.

**55.** From an interactive shell, `kill -TERM $$` closes the shell — and if it was your login shell,
the session ends. In a script, the same line ends the script with status 143. The difference is not
in the signal; it is in what that particular process was doing for you.

## Stretch

**56.**
```bash
gently() {
  local pid=$1 i
  kill -TERM "$pid" 2>/dev/null || { echo "gently: no such process $pid"; return 1; }
  for i in 1 2 3 4 5; do kill -0 "$pid" 2>/dev/null || { echo "gently: $pid exited"; return 0; }; sleep 1; done
  echo "gently: $pid ignored TERM, sending it again"
  kill -TERM "$pid" 2>/dev/null
  for i in 1 2 3 4 5; do kill -0 "$pid" 2>/dev/null || { echo "gently: $pid exited"; return 0; }; sleep 1; done
  echo "gently: ESCALATING TO KILL on $pid -- state was $(ps -o stat= -p "$pid")"
  kill -9 "$pid"
}
```
`bin/plain` and `bin/tidy` both exit on the first TERM. Only `bin/catcher` reaches the last line, and
that is the point of the loud message: reaching it is a finding.

**57.**
```
$ timeout 3 bin/catcher 60; echo rc=$?
catcher: caught TERM, ignoring it
...
rc=124
$ timeout -s KILL 3 bin/catcher 60; echo rc=$?
Killed
rc=137
```
124 is `timeout`'s own status meaning "I timed out" — note it is *not* 143, because `timeout` reports
the timeout, not the child's death. `-k DURATION` gives you the escalation built in: TERM, then KILL
after the grace period. You would still write `gently` yourself when you need to signal something you
did not start, which `timeout` cannot do at all.

**58.**
```bash
cleanup() {
  rm -f "$work"
  trap - TERM       # restore the default disposition
  kill -TERM $$     # and now let it do what it would have done
}
trap cleanup TERM
```
The handler removes itself first, so the second TERM finds the *default* disposition and the process
dies of the signal properly — the waiter sees 143 rather than 0. `exit 0` from a handler tells your
caller you finished normally, which is a lie that will cost somebody an afternoon.

**59.** No. KILL is acted on by the kernel without the process being consulted, so there is no code
path to put anything in. What people who claim otherwise have actually done is one of: a supervisor
that notices the death and starts a new process (a different process, same name); a process stuck in
uninterruptible sleep `D`, where the KILL is pending and will be acted on the moment the driver
returns; or a zombie, which is not surviving anything.

**60.** Its full command line (`/proc/<pid>/cmdline`), its environment (`/proc/<pid>/environ`) and its
open files (`/proc/<pid>/fd`, or `lsof -p`). **All three die with the process.** The pid, the start
time and the parent you can recover from logs afterwards; what the process was *told* when it started
exists nowhere but inside it. That is lesson 06, and it is the whole reason the incident says to
trace before you signal.
