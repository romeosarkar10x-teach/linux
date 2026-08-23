# 04/04 — Solutions (agent eyes only)

> **Student: do not open this file.** Everything here is measured against the running container.

There is no flag in this lesson. The flag lives in `05-incident-04`.

## The one sentence this lesson exists for

Deleting a file is **editing the directory that names it**. Every surprise in this lab falls out of
that: read-only files delete, writable files in read-only directories do not, `rm` on a hard link
removes a name and not a file, and `-f` cannot force what the kernel refuses.

## Per exercise

**1.** `rm junk/panel-01.log` — no output at all, rc 0. `ls junk` shows the remaining five logs and
`old`. `rm` is silent on success. That silence is the design: no confirmation you can rely on.

**2.**
```
$ rm junk/nosuch.log ; echo $?
rm: cannot remove 'junk/nosuch.log': No such file or directory
1
$ rm -f junk/nosuch.log ; echo $?
0
```
`-f` suppresses the missing-file diagnostic **and** the nonzero status.

**3.**
```
rm: cannot remove 'junk/old': Is a directory
rmdir: failed to remove 'junk/old': Directory not empty
```
Both rc 1. Different reasons: `rm` without `-r` will not descend into a directory at all; `rmdir`
only ever removes an *empty* directory and this one has contents. Accept any phrasing of "one
refuses the type, the other refuses the state".

**4.** `rm -r junk/old` (or `rm -rf`). `-r` overrides the exercise-3 `rm` refusal; the `rmdir`
refusal is *satisfied* rather than overridden, because `-r` empties the directory first and then
removes it.

**5.**
```
removed 'junk/panel-02.log'
removed 'junk/panel-03.log'
```
Past tense, printed after each unlink succeeds. `-v` reports, it does not confirm in advance.

**6.** `ls junk/panel-*.log` and `rm junk/panel-*.log` receive the *identical* argument list — the
shell expands the glob before either command starts. That is exactly why the `ls` is a real check
and not a ritual: it shows the literal list `rm` is about to be handed, including anything the
student did not expect to match.

**7.** Interactively, `y`/`n` per file and only the `y` files go. Non-interactively:
```
$ rm -i junk/panel-0*.log </dev/null ; echo $?
rm: remove regular file 'junk/panel-04.log'? rm: remove regular file 'junk/panel-05.log'? rm: remove regular file 'junk/panel-06.log'? 0
```
The prompts are printed, EOF reads as "no", **nothing is deleted**, rc **0**. Note for the agent:
this differs from `cp -i </dev/null`, which exits **1**. A student who has done lesson 03 may expect
1; the measured answer is 0.

**8.** `rm -I junk/panel-0*.log` on a terminal prompts exactly once:
```
rm: remove 6 arguments?
```
One prompt for six files. `-i` would have asked six times.

**9.** `man rm`: `-I` prompts once "when removing more than three files, or when removing
recursively". The argument: `-i` is so noisy that people alias it away or reflexively hold down `y`,
which trains the habit it was meant to prevent; `-I` fires only on the two shapes that actually cause
disasters, so it survives in a real `.bashrc`.

**10.** `-f` and `--force` look like options; `strain report.txt` breaks into two arguments unquoted;
`two\nlines.txt` cannot be typed. `keep-this.txt` is ordinary. (Accept the newline file being counted
instead of one of the others as long as the reasoning is right — there are four awkward names and
three *kinds* of awkwardness.)

**11.**
```
$ cd awkward; rm -f; echo $?
0
```
No output, rc 0, and the file named `-f` is still there. `rm` parsed `-f` as the force option, was
left with **no operands**, and `-f` also makes "no operands" a non-error. Two separate effects of the
same flag, which is why it looks like nothing happened.

**12.** `rm -- -f`. Everything after `--` is an operand.

**13.** `rm ./--force`. The argument no longer begins with a dash, so no option parser can mistake
it; `./--force` and `--force` name the same directory entry.

**14.** `--` needs `rm` to cooperate — it is a getopt convention, and a command that hand-rolls its
argument parsing may not honour it. `./` is a fact about the path and works with any command that
takes a filename. `./` is the better habit for that reason. (Both are correct answers to exercise
12/13; only `./` generalises.)

