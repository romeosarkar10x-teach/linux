# 04/03 — `cp` & `mv`

> Copying is not moving and neither of them is what the trailing slash makes you think. This is
> where most people's first destructive mistake happens.

## What this lesson is

Two commands. Both take a source and a destination, both are used a hundred times a day, and both
will silently destroy a file if you point them at one that already exists. There is no undo. There
is no confirmation unless you ask for it, and the flag that asks for it does nothing when the
command is running from a script.

That is the whole risk surface, and it is small enough to learn properly in one sitting.

## `cp` copies bytes; `mv` renames

`cp` opens the source, creates the destination, and writes the bytes across. Two files exist
afterwards, with two inodes, and the copy is a genuinely new file that happens to have the same
contents.

`mv` does not move anything, in the usual case. If the source and the destination are on the same
filesystem it makes a new directory entry pointing at the **same inode** and unlinks the old one.
Nothing is read, nothing is written, and a fifty-gigabyte file renames as fast as an empty one. That
is why "rename" and "move" are the same command: from the filesystem's point of view they are the
same operation, and which one it looks like depends only on whether the two directory entries happen
to be in the same directory.

Point `mv` at a different filesystem and it can no longer do that — a directory entry cannot name an
inode on another device. `mv` falls back to copy-then-delete, the file gets a **new inode**, and the
speed changes from instant to however long the bytes take. `/labs` and `/tmp` are on different
filesystems in this container, which makes that measurable.

## What the destination means

Everything confusing about these two commands comes from one rule: **the meaning of the destination
depends on what is already there.**

- Destination does not exist → it becomes the new name. `cp a b` creates `b`.
- Destination exists and is a **file** → it is overwritten. No prompt, no backup, gone.
- Destination exists and is a **directory** → the source is copied or moved *into* it, keeping its
  own name. `cp a d` creates `d/a`.

So the same command line does two entirely different things depending on the state of the
filesystem at the moment you press return. `cp -r source dest` makes `dest/source` if `dest` exists,
and makes `dest` a copy of `source` if it does not. This is not a wart you can memorise your way
around; it is the reason `-T` exists, which forces the destination to be treated as a name and never
as a directory to descend into.

The trailing slash is not the fix people think it is. On the source it is nearly always a no-op —
except on a symlink, where `latest.txt/` is a demand that the shell resolve a link to a directory
and fails with `Not a directory` when it points at a file. On the destination it is an assertion:
`mv f nosuch/` fails rather than creating a file called `nosuch`, which is occasionally exactly what
you want.

## The flags worth knowing

`-r` (or `-R`) for directories — without it `cp` refuses and tells you so. `-i` prompts before
overwriting, `-n` refuses to overwrite at all, and where both are given the last one wins. `-u`
copies only when the source is newer than the destination, or the destination is missing. `-v`
prints what it did, which is the cheapest possible safety net.

`-a` is the one to understand rather than memorise. Plain `cp` already preserves the mode — with the
umask applied — but not the ownership, not the timestamps, and not the identity of hard links. `-a`
is `-dR --preserve=all`: recursive, symlinks copied as symlinks rather than followed, and every
piece of metadata carried across including the fact that two names were the same inode. If you are
copying a tree that you intend to be the same tree, `-a` is the flag.

## The shape of the lab

`source/` is a small deck tree with two subdirectories, a symlink and a hard-link pair. `dest/`
already exists as a directory and already has a `handover.txt` in it. `dest-file` already exists as a
regular file. `stale/` holds older copies of three of the source files, and one copy that is
*newer* than its source. `perms/` has a 755 script and a 600 file. `rename/` has six logs with the
wrong prefix. `scratch/` is where anything destructive happens.

## Rules of engagement

Destroy things — that is what the lab is for — but destroy them in `scratch/` or in a `mktemp -d`,
and use `kestrel reset 04/03` the moment you are unsure what state you are in. Several exercises
depend on the seeded timestamps, so a lab you have been overwriting at random will give you wrong
answers with no error message.

Every prompting flag (`-i`) is worth trying once with `</dev/null` to see what it does when there is
no human to answer it.

## What "solved" looks like

You can state, without running anything, what `cp -r a b` will do given the three possible states of
`b`. You can say which of mode, owner, timestamp and hard-link identity survives a plain `cp` and
which needs `-a`. You have seen `mv` keep an inode and then seen it change one. And you have
overwritten a file you cared about at least once, in a directory where it did not matter.

## Before you move on

Two things to carry into the next lesson: overwriting is deletion by another name, and the
protections you get by default are none.
