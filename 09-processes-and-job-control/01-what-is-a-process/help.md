# 09/01 — Help

Read this when you are stuck. It does not contain answers.

## "My pid is different every time I run the same command"

Correct. A process is one *run*. The program file does not change; the running instance is new each
time, and it gets a new number. If two runs had the same pid at the same time, the number would be
useless as an address.

## "ps shows almost nothing"

Plain `ps` filters twice: your user, and your terminal. That is the default and it is rarely what you
want. Add `-e` for every process. When you find yourself piping `ps` into `grep` to select rows,
check first whether a `ps` option selects them for you: `-p`, `-u`, `-U`, `-C`.

## "-ef or aux?"

Neither is more modern; they come from two different Unix families and `ps` accepts both. The dash
matters: `ps -e` and `ps e` are not the same request. If you want to stop guessing, use `ps -eo` and
name your columns.

Columns worth knowing by name: `pid`, `ppid`, `user`, `comm`, `args`, `etime` (wall-clock age),
`time` (CPU consumed), `stat`, `%cpu`, `%mem`, `rss`, `nice`. A trailing `=` on a column suppresses
its header, which is what makes `ps -eo` output safe to pipe.

## "I started one command and ps shows two processes"

Read the script. If it runs another command in the normal way, there are two processes: the script
and the thing it started. That is the fork model doing exactly what it says. `exec` is the word that
collapses them into one.

## "nest prints four lines but only one pid — is it broken?"

No. That is the demonstration. `exec` does not make a process; it changes which program an existing
process is running. Same pid, same ppid, same open files, different code. If you want the version
that makes four processes, take the `exec` out.

## "I killed the parent and the child is still there"

Yes. Signals go to the process you name. Children are not included and are not notified. When a
parent dies first, its children are re-parented to pid 1 and keep running. This is the correct
behaviour and it will bite you again in 09/04 — notice it now.

## "grep keeps matching itself"

`ps -e | grep sleep` runs a `grep` whose own argv contains `sleep`, so it matches itself. Habits:
`grep -v grep` afterwards, or `pgrep`, which you meet in 09/04.

## "What is the difference between TIME and ELAPSED?"

`etime`/`ELAPSED` is wall-clock age: how long ago it started. `time`/`TIME` is CPU time consumed. A
process asleep for eight months has an enormous `etime` and a tiny `time`. A process spinning for a
minute has a small `etime` and a `time` almost as large. That gap is a diagnosis, and you will use it.

## "Is the CMD column reliable?"

It is reliable as a record of what the caller passed. It is not proof of which program is running.
`/proc/PID/exe` is the kernel's answer and cannot be spoofed by the caller; `comm` sits in between.
The lab's `nap` experiment is there so you meet a program that decides what it is from its own name.

## Where to look

- `notes/process.txt` — the model, in one page
- `notes/ps.txt` — the column and option reference for this lesson
- `man ps` — long, but "STANDARD FORMAT SPECIFIERS" and "PROCESS STATE CODES" are the two sections
  you actually want
- `man pstree`, `help type`, `help exec`

## Still stuck

Say what you ran, what you expected, and what you got. If the confusion is about pids, include the
`ps -eo pid,ppid,args` output — with the `ppid` column, because without it nobody can help you.
