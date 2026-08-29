# 09/05 — Job control

> Your shell can hold more than one thing at a time. Everything you background here dies when you log
> out — unless you say otherwise, which is a sentence somebody typed eight months ago.

A shell runs one command and waits for it. That is the whole model you have been using since Chapter
1, and it is a good model right up to the first time you need two things at once: a long copy and a
look at the log it is writing, a monitor left running while you keep working, a command you started
that you now wish you had not started in the foreground.

Job control is the shell's answer. It is small — about eight commands and a handful of `%` specs —
and it is worth learning exactly rather than approximately, because the approximate version leaves
processes on the station and no record of who left them.

**A job is not a process.** A job is a *pipeline* the shell started: `sort big | uniq -c | head` is
one job and three processes. The shell numbers jobs per shell, starting at 1, and reuses numbers as
jobs finish. Two shells on the same machine each have a job 1 and they are unrelated. `jobs` is not a
station-wide view of anything; it is one shell's memory of what it started, which is why `ps` and
`jobs` disagree constantly and both are correct.

**Backgrounding.** `cmd &` starts the job and gives you the prompt back, printing `[1] 4210` — job
number and pid. `Ctrl-Z` stops the job you are already running and hands you back the prompt with the
job in state `T`, exactly the state you produced with `kill -STOP` in lesson 03. From there `fg`
resumes it in the foreground and `bg` resumes it in the background. A stopped job is *not* a paused
idea; it is holding its memory, its open files and its place in the terminal.

**Terminals are shared badly.** A background job still has your terminal for output, and it will
write into the middle of what you are typing. What it cannot do is read: the kernel stops a
background job that tries to read from the terminal, with `SIGTTIN`, and `jobs` reports
`Stopped (tty input)`. That message means "this job wants the keyboard and is not allowed to have
it", and the fix is `fg`, not `kill`.

**Then the part this chapter is really about.** When the shell goes away, what happens to its jobs?
The rules are: the kernel sends `SIGHUP` to the foreground process group if the terminal itself dies;
bash sends `SIGHUP` to its jobs on `exit` only if `huponexit` is set *and* it is a login shell; and
`nohup`, `setsid` and `disown` each break that chain in a different way. On this station `huponexit`
is off, so a plain `cmd &` usually survives — "usually" being the word that has left processes
running here since last October.

You will finish this lesson able to say, of any running process, whether the shell that started it
could still kill it. That is precisely the question lesson 07 asks about a summariser nobody
scheduled.

## Objectives

- [ ] Define a job, and say why one job can be several processes
- [ ] Start a job with `&`, read the `[n] pid` line, and use `$!`
- [ ] Stop a foreground job with `Ctrl-Z` and resume it with `fg` or `bg`
- [ ] Read `jobs`, `jobs -l`, `jobs -p`, `jobs -r`, `jobs -s` and the `+`/`-` markers
- [ ] Use every job spec: `%n`, `%%`, `%+`, `%-`, `%prefix`, `%?substring`, and predict `ambiguous job spec`
- [ ] Signal a job with `kill %n` and say what signal that sends
- [ ] Use `wait`, `wait %n` and `wait $!`, and read the status they return
- [ ] Recognise `Stopped (tty input)` and explain SIGTTIN
- [ ] State the three rules that decide whether a job survives its shell
- [ ] Test `shopt huponexit` and demonstrate that it only bites in a login shell
- [ ] Use `nohup`, and say exactly when `nohup.out` is created and when it is not
- [ ] Use `disown` and `disown -h`, and say what each removes and what each keeps
- [ ] Use `setsid`, and read the resulting `ppid`, `sid` and `TT` in `ps`
- [ ] Explain why job control is off in scripts and what `set -m` changes

## The lab

```
cd /labs/09-processes-and-job-control/05-job-control
```

`bin/` holds five programs to background: `talker` (writes on both streams, on a timer),
`quiet-work` (says nothing until it finishes), `reader` (wants a line of input), `counter` (appends
to a file so you can watch it from outside) and `hupper` (records the fact that it received HUP, so
you have evidence after the shell that started it is gone).

`notes/jobs.txt` is the job-control reference, `notes/survival.txt` is the survival rules, and
`notes/page.txt` is rhea asking the two questions this lesson answers. Her second question is the
one lesson 07 turns on.

Wrecked it? `kestrel reset 09/05`.
