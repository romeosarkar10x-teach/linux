# 03/03 — Solutions

**Do not show the student.** Instructor copy: worked answers, the output a clean seed actually
produces, and where students reliably go wrong.

Every block below was captured from a freshly seeded container. **Inode numbers differ on any other
seed.** Stable and gradeable: every size, every link count, every error string, and which inode
equals which.

---

## Warmup

**1.**
```
$ ls -li panels
total 8
44823 lrwxrwxrwx 1 cadet crew 12 Aug 23 09:04 current -> panel-07.txt
44824 lrwxrwxrwx 1 cadet crew 70 Aug 23 09:04 current-abs -> /labs/03-files-links-and-types/03-hard-vs-symlinks/panels/panel-07.txt
44822 -rw-r--r-- 2 cadet crew 40 Aug 23 09:04 panel-07-alias
44822 -rw-r--r-- 2 cadet crew 40 Aug 23 09:04 panel-07.txt
```
Three distinct inodes: 44822 twice, 44823, 44824.

**2.** `panel-07.txt` and `panel-07-alias`. There is **no original.** Both are directory entries
pointing at inode 44822; the filesystem records how many names exist, not which was first. The name
`alias` is a hint the seed left for humans and carries no weight.

**3.** A symlink's contents *are* the target path. `panel-07.txt` is 12 characters, so the link is
12 bytes. `current-abs` stores a 70-character absolute path, hence 70.

**4.**
```
$ readlink panels/current
panel-07.txt
$ readlink panels/current-abs
/labs/03-files-links-and-types/03-hard-vs-symlinks/panels/panel-07.txt
```
One relative, one absolute. Relative targets are resolved from **the directory containing the
link**, not from the caller's cwd — the source of most confusion later in the lesson.

## Core

**5.**
```
$ cd panels
$ for f in current current-abs panel-07-alias panel-07.txt; do stat -c '%i %h %s %F' "$f"; done
44823 1 12 symbolic link
44824 1 70 symbolic link
44822 2 40 regular file
44822 2 40 regular file
```
Rows 3 and 4 are the same file. Rows 1 and 2 are two separate files that *reach* it.

**6.** `panel-07-alias`: the directory entry holds inode 44822, so `cat` opens that inode directly —
one lookup, no indirection. `panels/current`: `cat` opens inode 44823, the kernel sees the symlink
type, reads its 12 bytes as a path, resolves `panel-07.txt` relative to `panels/`, and opens 44822
instead. Two inodes touched, one file read.

**7.**
```
$ ls -l chain
total 0
lrwxrwxrwx 1 cadet crew  1 Aug 23 09:04 a -> b
lrwxrwxrwx 1 cadet crew  1 Aug 23 09:04 b -> c
lrwxrwxrwx 1 cadet crew 20 Aug 23 09:04 c -> ../target/report.txt
```
`total 0` because `total` counts allocated **blocks**, and a short target is stored inside the inode
itself — a *fast symlink*. Nothing on disk outside the inode, so zero blocks. The files are not
empty; they are 1, 1 and 20 bytes.

**8.**
```
$ readlink chain/a
b
$ readlink chain/b
c
$ readlink chain/c
../target/report.txt
$ readlink chain/../target/report.txt ; echo $?
1
```
The last one prints nothing and exits 1: not a symlink, so there is nothing to read. That failure
*is* the end of the chain, not a mistake.

**9.**
```
$ readlink -f chain/a
/labs/03-files-links-and-types/03-hard-vs-symlinks/target/report.txt
```
Plain `readlink` returns exactly one hop of stored text. `-f` follows every hop and canonicalises
the result to an absolute path, resolving each relative target from the right directory as it goes.

**10.**
```
$ stat -c '%i %s %F' panels/current
44823 12 symbolic link
$ stat -L -c '%i %s %F' panels/current
44822 40 regular file
```
All three fields change because `-L` makes `stat` describe a different file entirely.

