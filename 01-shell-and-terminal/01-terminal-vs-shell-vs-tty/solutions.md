# 01/01 — Solutions

> **Student: do not read this file.**
> **Agents:** steering only. See `docs/AGENT_MODES.md`.

No flag in this lesson. The chapter's flag is in `07-incident-01`.

### 1 — tty, PID, program
```bash
tty          # /dev/pts/0
echo $$      # 2417
ps -p $$     # 2417 pts/0  00:00:00 bash
```

### 2 — whoami vs id
`whoami` → `cadet`. `id` → `uid=1000(cadet) gid=1000(cadet) groups=1000(cadet),27(sudo),1001(crew)`.
The fact unique to `id`: the numeric uid/gid, and supplementary group membership. Group membership
is what actually decides file access, so `id` is the one that explains a permission error.

### 3 — processes on your tty
`ps` — bare. Lists the shell and `ps` itself. `ps` appears because it is a live process at the
instant it reads the process table; it cannot exclude itself without lying.

### 4 — not a tty
```bash
tty            # /dev/pts/0
echo hi | tty  # not a tty
```
The program did not change. Its standard output was replaced by a pipe, so there is no terminal on
that end to name. `tty < /dev/null` also works and is arguably cleaner — it changes the *input*,
which is what `tty` actually inspects.

### 5 — ls through a pipe
```bash
ls consoles          # multiple columns
ls consoles | cat    # one name per line
```
`ls` calls `isatty()` on its output. Human on the other end → columns, which fit more on a screen.
Program on the other end → one record per line, which is parseable. The same reasoning makes `grep`
colour matches on screen but not into a file.

### 6 — child shell
```bash
echo $$   # 2417
bash
echo $$   # 2588
exit
echo $$   # 2417
```

### 7 — three deep
Three `bash` invocations, then `ps` shows four `bash` lines plus `ps`. Three `exit`s to get back.
A fourth `exit` would end the original shell and the session.

### 8 — SHELL vs ps
```bash
echo $SHELL   # /bin/bash
dash
echo $SHELL   # /bin/bash   <- unchanged
ps -p $$      # ... dash
```
Trust `ps -p $$`. `$SHELL` is set once at login from the account record and never updated by
running a different shell.

### 9 — the device file
```bash
ls -l "$(tty)"
crw--w---- 1 cadet tty 136, 0 ...  /dev/pts/0
```
Leading `c` — a character device. The `136, 0` where a size would normally be are the major and
minor device numbers.

### 10 — two sessions (Experiment)
Different ttys (`pts/0`, `pts/1`) and different PIDs. Each `kestrel enter` allocates a new
pseudo-terminal and starts a new shell process. The common wrong prediction is that the PIDs will
be adjacent numbers — often they are close, but nothing guarantees it, and other processes started
in between will have taken numbers.

**Grading note:** a wrong prediction, correctly explained afterwards, is a full pass. A missing
prediction is not.

### 11 — exit and the child (Experiment)
The child is gone from `ps` entirely. Its PID is not reused immediately — Linux allocates PIDs
roughly sequentially up to a maximum and then wraps, so reuse takes thousands of process creations.
Nothing remains of an exited process once its parent has collected its exit status.

### 12 — identify this session (Stretch)
```
cadet@kestrel  bash  pts/0  pid 2417
```
from `whoami`, `hostname`, `ps -p $$`, `tty`, `echo $$`. Anything with all five facts passes. The
tty and PID are the two that distinguish this session from another one by the same user on the same
host.

### 13 — tty3 vs pts (Stretch)
`tty3` in the roster is a hardware console — a device wired to a physical screen and keyboard on
deck 3, reachable by Ctrl-Alt-F3 at that console, and it exists whether or not anyone is logged in.
`/dev/pts/0` is a pseudo-terminal created by software when the session started, and it disappears
when the session ends.

### 14 — parent PID (Dig)
```bash
ps -o pid,ppid,comm -p $$
```
`ps -f -p $$` also shows PPID. The parent is whatever started the shell — in the container, the
process from `docker exec`, or the outer shell if they nested.

Found via `man ps` → STANDARD FORMAT SPECIFIERS → `ppid`, used with `-o`.

`cat /proc/$$/status | grep PPid` is correct and worth acknowledging, but it sidesteps the man-page
skill this exercise exists to drill.

### 15 — who and w (Dig)
`who` lists login sessions: user, tty, login time. `w` lists the same sessions plus load average,
idle time, and — the difference — the `WHAT` column, the command each session is currently running.

`w` first, on a machine you suspect someone else is on: it tells you not just that they are there
but what they are doing.
