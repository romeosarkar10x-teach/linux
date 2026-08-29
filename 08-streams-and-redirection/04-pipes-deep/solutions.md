# 08/04 — Solutions: pipes, properly

Answer key and authoring notes. Every number was measured in the container. Students should not read
this file.

---

## Warmup

**1.** What goes down the pipe; exit status; subshells; SIGPIPE; buffering; `tee`.

**2.** They are two different mechanisms and rhea is right: the filter problem is `2>&1` on the wrong
side of the `|`; the burst problem is block buffering. Both are "nothing was touched and it broke",
which is why they arrived in one page.

**3.** `bin/noisy` prints 6 lines on fd 1 and 6 on fd 2. `bin/noisy 2>/dev/null` leaves `out 1..6`;
`bin/noisy 1>/dev/null` leaves `err 1..6`.

**4.** `pipe:[22072171]` — an anonymous pipe, identified by inode number. You cannot open it by name;
there is no name. (`/proc/PID/fd/0` is a handle to it, not a path to a pipe you could `cat`.)

**5.** The second stage's `date` fires about **1.004 s** after the first — measured
`1787997342.994917` then `1787997343.999192`. It had already started and was blocked in `read`.
`read` waiting proves the process existed the whole time.

**6.** Two. Evidence: `readlink /proc/self/fd/1` differs in each stage, both stages appear in `ps`
during a slow pipeline, and a variable set in one is invisible to the other (exercise 26).

**7.** Still 5. The three `cat`s cost three processes, three pipe buffers, and three copies of every
byte through the kernel — measurable but small (200 copies of `readings.txt` through ten `cat`s ran
in 0.268 s).

## Only fd 1 goes down the pipe

**8.** 6. The `err` lines came from `noisy`'s fd 2, which `|` does not touch; they went to the
terminal, past `wc` entirely.

**9.** 12. `2>&1` copied whatever fd 1 was **at that moment** — and the pipe had already been set up,
so fd 1 was the pipe.

**10.** `|&` is bash shorthand for `2>&1 |`.

**11.** `bin/noisy | wc -l 2>&1` prints 6 and the six `err` lines still hit the terminal. You
redirected **`wc`'s** stderr, which had nothing on it.

