# tar — Validation Rubric

## Must be right

- `-f` takes the next word; `-czf` not `-cfz`, and the student can say *why*
  rather than reciting the order.
- Listing (`-t`) does not modify the archive, and the student can propose a way
  to demonstrate it.
- Compression flags are needed on create and optional on read, and a *wrong*
  read flag is worse than none.
- `-C` is where extraction lands, and it is the answer to the archive with no
  top-level directory.
- `Removing leading '/'` is a warning, exit status 0, and it is protection.

## Strong pass

- Checks `file` as well as `tar -tf` before extracting anything.
- Notices the extraction in exercise 14 overwrote silently and says so without
  being asked.
- Explains exercise 20 as a silent no-op, and connects "exit 0" to "did
  nothing" rather than to "worked".
- Explains the 20480 bytes with blocking, not by guessing.
- Refuses to conclude anything about compressors from three text files
  (exercise 31). Students who rank gzip/bzip2/xz from this data have answered
  a question the data cannot answer.

## Pass

Can list, extract into a scratch directory, create an archive with the flags in
the right order, and identify `spare-logs.tar.bz2` as gzip. May still be
guessing about blocking or about `-a`.

## Partial

Everything works but extraction is done in place, without `-C` and without
listing first. Push on that specifically — the habit is the lesson, not the
flags.

## Fail

- Extracted an archive outside `scratch/` and cannot say what it overwrote.
- Believes `-t` unpacks files.
- Thinks the `Removing leading '/'` warning means the archive is damaged.

## Common wrong answers

- **"`-z` is required to read a .tar.gz."** Not since tar 1.15. Have them run
  it.
- **"tar asks before overwriting."** It does not, ever. Exercise 14.
- **"The archive with no top directory is malicious."** It is careless, which is
  far more common. The defence is the same either way, which is the point.
- **"`--strip-components=6` failed."** It exited 0 and did nothing. Different
  thing, and the more dangerous one.