**15.** `rm 'strain report.txt'` or `rm strain\ report.txt`. Unquoted, `rm` would have received
**two** arguments, `strain` and `report.txt`, and reported two separate "No such file" errors while
the real file survived.

**16.** `ls -b awkward` →
```
two\nlines.txt
```
`\n` escaped, one line, one entry. Also acceptable: `ls -A awkward | wc -l` → 4 against
`find awkward -type f | wc -l` → 4; or `ls -1q`, or `find awkward -type f -print0 | tr '\0' '\n'`.
Reject "I counted the lines of `ls`" — that is the misreading the exercise is about.

**17.** `rm awkward/two*lines.txt` or tab completion. Typing fails because there is no way to enter a
literal newline into a command line as part of a word without quoting gymnastics; the shell treats
Enter as end of command. Completion and globbing both take the bytes from the filesystem.

**18.** Check first, then delete. Any of these is correct:
```
$ ls awkward/[!k]*                 # check the glob
$ rm -- awkward/[!k]*              # delete what it listed
```
or explicitly `rm -- awkward/-f awkward/--force awkward/'strain report.txt' awkward/two*lines.txt`,
or `find awkward -type f ! -name keep-this.txt -delete`. There is no single elegant "everything but
this one name" glob in POSIX shell without `extglob`; several answers are right. Reject any answer
that was not checked with `ls` first.

**19.** A filename is dangerous when the *shell or the option parser* will interpret it before `rm`
ever sees it as a name. The characters are legal in a filename — everything except `/` and NUL is —
the danger lives entirely in the layer above.

**20.** With a terminal:
```
rm: remove write-protected regular file 'protected/keep.txt'?
```

**21.** `y` deletes it, rc 0. With `</dev/null`: **no prompt at all**, the file is deleted, rc 0. The
prompt is only printed when stdin is a terminal — it is a courtesy for humans, not a permission
check, and scripts never see it.

**22.** `rm -f protected/keep.txt` — no prompt, deleted, rc 0. `-f` means "do not ask me about
write-protected files". It does not mean the file was protected and got overridden; the file was
never protecting itself.

**23.** **The directory's** permission bits decide. Removing a name is a write to the directory. The
file's own mode is irrelevant to deletion (it only triggers a courtesy prompt).

**24.**
```
rm: cannot remove 'locked/report.txt': Permission denied
```

**25.** Identical message, rc **1**. `-f` suppresses prompts and missing-file errors; it does not
grant write permission on the directory. "Force" is about `rm`'s own politeness, not about the
kernel.

**26.** `chmod u+w locked` (i.e. `chmod 755 locked`), then `rm locked/report.txt` succeeds. The file
was never touched.

**27.** Model answer: "`chmod 400` stops people reading and writing the file's *contents*; it does
not stop anyone deleting it, because deletion is a write to the enclosing directory. If you want a
file to survive, make the directory unwritable — and accept that this also stops you creating
anything else in there."

**28.**
```
linked/readings.txt       3288628 2
linked/readings-alias.txt 3288628 2
(after rm)
linked/readings-alias.txt 3288628 1
strain 0.41
strain 0.43
```
Inode numbers are seed-specific. `rm` removed a **directory entry** and decremented the link count.
No data was touched.

**29.** Because that is literally the system call (`unlink(2)`), and because "delete" implies the
contents went away, which happens only as a side effect when the count hits zero *and* nothing has
it open. `rm` never deletes; it unlinks, and the kernel collects.

**30.** `rm` removed the symlink `linked/latest.txt`. `linked/readings.txt` is untouched. `rm` on a
symlink never follows it — it always removes the link itself.

**31.**
```
rm: cannot remove 'linked/archive-link/': Is a directory
rm: cannot remove 'linked/archive-link/': Not a directory
```
Both rc 1.

