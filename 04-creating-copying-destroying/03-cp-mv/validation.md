# 04/03 — Validation: `cp` & `mv`

For the validating agent. No auto-grading. Read the log, check against the table, apply the rubric.
Many exercises depend on seeded timestamps and on `dest/` being clean; if numbers disagree, have the
student `kestrel reset 04/03` and re-run before marking anything wrong.

---

## Reference values (measured in the image)

| Thing | Value |
|---|---|
| `cp source scratch/x` | `cp: -r not specified; omitting directory 'source'`, rc 1 |
| `cp -r source dest` (dest exists) | creates `dest/source/…`; `dest/handover.txt` untouched |
| `cp -rT source dest` | `dest` becomes the tree; `dest/handover.txt` **is** overwritten |
| trailing slash on a `cp` **source** | no effect |
| trailing slash on a symlink source | `cp: cannot stat 'source/latest.txt/': Not a directory`, rc 1 |
| `mv f nosuch/` | `mv: cannot move … to 'nosuch/': Not a directory`, rc 1 |
| `mv f scratch/nosuch2` | creates a **file** named `nosuch2` |
| `cp -r` on a symlink | stays a symlink, size 23 |
| `cp -rL` on a symlink | regular file, size 36 |
| `cp -i` with `</dev/null` | prompt printed, **rc 1**, target untouched |
| `cp -n` refusing | **rc 0**, silent, target untouched |
| `cp a b dest-file` | `cp: target 'dest-file': Not a directory`, rc 1 |
| `cp -v` line | `'source/readings' -> 'scratch/rd'` — past tense, after the fact |
| `mv -v` line | `renamed 'x' -> 'y'` |
| `cp -u`, source newer | copies; `-v` prints a line |
| `cp -u`, dest newer | copies nothing, prints nothing, **rc 0** |
| plain `cp` and mode | **preserved** (0755 stays 0755, 0600 stays 0600) |
| plain `cp` and mtime | **not** preserved |
| `cp -r` and hard links | link count drops to 1; two separate inodes |
| `cp -a` and hard links | link count stays 2; one inode |
| `mv` same filesystem | inode **unchanged** |
| `mv` `/labs` → `/tmp` | inode **changes** (different filesystems) |
| `mv x x` / `cp x x` | `'x' and 'x' are the same file`, rc 1 |
| `cp -r source source/nested` | `cannot copy a directory, 'source', into itself`, rc 1 |
| `mv e f` (f empty dir) | `f/e/x` — source goes inside |
| `mv -T e f` (f empty dir) | `f/x` — f replaced |
| `mv c d` (d/c non-empty) | `mv: cannot overwrite 'd/c': Directory not empty`, rc 1 |
| `mv pnl_{01..06}.log panel-{01..06}.log` | `mv: target 'rename/panel-06.log': No such file or directory`, rc 1, **nothing moved** |
| `cp --backup=numbered` | leaves `handover.txt.~1~` |
| `mv` over a 0400 file, tty | `mv: replace 'p', overriding mode 0400 (r--------)?` |
| `mv` over a 0400 file, `</dev/null` | no prompt, move succeeds |
| `cp` over a 0400 file | `cp: cannot create regular file 'p': Permission denied` |
| `cp` over a hard-linked target | both names show the new contents; inode and link count unchanged |
| `mv` over a hard-linked target | other name keeps old contents; inodes now differ, both count 1 |
| `cp -a` and `stat` times | atime and mtime preserved; **ctime** (and `%w`) differ |
| `noclobber` | blocks `>`, rc 1; `cp` unaffected, rc 0 |
| filesystems | `/labs` = `/dev/nvme2n1p2`, `/tmp` = `overlay` |
| coreutils | 9.11 — no `--update=none-fail` |

No flag in this lesson.

---

## Per-exercise rubric

### Warmup 1–4

**Goal.** Read a directory of mixed types and see that rename and move are one operation.

