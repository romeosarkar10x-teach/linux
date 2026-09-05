# 02/05 — Solutions (agent-eyes-only)

> **Student: do not open this file.** It contains the answers. The tutor agent may read it to know
> where it is steering, and must never quote it.

Inode numbers, dates and free-space figures vary. Sizes, counts and block figures below are exact for
a freshly seeded lab.

---

**1.** `tree bays` → `9 directories, 5 files`.

**2.** `stat manifest/notes.txt` → `Size: 23`, `regular file`, and an inode number (varies).

**3.** `file manifest/hullscan` → `ELF 64-bit LSB pie executable, x86-64 … stripped`. A compiled
program, despite having no extension.

**4.** `du -sh accounting` → `40M`.

**5.** `tree -a bays` → `10 directories, 7 files` (from `9, 5`). New: the directory
`bays/.calibration`, the file `bays/.calibration/offsets.txt` inside it, and the file
`bays/.treeignore-note`. One dot-directory brought a file in with it — which is why the file count
rose by two, not one.

**6.** `tree -d -L 2 bays`.

**7.** `tree -f bays`. Every line becomes a usable path, so the output can be fed to another command
or pasted into a `cd`; the default's drawing is only meaningful read top-to-bottom.

**8.** `tree -p` over the lab (not just `bays` — nothing in `bays` was chmodded).
`stamps/chmodded.txt` shows `[-rw-r-----]` against its siblings' `[-rw-r--r--]`. It was set by this
lesson's own setup script, to give exercise 10 a file whose ctime could not match its mtime.

**9.**

| File | atime (`Access`) | mtime (`Modify`) | ctime (`Change`) |
|---|---|---|---|
| `read-me.txt` | 2187-06-20 | 2187-06-01 | today |
| `written.txt` | 2187-06-02 | 2187-06-14 | today |
| `chmodded.txt` | 2187-06-07 | 2187-06-07 | today |

Oldest mtime: `read-me.txt` (2187-06-01). Most recent atime: **also `read-me.txt`** (2187-06-20).
The same file holds both, which is the point — a file can be the least recently written and the most
recently read at once. The mirror image is `written.txt`: newest mtime, oldest atime. A file's contents were written once, long ago, and read
much later; nothing about reading a file changes when it was written.

**10.** `touch` set atime and mtime to arbitrary values in 2187. It cannot set ctime, because
changing the inode *is* what ctime records — so all three read today. Trust **ctime** as evidence:
mtime is attacker-controlled, ctime is not (short of raw device access or clock manipulation). This
is the reasoning Chapter 15 needs.

**11.** `ls -l stamps` (mtime) → `written.txt` newest. `ls -lu stamps` (atime) → `read-me.txt`
newest. `ls -lc stamps` (ctime) → all three today, effectively tied. Three different orderings from
one directory.

**12.** `stat -c '%n %s %a' manifest/*` — e.g. `manifest/notes.txt 23 644`, `manifest/check.sh 33
755`. `%A` instead of `%a` gives `-rw-r--r--`; the exercise asked for octal.

**13.** `stat` reports `readme.txt` as `regular file`, size 26936 (it is a copy of `/bin/true`),
and `notes.txt` as `regular file`, size 23. Identical type. `file` reports the first as an ELF
executable and the second as ASCII text.

The filesystem knows **nothing** about the difference: an inode stores size, owner, mode, timestamps,
link count and block pointers, and no content-type field. That is the right design — it means the
filesystem never has to be updated when a new file format is invented, and never has to be wrong
about one. Type is a question for whoever opens the file.

**14.** `file manifest/*`:
- `telemetry.txt` → `gzip compressed data, from Unix, original size modulo 2^32 26`
- `readme.txt` → an ELF executable (a copy of `/bin/true`)

Both are named `.txt` and neither is text.