**32.** The trailing slash makes the kernel resolve the symlink, so `rm` sees the *directory*
`archive` and refuses without `-r` — "Is a directory". With `-r`, `rm` tries to recurse into the
path `archive-link/` but the entry it must actually unlink at the end is a symlink, not a directory,
so the resolution fails the other way — "Not a directory". If the slash had been ignored, exercise
33's plain `rm` would have removed the link and `archive/` would still be there — which is precisely
what happens without the slash.

**33.** `rm linked/archive-link` — rc 0, and `linked/archive` survives with its file. Sticky note:
**a trailing slash on a symlink means "the thing it points at", so never put one there unless that is
what you mean.**

**34.**
```
rm: it is dangerous to operate recursively on '/'
rm: use --no-preserve-root to override this failsafe
```
rc 1, nothing removed. Still dangerous: `rm -rf --no-preserve-root /`, and — the point worth making —
`rm -rf /*`, which the failsafe does **not** catch, because after globbing no argument is the literal
string `/`.

**35.**
```
rm: skipping '/labs', since it's on a different device
rm: and --preserve-root=all is in effect
```
rc **1**. What protected the tree was the **filesystem boundary**: `/labs` is `/dev/nvme2n1p2` and
`/` is `overlay`, and `--preserve-root=all` refuses to cross a mount point. Without `=all`, plain
`--preserve-root` only special-cases `/` itself and this command would have erased the lab.

**36.**
- `D=""; rm -rf "$D"/subdir` — expands to `rm -rf /subdir`. rc 0 here only because `/subdir` does not
  exist. On a system where it did, it would be gone. **Dangerous.**
- `rm -rf scratch/tmpdir /` — `scratch/tmpdir` is removed, *then* `/` hits the failsafe and prints
  the exercise-34 message, rc 1. **Stopped by the failsafe** (for the part that mattered).
- `cd scratch; rm -rf tmpdir/ *` — the glob expands to everything in the current directory and it all
  goes. **Dangerous**, and it is the realistic one: a stray space in `rm -rf "$DIR"/ *`.

The lesson: the failsafe matches one literal argument. Everything that goes wrong in practice goes
wrong during *expansion*, before `rm` can inspect anything.

**37.** rc **0**. In a cleanup script that is correct — "make sure this is gone" should not fail
because it was already gone. At a prompt it is dangerous for the same reason: `rm -rf` on a
mistyped path reports nothing and succeeds, so a typo is indistinguishable from a correct run.

**38.** A working version:
```
trash() {
  local ts f
  ts=$(date +%Y%m%dT%H%M%S)
  for f in "$@"; do
    mv -- "$f" "trash/$(basename -- "$f").$ts.$$"
  done
}
```
Demonstrate with `trash junk/panel-04.log junk/old/notes.txt` — two different `notes.txt`-style
basenames land side by side. Worse than `rm` in two ways: it never frees any space (that is the whole
idea, but it means the disk still fills), and `mv` across filesystems copies rather than renames, so
trashing a large file on another mount is slow and can itself fail halfway. Accept also: it changes
the file's path so anything referring to it breaks; it silently grows forever with no expiry.

**39.** `mktemp` prints a path like `/tmp/tmp.NlWDoUG5b5`; `-d` makes a directory. `XXXXXX` in a
template is replaced with random characters, and `mktemp` *creates* the file atomically with mode
0600 (directory 0700), so there is no window where another user can pre-create or symlink-attack the
path. The safety answer: `/tmp/mywork` is a name you chose, so it might already exist, might belong
to somebody else, might be a symlink pointing at something you care about — and `rm -rf` on it
follows your intent into the wrong place. `$(mktemp -d)` is guaranteed fresh, yours, and empty, so
`rm -rf` on it can only destroy what you put there.

**40.**
```
#!/usr/bin/env bash
set -euo pipefail
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
printf 'work\n' > "$tmp/file"
false            # blow up on purpose
```
Run it, `echo $?` → 1, and `ls "$tmp"` (the path it printed, if you print it) → gone. `trap … EXIT`
fires on normal exit, on `set -e` failure, and on most signals.

