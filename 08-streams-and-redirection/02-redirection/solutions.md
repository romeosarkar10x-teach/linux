# 08/02 — Solutions

All numbers measured in the lab container. Work in `scratch/`.

## Warmup

**1.** fd 1 is twelve lines: the date header, three `sensor bank` lines, six `panel NN nominal`
lines, `6 panels, 3 banks`, `end of summary`. fd 2 is five lines, all prefixed `deckreport:`. The
prefix is a courtesy of this author; do not rely on it in general.

**2.** `12`.

**3.** `5`. 12 + 5 = 17, which is what the screen showed.

**4.**

```
deckreport 2>&1 >/dev/null | wc -l
  the pipe is built first:      fd 1 → pipe
  2>&1                          fd 2 := copy of fd 1  → pipe
  >/dev/null                    fd 1 := /dev/null
  result: only fd 2 reaches wc
```

**5.**

```
deckreport >/dev/null 2>&1 | wc -l
  the pipe is built first:      fd 1 → pipe
  >/dev/null                    fd 1 := /dev/null
  2>&1                          fd 2 := copy of fd 1  → /dev/null
  result: nothing reaches wc → 0
```

The explaining line is the third: by the time `2>&1` ran, fd 1 was already the void, so fd 2 was
pointed at the void too.

**6.** The sentence that survives is "it points fd 2 at whatever fd 1 is pointing at **at that
moment**". The one that does not is "it merges the streams" — nothing is merged, and the streams
stay two separate descriptors that happen to share a destination.

**7.** Open. Most people arrive at the left-to-right rule and are surprised by truncation-before-run.

## `>`, `>>`, truncation

**8.** `12` both times. The second run truncated `a.txt` to zero before `deckreport` printed
anything, so you are looking at run two's output alone, not at run one plus run two.

**9.** `24`. In descriptor terms both do `fd 1 := a.txt`; they differ only in the flag passed at open
time — `O_TRUNC` versus `O_APPEND`. "Overwrite" is a bad description of `>` because it does not
overwrite in place, it empties first.

**10.** `14` — the two existing lines plus twelve.

**11.** They are gone. `>` truncated the file at open time.

**12.** The character is `>` where it should be `>>`. The nightly summary opens the log with
`O_TRUNC` every night, so the file only ever contains the most recent run. One character.

**13.** Yes, `>` creates it, mode `-rw-r--r--` here. The mode is 666 masked by your `umask`, which is
`0022` in this container, giving 644. The shell decides, not the program. `umask` is Chapter 10.

**14.** It works and produces an empty file. `> file` with no command is the idiomatic way to create
or empty a file — the shell performs the redirection, finds no command to run, and stops. `:` and
`true` in front of it do the same thing and are clearer to a reader.

**15.** `rc=0`. Redirection has no effect on status.

**16.** `rc=3`. Same point, made by a program that fails: throwing the output away does not throw the
status away. This matters later — `>/dev/null 2>&1` is how a great many real failures get silenced,
and the status is what is left to notice them by.

## Order

**17.** `17`. fd 1 := out.txt, then fd 2 := copy of fd 1 → out.txt. Both in the file.

**18.** `12` in the file, five on your screen. fd 2 was copied from fd 1 **before** fd 1 moved, so
fd 2 kept the terminal.

**19.** Equivalent to `> out.txt 2>&1`.

**20.** `cmp` printing nothing means the files are byte-for-byte identical, and its exit status is 0.
That is a proof, not an impression.

**21.**

```
$ deckreport > s.txt 2> s.txt
$ wc -l s.txt
7 s.txt
$ tail -2 s.txt
els, 3 banks
end of summary
```

Two separate `open()` calls, two separate file positions, both starting at zero. The five stderr
lines and twelve stdout lines wrote over each other; `6 panels, 3 banks` survives only as `els, 3
banks` because a stderr write landed on top of its first six bytes. 258 bytes, reproducibly, in this
lab. Nothing warned you and nothing failed.

**22.** `deckreport > s.txt 2>&1` or `deckreport &> s.txt`. Both give one open file description
shared by two descriptors, so there is one position and the writes queue up behind each other.

**23.** fd 2 := e.txt; fd 1 := copy of fd 2 → e.txt. Seventeen lines. Legal, correct, and rarer than
its mirror image mostly out of habit.

**24.** Preserved: `out: a`, `err: a`, `out: b`, `err: b`. Small unbuffered writes from bash, one
shared file position.

**25.** `o2.txt` has the two `out:` lines; the two `err:` lines are on your screen.

**26.** The first two stderr lines: `deckreport: bank C running on two of three sensors` and
`deckreport: panel 04 last calibrated 2186-11`. `head` was fed fd 2 only, so "first two" means first
two complaints.

**27.** The evidence is exercise 3 itself: `2>&1` produced a copy that reached `wc`. If the pipe had
been built after the redirections, `2>&1` would have copied the terminal and `wc` would have seen
nothing. The shell builds the pipeline, then applies each command's redirections.

## The trap

