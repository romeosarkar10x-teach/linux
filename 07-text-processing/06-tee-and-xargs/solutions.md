# 07/06 — Solutions: `tee` and `xargs`

Measured in the lab. The two logs are 600 lines (2187-06-10) and 556 (2187-06-09).

## `tee`

**1.**
```
awk '{print $3}' logs/access-2187-06-10.log | sort | uniq -c | sort -rn |
  tee reports/top-2187-06-10.txt | head -3
```
Screen shows `412 ops-bot`, `96 rhea`, `54 cass`.

**2.** `wc -l reports/top-2187-06-10.txt` → 7. The other four lines went into the file and never to
the terminal, because `head` stopped reading. The log was read **once**.

**3.** Temporary file: `… > /tmp/t; head -3 /tmp/t` — needs a name, needs cleaning up, and the name
is a small race if two people run it. Running twice: reads the log twice and, on a log that is still
being written, can give two different answers. `tee` costs neither.

**4.** `one` is gone. `tee` truncates its target before writing, exactly as `>` does.

**5.** `tee -a` appends: the file holds `one` then `two`. Rule: **`tee` is `>`, `tee -a` is `>>`,
plus a copy down the pipe.**

**6.** Three: `scratch/b1.txt`, `scratch/b2.txt`, and standard output.

**7.** `tee: /etc/nope.txt: Permission denied`, `x` still printed, exit status **1**.

**8.** Because `tee` is in the middle of somebody's pipeline. If it aborted on a bad output file, a
failed log-keeping step would take out the whole report. Instead it does the pass-through it promised,
reports the failure on stderr, and lets the exit status tell a script that something did not get
saved.

**9.** `tee /dev/null` is used when a command **must** be last in the pipeline but you do not want its
output, or when you want the pipeline to keep flowing past a point where nothing else needs it. It is
also how you keep a `sudo`-style construct honest in scripts. It is deliberate, not a leftover.

**10.** The shell sets up all redirections **before** either command runs, so `tee` truncates the log
to zero bytes at once, while `cat` is still opening it. Whether you keep any data depends entirely on
who won the race and how large the pipe buffer is — on this log the file happened to survive intact,
which is the worst possible outcome, because it teaches you the command is safe. It is not.

**11.** `cp logs/access-2187-06-10.log scratch/; sed -i.bak 's/ops-bot/OPS-BOT/' scratch/…`. `sed -i`
writes to a temporary file and renames it over the original, so there is never a moment when the file
is half-written. `tee` has no such step: it opens and truncates.

**12.**
```
awk '{print $3}' logs/access-2187-06-10.log | tee scratch/accounts.txt |
  sort | uniq -c | sort -rn | tee reports/top.txt | head -3
```
One read of the log, two artifacts, plus the screen.

## `xargs`: the basics

**13.** Once. All seven names became arguments to a single `echo`, which printed them on one line.

**14.** Seven times, one name per line.

**15.** Four runs: three of two names and a last of one. `-n` is a **maximum**, not a requirement, and
the final batch is whatever is left.

**16.** `-t` prints each constructed command on stderr before running it:
```
echo ops-bot rhea cass
ops-bot rhea cass
echo vint orla bex
…
```
It shows you the batching — the thing you cannot see from the output alone, and the thing that is
wrong when `xargs` surprises you.

**17.** `{}` can go anywhere in the command, including inside a quoted string, and may appear more
than once. `-I` also switches the input unit from whitespace-separated words to **whole lines**.

**18.** `xargs -I{} echo "{} -> reports/{}.txt" < data/accounts.txt`.

**19.** The warning is `options --replace and --max-args/-n are mutually exclusive, ignoring previous
--replace value` — `-n2` won, `-I` was dropped, and the output is `{} ops-bot rhea` with a literal
`{}`. Two flags, one silently discarded: read `xargs` warnings.

**20.** The default command is `echo`. `printf 'one\ntwo\n' | xargs` prints `one two`.