**15.** `file manifest/dangling.link` →
`broken symbolic link to ../accounting/.staging/dump-2187-06-12.bin`.
`file -L manifest/dangling.link` →
``manifest/dangling.link: cannot open `manifest/dangling.link' (No such file or directory)``

Without `-L`, `file` describes the link itself — reading a symlink always succeeds, because the link
is a real object holding a string. With `-L` it is asked to open what the string names, and that does
not exist, so the open fails. Same file, two questions, and only one of them can fail.

**16.** `manifest/empty.log` is the empty one. The file that reports `empty` and is not:
`file /proc/cpuinfo` → `empty`, yet it produces 672 lines when read. `file` starts by asking for the
size, and procfs has no recorded size — last lesson's surprise, met again in a new tool.

**17.** `ls -a accounting` reveals `.staging`. `ls` was hiding it; `du` was never told to skip
anything. `du` is not overcounting — `ls` was under-reporting, and it did so because it was asked to.
Reconciling listing: `ls -la accounting` or `tree -a accounting`.

**18.** `accounting/.staging/dump.bin`, 41926656 bytes (40M).

**19.** `du -h -d 1 .`:

```
40M     ./accounting
16K     ./stamps
8.0K    ./ledger
64K     ./bays
84K     ./manifest
41M     .
```

`accounting` is essentially all of it. `ledger` is the interesting one for containing 50 MB of file
and costing 8 K — which is exercise 20.

**20.** `ls -l ledger/reserved.img` → 52428800. `du -h ledger/reserved.img` → `0`.
`stat` shows both fields on one line: `Size: 52428800  Blocks: 0`. The file is 50 MB long and
occupies no blocks — it is sparse. Reads of it return zeros the filesystem generates rather than
stores.

**21.** Prediction required in writing first.
```
$ du -h ledger/reserved.img                    0
$ du -h --apparent-size ledger/reserved.img    50M
$ du -sh ledger                                8.0K
$ du -sh --apparent-size ledger                51M
$ wc -c < ledger/reserved.img                  52428800
```
Default `du` answers "how much storage would I get back by deleting this". `--apparent-size` answers
"how many bytes would I read out of this". They agree for ordinary files, which is why most people
never learn there are two questions.

For "will this fit on a USB stick?" the honest answer is **apparent size**: `cp` to most filesystems
writes the zeros out for real, and 50 MB arrives. Only a copy that explicitly preserves sparseness
keeps the file at 0 blocks. A student who says "allocated blocks, because that is what it uses" has
the wrong answer for a defensible reason — mark it wrong and use the probe question.

**22.** Prediction required in writing first. `du -h manifest/notes.txt` → `4.0K`, for a 23-byte
file. `check.sh` (33 bytes) and `strain.csv` (34 bytes) also report `4.0K`; `empty.log` reports `0`,
because a zero-byte file needs no data block at all — only an inode.

The common number is 4.0K, which is this filesystem's block size (`stat` calls it `IO Block: 4096`).
A million 23-byte files would consume about 4 GB of blocks to hold 23 MB of data, plus a million
inodes. This is why archive formats and databases exist.

**23.** Default `tree bays/deck-3`: prints `loop -> ../..` and stops there.
`tree -l bays/deck-3`: follows it, walks back up into the whole lab, and where the loop would repeat
prints:

```
└── loop -> ../..  [recursive, not followed]
```

A tool without that check would descend forever, or until it hit the kernel's symlink-resolution
limit or ran out of memory building the path.

**24.**
```
$ df -T /labs
/dev/nvme2n1p2 ext4 375356492 253565212 102650928  72% /labs
$ df -T /
overlay overlay 375356492 ... /
```
`/labs` is `ext4` on a real block device; `/` is the container's `overlay` filesystem. The lab files
are on `/labs`, which is a Docker volume with a life of its own — `docker rm` of the container
destroys the overlay and leaves the volume, so lab work survives. Anything written outside `/labs`
does not. (Both report the same 358G because the volume's backing store is the same disk.)

**25.** `df -i /labs` → `Inodes 23912448  IUsed 2409266  IFree 21503182  IUse% 11%`. It explains a
filesystem that reports gigabytes free but refuses to create a file: inodes are allocated when the
filesystem is made, and a workload of millions of tiny files exhausts them long before the blocks
run out. Plain `df` would make that failure look impossible.

**26.** `stat manifest/subsystem` → `directory`, `Links: 2`. The two are: the name `subsystem` in
`manifest`, and the entry `.` inside `subsystem` itself. Every subdirectory added inside it would add
one more, via that child's `..`. This is why an empty directory has 2 links and a directory with
three subdirectories has 5.

**27.** `tree -ah --du .` (hidden entries included, no depth limit):
`accounting` → `40M`; `ledger` → `50M`.

The `ledger` figure contradicts exercise 20's `du -sh ledger` of `8.0K`. `tree --du` sums the
**apparent sizes** it already collected for the display; `du` reports allocated blocks. Same disagreement
as exercise 21, arriving from a tool that never told you which of the two it was doing — which is the
real lesson of this Dig.

**28.** `stat -f /labs`:
```
  File: "/labs"
    ID: e0e63c9ef09de231 Namelen: 255     Type: ext2/ext3
