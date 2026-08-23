# 04/04 — `rm`, Safely

> `rm` has no undo, no confirmation you can rely on, and a folklore problem. Everything here lives
> in a lab directory and `kestrel reset` puts it back, so make the mistake now.

## What this lesson is

`rm` is four hundred lines of C with a very simple job and a reputation out of all proportion to its
complexity. Most of that reputation comes from stories rather than from behaviour, and the stories
teach the wrong lessons — usually some version of "type carefully", which is not a technique.

The technique is understanding exactly what `rm` does, exactly who is allowed to stop it, and where
the actual danger is. It is not where the folklore says.

## `rm` removes names, not files

`unlink()` is the syscall, and the name is honest. `rm` deletes a **directory entry**. The file's
inode — its contents, its mode, its times — is freed only when two counters both reach zero: the
number of names pointing at it, and the number of processes holding it open.

Two consequences you will measure in this lesson. Delete one of two hard links and the data is
entirely intact under the other name, with the link count down to one. Delete a file that a running
program has open and the name disappears immediately, the program keeps reading happily, and the
disk space does **not** come back until that program exits. A full disk that stays full after you
deleted the log file is this, every time.

## Who gets to say no

Here is the part that surprises people: **the permissions on the file have almost nothing to do with
whether you can delete it.** Removing a name means modifying the directory that holds it, so what
matters is write permission on the *directory*.

So a file with mode `0400` in a directory you own is deletable. `rm` will ask first — "remove
write-protected regular file?" — but that prompt is a courtesy, it only appears when there is a
terminal to answer it, and it does not appear at all under `-f`. Meanwhile a perfectly writable
`0644` file inside a `0555` directory cannot be removed by you at all, and `-f` does not help,
because `-f` suppresses prompts and missing-file errors — it does not grant permissions the kernel
just refused.

## The folklore

`rm -rf /` does not work. GNU `rm` refuses it outright and tells you which flag would override the
failsafe, and modern coreutils extend that to `--preserve-root=all`, which also refuses to cross a
filesystem boundary. The famous story is thirty years old and the danger it describes has been
patched since 2006.

What has *not* been patched is `rm -rf $DIR/` where `DIR` is unset, `rm -rf ./ *` with a stray space,
or a `find … -exec rm -rf {} \;` whose path expression matched more than you thought. The failsafe
protects one specific path. It does not protect the directory you actually care about, and nothing
does.

## The flags

`-r` for trees; without it `rm` refuses a directory. `-i` prompts per file, `-I` prompts once for
more than three files, which is the one that survives contact with real use. `-f` means: do not
prompt, do not complain about files that do not exist, and exit 0 anyway — which is why `rm -f` is
correct in scripts and dangerous in a shell where you have not finished thinking.

`--` ends the options, which is how you delete the file called `-f` that somebody left in the
directory. `./-f` does the same job by making the name not start with a dash at all, and needs no
cooperation from `rm`.

## The shape of the lab

`junk/` for ordinary deletions. `awkward/` holds names that fight the shell: one called `-f`, one
called `--force`, one with a space, one with a newline in the middle. `protected/` has a `0400` file
in a normal directory; `locked/` has a `0644` file in a `0555` directory — the two halves of the
permission story. `linked/` has a hard-link pair, a symlink to a file and a symlink to a directory.
`busy/big.log` is for deleting a file while something is reading it. `trash/` and `scratch/` are
yours.

## Rules of engagement

Delete everything in this lab. That is what it is for, and `kestrel reset 04/04` brings it back.

Two habits worth building while you are here. First: run the glob through `ls` before you run it
through `rm` — the shell expands it identically for both. Second: when the command is long or the
glob is clever, put the `rm` at the end, not the beginning, so you read what you are deleting before
you say what to do with it (`find … -print` before `find … -delete`).

## What "solved" looks like

You can say why `rm` cannot delete a file in one directory and can delete a read-only file in
another. You have watched a file survive its own deletion under a second name, and watched disk
space fail to come back. You can delete a file called `--force` two different ways. And you can say
what `rm -rf /` actually does today, from having run it.

## Before you move on

Next is the incident. You will be handed a manifest for a tree that no longer exists, and everything
from the last three lessons is on the table.