**21.** Yes — `hello` is printed. `xargs` runs the command once even with no input, which is a
POSIX-mandated surprise and the reason `-r` exists.

**22.** With `-r` nothing runs. It matters whenever the command has an effect: `find … | xargs rm`
with an empty result runs `rm` with no arguments (harmless, an error), but `find … | xargs tar -cf
backup.tar` would happily make an empty archive over the top of a good one. In scripts, use `-r`.

**23.** `-a FILE` saves the redirect, and more importantly it leaves **standard input free** for the
command `xargs` is running — which matters the moment that command wants to read something itself.

**24.** `-d,` sets the separator to a comma, so quotes and whitespace stop being special. The input
`a,b,c` has no trailing newline and the last field is `c` — with `-d` the newline would have been part
of a field, which is why `-d` and `-0` are the two safe modes and default splitting is not.

**25.** `xargs: echo: terminated by signal 13`. Signal 13 is SIGPIPE: `head` printed three lines and
closed the pipe, so the next write failed. Nothing is wrong. It is noise on stderr and you will see it
often; redirect it away only when you are sure that is why it appeared.

## Which commands need `xargs`

**26.** Without `xargs`, `basename` is run with no arguments and prints its usage error; the filenames
sit unread on its standard input. `basename` has no code that reads stdin at all.

**27.** Need it: `rm`, `cp`, `mv`, `mkdir`, `chmod`, `basename`, `dirname`, `touch`, `ln`. Do not:
`grep`, `sort`, `uniq`, `wc`, `sed`, `awk`, `tr`, `cut`, `head`, `tail`. The test: **does the command
do anything useful when you give it no arguments and pipe data at it?** If it waits and processes the
data, it reads stdin. If it errors or does nothing, it needs `xargs`.

**28.** `wc -l logs/access-2187-06-10.log logs/access-2187-06-09.log` gives per-file counts and a
`total` line; `cat log | wc -l` gives a bare `600`. Prefer the filename form: the labels are the
useful part, and the bare number is the one you will misattribute in a week.

**29.** `xargs wc -l < scratch/list.txt` (or `-a`). The `total` line comes from `wc` itself, which
prints it whenever it is given more than one filename — not from `xargs`, and not if `xargs` batched
the list into several runs, in which case you get several totals. That is a real reporting bug worth
seeing coming.

**30.** `wc: nosuchfile: No such file or directory`, then `123`. `xargs` exits **123** if any command
it ran exited non-zero; 124 means one was killed, 125 a fatal error, 126 the command could not be run,
127 it was not found. It does **not** stop after the first failure.

## The whitespace edge

**31.** `panel log.txt` (space), `it's a report.txt` (single quote), `two\nlines.txt` (newline), and
`-n` (looks like an option). All four break something.

**32.** `xargs: unmatched single quote; by default quotes are special to xargs unless you use the -0
option` — caused by `it's a report.txt`. Note `xargs` failed **before** running anything, which is the
kindest of the four failures.

**33.** `find … | wc -l` says 5; `ls -1 | wc -l` also says 5; there are **four** files. The name
containing a newline is counted twice by anything that counts lines. `find -type f -printf '%f\n'`
shows the halves: `two` and `lines.txt`.

**34.** All four print correctly. The only byte that cannot appear in a filename is **NUL** (`\0`).
The other prohibition is `/`, which is the path separator — everything else, including newline, tab
and every control character, is legal.

**35.** Because a separator has to be something the data cannot contain. Every printable character and
every whitespace character is legal in a filename, so only NUL is left. `find -print0` and `xargs -0`
are the pair that uses it.

**36.** `echo` received `-n` as its own option and suppressed the trailing newline: the output is
`hello` with the next prompt on the same line. `xargs` did nothing wrong — it passed the argument, and
the *command* interpreted it.

**37.** `xargs echo --` prints `-- -n hello`. It did **not** work, because `echo` does not implement
the `--` convention; it just printed it. That is the lesson: `--` is a property of the command you
run, not of `xargs`, so check the command before relying on it. (`rm -- -n` does work, and `rm ./-n`
works everywhere.)

