# 03/06 — Incident: the maintenance-deck maze

> Four links in the maintenance tree. Three go somewhere. One has been pointing at nothing since
> before you arrived, and nothing that runs depends on it, which is why nobody noticed.

No `find -name`, no `grep` for content — Chapter 6. `find -xtype l` is fair game and is in
Chapter 3. This one is solved by following names to their ends.

## The page

rhea sends four lines from engineering at 05:40:

> "Deck 3 console. Every entry on it is a link, that is normal, that is how the deck is built.
> One of them does not resolve any more and I want to know what it was aimed at before anybody
> touches it. Do not repair anything. I want the old path written down first."

That is the briefing. Nothing is on fire. A name points at a place, and the place is gone, and
the name is the only surviving record of where the place was.

## What this lesson is

No new command. Chapter 3, used properly:

- `ls -l` on a symlink shows the target path and a size that is the *length* of that path.
- `readlink` follows one hop. `readlink -f` follows all of them, and fails on a dangling arm.
- `ls -lL` and `stat -L` ask about the target instead of the link.
- `find -xtype l` finds links whose target does not exist.
- `ls -i` and `stat -c %h` are the only things that tell a hard link from a copy.
- A symlink has its own mode, owner and timestamps, and `touch -h` sets them.

## The shape of it

The console is not storage. It is a set of names:

```
$ ls -lF deck3/console
```

Four entries, four links. One is a link to a link. One is a link to a directory. One is ordinary.
One resolves to nothing at all.

> **A symlink stores a path string, not a file.** It has no idea whether that path leads anywhere.
> It never checks. The check happens when something opens it, and until something does, a dead
> link and a live link look identical in every column except the one you have to go and test.

## Rules of engagement

1. **You may not create, delete or repair any link until you can say, in writing, where each one
   currently points.** All four. On paper. Before you touch anything.
2. **In-chapter tools only.** `ls`, `stat`, `file`, `ln`, `readlink`, `touch`, `find` with
   `-type`/`-xtype`/`-newer`, `cat`, `head`, `tail`, `wc`, `cd`, `pwd`. No `grep`.
3. **Do not open `setup.sh`.** It is the answer key.
4. **Record what you tried, including what failed.** A command that errors on a dangling link is a
   finding — write down the exact error and the exit status.

## What "solved" looks like

You will be able to state, in one sentence each:

- where each of the four console entries points, and which one goes nowhere,
- the full path the dead one was aimed at,
- why a symlink can outlive its target,
- and how you told the two hard links from the genuine copy sitting next to them.

There is a flag. It is not stored as a flag in any file. Read `exercises.md`.

## Before you move on

- A link that resolves and a link that does not look the same in `ls -l`. Only opening tells you.
- `readlink -f` prints nothing and exits non-zero on a broken chain. That empty output is an answer.
- `readlink -f` stops at the *name* it was pointed at. If that name is a hard link, there is another
  name for the same inode and `-f` will never mention it.
- Two names with the same inode number are one file. Two files with identical bytes are two files.
  The link count column is the difference.
