# 03/04 — Validation: Timestamps

For the validating agent. The student never sees this file. Judge the *reasoning*, not the command
spelling: many of these have several correct forms. Where an exercise asks for a written answer,
the words are the deliverable and a correct command with no explanation is not a pass.

Note throughout: the container clock reads 2026, the story reads 2187, so nearly every mtime in this
lab is "in the future" as far as `find -newermt now` is concerned. Answers that assume otherwise are
wrong for a real reason, and exercise 48 exists to surface it.

---

## Warmup

**1. Four times named**
- Goal: student separates atime / mtime / ctime / btime before being told the answer.
- Expected end state: four written guesses, kept.
- Evidence: the written guesses.
- Accept: any four-way split that assigns *distinct* meanings, even if ctime is guessed as "created".
- Reject: fewer than four; "they are all the same thing"; no written record.
- Red flags: answer matches the readme wording exactly — they read ahead instead of guessing.
- Probe: "Which of your four did you feel least sure about?"

**2. `Access` twice**
- Goal: notice `stat` reuses one word for permission bits and for atime.
- Accept: "the bracketed one is the mode, `(0644/-rw-r--r--)`; the line on its own is the last read
  time".
- Reject: any answer claiming both are times, or both are permissions.

**3. Which time `ls -l` shows**
- Accept: mtime shown; atime, ctime and btime invisible.
- Reject: "creation time"; "the time it was made".
- Probe: "How would you get `ls` to show one of the other three?" (Not required here — exercise 19
  needs it.)

**4. `--full-time`**
- Expected end state: student has seen `2187-05-22 03:14:00.000000000 +0000` versus `May 22  2187`.
- Accept: notes that `ls -l` drops the time of day for non-recent files (and drops sub-second
  entirely), and offers a reason — column width / readability.
- Reject: "it shows more decimals" with no mention of the missing time of day.

---

## Core

**5–6. `ls -lt`, `ls -ltr`**
- Expected: newest `strain-2187-05-24.csv`; oldest `strain-2187-05-19.csv`.
- Accept: either flag order, `--sort=time` spelled out, or `-t` plus `-r`.
- Reject: an answer derived from the filenames rather than the listing.

**7. Where `strain-summary` lands**
- Goal: the load-bearing observation of the whole lesson.
- Expected: it sits between `strain-2187-05-21.csv` and `strain-2187-05-22.csv` — mtime
  2187-05-21 09:30.
- Accept: states that three of the six files it claims to summarise were written *after* it, so the
  summary cannot include them; the claim is false or the summary is stale.
- Reject: "it is in the middle" with no consequence drawn. Reject any claim that the summary was
  edited later — nothing here supports that.
- Red flags: student concludes someone tampered with it. Possible, but unevidenced; ask what would
  distinguish stale from tampered. (Answer: nothing available at this point — which is itself the
  right answer.)

**8. `find -newer`**
- Expected: `logs/strain-2187-05-22.csv`, `-23`, `-24` (any order).
- Accept: `find logs -newer logs/strain-summary`, with or without `-type f`.
- Reject: any command containing a typed date — the exercise forbids it. Reject an answer of four
  files (that means they included `strain-summary` itself or used `!` wrongly).

**9–10. `stat` format strings**
- Expected: `2187-05-21 02:07:00.000000000 +0000`; epoch `6859994820`.
- Accept: `stat -c %y` / `stat -c %Y`, or `--format=`.
- Reject: `stat` with no format string and the line picked out by eye — the exercise asks for the
  format string. `%z`/`%Z` is the wrong time.

**11. One `stat`, no loop**
- Accept: `stat -c '%n %y' logs/*` — seven lines. Any format including name and mtime.
- Reject: a `for` loop; `find -exec stat \;`; one `stat` per file.

