# 08/02 — Redirection, and why the order matters

> `prog > out 2>&1` and `prog 2>&1 > out` are both correct, both common, and do completely
> different things. This lesson is the reason, and the reason is not a rule to memorise.

## What this lesson is

Last lesson: a process starts with three descriptors already open, and it does not choose where they
point. This lesson: **you** choose, and you do it by writing assignments to the process's descriptor
table on the command line.

That framing is the whole lesson. A redirection is not a pipe, not a filter, not a transformation.
It is an assignment, the shell performs it **before the program starts**, and several of them are
performed **left to right**.

## The operators

| you write | it means |
|---|---|
| `> file` | fd 1 := `file`, created if absent, **truncated to zero** if present |
| `>> file` | fd 1 := `file`, created if absent, appended to if present |
| `2> file` | fd 2 := `file` (truncating), `2>>` to append |
| `< file` | fd 0 := `file`; the file must exist |
| `2>&1` | fd 2 := a copy of **whatever fd 1 is pointing at right now** |
| `1>&2` | fd 1 := a copy of whatever fd 2 is pointing at right now |
| `&> file` | bash shorthand: fd 1 and fd 2 both := `file`. `&>>` appends |
| `n> file` | any descriptor number you like, not just 1 and 2 |

`>` is short for `1>`. Nobody writes the `1`, but it is there, and remembering it makes `2>` stop
looking like a strange new operator.

## The one people get wrong

`2>&1` does not mean "merge the streams" and it does not mean "send stderr to stdout". It means
**point fd 2 at fd 1's current target**. Current. At that instant. Read left to right and both
famous forms become obvious:

```
deckreport > out.txt 2>&1
   fd 1 := out.txt
   fd 2 := copy of fd 1 → out.txt
   result: everything in out.txt
```

```
deckreport 2>&1 > out.txt
   fd 2 := copy of fd 1 → the terminal (fd 1 has not moved yet)
   fd 1 := out.txt
   result: stdout in the file, stderr still on your screen
```

Neither is a typo. The second is how you throw away the answer and keep only the complaints:

```
deckreport 2>&1 >/dev/null | wc -l
```

Read it: fd 2 becomes the pipe (because fd 1 is the pipe at that moment), then fd 1 becomes
`/dev/null`. `wc` counts stderr and nothing else. Compare with

```
deckreport >/dev/null 2>&1 | wc -l      # prints 0
```

which sends both to the void and leaves the pipe empty. Same characters, different order, and one of
them silently answers a question you did not ask.

**Where the pipe fits.** The pipe is set up first, before any of the redirections on that command are
applied. That is why `2>&1` in a pipeline copies *the pipe*, not the terminal.

## Truncation happens first

`> file` empties the file when the shell builds the descriptor table — before the program has read
one byte. So:

```
sort data/readings.txt > data/readings.txt
```

destroys `data/readings.txt`. The shell truncates it to zero, then hands `sort` an empty file, and
`sort` writes nothing back. No warning, no recovery, and it is a mistake experienced people still
make about once a year. Use a second name, or a tool with an in-place flag that does the temp-file
dance for you (`sed -i` — Chapter 7).

bash can be told to object:

```
set -o noclobber
echo y > n.txt      # bash: n.txt: cannot overwrite existing file   (rc 1)
echo y >| n.txt     # the override
```

It protects `>` against an existing file. It does not protect you from `>>` into the wrong file, and
it is off by default.

## Two redirections, one file, no

```
deckreport > s.txt 2> s.txt
```

Both descriptors are opened **independently**, each with its own position in the file, and they
overwrite each other. In this lab that produces 7 lines and a truncated word where 17 lines should
be. If you want both streams in one file, you want `2>&1` — a *copy* of one descriptor, sharing one
position — or `&>`.

## `/dev/null`, and the other special paths

`/dev/null` is an ordinary device file that accepts every write and returns end-of-file on every
read. `>/dev/null` throws output away; `</dev/null` promises a program it will get no input, which
is how you stop something that would otherwise sit waiting at a prompt.

`/dev/stdout` and `/dev/stderr` also exist, and are occasionally the only way to hand "stderr" to a
program that only takes filenames.

## What redirection does not do

- It does not change the program's exit status. `failhard >/dev/null 2>&1` still exits 3.
- It does not tell the program anything. Nothing on the far side can ask "was I redirected?" except
  by inspecting its own descriptors, as `fdreport` did last lesson.
- It does not reorder anything. What lands in the file is what the program wrote, in the order it
  wrote it — subject to the buffering caveat in `04-pipes-deep`.

## Files in this lab

```
bin/deckreport    12 lines on fd 1, 5 on fd 2, exit 0
bin/failhard      1 line on fd 1, 2 on fd 2, exit 3
bin/chatty        one line per stream per argument, in order
data/readings.txt 20 lines. Copy it before you experiment on it
logs/deck05.log   two lines that already exist, so `>` and `>>` differ visibly
notes/order.txt   the table above, in the station's words
notes/wrong.txt   six redirections off the shift board. Not all six are wrong
notes/page.txt    rhea, on a log file that is always one run long
scratch/          yours
```
