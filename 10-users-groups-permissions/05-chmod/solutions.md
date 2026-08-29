# 10/05 — Solutions

Instructor copy. Every mode below was measured in the container, not remembered.

---

## Numeric

**1.** `644` for all three (`chmod.txt`, `deletion.txt`, `page.txt`). Unremarkable, which is the
point: 644 is what an ordinary readable file looks like and you should stop noticing it.

**2.** `644` — same as the original here, but not *because* it copied it. `cp` creates a new file and
the new file's mode is the source mode reduced by the `umask` (0022). 644 has no group- or
other-write to remove, so nothing changed. Lesson 06 does umask properly.

**3.** `600 -rw------- scratch/a`. `%a` is the digits, `%A` is the ten-character string `ls -l`
prints. Same information twice.

**4.** `bash: scratch/a: Permission denied`. `chmod 600` (or `u+w`) restores the owner's write bit.

**5.** Measured: `stat -c '%a %A'` prints `4 -------r--`. A short numeric argument is **left-padded
with zeros**, so `chmod 4` means `chmod 004`: owner and group get nothing at all. This is why nobody
types short numeric modes.

**6.** `chmod 644 scratch/a`.

**7.** `640` (`rw- r-- ---`) to `755` (`rwx r-x r-x`): owner gains `x`, group gains `x`, other gains
`r` and `x`. Nothing is removed in this particular case — so the student must reason about what
*would* be. `chmod 755` on `664` removes group write and other write; `chmod 755` on `600` grants
group and other read and execute. The bit to name is any bit set in the old mode and clear in `755`,
and the student should be able to say that a numeric mode always has some such set, in general.

**8.** A numeric mode is **absolute**: it sets all nine bits, so every bit you did not think about is
being set to zero as deliberately as the ones you did.

---

## Symbolic

Measured sequence, starting from `000`, each command applied to the result of the last:

```
u+r            -r--------  400
g+w            -r---w----  420
o=x            -r---w---x  421
a+x            -r-x-wx--x  531
ug=rw          -rw-rw---x  661
u+rwx,go-rwx   -rwx------  700
+X             -rwx--x--x  711
```

**9.** `400`. **10.** `420`. 

**11.** `421`. `o=x` *assigns* the other triad — it would have cleared `r` and `w` there if they had
been set. `o+x` only adds. `=` is absolute within its triad; `+`/`-` are relative.

**12.** `531`. All three: owner `r--`→`r-x`, group `-w-`→`-wx`, other `--x` already had it (no
change), so `a+x` is idempotent on a triad that already has the bit.

**13.** `661`. The `other` triad kept its `x` — `ug=` says nothing about `other`, so `other` is
untouched. That is the whole exercise: `=` is absolute *within the triads you name*, not across the
file.

**14.** `700`. Numerically `chmod 700`. Two clauses, comma-separated, applied left to right.

**15.** Only the ones that assign every triad: `u+rwx,go-rwx` and (jointly) nothing else here.
`u+r`, `g+w`, `a+x`, `ug=rw` and `o=x` all depend on bits they leave alone, so you cannot write them
numerically without first reading the current mode.

**16.** From `000`, `chmod +w` gives **`200`**, not `222`. `notes/chmod.txt` says the default `who` is
`a`, and that is true — but a bare `+` (and only a bare `+`, with no `who`) has the **umask** applied
to it. `umask` is `0022`, which removes group and other write, leaving the owner's. From `644` the
same command changes nothing at all. This is the single most confusing corner of `chmod`; the honest
advice is to always write the `who`.

**17.** `chmod go-w FILE` — or `chmod a-w,u+w FILE` if you also want to guarantee the owner has it.

**18.** `chmod g+x FILE`.

**19.** You cannot, without first running `stat` or `ls -l`: you would have to reconstruct all nine
bits. That asymmetry — symbolic edits relative, numeric sets absolute — is when to reach for which.

**20.** `chmod a=r` then `chmod u+w` = `644`, built without reading the old mode: clear everything to
a known state, then add back exactly what you want. Idiomatic precisely because it does not depend on
what the file was.

