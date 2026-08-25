# 06/05 — Solutions: `find`, Advanced

> Tutor notes. Every number here was measured in the container. Where a student's number differs,
> check whether they reset the lab — `spool/` mtimes are relative to seed time and `scratch/`
> exercises mutate the tree.

**Chapter 6 flag (do not reveal):** `KESTREL{the_gap_is_the_message}` — lesson 07.

---

## Size

**1.** Nine files: `zero.log` 0, `one-byte.log` 1, `just-under-512.log` 511, `exactly-512.log` 512,
`just-over-512.log` 513, `exactly-1k.log` 1024, `just-over-1k.log` 1025, `three-k.log` 3072,
`forty-k.log` 40960.

**2.** `sizes/zero.log`. Rounding up means every non-empty file rounds to at least 1, so only a
genuinely zero-byte file can be `-size 0` in any unit.

**3.** Only `zero.log`. `-size -1k` is "rounds up to strictly less than 1 KiB", and a 1-byte file
rounds up to 1. The intuition "under 1024 bytes" is `-size -1024c`.

**4.** `one-byte.log`, `just-under-512.log`, `exactly-512.log`, `just-over-512.log`, `exactly-1k.log`
— five. Rule: `-size Nk` matches sizes in `((N-1)*1024, N*1024]`. For N=1 that is 1 through 1024.

**5.** `just-over-1k.log`, `three-k.log`, `forty-k.log`. `exactly-1k.log` is exactly 1024, which
rounds to exactly 1, and `+1k` demands strictly more than 1.

**6.** `-size 1c` → `one-byte.log`; `-size 512c` → `exactly-512.log`; `-size 1024c` →
`exactly-1k.log`. With `c` the unit is one byte, so rounding up to the nearest byte is the identity.

**7.** `-size -512c` → `zero.log`, `one-byte.log`, `just-under-512.log` (3). `-size +512c` →
`just-over-512.log`, `exactly-1k.log`, `just-over-1k.log`, `three-k.log`, `forty-k.log` (5).
`exactly-512.log` is in neither: it is neither strictly less nor strictly more than 512.

**8.** **Eight**, not nine — the trap. `-size +0` means "rounds up to more than 0 blocks", true of
every non-empty file, so it excludes `zero.log`. `! -size 0` also gives 8. They agree here; they are
the same set for any file, since `-size 0` is exactly "zero bytes".

**9.** `one-byte.log`, `just-under-512.log`, `exactly-512.log`. Bare `1` means one **512-byte
block**, i.e. 1–512 bytes.

**10.** `find . -type f -size +32k` → `./sizes/forty-k.log`.

**11.** `find sizes -type f -size +1k -size -3k` → `just-over-1k.log` only. Honest answer: no, it
does not mean inclusive. Rounding puts 1024 at exactly 1k and 3072 at exactly 3k, and both `+`/`-`
are strict, so both endpoints fall out. If you want inclusive bytes, use `-size +1024c -size -3072c`
and accept that those are strict too — or `! -size -1024c ! -size +3072c`.

**12.** `du` reports blocks allocated on disk; `-printf '%s'` reports the byte length in the inode.
For "how many bytes is this file", `%s`. For "how much space would I get back", `du`.

## Time, real clock

**13.** Six files, ages roughly 5 minutes, 90 minutes, 25 hours, 3 days, 8 days, 40 days.

**14.** `-mmin -60` → `run-05min.log`. `-mmin +60` → the other five. `-mmin 60` would be the file
whose age truncates to exactly 60 minutes; nothing here sits there, so no file is in neither set.

**15.** `run-05min.log`, `run-90min.log`. `-mtime 0` means the age **truncated** to whole days equals
0, i.e. under 24 hours. 25 hours truncates to 1.

**16.** `run-25h.log`. It is the only file whose age truncates to 1 — between 24 and 48 hours.

**17.** Always true. `-mtime -1` is "truncated age < 1", which is the same set as "= 0" because the
truncated age is a non-negative integer.

**18.** `-mtime +7` → `run-8d.log`, `run-40d.log`. `-mtime 7` → nothing here; it would match only
files aged 7 to 8 days. A rotation script with `-mtime 7 -delete` deletes one day's band and leaves
everything genuinely old in place — and it looks like it worked.