**Accept.** Ex 1 naming `faults/open.txt` and `open-hardlink.txt` as the same file, and explicitly
**not** counting `latest.txt` as the same file as its target. Ex 2's exact message and rc 1. Ex 3:
different inode. Ex 4 in terms of directory entries and one inode.

**Reject.** Ex 1 calling the symlink and its target "the same file". Ex 4 answered as "because
`mv` is used for both" — that restates the question.

**Distinction.** Ex 4 notes that whether it looks like a rename depends only on whether the two
entries share a directory.

### Core 5–14 — the destination rule and the slash

**Goal.** State the three-state destination rule, and separate it from what the trailing slash does.

**Accept.** Ex 6's rule stated as a conditional on what already exists. Ex 8 must report **both**
that `dest` became the tree and that the pre-existing `dest/handover.txt` was overwritten. Ex 9: no
difference. Ex 11: the slash asserts the destination is a directory, and without it a *file* named
`nosuch2` is created. Ex 13's exact error, with the reason (resolution as a directory fails on a
symlink to a file). Ex 14: `-r` keeps the link, `-L` follows it, sizes 23 and 36.

**Reject.** Any claim that a trailing slash on a `cp` source changes the copy — rsync habits do not
transfer and the measurement says otherwise. Ex 8 answered without mentioning the overwrite.

**Red flags.** Ex 8 run without the reset: the answer will contain `dest/source/`, which means the
lab was dirty.

**Distinction.** Notices that `source/.` (ex 10) and `-T` (ex 8) reach the same result by different
routes — one changes the source, the other changes how the destination is interpreted.

### Core 15–20 — overwriting, prompting, refusing

**Goal.** See a file destroyed with no output, then measure exactly what `-i` and `-n` are worth.

**Accept.** Ex 15 must state that there was **no** warning. Ex 16: prompt printed, rc **1**, and the
conclusion that `-i` in a script is a failure, not a safeguard. Ex 17: rc **0** and `-n` as the
script-safe one. Ex 18's rule about the last argument. Ex 19: after the fact. Ex 20: `renamed`, with
the observation that it is inaccurate for the cross-device case.

**Reject.** Ex 16 or 17 with the exit statuses swapped — the asymmetry is the point of the pair. Any
claim that `-i` protects an unattended script.

**Distinction.** Points out that neither `-i` nor `-n` tells you *which* files were skipped, which is
exercise 40's problem stated early.

### Core 21–25 — `-u`

**Goal.** `-u` is a clock comparison, it is silent, and silence is indistinguishable from success.

**Accept.** Ex 22 must report **no output and rc 0**, and answer the "how would you have known"
question with `-v` or a `stat` comparison. Ex 23 needs a concrete case where mtime does not track
correctness — a restore, a `touch -d`, or a newer broken file.

