# 09/01 — Solutions

Answer key. Every number below was measured in the lab container; pids will differ on your run, the
relationships will not.

## Warmup

**1.** rhea wants the *skill*, on purpose: "I do not want a report, I want you to know how to find out
what is running before you need to." She is not asking for a diagnosis of the load. Learn it on
something harmless.

**2–3.** `$$` is the shell's own pid. `$PPID` is whoever started that shell. In a container session
the parent is often gone already and `$PPID` reads `0`, or `ps -p $PPID` returns nothing — a
container has no login manager and no terminal server above you. On a normal machine you would see
`sshd`, a terminal emulator, or `login`.

**4.** Different, and they must be. `bin/whoami-really` is a *new process* — the shell forked and the
copy exec'd bash on the script. `$$` inside the script is the script's own pid.

**5.** `pid` changes every run (new process each time). `ppid` is constant — your shell started all of
them. `user`, `argv0` and `cwd` are constant. Pids increase but are not guaranteed to; they wrap.

**6.** The `ppid` printed is your shell's `$$`. Compare directly.

**7.** `cd` must change the *calling shell's* current directory. A separate program runs in a forked
child, and a child cannot change its parent's cwd — a child gets a copy of the parent's state, not a
handle on it. So a `cd` program would change its own directory and then exit, achieving nothing. This
is the single clearest consequence of the fork model.

**8.** Measured: `type` builtin, `echo` builtin, `grep` is `/opt/kestrel/bin/grep`, `kill` builtin.
`type -a echo` shows four: the builtin, `/opt/kestrel/bin/echo`, `/usr/bin/echo`, `/bin/echo`. The
builtin wins — builtins are looked up before `PATH`. To get the file you name it: `/usr/bin/echo`, or
`env echo`. Same for `kill`, `printf`, `test`.

## ps, the short way

**9.** Plain `ps` selects on two things at once: your uid *and* your controlling terminal. `ps -e`
drops both filters. In the lab container with a terminal, plain `ps` shows 2 processes and
`ps -e --no-headers | wc -l` shows 4.

**10.** With no terminal, "processes on my terminal" has no members — but `ps` falls back to showing
your processes anyway, which is why the answer looks inconsistent between a script and a prompt.
Measured: `tty` prints `not a tty` and exits 1 in a non-interactive `docker exec`, and plain `ps`
there listed pid 1, the script's bash, and `ps` itself. Never build a script on plain `ps`.

**11.** `UID PID PPID C STIME TTY TIME CMD`. `C` is a crude recent-CPU number; `TIME` is cumulative
CPU time consumed, not wall-clock age.

**12.** `USER PID %CPU %MEM VSZ RSS TTY STAT START TIME COMMAND`. New here: `%CPU`, `%MEM`, `VSZ`,
`RSS`, `STAT`. Missing here: `PPID`.

**13.** "Who started this" → `ps -ef` (it has PPID). "What is eating the machine" → `ps aux` (it has
%CPU, %MEM, RSS). Or stop choosing and use `ps -eo` with the columns you want, which is the real
answer.

**14.** Measured: pid 1 is `sleep infinity`, owned by cadet, ppid `0`. On a normal Linux box it would
be `systemd` or `init`; in a container it is whatever the image was told to run, and here that is a
placeholder that does nothing but keep the container alive.

**15.** Pid 1 is started by the kernel, not forked from a userspace parent, so there is no parent pid
to report and `ps` prints 0. It is also special in another way you meet in 09/03: it inherits
orphans.

**16.** Measured 4 with nothing running. A desktop machine runs 200–400. A container is one namespace
holding the processes somebody asked for, and nothing else — no login manager, no logging daemon, no
scheduler. Remember that sentence for Chapter 9's incident: **nothing on this station schedules
anything.**

## ps, your way

**17.** `--sort=pid` is easier because pids are roughly creation order. Neither is a tree: both are
flat lists, and reconstructing parenthood by eye from a PPID column is exactly the work `pstree`
does for you.

**18.** `ps -eo pid,etime,comm -u cadet` — or `ps -U cadet -o pid,etime,comm`. Naming the columns is
the point; do not select with `grep`.

**19.** Pid 1, by a wide margin — measured `03:26` elapsed when everything else was under a second
old. It should not surprise you: pid 1 is as old as the container.

