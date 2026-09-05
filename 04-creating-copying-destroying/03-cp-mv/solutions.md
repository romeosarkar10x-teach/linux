# 04/03 — Solutions (agent eyes only)

> **Student: do not open this file.** Every answer is here.

## The shape of the lab

- `source/` — `handover.txt`, `readings/` (two files), `faults/open.txt`, `latest.txt` (symlink to
  `readings/2187-05-17.txt`), `open-hardlink.txt` (second name for `faults/open.txt`).
- `dest/` — exists, contains `handover.txt` dated 2187-05-16.
- `dest-file` — exists, regular file.
- `stale/` — `2187-05-17.txt`, `2187-05-18.txt`, `handover.txt` all dated 2187-05-17 01:00 (older
  than source's 2187-05-18 06:00), and `open.txt` dated 2187-05-19 23:00 (**newer** than its source).
- `perms/exec.sh` 0755, `perms/secret.txt` 0600, both dated 2187-05-17 08:00.
- `rename/pnl_01.log` … `pnl_06.log`.
- `/labs` is `/dev/nvme2n1p2`; `/tmp` is on the `overlay` root. Different filesystems — exercise 35
  depends on it.
- coreutils 9.11.

## Per exercise

**1.** `faults/` and `readings/` directories, `handover.txt` regular, `latest.txt` symlink (`@`),
`open-hardlink.txt` regular. The two that are the same file are `open-hardlink.txt` and
`faults/open.txt` — same inode, link count 2. `latest.txt` is **not** the same file as its target;
it is a separate inode holding a path.

**2.** `cp: -r not specified; omitting directory 'source'`, exit **1**. `cp` will not assume you
meant the whole tree.

**3.** Different inode. Two files now exist with the same bytes and no relationship.

**4.** Because renaming and moving are the same filesystem operation: unlink the old directory entry,
create a new one pointing at the same inode. Whether it looks like a rename depends only on whether
both entries are in the same directory.

**5.** `scratch/tree` did not exist, so it **became** the copy: `scratch/tree/handover.txt`,
`scratch/tree/readings/…` and so on. The name was used as the destination itself.

**6.** `dest` existed and was a directory, so `source` was copied **into** it as `dest/source/…`.
Rule: if the destination is an existing directory, the source is placed inside it under its own
name; otherwise the destination is the new name.

**7.** Nothing was copied to `dest/handover.txt` — the copy went to `dest/source/handover.txt`. The
two paths never collided.

**8.** `-T` forces the destination to be treated as a name, never as a directory to descend into, so
`dest` becomes the tree: `dest/handover.txt`, `dest/readings/…`. The pre-existing
`dest/handover.txt` is replaced by `source/handover.txt` — `-T` merges onto the existing directory
and overwrites colliding names.

**9.** No. `cp -r source/ x` and `cp -r source x` produce identical trees. A trailing slash on the
source of a `cp` is a no-op (this is where people's rsync habits mislead them).

**10.** `source/.` names the *contents*, so `scratch/dot` gets `handover.txt`, `readings/` etc.
directly rather than a `source/` wrapper — which is the same result `-T` gives, reached by naming a
different source.

**11.** `mv: cannot move 'source/handover.txt' to 'nosuch/': Not a directory`, exit 1. Without the
slash, `mv` happily creates a **file** called `scratch/nosuch2`. The slash asserts "this destination
is a directory"; if it is not one, the command fails instead of quietly creating a file with the name
you meant as a folder.

**12.** Whenever you mean "put this inside that" and would rather fail than create a file with the
directory's name — for example in a script where the target directory may not have been created yet.

**13.** `cp: cannot stat 'source/latest.txt/': Not a directory`, exit 1. The trailing slash forces
resolution as a directory; `latest.txt` is a symlink to a regular file, so the resolution fails
before `cp` does anything. The same applies to `mv`.

**14.** `cp -r` keeps it a symlink (`lrwxrwxrwx … -> readings/2187-05-17.txt`, size 23 — the length
of the path). `cp -rL` **follows** it and writes a regular file with the target's contents, size 36.
`-r` alone copies symlinks as symlinks; `-L` dereferences.

**15.** `this is a file, not a directory`, then after the copy `deck 3 handover, shift 2 / nothing
outstanding`. **No warning, no output, exit 0.** The original content is gone.

**16.** `cp: overwrite 'dest-file'? ` — answering `n` leaves the file alone. With `</dev/null` the
prompt is still printed, nothing is read, the answer is taken as no, and the exit status is **1**.
Consequence: `-i` in a script is not a safety feature, it is a failure with a prompt printed to
stderr.

**17.** `cp -n` exits **0** and does not overwrite. `-n` is the script-safe one; `-i` is the
interactive one. Note the asymmetry: `-n`'s refusal is a success, `-i`'s unanswered prompt is a
failure. Neither tells you *which* files it skipped.

**18.** `cp: target 'dest-file': Not a directory`, exit 1. Copying into `dest` works. Rule: with more
than one source, the last argument must be an existing directory.

**19.** What already happened — `-v` prints each copy after it is made, `'source' -> 'dest'`, one
line per file including the directories themselves.

**20.** `renamed 'rename/pnl_02.log' -> 'rename/panel-02.log'`. "renamed" is accurate for the
same-filesystem case, which is what happened; for a cross-device move it is a copy and a delete
described with the same word.

**21.** `source/handover.txt` is 2187-05-18 06:00, `stale/handover.txt` is 2187-05-17 01:00, so the
source is newer. `cp -u -v` prints `'source/handover.txt' -> 'stale/handover.txt'`.

**22.** `stale/open.txt` (2187-05-19 23:00) is newer than `source/faults/open.txt` (2187-05-18
06:00). `cp -u -v` prints **nothing**, exits **0**, and the file still says `NEWER than the source
copy`. Without `-v` there is no difference at all between "copied" and "skipped" — same silence, same
exit status. That is the answer to "how would you have known".

**23.** Any case where mtime does not track content usefully: a file restored from a backup with its
original date, a file whose mtime was set by `touch -d`, or a correct file that is simply older than
a broken newer one. `-u` compares clocks, not correctness.

**24.** Both `stale/2187-05-17.txt` and `stale/2187-05-18.txt` are older than their sources, so both
are copied. (If a student reports only one, they have already run exercise 21's copy or an earlier
overwrite; reset.)

**25.** `cp -ru source/. stale/` or `cp -u source/*.txt source/readings/*.txt stale/` — any form that
uses `-u`. Confirm with `cat stale/open.txt`.

**26.** Yes, both: `scratch/e1` is `-rwxr-xr-x`, `scratch/s1` is `-rw-------`. Plain `cp` creates the
destination with the source's mode (with the umask applied to the bits the umask covers — 0600 and
0755 both survive a 0022 umask untouched). Students who were told "cp does not preserve permissions"
are being corrected here.

**27.** The **mtime**. `perms/secret.txt` is 2187-05-17 08:00; the copy carries the current time.
Ownership would also differ if the source were owned by somebody else; in this lab the student owns
both, though the group may differ.

**28.** `-p` preserves mode, ownership and timestamps. `-a` adds `-d` (do not follow symlinks) and
`-R` (recurse) and `--preserve=all`, which additionally keeps hard-link relationships, extended
attributes and contexts. For a tree, `-a` is what "the same tree" means.

**29.** Source: link count **2**, one inode. After `cp -r`: both names have link count **1** and two
different inodes — one file became two. After `cp -a`: both names have link count **2** and share an
inode. `-a` (via `--preserve=links`) kept them one file.

**30.**
```
for f in rename/pnl_*.log; do
  mv "$f" "rename/panel-${f#rename/pnl_}"
done
```
Any equivalent is fine — `basename`, `sed`, a `case`. Quoting `"$f"` is required for a pass mark on
principle, though these names have no spaces.

**31.** No.
```
$ mv rename/pnl_{01..06}.log rename/panel-{01..06}.log
mv: target 'rename/panel-06.log': No such file or directory
```
Exit 1, and **nothing is moved** — it fails before acting. `mv` has one rule for more than two
arguments: the last is a destination *directory*. The twelve names the shell produced are not six
pairs to `mv`; they are eleven sources and one target.

**32.** `mv rename/panel-0{1,2,3}.log scratch/` works because the last argument really is an existing
directory, which is the shape `mv` supports. Many sources, one directory.

**33.** `cp x x` → `cp: 'x' and 'x' are the same file`, exit 1. `mv x x` → `mv: 'x' and 'x' are the
same file`, exit 1. Both refuse; neither truncates. This is a guard, not a coincidence — a naive `cp`
would open the destination with `O_TRUNC` and destroy the source before reading it.

**34.** `cp: cannot copy a directory, 'source', into itself, 'source/nested'`, exit 1. `cp` compares
the destination against the source tree before recursing; without that check the recursion would copy
the growing destination into itself forever.

**35.** Same filesystem: the inode number is **unchanged** — `mv` is a `rename()` syscall, no bytes
read or written. Across filesystems (`/labs` → `/tmp`): a **new** inode, because a directory entry
cannot reference an inode on another device, so `mv` falls back to copy-then-unlink. That is the case
that reads and writes every byte, and the case where an interruption can leave both a partial copy
and the original.

**36.** `mv scratch/e scratch/f` with `f` an existing empty directory → `f/e/x`; the source went
*inside*. `mv -T scratch/e scratch/f` → `f/x`; `-T` replaced `f` (it may do so only because `f` was
empty). With a non-empty target:
```
mv: cannot overwrite 'd/c': Directory not empty
```
exit 1. `mv` will replace an empty directory and will not silently merge or delete a populated one.

**37.**
```
cp -a source scratch/mirror     # first run creates it
cp -a source scratch/mirror     # second run: now mirror exists, so this nests!
```
This is the trap. The correct answer is `cp -aT source scratch/mirror` (or `cp -a source/. …`), run
twice, with identical md5 sums both times. `-a` makes the timestamps match; `-T` makes the second run
a no-op instead of creating `scratch/mirror/source`. A student who reports two different sums has
found the nesting bug and should be credited for finding it, then asked to fix it.

**38.** `dest/handover.txt.~1~` appears — the previous contents, preserved under a numbered backup
name. `--suffix` changes the `~` form for simple backups; the `VERSION_CONTROL` environment variable
supplies the default backup method when `--backup` is given without an argument.

**39.** `cp -t scratch/ source/handover.txt source/latest.txt source/faults/open.txt`. It is the only
thing that works when the file list is generated and appended at the end — `find … -exec cp -t DEST
{} +` or `xargs cp -t DEST`, where the sources necessarily come last and there is no way to put the
destination after them.

**40.** Either
```
cp -n -v source/*.txt dest/     # -v prints only what was copied; anything absent was skipped
```
compared against the source list, or a `ls`/`md5sum` listing of the destination before and after. The
point is that `-n` reports nothing and exits 0, so "did it skip anything?" has to be answered from
outside the command. (This image's coreutils 9.11 does not have a `--update=none-fail`; a student who proposes one has
read a newer man page and should be asked to check `cp --help` in the container.)

**41.** `cp -a source /other/place` — or `cp -aT` if the destination should *be* the tree. The thing
that cannot be reproduced is the **inode numbers**, and with them any hard links that reach *outside*
the copied tree: link identity is preserved only among the files copied in the same run, because a
new file on a new filesystem necessarily gets a new inode. (`ctime` is the other acceptable answer;
see exercise 46.)

**42.**
```
$ set -o noclobber
$ echo z > existing
bash: existing: cannot overwrite existing file
$ cp src existing ; echo $?
0                                  <-- the file is overwritten
```
`noclobber` is a property of the **shell's redirection operator**, not of the filesystem and not of
any command. It refuses to open a file for `>` when it already exists. `cp` opens its own destination
and never consults the shell, so `noclobber` is invisible to it. (`>|` overrides it deliberately.)

**43.** With a terminal attached:
```
mv: replace 'p', overriding mode 0400 (r--------)?
```
`cp` on the same target does not prompt — it fails:
```
cp: cannot create regular file 'p': Permission denied
```
The difference: `cp` must **open the target for writing**, and the mode says no. `mv` (same
filesystem) only has to **unlink** the target and create a directory entry, which needs write
permission on the *directory*, not on the file — so it can succeed, and prompts as a courtesy
because it is about to destroy a file you marked read-only. Run the `mv` with `</dev/null` and the
prompt does not appear at all and the move goes through: the courtesy prompt only exists when stdin
is a terminal.

**44.**
```
$ echo dest > d1; ln d1 d2; echo srcdata > s
$ cp s d1
$ cat d2                      -> srcdata
$ stat -c '%i %h' d1 d2       -> same inode, link count still 2
```
`cp` opened `d1` and truncated it in place, so the *other* name for the same inode shows the new
contents. The link was never broken.

**45.** Contrast with `mv`:
```
$ echo dest2 > e1; ln e1 e2; echo new > s2
$ mv s2 e1
$ cat e2                      -> dest2      (unchanged)
$ stat -c '%i %h' e1 e2       -> different inodes, both link count 1
```
`mv` replaced the *directory entry*: `e1` now names a different inode and `e2` still names the old
one. A reader holding the old file open keeps reading the old, complete file. `cp` mutates the inode
underneath every reader. So **`mv` is the safe way to publish** — write the new version to a
temporary file in the same directory, then `mv` it over the name, and every reader sees either the
whole old version or the whole new one, never a half-written file. This is the atomic-replace idiom
and it depends on `rename()` being atomic within a filesystem.

**46.** **ctime** differs — it records when the inode last changed, and the copy's inode was created
just now. `cp -a` sets atime and mtime explicitly; ctime is not settable by any interface, so
preserving it would mean lying about when this new inode came into existence, which the kernel does
not offer. (The birth time `%w` differs for the same reason.)

## Added exercises 47–52

**47.** `cp --parents source/readings/2187-05-17.txt scratch/`:

```
scratch/source
scratch/source/readings
scratch/source/readings/2187-05-17.txt
```

`--parents` recreates the source path, directory by directory, under the destination — the
destination must already exist and must be a directory. With an absolute source path the leading `/`
is dropped and the rest is appended, so `cp --parents /etc/hosts scratch/` produces
`scratch/etc/hosts`. This is how `cp` is used to pull a scattered subset of a tree out while keeping
the structure that explains what the files are.

**48.**

```
cp -t scratch source/handover.txt source/faults/open.txt
mv -t scratch/sub scratch/a scratch/b
```

The option exists because of `xargs`. `find … -print0 | xargs -0 cp …` appends the filenames to the
end of the command, which is exactly where `cp`'s destination has to go in the normal form — so
without `-t` there is no way to write the pipeline at all. The failure mode it prevents is the
serious one: if the last filename is missing or the list is empty, the normal form silently treats
one of the *sources* as the destination and copies files over each other. With `-t` the destination
is fixed by the option and can never be taken from the argument list.

**49.**

```
$ mkdir -p A/x B/y; mv A B          # status 0 — A becomes B/A
$ mv -T A B                         # B non-empty
mv: cannot overwrite 'B': Directory not empty      # status 1
$ mv -T A B                         # B empty
                                    # status 0 — A's contents are now B/x
```

Plain `mv` sees that the destination exists and is a directory, so it moves the source *into* it —
the same rule that makes `mv file dir/` work. `-T` says "treat the destination as the thing to
become, not as a container", and it refuses to overwrite a non-empty directory: replacing a directory
would mean deleting everything under it, which `mv` will not do implicitly. On an empty `B` it
succeeds and `B` is now what `A` was.

**50.**

```
$ mv A A/x
mv: cannot move 'A' to a subdirectory of itself, 'A/x/A'
```

Status 1. `mv` does not walk the tree: it compares the paths. If the destination path has the source
path as a prefix at a component boundary, the move is a subdirectory-of-itself and is rejected
before anything is renamed. (The kernel's `rename` would also fail with `EINVAL` for the same reason;
`mv` checks first so it can give a useful message.)

**51.**

```
$ cp -rl source scratch/cl
$ stat -c '%i %n' source/handover.txt scratch/cl/handover.txt
4109230 source/handover.txt
4109230 scratch/cl/handover.txt
```

`-l` hard-links the files instead of copying them: same inode, no data written, and the directories
themselves are new. `cp -s` makes symlinks, and it is the one with the path restriction:

```
$ cp -s source/handover.txt scratch/sl.txt
cp: scratch/sl.txt: can make relative symbolic links only in current directory
$ echo $?
1
```

A relative source is copied verbatim into the link, so a link created *elsewhere* would point at a
path relative to the wrong directory and dangle — `cp` refuses rather than make one. `cp -s
source/handover.txt sl.txt` (destination in the current directory) succeeds and gives
`sl.txt -> source/handover.txt`; an absolute source works anywhere and gives an absolute target.

Uses: `cp -rl` is how a cheap snapshot is taken — an entire tree of names for the cost of the
directory entries, so long as nothing edits a file *in place* (an editor that writes-and-renames
breaks the link and leaves the snapshot intact, which is the point; an editor that truncates and
rewrites changes both names at once, which is the trap). `cp -s` gives you a tree that is obviously
not the original: every entry announces where the real file is, so nobody mistakes the copy for
data they can edit.

**52.**

```
$ cp --reflink=always source/handover.txt scratch/rl.txt
cp: failed to clone 'scratch/rl.txt' from 'source/handover.txt': Operation not supported
$ echo $?
1
$ cp --reflink=auto source/handover.txt scratch/rl2.txt
$ echo $?
0
```

A reflink is a copy-on-write clone: the new file gets its own inode and its own name but points at
the *same data blocks*, and blocks are duplicated only when one of the two files is written to. It
needs filesystem support — btrfs, XFS with reflinks enabled, ZFS — and the layers under `/labs` here
(ext4 under an overlay) provide none, so the `FICLONE` ioctl returns `EOPNOTSUPP`.

`auto` caught that and fell back to an ordinary full-data copy, silently and successfully. That is
right for `cp`, whose contract is "the destination has these contents" — how the bytes got there is
an optimisation. It would be wrong for a backup or snapshot tool whose contract is "this costs no
space": there the silent fallback turns a promised deduplicated snapshot into a full second copy, and
you find out when the disk fills. Same fallback, opposite correctness, because the promise is
different.

## Notes for the authoring/tutor agent

- Exercises 6 and 8 both write into `dest`. The instruction to reset between them is not optional;
  without it exercise 8's answer includes leftovers from exercise 6.
- Exercise 26 corrects a very common false belief. Do not let a student pass by asserting "cp does
  not preserve permissions" — the measured answer is that it does, and it is timestamps and
  ownership that it drops.
- Exercise 37 is deliberately shaped so that the obvious answer nests on the second run. Watch for a
  student who reports "identical" without actually running it twice.
- No flag in this lesson. The chapter's only flag is in `05-incident-04`.
