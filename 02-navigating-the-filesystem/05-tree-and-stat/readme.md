# 02/05 — Shape, metadata and size

> Disk accounting says a maintenance directory holds forty megabytes. It looks empty. One of those
> two facts is a lie and it is not the one you would guess.

So far you have asked *where* things are. This lesson asks three different questions about them:
what **shape** is this tree (`tree`), what does the filesystem **know** about this file (`stat`),
what **is** this file (`file`), and how much **space** does any of it take (`du`, `df`).

The last of those is where beginners get burned. There is no single number called "the size of a
file", and once you know why, a whole class of confusing situations stops being confusing.

## `tree` — the shape of a directory

`ls -R` prints a recursive listing as a flat sequence of directory blocks. `tree` prints the same
information as a picture, and gives you a count at the bottom.

```
$ tree bays
bays
├── deck-3
│   ├── bay-1
│   │   ├── panels
│   │   └── survey.txt
│   ├── bay-2
│   │   ├── panels
│   │   │   ├── panel-07.txt
│   │   │   └── panel-08.txt
│   │   └── survey.txt
│   └── loop -> ../..
└── deck-4
    └── bay-1
        └── survey.txt

9 directories, 5 files
```

Flags worth knowing:

| Flag | Effect |
|---|---|
| `-a` | include dotfiles — **and dot-directories**, which is usually the bigger change |
| `-d` | directories only |
| `-L n` | descend at most `n` levels |
| `-f` | print the full path on every line, not just the base name |
| `-F` | append a type marker (`/`, `*`, `@`) as `ls -F` does |
| `-p` | prefix each line with its permission bits |
| `-h` | human-readable sizes; `-s` for raw byte sizes |
| `--du` | with `-s`/`-h`, make a directory's size the **sum of its contents** |

That count on the last line is the part people forget to read. It is the cheapest way to answer "did
adding `-a` change anything?" — if the counts move, something was hidden.

> **Symlinks and loops.** `tree` does not follow symlinks by default; it prints
> `loop -> ../..` and stops. `tree -l` does follow them, which means it can walk into a directory
> that contains a link back to one of its own ancestors. It detects that and prints
> `[recursive, not followed]` rather than running forever. Very few tools are that polite.

## `stat` — everything the filesystem records

`ls -l` is a summary. `stat` is the whole record.

```
$ stat waiter.sh
  File: waiter.sh
  Size: 168        Blocks: 8          IO Block: 4096   regular file
Device: 259,5      Inode: 44679       Links: 1
Access: (0755/-rwxr-xr-x)  Uid: ( 1005/cadet)   Gid: ( 1001/crew)
Access: 2026-08-23 05:54:08.010553746 +0000
Modify: 2026-08-23 05:54:07.971553746 +0000
Change: 2026-08-23 05:54:07.975553746 +0000
 Birth: 2026-08-23 05:54:07.969553746 +0000
```

The three timestamps everyone mixes up:

| Name | `stat` label | Changes when |
|---|---|---|
| **atime** | `Access` | the file's **contents** are read |
| **mtime** | `Modify` | the file's **contents** are written |
| **ctime** | `Change` | the file's **inode** changes — contents, permissions, owner, name, link count |

Two consequences worth memorising:

- **`ls -l` shows mtime**, not ctime and not "creation time". `ls -lu` shows atime, `ls -lc` shows
  ctime.
- **ctime cannot be set.** `touch -d '2187-06-01' file` will happily backdate atime and mtime to a
  date a century away — but the act of doing so *is* an inode change, so ctime becomes now. Someone
  covering their tracks with `touch` leaves that behind.

`stat -c` takes a format string, which is how you get one field instead of twelve:

```
$ stat -c '%n %s %F %a %U' /etc/hostname
/etc/hostname 8 regular file 644 root
```

`%n` name · `%s` size in bytes · `%b` blocks allocated · `%F` type · `%a` permissions in octal ·
`%A` permissions as `ls` draws them · `%U` owner · `%G` group · `%i` inode · `%h` link count ·
`%y` mtime · `%z` ctime · `%x` atime. There are more; `man stat` lists them all in one table.

## `file` — what something actually is