---

## What chmod needs

**21.** `root root 444`.

**22.** `chmod: changing permissions of 'drop/theirs.txt': Operation not permitted` (exit 1). None of
the nine would have helped.

**23.** `chmod` requires that you **own the file** (or be root). The nine permission bits describe
what may be done to the file's *contents*; changing the mode is a change to the file's *metadata*,
which is the owner's prerogative. The owner is recorded in the inode, next to the mode itself.

**24.** It worked because ownership, not the mode, is what `chmod` consults — and you own it. `000`
means you cannot read or write the data; it says nothing about your authority over the inode.

**25.** No. There is no such mode, and there cannot be, because the check does not read the mode at
all. If it did, `000` would be a one-way door and every accidental `chmod 000` would need root to
undo.

---

## The four repairs

**26.** `644`. It has no `x` for anybody, including its owner, so it cannot be executed — the shell
reports `Permission denied` even though the file is perfectly readable.

**27.** All three give `755` **here**, because the file is already `644` and `umask 0022` contains no
`x` bits to mask. On a `640` file they diverge: measured, both `+x` and `a+x` give `751`, while
`chmod 755` gives `755` — additionally granting other-read, which nobody asked for. Prefer `a+x` when you mean "make it runnable" and
`755` when you mean "make it look like every other script here".

**28.** `./repair/collect.sh` prints `collected 2026-08-29`.

**29.** `644`. Every account on the station can read a private key. Read is the whole compromise —
they do not need write.

**30.** `chmod 600 repair/id_station`. Numeric, and this is the case where symbolic is wrong:
`chmod go-r` fixes only what you happened to notice, and leaves whatever else was set. For a secret
you want an *absolute* statement of the final mode, so that the command is true regardless of what
the file was.

**31.** `755`, owner `cadet`, group `crew`. Group write is missing. Others in `crew` can enter and
read but cannot create, rename or delete a name in it.

**32.** `chmod g+w repair/handover` → `775`. The change is on the directory because creating and
deleting a name is a modification of the directory, not of any file.

**33.** `touch repair/handover/mine` succeeds. Another `crew` member could now **delete
`week-24.txt`**, even though the file is `644` and owned by you and they cannot write a byte of it —
because `rm` needs write on the *directory*, not on the file.

**34.** Correct to be uneasy. The fix is the sticky bit, chapter 10 lesson 08, and it is exactly what
`/tmp` uses.

**35.** `777`. It holds an endpoint and a token: `token = not-a-real-token-but-treat-it-like-one`.

**36.** In descending badness: (a) **world-readable** — every account can read the token, and that is
the actual breach; (b) **world-writable** — every account can rewrite the endpoint and point the
exporter at a machine of their choosing, which is worse in impact but requires intent rather than
curiosity; (c) **world-executable** — meaningless here, but it is the loudest signal in `ls -l` that
somebody typed 777 without thinking. Reasonable people rank (a) and (b) either way; the student must
argue, not just list.

**37.** `chmod 600 repair/exporter.conf`. The service runs as the file's owner, so nobody else needs
any access at all.

**38.** The `x` bit on a non-program means "the kernel may try to run this as a program". If somebody
does, the kernel reads the first line, finds no `#!` and no valid binary header, and the exec fails
with `Exec format error`. So it is not directly harmful — it is *wrong*, and wrongness in a mode is
worth fixing because modes are read by people who assume they were chosen.

**39.** Model answer:

```
collect.sh   chmod a+x       — it is a script; it was missing the bit that makes it one.
id_station   chmod 600       — private key. Was world-readable. Read was the whole problem.
handover/    chmod g+w       — crew write in it daily; creating a name is a write to the directory.
exporter.conf chmod 600      — it holds a token. 777 was three separate mistakes in one number.

The 777 got the export out on time and I would rather have the export. It is fixed now, and
600 is what it should have been from the start.
```

Marking the last line: it must fix the config *and* decline to name a culprit. rhea's position is
that the mode was wrong, not that the person was.

