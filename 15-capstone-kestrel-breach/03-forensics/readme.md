# Forensics — fourteen artefacts and two sets of hands

Lesson 02 told you who exists and what is running. This lesson is about
**when**, and it is the hardest thinking in the course.

There are fourteen files and one symlink under this lab. None of them is
labelled. None of them says who did anything. What you have is three trees —
`engineering/`, `station/`, `home/` — and the metadata the filesystem happened
to keep. By the end you should be able to put every artefact on one line of
time and say, with evidence, that the work in front of you was done by more
than one set of hands.

## Three timestamps, and the one you cannot have

`stat` gives you three:

```
$ stat engineering/audit/checksums-2186.txt
  Access: 2026-09-05 10:47:55.731648642 +0000
  Modify: 2187-05-15 23:05:00.000000000 +0000
  Change: 2026-09-05 10:47:47.716648390 +0000
   Birth: 2026-09-05 10:47:47.680648389 +0000
```

Look at that for a moment before reading on. The mtime is in 2187. Everything
else is today.

**Modify** (mtime) is when the file's *contents* last changed. This is the one
you build timelines from.

**Change** (ctime) is when the *inode* last changed — contents, but also
permissions, ownership, link count, or a rename. You cannot set ctime with a
command. `touch -d` rewrites mtime and atime and leaves ctime at now, which is
why a file whose mtime is far older than its ctime is worth a second look. It
is not proof of anything: copying a file with `cp -a` produces exactly the same
pattern, honestly.

**Access** (atime) is when it was last read. Treat it as noise. Most systems
mount with `relatime`, so atime only updates once a day or when it is already
older than mtime; your own `cat` may or may not have moved it.

**Birth** is the fourth, and it is the one people reach for. Modern `stat` on
ext4 and overlayfs will show it. Do not build on it: it is absent on many
filesystems (`Birth: -`), it is not exposed by `find -printf` or by `ls`, and
it records when *this inode* was created — so a copied file is born the moment
it was copied, and tells you nothing about the original. Here, every birth time
is the moment this lab was seeded onto your machine.

Format them yourself with `stat -c`:

```
%n  name        %s  size        %U  owning user
%y  mtime human %Y  mtime epoch %z  ctime human %Z  ctime epoch
```

Epoch seconds sort correctly with `sort -n`; human strings do not always.

**Do not use `ls -l` for timestamps.** It drops the time and prints only the
year for anything more than six months from now, and it prints mtime with no
label so nobody can tell from your notes which of the three you meant. `ls -l`
is for permissions and ownership. `stat` is for time.

## Finding by time

`find` selects on time directly, and this is the workhorse of the lesson:

```
find . -type f -newermt '2187-05-15'                  # modified after
find . -type f ! -newermt '2187-05-20'                # modified before
find . -type f -newermt '2187-05-15' ! -newermt '2187-05-20'
find . -type f -newer engineering/audit/README.txt    # newer than that file
```

`-newermt` takes a date string; `-newer` takes a reference file, which is often
easier and always less ambiguous. There is also `-newerct` for ctime. The
`-mtime N` form counts 24-hour blocks backwards from *now*, which in this lab
means a number in the tens of thousands — ignore it and use `-newermt`.

To sort a whole tree by time, print the epoch, sort, then throw it away:

```
find . -type f -printf '%T@\t%TY-%Tm-%Td %TH:%TM\t%u\t%p\n' | sort -n | cut -f2-
```

`bin/timeline` does exactly that. Read it before you use it — it is nine lines,
and one of them decides what silently does not appear in the output.

## Ownership is evidence

Every artefact here is owned by a real account, and the owner is a fact you can
cite. `find . -type f -printf '%u %p\n'` gets you all of them at once, and
`find . -user rhea` selects.

What ownership means is narrower than it feels. It says which uid the file was
last written by — or last chowned to. It does not say who was at a keyboard.
An account with a `nologin` shell can own a file that changed at 23:58, and
lesson 02 already showed you how that happens.

## Comparing files

```
diff a b            # line by line, exit 1 if they differ
diff -u a b         # unified, easier to paste into a report
cmp a b             # first differing byte, for binaries
sha256sum a b       # identical or not, one line each
```

Two files with the same name in different places, or a file next to something
ending `.orig`, is an invitation to diff them. Do it before you theorise about
either one.

## Two hands

The claim you are being asked to test is that the work in this lab was not done
by one person in one sitting. The evidence for that kind of claim is always the
same three things: **clustering** (edits that fall together in time), **owner**
(who the filesystem says wrote them), and **direction** (whether an artefact is
building something or checking something).

You will find both clusters. Write down what separates them before you write
down what you think either was doing — and remember rule 4 from lesson 01. A
cluster is a fact. A purpose is an inference, and it belongs on the `means`
line, marked as yours.

## Before you move on

- Every one of the fourteen files on one timeline, with mtime and owner.
- The two clusters identified by date range, with the accounts in each.
- The two checksum files diffed, and the difference stated exactly.
- The summariser and its `.orig` diffed.
- The symlink accounted for — including why it is missing from your timeline.
- At least five claim files, six fields each, no motive on any `says` line.