**38.** `xargs rm` would run `rm -rf …` — the `-rf` becomes an option, and every subsequent filename
in the batch is deleted recursively and without complaint. This is the classic way to destroy a
directory tree with a correct-looking pipeline.

**39.** `find scratch -name '*.tmp' -type f -print0 | xargs -0 -r rm --`. Four defences: `-print0`/`-0`
for the separators, `-r` so an empty list runs nothing, `--` so a leading-dash name is data, and
`-type f` so it cannot pick up a directory.

**40.** The rule: **a stream carrying filenames is NUL-separated or it is wrong.** Use `-print0` and
`-0`, and if a tool in the middle cannot handle NUL, that tool is the wrong tool for filenames.

## Combining them

**41.** As exercise 1; `wc -l reports/top-2187-06-10.txt` → 7 while the screen saw 3. `tee` wrote
everything it received before `head` closed the pipe, and here the whole table fit in the pipe buffer.

**42.** The filename is written to `scratch/list.txt` and simultaneously handed to `xargs`, which
turns it into an argument for `wc -l`: `600 logs/access-2187-06-10.log`. One stream, one saved copy,
one command that cannot read streams.

**43.**
```
printf 'rhea\ncass\n' |
  xargs -I{} sh -c 'echo "{} has $(grep -c " {} " logs/access-2187-06-10.log) lines"'
```
→ `rhea has 96 lines`, `cass has 54 lines`. `sh -c` is needed because `xargs` runs one command with
arguments — it cannot expand `$( )`, redirect, or run a pipeline. Anything with shell syntax in it
needs a shell.

