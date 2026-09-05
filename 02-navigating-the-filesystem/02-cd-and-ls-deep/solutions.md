# 02/02 — Solutions

> **Agent eyes only.** Student: do not open this. `help.md` is the file you want.

`$LAB` = `/labs/02-navigating-the-filesystem/02-cd-and-ls-deep`

---

**1.**
```bash
ls logs        # 5
ls -A logs     # 7   (+ .keep, .rotated)
ls -a logs     # 9   (+ . and ..)
ls             # 7
ls -a          # 9
ls -A          # 7
```
The lab root has no dotfiles of its own, so `-a`'s only additions there are `.` and `..` — which
is exactly the two-entry difference the exercise asks about.

**2.** `-a` shows everything including `.` and `..`; `-A` shows everything except those two.

**3.** `ls -lh logs` — `hull-2187-06-10.log` reads `879K`, and the `total` line becomes `920K`.

**4.** `.rotated`. Told it is a directory by `ls -lA logs` (leading `d`) or `ls -FA logs` (trailing
`/`). It is invisible to plain `ls` because its name begins with `.` — nothing else.

**5.** `ls logs/.rotated` → `strain-2187-04.log.2`, `strain-2187-05.log.1`. No `-a` needed: the
files inside are not themselves dotfiles.

**6.**
```bash
ls -t logs     # strain-06-12, thermal-06-13, strain-06-13, strain-06-11, hull-06-10
ls -tr logs    # the reverse
```
Note the trap: the newest **mtime** is `strain-2187-06-12.log`, whose name carries the *second*
latest date. Seeded that way on purpose.

**7.** `ls -S logs` → hull (900000), strain-06-12 (24000), thermal-06-13 (6300), strain-06-13
(1400), strain-06-11 (180).

**8.** The three orders:

| Sort | Order |
|---|---|
| name | hull-06-10, strain-06-11, strain-06-12, strain-06-13, thermal-06-13 |
| time (`-t`) | strain-06-12, thermal-06-13, strain-06-13, strain-06-11, hull-06-10 |
| size (`-S`) | hull-06-10, strain-06-12, thermal-06-13, strain-06-13, strain-06-11 |

No two agree. Name and size share a first element and diverge immediately.

**9.**
```bash
ls current      # lists the five files
ls -l current   # lrwxrwxrwx 1 cadet crew 4 ... current -> logs
```
The rule: **`-l` does not follow a symlink given as an argument.** No `-d` is required. `ls` with
no `-l` descends into it; `-l` describes the entry. (`-L` forces dereferencing even with `-l`.)

This is the misconception the lesson is built to kill: students assume `-d` is what stops the
descent. `-d` stops it for directories; for a symlink argument, `-l` already did.

**10.** `ls -ld logs` → one line, type `d`. `-d` means "do not descend into directory arguments;
list them as entries".

**11.** `Archive` before `archive`, because in this locale the comparison is by byte value and
`A` (0x41) < `a` (0x61). The responsible setting is `LC_COLLATE` (set here via `LANG=C.UTF-8`).

`locale -a` on this image prints only:
```
C
C.utf8
POSIX
```
So the contrast **cannot be demonstrated here** — `LC_ALL=en_US.UTF-8 ls` silently falls back and
the order does not change. "I could not demonstrate it and here is why" is the correct answer.

**12.**
```bash
ls -1 logs
ls logs | cat
```
`ls` produces columns only when its standard output is a terminal. Redirecting or piping makes it
one-per-line without any flag. Same mechanism as `01/01`.

**13.**
```bash
ls runs      # run-1, run-10, run-11, run-2, run-20, run-3, run-9
ls -v runs   # run-1, run-2, run-3, run-9, run-10, run-11, run-20
```
Default compares character by character, so `1` beats `9` at the second character. `-v` compares
runs of digits as numbers.

**14.** `ls -R deep`. Two directories at any depth: `deck-3` and `deck-3/bay-2`. `empty-bay` is
covered only if they also ran `ls -R empty-bay` or `ls -R *`; it appears as a label with nothing
beneath it, which is how "visited and empty" is distinguished from "not visited".

**15.** `ls Archive logs` prints a `Archive:` label, its entries, a blank line, a `logs:` label, its
entries. A script doing `for f in $(ls Archive logs)` would treat `Archive:` as a filename.

**16.** *Experiment.* Observed:

```
ls current        -> the five log files
ls -l current     -> lrwxrwxrwx ... current -> logs
ls -ld current    -> lrwxrwxrwx ... current -> logs
ls current/       -> the five log files
ls -ld current/   -> drwxr-xr-x ... current/
```

Three mechanisms, deliberately overlapping:

1. **`-l` does not dereference a symlink argument.** That alone explains lines 2 and 3.
2. **`-d` does not descend into directory arguments.** Here it changes nothing for lines 2/3,
   because `-l` had already stopped the descent — which is the trap.
3. **A trailing slash is a path-level assertion** that the path names a directory, so the kernel
   resolves the symlink *before* `ls` ever gets to choose. That is why line 5 reports a directory
   with mode `drwxr-xr-x` under the name `current/`.

A student who says "`-d` and `/` do the same thing" is refuted by line 5 alone.

**17.** *Experiment.*
```
cd logs   -> $LAB/logs
cd ../deep -> $LAB/deep
cd -      -> $LAB/logs     (and cd - prints the destination)
cd -      -> $LAB/deep
```
`cd -` swaps `PWD` and `OLDPWD`. One stored value, so two invocations are the identity and there is
no way back to a third directory. `pushd`/`popd` maintain an actual stack; not required here.

**18.** *Experiment.* All five files show `2187` rather than a clock time, because every one of them
is roughly 161 years away from the container's clock. The rule: `ls -l` prints the year instead of
the time whenever the timestamp is more than about six months from now, **in either direction**.
Students who predicted "some will show times" are wrong but pass, provided the explanation
addresses it. Verify with `touch -d now /tmp/x && ls -l /tmp/x`.

