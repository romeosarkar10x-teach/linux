# 03/02 — Inodes, and what a filename really is

> A filename is not a file. It is a label somebody stuck on one, and labels come off — which is how
> two names end up meaning the same thing and nobody notices for a decade.

Last lesson you learned to read the type character. This lesson is about the object that character
describes, and about the thing you have been mistaking for it: the name.

Every file on a Linux filesystem is an **inode** — a numbered record holding the type, the
permissions, the owner and group, the timestamps, the size, the link count, and the addresses of the
data blocks. Read that list again and notice what is missing. **The inode does not contain the
name.**

Names live in directories. A directory is a file whose contents are a table of
`(name, inode number)` pairs, and nothing more. That is the whole design, and almost every surprise
in this chapter falls out of it.

## Seeing the number

`ls -i` prints the inode number in front of each entry.

```
$ ls -li roster
total 24
44806 -rw-r--r-- 1 cadet crew 38 Aug 23 08:07 copy.txt
44805 -rw-r--r-- 3 cadet crew 38 Aug 23 08:07 crew-list.txt
44805 -rw-r--r-- 3 cadet crew 38 Aug 23 08:07 roster.txt
```

`crew-list.txt` and `roster.txt` are the same number. They are not two files that happen to match.
There is one file, and the directory holds two entries pointing at it. Neither name is the original
and neither is a copy; `ls` cannot tell you which was created first, because the inode does not
record that either.

`copy.txt` has a different number. Its contents are byte-for-byte identical — `cmp` reports no
difference — and it is a different file. **Identical contents are not evidence of identity.** The
inode number is.

## The link count

That `3` in the third column of `ls -l` is the **link count**: how many directory entries point at
this inode. Everybody reads past it. It is the single most informative number in an `ls -l` line
that people never use.

```
$ stat -c '%i %h %n' roster/roster.txt roster/crew-list.txt roster/.backup/names.txt
44805 3 roster/roster.txt
44805 3 roster/crew-list.txt
44805 3 roster/.backup/names.txt
```

Three names, one inode, and the third lives in a different directory. A hard link is not a
same-directory trick; the entry can be anywhere on the same filesystem.

The count is how deletion works. `rm` does not delete files. It removes one `(name, inode)` pair
from a directory and decrements the count. Only when the count reaches zero does the filesystem free
the inode and its blocks. The system call is literally named `unlink`.

```
$ stat -c '%i %h %n' keeper.txt expendable.txt
3288083 2 keeper.txt
3288083 2 expendable.txt
$ rm expendable.txt
$ stat -c '%i %h %n' keeper.txt
3288083 1 keeper.txt
```

Nothing was destroyed. One label came off.

## Directories have link counts too, and they mean something

```
$ stat -c '%i %h %n' decks decks/deck-3
44807 5 decks
44808 2 decks/deck-3
```

`decks` holds three subdirectories and its count is five. A directory's link count is
**(number of subdirectories) + 2**: one for its own name in its parent, one for the `.` entry inside
itself, and one for the `..` entry inside each child. `deck-3` has no subdirectories, so its count is
2 — every empty directory on the system reads 2.

This is also why `.` and `..` are not shell magic. They are real entries with real inode numbers:

```
$ stat -c %i .
44781
$ stat -c %i decks/..
44781
```

Same number. `..` is a name for the parent inode, stored in the child directory, exactly like any
other name.

## Making a hard link

```
$ ln roster.txt second-name.txt
```

No `-s`. `ln` with no options adds a directory entry pointing at an existing inode. Two rules, both
enforced by the kernel:

- **No directories.** `ln decks decks-link` fails with `hard link not allowed for directory`.
  Allowing it would let you build a cycle in the tree with no way to tell which path is the real one,
  and every tree-walking tool would loop forever.
- **No crossing filesystems.** An inode number is only meaningful within one filesystem, so a
  directory entry can only point at an inode on the same one:

```
$ ln /labs/.../roster.txt /home/cadet/x
ln: failed to create hard link '/home/cadet/x' => '...': Invalid cross-device link
```

Note that `df` reports both paths as living on the same physical disk. It is still cross-device,
because the kernel goes by the device number in the inode, and `/labs` is a separate mount:
`stat -c %d /labs` gives `66309`, `stat -c %d /home/cadet` gives `69`.

## Deletion is a directory operation

Since removing a name is a write to the *directory*, the permission that governs it is the
directory's, not the file's.

```
$ ls -l locked/notes.txt
-r--r--r-- 1 cadet crew 32 ... notes.txt
$ echo x > locked/notes.txt
bash: notes.txt: Permission denied
$ rm locked/notes.txt
rm: remove write-protected regular file 'locked/notes.txt'? y
$
```

You cannot write one byte into that file, and you can delete it entirely. `rm` asks first — that
question is a courtesy from `rm`, not a permission check, and answering `y` is the end of it.

The inverse is stranger:

```
$ ls -ld sealed
dr-xr-xr-x 2 cadet crew 4096 ... sealed
$ echo more >> sealed/bolted.txt          # succeeds
$ rm sealed/bolted.txt
rm: cannot remove 'sealed/bolted.txt': Permission denied
```

A writable file in an unwritable directory: you can change its contents freely and you cannot remove
its name. Contents and names are governed by different permissions because they are different
things.

## Renaming changes nothing

```
$ i=$(stat -c %i roster.txt); mv roster.txt renamed.txt; stat -c %i renamed.txt
```

Same number before and after. `mv` within one filesystem writes a new name into a directory and
removes the old one. The file is untouched — which is why `mv` on a 40 GB file inside one filesystem
is instant, and why `mv` **across** filesystems is not (there it must copy and unlink, because the
inode cannot move).

## Gotchas

- Inode numbers are unique per **filesystem**, not per system. Two files on different mounts can
  share a number and be unrelated. Compare `%d %i` — device and inode — to be sure.
- Inode numbers are **reused**. Delete a file and the next one you create may take its number. The
  number identifies a file only while that file exists.
- A hard link is not "a link to the original". There is no original. Delete the name you made first
  and the other name still works.
- Editors break hard links. Many write a new file and rename it over the old name, which leaves your
  other name pointing at the old inode with the old contents. `stat` the link count afterwards.
- `cp -a` of a directory containing two hard-linked names produces two independent files unless you
  pass `--preserve=links`.

## Before you move on

- An inode holds everything about a file except its name; the name lives in a directory as a
  `(name, inode)` pair.
- The third column of `ls -l` is the link count — how many names point at this inode.
- `rm` removes a name and decrements the count; the data goes away at zero.
- A directory's link count is its subdirectory count plus two.
- Deleting is a write to the directory, so a read-only file in a writable directory is deletable.