**Reject.** Ex 22 reporting an error or a nonzero status. Ex 23 answered abstractly ("times can be
wrong") with no scenario.

**Red flags.** Ex 24 reporting only one file copied — an earlier exercise already overwrote one of
them; reset.

**Distinction.** Ex 23 observes that `-u` makes a *restore from backup* actively dangerous, since
restored files carry old dates.

### Core 26–29 — what survives a copy

**Goal.** Replace the folk belief with four measured facts.

**Accept.** Ex 26: **yes, mode survives**, both files. Ex 27: mtime does not. Ex 28: `-p` covers
mode, owner, times; `-a` adds recursion, symlinks-as-symlinks and hard-link preservation. Ex 29:
link count 1 after `cp -r`, 2 after `cp -a`, with the inode numbers as evidence.

**Reject.** "`cp` does not preserve permissions" — measurably false in this image and the exercise
exists to correct it. Ex 29 answered from the man page without the `stat` output.

**Distinction.** Ex 29 states that `cp -r` turns one file into two, and works out that this doubles
the disk usage of a tree that used links deliberately.

### Experiment 33–36

**Goal.** Predictions on paper, then the guards and the two `mv` cases.

**Accept.** Predictions recorded **before** the run. Ex 33: both refuse, rc 1, and ideally why the
guard has to exist. Ex 34: the exact message plus the non-termination argument. Ex 35: same inode
same filesystem, new inode across, and `/labs` vs `/tmp` verified with `df`. Ex 36: all three
outcomes, including `Directory not empty`.

**Reject.** Any Experiment answer with no written prediction, or one that matches the output
suspiciously exactly. Ex 35 asserted from theory with no inode numbers in the log.

**Distinction.** Ex 35 notes that the cross-device case is interruptible and can leave both a partial
destination and the intact source, so it is not atomic the way `rename()` is.

### Stretch 37–42

**Goal.** Idempotent copying, backups, `-t`, refusal reporting, exact reproduction, and the
`noclobber` boundary.

**Accept.** Ex 37 must end at `cp -aT` (or `source/.`) with two identical md5 sums; a student who
first hit the nesting trap and then fixed it has done the exercise correctly and should be credited
for finding it. Ex 38: `handover.txt.~1~` and `VERSION_CONTROL` as the default-supplying variable.
Ex 39 must name the generated-list case (`find -exec cp -t DEST {} +` or `xargs`). Ex 40: any method
that surfaces the skips, since `-n` will not. Ex 41: `cp -a`, plus inode numbers (or ctime) as the
thing that cannot come across. Ex 42: `noclobber` blocks `>` and not `cp`, and is a property of the
shell's redirection operator.

**Reject.** Ex 37 reported as identical without two actual runs. Ex 42 concluding that `noclobber`
is broken, or that it should have stopped `cp`.

**Red flags.** Ex 41 answered with `-rp`; that is the near-miss from help.md and misses symlinks and
link identity.

**Distinction.** Ex 42 generalises: a shell option can only constrain what the shell itself does, and
every command is free to open whatever it likes.

### Dig 43–46

**Goal.** The permission asymmetry, in-place truncation, atomic replace, and the unpreservable time.

**Accept.** Ex 43 must have both outputs — `mv`'s prompt and `cp`'s `Permission denied` — and the
explanation in terms of write-on-file versus write-on-directory, plus the observation that the prompt
vanishes without a terminal. Ex 44: the second hard-linked name shows the new contents, inode and
link count unchanged. Ex 45: `mv` swaps the directory entry, readers of the old inode are unaffected,
and therefore write-to-temp-then-`mv` is the safe publish. Ex 46: **ctime**, and that it is not
settable by any interface.

**Reject.** Ex 45 answered without the experiment from ex 44 behind it. Ex 46 answering "mtime" or
"atime" — both are preserved by `-a`.

**Red flags.** Ex 43 with only one of the two commands run; the contrast *is* the exercise.

**Distinction.** Ex 45 names the idiom (atomic replace) and states its precondition — the temporary
file must be in the same directory, because `rename()` is only atomic within a filesystem.

---

## Roll-up

**Pass** — the three-state destination rule is stated correctly; `-T` and the trailing slash are
distinguished; a file was overwritten with no warning and reported as such; `-i` rc 1 versus `-n`
rc 0 is right; mode-survives / mtime-does-not is measured rather than assumed; `mv`'s inode is shown
unchanged and then changed; both Experiment predictions are written before the runs.

**Redo** — the student asserts a trailing slash changes a `cp` source; or claims plain `cp` drops
permissions; or has `-i` and `-n` the wrong way round; or reports ex 22 as an error; or answers ex 45
without having run ex 44.

**Distinction** — exercise 37 reaches an idempotent `cp -aT` with two matching sums, exercise 43 is
argued from directory-write versus file-write permission, exercise 45 arrives at the atomic-replace
idiom unprompted, and exercise 46 identifies ctime with the reason it cannot be set.