**11.**
```
$ ls -l panels/current
lrwxrwxrwx 1 cadet crew 12 Aug 23 09:04 panels/current -> panel-07.txt
$ ls -lL panels/current
-rw-r--r-- 2 cadet crew 40 Aug 23 09:04 panels/current
```
Type character, mode, link count, size, and the arrow all differ. `ls -lL` shows count **2** —
it is describing inode 44822, which has two names.

**12.**
```
$ cat perms/back-door
cat: perms/back-door: Permission denied
$ ls -l perms
total 8
lrwxrwxrwx 1 cadet crew 10 Aug 23 09:04 back-door -> sealed.txt
lrwxrwxrwx 1 cadet crew 10 Aug 23 09:04 open-door -> secret.txt
---------- 1 cadet crew 25 Aug 23 09:04 sealed.txt
-rw------- 1 cadet crew 35 Aug 23 09:04 secret.txt
```
The relevant line is `sealed.txt` at mode `----------`. The distraction is `back-door`'s own
`lrwxrwxrwx`, which grants nothing to anybody.

> **Seed note.** An earlier draft made `sealed.txt` root-owned. Inside the container that did not
> take, and `cat perms/back-door` succeeded — the exercise was silently broken. `chmod 000` is what
> actually produces the denial and is what the seed ships.

**13.** A symlink's mode bits are never consulted. Permission is checked against the target:
`sealed.txt` is `000`, so the read is denied; `secret.txt` is `600` and owned by `cadet`, so it
reads. Both links being `lrwxrwxrwx` is irrelevant in both directions.
```
$ cat perms/open-door
hull tolerance override code: 4471
```

**14.**
```
$ ls -l dangling
total 0
lrwxrwxrwx 1 cadet crew 38 Aug 23 09:04 ghost -> /mnt/engineering/strain-2187-05-22.csv
lrwxrwxrwx 1 cadet crew 16 Aug 23 09:04 ghost-dir -> /mnt/engineering
lrwxrwxrwx 1 cadet crew 18 Aug 23 09:04 vanished -> ../target/gone.csv
$ cat dangling/ghost
cat: dangling/ghost: No such file or directory
```
The link exists — it is right there in the listing. `/mnt/engineering/strain-2187-05-22.csv` does
not. The error names the path the student typed, which is why this trips people.

**15.**
```
$ file dangling/ghost
dangling/ghost: broken symbolic link to /mnt/engineering/strain-2187-05-22.csv
```
`file` states the brokenness. `ls -l` shows only the arrow; a student has to test the target
themselves to learn the same thing.

**16.**
```
$ readlink dangling/ghost
/mnt/engineering/strain-2187-05-22.csv
$ stat -c %N dangling/ghost
'dangling/ghost' -> '/mnt/engineering/strain-2187-05-22.csv'
```
`readlink` is the clean answer. `%N` prints the name and the arrow too, so a student offering it
must say so. Anything parsing `ls -l` output is fragile and should be probed, not failed.

**17.**
```
$ readlink -f dangling/vanished ; echo $?
/labs/03-files-links-and-types/03-hard-vs-symlinks/target/gone.csv
0
$ readlink -e dangling/vanished ; echo $?
1
$ readlink -f dangling/ghost ; echo $?
1
$ readlink -e dangling/ghost ; echo $?
1
```
The rule is about which *components* exist. `-f` requires every component except the last;
`target/` exists, so `vanished` canonicalises even though `gone.csv` does not. `-e` requires all of
them, so it fails. For `ghost`, `/mnt/engineering` itself is missing — a non-final component — so
even `-f` gives up. Not "files versus existence": components.

