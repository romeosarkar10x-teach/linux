# 03/04 — Timestamps

> Every file on this station remembers three different times, none of which is "when it was
> created", and the difference between them is about to become your job.

Chapter 3 has been about the difference between a name, an inode, and the bytes. Timestamps live in
the inode. That one fact explains almost everything odd in this lesson.

---

## Three times, and what each one actually means

Run `stat` on a file and the bottom of the output is four lines:

```
$ stat logs/strain-2187-05-22.csv
  File: logs/strain-2187-05-22.csv
  Size: 39        	Blocks: 8          IO Block: 4096   regular file
Device: 259,5	Inode: 44861       Links: 1
Access: (0644/-rw-r--r--)  Uid: ( 1005/   cadet)   Gid: ( 1001/    crew)
Access: 2187-05-22 03:14:00.000000000 +0000
Modify: 2187-05-22 03:14:00.000000000 +0000
Change: 2026-08-23 08:42:56.883635794 +0000
 Birth: 2026-08-23 08:42:56.814667519 +0000
```

Careful with the word **Access** — it appears twice and means two different things. The one in
brackets is the permission bits. The one on its own line is a time.

| line | short name | moves when | does *not* move when |
|---|---|---|---|
| Access | **atime** | the file's contents are read | you look at its name or its metadata |
| Modify | **mtime** | the file's contents are written | permissions, owner or name change |
| Change | **ctime** | anything in the **inode** changes — contents, mode, owner, link count, name | nothing you can control |
| Birth | btime | never; it is set once at creation | — |

`mtime` is "when the contents last changed". `ctime` is "when the **inode** last changed", and
because writing contents also updates the inode's size and mtime, every content change moves ctime
too. The reverse is not true: `chmod` moves ctime and leaves mtime alone.

There is no "creation time" in the classic Unix inode. Birth time was added much later, and it is
the odd one out: this lab volume is ext4 and reports it, plenty of real filesystems do not, and
`stat` prints `-` when it is missing. Nothing in this course depends on it.

## The one that cannot be faked

`touch` can set mtime and atime to anything you like — the past, the future, another file's value.
It cannot set ctime. There is no system call that sets ctime; the kernel stamps it with the current
time on every inode change, including the change `touch` just made.

```
$ touch -d '2187-05-24 04:12' meta/moved.txt
$ stat -c 'm=%y c=%z' meta/moved.txt
m=2187-05-24 04:12:00.000000000 +0000 c=2026-08-23 08:43:23.669636011 +0000
```

An mtime in the far past next to a ctime from this morning means: *someone set that mtime this
morning*. It could be `touch`. It could be a restore from backup, or an unpacked archive, or a
`chmod`. The pairing is evidence that something happened, not evidence of what. This is the single
most useful reading skill in the lesson, and you will use it again in the incident.

## Reading times without `stat`

`ls -l` shows **mtime** and abbreviates it: a time of day for recent files, a year for old ones.

```
$ ls -l reads
-rw-r--r-- 1 cadet crew 31 Jan  1  2287 cold.txt
-rw-r--r-- 1 cadet crew 31 May 22  2187 warm.txt
```

Two switches change *which* time it shows, and both of them also change what `-t` sorts by:

- `ls -lu` — atime
- `ls -lc` — ctime
- `ls -l --time=atime` — the same thing, spelled out
- `ls --full-time` — the whole stamp, no abbreviating, no guessing

`-t` sorts newest first, `-tr` reverses it. `ls -lt` is how you find the most recently written file
in a directory without reading a single name. Names are frequently a lie about time; in `logs/` the
summary is dated in the middle of the files it summarises.

## Reads and `atime`

Reading a file updates its atime — in principle. In practice almost every Linux system mounts with
**`relatime`**, which updates atime only if the old atime is older than mtime or ctime, or is more
than a day stale. Writing the timestamp on every read is a write for every read, which is expensive
for something almost nobody reads.

```
$ grep /labs /proc/mounts
/dev/nvme2n1p2 /labs ext4 rw,relatime 0 0
```

So `atime` answers "has this been read since it was last written?" reliably, and "when was it last
read?" only loosely. Treat it as a hint, never as a fact.

## Setting times on purpose

```
touch f                      # both times to now; creates f if it does not exist
touch -c f                   # ... but do not create it
touch -m -d '2187-05-22 03:14' f   # mtime only
touch -a -d '2187-06-01 11:00' f   # atime only
touch -t 218705220314 f            # same idea, [[CC]YY]MMDDhhmm[.ss] format
touch -r anchor.txt f              # copy anchor.txt's times onto f, whatever they are
touch -h link                      # the symlink's own times, not its target's
```

`touch -r` is the one worth remembering. It transfers a timestamp you never have to read, type, or
get the format right for.

## Copying

`cp` writes a brand new file, so the copy's mtime is now. `cp -p` preserves mode, ownership and
timestamps; `cp -a` implies `-p` and recurses.

```
$ cp source.csv plain.csv ; cp -p source.csv kept.csv
$ stat -c '%n %y' plain.csv kept.csv
plain.csv 2026-08-23 08:43:37.607901408 +0000
kept.csv  2187-05-22 03:14:00.000000000 +0000
```

This is why a tree restored from a backup with plain `cp` looks like it was all written in one
second, and why every "sort by date" answer about it is worthless afterwards. Both copies get a
fresh ctime regardless: `-p` cannot preserve what cannot be set.

## Directories have times too, and they mean something narrower

A directory's contents are its **entry list** — the name-to-inode pairs. So its mtime moves when a
file is created, deleted or renamed inside it, and does **not** move when a file inside it is
edited.

```
$ printf x >> stamps/bay-2/torque.txt   # dir mtime unchanged
$ touch stamps/bay-2/new.txt            # dir mtime is now
```

"This directory was last modified in May" means nobody has added or removed anything since May. It
says nothing about the files.

---

## Gotchas

- **`ls -l` shows mtime, not creation time.** There is no creation-time column, and there never was.
- **`ls -lt` sorts by whichever time is being displayed.** `ls -ltu` sorts by atime. Mixing that up
  produces a confidently wrong answer.
- **Timestamps live in the inode, so hard links share them.** `touch` one name and the other name's
  times change too. There is only one set.
- **ctime is not creation time.** Change, not create. The name has been misleading people for
  fifty years.
- **A far-future mtime breaks relatime.** If mtime is ahead of atime, every read updates atime,
  because the relatime rule says so.
- **ext4 cannot store arbitrary dates.** Push a timestamp far enough out and it silently lands
  somewhere else. Timestamps are a fixed-width field, not a string.

---

## Before you move on

You should be able to say, without hedging:

- which of the three times a `chmod` moves, and which it leaves alone;
- what an old mtime beside a new ctime tells you, and what it does not;
- why `ls -l` on a restored backup is useless and `stat` on it is not;
- what a directory's mtime is actually measuring.

Next: `05-devices-fifos-sockets` — the files that are not storage at all.
