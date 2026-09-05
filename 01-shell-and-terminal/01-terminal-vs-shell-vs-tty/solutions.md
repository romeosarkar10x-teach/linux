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

---

## Added exercises 16–52

### 18 — `$0` in three shells
Login shell → `-bash` or `bash`; inside `bash` → `bash`; inside `sh` → `sh`. `$0` is the name the
shell was *invoked as*, not the path to the binary and not a reliable statement of which shell it
is. A leading `-` means a login shell. `ps -p $$ -o comm=` is the honest answer.

### 20 — the four columns
`pid` this process. `ppid` the process that started it. `tty` the terminal it is attached to, or `?`
for none. `comm` the executable name, without arguments.

### 22 — `ps -p $PPID`
The parent shell — the one you were in before you typed `bash`. `$PPID` is set by the shell for
itself; it is not the same thing as `$$` of the parent, though it holds the same number.

### 23 — the parent of the login shell
Inside the course container it is typically the container's init or the `docker exec` process; on a
VM it is `sshd`, `login`, or the terminal emulator. The difference from exercise 22: the child shell
was started *by you*, so you can name the parent from memory. The login shell's parent is whatever
the system used to hand you a session, and you can only find it by looking.

### 24 — writing to a tty device
The text appears in the session sitting on that tty. `echo` put it there in the ordinary way — it
wrote bytes to a file. The terminal is on the other end of that file, so the bytes get drawn.

### 26 — what a tty device file is
It is a handle to a kernel device, not a place bytes are stored. Writing to it hands the bytes to
the terminal driver, which passes them to whatever is displaying that terminal; reading from it
takes keystrokes.

### 28 — bare `cat`
Standard input, which is your tty — `/dev/pts/N`, the same file exercise 24 wrote to. Leave with
`Ctrl-d`, which is end-of-input, not a kill.

### 29 — two destinations
Both are files in the filesystem, and neither stores anything. `/dev/null` discards; the tty
displays. The shell's `>` does not know or care about the difference.

### 32 and 33 — `MARKER` in the other session
Empty both times. `export` makes a variable available to *child processes of this shell*. The other
session's shell is not a child of this one — it descends from a separate login. Nothing a shell sets
in memory reaches a sibling session; a file does, which is what exercise 31 showed.

### 35 — `tty` inside `$(...)`
`echo "$(tty)"` usually prints `not a tty`. Command substitution replaces the inner command's
standard output with a pipe so the shell can capture it — which is exactly the exercise-4 situation.
The device did not change; what `tty` was handed did.

### 36 — `ps | cat`
Output is the same content, but the `ps` process itself appears differently: piping adds `cat` to
the tty's process list, so one more line. Unlike `ls`, `ps` does not reformat by destination.

### 37 and 38 — three nested shells
Four `bash` processes on the tty: the original plus three. `$$` in the innermost never matches the
outermost; each `bash` is a new process with a new PID, and `$$` is per-process. `exit` four times
to leave, or three to get back to where you started.

### 39 — closing the window
The child dies with the rest of the session — the terminal going away sends `SIGHUP` down the
session. Chapter 9 names the signal and shows how `nohup` and `disown` opt out of it. Accept any
answer that observes the death without claiming to know the mechanism yet.

### 43 — why `$SHELL` lies
It is an environment variable, set at login from the account's configured shell in `/etc/passwd`.
It is inherited by children unchanged, so it keeps saying `/bin/bash` inside `sh`, inside `dash`,
inside anything. The running shell is `ps -p $$ -o comm=`.

### 45 — the tree (Dig)
`ps --forest`, or `ps -ef --forest`, or `ps f`. Any of them show the nested shells indented under
each other.

### 47 — `/dev/tty` (Dig)
`/dev/tty` is a per-process alias for *the controlling terminal of whatever is reading it*. It is
the same destination as your `/dev/pts/N` from your own session, and a different one from another
session. They differ whenever the writer has no controlling terminal — a process started detached
gets an error from `/dev/tty` while `/dev/pts/3` still works.

### 48 — session leader (Dig)
`ps -o sid,pid,comm -p $$`. A session leader is the process whose PID equals the session ID; for a
login shell they match. A child shell has the same SID and a different PID, so it is not a leader.

### 49 — the pty limit (Dig)
`/proc/sys/kernel/pty/max` — 4096 in this image. `/proc/sys/kernel/pty/nr` is the current count.

### 50 — `stty -a` (Dig)
The `intr = ^C;` field in the second block. It is a terminal setting, not a shell setting, which is
why it survives starting a new shell and why `stty intr ^X` changes it for everything on that
terminal at once.

### 51 and 52 — breaking and fixing the terminal (Dig)
`cat /bin/ls` sprays bytes that the terminal interprets as escape sequences, leaving it in an
alternate character set with echo off. `reset` fixes it; `stty sane` fixes most of it. What was
broken belonged to neither the shell nor `cat` — it was *terminal state*, held by the terminal
driver, which is the whole point of this lesson.