**19.** They stop agreeing whenever "24 hours ago" and "midnight today" fall on different sides of a
file's mtime — i.e. any time of day except exactly midnight. Concretely: run at 15:00 and a file
stamped 09:00 yesterday is `-mtime 1` by clock age but `-daystart -mtime 1` too; a file stamped
20:00 yesterday is `-mtime 0` by clock age and `-daystart -mtime 1`.

**20.** `chmod` changes **ctime** only. `stat` before and after shows Modify unchanged, Change
updated.

**21.** `spool`, `spool/run-05min.log`, `spool/run-90min.log`, `spool/run-25h.log`. The reference
file is **not** included — `-newer` is strictly greater. Note the directory `spool` itself appears;
its mtime moved when the files were created.

**22.** `find spool \( -newer spool/run-3d.log -o -samefile spool/run-3d.log \)`, or more simply
`find spool ! -newer spool/run-3d.log -prune -o -print` is *not* equivalent — the clean answer is
the `-o -samefile` form. `-samefile` compares inodes, which is exact.

## Time, fictional clock

**23.** `-mtime -7` → all ten entries: the mtimes are in 2187, so their age is **negative**, which
truncates to 0 and satisfies "< 7". `-mtime +1` → nothing, for the same reason: nothing is older
than one day.

**24.** Zero. `-newerct` compares **ctime**, and ctime cannot be forged with `touch` — it was set
when the seed script actually ran, in the present. Nothing in `deck/` has a ctime in 2187.

**25.** It detects mtimes that were set after the fact: any file whose mtime is far from its ctime
was stamped, not written.

**26.** Six: `adjustment.note`, `marker-after`, `panel-09.log`, `strain-01.log`, `strain-02.log`,
`summary.txt`. Earliest is `adjustment.note` at 04:32.

**27.** `deck/adjustment.note` (04:32) and `deck/marker-after` (04:35).

**28.** `marker-after` is stamped exactly 04:35 and is included. `-newermt A` is strict (`> A`);
`! -newermt B` is the negation of strict, so `<= B`. The window is **(A, B]** — open at the start,
closed at the end.

**29.** `deck/adjustment.note` alone. It reads: `value adjusted by hand; no entry made`.

**30.** Three: `marker-before` (04:30), `adjustment.note` (04:32), `marker-after` (04:35). The
markers exist so a student can find the boundaries of a window without being told them — they are
the "what carries the time" from the handover.

**31.** `find: I cannot figure out how to interpret ‘yesterdayy’ as a date or time`. Compare a
mistyped `-name` pattern, which silently matches nothing.

**32.** Only `-newermt '2187-06-09'` — an absolute stamp — belongs in a script. `yesterday` and
`2 hours ago` are evaluated at run time, so the same script gives different answers on different
runs and cannot be reproduced from a log.

**33.** `find deck -newermt '2187-06-09 04:30' ! -newermt '2187-06-09 04:34'` →
`deck/adjustment.note`. Its one line: `value adjusted by hand; no entry made`.

**34.**
```bash
window() { find "${3:-.}" -newermt "$1" ! -newermt "$2" -printf '%TY-%Tm-%Td %TH:%TM %p\n' | sort; }
window '2187-06-09 04:29' '2187-06-09 04:36' deck
```
Three lines. Accept any version that quotes `$1`/`$2`.

## Permission

**36.** `perms/notes.txt` and `perms/closed/inside.txt`. Exact-match flavour: the mode is precisely
0644 and nothing else.

**37.** Six entries — `perms` itself, `notes.txt`, `run.sh`, `group-write.txt`, `world-write.txt`,
`closed/inside.txt`. Rule: every bit in the argument is set, extra bits allowed. `run.sh` is 755,
which contains all of 644's bits plus the execute bits, so it passes `-644` and fails exact `644`.

**38.** `group-write.txt`, `world-write.txt`. `/` is "any of these bits", which is the only flavour
that answers "is this writable by anyone outside the owner" in one predicate.

**39.** `-perm -022` → `world-write.txt` only. `-022` demands **both** the group-write and
other-write bits; `group-write.txt` (664) has only the first.

