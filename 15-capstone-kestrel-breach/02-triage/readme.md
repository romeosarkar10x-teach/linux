# 02 — Triage

Before you reconstruct what happened, establish what is happening. Who has an
account on this station, which of those accounts can log in, and what is
running right now that nobody remembers starting.

Triage is observation only. Nothing in this lesson is stopped, killed, chowned
or fixed. That is lesson 04, and doing it early destroys the evidence lesson 03
needs.

## Accounts are not people

`/etc/passwd` is a seven-field, colon-separated text file, one line per account:

```
ops-bot:x:1004:1007::/home/ops-bot:/usr/sbin/nologin
  name  pw  uid  gid  gecos   home        shell
```

The `x` means the password hash lives in `/etc/shadow`, which is root-only.
`getent passwd NAME` asks the same question through the system's account
lookup and exits **2** if the name does not resolve — which is a cleaner test
than grepping, because grep matches substrings and `getent` matches accounts.

Two distinctions that matter for the report:

- **uid ranges.** Under 1000 is conventionally system; 1000 and up is a human
  account created by an administrator. Convention, not enforcement.
- **the shell field.** `/usr/sbin/nologin` means the account cannot start an
  interactive session. It does **not** mean nothing runs as that account. A
  process can be started as a nologin user by anything with the privilege to
  do so — including `sudo -u`.

> An account with no shell that owns a running process is not a contradiction.
> It is the normal way automation is run, and it is also the reason automation
> is a convenient thing to run something under.

## What is running

```
ps -ef                       every process, parent pid included
ps aux                       every process, with %CPU and %MEM
ps -eo pid,ppid,user,etimes,lstart,cmd    pick your own columns
pgrep -u ops-bot -a          pids owned by a user, with their command lines
pstree -ps PID               the ancestry of one process
```

`etimes` is elapsed seconds; `lstart` is the absolute start time. For a process
that has been running for months, `lstart` is the one that belongs in a report.

`ps` is a snapshot of `/proc`, and you can read `/proc` directly:

| path | holds |
|---|---|
| `/proc/PID/cmdline` | the argv, NUL-separated |
| `/proc/PID/status` | name, state, `PPid`, real/effective `Uid` and `Gid` |
| `/proc/PID/cwd` | symlink to the working directory |
| `/proc/PID/fd/` | one symlink per open file descriptor |
| `/proc/PID/environ` | the environment it was started with, NUL-separated |

`cmdline` and `environ` are NUL-separated, so pipe them through
`tr '\0' '\n'`. Most of `/proc/PID/` is readable only by the process's owner
and root.

> **The redirection gotcha.** `sudo cat /proc/PID/environ` works.
> `sudo tr '\0' '\n' < /proc/PID/environ` does **not** — the shell opens the
> file to build the redirection *before* `sudo` runs, and the shell is you.
> Chapter 8 explained why; this is where it bites.

## Open files

`lsof -p PID` lists what one process has open; `lsof -u NAME` lists what a user
has open. The `FD` column is the descriptor number and its mode: `3w` is fd 3
open for writing, `cwd` and `rtd` are the working and root directories, `255r`
is the descriptor bash uses for the script it is executing.

A long-running writer that opened its log **once**, at startup, keeps that
descriptor for its whole life. Chapter 14 showed you what that means: delete
the log and the writer keeps writing into a file that no longer has a name.
`lsof` marks it `(deleted)`, and it is the single most useful thing `lsof`
tells you.

## The two logs

`access/eng-access.log` and `access/crew-shell.log` are copies, taken for this
review. Read them as evidence, which means: every account named in them is a
claim you can check against `/etc/passwd`, and a name that does not check out
is worth a line in the report on its own.

## Before you move on

- `getent passwd NAME` exits 2 for an account that does not exist.
- `nologin` prevents interactive login, not execution.
- `lstart` for old processes, `etimes` for arithmetic.
- `/proc/PID/cmdline` and `environ` are NUL-separated and mostly owner-only.
- A redirection is opened by your shell, not by `sudo`.
- `lsof` is how you find a file that is still being written and no longer
  exists.
