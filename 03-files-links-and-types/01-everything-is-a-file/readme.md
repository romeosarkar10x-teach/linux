# 03/01 — Everything is a file

> The first character of every `ls -l` line is the station telling you what kind of thing it is.
> Most people read past it for years.

"Everything is a file" is the sentence people quote about Unix, and it is usually said as though it
were poetry. It is not. It is a design decision with a visible consequence: the same seven system
calls — `open`, `read`, `write`, `close`, and friends — operate on a text file, a disk, a keyboard,
and a channel between two running programs. Because they all answer the same calls, they all appear
in the same directory tree, and `ls -l` has to tell you which is which.

That is the job of the first column.

## The seven types

```
$ ls -l types
total 8
srwxr-xr-x 1 cadet crew    0 Aug 23 07:59 control.sock
drwxr-xr-x 2 cadet crew 4096 Aug 23 07:59 deck-3
prw-rw-rw- 1 cadet crew    0 Aug 23 07:59 pipeline
lrwxrwxrwx 1 cadet crew   11 Aug 23 07:59 pointer -> regular.txt
-rw-r--r-- 1 cadet crew   36 Aug 23 07:59 regular.txt
brw-rw---- 1 cadet crew 7, 200 Aug 23 07:59 scratch-disk
crw-rw-rw- 1 cadet crew  1,   3 Aug 23 07:59 void
```

| Char | Type | What it is |
|---|---|---|
| `-` | regular file | bytes on disk. Text, binaries, images, everything ordinary |
| `d` | directory | a list mapping names to inode numbers. Lesson 2 |
| `l` | symbolic link | a small file whose contents are a *path*. Lesson 3 |
| `c` | character device | a driver you read/write a byte at a time — terminals, `/dev/null` |
| `b` | block device | a driver addressed in fixed-size blocks — disks, partitions |
| `p` | named pipe (FIFO) | a buffer with a name. Two programs, one channel. Lesson 5 |
| `s` | socket | like a FIFO but bidirectional, and speaks a protocol. Lesson 5 |

Seven characters, and only the first two are ones most people ever consciously look at. Learn them
now: from here on, "why does `cat` hang on this file" and "why is this file zero bytes but full of
data" are both answered by that one character.

## Three tools that answer three different questions

They are not interchangeable and the difference matters.

**`ls -l`** — asks the *directory entry and inode*: what type, what permissions, what size.
Cheapest, always right about type, tells you nothing about contents.

**`stat -c %F`** — asks the *inode* for the type in words:

```
$ stat -c '%F' types/pipeline types/void types/scratch-disk types/pointer
fifo
character special file
block special file
symbolic link
```

**`file`** — ignores the name and the mode, opens the thing, and reads the first few hundred bytes,
comparing them against a database of signatures. For special files it does not read at all; it
reports the type, and for devices it prints the numbers:

```
$ file types/*
types/control.sock: socket
types/deck-3:       directory
types/pipeline:     fifo (named pipe)
types/pointer:      symbolic link to regular.txt
types/regular.txt:  ASCII text
types/scratch-disk: block special (7/200)
types/void:         character special (1/3)
```

Note the three tools disagree on *wording* for the same object — `stat` says `fifo`, `file` says
`fifo (named pipe)`, `ls` says `p`. They agree on the fact. If you are ever scripting against one of
these, know which one you are parsing.

`file` is the one you use on *regular* files, because that is the only case where the answer is not
already in the mode:

```
$ file manifest/*
manifest/empty:       empty
manifest/hull-log:    ELF 64-bit LSB pie executable, x86-64, ... stripped
manifest/latin1.txt:  ISO-8859 text
manifest/panel.png:   ASCII text
manifest/panelcheck:  Bourne-Again shell script, ASCII text executable
manifest/survey.txt:  gzip compressed data, from Unix, original size modulo 2^32 31
manifest/utf8.txt:    Unicode text, UTF-8 text
```

`panel.png` is text. `survey.txt` is gzip. Nothing is broken — the extension is a note between
humans and the kernel never reads it. `file -b` drops the name prefix; `file -i` prints the MIME
type instead of prose (`text/plain; charset=us-ascii`, `application/gzip; charset=binary`).

## `ls -F` and its blind spot

`-F` appends a one-character marker so you can see types without `-l`:

```
$ ls -F types
control.sock=  deck-3/  pipeline|  pointer@  regular.txt  scratch-disk  void
```

`/` directory · `@` symlink · `|` FIFO · `=` socket · `*` executable. **Device nodes get no marker
at all**, and neither do plain files — so in `-F` output `scratch-disk` and `regular.txt` look
identical. `-F` is a convenience, not an answer.

## `/dev/null` and `/dev/zero`

Two character devices you will use constantly, both of them the same kind of object as
`types/void`:

- **`/dev/null`** — major 1, minor 3. Everything written to it is discarded; every read returns
  end-of-file immediately. It is the wastebasket you redirect output into.
- **`/dev/zero`** — major 1, minor 5. Reads return an endless run of zero bytes. It is how you
  fabricate a file of a given size.

Two devices are "the same device" when their **major and minor numbers** match, not when their
names do. Major says which driver; minor says which instance that driver should use. `types/void`
was created with `mknod void c 1 3` — the same pair as `/dev/null` — so it *is* a second
`/dev/null`, under a different name, in a different directory.

That is also why `ls -l` prints `1,   3` where a size would go. A device node holds no data; there
is nothing to measure, so the field is reused for the numbers that identify the driver.

## Sizes that are not sizes

- A **device node**: size 0, blocks 0. The data lives in the driver, not the file.
- A **symlink**: size = the length of the target path string. `pointer -> regular.txt` is 11 bytes
  because `regular.txt` is eleven characters. That is literally all a symlink contains.
- A **FIFO** and a **socket**: size 0, always. Nothing is stored; bytes pass through.
- An **empty regular file**: size 0 too — and `file` calls it `empty`, not `text`.

## Gotchas

- `cat` on a FIFO **blocks** — it waits, apparently hung, until another process opens the other end.
  That is not a crash. `Ctrl-C` gets you out.
- `cat` on a socket fails immediately: `No such device or address`. Sockets need a program that
  speaks their protocol; `cat` is not one.
- `file` on a symlink describes the *link*. `file -L` follows it and describes the target.
- `file` reads only the first few hundred bytes, so a text file that becomes binary halfway through
  is still reported as text.
- Reading a block device with no backing store attached fails. Permission and existence are separate
  questions from *does this driver have anything behind it*.

## Before you move on

- The seven first-column characters are `-` `d` `l` `c` `b` `p` `s`, and you can name each.
- `ls -l` reads the inode, `file` reads the contents, and the file extension is decoration.
- A symlink's size is the length of its target path; a device node's size field holds major and
  minor instead.
- Two device nodes with the same major/minor are the same device, whatever they are called.
- `ls -F` marks directories, symlinks, FIFOs, sockets and executables — and says nothing about
  device nodes.