Block size: 4096       Fundamental block size: 4096
```
Block size 4096, type `ext2/ext3` — while `df -T` said `ext4`.

`df` reads the mount table (`/proc/mounts`), where the kernel records the driver that actually mounted
the filesystem: `ext4`. `stat -f` reports the filesystem's magic number, and ext2, ext3 and ext4 share
one magic number (`0xEF53`), so it can only name the family. **Trust `df -T`.** Check with
`grep /labs /proc/mounts` — last lesson's file, answering this lesson's question.

**29.** `du -csh accounting ledger manifest` → per-argument lines plus `41M total`.

**30.** `file -i` (or `--mime`):
```
manifest/telemetry.txt: application/gzip; charset=binary
manifest/drift.txt:     text/plain; charset=utf-8
manifest/hullscan:      application/x-pie-executable; charset=binary
```
A program prefers this because it is a fixed, comparable vocabulary — `application/gzip` is a token
you can test for equality. The default output is an English sentence whose wording changes between
`file` versions and cannot be safely matched against.

---

## Added exercises 31–52

**31.** `tree -P 'survey.txt' bays`:
```
bays
├── deck-3
│   ├── bay-1
│   │   ├── panels
│   │   └── survey.txt
│   └── bay-2
│       ├── panels
│       └── survey.txt
└── deck-4
    └── bay-1
        └── survey.txt

8 directories, 3 files
```
`-P` filters **files**, not directories. `tree` still has to walk every directory to find out whether
anything inside matches, and by default it prints the ones it walked — including `panels`, which
contains no match at all.

**32.** `tree -P 'survey.txt' --prune bays` → `6 directories, 3 files`; the two `panels` directories
are gone. They are separate options because pruning is a second pass over the result: `-P` decides
which files to show, `--prune` decides whether a directory that ended up empty is worth printing. You
can want an unpruned filtered tree (to see the shape you searched) or a pruned unfiltered one (to
drop genuinely empty directories).

**33.** `tree -I 'panels' bays` → `7 directories, 3 files`, and it shows `loop -> ../..`, which
exercise 31's output did not: `-P` filters files and a symlink counts as a file, so `loop` failed the
`survey.txt` pattern. `-I` excludes by name and `loop` is not named `panels`.

**34.**
```
$ tree --noreport -L 1 bays
bays
├── deck-3
└── deck-4

$ tree --dirsfirst -a -L 2 bays
bays
├── .calibration
│   └── offsets.txt
├── deck-3
│   ├── bay-1
│   ├── bay-2
│   └── loop -> ../..
├── deck-4
│   └── bay-1
└── .treeignore-note