**18.**
```
$ cat loop/ring-a
cat: loop/ring-a: Too many levels of symbolic links
$ ls -l loop
total 0
lrwxrwxrwx 1 cadet crew 6 Aug 23 09:04 ring-a -> ring-b
lrwxrwxrwx 1 cadet crew 6 Aug 23 09:04 ring-b -> ring-a
```
`ls -l` reads two directory entries and stops. It never resolves a target, so there is no loop to
fall into. The kernel caps resolution depth (40 on Linux) and returns `ELOOP` — it does not detect
the cycle, it just gives up.

**19.**
```
$ ln    target/report.txt mine-hard
$ ln -s target/report.txt mine-soft
$ ls -li target/report.txt mine-hard mine-soft
44831 -rw-r--r-- 2 cadet crew 48 Aug 23 09:04 mine-hard
44840 lrwxrwxrwx 1 cadet crew 17 Aug 23 09:04 mine-soft -> target/report.txt
44831 -rw-r--r-- 2 cadet crew 48 Aug 23 09:04 target/report.txt
```
Count on 44831 went 1 to 2. The symlink is its own inode with count 1 and size 17 — it does not
touch the target's count at all. That is the exercise.

**20.**
```
$ rm target/report.txt
$ cat mine-hard
strain report, deck 3
status: within tolerance
$ cat mine-soft
cat: mine-soft: No such file or directory
$ stat -c %h mine-hard
1
```
The inode still has one name, so the data is fine. The symlink's stored text names a path that no
longer resolves. Deleting a name is not deleting a file; a file dies when its last name does.

**21.** `kestrel reset 03/03`, then confirm `target/report.txt` is back and `mine-*` are gone.

**22.**
```
$ ls -li sizes
total 8
44853 -rw-r--r-- 2 cadet crew    5 Aug 23 09:04 leaf.txt
44855 lrwxrwxrwx 1 cadet crew   40 Aug 23 09:04 long -> very/deeply/nested/subdirectory/leaf.txt
44854 lrwxrwxrwx 1 cadet crew    8 Aug 23 09:04 short -> leaf.txt
44849 drwxr-xr-x 3 cadet crew 4096 Aug 23 09:04 very
$ stat -L -c %s sizes/short sizes/long
5
5
```
Both links reach inode 44853. The short route goes through `sizes/leaf.txt`, which is a **hard link**
to the file at the bottom of `very/` — count 2, same inode, which the student can show with
`ls -i sizes/leaf.txt sizes/very/deeply/nested/subdirectory/leaf.txt`. The link sizes differ because
the stored routes are 8 and 40 characters. The target size is a property of the one file and does not
care which route reached it.

## Experiment

**23.** Predictions first; a missing prediction voids the exercise.
```
$ mv moved/inner moved/renamed
$ cat moved/renamed/near
bay 2 clearance 0.6mm
$ cat moved/renamed/far
cat: moved/renamed/far: No such file or directory
```
`near -> note.txt` is relative and resolved from whatever directory currently holds the link, so it
travelled with the rename. `far` stores the old absolute path containing `inner`, which no longer
exists. Symlinks store **text**, resolved fresh at every use — not an inode, not a handle.

**24.**
```
$ cp    panels/current copy-default ; ls -l copy-default
-rw-r--r-- 1 cadet crew 40 Aug 23 09:06 copy-default
$ cp -P panels/current copy-P ; ls -l copy-P
lrwxrwxrwx 1 cadet crew 12 Aug 23 09:06 copy-P -> panel-07.txt
$ cp    dangling/ghost copy-ghost
cp: cannot stat 'dangling/ghost': No such file or directory
```
`cp` dereferences by default, so the first is a real copy of the 40-byte file. `-P` copies the link
itself — note `copy-P` now points at `panel-07.txt` relative to the *lab root*, where no such file
exists, so it is dangling. The third fails because `cp` stats the source before reading it, and the
stat follows the link into nothing. `cp -P dangling/ghost` would have worked fine — `cp` has no rule
against broken links, it just cannot read through one.