**12.** `bin/noisy 2>&1 >/dev/null | wc -l` → **6**. fd 2 is aimed at the pipe first, then fd 1 is
sent to `/dev/null`; only stderr goes down the pipe. (Lesson 02's trap, used deliberately.)

**13.** `bin/failmid | grep reading` prints three matched lines, and `failmid: bank B did not answer`
appears from fd 2. Useful: the error reaches a human even though the filter is discarding
non-matching lines. That is the reason the fd 1 / fd 2 split exists.

**14.** "Your filter only ever receives standard output; the warnings are on standard error, which
the pipe does not carry. Move `2>&1` to the left of the `|`." One token: `2>&1`.

**15.** `bin/noisy 2>&1 >scratch/out.txt | wc -l` → **6**, and `out.txt` has the 6 stdout lines.

## Exit status

**16.** `false | true` → 0. `true | false` → 1. The pipeline's status is the last stage's.

**17.** **0.** `failmid` exited 4 and the pipeline reported success.

**18.** `4 0` — first stage 4, second stage 0, left to right.

**19.** After `true`, `PIPESTATUS` is `0`. It is set by *every* command, so it is valid only
immediately after the pipeline, before anything else runs — including `echo`.

**20.** `bin/failmid | grep reading | wc -l` → `PIPESTATUS` = `4 0 0`: the producer failed, `grep`
found matches, `wc` counted. The failure is invisible in `$?`.

**21.**
```
{ bin/failmid 2>/dev/null; echo $? > scratch/rc; } | wc -l    # 3
cat scratch/rc                                                # 4
```
The stage is a subshell, so it cannot set a variable for you — but it can write a file (or an fd you
opened earlier). `PIPESTATUS` is the easier answer whenever you control the whole pipeline.

**22.** `rc=4`. `pipefail` makes the pipeline take the rightmost non-zero status.

**23.**
```
( set -o pipefail; bin/failmid | { cat >/dev/null; exit 7; }; echo "rc=$?" )   # 7
```
Rightmost non-zero wins, not largest, not first.

**24.** **141.** `head -1` exited after one line, `seq`'s next write got SIGPIPE, and `pipefail`
faithfully reported the resulting 141. A script with `set -o pipefail; set -e` and a `head` at the end
of a pipeline will abort on a completely normal event, intermittently, depending on timing.

**25.** `set -e` does **not** catch it: `( set -e; bin/failmid | wc -l; echo "still here rc=$?" )`
prints `3` then `still here rc=0`. `set -e` acts on the *pipeline's* status, which is the last
stage's, which was 0. `set -e` without `pipefail` is close to useless around pipelines.

## Subshells

**26.** `0`. Each stage is a separate process; the loop incremented `n` in a child that then exited.

**27.** `3`. `< <(seq 1 3)` is a redirection, so the loop runs in the current shell.

**28.** Heredoc form also gives 3. For "count lines of a command's output matching a pattern", the
honest answer is not a loop at all: `cmd | grep -c PATTERN`.

**29.** `3`. `lastpipe` runs the **last** stage in the current shell, but only when job control is
off — so it works in scripts and silently does nothing in an interactive shell. Portable code cannot
rely on it, and reading a script that does is confusing.

**30.** `seq 1 3 | read -r a` leaves `a` empty. Three fixes:
```
read -r b < <(seq 1 3)            # 1
read -r c <<<"$(seq 1 3)"         # 1
c=$(seq 1 3 | head -1)            # 1
```

## SIGPIPE

**31.** `head` exited after two lines; `yes`'s next write hit a pipe with no reader and the kernel
sent SIGPIPE, whose default action is to kill the process.

**32.** `PIPESTATUS` = `141 0`. 141 = 128 + 13; the shell reports "killed by signal N" as 128 + N, and
13 is SIGPIPE.

**33.** You do not see `countdown: finished all 30`. The writer died before reaching its last line —
a writer's cleanup, summary or flush may simply never happen.

**34.** `wc -l < scratch/big.txt` → about **10043** lines of the intended 100000, and `PIPESTATUS` is
`141 141 0`: `seq` **and** `tee` were both killed. The exact count varies with timing.

**35.** Loses data: `producer | tee audit.log | head -20` — your audit log is truncated at a random
point and nothing says so. Wanted: `find / | head -5`, where you genuinely want the search abandoned
rather than completed.

**36.** For: it is a non-zero status and a fatal signal, and `pipefail` reports it. Against: it is the
normal, designed way for a reader to say "enough", and the pipeline did exactly what was asked. A
script should treat 141 from a pipeline ending in `head`/`q`-style readers as success, and say so
explicitly rather than turning `pipefail` off.

**37.** Fast — about 0.4 s, not the 8 s of 40 ticks. Without SIGPIPE, `head` would have to keep
reading and discarding until the writer finished, or the writer would block forever on a full pipe.

## Buffering

**38.** In two seconds: nothing from `grep`, and two `slowtick: N ticks` lines on stderr (which never
entered the pipe). `timeout` exits **124**.

**39.** With `--line-buffered`: `tick 1`, `tick 2`, `tick 3` and the pipeline exits **0** well inside
the two seconds. One sentence: `grep`'s output was block buffered because its stdout was a pipe, so
`head` was still waiting for the first block.

**40.** `stdbuf -oL grep tick` works the same. `stdbuf` sets the stdio buffering mode of a program
that has no flag of its own, by preloading a library before `exec`. It cannot help a program that
does its own buffering.

**41.** The three spellings:
```
grep --line-buffered PATTERN
sed -u 's/x/y/'
awk '{print; fflush()}'
```
all measured working inside two seconds.

**42.** `cat` needed no flag: it reads a block and writes it straight out, so whatever arrives is
passed on. It has no line-oriented accumulation to delay.

**43.** `bufdemo` uses bash's `echo`, which issues a `write` per line and never buffers. The C stdio
rule applies to programs using stdio — which is most compiled tools and not the shell. This is
exactly why shell scripts hide the problem until somebody puts a compiled tool in the pipeline.

**44.** Not buffering. `wc -l` **cannot** produce an answer until it has seen end of input; there is
no partial answer to flush. `timeout` returns 124 and the `slowtick` stderr lines still appear.

**45.** Buffering (can stream, chooses not to when piped): `grep`, `sed`, `awk`, `tail -f`. Cannot
stream by nature: `wc -l`, `sort`, `tac`. `head` streams and then quits early, which is a third
category.

**46.** Ten-second test: run it against a slow producer with `head -1` on the end, under `timeout`. If
you get the line immediately it streams; if you get nothing, run it again with `stdbuf -oL` — if that
fixes it, it was buffering, and if it does not, the tool needs the whole input.

**47.** Same command, two destinations: `bin/slowtick 40 | grep tick` shows nothing for a long time;
`bin/slowtick 40 > /dev/null; grep tick file` is not the comparison — the right one is running
`grep tick` with its stdout on a terminal versus piped into `cat`. Nothing changed but fd 1.

## `tee`

**48.** Both **6**. `tee` passed everything on and kept a copy.

**49.** Both **12**. With `2>&1` before the pipe, `tee` also captured the six stderr lines.

**50.** Two runs into the same file: with `>` (inside `tee`'s default) the second run leaves 2 lines;
with `tee -a` twice you get **4**.

**51.** Three copies at that moment — `f1`, `f2`, and the stream on stdout (here sent to `/dev/null`).

**52.** `/dev/tty` is the controlling terminal of the process, whatever that is. `tee /dev/tty` gives
you a live look at what is flowing while the pipeline's real output goes on to the next stage — the
one place a copy is *not* redirectable away.

**53.** `tee >(wc -l > scratch/c1.txt)` writes **6** into `c1.txt`. Process substitution let `tee`
write into another *program* rather than a file, so the counting happened concurrently and no
intermediate file was needed. (Note that you may need to wait for it: the substituted process is not
part of the pipeline's wait set.)

**54.** `$?` is 0 and `PIPESTATUS` is `4 0`. `tee` does not and should not change status — its job is
to copy bytes. Use `PIPESTATUS` or `pipefail`.

**55.** Not possible as written: exercise 34 showed `tee` itself gets SIGPIPE. Options: put the `head`
in a substitution that does not kill the pipeline (`tee full.log | { head -20; cat >/dev/null; }`),
or write the full copy first and read the head from the file afterwards.

## Reporting

**56.** Model reply, two paragraphs: (1) The filter sees only standard output; the warnings are on
standard error, which `|` does not carry. Add `2>&1` before the `|`, or `|&`. (2) Separately, when a
program's stdout is a pipe its C library switches from line buffering to block buffering, so output
piles up until several kilobytes exist. `grep --line-buffered`, `sed -u`, `awk … fflush()` or
`stdbuf -oL` restores the line-at-a-time behaviour. The two are unrelated: one is about which stream,
the other about when.

**57.** For: nothing is silently dropped, and diagnostics reach the same log as the output. Against:
you have merged two streams that exist precisely so they can be separated — your filter now matches
error text as data, `wc -l` counts warnings as records, and you can never again send output one way
and errors another. Merge deliberately, at the point where you are about to store or display.

**58.** "Turn on `pipefail` in scripts. Where a pipeline ends in `head`, `grep -q`, or anything else
that exits early, expect 141 from an upstream stage and treat it as success explicitly — do not turn
`pipefail` back off for the whole script."

**59.** `cmd | grep -q ERROR && alert`: (a) `cmd`'s errors are on fd 2 and never reach `grep`, so a
crashing `cmd` produces no alert; (b) `grep -q` exits on the first match, killing `cmd` with SIGPIPE,
and `cmd`'s own exit status is invisible anyway because the pipeline reports `grep`'s.

## Experiment

**60.** `cmd1 | cmd2 | cmd3; echo "${PIPESTATUS[@]}"` already does it, for any number of stages, as
long as the `echo` is the very next command. Test: `bin/failmid | cat | (exit 5)` → `4 0 5`.

**61.** Measured: a writer writing 1024-byte lines into a pipe with a sleeping reader gets **64**
writes away before it blocks — a **64 KiB** pipe buffer, the Linux default. Test shape: writer
records a counter to a file each iteration, reader sleeps, `timeout` ends it, read the counter.

**62.** Same answer (9 and 9 on `readings.txt` with `grep p-0`). Three differences: the pipeline runs
concurrently while the file version is strictly sequential; the file version needs writable space and
leaves two files behind; the file version's intermediate results have names, so they can be inspected
and re-used, which is occasionally the reason to do it.

**63.** "You were right that they are two problems. The filter never sees the warnings because `|`
carries standard output only. The wall-of-text is buffering, which changes mode when the destination
is a pipe. Different causes, different fixes, neither one anybody's fault."

**64.** Make the reader die: `bin/slowtick 40 | head -0`. The writer keeps going until its *next
write*, which is when the signal is delivered — not at the moment the reader exits. A writer that
is sleeping between writes survives, briefly, past the death of its reader.

**65.** `tail -n +2 data/panels.csv | grep -c clamped` → **3**. `tail -n +2` streams; `grep -c` must
read the whole input to produce a count (its `-c` output is one line at the end), so this pipeline
cannot show a partial answer no matter what you do about buffering.

## Stretch

**66.** Any `pipestat` that takes a string has to `eval` it, which re-parses user text as shell —
quoting, redirections and subshells all have to survive. `PIPESTATUS` gives you every stage's status
for free provided the pipeline is written literally, which is the argument for writing it literally.

**67.**
```
set -eo pipefail
seq 1 100000 | head -1        # aborts the script, sometimes
```
Rule: (1) `pipefail` on; (2) any pipeline ending in an early-exit reader gets its status handled
explicitly — `… | head -1 || [ "${PIPESTATUS[0]}" = 141 ]` or restructure so nothing exits early;
(3) never leave `set -e` to make that judgement for you.

**68.** Right answer, more cost: each extra `cat` is a fork, an exec, a pipe, and a full copy of every
byte through kernel buffers. 200 copies of `readings.txt` through ten `cat`s: 0.268 s real, 0.163
user, 0.127 sys — note that most of it is system time, which is the copying.

**69.** The stage that buffers is the one whose **stdout is a pipe** — `grep`. `tail -f` keeps
writing as lines arrive, but `grep`'s output goes into a pipe, so its C library block buffers and
nothing reaches your terminal until several kilobytes of matches exist. `grep --line-buffered` fixes
the stage that is actually buffering; adding flags to `tail` does nothing. In
`tail -f log | grep --line-buffered ERROR | tee found.txt`, `tee` is unbuffered by design.

**70.** Let the writer finish while showing three lines: `bin/slowtick 40 | { head -3; cat >/dev/null; }`
— something must keep draining the pipe. What you gave up: the pipeline now takes the writer's full
running time, which is exactly what SIGPIPE was saving you.

**71.** Three ways a pipeline loses a stream quietly: (a) fd 2 is not carried by `|`, so diagnostics
go somewhere else entirely; (b) the pipeline's status is the last stage's, so an upstream failure
reports success; (c) a reader exiting early kills the writer mid-output, truncating anything the
writer was also writing elsewhere. None of the three prints an error.

---

## Authoring notes

- The buffering demonstration is the centrepiece and it must be run, not read. `bin/slowtick` at
  0.2 s per line makes the two-second `timeout` decisive: plain `grep` yields nothing, `--line-buffered`
  yields three lines and exits 0.
- `bin/countdown | head -1` swallowing the completion line is the emotional setup for lesson 06.
  Do not explain the connection here.
- Exercise 34's `10043` is timing-dependent. The solution says "about"; a validator must not require
  the number.
- Exercise 47 is deliberately awkward to phrase — the point is that the *only* difference is fd 1's
  destination. Accept any experiment that isolates that.
- Nothing in this lab contains the string `KESTREL`. There is no flag in this lesson.
