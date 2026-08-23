# 03/03 — Hard links and symbolic links

> Half the maintenance tree is links pointing at other links. Three of them go somewhere.

Last lesson you learned that a filename is a directory entry pointing at an inode, and that two
names can point at the same inode. That is a **hard link**, and you have already made one with `ln`.

This lesson finishes the picture with the other kind. A **symbolic link** — symlink, soft link — is
not a second name for an inode. It is a small file of its own, with its own inode, whose *contents*
are a path. When something opens it, the kernel reads that path out and starts again from there.

Two mechanisms, one arrow in `ls -l`. Almost every confusing thing about links comes from mixing
them up.

## The two kinds side by side

```
$ ls -li panels
44823 lrwxrwxrwx 1 cadet crew 12 Aug 23 08:20 current -> panel-07.txt
44824 lrwxrwxrwx 1 cadet crew 70 Aug 23 08:20 current-abs -> /labs/03-files-links-and-types/03-hard-vs-symlinks/panels/panel-07.txt
44822 -rw-r--r-- 2 cadet crew 40 Aug 23 08:20 panel-07-alias
44822 -rw-r--r-- 2 cadet crew 40 Aug 23 08:20 panel-07.txt
```

`panel-07.txt` and `panel-07-alias` share inode **44822** and the link count is **2**. Neither is
the original; the inode has two names and no opinion about which came first. Delete either and the
other still holds the file.

`current` has inode **44823**, its own. It is a different file. Its type character is `l`, and its
contents are the twelve bytes `panel-07.txt`.

| | hard link | symbolic link |
|---|---|---|
| what it is | another directory entry for one inode | a separate file holding a path |
| own inode? | no | yes |
| raises target's link count? | yes | no |
| survives target's deletion? | yes — it *is* the file | no — it dangles |
| across filesystems? | no | yes |
| to a directory? | no | yes |
| made with | `ln target name` | `ln -s target name` |

## Size is the length of the target string

That `12` in the size column is not a coincidence and it is not the size of `panel-07.txt`
(which is 40). `panel-07.txt` is twelve characters long.

```
$ ls -l sizes/long sizes/short
lrwxrwxrwx 1 cadet crew 40 ... long -> very/deeply/nested/subdirectory/leaf.txt
lrwxrwxrwx 1 cadet crew  8 ... short -> leaf.txt
```

Forty and eight — the exact lengths of those two path strings. A symlink's size *is* its target
path, which is the fastest way to convince yourself the contents really are just text.

> **`total 0`.** `ls -l` on a directory of nothing but symlinks reports `total 0` blocks. A short
> target path is stored inside the inode itself (a "fast symlink"), so no data block is allocated
> at all. The file has a size and occupies no space.

## `lrwxrwxrwx` is decoration

Every symlink shows `rwxrwxrwx`. Those bits are never consulted. Access is decided by the
permissions of whatever the link resolves to.

```
$ ls -l perms
lrwxrwxrwx 1 cadet crew 10 ... back-door -> sealed.txt
lrwxrwxrwx 1 cadet crew 10 ... open-door -> secret.txt
---------- 1 cadet crew 25 ... sealed.txt
-rw------- 1 cadet crew 35 ... secret.txt
$ cat perms/back-door
cat: perms/back-door: Permission denied
```

The link says world-writable. The read still fails, because `sealed.txt` says mode 000. A symlink
grants nothing. If you ever see `lrwxrwxrwx` and conclude something is exposed, you have read the
wrong line.

## Following the arrow: `readlink`

`readlink` prints a symlink's contents — **one hop, verbatim**, no resolution:

```
$ readlink chain/a
b
```

`chain/a` points at `b`, which points at `c`, which points at `../target/report.txt`. To resolve
the whole run, use `-f`:

```
$ readlink -f chain/a
/labs/03-files-links-and-types/03-hard-vs-symlinks/target/report.txt
```

`-f` canonicalises: it follows every link in the chain, resolves `.` and `..`, and prints one
absolute path. It is the tool for the question "where does this *actually* end up".