**25.**
```
$ mkdir -p /tmp/e && cd /tmp/e && mkdir d && : > f
$ ln -s ../f d
$ ls -l d
lrwxrwxrwx 1 cadet crew 4 Aug 23 09:07 f -> ../f
```
When the last argument is an existing directory, `ln` creates the link **inside** it under the
target's basename. `-n`/`--no-dereference` makes `ln` treat a symlink-to-directory as a link rather
than descending into it; with `-f` to replace, `ln -sfn NEW dirlink` repoints a directory symlink in
place. Without `-n` the same command drops a new link inside the pointed-at directory instead — the
classic way to make a mess of a `current -> release-N` symlink.

## Stretch

**26.**
```
$ for f in */*; do [ -L "$f" ] && { readlink -e "$f" >/dev/null || echo "$f"; }; done
dangling/ghost
dangling/ghost-dir
dangling/vanished
loop/ring-a
loop/ring-b
```
Five, in two groups. The three under `dangling/` fail because the target does not exist. The two
under `loop/` fail for a different reason: resolution never terminates, so `readlink -e` returns
`ELOOP` rather than a verdict — they are not dangling, they point at something that exists (each
other). Only the first group is dangling.

The `[ -L "$f" ]` guard matters: without it, `readlink -e` also fails on every ordinary file and the
loop reports the whole tree. `readlink -f` would not work here either — it succeeds on `vanished` and
would silently drop one of the three. `cat` tells the two groups apart:
`No such file or directory` versus `Too many levels of symbolic links`.

**27.**
```
$ rm chain/b
$ readlink chain/a
b
$ readlink -f chain/a ; echo $?
/labs/03-files-links-and-types/03-hard-vs-symlinks/chain/b
0
$ cat chain/a
cat: chain/a: No such file or directory
```
Three questions, three answers. What is stored: `b`, unchanged — deleting the target never touches
the link. What does it canonicalise to: `chain/b`, exit 0, because `chain/` exists and `-f` allows
the last component to be absent. Can it be opened: no.

**28.**
```
$ ln -sfn target/report.txt chain/a
$ readlink chain/a
target/report.txt
$ readlink -f chain/a
/labs/03-files-links-and-types/03-hard-vs-symlinks/target/report.txt
$ cat chain/a
strain report, deck 3
status: within tolerance
```
One hop: `readlink` and `readlink -f` now name the same file. `-f` on `ln` replaces the existing
link instead of erroring; `-n` is harmless here and is the habit worth building.

**29.**
```
$ rm panels/panel-07.txt
$ cat panels/panel-07-alias
panel 07
seated 2187-06-09
torque 42 Nm
$ cat panels/current
cat: panels/current: No such file or directory
$ ln -sfn panel-07-alias panels/current
$ cat panels/current
panel 07
seated 2187-06-09
torque 42 Nm
```
The data never moved — inode 44822 still has a name, `panel-07-alias`, and its count is 1 again. The
repair changes the twelve bytes inside the symlink so they name a path that resolves. Recreating
`panel-07.txt` is excluded, and `ln panels/panel-07-alias panels/panel-07.txt` is recreating it by
another route.

**30.**
```
$ mkdir -p /tmp/r/x && ln -s x /tmp/r/xl && cd /tmp/r/xl
$ pwd
/tmp/r/xl
$ pwd -P
/tmp/r/x
```
`cd` deliberately does not resolve the symlink; the shell keeps a logical path so that `cd ..` takes
you back where you came from rather than somewhere surprising. `pwd -P` is the kernel's view, and
that is the one every non-shell tool sees.

## Dig

**31.**
```
$ mkdir -p /tmp/r/x && : > /tmp/r/t.txt
$ ln -sr /tmp/r/t.txt /tmp/r/x/rel
$ ls -l /tmp/r/x/rel
lrwxrwxrwx 1 cadet crew 8 Aug 23 09:08 /tmp/r/x/rel -> ../t.txt
```
`-r`/`--relative` computes the target relative to the link's own directory. Handy for trees that get
moved or mounted somewhere else — the whole point of exercise 23.

