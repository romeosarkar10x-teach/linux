# 04/02 — touch and mkdir

> You are about to rebuild a directory tree from a piece of paper. Forty `mkdir` calls is one way. It
> is not the way anybody does it twice.

## What this lesson is

Two commands that create things, and one shell feature that makes creating forty things cost the
same as creating one.

`mkdir` makes directories. `touch` makes empty files — or, more precisely, `touch` sets timestamps
and creates the file first if it has to, which is a different job that happens to look the same from
outside. Brace expansion is not a command at all: it is the shell rewriting your command line before
`mkdir` ever runs.

At the end of this chapter you will be handed a manifest with dozens of paths in it and asked to
rebuild what it describes. This lesson is where you get the technique. The incident is where you find
out that the manifest is not entirely trustworthy.

## Brace expansion is a shell feature

Type this and read the output before you believe anything else:

```
echo bay-{01,02,03}
echo bay-{01..06}
echo deck-0{3,4}/bay-{01..04}
```

Three facts, in order:

1. `{a,b,c}` expands to each alternative in turn, with whatever surrounds it kept.
2. `{01..06}` is a *sequence* expression, and the leading zero in the first element makes every
   element zero-padded to the same width. `{1..6}` does not pad.
3. Adjacent expansions multiply. Two decks and four bays is eight paths, and you did not type eight
   of anything.

`mkdir` never sees a brace. By the time `mkdir` runs, the shell has already replaced the word with
however many words it expanded to, and `mkdir` sees an ordinary argument list. That is why brace
expansion works with `mkdir`, `touch`, `cp`, `rm` and everything else: it is not a feature of any of
them.

The trap is the single-element case. `echo bay-{01}` prints `bay-{01}` — a brace group with no comma
and no `..` is not an expansion at all, and the braces stay in your filename. You will make this
mistake once.

## `mkdir -p` and what it does not forgive

`mkdir a/b/c` fails if `a` does not exist. `mkdir -p a/b/c` creates every missing component and, if
the whole path already exists, succeeds silently instead of failing. That "succeeds silently" is the
half people forget: `-p` makes `mkdir` **idempotent**, which is why it belongs in every setup script,
including the ones in this course.

What `-p` does not do is override reality. If `a/b` exists and is a regular file, `mkdir -p a/b/c`
fails with `Not a directory`, and nothing in `-p` will help. You have one of those in the lab.

`-m` sets the mode of the directory it creates, and it sets it *exactly* — the umask does not apply
to a mode given with `-m`, which is why `mkdir -m 777` really does produce `drwxrwxrwx` while a plain
`mkdir` under a `0022` umask produces `drwxr-xr-x`. With `-p`, `-m` applies only to the final
component; the parents it invented get the default treatment.

## `touch` creates as a side effect

`touch f` sets `f`'s access and modification times to now. If `f` does not exist, it creates it
empty first — and that creation is the *only* reason anyone uses `touch` to make files. `-c` turns
the creation off: `touch -c f` on a missing file does nothing at all and exits 0.

You met `-d`, `-r`, `-a`, `-m` and `-h` in Chapter 3. They are the same flags here. What is new is
watching them create things.

## The shape of the lab

```
cd /labs/04-creating-copying-destroying/02-touch-mkdir
ls -F
```

`spec/` holds the tree you are asked to build and a short note about two ways the obvious brace
expression gets it wrong. `existing/` is a partly built tree with one deliberate obstruction in it.
`perms/` is empty and is where you will experiment with `-m` and the umask. `times/` holds three
files with known timestamps. `build/` is empty and is yours.

## Rules of engagement

- Everything you create goes under `build/`, `perms/` or `times/`. Leave `spec/` alone.
- Read `spec/naming-notes.txt` before you write your brace expression, not after.
- `kestrel reset 04/02` from the repo root puts everything back, and you will need it at least once.

## What "solved" looks like

You can build the whole `spec/deck-tree.txt` tree in **one command line**, with the right number of
digits in every bay number, and verify it with `find` without counting on your fingers. You can say
what `mkdir -p` will and will not forgive. And you can explain why `mkdir -m 777` and `chmod 777`
after a plain `mkdir` are not quite the same operation, even though they end in the same permissions.

## Before you move on

Count the directories in the tree you built. Then count the characters in the command you built it
with. The ratio is the entire point of the lesson.