**28.** `0` bytes.

**29.** The shell performs `> r.txt` while setting up the command — before `sort` is even executed,
let alone before it opens its input. `sort` then opened an empty file, had nothing to sort, and
wrote nothing. Every step behaved correctly and the file is gone.

**30.** On a fresh 20-line copy, `sort r.txt >> r.txt` exits 0 and leaves **40 lines**: `sort` reads
its entire input before writing anything, so it read 20, sorted them, and appended 20 to the end.
It does not hang and it does not truncate — it silently doubles the file. "Not destroyed" is not the
same as "fine".

**31.**

```
sort r.txt > r.sorted && mv r.sorted r.txt      # explicit temp file
sed -i '...' r.txt                              # the tool does the dance for you
```

`sed -i` is not magic: it writes a temp file and renames it. The rename is the part that makes it
safe, because a rename is atomic and a truncate is not.

**32.**

```
$ set -o noclobber
$ echo y > r.txt
bash: r.txt: cannot overwrite existing file
$ echo $?
1
$ echo y >| r.txt        # rc 0
```

Note who complained: **bash**, before running anything. The status is the shell's.

**33.** It covers `>` onto an existing file. It does **not** cover exercise 28 — well, it would have
refused that particular line, but it does not cover `>>`, does not cover a program that opens and
truncates a file itself, and is off by default so it protects nobody's script but your own
interactive session. Treat it as a seatbelt, not a policy.

## `<` and `/dev/null`

**34.** Both print `20`, but `wc -l < file` prints the number alone. `wc` was handed a descriptor,
not a name — it never learned there was a file, so it has no name to print. This is the standard way
to get a bare number out of `wc` for arithmetic.

**35.**

```
$ wc -l < nope.txt
bash: nope.txt: No such file or directory
$ echo $?
1
```

**bash** produced it: the message is prefixed `bash:` and, more decisively, `wc` never ran — the
shell failed while building the descriptor table and abandoned the command. `wc`'s own missing-file
message reads `wc: nope.txt: No such file or directory` and its status would be 1 as well, so the
prefix is your evidence, not the number.

**36.** `rc=3`, and `attempting bank D` still printed. `< /dev/null` guarantees the program an
immediate end-of-file: it will never block waiting for input. This is standard practice for anything
run unattended.

**37.** It swallows every write and returns EOF on every read. A hole that is also an empty file.

**38.** `5`. `2>/dev/stdout` opens the *file* `/dev/stdout`, which the kernel points at descriptor 1
of the opening process — the pipe. It arrives at the same place by a different route. Prefer `2>&1`
in a script you want read: `/dev/stdout` depends on `/proc` being mounted and behaves differently on
other systems, whereas `2>&1` is a shell operation with no filesystem involved.

## The shift board

**39.** Predictions first. This exercise measures whether you can read a redirection, and running it
first destroys the measurement.

**40.**

| entry | what it does |
|---|---|
| A `> out.txt 2>&1 > out2.txt` | fd1:=out.txt, fd2:=out.txt, fd1:=out2.txt. **out.txt gets the 5 stderr lines, out2.txt gets the 12 stdout lines.** |
| B `2> out.txt 1>&2` | fd2:=out.txt, fd1:=copy of fd2. All 17 lines in out.txt. |
| C `2>&1 >/dev/null \| wc -l` | prints `5`. Not a mistake — see 41. |
| D `sort data/readings.txt > data/readings.txt` | destroys the file. |
| E `&> out.txt 2>/dev/null` | fd1,fd2:=out.txt, then fd2:=/dev/null. out.txt gets the 12 stdout lines; the 5 complaints are discarded. |
| F `> /dev/null 2>&1 \| wc -l` | prints `0`. |

A is the instructive one: it looks like a typo and it is in fact a working, if obscure, way to split
the two streams into two files. `> out.txt 2>&1 > out2.txt` and `> out2.txt 2> out.txt` do the same
thing, and only one of them is readable.

**41.** **C.** It is the canonical idiom for "count/inspect the complaints and throw the answer
away", which is exactly what you did in exercise 3. It is on a list of mistakes because whoever kept
the board pattern-matched on `2>&1` appearing before `>` and assumed it was the famous bug. Being
able to say "that one is deliberate" is the point of the exercise, and it is the same skill as
reading someone's script without rewriting it.

**42.** `out.txt` holds the twelve stdout lines. The complaints went to `/dev/null` and are gone.
Assignments: `&>` sets fd 1 and fd 2 to `out.txt`; then `2>/dev/null` re-points fd 2. Later wins —
which is what makes E an easy way to accidentally silence exactly the thing you were collecting.

**43.** Not wrong: it is a legitimate "everything into one file" that happens to route through fd 2.
Wrong-ish: the reader has to hold two assignments in their head to see that the file ends up with
both streams, where `&>` or `> f 2>&1` says it at a glance. Both sentences are true; in review, the
second one wins.

**44.** **D.** Surviving it requires having made a copy first, or `set -o noclobber` set in that
shell, or the file being under something that keeps versions. There is no undo — the data was gone
before `sort` started.