**41.**
```
$ find junk -name '*.log' -print
junk/panel-05.log
junk/panel-04.log
junk/panel-06.log
$ find junk -name '*.log' -delete ; echo $?
0
```
`-delete` is safer than `-exec rm {} \;` because it deletes using a file descriptor for the
containing directory (`unlinkat`) rather than re-resolving the path in a new process, so it cannot be
tricked by a path component that changed between `find` seeing it and `rm` acting on it — and it does
not fork a process per file. On a non-empty directory:
```
find: cannot delete ‘junk/old’: Directory not empty
```
rc 1 — `-delete` implies `-depth` but still uses `rmdir` semantics for directories.

**42.** `shred -u scratch/s.txt` overwrites and then removes it, rc 0. It cannot promise anything on
a modern filesystem because `shred` overwrites *the blocks the file currently points at*, and
journalling, copy-on-write, compression, snapshots and log-structured layouts all mean the old
contents may still sit in blocks the file no longer references. SSD wear-levelling makes it worse:
the drive may write the overwrite somewhere else entirely. `man shred`'s CAUTION says this in the
same words.

**43.** The file disappears from `ls busy` immediately. `ls -l /proc/<pid>/fd` shows something like:
```
lr-x------ 1 cadet crew 64 ... 3 -> '/labs/.../busy/big.log (deleted)'
```
The word is `(deleted)`. The name is gone; the open file description is not.

**44.** Three `df` readings: used space rises by ~48–50 MB when `scratch/big` is created; **unchanged**
immediately after `rm` while `tail -f` still holds it; drops back only after the holder is killed.
Exact numbers are machine-specific — what must be right is that reading two equals reading one and
reading three is back near the starting figure.

**45.**
```
$ lsof +L1
COMMAND  PID  USER  FD  TYPE DEVICE SIZE/OFF NLINK NODE NAME
tail     ...  cadet  3r  REG  ...   50000000     0  ... /labs/.../scratch/big (deleted)
```
`+L1` means "list open files whose link count is less than 1". `NLINK` is `0`.

**46.** Model answer: "The file has been unlinked but a process still has it open, so the kernel will
not free the blocks until that descriptor closes — `df` is telling the truth and so are you. Find the
holder with `lsof +L1` (or `lsof | grep deleted`). Restart or signal that process, or if you cannot,
truncate the file through its descriptor with `: > /proc/<pid>/fd/<n>` — the space comes back
immediately."

**47.** The rule from 23 applies at every level: `rm -r` must have **write and execute on each
directory it removes an entry from**. So:
```
$ mkdir -p x/inner && printf a > x/inner/f && chmod 500 x/inner
$ rm -r x
rm: cannot remove 'x/inner/f': Permission denied
```
rc 1. Every file is owned by the student and `x` itself is writable; the unwritable *inner* directory
stops the recursion, and `x/inner` cannot be removed either because it is not empty.

**48.** The shell expands `"$DIR"/` to the single argument `/` **before** `rm` starts, so `rm` sees a
literal `/` and the failsafe fires — that case is caught. The one that is not caught is anything that
expands to a *list*: `rm -rf "$DIR"/ *`, or `rm -rf $DIR/*` with `DIR` empty, which becomes
`rm -rf /*` — a long list of top-level entries, none of which is the string `/`. `rm` can only inspect
the arguments it is handed; by the time it can apply a failsafe, the shell's substitution has already
turned the mistake into a set of perfectly ordinary-looking paths.

## Notes for the authoring/tutor agent

- Exercise 7's rc is **0** and exercise 25's rc is **1**; both are easy to state backwards from
  memory. Have the student show `echo $?`.
- Exercise 35 exits **1** with a **two-line** message. An earlier draft of this lesson recorded rc 0;
  it was corrected against the container.
- Exercise 11 confuses almost everyone: the file `-f` still exists afterwards and `rm` printed
  nothing. Ask "how many operands did `rm` receive?" rather than explaining.
- Exercise 18: there is no single elegant glob that excludes one name in POSIX shell without
  `extglob`. Several correct answers exist; the mark is on having run `ls` first.
- Nothing in this lab needs `sudo`, and nothing should be attempted as root. Exercise 34 is safe as
  `cadet` **and** would be refused as root — the failsafe is in `rm`, not in the permissions.
