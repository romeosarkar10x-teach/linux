# 08/01 — Solutions

Every command here was run in the lab container. Where a number depends on what else is seeded on
your station, it says so.

## Warmup

**1.** 0 stdin, 1 stdout, 2 stderr. The habit worth building is thinking of them as *numbers*, not
names — the redirection syntax next lesson is all numbers, and `2>` will read as gibberish until
`2` means something to you.

**2.** All three point at the same terminal device:

```
$ fdreport
fd 0 -> /dev/pts/0
fd 1 -> /dev/pts/0
fd 2 -> /dev/pts/0
```

The number after `pts` may differ. This is why the split is invisible: your terminal is one bucket
and both output streams pour into it with nothing marking which was which.

**3.** `$$` is the PID of the running shell — here, the `fdreport` script itself. `$(readlink
/proc/self/fd/1)` would have been evaluated inside a command substitution, and a command
substitution's stdout **is the substitution pipe**, so fd 1 would have read `pipe:[…]` no matter
what you typed on the command line. The first draft of this lab had exactly that bug and reported
a pipe for a plain terminal run. Reading your own state through a mechanism that changes that state
is a real class of mistake, not a curiosity.

**4.** Three, plus one more:

```
$ ls -l /proc/$$/fd
0 -> /dev/pts/0
1 -> /dev/pts/0
2 -> /dev/pts/0
255 -> /dev/pts/0
```

255 is bash's own — it keeps a private copy of the terminal (or, when running a script, of the
script file) so that a command which mangles fd 0/1/2 does not cost the shell its own I/O.

**5–7.** Screen order at a terminal is roughly the order things were written, but the six complaint
lines and the ten report lines are visually identical in kind. Almost everybody guesses `6 panels
checked` is a complaint (it is not: fd 1) and `clamp applied 2 times this run` is a report (it is
not: fd 2). Guessing is the point of the exercise.

fd 1 (ten lines): the title, two rule lines, six `panel p-… ok` rows, `6 panels checked`.
fd 2 (six lines): two clamp warnings, `clamp applied 2 times this run`, the `see /var/tmp/…` line,
`written by dorn, 2186-04`, and the parenthetical.

**8.** Yes, correct. Every clamp line, the summary of clamps, and the provenance lines are things a
downstream parser should not have to skip. The panel rows are the answer. dorn got this right, and
`notes/dorn-readme.txt` says the first version got it wrong.

## Counting the two streams

**9.** `10`.

**10.** `0`, because a pipe connects **fd 1 of the left-hand command to fd 0 of the right-hand
command** and nothing else. `>/dev/null` sent fd 1 to the void, so the pipe carried nothing. The
complaints went to your terminal, over the pipe's head — you saw them, `wc` did not.

**11.** The answer is `panelcheck 2>&1 >/dev/null | wc -l`, and if you tried
`panelcheck >/dev/null 2>&1 | wc -l` you got `0` and no idea why. Both are next lesson.

**12.** `6`. 10 + 6 = 16, which is what you saw on screen.

**13.** `rc=0`.

**14.** It is not a bug. "Failed" means the program could not do its job; "clamped" means it did its
job and the job included bringing two readings back into band. The status code answers *did you
finish*, not *is everything fine on deck 05* — those are different questions and only one of them
has a number.

**15.** `8`. `grep` was on the other end of a pipe, so it only ever saw fd 1: the title line, six
panel rows, and `6 panels checked`. The two `panel p-b/p-e: reading out of band` lines contain
`panel` and were on your screen, but they arrived on fd 2 and never entered the pipe. **This is the
single most useful fact in the lesson**: a filter cannot filter what it was never given.

## Proving they are separate

**16.** The six complaint lines stay on screen; the ten report lines go to the file. In the file,
`fd 1 -> /tmp/o.txt`. fd 0 and fd 2 are unchanged.

**17.** `/tmp/e.txt` is empty — `fdreport` never writes to fd 2. Its three lines are all on fd 1,
including the line *about* fd 2. Worth sitting with: a program describing fd 2 does not have to use
fd 2.

**18.**

```
fd 1 -> pipe:[22703164]
```

The number is the pipe's **inode number** in the kernel's anonymous pipe filesystem. There is no
path because a pipe has no name — that is what makes it a pipe. Two processes sharing a pipe show
the same number, which is how you match up the ends of one in `/proc`.

**19.** fd 0 becomes the absolute path of `data/decks.txt`. `fdreport` never reads it. It does not
have to: the descriptor is set up by the shell before the program starts, so "where does my stdin
come from" is answerable without reading a byte.

**20.** Every write to fd 1 fails, so the program cannot report anything — including the fact that
it cannot report:

```
fdreport: line 8: printf: write error: Bad file descriptor
readlink: write error: Bad file descriptor
fdreport: line 11: printf: write error: Bad file descriptor
```

