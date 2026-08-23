# 04/01 — cat and Friends

> Most of what you will do on this station is read a file somebody else wrote at four in the
> morning. There are better ways to do that than opening it and scrolling.

## What this lesson is

Reading. Nothing in this lesson writes to a file, and nothing here can break anything. That is
deliberate: Chapter 4 goes on to `mkdir`, `cp`, `mv` and `rm`, all of which change the disk, and the
only way to be confident about a change is to be fluent at reading the state before and after it.

You already met `cat`, `head` and `tail` in Chapter 1 as ways to get bytes onto the screen. Here they
become instruments. The question stops being "what is in this file" and becomes:

- What is in it that I cannot see? Tabs, carriage returns, control bytes, a missing final newline.
- Which part of it do I want — the first N lines, the last N, everything from line N onwards?
- How do I read a five-thousand-line file without printing five thousand lines?
- How do I watch a file that is still being written?

## The tools

`cat` concatenates. That is the whole of its job and the origin of its name: it takes files, in the
order you name them, and writes their bytes to standard output as one stream. Printing a single file
is the degenerate case. Its `-A`, `-v`, `-T`, `-E`, `-n` and `-s` options do not change the file —
they change how `cat` *renders* bytes that would otherwise be invisible or ambiguous.

`tac` is `cat` backwards, line by line. Not a joke tool: log files are usually written oldest-first
and read newest-first.

`nl` numbers lines. It looks like `cat -n` and is not: `nl` has an opinion about which lines deserve
a number, and by default blank lines do not get one. Two commands that both "number the lines" will
disagree on a file with blanks in it, and knowing which one you used is the difference between a
correct line reference and a wrong one.

`head` and `tail` take the ends. Both count lines by default and bytes with `-c`. `tail` has the more
interesting arguments: `-n +N` means *from* line N rather than the last N, and `-f` means do not stop
at end of file — keep the file open and print whatever gets appended.

`less` is a pager. It shows you one screen, waits, and lets you move. It never loads the whole file
to start, which is why it opens a gigabyte instantly and `cat` does not. Its keys are worth actually
learning, because the same keys drive `man`.

## The shape of the lab

```
cd /labs/04-creating-copying-destroying/01-cat-and-friends
ls -F
```

`logs/` holds four files of increasing awkwardness: a comms log with blank lines in it, a CSV whose
rows are 314 characters wide, a five-thousand-line crew roster, and a short panel log. `notes/` holds
five small files that are each a different kind of lying — a file with no trailing newline, one with
real tabs, one with CRLF line endings, one with a control byte and a non-ASCII character in it, and
one with a run of blank lines. `fragments/` holds three pieces of one handover note. `feed/` is
empty; you will fill it yourself in the `tail -f` exercises.

These are logs from 2187-05-17. That date will come back at the end of the chapter. For now they are
just files.

## Rules of engagement

- Read-only. No exercise in this lesson requires you to modify anything in `logs/`, `notes/` or
  `fragments/`. The `feed/` exercises create their own files.
- `less` is interactive. `q` quits. If you get stuck in it, that is `q`.
- `tail -f` does not return on its own. Ctrl-C.
- If you mangle something anyway: `kestrel reset 04/01` from the repo root.

## What "solved" looks like

You can state, without running anything, which of `cat -n` and `nl` will number a blank line. You can
get lines 4000–4010 out of a 5000-line file with one command. You can tell a tab from spaces and a
CRLF file from a LF file by looking, because you know which flag makes them visible. And you can
watch a log grow in one terminal while something writes to it in another.

## Before you move on

Write down, in your own words, what `cat file` does that `less file` does not, and what `less file`
does that `cat file` cannot. If your answer is only about screen size, read the `less` exercises
again.