Three variants worth knowing:

| | requires |
|---|---|
| `readlink -f` | every component **except the last** must exist |
| `readlink -e` | **every** component must exist, last one included |
| `readlink -m` | nothing must exist |

That distinction is not academic:

```
$ readlink -f dangling/vanished
/labs/.../target/gone.csv          # exit 0 — the directory exists, the file does not
$ readlink -e dangling/vanished
                                   # exit 1, prints nothing
$ readlink -f dangling/ghost
                                   # exit 1 — /mnt/engineering itself is gone
```

`-f` tells you *where a link points*. `-e` tells you *whether that thing is there*. Use `-e` when
you are auditing a tree for broken links, `-f` when you need the path a broken link was aiming at —
and that path is often the interesting artefact.

## Dangling links

Nothing prevents a symlink from pointing at a path that does not exist. The link is created
happily, lives forever, and fails only at the moment something dereferences it.

```
$ ls -l dangling
lrwxrwxrwx 1 cadet crew 38 ... ghost -> /mnt/engineering/strain-2187-05-22.csv
lrwxrwxrwx 1 cadet crew 16 ... ghost-dir -> /mnt/engineering
$ cat dangling/ghost
cat: dangling/ghost: No such file or directory
```

Note carefully what the error blames. `dangling/ghost` exists — you just listed it. The
`No such file or directory` is about the *target*. A symlink and its target are two separate
questions, and most link confusion is answering one while thinking about the other.

## `stat` and `stat -L`

`stat` describes the link. `stat -L` dereferences and describes the target.

```
$ stat -c '%i %h %s %F %A %N' panels/current
44823 1 12 symbolic link lrwxrwxrwx 'panels/current' -> 'panel-07.txt'
$ stat -L -c '%i %s %F' panels/current
44822 40 regular file
```

Same argument, two inodes, two sizes, two types. `%N` prints the name with the arrow, which is the
quickest way to dump what a batch of links point at. The same `-L` idea runs through the toolbox:
`ls -lL`, `file -L`, `du -L`, `cp -L`.

## Relative or absolute targets

A relative target is resolved **from the directory the link sits in**, not from your current
directory. That has a consequence:

- `near -> note.txt` keeps working if you rename the directory containing both.
- `far -> /labs/.../moved/inner/note.txt` breaks the moment that path changes.

Relative links survive a tree being moved; absolute links survive a link being moved. Pick by
asking which of the two is more likely.

## Loops

Two links pointing at each other are legal to create and impossible to follow:

```
$ cat loop/ring-a
cat: loop/ring-a: Too many levels of symbolic links
```

The kernel gives up after roughly forty hops (`ELOOP`) rather than spinning. `ls -l` still shows
both links perfectly well — listing a link never dereferences it.

## Gotchas

- `ln -s` does not check the target. Typos become dangling links silently.
- `ln -s` records the target string **exactly as you typed it**. Type a relative path while standing
  somewhere else and you get a link that is wrong from birth.
- `rm link` removes the link. `rm link/` may remove nothing and error — the trailing slash means
  "the directory it points to".
- `cp` follows symlinks by default and copies the target's contents; `cp -P` (or `-a`) copies the
  link itself. On a dangling link the default `cp` fails outright: `cannot stat`.
- `ln -sf` replaces an existing link — but if the name is an existing *directory*, it drops the new
  link *inside* it instead. `ln -sfn` is the habit that avoids that.
- Hard links to directories are refused, and hard links cannot cross filesystems. You proved both
  last lesson.

## Before you move on

- A hard link is another name for one inode; a symlink is a file whose contents are a path.
- A symlink's size is the length of its target string, and `total 0` because it needs no block.
- `lrwxrwxrwx` is decoration — the target's permissions decide.
- `readlink` is one hop; `readlink -f` resolves the whole chain; `readlink -e` also demands the
  target exist.
- A dangling link is a normal file pointing at nothing, and the error names the target, not the link.
