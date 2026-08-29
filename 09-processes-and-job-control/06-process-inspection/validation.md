# 09/06 — Validation

For the validator agent. No script grades this lesson. There is no flag in it. What you are checking
is whether the student can interrogate a process they did not start — and whether they know what dies
with it.

## Pass requires all of these

1. **`/proc` is an interface, not storage.** They can say the sizes are 0 because the content is
   produced at read time, and they can name the filesystem type (`proc`).
2. **`cmdline` and `environ` read correctly**, with `tr '\0' '\n'`, and they can explain the NUL
   separator without being prompted.
3. **The permission fact, stated precisely.** `environ` is mode `-r--------`: the owning user and
   root. Not "it is private" — the mode, and who root is.
4. **The evidence sentence.** Ask directly: where else is a running process's environment written
   down? The answer is *nowhere*, and it is destroyed when the process exits. A student who hedges
   here has missed the lesson.
5. **`cwd` is live.** They watched `bin/wanderer` move and can say why "where it started" is not
   recoverable from `cwd`.
6. **`exe` names the interpreter.** A bash script's `exe` is `/usr/bin/bash`; `sleep`'s is a multicall
   coreutils binary. They should know `fd/255` is where bash holds the script.
7. **Deleted-but-open, demonstrated.** They read content through `/proc/<pid>/fd/9` after the name was
   gone, and can state that the space is freed when the last descriptor closes, not when the name is
   removed.
8. **`lsof` and `fuser` from the file's end.** `lsof PATH`, `fuser -v PATH`, and reading the FD column
   (`cwd`, `rtd`, `txt`, `mem`, and numbered descriptors with `r`/`w`/`u`).
9. **The nice ratchet.** A normal user raises niceness only; `renice 0` back down gives
   `Permission denied`; only root reverses it. And `nice -n -5 cmd` runs the command and exits with
   the *command's* status, so `$?` does not tell you whether the nice took.
10. **Niceness is CPU only**, and does nothing for a job blocked on I/O.

## Good answers to listen for

- On 52: any sensible order, but `environ` and `cmdline` should come before anything that risks the
  process, and they should say why.
- On 55: a real `environ` can contain tokens, paths that identify people, and internal hostnames.
  "Redact nothing, it is just variables" is wrong.
- On 60: to answer "whose cwd is under /labs" you must be able to read each `/proc/<pid>/cwd`, and
  you will silently miss every process owned by another account. That limitation is lesson 07's whole
  shape.
- On 65: the list should mark `environ`, `cwd`, `fd` and the open-file contents as *lost on death*,
  and start time, uid and command line as recoverable from `ps` while it lives — and from nothing
  afterwards.

## Answers to push back on

- "`ps` shows the command line, so `cmdline` is redundant." Ask about arguments containing spaces,
  and about a command line longer than `ps` chooses to print.
- "`environ` shows the current environment." It shows what the process was given; a process can alter
  its own copy, and exercise 63 is where they should have thought about this. Accept a careful answer,
  reject a confident one with no experiment behind it.
- "Renice it and it will speed up." Ask what the process is waiting for.
- "The deleted file is gone." Ask what they read in exercise 28.

## Cross-checks

- Lesson 03: `SigIgn`/`SigCgt` in `status` should be second nature by now.
- Lesson 04: `comm` is the 15-character name in `status`'s `Name:` field; they should connect the two.
- Lesson 05: a setsid'd process's ppid of 1 was explained there; here they can add `cwd`, `environ`
  and `fd` to what they can still learn about it.
- Forward: if the student's answer to 54 is a capture command they actually tested, tell them to keep
  it. They will want it in the next lesson.
