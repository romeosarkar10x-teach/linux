# 03/05 — Devices, FIFOs & Sockets

> Some files are not storage. They are holes in the wall that two programs shout through. You are
> going to build one and shout through it.

## Where you are

Lesson 01 said everything is a file. You have spent three lessons on the kind of file that holds
bytes on a disk, and on the two ways a name can point at one. This lesson is the other kind: the
files that hold nothing at all, and are still files, and are still worth having.

There are seven file types on this system. You have met four of them without being told they were a
category:

| `ls -l` | `stat -c %F` | name | what it is |
|---|---|---|---|
| `-` | `regular file` | regular file | bytes on a disk |
| `d` | `directory` | directory | a list of names and inode numbers |
| `l` | `symbolic link` | symlink | a stored path |
| `p` | `fifo` | named pipe | a queue between two processes |
| `s` | `socket` | socket | a two-way channel between two processes |
| `c` | `character special file` | character device | a stream handled by a driver |
| `b` | `block special file` | block device | a random-access device handled by a driver |

That first column is not decoration. It is the type field of the inode, and it is fixed when the
file is created. A regular file cannot become a FIFO. You do not convert; you delete and remake.

## Why a file that stores nothing

A file name is the one thing every program on this system already knows how to open. If you want two
unrelated programs to talk — one written in C in 1994, one you wrote this morning — the cheapest
contract you can offer them is a path. Both sides call `open()`. Neither side needs to know the
other exists.

So the kernel offers file-shaped things that are not storage:

- A **FIFO** (named pipe) is `|` with a name. One process writes, another reads, the bytes never
  touch a disk. It is one-directional and one-shot: each byte is delivered to exactly one reader and
  is then gone.
- A **socket** is the same idea, two-directional, with the connection semantics of the network stack
  but staying inside the machine. You will see them in this lesson and use them properly much later.
- A **device node** is not a channel at all. It is a *name for a driver*. `/dev/null` contains no
  data; it is a pair of numbers that tells the kernel "send everything here to driver 1, unit 3",
  and driver 1 unit 3 throws it away.

## Mechanism: what a device node actually stores

A device node has no data blocks. What it has is a **major** and a **minor** number, stored in the
inode where a regular file stores its size.

```
$ ls -l /dev/null
crw-rw-rw- 1 root root 1, 3 Aug 23 07:52 /dev/null
```

Where every other listing shows a size, a device shows `1, 3`. Major 1 selects the driver; minor 3
selects which thing that driver offers. `stat` will show you the same pair, but in **hex**:

```
$ stat -c "%F major=%t minor=%T" /dev/null
character special file major=1 minor=3
$ stat -c "%F major=%t minor=%T" zoo/dev-sensor
block special file major=7 minor=c8
```

`c8` is 200. `%t` and `%T` are hexadecimal and `ls` is decimal; they are not disagreeing with each
other. This catches people who only ever look at one of the two.

Character versus block is about how the driver is spoken to: a character device is a stream you read
and write byte by byte in order; a block device is addressable in fixed-size chunks and sits behind
the kernel's buffer cache. Disks are block. Terminals, `/dev/null`, and randomness are character.

Because the node is only a *name* for a driver, two nodes with the same numbers are the same device.
`zoo/null-clone` is `c 1 3`. It is `/dev/null`, under a different name, in your lab directory. That
is not a copy of `/dev/null` — there is nothing to copy.

## The standard character devices

| path | reading it gives you | writing to it does |
|---|---|---|
| `/dev/null` | end-of-file, immediately | nothing, successfully |
| `/dev/zero` | endless `0x00` bytes | nothing, successfully |
| `/dev/full` | endless `0x00` bytes | **fails** with `No space left on device` |
| `/dev/urandom` | endless unpredictable bytes | stirs the pool, harmlessly |
| `/dev/tty` | whatever your terminal is | writes to your terminal |

`/dev/full` exists to test error handling: it is a disk that is always full, on demand.

`/dev/tty` is the odd one. It is not one device — it is "the terminal of whichever process opens
it". That makes it the way to reach the user even when your output has been redirected:

```
$ { echo to-stdout; echo to-tty > /dev/tty; } > console/cap.txt
to-tty
$ cat console/cap.txt
to-stdout
```

The `> console/cap.txt` captured stdout. It could not capture the line that went to `/dev/tty`,
because that line never went through stdout. This is how `ssh` and `sudo` prompt for a password in
the middle of a pipeline.

## Mechanism: what a FIFO does when you open it

```
$ mkfifo pipe/inbox
$ ls -lF pipe/inbox
prw-r--r-- 1 cadet crew 0 May 21  2187 pipe/inbox|
```

Size 0, and it stays 0 forever, no matter how much traffic passes through. There is no storage to
measure. `du` agrees: 0.

The rule that governs everything else in this lesson is this:

> **Opening a FIFO for reading blocks until some process opens it for writing, and opening for
> writing blocks until some process opens it for reading.**

That is not a bug and it is not a timeout you are waiting out. It is the rendezvous. Two commands in
two terminals, and neither one starts until both have arrived:

```
# terminal A                    # terminal B
$ cat pipe/inbox                $ echo 'panel 07 clear' > pipe/inbox
panel 07 clear                  $
$
```

Terminal A sat there doing nothing until B ran. Then both finished. Run them in the other order and
you get the same result: B blocks until A arrives.

The bytes are consumed. Read it again and you get nothing — a FIFO is not a mailbox that keeps a
copy.

## Gotchas

- **`timeout 1 cat < p` still hangs forever.** The redirect `< p` is performed by *the shell*,
  before `timeout` is ever executed, and the shell blocks on the open. There is nothing left to time
  out. Give the open to a program that can do it non-blocking: `timeout 2 dd if=p iflag=nonblock`,
  which returns `0+0 records out` on an idle FIFO. If you are already stuck: **Ctrl-C**.
- **One FIFO, several readers, one delivery.** If two `cat`s are waiting, each line goes to exactly
  one of them, and which one is a race. This is a queue, not a broadcast.
- **You cannot make a device node.** `mknod` needs `CAP_MKNOD`, which cadet does not have. This is a
  security boundary, not an oversight: a device node is direct access to a driver, and a node you
  could plant in a directory someone else trusts would be a way around every permission on the real
  one.
- **A device node is a name, not an entitlement.** You can own `zoo/dev-sensor` outright and still be
  refused when you read it, because access to devices is mediated separately from file permissions.
- **`cp` of a FIFO does what you did not mean.** Plain `cp fifo dest` tries to *read the FIFO* and
  blocks. `cp -R` recreates it as a FIFO instead. Neither one is "copying the data" — there is none.

## Before you move on

You should be able to:

- name all seven types, and produce each one's `ls -l` letter and `stat -c %F` string from memory;
- read a `1, 3` in a size column and say what it means;
- explain why `%t` says `c8` and `ls` says `200`;
- create a FIFO and move a line through it between two terminals, in either order;
- say what happens to a FIFO's size when a megabyte passes through it, and why;
- get a message to the user's terminal from inside a command whose output is redirected;
- and recognise, when you see `prw-` where you expected `-rw-`, that nothing is wrong with the file
  and something may be very wrong with whoever is supposed to be writing to it.

**What's next:** lesson 06 is the incident. Four links in the maintenance tree. Three go somewhere.