**44.** The account name is pasted into a shell command and then executed, so `; rm -rf ~` would run
as a command. `-I{}` plus `sh -c` is **string interpolation into a shell**, which is the same class of
hole as SQL injection. It is fine for data you generated (a log's own account column) and unsafe for
anything a stranger controls. The safer form passes the value as a positional parameter:
`xargs -I{} sh -c 'echo "$1 has …"' _ {}`.

**45.** With `xargs`:
```
xargs -I{} sh -c 'grep " {} " logs/access-2187-06-10.log > "reports/{}.txt"' < data/accounts.txt
```
Seven greps, seven passes over the log, one shell each. With `awk`:
```
awk '{ print > ("reports/" $3 ".txt") }' logs/access-2187-06-10.log
```
One pass, one process, and it cannot be confused by an account name with a space. `reports/rhea.txt`
comes out at 96 lines either way. The `awk` version is better here and the general rule is behind it:
if the loop body is one line of text processing, `awk` already has a loop.

**46.** `-exec … \;` runs one process per file — four here. The `xargs` version runs one process for
as many files as fit on a command line — one here. At four files it is irrelevant; at forty thousand
it is the difference between a second and several minutes. (`find -exec … +` is the third option and
batches like `xargs`.)

**47.** `Maximum length of command we could actually use: 2094586` — about two megabytes, and
`ARG_MAX` reports 2097152. `xargs` exists because that limit is real: `rm *` in a directory of a
million files fails with "Argument list too long", and `xargs` is the thing that splits the work into
batches that fit. That it also converts streams to arguments is the part you use daily.

**48.**
```
cat logs/*.log | awk '{c[$3]++} END {for (k in c) print c[k], k}' | sort -rn |
  tee reports/top-both.txt | head -3
```
→ `800 ops-bot`, `170 rhea`, `115 cass`.

## The report

**49.**
```
awk '{ c[$3 " " $1]++; t[$3]++ }
     END { for (k in t) printf "%-12s %4d %4d %5d\n",
                        k, c[k " 2187-06-09"], c[k " 2187-06-10"], t[k] }' logs/*.log |
  sort -k4,4rn
```
```
ops-bot       388  412   800
rhea           74   96   170
cass           61   54   115
vint           18   21    39
orla            9   12    21
bex             6    4    10
maintenance     0    1     1
```
The composite key `$3 " " $1` is lesson 05 exercise 42; `t[$3]` is the row total.

**50.** Append `| tee reports/access-summary.txt` before any `head`.

**51.** `maintenance` appears on 2187-06-10 and not on 2187-06-09 — confirm with
`awk '{print $3}' logs/access-2187-06-09.log | sort -u`, which lists six accounts, not seven. Whether
it shows as a blank, a zero or a missing row depends entirely on how you built the report, and a
naive `sort | uniq -c` per day gives you two tables of different heights with no row to compare.

**52.** It shows as `0` because the loop is over `t` (every account seen in **either** file) and
`c[k " 2187-06-09"]` is an unset array element, which `printf "%d"` renders as 0. That is worth it:
a zero is a fact, a missing row is an ambiguity between "none" and "I did not look".

**53.** Biggest first (`sort -k4,4rn`), columns aligned by `printf`, and — as written — **it does not
say which days it covers**. That is the flaw the captain will find in lesson 08.

**54.** Print the header after sorting, by putting the sorted pipeline and a `printf` inside a group:
```
{ printf '%-12s %4s %4s %5s\n' account 06-09 06-10 total
  awk … | sort -k4,4rn ; } | tee reports/access-summary.txt
```
This is lesson 05 exercise 45: a header printed in `BEGIN` gets sorted like data. Sort first, label
after.

## Stretch

**55.**
```
awk '{print $3}' logs/access-2187-06-10.log | sort | uniq -c | sort -rn |
  tee reports/top.txt | tee >(awk '{print $2}' | tr '\n' '\0' > scratch/names.nul) | wc -l
```
It works and nobody can read it, the process-substitution branch's exit status is invisible, and the
order in which the two branches finish is not defined. Split it into two commands with a name in
between. "One line" is not a goal.

**56.** `xargs -n1 echo` over seven lines: ~14 ms. `awk` over the same file: ~2 ms. Seven processes
against one. The rule: **a loop that starts a process per line costs more than the work in the line**,
and at a few hundred lines it is already the dominant cost. If the body is text processing, keep it
inside one `awk`.

**57.** `tee -a` — a single `write()` of a short line to a file opened in append mode is atomic enough
in practice, which makes it the least-bad of the four. `sed -i` — **wrong**: it rewrites and renames
the whole file, so two scripts racing lose each other's lines entirely. `awk '{print >> …}'` — same
append semantics as `tee -a`, but you are running `awk` to do nothing. `xargs` — irrelevant, it does
not write files. The honest answer is that concurrent appends want `>>` or `tee -a` and a line short
enough not to be split, and anything more needs a lock.

**58.** `seq 1 100000 | tee scratch/big.txt | head -2` saved **14139** lines, not 100000: `head`
exited, the pipe closed, `tee` and `seq` were killed by SIGPIPE mid-stream. So a `tee` before a `head`
saves *what flowed*, not the whole thing. If you need the complete file, put `head` nowhere near it —
save first, then look at the file.

## Authoring notes

- Exercise 10 was run once during authoring: `cat log | tee log` left the 600-line log **intact**
  (md5 unchanged). That is recorded in the solution because it is the point — the dangerous command
  looked safe. Students are told to reason, not to run it.
- Exercise 58's number (14139 of 100000) is buffer-dependent and will differ on other machines. The
  solution gives the measured value and the reason; a student who gets a different number is right.
- `data/awkward/` covers all four failure classes deliberately: space (splitting), quote (`xargs`
  refuses), newline (line counts lie), leading dash (option injection). Four files, four lessons.
- The two-day report in exercises 49–54 is the direct ancestor of the captain's report in lesson 08,
  including the flaw she rejects it for: no date range.
- `maintenance` is absent from 2187-06-09 by construction (`gen_access … 0`). It is the chapter's
  rehearsal for an account that exists on one day only.
