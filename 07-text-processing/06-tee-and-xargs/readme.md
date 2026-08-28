# 07/06 — `tee` and `xargs`

> Reports go two places: the person who asked, and the file you will need when they ask again.

## What this lesson is

Two small commands that connect the pipeline to everything else.

`tee` splits a stream: it writes to a file **and** passes the same bytes along. `xargs` does the
reverse — it takes a stream and turns it into **arguments** for a command that does not read standard
input.

Neither is hard. Both have exactly one dangerous edge, and both edges are about whitespace.

## `tee`

```
$ awk '{print $3}' logs/access-2187-06-10.log | sort | uniq -c | sort -rn | tee reports/top.txt | head -3
    412 ops-bot
     96 rhea
     54 cass
```

The full table went into `reports/top.txt`; the first three lines came to your screen. You did not
run the pipeline twice, and you did not have to choose between seeing it and keeping it.

- `tee file` truncates the file first. `tee -a file` appends.
- `tee a b c` writes to all three, plus stdout.
- `tee` returns non-zero if a file could not be written, and **keeps going with the others**:

```
$ echo x | tee /etc/nope.txt
tee: /etc/nope.txt: Permission denied
x
```

The `x` still reached the terminal. That is the design: `tee` is a pass-through first and a writer
second.

The one thing never to do is `cat file | tee file`. The shell truncates the target before `cat` gets
going, and whether you keep your data depends on buffer sizes — which is another way of saying you
lose it on the file that matters. When you want to edit a file in place, use `sed -i` (lesson 04) or
write to a new name and `mv`.

`tee /dev/null` is a real idiom: it is how you make a pipeline's data visible to a command that must
be at the end while still discarding it. You will meet it in scripts. It is not a mistake.

## `xargs`

`grep` reads standard input. So do `sort`, `wc`, `sed`, `awk`, `tr`. Some commands do not: `rm`,
`cp`, `mkdir`, `chmod`, `basename` — they take **arguments**. That is what `xargs` is for.

```
$ grep -rl rhea logs | xargs -n1 basename
access-2187-06-09.log
access-2187-06-10.log
```

Without `xargs` the filenames would arrive on `basename`'s standard input and be ignored.

Useful flags:

| Flag | Effect |
|---|---|
| `-n N` | at most N arguments per command run |
| `-I{}` | one run per input line, `{}` replaced by it, anywhere in the command |
| `-0` | input is separated by NUL bytes, not whitespace |
| `-r` | do not run the command at all if the input is empty (GNU) |
| `-t` | print each command before running it |
| `-a FILE` | read from FILE instead of stdin |
| `-d C` | use C as the separator |

`-t` is how you find out what `xargs` actually built, and it is worth reaching for before `-p` or
before guessing.

## The whitespace edge

By default `xargs` splits on **whitespace**, and it also honours quotes:

```
$ ls data/awkward | xargs -n1 echo
xargs: unmatched single quote; by default quotes are special to xargs unless you use the -0 option
```

That directory contains a file with a space in its name, one with a quote, one with a newline, and
one called `-n`. Every one of them breaks the naive pipeline, and the failure modes range from an
error message to deleting the wrong file.

The fix is a separator that cannot appear in a filename. There is exactly one — the NUL byte:

```
$ find data/awkward -type f -print0 | xargs -0 -n1 echo
```

`find -print0` and `xargs -0` are a matched pair and you should learn them as one thing. Whenever the
stream carries **filenames**, use them. When it carries account names out of a log, plain `xargs` is
fine — but be able to say which case you are in.

Note also what happens without `-print0`:

```
$ find data/awkward -type f | wc -l
5
```

Four files, five lines, because one filename contains a newline. Counting lines is counting
filenames only when filenames behave.

## Arguments that look like options

```
$ printf -- '-n\nhello\n' | xargs echo
hello
```

`echo` read `-n` as its own flag and suppressed the newline. If that had been `rm` and the file were
called `-rf`, you would have had a worse afternoon. Many commands accept `--` to mean "no more
options"; `echo` is not one of them, which is itself the point: `--` is a convention of the command
you are running, not of `xargs`.

## `-I` and one-per-line

```
$ xargs -I{} echo "account: {}" < data/accounts.txt
account: ops-bot
account: rhea
...
```

`-I` implies one input **line** per run (not one whitespace-separated word), and it lets you put the
value anywhere, more than once. It also silently overrides `-n`:

```
xargs: warning: options --replace and --max-args/-n are mutually exclusive, ignoring previous --replace value
```

Read that warning when it appears. It means one of the two flags you wrote did nothing.

## Exit status

`xargs` exits 123 if any command it ran failed, 124 if one was killed, 126/127 if the command could
not be run. It does not stop at the first failure by default. And if a downstream command closes the
pipe early — `| head -3`, say — you will see:

```
xargs: echo: terminated by signal 13
```

Signal 13 is SIGPIPE. Nothing is wrong; `head` had seen enough and closed the pipe, and `xargs` is
telling you it noticed.

## What you have

Two days of access log, `data/accounts.txt`, `data/awkward/` (four files with hostile names),
`data/empty.txt`, an empty `reports/` and an empty `scratch/`.

The report you build at the end of this lesson is the one the captain asks for in lesson 08. Put it in
`reports/`.