**20.** `comm` is the process's *name* — a short field, truncated to 15 characters, taken from the
executable. `args` is the full command line including every argument. Measured: `comm` = `sleep`,
`args` = `sleep 20`.

**21.** The trailing `=` sets an empty header for that column, so `ps` prints no header line at all.
That is what makes `ps -eo comm=` safe to pipe into `sort` — otherwise the header sorts in with the
data, which is the same class of bug as counting a comment line as an entry in Chapter 6.

**22.** Varies with what you are running. With three sleepers up, `sleep` dominates.

**23.** For example: "There are four `sleep` processes and one `sleep` program. `/opt/kestrel/bin/sleep`
is a file; each of those four is a running instance of it, with its own pid, its own arguments and
its own deadline."

## fork and exec, watched live

**24–26.** Measured:

```
alpha: pid 166 ppid 159, sleeping 20s
    166     159 bash bin/sleeper 20 alpha
    168     166 sleep 20
```

Two processes: the script (166) and the `sleep` it started (168). 166 is the parent — 168's PPID
column is 166. That is the proof; print order proves nothing.

**27.** Measured: `bash(159)-+-bash(166)---sleep(168)`. Chain: your shell → the sleeper script →
`sleep`.

**28.** The script runs `sleep "$secs"` as an ordinary command: fork, then exec in the child. The
script stays alive to wait for it. Add `exec`: `exec sleep "$secs"` replaces the script's own program
with `sleep`, so there is one process instead of two and it keeps pid 166.

**29.** Measured: killing the sleeper leaves the child alive with **ppid 1**:

```
    748       1 sleep 30
```

Killing a parent does not kill its children. The orphan is re-parented to pid 1. This is the single
most common wrong assumption about `kill`, and 09/03 and 09/04 are largely about it.

**30–31.** Measured:

```
nest level 4: pid 175 ppid 159
nest level 3: pid 175 ppid 159
nest level 2: pid 175 ppid 159
nest level 1: pid 175 ppid 159
```

One pid for all four. `exec` keeps the **same process** and gives it a **different program**. Nothing
is forked, so nothing new appears; nothing exits, so nothing disappears.

**32.** Measured: `bash /labs/.../bin/nest 1`. The argv is whatever the *last* exec supplied, and the
last one was called with `1`. The `4` you typed is gone — overwritten in the same process. First
warning that argv is a claim.

**33.** Without `exec` you get four bash processes in a chain, each the child of the previous, plus
the `sleep`. `pstree -p` draws a five-deep line. The pids are all different.

**34.** …replaces the program running inside an existing one.

**35.** Measured: `forker: pid 64` with children 67, 68, 69. One command shows all four:
`ps -eo pid,ppid,args | grep -v grep | grep -E 'forker|sleep 40'`.

**36.** The ppid of all three children is the forker's pid. `sleep 40 &` is fork *and* exec: fork to
make the child, exec to turn the child from a copy of bash into `sleep`.

**37.** `nest` is a straight line (or a single node, with `exec`); `forker` is a fan — one parent,
three siblings. The source difference is the loop with `&`: three forks from one parent, versus one
process replacing itself.

**38.** Measured: `ps -p 99999` prints the header and exits **1**. So `ps -p "$pid" >/dev/null` is a
liveness test you can put in an `if`, exactly like `grep -q` in Chapter 6. (It is not a *safe* one —
see exercise 57.)

## The CMD column is a claim

**39.** `comm` comes from the kernel's copy of the executable's name; `args` is the argv the caller
supplied. `args` is the one under the caller's control.

**40.** Measured:

```
$ cp /opt/kestrel/bin/sleep ./nap
$ ./nap 2
coreutils: unknown program 'nap'
rc=1
```

`/opt/kestrel/bin/sleep` is a symlink to a single **multicall** binary: one file that implements every
coreutils tool and decides which one to be by looking at **argv[0]** — the name it was invoked under.
Copied to `nap`, it looks at its own name, does not recognise it, and refuses. A program's idea of
what it is can come from its argv, which comes from its caller.

**41.** Measured: `comm` reads `sleep`, not `bash`. Bash saw that the whole `-c` string was a single
external command and `exec`'d it directly instead of forking a child. Same optimisation, same
mechanism as `bin/nest`.

**42.** For example: "The `CMD` column shows the arguments the process was started with. It is set by
whoever started the process, it can be anything, and it is not evidence of which program is running."