**40.** `perms`, `perms/closed`, `perms/run.sh`. The execute bit on a directory is the **search**
bit: permission to traverse into it and resolve names inside. Without it you cannot `cd` in or stat
its contents even if you can list the name.

**41.** `perms/readonly.txt` (444). `rm` can still delete it — deletion needs write permission on the
*directory*, not the file — but it will prompt "remove write-protected regular file?" when there is
a terminal, and `-f` skips the prompt.

**42.** `find . -perm -o=w` → `./perms/world-write.txt`. Numeric equivalent: `-perm -002`.

**43.** `./perms/secret.txt` and `./owners/mode-differs.txt`. The second is the point — a mode you
associate with one directory's theme turns up somewhere else, and `find` does not care about
directory names.

**44.** Two steps: `find . -type d -perm -700 ! -perm -050 ! -perm -005` finds the directories, then
feed those to a second `find`. `find` cannot do it in one predicate because every predicate applies
to the entry being examined, not to its ancestors; there is no "parent has mode X" test.

## Ownership

**45.** The harness runs `chown -R cadet:crew` on the lab after every seed, so nothing can be seeded
with a different owner. `-user` partitions this tree into "everything" and "nothing".

**46.** No. It is a fact about the harness, not about authorship. General rule: a predicate that
returns everything or nothing has zero discriminating power and is not a finding.

**47.** A tree restored from a backup taken on another machine, or a home directory left behind after
an account was deleted: the numeric uid survives in the inode, the passwd entry does not.
`-nouser` finds exactly those, which matters for cleanup and for spotting files nobody can now
administer by name.

**48.** `find . -uid 1000 | wc -l` → **0**. `id cadet` shows uid **1005**, not 1000. Use `-user
cadet` when you mean the account and it exists; use `-uid` when the name may be unresolvable — the
two are not interchangeable and guessing 1000 is a common and silent mistake.

## Empty

**49.** `-type d -empty` → `./scratch`, `./notes/empty-dir`. `-type f -empty` → **two** files:
`./notes/empty.log` and `./sizes/zero.log`. The second is the surprise; `-empty` on a file is
identical to `-size 0` and does not care what directory it lives in.

**50.** Not empty; the command prints nothing and exits **0** (finding nothing is not an error).
"Empty" for a directory means no entries at all other than `.` and `..` — a dotfile counts.

**51.**
```bash
find . -type d -empty -print
find . -type d -empty -delete
```
Print first, read the list, then delete. Note `scratch` itself is in that list.

## `-exec`

**52.** `find: missing argument to \`-exec'`. `+` must come immediately after `{}` — the form is
`-exec cmd {} +`, and `{}` may appear only as the last argument. Fixed: `-exec echo one {} +`.

**52b.** `-exec echo {} \;` → nine lines, nine `echo` processes, one filename each. `-exec echo {} +`
→ one line, one `echo` process, nine filenames. `+` batches as many paths as fit on a command line.

**53.** `+` prints the `total` line. `wc` prints a total when it is given more than one file in a
single invocation; with `\;` each `wc` sees exactly one file and has nothing to total.

**54.** `+` prints `deck/panel-03.log:` prefixes. Same cause: `grep` prefixes filenames when it is
given more than one file argument (lesson 01, exercise 14). With `\;` every `grep` gets one file.

**55.** `find deck -type f -exec grep -H strain {} \;` — `-H` forces the prefix.

**56.** `find` substitutes `{}` once, producing one argument; `sh -c` then uses `$1` twice inside the
script. The `_` fills `$0`, which `sh -c` assigns to the script name — without it the filename would
land in `$0` and `$1` would be empty.

**57.** `rc=0`. `find` reports failure for its own errors (bad path, bad predicate), not for the exit
status of `-exec`'d commands. To detect a failure, make the command report it: `-exec sh -c '… ||
exit 1' _ {} \;` combined with `-print` and a count, or drop `find` and drive a loop over
`-print0`.

**58.** `deck/adjustment.note`. `-exec … \;` used as a test is **true** when the command exits 0, but
it produces no output of its own once `grep -q` is silent — `-print` is the action that shows the
result. Without `-print`, `find` still evaluates the test on every file and prints nothing at all.