## Reporting

**45.** Model: "The nightly summary writes with `>`, which truncates the log every time it opens it,
so the file only ever holds the most recent run. Changing that one character to `>>` fixes it, and
nothing before tonight can be recovered."

**46.** They diverge the day something writes to stderr that matters — a disk filling, a sensor
dropping out. Yours has been putting complaints in the log; theirs has been putting them on the
terminal of whatever ran the script, which for a scheduled job is nobody's terminal at all. Neither
script changed. The world did.

**47.** For example: "Write the destination first and the duplication second — `> file 2>&1`, never
`2>&1 > file` — unless you are deliberately splitting the streams, and say so in a comment." That
covers A, B, E and F; it does not cover D, which is a different mistake entirely.

## Experiment

**48.** Three runs, appending stderr, discarding stdout:

```
deckreport 2>> errs.txt >/dev/null
deckreport 2>> errs.txt >/dev/null
deckreport 2>> errs.txt >/dev/null
wc -l errs.txt      # 15
```

**49.** That *is* the one-command-line form; the point is `2>>` rather than `2>`. Verified: 5, 10, 15.

**50.**

```
$ exec 3> three.txt
$ echo hi >&3
$ ls -l /proc/$$/fd
0 -> /dev/pts/0
1 -> /dev/pts/0
2 -> /dev/pts/0
3 -> .../scratch/three.txt
255 -> /dev/pts/0
$ exec 3>&-
```

`exec` with no command applies the redirection **to the shell itself**, permanently, until you undo
it. That is how a script opens a log once instead of re-opening it on every line. Forgetting the
`3>&-` leaves a descriptor open for the life of the shell.

**51.** You cannot. Redirection points a descriptor at exactly one destination; duplicating *content*
to two places needs a process that reads and writes twice, which is `tee`. What you would need is a
second writer, and there is no operator that creates one. (`exec 3>&1` plus a `tee` on fd 3 is the
usual trick, and it still needs `tee`.)

**52.** `deckreport > o1.txt 2>&1 > o2.txt 2> o3.txt`: fd1:=o1, fd2:=o1, fd1:=o2, fd2:=o3.
**o1.txt is empty (0 lines)**, o2.txt has 12, o3.txt has 5. Both of o1's assignments were superseded
before the program ran, so a file was created, truncated, and never written to. Verified.

**53.** `> f`, `: > f`, `true > f`. All three create-or-truncate; the last two exist because a bare
`> f` at the start of a line is easy to misread. `cp /dev/null f` also works and opens a different
argument about clarity.

## Stretch

**54.** Both give the same file, verified with `cmp`. The grouping matters when the redirection moves
inside: `{ echo a; echo b >&2 > f; }` redirects only that one command, and `{ echo a > f; echo b
>&2; }` redirects only the other. A redirection attaches to exactly one command — a simple command, a
compound command, or a group — and the braces are how you say which.

**55.** `2>&1` is a single token to the shell's parser: the operator `>&` with a source descriptor
`2` and a target descriptor `1`. Whitespace is allowed after the operator, so `2>& 1` parses and
prints `5` as expected. `2> &1` puts the space *inside* the operator, so bash sees `2>` followed by
the word `&1`, and `&` is a control operator:

```
bash: syntax error near unexpected token `&'
```

The error names the character, which is a useful habit to notice: bash tells you which token
surprised it.

**56.**

```
$ deckreport 2>&1 | tee log >/dev/null; echo "rc=$? P=${PIPESTATUS[*]}"
rc=0 P=0 0
$ failhard 2>&1 | tee log >/dev/null; echo "rc=$? P=${PIPESTATUS[*]}"
rc=0 P=3 0
```

The pipeline's status is `tee`'s — the **last** command — so a failing program behind a `tee` reports
success. `PIPESTATUS` has the truth, and `set -o pipefail` makes the pipeline adopt it. This is
lesson 05's subject and it is worth arriving there already annoyed about it.

**57.** Nothing is wrong with the redirection, and that is the failure mode. The path contains a
date, so it changes every day; whatever cleans `/var/tmp` removes it on a schedule; and no one has a
reason to open a file whose name they cannot predict. The tool has been complaining correctly, on
the correct stream, into a location that is by construction unread. Hold that thought.

## Authoring notes

- Every count measured: deckreport 12/5, failhard 1/2 exit 3, `> s.txt 2> s.txt` = 7 lines / 258
  bytes reproducibly across three runs, entry A = 5 + 12, entry E = 12, exercise 52's o1 empty.
- `sort r.txt >> r.txt` was assumed to hang or truncate when drafted. Measured: rc 0, 40 lines. The
  solution says so instead of the guess.
- The `2> &1` syntax error text is quoted from the container, not from memory.
- Exercise 41's answer (entry C is correct) is the lesson's red herring inversion: the list is
  labelled "mistakes" and the student is expected to disagree with it.
- Exercise 57 is the chapter's incident, stated as a hypothetical, with no path from this lab to it.