**40.** `ls -l` makes `id_station` (`-rw-r--r--` on something called a key) and `exporter.conf`
(`-rwxrwxrwx`) obvious to anyone glancing. `collect.sh` missing `x` is only obvious if you know it is
meant to be run, and `handover/` missing `g+w` is invisible unless you know who uses it. So half of
the class is findable mechanically (`find -perm`) and half needs intent — which is why lesson 04's
`find -perm` sweeps find leaks, and never find missing capability.

---

## Deleting

**41.** `drop` is `777`, owner `cadet`. It contains `theirs.txt` (`444 root:root`), `yours.txt`
(`644 cadet:crew`) and `README`.

**42.** Denied. The `other` triad — you are neither `root` nor in group `root` — and it is `r--`.

**43.** `rm drop/theirs.txt` **succeeds**, rc 0. Most students predict failure.

**44.** `rm` was asking, not the kernel. Interactively `rm` notices the file is not writable by you
and prints `rm: remove write-protected regular file 'theirs.txt'?` — a courtesy, entirely inside
`rm`. Check by running `rm -f`, or by piping input so there is no terminal: the prompt vanishes and
the removal still happens. The kernel never had an objection.

**45.** Deleting is removing a name from a list. The list is the directory. You have write on the
directory, so you may change the list. The file's own mode governs its contents, and you never
touched its contents.

**46.** e.g. `mkdir scratch/d7; echo hi > scratch/d7/f; chmod 444 scratch/d7/f` — directory `755`
and yours, file unwritable. `rm scratch/d7/f` returns 0.

**47.** `mkdir scratch/d5; echo hi > scratch/d5/f; chmod 555 scratch/d5`.

**48.** `echo more >> scratch/d5/f` succeeds (file mode `644`, and you own it).
`rm scratch/d5/f` gives `rm: cannot remove 'scratch/d5/f': Permission denied`, and
`touch scratch/d5/new` gives the same. Editing consulted the **file's** mode; creating and deleting
consulted the **directory's**.

**49.** To stop deletion, change the **directory's** mode (or set the sticky bit). To stop editing,
change the **file's**.

**50.** Anyone in group `crew` may now create, rename and delete any name in `repair/handover`,
regardless of who owns those files or what modes they carry.

**51.** The `1` must be an exception to the directory-write rule: write on the directory still lets
you add names, but removing or renaming a name is restricted to the file's owner (or the directory's,
or root). Which is exactly what it is — the sticky bit, lesson 08. Accept any answer that identifies
"write, except you can only delete your own".

---

## Recursion

**52.** `tree` is `600`. No `x` on a directory means it cannot be traversed, so `cd tree`, `ls tree`
and `find tree` all fail — `find: 'tree/README': Permission denied` and the same for `bin` and
`data`. Read without execute on a directory is close to useless.

**53.** `chmod -R 755 tree` marks the three CSVs and the README executable. They are data. Every
future `find -perm /111` sweep will trip over them and every reader will wonder what they run.

**54.** `chmod -R a+rx tree` has the same problem: `+x` applied to every file regardless of kind. It
differs from 53 only in that it preserves write bits — the executability mistake is identical.

**55.** Measured after `chmod -R a+rX tree` (rc 0):

```
755 tree
755 tree/bin
755 tree/bin/helper
755 tree/bin/run
755 tree/data
755 tree/data/archive
644 tree/README
644 tree/data/archive/cycle-40.csv
644 tree/data/cycle-41.csv
644 tree/data/cycle-42.csv
```

Directories and the two scripts got `x`; the README and the CSVs did not.

**56.** `X` sets the execute bit **if the target is a directory, or if the target already has execute
set for at least one of the three triads**. The second half is what spares the CSVs and preserves the
scripts: `600` files stay non-executable, `700` files stay executable.

**57.** `chmod` fixes a directory's own mode *before* descending into it, so by the time it needs to
traverse `tree` it has already granted itself the `x` it needs. It works top-down. A bottom-up
implementation could not have started.

