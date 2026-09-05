# 03 — Where the space went

`df` and `du` answer two different questions, and the day you need them is the
day they disagree.

`df` asks the *filesystem* how much space it has handed out. `du` walks a
*directory tree* and adds up what it finds. When those two numbers don't
match, neither one is broken — you are asking about two different things, and
the gap between them is usually the interesting part.

## df: by filesystem

```
df -h /labs
```

`-h` for human sizes. Give `df` a path and it reports the filesystem that path
lives on, which is why `df -h .` is the useful form: it answers "the volume I
am standing on". With no argument it lists every mounted filesystem, including
several you did not know were there.

`df -i` reports **inodes** instead of bytes. A filesystem can be 4% full and
still refuse to create a file, because every file consumes one inode and the
inodes ran out. Four hundred one-line files cost four hundred inodes.

## du: by directory

```
du -sh bay
du -h --max-depth=1 bay | sort -h
```

`-s` summarises: one total, no per-file lines. `-h` again for human sizes.
`--max-depth=1` is the one you will actually use — it prints each immediate
child's total, so you can pipe it through `sort -h` and see which subdirectory
is eating the volume, then descend one level and repeat. That loop, three or
four times, finds almost anything.

`du -a` includes individual files. `du -x` refuses to cross into another
filesystem, which matters when a mount point sits inside the tree you are
measuring.

## du counts blocks, not bytes

A file's *apparent size* is the number in `ls -l`. Its *disk usage* is the
number of filesystem blocks it occupies, and blocks are 4 KB here. So:

- 400 files of 8 bytes each have an apparent size of about 3 KB and a disk
  usage of 1.6 MB. `du` reports the second. It is right.
- A **sparse** file — one with holes that were never written — has a large
  apparent size and almost no disk usage. `du --apparent-size` shows you the
  gap.
- **Hard links** are one set of bytes with several names. `du` counts an inode
  once, no matter how many names it walks past. `--count-links` turns that off
  and triple-counts, which is almost never what you want.

## ncdu

`ncdu` is `du` with a cursor: it scans once, then lets you walk the tree,
sorted by size, deleting as you go. It is not installed. Install it with what
you learned in chapter 13, use it, and remove it again.

## The gap

If `df` says a volume is full and `du` on that volume's root says it is not,
the space is being held by a file that has been **deleted while a process
still had it open**. Unlinking a file removes its name; the bytes are freed
when the last file descriptor closes. Until then `du` cannot find the file —
it has no name to walk to — and `df` still counts it, because the filesystem
still has it.

`lsof +L1` lists exactly those: open files with a link count below one. So does
`ls -l /proc/<pid>/fd/`, where the deleted target is marked `(deleted)`. The
fix is never `rm`; the file is already gone. You restart or signal the process
holding it.

You will build one of these yourself in `/dev/shm`, which is a 64 MB
filesystem you can genuinely fill without hurting anything.

Do not delete anything under `bay/`. Read only.