**12. Odd time of day**
- Expected: five files at 02:02–02:07, `strain-2187-05-22.csv` at **03:14**.
- Accept: names 05-22 and notes it is an hour off the nightly pattern.
- Reject: naming `strain-summary` — it has no date in its name and is not one of the six.
- Probe: "Anything else about 05-22 you have already noticed?" (Its strain value, 0.71, is the peak.
  Not required, but a strong student connects them.)

**13. `%y` vs `%z` a century apart**
- Accept: mtime was *set* to a 2187 value by whatever seeded the file; ctime records the real moment
  the inode was written, which was today; ctime cannot be backdated, so the gap is expected.
- Reject: "the clock is wrong"; "it is a bug"; any answer that does not name which of the two is
  settable.

**14. Shared ctime**
- Accept: the moment `setup.sh` created/stamped the lab.
- Reject: "when the files were written in 2187".

**15–17. relatime in action**
- Expected: `warm.txt` atime does **not** move on repeated `cat` (a=2187-06-01 is newer than
  m=2187-05-22). `cold.txt` atime moves on **every** read (m=2287 is newer than atime).
- Accept for 17: "atime only updates when the stored atime is older than mtime/ctime".
- Reject: "reading never updates atime" (false — cold.txt disproves it); "the lab is broken".
- Red flags: student never reset and is reading atimes their own earlier commands moved. Ask them to
  reset and redo.

**18. The mount option**
- Expected: `relatime` in `/dev/nvme2n1p2 /labs ext4 rw,relatime 0 0`.
- Accept: names `relatime` and states the rule (update if atime older than mtime or ctime, or older
  than a day), plus the reason — otherwise every read costs a write.
- Reject: naming `rw`; naming `noatime` (not what this mount says).

**19. Sort by atime**
- Expected: `warm.txt` on top (2187-06-01), `cold.txt` below (today, 2026) — the **opposite** of
  `ls -lt`, where cold.txt's 2287 mtime puts it first.
- Accept: `ls -ltu reads` or `ls -lt --time=atime reads`, with the reversal noticed.
- Reject: `ls -lu` without `-t` and a claim about ordering — that sorts by name.

**20–21. Hard links share timestamps**
- Expected: same inode, `Links: 2`; touching the alias moves `panel-07.txt`'s mtime to 2100-01-01.
- Accept: "the timestamps are in the inode, and both names point at that one inode".
- Reject: "touch followed the link" — there is no link to follow; both are real names.
- Probe: "How many sets of timestamps exist on disk for these two names?" Answer: one.

**22–23. chmod and mv**
- Expected: `chmod` moves **ctime only**; `mv` within the same directory moves **ctime only** as
  well. mtime stays 2187-05-24 04:12 throughout; atime untouched.
- Accept: explains that both changed the inode (mode bits; link count/name bookkeeping) without
  changing the bytes, and ctime is the inode's own clock.
- Reject: "mv changed mtime"; "renaming does not touch the file at all" (it moved ctime — that is
  the finding).
- Red flags: student measured with `ls -l` only and therefore saw nothing change. Push them to
  `stat`.

**24. Setting ctime**
- Accept: `touch` has no option for it; there is no system call to set ctime; it is always "now".
- Reject: any claimed command that does it. If they produce one, ask them to show the before/after
  `stat` — it will not.

**25. Two histories for old mtime + new ctime**
- Accept any two genuinely different plausible causes, e.g.: someone ran `touch -d` to backdate it;
  it was restored from a backup or archive that preserved mtime; a `chmod`/`chown`/rename happened
  today on a genuinely old file.
- Reject: two rewordings of the same cause; "someone tampered with it" as both answers.
- Probe: "Which of your two could you rule out with information available in this lab?"

**26–28. `cp` vs `cp -p`**
- Expected: `plain.csv` mtime = now (2026); `kept.csv` mtime = 2187-05-22 03:14; **all three**
  ctimes recent — `source.csv`'s ctime is the seed time, the copies' are now.
- Accept for 28: ctime cannot be set at all, so `-p` has nothing to set it with; writing the copy
  necessarily stamped it.
