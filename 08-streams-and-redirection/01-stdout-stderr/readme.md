# 08/01 — Two mouths: stdout and stderr

> Every program you have run so far has been writing to two different places at once, and your
> terminal has been hiding that from you by putting both of them in the same window.

## What this lesson is

A process does not open its own connection to your screen. By the time its first line of code runs,
three file descriptors are already open, and the shell opened them:

| fd | name | what belongs there |
|---|---|---|
| 0 | stdin | where the program **reads** from |
| 1 | stdout | where the program writes its **result** |
| 2 | stderr | where the program writes **everything else** |

A file descriptor is a small non-negative integer the kernel hands a process to stand for an open
thing — a file, a pipe, a terminal, a socket. The program says "write this to 1" and the kernel
knows where 1 currently points. The program does not know and does not care.

That last sentence is the whole chapter. The program does not choose where its output goes. **You**
choose, from the command line, and the program is written to be indifferent about it.

## Why two output streams and not one

The split is not "normal output" versus "errors". The name `stderr` is forty years old and it is
misleading. The real division is:

- **fd 1 is the answer.** The thing somebody would want to pipe into another program.
- **fd 2 is everything that is not the answer.** Warnings, prompts, progress, diagnostics, "3 files
  copied", "connecting…", and yes, errors.

The test an author is supposed to apply:

> If somebody pipes my output into `sort`, is this line something `sort` should have to deal with?
> If no, it goes to fd 2.

That is why `wc -l` prints its count on fd 1 and its "no such file" on fd 2. It is why a download
tool's progress bar is on fd 2: you want the file on fd 1, not the file with a progress bar
sprinkled through it.

You have already relied on this without knowing. Every time you ran something like

```
grep pattern *.log | sort
```

and a "Permission denied" appeared **on your screen** rather than **in the sorted output**, fd 2 did
that for you.

## Why you have never noticed

At a terminal, all three descriptors point at the same place — the terminal device itself. The lab
ships a program that says so out loud:

```
$ bin/fdreport
fd 0 -> /dev/pts/0
fd 1 -> /dev/pts/0
fd 2 -> /dev/pts/0
```

Three descriptors, one destination. Nothing on your screen marks which line arrived by which
descriptor, there is no colour, no prefix, no ordering rule. The two streams are as separate as two
pipes into the same bucket, and looking at the bucket will never tell you.

`fdreport` reads its own `/proc/<pid>/fd/` directory, where the kernel exposes one symlink per open
descriptor. That directory is the truth, and you can look at it for any process you own.

## The one that matters here

`bin/panelcheck` is dorn's panel diagnostic, written in 2186 and running ever since. Run it:

```
$ bin/panelcheck
```

You get a report and some complaints, mixed together on your screen. Now send one stream away and
look at what is left:

```
$ bin/panelcheck 2>/dev/null      # complaints discarded: a clean report
$ bin/panelcheck >/dev/null       # report discarded: nothing but complaints
```

Ten lines of report, six lines of complaint, and **exit status 0**. The program is not broken and
is not lying. It clamped two readings, said so on the correct stream, and reported success because
clamping is what it is supposed to do when a reading is out of band.

Hold on to that. It is the seed of this chapter's incident: a tool that has been complaining
correctly, on the correct stream, for fourteen months, to a place nobody reads.

## Interleaving, and why order is not guaranteed

`bin/twovoices` alternates strictly: `out 1`, `err 1`, `out 2`, `err 2`, and so on. Send both to the
same file and the alternation survives:

```
$ bin/twovoices > /tmp/t.txt 2>&1
$ cat /tmp/t.txt
out 1
err 1
out 2
...
```

That works here because this program writes small lines and does not buffer. It is **not** a
guarantee. Most C programs buffer fd 1 in blocks when it is not a terminal and leave fd 2 unbuffered
always, so a redirected stdout can arrive in one lump at the end while stderr trickles out live. You
will meet that properly in `04-pipes-deep`. For now: **if you need to know the order, do not rely on
it — timestamp it or keep the streams apart.**

## fd 0 exists too

`bin/askdeck` reads a line from stdin. Three ways to feed it, all identical from the program's side:

```
$ echo 05 | bin/askdeck            # stdin is a pipe
$ bin/askdeck < data/decks.txt     # stdin is a file
$ bin/askdeck                      # stdin is your keyboard; it waits
```

Note where its prompt goes. `which deck?` is on fd 2 — because a prompt is not the answer, and if
you piped this program into another one, the prompt must not end up in the data. That is the same
rule again, applied to the one case beginners always get wrong.

## What this lesson deliberately does not give you

The redirection operators themselves — `>`, `>>`, `2>`, `2>&1`, `&>` — are `02-redirection`. This
lesson uses `>` and `2>` only in their simplest form, and only to prove the streams are separate.
The order-of-redirection rule that the whole chapter turns on is the next lesson's, and it will not
make sense until you believe, in your hands, that fd 1 and fd 2 are two different things.

## Files in this lab

```
bin/panelcheck    dorn's panel diagnostic: 10 lines on fd 1, 6 on fd 2, exit 0
bin/twovoices     strict alternation between the streams
bin/askdeck       reads fd 0; prompt on fd 2; three different exit codes
bin/fdreport      prints where its own fd 0, 1 and 2 point
data/             small inputs for askdeck
notes/streams.txt the reference table, in the station's words
notes/dorn-readme.txt  why panelcheck exits 0. Read it before you judge it.
scratch/          yours
```

All four programs are shell scripts and you are meant to read them.