**43.** Measured: `/opt/kestrel/bin/sleep` → the coreutils multicall binary in the Nix store. `comm`
still says `sleep`, because `comm` follows the invocation name, not the resolved file.

**44.** Measured: `/proc/$$/exe` is a symlink to `/usr/bin/bash`. That link is maintained by the
kernel and cannot be set by the caller. Ranking for an argument: `/proc/PID/exe` first, `comm`
second, `args` last. You will use `/proc` properly in 09/06.

## Reporting

**45.** Two reasonable first commands, and what each rules out:
`ps -eo pid,ppid,user,etime,comm --sort=-etime` — is anything old that should not be? and
`ps aux --sort=-%cpu | head` — is anything *currently* burning CPU, or is the load coming from short
work repeated? If nothing is old and nothing is hot, the load is not a single runaway and you look
elsewhere.

**46.** For example: "I do not know yet what is awake. I am going to list every process on the
station with its parent, its owner and how long it has been running, and start from whatever is
oldest. I will tell you what I find, including if it is nothing."

**47.** Three meanings: (a) a process with that name exists right now; (b) it is scheduled and runs
periodically; (c) somebody started it once and it never exited. `ps -eo pid,etime,args | grep
summaris` tells them apart: no line means (a) is false; a line with a small `etime` fits (b); a line
with an enormous `etime` is (c). Hold on to this exercise. It is the chapter.

## Experiment

**48.** Three sleeper scripts plus three `sleep` children is six, plus the `grep` itself if you forget
`grep -v grep` — which is why every command in this key has it.

**49.** Sorting by ppid groups siblings, so a fan of children started by one parent lands in one
block. Fastest way to spot "one thing started forty things".

**50.** Bare `pstree` on this station is almost empty, so it is fine here. On a real machine it is
hundreds of lines and the subtree view is the only usable one. The whole-station view is worse
whenever you already know which process you care about.

**51.** Measured, two seconds into a `bin/spin 6` and a `bin/sleeper 6 q`:

```
    755 R    bash            bash bin/spin 6
    756 S    bash            bash bin/sleeper 6 q
    758 S    sleep           sleep 6
```

`R` is runnable — on a CPU or waiting for one. `S` is interruptible sleep — blocked, waiting for
something, consuming nothing. Sleeping is the normal state; almost everything on a healthy machine is
`S`. A process that is `R` and stays `R` is the shape of this chapter's incident.

**52.** Measured: `time bin/spin 5` gives 4.269s real on one measured run. `bin/spin` computes its deadline from
whole seconds, so starting part-way through a second costs it up to one second. Read the comment;
the script says so. This is a lab toy, not an instrument.

## Stretch

**53.**

```bash
ancestors() {
  local pid=$1
  while [ -n "$pid" ] && [ "$pid" -ne 0 ] 2>/dev/null; do
    ps -o pid=,comm= -p "$pid" || break
    [ "$pid" -eq 1 ] && break
    pid=$(ps -o ppid= -p "$pid" | tr -d ' ')
  done
}
```

The `tr -d ' '` matters: `ps -o ppid=` right-aligns in a padded field, and the spaces break the
arithmetic test.

**54.** `kids() { ps -eo pid=,ppid=,args= | awk -v p="$1" '$2==p'; }` — an `awk` field comparison, not
a `grep`, because a `grep` for a pid matches any column that happens to contain those digits.

**55.** `family` is the two above plus a `ps -p "$1"` in the middle. On a nonexistent pid the naive
version prints nothing at all, silently — which looks identical to "a real process with no
children". It should say so and exit non-zero. Chapter 8's lesson, applied here.

**56.** Pid 1 is the container's placeholder and it is as old as the container, which is normal and
not evidence of anything. The check that settles it: `ps -p 1 -o args=` — if pid 1 is the thing the
image was built to run, there is nothing to explain.

**57.** The sequence: a script records pid 4021; the process at 4021 exits; the kernel allocates pids
forward and eventually wraps; something unrelated is started and receives 4021; the script wakes up
and signals 4021. Nothing in `ps` will tell you this happened, because the pid is genuinely alive and
genuinely not the process you meant. The defence is to check *identity*, not existence — start time,
argv, `/proc/PID/exe` — before acting on a stored pid.

## Flag

None. Chapter 9's flag is in `07-incident-09`, and it is in a running process's environment. When you
get there: trace it before you signal it.