**32.** `-m`. It requires **nothing** to exist and canonicalises the path purely as text.
```
$ readlink -e /tmp/r/nope/deeper ; echo $?
1
$ readlink -f /tmp/r/nope/deeper ; echo $?
1
$ readlink -m /tmp/r/nope/deeper ; echo $?
/tmp/r/nope/deeper
0
```
Two missing components is the discriminating case: `-e` needs all, `-f` needs all but the last, `-m`
needs none.

**33.**
```
$ ls -F panels
current@  current-abs@  panel-07-alias  panel-07.txt
$ ln -s very sizes/dlink
$ ls -F sizes
dlink@  leaf.txt  long@  short@  very/
$ ls -p sizes
dlink  leaf.txt  long  short  very/
```
`-F`/`--classify` marks every type: `@` symlink, `/` directory, `*` executable, `|` FIFO, `=`
socket. A symlink gets `@` **even when it points at a directory** — `-F` describes the link, not the
target. `-p` marks real directories only and says nothing about links at all, including
symlink-to-directory. For "which of these are links?", `-F` is the only one of the two that answers.

## Added exercises 34–52

**34.** `panel-07.txt` is 12 characters; the absolute path
`/labs/03-files-links-and-types/03-hard-vs-symlinks/panels/panel-07.txt` is 70. A symlink's size is
the length of its target string, with no terminating NUL counted. A size-0 symlink would be a link
whose target is the empty string, which is not a path; `ln -s '' x` refuses with
`No such file or directory`, so you will not meet one.

**35.**
```
$ stat -c '%N' chain/a chain/b chain/c
'chain/a' -> 'b'
'chain/b' -> 'c'
'chain/c' -> '../target/report.txt'
```
`%N` quotes the name **and**, for a symlink, appends the arrow and the target. It needs no `-L`
because it is reporting on the link itself — `-L` would make `stat` describe the target instead, and
then there would be no arrow to print.

**36.**
```
$ readlink -f sizes/short  → …/sizes/very/deeply/nested/subdirectory/leaf.txt
$ readlink -f sizes/long   → the same path
$ stat -L -c %s sizes/short sizes/long → 5 and 5
```
**5** is the property of the target — the five bytes of `here\n`. 8 and 40 are properties of the two
links: the lengths of `leaf.txt` and `very/deeply/nested/subdirectory/leaf.txt`.

**37.**
```
$ ls -F dangling
ghost@   ghost-dir@   vanished@
```
All three get `@`, the same marker a working link gets. `ls -F` **cannot** distinguish working from
broken, because the marker comes from `lstat` on the link — the type of the link itself — and `ls`
never tries to resolve it. Answering "is this link broken?" requires a second syscall that `-F` does
not make.

**38.**
```
dangling/ghost:     broken symbolic link to /mnt/engineering/strain-2187-05-22.csv
dangling/ghost-dir: broken symbolic link to /mnt/engineering
dangling/vanished:  broken symbolic link to ../target/gone.csv
```
`file`'s job is to identify what is at the end of a name, so it follows the link and reports the
failure it got. `ls -l`'s job is to list directory entries, and the entry contains only the target
string — the directory has no field saying whether that string still resolves. `ls` cannot guess
because the information is not in the thing it read.

**39.** **A symlink's `rwxrwxrwx` is never consulted; access is decided entirely by the target's
mode.** `open-door` reads because `secret.txt` is mode 600 and you own it; `back-door` gives
`Permission denied` because `sealed.txt` is mode 000. On Linux the nine bits on a symlink are
unused — the kernel does not check them and `chmod` on a link changes the target, not the link. For
a script this means **checking a link's mode tells you nothing**: test access on the resolved path
(`readlink -e` then test), or simply attempt the read and handle the error.

