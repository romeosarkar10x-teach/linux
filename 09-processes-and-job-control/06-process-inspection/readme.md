# 09/06 — Process inspection

> A running process carries its whole configuration in memory, and the kernel will show it to you. A
> process's environment survives nowhere else. Kill it and you lose the evidence.

Every lesson so far has asked *which* processes exist. `ps` lists them, `top` ranks them, `pgrep`
selects them, `kill` ends them. This lesson asks the question those tools cannot answer: **what is
this particular process actually doing?**

The answer is `/proc`. Every running process has a directory named for its pid, and that directory is
not storage — it is the kernel answering questions, formatted as files. The sizes are all zero and
mean nothing; every read is a fresh reading taken at the moment you read it. `ls -l /proc/4210/` is
one of the more informative minutes you can spend on an unfamiliar system.

What you get from it:

- **`cmdline`** — the exact argv the process was started with. Not `ps`'s rendering of it: the
  original, NUL-separated, which is why `cat` runs the arguments together and `tr '\0' '\n'` is the
  read.
- **`environ`** — the environment it was *given*. Mode `-r--------`: the owner and root, nobody else.
- **`cwd`**, **`exe`**, **`root`** — symlinks, live. `cwd` is where it is now, not where it started.
- **`fd/`** — one symlink per open descriptor, including pipes, terminals, and files that have been
  deleted while still open.
- **`status`** and **`stat`** — the same summary twice, once for you and once for a program, including
  the signal masks you decoded in lesson 03.

Then `lsof` and `fuser`, which answer the question from the other end: *given this file, who has it
open?* That is how you find out who is holding a filesystem busy, and how you recover a log that was
deleted while a process was still writing to it — the bytes are not freed until the last descriptor
closes, and `/proc/<pid>/fd/9` is a working handle to them.

Finally `nice` and `renice`: the one knob you have over CPU priority, with a ratchet on it. A normal
user may raise a process's niceness and may never lower it again, not even back to where it started.
That is worth knowing *before* you type it.

The sentence at the top of this page is the reason this lesson sits where it does. Everything in
`/proc` exists only while the process runs. There is no copy on disk, no log, nothing to recover
afterwards. In the next lesson something has been running since October under an account that is not
a person, and the only record of why is inside it.

## Objectives

- [ ] Describe `/proc/<pid>/` as a kernel interface, and say why its file sizes are 0
- [ ] Read `cmdline` and `environ` correctly, and explain the NUL separator
- [ ] State who may read another process's `environ`, and prove it
- [ ] Read `exe`, `cwd` and `root`, and say why `exe` may not name the command you typed
- [ ] Show that `cwd` is a live reading by watching it change
- [ ] List a process's open files with `/proc/<pid>/fd`, and identify pipes and terminals
- [ ] Recover the contents of a deleted-but-open file through `/proc`
- [ ] Read `status` for state, ppid, uid/gid, groups and signal masks
- [ ] Find the state letter, ppid and start time in `stat`
- [ ] Use `lsof -p`, `lsof PATH`, `lsof -u`, `lsof -c` and read the FD column
- [ ] Use `fuser` and `fuser -v` to find who is holding a path
- [ ] Set niceness with `nice`, change it with `renice`, and read it with `ps -o ni`
- [ ] State the ratchet rule, and demonstrate the permission error
- [ ] Explain why `nice -n -5 cmd` exits 0 for a normal user
- [ ] Say what niceness does not affect

## The lab

```
cd /labs/09-processes-and-job-control/06-process-inspection
```

`bin/tagged` is an ordinary sleeper you can start with an unusual environment. `bin/wanderer` changes
its own working directory while it runs. `bin/holdopen` creates a file, opens it, deletes the name and
keeps writing. `bin/reader-of` holds a file open so you can find it from the other end. `bin/spin`
burns actual CPU, for `nice`; it is the only thing in this course that does, so do not leave it
running.

`notes/proc.txt`, `notes/open-files.txt` and `notes/priority.txt` are the references.
`notes/page.txt` is rhea, asking for exactly this lesson and telling you not to kill the thing first.

Wrecked it? `kestrel reset 09/06`.