The errors you *do* see came out on fd 2, which is still open. A program with no stdout is mute on
the subject of its own muteness, and this is precisely why `2>&1` gets written the wrong way round
by people who never see a complaint about it.

**21.** `rc=1` — from `fdreport`, which exits with the status of its last command, and that command
failed to write. bash reported the write error but did not invent the status.

**22.** Five lines in the file (`out 1`…`out 5`); the five `err` lines went to your terminal.

**23.** Mirror image: five `err` lines in the file, five `out` lines on screen. Nothing is lost
either way — redirection moves a stream, it does not drop it. The only way to drop one is to aim it
at `/dev/null`, and that is a choice you have to type.

**24.** Ten lines, alternating `out 1 / err 1 / out 2 …`. A reasonable sentence: "it made fd 2 point
at whatever fd 1 was pointing at". That is exactly right, and the whole of next lesson is about the
word *whatever* — it means "at that moment", and moments have an order.

**25.** No. Both streams here are unbuffered small writes from bash; most compiled programs
**buffer** fd 1 in ~4 KB blocks when it is not a terminal, while fd 2 stays unbuffered, so a
redirected stdout can appear all at once at the end while stderr arrives live.

## stdin

**26.** Prompt `which deck? ` on fd 2, answer `deck 05: crew accessible` on fd 1. Both on screen,
and only redirection can tell them apart.

**27.** A pipe. `fdreport` under the same pipe would have shown `fd 0 -> pipe:[…]`.

**28.** `read -r deck` reads **one** line. The other three lines stay in the file, unread; nobody is
obliged to consume all of stdin. The program answers for `03` and exits.

**29.** `askdeck: not a deck: 99` on fd 2, `rc=4`.

**30.** `rc=3`. `/dev/null` read from gives immediate end-of-file — zero bytes, no error. So `read`
returns false and the script takes its "no input" branch. `< /dev/null` is the standard way to
promise a program that it will never get input, and it is how you stop something that might block
on a prompt.

**31.** `1` then `0`. In the failure case fd 1 got nothing at all, so `wc -l` counted zero lines,
while the message travelled to your terminal on fd 2 and never entered the pipe. A pipeline that
"prints an error but produces no data" is not a contradiction — it is the two streams doing their
jobs.

**32.** 0 accepted, 3 nothing on stdin, 4 not a deck. From the messages alone you could distinguish
them here because they are worded differently, but that is the author's courtesy, not a rule. The
status is the machine-readable answer and it is the one a script should test.

## The rule, applied

**33.**

| line | stream by the rule | what panelcheck does |
|---|---|---|
| `panel diagnostic, deck 05` | arguable — it is a header, not data | fd 1 |
| `panel p-a   42   ok` | fd 1, it is the answer | fd 1 |
| `clamp applied 2 times this run` | fd 2, it is a summary about the run | fd 2 |
| `6 panels checked` | arguable, leaning fd 2 | fd 1 |

Two of the four are genuinely debatable, and saying so is the correct answer. Headers and totals are
where real tools disagree with each other — compare `wc`'s `total` line (fd 1) with `du -s`'s
behaviour, or `grep --count` with `grep -r`'s filename prefixes.

**34.** The listing of `/labs` is on fd 1; `ls: cannot access '/nosuchplace': No such file or
directory` is on fd 2. Proof: `ls /labs /nosuchplace 2>/dev/null` keeps the listing, `ls /labs
/nosuchplace >/dev/null` keeps only the complaint. `ls` also exits **2** here, which you will use in
`05-exit-codes-and-chaining`.

**35.** The first proves the listing survives without the complaint (so the complaint was on fd 2);
the second proves the complaint survives without the listing. The line count from the first depends
on how many chapters your station has seeded — the number is not the point, the survival is.

**36.** `cp -v` writes `'a.txt' -> 'b.txt'` on **fd 1**:

```
$ cp -v a.txt b.txt 2>/dev/null      # line still appears
$ cp -v a.txt c.txt >/dev/null       # line disappears
```

By the readme's rule that is arguably wrong — `cp`'s "answer" is the copied file, not a log line,
and a script doing `cp -v … | something` gets progress in its data. GNU's position is that `-v` was
explicitly asked for, so it is the output you requested. Both readings are defensible; being able to
*test* which one a tool chose, in two commands, is the skill.

**37.** Open. Good candidates: `wc`'s `total`, `rm -v`, `tar -v`, `find`'s permission-denied lines,
`sort --debug`.

## Reporting

**38.** Model answer: "panelcheck writes its report on one stream and its warnings on another, and
your terminal shows you both at once. It clamped two panel readings, said so on the warning stream,
and finished normally — you can see the report on its own with `panelcheck 2>/dev/null`."