**40.**
```
$ cp -a panels /tmp/panels-moved && cd /tmp/panels-moved
$ stat -L -c '%i %n' current current-abs
4109213 current        ← the copy's panel-07.txt
300277  current-abs    ← the original in /labs
```
The **relative** link still works and now points at the copy, because `panel-07.txt` is resolved
against whatever directory the link happens to be in. The **absolute** link also still works, but it
reaches back to the original file in `/labs` — the copy of the link carries the copy of the string,
and that string names a fixed place. This is the whole argument for relative links inside a tree that
may be moved, and for absolute links to things outside it.

**41.**
| command | follows by default? | flag to flip |
|---|---|---|
| `ls -l` | no | `-L` (and `-H` for arguments only) |
| `ls -lL` | yes | omit `-L` |
| `stat` | no | `-L` |
| `stat -L` | yes | omit `-L` |
| `file` | yes for its *description*, no for links — reports the link | `-L` follows, `-h` does not |

**42.** `ls`, `stat` and `file` are **tools for inspecting names**, so "the link" and "the target" are
two different legitimate subjects and they need a way to say which. `cat`, `wc` and `grep` are tools
for **processing contents**, and a symlink's contents are not something you would ever want them to
read — the whole purpose of using the link is to reach the file. A `cat` that printed the target
string would be useless, so no flag exists.

**43.**
```
dangling/vanished:
  readlink     ../target/gone.csv                      exit 0
  readlink -f  …/03-hard-vs-symlinks/target/gone.csv   exit 0
  readlink -e  (nothing)                               exit 1
  readlink -m  …/03-hard-vs-symlinks/target/gone.csv   exit 0
chain/a:
  readlink     b                                       exit 0
  readlink -f  …/target/report.txt                     exit 0
  readlink -e  …/target/report.txt                     exit 0
  readlink -m  …/target/report.txt                     exit 0
```
- plain: *what does this one link say?* (one hop, verbatim)
- `-f`: *what absolute path does this resolve to, if everything but the last component exists?*
- `-e`: *what absolute path does this resolve to, given that all of it must exist?*
- `-m`: *what would this path be, canonically, whether or not any of it exists?*

**44.**
```
$ cat x0
cat: x0: Too many levels of symbolic links
$ readlink -f x0
/tmp/t4/x46
```
The kernel refuses after about **40** hops during a single path resolution — the `ELOOP` limit,
enforced inside `open`. `readlink -f` does not resolve the chain in one syscall: it reads one link,
builds the next path, reads again, in a loop of its own, so no single kernel resolution ever exceeds
the limit. Same chain, two different mechanisms, two different answers.

**45.** The limit is not about long chains, it is about **termination**: a loop has no length, and the
kernel cannot tell a 45-link chain from a cycle without following it. Counting hops is the cheap
answer that handles both. `cat loop/ring-a` gives exactly the same error as the 45-link chain —
`Too many levels of symbolic links` (`ELOOP`) — after bouncing between the two names twenty times
each.

**46.**
```
$ ln -sf /etc sl      # sl -> deep/real2, a directory
$ ls -ld sl           → sl -> deep/real2      (unchanged!)
$ ls -ld deep/real2/etc → etc -> /etc          (created inside the target)
$ ln -sfn /etc sl
$ ls -ld sl           → sl -> /etc             (the link itself replaced)
```
Without `-n`, `ln` **followed** `sl` into the directory and made the link there. With `-n`
(`--no-dereference`) it treated `sl` as a plain file to be replaced. **`-sfn` is what you almost
always want** when re-pointing an existing link. Clean up the stray: `rm deep/real2/etc`.

**47.**
```
$ ln -s panel-07.txt panels/current
ln: failed to create symbolic link 'panels/current': File exists
$ ln -sf panel-07.txt panels/current   # silent success
```
`ln` will not overwrite by default; `-f` removes the destination first. Note that "removes the
destination" is exactly what makes `-f` dangerous on a link to a directory without `-n` — exercise
46.

