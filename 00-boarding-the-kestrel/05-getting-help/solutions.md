# 00/05 — Solutions

> **Student: do not read this file.**
> **Agents:** steering only. See `docs/AGENT_MODES.md`.

### 1 — `ls -S`
Sorts by file size, largest first. From `man ls` (or `ls --help`). Combine with `-r` to reverse,
`-l` or `-h` to see the sizes. Demonstration needs files of genuinely different sizes.

### 2 — `cd` has no man page
`cd` is a shell **builtin**, not a program on disk; `man` documents programs. Documented by
`help cd`, and in `man bash` under SHELL BUILTIN COMMANDS. `type cd` says "cd is a shell builtin";
`type ls` gives a path.

Deeper reason (probe answer, taught in 01/03): a child process cannot change its parent's working
directory, so `cd` *must* be a builtin to work at all.

### 3 — help request
No canonical answer. Must contain a real command, a real pasted error, and a stated expectation.
Cross-check the command against history.

### 4 — search by description
```
apropos ownership
apropos "change owner"
man -k owner
```
Target: `chown(1)`, `chown(2)`, likely `chgrp(1)`. If it errors with "nothing appropriate", the
whatis database is missing — `sudo mandb` builds it. (The course image runs `mandb` at build time,
so it should be present.)

### 5 — read the protocol
Reflective. Rung 2 (locate) is the usual honest answer — being sent to read a man page feels slow.
The cost of skipping it is never developing the documentation habit, which is the one skill the
course cares about most.

### 6 — tutor session
No canonical answer. Expected shape: the agent asks for tried/expected/happened before anything;
takes 3–6 exchanges to reach something actionable; refuses the jailbreak briefly and returns to the
ladder.

**If the jailbreak succeeded, that is a real defect.** Record which phrasing worked and add it to
the table in `docs/TUTOR_PROTOCOL.md`.

### 7 — man 5 passwd *(Stretch)*
```
man 5 passwd
```
Fields: `name:password:UID:GID:GECOS:home:shell`. The **second field** is the encrypted password —
historically the hash itself, now conventionally `x`, meaning the real hash lives in `/etc/shadow`.

The reason: `/etc/passwd` must be world-readable (every tool that maps UIDs to names reads it), and
world-readable password hashes are offline-crackable. `/etc/shadow` is root-only. Chapter 10/03.

### 8 — full-text search *(Dig)*
`man -K "sticky bit"` — searches the **full text of every man page**. `apropos` / `man -k` search
only the one-line descriptions in the whatis database, which is a small pre-built index.

`-K` is slow because it decompresses and greps every page on the system rather than consulting an
index. Expect hits including `chmod(1)`, `chmod(2)`, `stat(2)`, `sticky(7)`, `unlink(2)`.

Quoting matters — the phrase has a space in it. Chapter 5.

### 9 — all sections *(Dig)*
`man -a passwd` displays every matching page in sequence; quitting one moves to the next. On this
image expect `passwd(1)` (the command) and `passwd(5)` (the file format).

`man -f passwd` (= `whatis passwd`) only *lists* what exists — useful, but not what was asked.