**59.** `grep -rl adjusted deck`. Use `grep -rl` when the filter is purely content. Use the `find`
form when the filter also involves metadata (`-newermt`, `-size`, `-perm`), because `find` can
eliminate most files by `stat` alone before any file is opened — which is both faster and the only
way to express the combination.

**60.** `< rm ... scratch/ok.log > ?` and the file survives. With no terminal the read hits EOF and
`-ok` treats that as "no", so the action is skipped. `rm -i` behaves the same way, but `rm -i` is
easy to defeat with `-f` in the same command line whereas `-ok` has no such override — the safe
default is stronger, which also makes `-ok` useless in scripts.

## `-delete`

**61.** `-print` lists `scratch/a/one.log` and `scratch/a/two.log`; after `-delete` only
`scratch/a/keep.txt` remains.

**62.** It fails on `scratch/a` with `Directory not empty` and removes nothing above it. `-delete`
implies `-depth`, so it tries children first — but `keep.txt` does not match, so the directory is
still occupied when `find` reaches it.

**63.** `scratch/w` is **gone entirely**, files and directory. `-delete` was written first, so it is
the first thing evaluated on every entry; it deletes, returns true, and only then does `find` test
`-name '*.log'` against a path that no longer exists. The `-name` filter never protected anything.
There is no warning and no error.

**64.** `find scratch/w -name '*.log' -delete`. Habit: put every filter before the action, and run
the command with `-print` in the action's place first.

**65.** It prints the path and exits 0. Not a safety net: `-print` runs **after** the deletion has
already happened, so what you are reading is a receipt, not a preview.

**66.** `find scratch/tree -delete` removes the whole tree. The implied `-depth` is required, not
convenient: `find` must read a directory's entries to descend into it, so removing the directory
before its children would make the children unreachable — and `rmdir` on a non-empty directory fails
anyway.

## Awkward names

**67.** `run report.log` (space — word splitting), `-summary.log` (leading dash — parsed as an
option), `two\nlines.log` (embedded newline — breaks any line-oriented pipeline), `it's.log`
(single quote — breaks `xargs` quote parsing and naive shell quoting).

**68.** `xargs: unmatched single quote; by default quotes are special to xargs unless you use the -0
option`. Only `-summary.log` was echoed before `xargs` gave up.

**69.** **Five** lines from four files: the newline inside `two\nlines.log` is printed as a newline.
Not `xargs`'s fault — `echo` is faithfully printing a name that genuinely contains a newline, and
your terminal has no way to show the difference.

**70.** `[run report.log]`, `[-summary.log]`, `[it's.log]`, and one bracketed name split across two
lines. `while read` splits on newlines, so any name containing one is silently cut in half — the
loop then operates on two paths that do not exist. Use `read -d ''` with `-print0`, or `-exec`.

**71.** `find awkward -type f -exec echo {} +` prints all four names on one line, correctly. Better
than `-print0 | xargs -0` because there is no pipe, no second program's quoting rules, and no
opportunity for the stream to be reinterpreted; it also fails loudly if the command is wrong.

**72.** `rm -- ./-summary.log` or `rm ./-summary.log`. `find scratch -name '-summary.log' -delete`
never had the problem, because the name is an argument to `-name`, not to a command that parses
options.

## `-printf`

**73.** `6861643200.0000000000` for `deck/panel-03.log` — seconds since the epoch for 2187-06-09
04:00. It is far greater than `date +%s` because the file claims to be modified in the future. Any
mtime greater than now is, by itself, proof of a set clock or a `touch`.

**74.** `find sizes -type f -printf '%s\t%f\n' | sort -rn`.

**75.** `%p` `deck/adjustment.note` (path as `find` walked it), `%f` `adjustment.note` (base name),
`%h` `deck` (the directory part).

**76.**
```bash
find . -type f -newermt '2187-06-09 04:00' ! -newermt '2187-06-09 05:00' \
    -printf '%TH:%TM %p\n' | sort
```
Four lines: `04:30 marker-before`, `04:32 adjustment.note`, `04:35 marker-after`, `05:00
panel-09.log`. Note `panel-09.log` at exactly 05:00 is included — the closed end again.

