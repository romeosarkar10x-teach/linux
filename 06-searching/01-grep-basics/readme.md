# 06/01 — `grep` Basics

> Sixty people, eleven years, and a comms officer who generates more log traffic than the rest of
> the station combined. You are not going to read it.

## What this lesson is

`grep` prints the lines of its input that match a pattern. That is the whole description, and every
difficulty with `grep` comes from three words in it: *lines*, *input*, and *pattern*.

**Lines.** `grep` is line-oriented. It does not find "the error", it finds the lines containing it,
and a match twice on one line is still one line of output. If what you want spans two lines, `grep`
alone is the wrong tool and no flag fixes that.

**Input.** Files if you name them, standard input if you do not. Name more than one file and `grep`
starts prefixing every line with the filename it came from — which changes the shape of the output
and breaks anything downstream that was not expecting it.

**Pattern.** Not a glob. `grep` takes a *regular expression*, and although the two notations share
characters they do not share meanings. `*` in a glob means "anything"; `*` in a regex means "zero or
more of the previous thing". Lesson 03 is the whole story. What you need today is smaller and more
urgent: **`.` matches any character**, so `grep '0.06'` also matches `0x06` and `0-06`, and if you
wanted a literal dot you have said something slightly wrong and been given a slightly wrong answer.

## Quoting the pattern

Everything you learned in Chapter 5 applies, immediately and painfully. The pattern is an argument,
the shell expands arguments, and regex metacharacters overlap almost exactly with glob
metacharacters. `grep comms ERROR file.log` is not a search for two words; it is a search for
`comms` in two files, one of which does not exist.

Single-quote the pattern. Always, from today, even when it looks like it does not need it. It is the
cheapest habit in this course.

## Exit status is the point

`grep` exits **0** if it matched something, **1** if it matched nothing, and **2** if something went
wrong — an unreadable file, a bad pattern. That three-way answer is what makes `grep` usable in
scripts, and `-q` exists to get it without any output at all.

Note the trap: "matched nothing" and "the file does not exist" are different statuses, and if you
only test for zero you will treat a typo'd filename as a clean result.

## The shape of the lab

```
cd /labs/06-searching/01-grep-basics
ls -F
```

`logs/` has four files: a 240-line comms log for 2187-06-10 where the severity word appears as
`ERROR`, `Error` and `error` in equal numbers, a 40-line panel log where nothing you search for in
the comms log appears at all, a 60-line strain log of numeric readings, and an empty file.
`notes/handover.txt` contains a line beginning with a dash and a note about panel numbering.
`notes/patterns.txt` holds three patterns, one per line. `notes/binary.dat` has a NUL byte in it.
`crew.txt` is sixty `name:role:deck` records. `scratch/` is yours.

## Rules of engagement

Read-only. Nothing in this lesson modifies the logs, and every exercise that creates a file creates
it in `scratch/`. `kestrel reset 06/01` if you mangle something anyway.

Two habits to build here. Quote every pattern. And when a `grep` returns nothing, check the exit
status before you conclude anything — `1` and `2` mean very different things and look identical.

## What "solved" looks like

You can say what `grep` returns for a match, a non-match and a missing file, and why that matters.
You can search case-insensitively without pretending that is always what you wanted. You know what
happens to the output format when you name a second file. You have been bitten by `.` at least once
and know that `-F` exists. And you can explain why `grep -v file` sits there doing nothing.

## Before you move on

Count the `ERROR` lines in the comms log three ways: `-c`, piping to `wc -l`, and by eye on a
filtered listing. If the three numbers ever disagree, the reason is worth more than the count.
