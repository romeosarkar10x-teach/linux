# 09/01 — What a process is

> Sixty people asleep and the station's CPU is at a permanent low simmer. Something is awake.

You have spent eight chapters on files. A file sits still. This chapter is about the other half of
the machine: the things that are *running*, which move while you look at them, and which you cannot
open with `cat`.

A **program** is a file on disk. A **process** is one running instance of one. That distinction is
not pedantry — it is the reason the same `sleep` can be running six times and there is still only one
`sleep` in `/opt/kestrel/bin`. Six processes, one file. When rhea says "the summariser is running",
she is not talking about a file. When you say "I deleted it", you are.

Every process the kernel keeps has a number, a **pid**, unique while it lives and reused after it
dies. It has a **ppid**, the pid of whatever started it. It has a user, a current directory, a copy of
an environment, and the command line it was started with. Chapter 12 will use the environment against
somebody. Right now the point is that all of it is visible from outside the process, without asking
the process anything.

Processes are made in two steps, and the split is the single most useful thing in this lesson.
`fork()` duplicates the calling process — two processes now exist, identical except for their pids.
`exec()` replaces a process's program with a different one — same pid, same ppid, new code, nothing
created and nothing destroyed. Running `ls` at a prompt is a fork followed by an exec in the copy;
your shell is untouched, which is why it is still there afterwards. `cd` does neither, because there
is no program to run, which is why `cd` cannot be a separate command.

The lab has `bin/nest`, which execs itself four times. Watch its pid while it does. It does not
change. That is not a trick; that is what exec is.

Then you learn to look. `ps` has two argument styles, from two Unix lineages, and both work:
`ps -ef` gives you the parent column, `ps aux` gives you the resource columns. Neither is more
correct. `ps` with no arguments gives you almost nothing and is the default, which catches everybody
once. `ps -eo` lets you name the columns you want, and by the end of this lesson you should be
reaching for that. `pstree` draws the parent relationships you would otherwise reconstruct by eye.

One warning that matters for the rest of the chapter. The `CMD` column is the process's **argv** —
whatever it was started with — and argv is set by the caller, not by the kernel and not by the file
on disk. It is a label. It is usually true. In Chapter 12 it will not be.

## What you will be able to do

- [ ] State the difference between a program and a process, with an example of one program and many processes
- [ ] Read pid, ppid, user and start time for any process on the station
- [ ] Explain `fork` and `exec` separately, and say what each one does to the pid
- [ ] Say why `cd` is a builtin and `ls` is not, and prove it with `type`
- [ ] Read `ps -ef` and `ps aux`, and name which column you get from which
- [ ] Build a `ps -eo` line with exactly the columns a question needs
- [ ] Draw the process tree with `pstree -p` and find a given process's ancestors
- [ ] Explain what pid 1 is and why it has no parent
- [ ] Say what the `CMD` column really shows, and why it is a claim rather than a fact

## Files

```
bin/whoami-really   prints its own pid, ppid, user, argv0, cwd
bin/sleeper N LABEL sits still for N seconds; parent of its own sleep
bin/nest N          execs itself N times, then sleeps
bin/forker N        starts N background children and reports their pids
bin/spin N          burns CPU for about N seconds (you will need it in 09/02)
notes/process.txt   the model: pid, ppid, fork, exec
notes/ps.txt        reading ps, both argument styles
notes/page.txt      rhea, 04:30
scratch/            yours
```

Nothing in this lesson runs in the background on its own. Every process you meet is one you started,
and it dies when you stop it or when its timer runs out.