8 directories, 2 files
```
(`--dirsfirst` sorts within each level; `.treeignore-note` is a file and lands last, after the
directories, despite the dot.)

**35.** `tree -J ledger`:
```
[
    {"type":"directory","name":"ledger","contents":[
        {"type":"file","name":"README"},
        {"type":"file","name":"reserved.img"}
    ]}
,    {"type":"report","directories":1,"files":2}
]
```
The last element is not part of the tree at all — it is the count line, as an object with
`"type":"report"`. A consumer walks the array and skips or splits off that entry rather than trying
to treat it as a filesystem node; it is the JSON equivalent of the human "1 directory, 2 files".

**36.** `tree --inodes --device -L 1 ledger`:
```
[ 300179 66309]  ledger
├── [ 300181 66309]  README
└── [ 300180 66309]  reserved.img
```
`reserved.img` is inode 300180 on device 66309. **The pair is the identity.** Inode numbers are only
unique within one filesystem, so two names are the same file exactly when device *and* inode match;
identical contents on two different inodes are two files that happen to agree today.

**37.** `stat -c '%n %A %a %U:%G %F' manifest/*`:
```
manifest/check.sh       -rwxr-xr-x 755 root:root regular file
manifest/dangling.link  lrwxrwxrwx 777 root:root symbolic link
manifest/drift.txt      -rw-r--r-- 644 root:root regular file
manifest/empty.log      -rw-r--r-- 644 root:root regular empty file
manifest/hullscan       -rwxr-xr-x 755 root:root regular file
manifest/notes.txt      -rw-r--r-- 644 root:root regular file
manifest/readme.txt     -rw-r--r-- 644 root:root regular file
manifest/strain.csv     -rw-r--r-- 644 root:root regular file
manifest/subsystem      drwxr-xr-x 755 root:root directory
manifest/telemetry.txt  -rw-r--r-- 644 root:root regular file
```
Not regular files: `dangling.link` (symbolic link) and `subsystem` (directory). `empty.log` is a
`regular empty file` — `stat` folds "size is zero" into the type word; `ls` can only show you a `0`
in the size column and leave you to notice it.

**38.**
```
$ stat -c '%N' manifest/dangling.link manifest/hullscan
'manifest/dangling.link' -> '../accounting/.staging/dump-2187-06-12.bin'
'manifest/hullscan'
```
`%N` quotes the name and appends the target only when there is one. `ls -l` gives you the arrow only
inside a fixed nine-column line you would have to cut apart, and it quotes nothing, so a name with a
space in it is ambiguous. `%N` is safe to hand to another program.

**39.** `stat -c '%w' manifest/notes.txt` (or `%W` for the epoch form) → a birth time of *today* —
the moment `setup.sh` ran. `stamps/read-me.txt` has an mtime of `2187-06-01`. There is no
contradiction and no lie: `touch -m -d` writes any value it is told into the mtime field, while birth
time is stamped by the kernel at creation and `touch` cannot reach it. A file can therefore claim to
have been modified 160 years before it existed.

**40.**
```
$ stat -L manifest/dangling.link
stat: cannot statx 'manifest/dangling.link': No such file or directory
```
Same cause as exercise 15: `-L` means "report on the target", the target does not exist, so there is
nothing to report on and the call fails. Without `-L` both tools describe the link itself, which
exists and is perfectly readable. The wording differs only because each tool names the syscall it
tried (`statx` here, `open` in `file`'s message).

**41.**
```
$ stat -c '%n %s' stamps/*
stamps/chmodded.txt 29
stamps/read-me.txt 30
stamps/written.txt 31

$ stat --printf '%n %s|' stamps/*
stamps/chmodded.txt 29|stamps/read-me.txt 30|stamps/written.txt 31|
```
`-c` appends a newline to every record; `--printf` emits exactly the format you wrote and also
interprets escapes like `\t` and `\n`. Inside a loop that is assembling one line, use `--printf` —
with `-c` you would have to strip the newlines back out afterwards.

**42.** Prediction to write down first; then:
```
$ cp ledger/reserved.img ~/a.img
$ ls -l ~/a.img   → 52428800
$ du -h  ~/a.img  → 0
```
The size is preserved and the disk cost is not. Modern `cp` defaults to `--sparse=auto`: it reads the
source, notices long runs of zeros, and instead of writing them it seeks past them, leaving the copy
holed too. It reproduced the file's *contents*, which include no data at all.

**43.**
```
$ cat ledger/reserved.img > ~/c.img ; du -h ~/c.img          → 50M
$ cp --sparse=never ledger/reserved.img ~/b.img ; du -h ~/b.img → 50M
```
All three copies are 52428800 bytes by `ls -l`. Only `cp`'s default preserves the hole. The rule:
**a hole survives only when the copying tool goes looking for it.** `cat` is a byte pump — it reads
zeros and writes zeros, and the filesystem dutifully allocates 50 MB of blocks to hold them.
`--sparse=never` asks `cp` to behave like `cat` on purpose.

**44.**
```
$ touch -r stamps/read-me.txt ~/r.txt
$ stat -c '%y %x' ~/r.txt
2187-06-01 08:00:00.000000000 +0000   2187-06-20 08:00:00.000000000 +0000
```
Both mtime and atime are copied. **ctime is not**, and cannot be: ctime records when the inode last
changed, and `touch -r` just changed the inode, so ctime is now. No interface exists to set it —
which is exactly why it is the field worth trusting.

**45.** `du -sh --exclude='*.bin' .` → `188K`, against `41M` for the whole lab. One file,
`accounting/.staging/dump.bin`, is 99.6% of the lab. (`ledger/reserved.img` is not in the excluded
set and still contributes nothing, because it is sparse.)

**46.** `du -sh --inodes .` → `40`. It counts inodes, not bytes. That number diagnoses two failures
`du -sh` cannot see: a filesystem that reports "No space left on device" while `df -h` shows free
space (the inode table is full), and a directory that is slow to list not because it is large but
because it holds a hundred thousand tiny entries.

**47.**
```
$ du -h --max-depth=1 .
40M  ./accounting
16K  ./stamps
8.0K ./ledger
64K  ./bays
84K  ./manifest
41M  .
```
Same five figures as exercise 19, plus the total, in one walk of the tree instead of five. (`-s` is
just `--max-depth=0`.)

**48.** `du --time -h manifest`:
```
84K   2026-09-05 15:55   manifest
```
That column is the newest mtime found anywhere in the subtree. So it tells you when something under
`manifest` last changed, and nothing about **which** thing: the 26K `hullscan` and the 23-byte
`notes.txt` were written seconds apart by the same script, and this column cannot separate them. A
directory that shows a recent time may have had one trivial file touched.

**49.** `du -sh accounting` → `40M`; `du -s --si accounting` → `42M`. `-h` divides by 1024
(mebibytes); `--si` divides by 1000 (megabytes). **The disk vendor prints the `--si` number** — which
is why a "50 GB" disk mounts with less than 47 of what your file manager calls GB.

**50.**
```
$ tree -h --du -a manifest  → 61K used in 2 directories, 9 files
$ du -sh manifest           → 84K
```
They are measuring different quantities. `tree --du` sums **apparent sizes**: 54080 bytes of file
content plus 4096 for `manifest` and 4096 for `subsystem` = 62272 ≈ 61K. `du` sums **allocated
blocks**: `hullscan` and `readme.txt` are 26936 bytes each but occupy 56 512-byte blocks = 28672
each; the five small text files occupy a full 4096 each despite holding 23–46 bytes; plus 4096 per
directory. 57344 + 20480 + 8192 = 86016 = 84K exactly. The 23K gap is rounding *up to block
boundaries*, seven times over.

**51.**
```
$ stat -c '%s %b %B' ledger/reserved.img   → 52428800 0 512
$ stat -c '%s %b %B' manifest/notes.txt    → 23 8 512
```
`%s` is the apparent size; `%b × %B` is what is actually allocated. For `reserved.img`:
0 × 512 = 0 bytes on disk against 52428800 claimed — `du -h` says 0, `du -h --apparent-size` says
50M. For `notes.txt`: 8 × 512 = 4096 bytes on disk against 23 claimed — `du -h` says 4.0K,
`du -h --apparent-size` says 23. The two questions are "how much room does this take" (`%b × %B`) and
"how many bytes would I have to transmit" (`%s`), and the answer can be larger *or* smaller.

**52.** `du -ah manifest`:
```
4.0K  manifest/check.sh        (33 bytes by ls -l)
0     manifest/dangling.link   (42 bytes by ls -l)
28K   manifest/hullscan        (26936 bytes by ls -l)
0     manifest/empty.log       (0 bytes by ls -l)
```
The two extremes are `check.sh` — `du` says 4.0K, `ls` says 33 — and `dangling.link`, where `du` says
0 and `ls` says 42. `du` is right about **disk consumed**: the 33-byte script still occupies a whole
block, and the symlink's 42-byte target string is stored inside the inode itself (a "fast symlink")
and costs no data block at all. `ls` is right about **how many bytes the file contains**. Neither is
a size in the sense the other means.

---

## Tutor notes

- Exercises 20–22 and 27 are one idea approached four times. If a student groups them together
  unprompted, that is the strongest signal the lesson worked.
- Exercise 9's table is deliberately awkward: `read-me.txt` holds both the oldest mtime and the newest
  atime. Students often assume the answer must be two different files. Accept any answer that reports
  the timestamps correctly and notices the orders differ.
- Exercise 10 is the arc-relevant one. It is the tooling behind Chapter 15's argument about what a
  backdated file does and does not prove. Do not connect it to the sabotage arc out loud.
- The `ext2/ext3` vs `ext4` disagreement in 28 unsettles students. It is not a bug in either tool and
  neither is lying; they are reading different sources.

## Flags

None. Chapter 2's flag is in `07-incident-02`.