**39.** The summariser would have read the clamp lines as if they were panel rows: extra records in
the middle of the table, with the wrong number of fields. Depending on how it parsed, it either
crashed, or — much worse — counted eight panels on a six-panel deck and reported a clean total.

**40.** Only that the program considered itself finished. Not that its output is complete, not that
its input was valid, not that nothing was wrong on the deck. Exit 0 is a claim about the program,
not about the world.

## Experiment

**41.** For example:

```bash
#!/usr/bin/env bash
echo "result line 1"
echo "note: this is not a result" >&2
echo "result line 2"
```

`./s.sh 2>/dev/null` gives two lines, `./s.sh >/dev/null` gives one.

**42.** The test that matters is `./s.sh bad | wc -l` printing `0` while the message is still on
your screen — that is the pipeline behaviour from exercise 31, reproduced by you on purpose.

**43.** `grep -c '^panel p-'` still gives 6 either way, because the clamp lines do not start with
`panel p-`… which is the trap. Use `grep -c panel`: it goes from 8 to 10 once the clamps join fd 1.
A downstream tool that trusted "one line per panel" now sees ten lines for six panels. Anchoring
your pattern saved you here by accident; separating the streams would have saved you on purpose.

**44.** Both positions are defensible:

- **exit 1 on clamp**: the caller can then react without parsing text, which is the entire point of
  status codes.
- **exit 0 on clamp** (dorn's): clamping is normal operation, and a status that fires on normal
  operation is one that gets ignored within a week.

The right answer on a real station is usually a third one: a distinct non-zero code for "completed,
with clamps" — say 10 — so a caller can tell the three cases apart. What is not defensible is
choosing either without being able to say what the caller does with it.

**45.** Nothing changes because the script never writes to fd 3; the shell opened it and no code used
it. To see it you would add `3` to the loop's list. `/tmp/x.txt` is created — empty — because the
redirection happens whether or not it is used.

**46.** fd 1 is a pipe (into `head`); fd 0 and 2 are unchanged. The `$$` warning is real: in
`bash -c 'echo $$' | cat`, `$$` is the *parent* shell's PID, not the subshell's, because `$$` is
deliberately not updated in subshells. Use `$BASHPID` when you mean "this process".

## Stretch

**47.** Two lines with `>>`:

```
panelcheck > /tmp/both.txt
panelcheck 2>> /tmp/both.txt
```

The interleaving is **not** preserved — that is two runs, and all the stdout precedes all the
stderr. To keep the order you would have to keep them in one process, which is what `2>&1` is for.
Checking is the point: if you cannot state what you gave up, you have not solved it.

**48.**

```bash
#!/usr/bin/env bash
for fd in 0 1 2; do printf 'fd %s -> ' "$fd"; readlink "/proc/$1/fd/$fd"; done
```

Works for your own processes. For another user's you get `Permission denied` on the `fd` directory —
`/proc/<pid>/fd` is mode 500 and owned by the process's user. Root, or the same user, or nothing.
Chapter 9 goes further into `/proc`.

**49.** The first day somebody pipes it, or redirects it into a file that another tool reads, or runs
it from a script instead of by hand — which is to say the first day it is used the way tools are
meant to be used. The person paged is whoever owns the tool that received a progress bar where it
expected data, and they will spend the morning blaming their own parser.

**50.** Open. The strongest real case is `wc`'s `total` line, or `grep -r`'s `filename:` prefixes,
or `find`'s `Permission denied` lines drowning a legitimate result set. Argue from the rule, not
from taste.

**51.** `a | b | c`: fd 1 of `a` is a pipe to fd 0 of `b`; fd 1 of `b` is a pipe to fd 0 of `c`; fd 1
of `c` is the terminal. All three fd 2s are the terminal. So of the six output descriptors, **four**
point at your terminal and two are pipes. That is why a noisy middle stage of a pipeline is invisible
in the output and unmissable on the screen.

## Authoring notes

- `fdreport` uses `/proc/$$/fd`, not `/proc/self/fd`. The first draft used `self` inside `$( )` and
  reported `pipe:[…]` for fd 1 at a plain terminal, which would have taught the exact opposite of the
  lesson. Verified after the fix: three `/dev/pts/0` lines at a tty.
- Counts verified in the container: 10 lines on fd 1, 6 on fd 2, `panelcheck | grep -c panel` = 8,
  `panelcheck 2>/dev/null | grep -c panel` = 8, exit status 0.
- `askdeck` exit codes verified: 0, 3 (`</dev/null`), 4 (`echo 99 |`).
- `fdreport >&-` verified to produce three write errors and `rc=1`.
- `cp -v` verified to write on fd 1 in this image (coreutils 9.11).
- Exercise 35's line count is deliberately left unstated in the solution: it depends on how many
  chapters the student's station has seeded.