**48.**
```
$ ln -sr /labs/03-files-links-and-types/03-hard-vs-symlinks/target/report.txt /tmp/r
$ ls -l /tmp/r
/tmp/r -> ../labs/03-files-links-and-types/03-hard-vs-symlinks/target/report.txt
```
One `..`, not several: the link lives in `/tmp`, so one step up reaches `/`, and everything after
that is a descent. `-r` computes the target relative to the **directory containing the new link**,
which is the only place the string will ever be resolved from.

**49.**
```
$ mkdir -p /tmp/t4/deep/real2/sub2 && ln -s deep/real2 /tmp/t4/near2
$ cd /tmp/t4/near2/sub2 ; pwd      → /tmp/t4/near2/sub2
                          pwd -P   → /tmp/t4/deep/real2/sub2
$ cd .. ; pwd                      → /tmp/t4/near2
$ cd -P /tmp/t4/near2/sub2 ; cd .. ; pwd → /tmp/t4/deep/real2
```
The shell keeps a *logical* working directory — the path you typed — and `cd ..` edits that string,
so you go back the way you came. `cd -P` throws the string away and keeps the resolved path, so `..`
is the real parent. **`pwd -P` is the truth as the kernel sees it**: the kernel has no memory of how
you arrived, only an inode, which is why `ls -l /proc/self/cwd` always agrees with `pwd -P`.

**50.**
```
$ cat dangling/vanished
cat: dangling/vanished: No such file or directory   ← ENOENT, three links
$ cat loop/ring-a
cat: loop/ring-a: Too many levels of symbolic links ← ELOOP, two links
```
The `ENOENT` group — `ghost`, `ghost-dir`, `vanished` — is genuinely dangling and **would start
working the moment the missing files appeared**. The `ELOOP` group — `ring-a`, `ring-b` — is not
dangling at all: every target exists, and restoring files fixes nothing, because the defect is the
cycle itself. `readlink -e` fails on both, which is why "readlink -e failed" is not by itself a
diagnosis.

**51.**
```
$ mv panels/panel-07.txt panels/panel-08.txt
$ cat panels/current      → No such file or directory
$ ln -sfn panel-08.txt panels/current
$ cat panels/current      → works
$ cat panels/panel-07-alias → worked throughout
```
A symlink stores **a path**, and a path is a claim about the directory tree that a rename
invalidates; nothing updates the link because nothing knows the link exists. A hard link stores
**a reference to the inode**, and renaming another name for that inode changes no field the alias
depends on. The alias is not "repaired" — it was never broken.

**52.** Use `ln -sfn releases/2187-06-11 current.tmp && mv -T current.tmp current`, because `mv` onto
an existing name is a **`rename`**, which is atomic: at every instant `current` names either the old
release or the new one, and never nothing. `rm current` followed by `ln -s` opens a window — however
brief — in which `current` does not exist, and a process that opens `current/config` inside it gets
`ENOENT` and, typically, dies at start-up. The hard-link equivalent would be hard-linking every file
of the release under `current/`, which nobody does: hard links cannot be made to directories at all
(03/02 exercise 20), so you would be linking thousands of individual files with no atomic swap for
the set, and the release could not span a filesystem.

## Wrap-up

**No flag in this lesson.** Model answer:

- A hard link is an extra directory entry naming an existing inode; the inode's link count is how
  many such entries exist, and the file is freed when that count reaches zero.
- A symlink is a small file of its own whose contents are a path string, resolved by the kernel
  every time the link is used.
- A dangling link can exist because nothing ever checks the target: not `ln -s` at creation, not
  `rm` when the target goes. The text just stays and stops resolving.
- `readlink -f` gives a canonical absolute path whose last component need not exist; `readlink -e`
  prints nothing and exits 1 unless every component resolves to something real.

Keep these. `06-incident-03` is a link maze and the four sentences are the map.