Linux filenames have no required meaning. `.txt` is a convention between humans, and nothing
enforces it. `file` ignores the name and reads the beginning of the contents, comparing them against
a database of signatures ("magic numbers").

```
$ file notes.txt hullscan telemetry.txt subsystem
notes.txt:     ASCII text
hullscan:      ELF 64-bit LSB pie executable, x86-64, ... stripped
telemetry.txt: gzip compressed data, from Unix, original size modulo 2^32 26
subsystem:     directory
```

`telemetry.txt` is not text. Nothing is broken; someone just named it that. Before you `cat` an
unknown file — which can dump control codes into your terminal and leave it unreadable — ask `file`
what it is.

Useful behaviours:

- `file` reports `empty` for a zero-byte file, and `data` when it recognises nothing.
- On a symlink it reports the link and its target, and says `broken symbolic link to …` when the
  target does not exist. `file -L` follows the link and describes the target instead —
  and on a broken link it fails outright with `cannot open … (No such file or directory)`, which is
  a different and much louder answer than the default's calm one-liner.
- `file -b` drops the filename prefix, which matters when you want just the answer.

## `du` and `df` — two different questions about space

**`du`** walks a tree and adds up what its files occupy. **`df`** asks the filesystem how full it is.
They disagree constantly and both are right.

```
$ du -sh accounting
40M     accounting
$ df -h /labs
Filesystem      Size  Used Avail Use% Mounted on
/dev/nvme2n1p2  358G  242G   98G  72% /labs
```

`du` flags: `-s` summarise (one total per argument, not one line per file) · `-h` human-readable ·
`-a` every file, not just directories · `-d n` limit depth · `--apparent-size` report file sizes
instead of disk usage.

`df` flags: `-h` human-readable · `-T` show the filesystem type · `-i` report **inodes** instead of
blocks. That last one solves a genuinely baffling failure: a disk with free space that refuses to
create a file, because it has run out of inodes.

### The size that is a lie

Two files, two different lies, opposite directions:

```
$ ls -l ledger/reserved.img
-rw-r--r-- 1 cadet crew 52428800 Aug 23 06:03 ledger/reserved.img
$ du -h ledger/reserved.img
0       ledger/reserved.img
```

Fifty megabytes according to `ls`, zero according to `du`. Both are honest. `ls` reports the
**apparent size** — the offset of the end of the file, i.e. how many bytes you would read out of
it. `du` reports **allocated blocks**. This file is *sparse*: it was declared 50 MB long but no data
was ever written, so the filesystem allocated nothing and will hand you zeros for any part you read.
`stat` shows the mechanism directly: `Size: 52428800  Blocks: 0`.

The other direction is subtler and is the one in the page above:

```
$ ls accounting
$ du -sh accounting
40M     accounting
```

`ls` prints nothing at all and `du` says forty megabytes. Neither is lying either — and the
resolution is something you already learned in `02/02`. Work out which one of them is telling you
less than it knows.

Also note the *small* lie in the other direction: `du` on a 40-byte file usually reports 4.0K,
because space is allocated in blocks and a block is the smallest unit the filesystem hands out. A
thousand tiny files cost far more than the sum of their contents.

## Gotchas

- `du` without `-s` prints a line **per directory** and the last line is the total. People read the
  first line and get a wrong answer.
- `du` counts what it can descend into. Run it over a tree containing directories you cannot read
  and the total is silently short — the errors go to a stream you may have hidden.
- `-h` numbers are rounded and use 1024-based units. `40M` is not exactly forty million bytes.
- `file` reads only the first few hundred bytes. A text file that turns into binary halfway through
  is still reported as text.
- `tree` and `du` both count a symlink as one small entry — they do not add in the target.

## Before you move on

- `tree -a` and the count on the last line answer "is anything hidden here?" in one command.
- `ls -l` shows mtime; atime is `-u`, ctime is `-c`, and **ctime cannot be backdated**.
- `file` reads the contents; the extension is decoration.
- `ls` shows apparent size, `du` shows allocated blocks, and a sparse file makes them disagree by
  fifty megabytes.
- `df -i` exists, and is the answer when a disk with free space says it is full.