## Experiment

**77.** Any size from 1 to 1023 bytes disagrees (`-size 1k` matches, `-size 1024c` does not). They
agree only at exactly 1024 bytes.

**78.** Two files 100 seconds apart; a `-mmin` value that falls between their ages separates them,
even though both are "the same day" and both are `-mtime 0`. Demonstrates the underlying comparison
is in seconds and only the reported unit is coarse.

**79.** `touch -d` a file, note `-newer` against a reference; `chmod` it; `-newer` still gives the
same answer, `-cnewer` now includes it. mtime is contents, ctime is the inode.

**80.** Both give `deck/adjustment.note` (and `marker-after`, which is empty, so `grep -l .` drops
it). Time-first is cheaper: `find` eliminates 54 of 56 entries with `stat` alone and opens two files.
Grep-first opens every file in the tree and only then discards on metadata.

## Stretch

**81.** "For every file over a kilobyte, count its non-empty lines, then sort by that count
descending and show the top three." The sort key is **wrong** for `-t:` unless every path is free of
colons and `grep -c` output is `path:count` — check `find … -exec grep -c . {} +` output format
before trusting `-k2`.

**82.**
```bash
find spool -type f -name '*.log' -mtime +7 -print          # dry run, read it
find spool -type f -name '*.log' -mtime +7 -delete
```
Two dangers in the naive version: `-mtime 7` instead of `+7` (deletes one day's band, silently), and
putting `-delete` before the filters (deletes everything, silently).

**83.** `find . -type f -exec grep -q adjusted {} \; -print -quit` → `./deck/adjustment.note`. You
know it stopped because only one path is printed even though `-quit` was reached before the rest of
the tree was walked; compare with the same command without `-quit`.

**84.** Safer: `find`'s glob is matched by `find` against each name, so an unexpanded `*` never
reaches a command, and there is no argument-length limit and no leading-dash parsing problem.
Worse: `find` recurses by default, so a pattern you tested in one directory silently applies to every
directory beneath it, and `rm *.log` cannot do that.

## Dig

**85.** Model answer: "`deck/adjustment.note`, mtime 2187-06-09 04:32, is the only file in the tree
written between 04:30 and 04:34. It reads `value adjusted by hand; no entry made`. It does not say
who adjusted what, which value, or under whose instruction, and nothing else in the tree does
either." Mark down any answer that names a person.

**86.** Evidence: the surrounding files cluster at 04:00 and 05:00, and there is a single stamp
between them. `find deck -printf '%TH:%TM %f\n' | sort` shows the cluster and the outlier without
any prior knowledge of a window. Confidence: you can say precisely when the file was stamped; you
cannot say the gap was the only gap, because a deleted file leaves no mtime at all.

**87.** Every entry in `deck/` has a 2187 mtime and a present-day ctime, so `find deck -newerct
'2187-01-01'` returns nothing while `find deck -newermt '2187-01-01'` returns everything — mtimes in
the future of their own ctime. A careful person would set the system clock rather than use `touch`,
which moves ctime too; `find` alone could not then catch it, and you would need an external
reference — a log on another host, a package mtime, a git commit date.

**88.** Expected answer: from *this* lesson, `-newermt A ! -newermt B` to isolate what was written
during the gap (and `-printf '%TH:%TM'` to find where the gap is). Still needed from `grep`: reading
the entry numbers out of the log and noticing they skip — a content question `find` cannot ask.

---

## Authoring notes

- Exercise 8 (`-size +0` = 8) and exercise 48 (`-uid 1000` = 0) are deliberate "count it yourself"
  traps. Students who assert the number in the question without running it get both wrong.
- Exercise 52's error (`find: missing argument to \`-exec'`) is real and was found while measuring;
  `-exec echo one +` without `{}` does not work.
- Exercise 45's answer is a property of the harness (`kestrel run_setup` chowns the lab after every
  seed), not of the story. Say so plainly if asked.
- The `04:30`/`04:34` window in exercise 33 is the exact skill lesson 07's incident needs. If a
  student cannot build it, do not give the command — ask them what `! -newermt` means on its own.