**19.**
```bash
type ls          # ls is aliased to `ls --color=auto'
\ls logs
command ls logs
/opt/kestrel/bin/ls logs
```
Any two of the last three. `01/03` established `type` over `which` for exactly this.

**20.** `ls -lhrtA logs` — long, human sizes, reversed, time-sorted, almost-all. Letters may be in
any order. Expanded: `-l -h -r -t -A`.

**21.** From `$LAB/deep/deck-3/bay-2`, having previously been somewhere else: `ls ~-`. Equivalent
but less idiomatic: `ls "$OLDPWD"`.

**22.**
```bash
ls -ld logs current
# drwxr-xr-x 3 cadet crew 4096 ... logs
# lrwxrwxrwx 1 cadet crew    4 ... current -> logs
```
Different type character, different link count, different size, and one has an arrow. `stat`,
`file` and `readlink current` all work too.

Watch for `ls -i logs current`: that lists the *contents* of both and the inode numbers are
identical, which is true but answers a different question — the entries in the parent are what
differ.

**23.** *Dig.*
```bash
echo "[$LS_COLORS]"          # []
man ls                       # the --color entry names LS_COLORS
apropos color                # dircolors(1) -- color setup for ls
dircolors -b                 # prints an assignment
eval "$(dircolors -b)"
ls --color=always -d logs current | cat -v   # now shows ESC[ sequences
```
Two gotchas worth noting for the tutor:

- With `TERM` unset or `dumb`, `dircolors -b` emits `LS_COLORS='';` — an empty assignment. A
  student in a non-interactive `docker exec` will hit this; inside `kestrel enter` they will not.
- Ubuntu's stock `~/.bashrc` guards its `dircolors` call with `[ -x /usr/bin/dircolors ]`. On this
  image `dircolors` lives in the Nix closure at `/opt/kestrel/bin`, so the guard fails and the
  variable is never populated. That is the whole reason colour is off here, and a student who
  works that out has done something genuinely good — but it is not required.

Permanence would mean adding the `eval` line to a shell startup file. Chapter 11 owns that; do not
let them edit `~/.bashrc` yet.

**24.** *Dig.*
```bash
ls -ls logs
# 880 ... 900000 hull-2187-06-10.log
#   4 ...    180 strain-2187-06-11.log
#  24 ...  24000 strain-2187-06-12.log
#   4 ...   1400 strain-2187-06-13.log
#   8 ...   6300 thermal-2187-06-13.log
```
The pair is `strain-2187-06-11.log` (180 bytes) and `strain-2187-06-13.log` (1400 bytes): a
7.8× difference in bytes, identical 4-block allocation. Blocks here are 1 KiB units in `ls`'s
reporting and the filesystem allocates in 4 KiB chunks, so anything from 1 byte to 4096 bytes
costs the same. Chapter 3 revisits this with `stat` and `du`.

**25.** *Dig.* `ls -U logs` → thermal-06-13, strain-06-13, strain-06-12, hull-06-10, strain-06-11.

That is the order the directory itself stores the entries, which is a function of the order they
were created and which slots freed-up entries reused. Useless for humans; occasionally the only
surviving evidence of the sequence in which a directory was built. Do not oversell this — on many
modern filesystems the order is a hash and encodes nothing.


---

## Added exercises 26–52

All output below was taken from the running container. `$LAB` is
`/labs/02-navigating-the-filesystem/02-cd-and-ls-deep`.

**26.** Left to right: mode, link count, owner, group, size, modification time, name. The **name** is
the one not stored in the inode — it lives in the directory entry that points at the inode, which is
exactly why one inode can have several names.

**27.**
```
$ ls -l logs | head -1
total 920
```
It counts the disk blocks allocated to the listed files, not their byte sizes and not the number of
files. The unit is 1K blocks here — evidence: `ls -s logs` reports 880 for the 900000-byte file, and
900000/1024 rounds to 880. `ls -sk` gives the same numbers, confirming K.

**28.**
```
$ ls -ln logs | head -2
total 920
-rw-r--r-- 1 0 0 900000 Jun 10  2187 hull-2187-06-10.log
```
`-n`. Both numbers are `0` — root. Without `-n`, `ls` looks the numbers up in `/etc/passwd` and
`/etc/group` to print names; the numbers are what the inode actually holds.

**29.**
```
$ ls -ld logs
drwxr-xr-x 3 root root 4096 ... logs
```
Three: `logs/.` (the entry inside itself), the `logs` entry in the lab root, and `logs/.rotated/..`.
Every subdirectory adds one, so a directory's link count is 2 plus the number of subdirectories.

**30.**
```
$ ls -i logs
300112 hull-2187-06-10.log   300108 strain-2187-06-11.log   ...
```
An inode number identifies a file *within one filesystem*. Two files in different directories can
absolutely share one — that is a hard link. Two files on different filesystems can share a number
while being unrelated, which is why the number alone is not an identity.

**31.** They run 300108–300112. The seed script created the five files in one loop, and the
filesystem handed out consecutive inodes, so the order 300108…300112 matches
`strain-06-11, strain-06-12, strain-06-13, thermal-06-13, hull-06-10` — the order in the script, not
the alphabetical order and not the mtime order. Hedge: consecutive allocation is a common
implementation choice, not a guarantee, and a filesystem that reuses freed inodes will scramble it.
It is a hint, not evidence.

**32.**
| time | flag | name |
| modification | `ls -l` (default) | mtime — when the contents last changed |
| access | `ls -lu` | atime — when the contents were last read |
| status change | `ls -lc` | ctime — when the inode last changed |

**33.** mtime and atime show 2187; ctime shows the day the lab was seeded. `touch -d` sets mtime and
atime to whatever you ask, but it cannot backdate ctime — changing the inode *is* a status change,
so the kernel stamps it with the real clock. This is the single most useful fact about ctime.

**34.**
```
$ ls -t logs    # strain-06-12, thermal-06-13, strain-06-13, strain-06-11, hull-06-10
$ ls -tu logs   # identical order
$ ls -tc logs   # hull-06-10, thermal-06-13, strain-06-13, strain-06-12, strain-06-11
```
mtime and atime agree exactly, because `touch -d` set both together. The ctime order is different
from both and is not random: it is the reverse of the order the seed script touched the files in, so
ctime is recording the seeding, not the station's history.

**35.**
```
$ ls -l --time-style=full-iso logs | head -2
total 920
-rw-r--r-- 1 root root 900000 2187-06-10 01:20:00.000000000 +0000 hull-2187-06-10.log
```

**36.** atime is the one that answers it, and the reason to distrust it is that reading is not the
only thing that sets it and mounting is not the only thing that stops it: filesystems are commonly
mounted `relatime` or `noatime` for performance, in which case atime is stale or frozen by design.
Here it is worse than stale — `touch` wrote it, so it records a lie about a read that never happened.

**37.** `ls logs` prints five names in columns; `ls logs | cat` prints one per line. `ls` calls
`isatty` on its own standard output and only formats columns when the answer is yes. Same reason
`--color=auto` produces nothing through a pipe.

**38.**
```
$ ls -w 40 logs
hull-2187-06-10.log
strain-2187-06-11.log
...
```
The names are 19–21 characters, so at 40 columns two would need 42; one per line is all that fits.
With no `-w` and no terminal, `ls` uses `$COLUMNS` if set, and otherwise the one-per-line form, since
there is no width to fit anything to.

**39.**
```
$ ls -p          # Archive/  archive/  current  deep/  empty-bay/  logs/  runs/
$ ls -F          # Archive/  archive/  current@ deep/  empty-bay/  logs/  runs/
```
`-p` marks directories only. `-F` marks more kinds, and gives `current` an `@` for symlink. `-F`
would also add `*` for executables and `|` for FIFOs; there are none here.

**40.**
```
$ ls -m logs
hull-2187-06-10.log, strain-2187-06-11.log, strain-2187-06-12.log,
strain-2187-06-13.log, thermal-2187-06-13.log
```
Comma-separated. `m` for "comma" is not a fair hint from the letter alone; the honest answer to the
prediction is a guess, and `man ls` is faster than guessing.

**41.** It prints nothing. `--hide` excludes the five `.log` files, and the two remaining entries —
`.keep` and `.rotated` — are dotfiles, which are already excluded because `--hide` does not imply
`-a`. Everything is filtered by one rule or the other. (`--hide` is also ignored entirely when `-a`
or `-A` is given, which is worth noticing.)

**42.**
```bash
ls -lhAt logs
```
- `-l` long format
- `-h` sizes as `879K` rather than `900000`
- `-A` dotfiles, but not `.` and `..`
- `-t` newest first

The "newest first" here is `-t`; a student who read "newest first" as needing `-r` has inverted it.
There is no `.log` filter — `ls` cannot do that, and every non-dot entry in `logs` happens to be one.

**43.**
```
$ bash -ic 'type ls'
ls is aliased to `ls --color=auto'
$ bash -lc 'type ls'
ls is /opt/kestrel/bin/ls
```
Aliases are an interactive convenience and are not expanded in non-interactive shells; that is
deliberate, because a script's behaviour must not depend on the operator's personal shortcuts.