- Reject: "-p preserves everything".

**29. The other difference**
- Expected: group. `plain.csv` is `cadet cadet`; `source.csv` and `kept.csv` are `cadet crew`.
- Accept: new files get the creating user's primary group; `-p` copies ownership across.
- Reject: naming the size or the mode (both identical here).
- Red flags: student did not look past the timestamp column. Ask them to read the whole line.

**30. Backup restored with plain `cp`**
- Accept: every mtime is the restore time, so date ordering is destroyed and `ls -lt` orders by an
  event that has nothing to do with the data; use content, a checksum, a manifest, or the backup's
  own metadata instead.
- Reject: "use ctime instead" — ctime is equally the restore time.

**31–33. `touch -r`**
- Expected: `refs/one.txt` mtime becomes `2187-05-24 04:12:00`; then two and three likewise, in one
  command (`touch -r refs/anchor.txt refs/two.txt refs/three.txt`).
- Accept: `-r`, also spelled `--reference=`.
- Reject: any typed date; running `stat` first and pasting the value into `-d` (that is exercise 47,
  and doing it here fails the "without typing a date" constraint).
- For 33: atimes match too — `-r` copies both times. Accept "yes, because `-r` sets atime and mtime
  unless `-a`/`-m` narrows it".

**34–37. Directory mtime**
- Expected: appending to `torque.txt` leaves `stamps/bay-2` at 2187-05-30 07:45; creating
  `new.txt` sets it to now; deleting `new.txt` sets it to now again.
- Accept for 37: a directory's mtime tracks changes to its *entry list* — names added, removed or
  renamed — not the contents of the files listed.
- Reject: "directories do not have mtimes"; "it changes whenever anything inside changes".
- Probe: "If a file inside is edited every hour for a year, what does the directory mtime say?"
  (Unchanged since the file was created.)

**38–39. Birth**
- Expected: `birth/first.txt` btime == mtime == seed time (created, never re-stamped).
  `refs/anchor.txt` btime = seed time (2026), mtime = 2187-05-24 (set afterwards).
- Accept for 39: **btime** is the honest one about existence on this volume; mtime was assigned.
- Reject: choosing mtime; claiming btime is unreliable *here* (it is reliable here — it is
  unreliable in that many filesystems do not have it and `stat` then prints `-`).
- Bonus, not required: student tries to change btime and finds no way to.

---

## Experiment

Each of these requires a **written prediction before running**. No prediction on record = no pass,
even if the observation is correct. Do not evaluate the prediction for correctness — evaluate
whether they wrote one and then reconciled it with what happened.

**40. `touch -c`**
- Expected: nothing created; `ls: cannot access 'nosuch.txt': No such file or directory`.
- Accept: reconciliation naming `-c`/`--no-create` as "update if it exists, otherwise do nothing".