**58.** `644` — copied from `tree/data/cycle-41.csv`. `--reference` is better whenever the correct
answer is "the same as that one": it survives the other file's mode changing, and it documents the
intent instead of a magic number.

**59.** Measured: the first `chmod -c a+w tree/README` prints

```
mode of 'tree/README' changed from 0644 (rw-r--r--) to 0666 (rw-rw-rw-)
```

and the second prints nothing. `-c` reports only actual changes; `-v` reports every file whether it
changed or not. In a script that walks a thousand files, `-c` output *is* the change log, and empty
output means the run was a no-op.

**60.** `find tree -type d -exec chmod 755 {} + ; find tree -type f -exec chmod 644 {} +`. It is more
explicit than `X` and says what you mean when you genuinely want *no* executables. `X` is better when
the tree contains real scripts whose executability you want preserved — which is this tree, so here
`a+rX` is the right answer and the `find` pair would have broken `bin/run`.

---

## Symlinks and edges

**61.** `lrwxrwxrwx`. Symlink modes are always `777` on Linux and are not consulted for anything.

**62.** `chmod 600 scratch/link` sets **`notes/chmod.txt`** to `600`. The link still shows
`lrwxrwxrwx`. Verified: `stat -c %a notes/chmod.txt` → `600`.

**63.** `chmod` follows symlinks and there is no portable way to stop it (`-h` is not GNU `chmod`; the
tool has no such option). A symlink's own mode is good for nothing — access is decided by the
target's mode and by the `x` bits on the directories along the way.

**64.** No difference for the nine bits; the leading digit is the special-bits triad (setuid, setgid,
sticky) and omitting it means "clear it". `stat -c '%04a %n' /tmp` prints `1777` — and plain
`stat -c %a /tmp` prints `1777` too, because `%a` shows the fourth digit whenever it is non-zero.

**65.** From 51: it should make the directory shared-but-safe — anyone may create, only the owner of a
name may remove it. That is the sticky bit, lesson 08.

---

## Judgement

**66.** (1) It grants write to everybody, so the next failure is somebody else's edit and you will not
know whose. (2) It grants read to everybody, which is the part that leaks secrets and the part nobody
thinks about when they are chasing an execute error. (3) `-R` marks every data file executable,
poisoning every future permission audit. (4) `.` is wherever the shell happens to be, which is a
different set of files each time it is typed. And a fifth, worth saying: it does not identify what
was actually wrong, so nothing is learned and it will happen again.

**67.** `find /labs -type f -perm -o=w`. `-type f` matters because without it the sweep returns
symlinks, which are always `lrwxrwxrwx` and never a finding — the standard false positive, and the
reason lesson 04's `/etc` sweep returned `/etc/rmt`, `/etc/os-release` and `/etc/mtab`.

**68.**

```bash
harden() {
  local f=$1
  [ -e "$f" ] || { echo "harden: no such file: $f" >&2; return 1; }
  if [ ! -O "$f" ]; then
    echo "harden: not yours: $f (owner $(stat -c %U "$f"))" >&2
    return 1
  fi
  echo "before $(stat -c %a "$f") $f"
  chmod 600 "$f"
  echo "after  $(stat -c %a "$f") $f"
}
```

`[ -O ]` is "you own it" — cheaper and more honest than comparing `stat -c %U` to `id -un`, since it
compares uids. On `scratch/a` it prints before/after; on `drop/theirs.txt` it refuses before running
`chmod`, which is better than letting `chmod` fail.

**69.** A directory's mode controls the *names* in it, and the names are how files are reached and
removed — but the file's data lives in the inode, which several names may point at. So "read-only
directory" protects the listing, not the contents: anyone with an existing path into a file can still
edit it if the file's own mode allows, and anyone with write on any *other* directory holding a link
to that inode can still unlink it there. If you genuinely need a file nobody may remove, the tools
are the sticky bit (own-only deletion), ownership of the containing directory, or making the file
immutable at the filesystem level — not the directory's `w` bit.