**44.** Column layout (exercise 37) and `--color=auto` both branch on `isatty`. So does the choice
of `-1` as the fallback format. A script must not rely on any of them, because the script's output
is usually a pipe or a file and the formatting silently changes under it — parse `-1` output or, in
Chapter 7's terms, do not parse `ls` at all.

**45.**
```
$ ls -l current
lrwxrwxrwx 1 root root 4 ... current -> logs
$ ls -lL current
total 920
-rw-r--r-- 1 root root 900000 Jun 10  2187 hull-2187-06-10.log
... (five files)
```
`-L` dereferences: `ls` stops describing the link and describes what it points at, which for a
directory means listing its contents. One sentence: `-L` makes `ls` follow symlinks instead of
reporting them.

**46.** `ls` cannot do it. It sorts within the arguments it is given, it does not recurse and sort
as one set — `ls -lRS deep logs` sorts each directory separately, and `ls -S deep/*` only sees one
level. The tool wanted is `find` (Chapter 5) to produce the set, and something to sort it. Say so
and stop.

**47.**
```
$ ls -f logs
thermal-2187-06-13.log  strain-2187-06-13.log  strain-2187-06-12.log  .rotated
hull-2187-06-10.log  .  strain-2187-06-11.log  .keep  ..
$ ls -U logs
thermal-2187-06-13.log  strain-2187-06-13.log  strain-2187-06-12.log
hull-2187-06-10.log  strain-2187-06-11.log
```
Two differences: `-f` implies `-a`, so the dotted entries and `.`/`..` appear; and `-f` also
disables `-l`-style stat calls, which is why it is the fast one on a huge directory. The order of
the five ordinary files is identical, because both are unsorted.

**48.** `.` appears sixth and `..` last, with real files before and after both. Directory order is
hash order on this filesystem, not creation order, so `.` and `..` having no special position is the
point: they are ordinary entries. A student who expected them first has been reading listings, not
directories.

**49.** `-Q` (`--quote-name`):
```
$ ls -Q logs
"hull-2187-06-10.log"
...
```
It exists for names containing spaces, newlines, or control characters — where the unquoted listing
is ambiguous about where one name stops. Example: a file called `strain 2187 06.log` is three words
in a plain listing and one quoted string with `-Q`.

**50.** `--zero`. It separates entries with a NUL byte, which is the one byte that cannot appear in a
filename, so the output is unambiguous even for names with newlines in them. It is consumed by
`xargs -0` and by `while IFS= read -r -d ''` loops — Chapter 5 and Chapter 8.

**51.**
```
$ ls -s logs
880 hull-2187-06-10.log   4 strain-2187-06-11.log   24 strain-2187-06-12.log
  4 strain-2187-06-13.log   8 thermal-2187-06-13.log
```
Both small files occupy one 4096-byte block, reported as 4 (K). The prediction is that 4097 bytes is
the first size needing a second block. Tested:
```
$ head -c 4096 /dev/zero > a.bin; head -c 4097 /dev/zero > b.bin; ls -s a.bin b.bin
4 a.bin
8 b.bin
```
Exactly on the boundary.

**52.** `ls -l logs` says `total 920`. The byte sizes sum to 931880, which is 910K. The gap is
per-file rounding: every file is charged whole 4K blocks, so the four small files together consume
40K of allocation for 31880 bytes of data. Allocation is always at least the data and usually more.

---

## No flag in this lesson

Chapter 2's only flag is in `07-incident-02`.