**41. `touch -h` on a symlink**
- Expected: `stat reads/lnk` shows 2187-01-01 (the link's own inode); `stat -L reads/lnk` still
  shows the target's 2287-01-01. The target was not touched.
- Accept: "`-h` acts on the link itself, which is a file with its own inode and its own times".
- Reject: "symlinks have no timestamps".

**42. `touch -d '2999-01-01'`**
- Expected: `stat -c %y` reports **2446-05-10 22:38:55** — silently, with no error.
- Accept: identifies the cause as ext4's fixed-width on-disk timestamp field saturating; credit any
  answer that lands on "the filesystem cannot store that value and clamped it".
- Reject: "touch rejected it" (it did not — exit status 0, no message); "the date wrapped to 1970".
- Red flags: student never checked the result and assumed success. This is the point of the
  exercise; make sure they ran the `stat`.
- Probe: "Did `touch` tell you anything was wrong? What does that mean for a script that trusts it?"

**43. `cat >` into a file**
- Expected: mtime and ctime both move to now; atime does not (a write is not a read; and the
  truncating open does not read).
- Accept: explains that mtime cannot move without ctime moving, because the inode changed.
- Reject: claiming atime moved without showing a before/after that supports it.

---

## Stretch

**44. Newest file under the lab, no `ls`**
- Expected (clean lab): `./reads/cold.txt` — mtime 2287-01-01, the newest thing in the tree.
- Accept: `find . -type f -printf '%T@ %p\n' | sort -n | tail -1`, or a `stat`-based equivalent, or
  `find -newer` chained. Any approach that does not shell out to `ls`.
- Reject: an answer of a `logs/` file — that means they searched only one directory. Reject
  `refs/three.txt` unless they are working in a lab left dirty by exercise 42; if so, ask them to
  reset and rerun.
- Red flags: `ls -lt` piped into `head` — explicitly excluded.

**45. Between two anchors**
- Expected: `refs/anchor.txt`, `meta/panel-07.txt`, `meta/panel-07-alias`, `meta/moved.txt`,
  `reads/warm.txt`, `logs/strain-2187-05-22.csv`, `-23`, `-24`, `copies/source.csv` — nine paths,
  any order.
- Accept: `find . -type f -newer logs/strain-summary ! -newer refs/anchor.txt`.
- Reject: any typed date; a two-command pipeline diffing two `find` outputs is inelegant but
  acceptable if they explain it — the exercise says `find` alone, so prefer the single expression.
- Note: `refs/anchor.txt` is in the set because `! -newer anchor` is true of anchor itself.

**46. Full timestamps, oldest first**
- Expected: seven lines, `strain-2187-05-19.csv` first, `strain-2187-05-24.csv` last, timestamps
  like `2187-05-19 02:04:00.000000000 +0000`.
- Accept: `ls -l --time-style=full-iso -tr logs`, or `--sort=time -r`, or a `find -printf`/`stat`
  formulation that produces timestamp-and-name only.
- Reject: `--time-style=full` or `--sort=mtime` — neither is a value `ls` accepts (the near-miss in
  `help.md`). Reject output still carrying mode/owner/size columns *if* they claimed to have
  stripped them; `ls -l` keeping them is fine as long as the sort and format are right and they say
  which part answers the question.

**47. Copy a timestamp the long way**
- Expected: `refs/four.txt` mtime `2187-05-24 04:12:00`, matching `anchor.txt` exactly.
- Accept: `touch -d "$(stat -c %y refs/anchor.txt)" refs/four.txt`, or via `%Y` and `-d @seconds`.
  Proof by `stat -c %y` on both, or by `find -newer`/`! -newer` returning it.
- Reject: use of `-r` — the exercise forbids it. Reject a match only to the minute.

**48. Future mtimes**
- Expected: `find . -newermt '2187-06-14'` returns `refs/one.txt`, `refs/two.txt`, `refs/three.txt`
  (all 2187-06-14 08:00, i.e. later that day) and `reads/cold.txt` (2287-01-01).
- Accept: correct use of `-newermt`; the interesting one is `cold.txt`.
- For the second half: `-newermt now` returns essentially every file in the lab, because the
  container clock is 2026 and the story is set in 2187 — "in the future" is meaningless unless you
  say *future relative to what*.
- Reject: answering only the `now` half; failing to notice that `now` matches ~19 files.
- Probe: "Which reference point does a real investigator use, and where do they get it?"

---

## Dig

**49. Nanosecond precision**
- Expected: two files from one `touch b1 b2` share an **identical** mtime to the nanosecond.
- Accept: `touch` resolved the time once and applied it to both — one timestamp, two files; the
  nanosecond field has resolution far finer than the events being recorded.
- Reject: "they differ by a few nanoseconds" without output showing it; if their output genuinely
  differs, ask how they created the files (two separate commands would explain it).

**50. Why `touch` comes last in `setup.sh`**
- Expected: `chmod` and `chown` move ctime, and any `touch` after them would still leave ctime as
  "now" — but running them *after* the `touch` calls would be harmless for mtime and pointless for
  ctime, so the real answer is narrower than "it would break".
- Accept: the honest reading — ordering does not affect mtime/atime at all, because `touch` sets
  those explicitly; it affects nothing about ctime either, since ctime is "now" in both orders. What
  the ordering documents is *intent*: the author wanted the last inode write to be the timestamp
  write. Credit a student who works out that reversing it would in fact change nothing observable
  and says so.
- Also accept the stronger, correct catch: `chmod 600 meta/panel-07.txt` before the `touch` means
  the touch is done as root on a 600 file — fine here; after a `chmod 000` it would matter, which is
  the general reason the convention exists.
- Reject: confidently asserting that mtime would be wrong. Ask them to test it in `/tmp`.
- Red flags: student did not read the file. The path is given in the exercise.

**51. atime mount options**
- Expected: at minimum `noatime` (never update), `nodiratime` (skip directories), `relatime`
  (default rule), `strictatime` (always update), `lazytime` (defer writes to disk).
- Accept: for each, a forensic trade-off — `noatime` destroys read evidence entirely; `strictatime`
  preserves it at the cost of a write per read; `relatime` gives you "read since last write?"
  reliably and a precise last-read time only sometimes; `lazytime` can lose recent updates on an
  unclean shutdown.
- Reject: a list with no trade-offs; inventing options not in `man 8 mount`.

---

## Added exercise (52)

**52.** Must name **birth time** and both format specifiers (`%w`, `%W`). The before/after must be
explicit about all four: mtime set, atime set, ctime now, birth unchanged. The reason `touch` has no
option for it is the marking — a value written once by the kernel is worth something precisely
because no interface rewrites it; "touch just doesn'''t support it yet" is wrong and should be
corrected.

Both `find` lines must be quoted, including `invalid predicate`. A clean pass explains the split:
`stat` reports what `statx` says about *this file on this filesystem*, `find` reports what this build
supports *at all*. The filesystem must be named (`overlayfs` in the container) — an answer that omits
it has skipped the part that makes birth time untrustworthy.

**Distinction.** Noticing that `cp` gives the copy a new inode and therefore a new birth time, so the
timestamp does not survive being copied.

**Red flag.** Presenting birth time as the reliable one because "it cannot be forged". It cannot be
set through `touch`; it can be absent entirely, and a fresh copy of a file carries a fresh one. It is
the least portable timestamp here, not the strongest.

## Roll-up

The student has finished this lesson when they can, unprompted:

1. Name which of atime/mtime/ctime a given operation moves, **and check it by measurement** rather
   than by assertion — the before/`stat`, one command, after/`stat` habit from `help.md` L4.
2. Explain that ctime is not settable and say why that makes it the more trustworthy of the two when
   the two disagree.
3. Read an old-mtime/new-ctime pair as *evidence that something happened*, while refusing to state
   which of several possible histories caused it (exercise 25).
4. Say what `ls -l` shows, what it hides, and how to make it show the other times — including that
   `-t` sorts by whatever is displayed.
5. State the relatime rule and, from it, say what atime can and cannot be trusted to tell them.
6. Say what a directory's mtime measures and what it does not.
7. Explain why a `cp`-restored tree cannot be sorted by date afterwards.

Fail the lesson — do not wave it through — if the student finishes still believing any of:

- ctime is "creation time";
- `ls -l` shows when a file was made;
- reading a file always updates atime;
- `touch` can set all the times;
- editing a file changes the mtime of the directory it lives in;
- timestamps belong to a filename rather than to an inode.

Item 3 is the one that carries into `06-incident-03` and, eventually, into the sabotage arc. A
student who has learned to say "this mtime was set today, and I cannot yet tell you by what" is
ready. A student who leaps to "someone tampered with it" has learned the wrong habit and should be
sent back to exercise 25.
