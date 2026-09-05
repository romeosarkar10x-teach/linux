# Solutions — Forensics  ·  AGENT EYES ONLY

**Student: do not open this file.** No flag in this lesson. Values marked
*(varies)* depend on when the lab was seeded.

## A. Warmup

1. Evidence: `engineering/`, `station/`, `home/`. Scaffolding: `case/`, `bin/`.
   Tell them apart by mtime — the scaffolding is all `2187-06-14 07:30`, the
   date the course was handed over, and the evidence is not.
2. 17 regular files (14 evidential + 3 scaffolding), 1 symlink, 18 directories (including the lab root).
3. `May 24  2187` style — a date and a **year**, no time. `ls` drops the clock
   for anything far from now.
4. The clock, the ctime, the atime, the birth time, and the size in bytes with
   no `-h` rounding. Also that `ls -l`'s column is mtime, which `ls` never
   states.
5. **ctime**, and birth — both are the moment the lab was seeded *(varies,
   e.g. 2026-09-05)*. It tells them these files were created on their machine
   today, and that every 2187 date is a set mtime. Good students get uneasy
   here; that is the correct reaction and the readme addresses it.

## B. The three timestamps

6. `stat -c '%n %y %z' engineering/*/*` or with `find … -exec`. Accept any
   single call that produces all three columns.
7. mtime is settable and ctime is not. `touch -d` sets mtime to whatever you
   like and drags ctime to *now*, so mtime after ctime is trivially reachable.
   Innocent explanations: a `cp -a`/`tar -x`/`rsync -t` restore that reapplied
   recorded mtimes, or a clock that was wrong when the file was written and
   corrected afterwards. Reject "it proves the files were faked".
8. `Birth: 2026-09-05 10:47:47.680648389 +0000` *(varies)*. Useless because it
   is the moment of the copy, not of the original — and because `find -printf`
   cannot select on it.
9. mtime unchanged, ctime unchanged, **atime moved to now**. Worth drawing out:
   under `relatime` atime updates only when the old atime is older than mtime —
   and mtime here is in 2187, so it is always older, so atime updates on every
   single read. An accident of the lab, but a correct explanation of relatime.
10. Plain `cp`: nothing survives; the copy has all four timestamps set to now.
    `cp -a`: mtime and atime survive, ctime and birth do not — they cannot.
    This is the answer to exercise 7 in concrete form.
11. Ask for **mtime**. It could still have been produced by `touch -d`, by a
    restore from a backup, or by a copy made with `-a` from a file that itself
    had a set mtime. mtime is a claim the filesystem repeats, not one it checks.

## C. Building the timeline

12. The last block walks symlinks and prints any *dangling* one to stderr. So
    the timeline covers `-type f` only: a symlink is never in it, and a dangling
    one is only mentioned. An absence in the output is not an absence on disk.
13. `./bin/timeline . > /tmp/tl.txt` — stderr is already on the terminal. The
    line is `timeline: ./station/mounts/raw-strain: unreadable, not in timeline`.
14. ```bash
    find . -type f -printf '%T@\t%TY-%Tm-%Td %TH:%TM\t%u\t%p\n' | sort -n | cut -f2-
    ```
15. **Ten**: 2186-04-11, 2186-09-28, 2186-10-06, 2187-05-15, 05-16, 05-17,
    05-19, 05-20, 05-24, 2187-06-14.
16. Oldest: `engineering/repo.d/station.list`, 2186-04-11 09:00. Newest
    non-scaffolding: `station/var/deck3-report.txt`, 2187-05-24 06:15.
17. `bin/timeline`, `case/TEMPLATE.md`, `case/notes/00-open.md` — all
    scaffolding, all stamped at handover. They are the lesson's furniture, not
    the station's. Citing them is citing yourself.
18. Nine, with `-newermt '2187-05-15' ! -newermt '2187-05-21'`. Accept seven
    (`! -newermt '2187-05-20'`, excluding the 05-20 pair) **if** they state which
    end they treated as exclusive. Inclusivity is the exercise.
19. Any reference file dated on or just before the boundary — typically
    `engineering/audit/README.txt` (05-15 22:40). Not unique because `-newer`
    compares against that file's exact mtime, so different references give
    different boundaries; and `README.txt` itself is excluded by its own test.
20. Add `%u`. Accounts: `rhea`, `dorn`, `cass`, `ops-bot`, `cadet`.
21. Six: `engineering/audit/README.txt`, `engineering/audit/checksums-2186.txt`,
    `engineering/manifests/MANIFEST-2186.txt`,
    `engineering/repo.d/station.list`, `engineering/repo.d/third-party.list`,
    `home/rhea/toolchain.txt`. Trees: `engineering/` and `home/`.
22. `dorn` 2, `cass` 1, `ops-bot` 5, `cadet` 3.

## D. The two clusters

23. **05-15 22:40 to 05-17 23:51**, all `rhea`: `audit/README.txt`,
    `audit/checksums-2186.txt`, `repo.d/third-party.list`,
    `home/rhea/toolchain.txt`, `manifests/MANIFEST-2186.txt`.
24. **05-19 23:58 to 05-20 01:31**: `home/ops-bot/.bashrc` (ops-bot),
    `audit/checksums-2186.recheck.txt` (dorn), `home/dorn/notes-recert.txt`
    (dorn).
25. 2187-05-17 23:51 to 2187-05-19 23:58 = 48 hours and 7 minutes. Accept the
    arithmetic shown any way; reject a number with no working.
26. First: setting something up — a working directory, a checksum record, a
    manifest, an extra package source. Second: checking something — a second
    checksum run over the same files, and notes about it. Reject any sentence
    naming a purpose ("covering tracks", "auditing rhea").
27. `engineering/audit/checksums-2186.recheck.txt`, owned by **dorn**, sitting
    in a directory otherwise entirely rhea's. The significance is factual and
    limited: a second account wrote into the first account's working area.
    Anyone can, if the mode bits allow. It is a lead, not a finding.
28. Yes — 05-19 11:47, which is between the clusters, not in either. It is
    routine rota work with no connection to anything else in the lab. It is
    there so the student has to reject something on evidence.
29. Recorded, not explained. `.bashrc` sets `STRAIN_TOLERANCE=6.0` and is owned
    by an account with a nologin shell. Any student who explains it here is
    ahead of the evidence; lesson 04 is where it lands.
30. Cluster 1 earliest: `engineering/audit/README.txt`, 2187-05-15 22:40, owner
    rhea. Cluster 2 earliest: `home/ops-bot/.bashrc`, 2187-05-19 23:58, owner
    ops-bot. Note that a student who writes `checksums-2186.recheck.txt` as
    cluster 2's earliest has skipped the anomaly, which is exactly what the
    ordering is designed to catch.

## E. Comparing

31. **Two** content lines (plus the comment header, which differs as well):
    `2186-q3.dat` and `2186-q4.dat`.
32. `2186-q3.dat` changed completely — a different hash from the first
    character. `2186-q4.dat` changed by one character. A whole-hash change means
    different content. A one-character change means either different content
    (hashes have no locality — one flipped bit gives a completely different
    hash) **or** a transcription error in the record.
33. `5caf…` versus `5cef…`: position 3, `a` to `e`.
34. Either the file changed, or the *record* was mistyped. Distinguish by
    hashing the actual file: if it matches one of the two, the other is the
    error. A hash that differs in one character from another hash of real data
    is overwhelmingly likely to be a typo, because two different files never
    produce near-identical hashes.
35. `sha256sum: 2186-q3.dat: No such file or directory`, exit 1. None of the
    raw files are here. Everything in this lesson is a record about data you
    cannot see, which is the point.
36. The original prints the raw value as the reported value. The modified script
    replaces any value above 6 with `$TOLERANCE`, defaulting to 6.0. Anything
    above 6 is reported as exactly 6.0.
37. `.orig` 2186-09-28 14:22; live 2186-10-06 02:14. Seven days, eleven hours,
    fifty-two minutes apart.
38. `.orig` is **older**. That matches a backup taken before an edit. It is the
    unremarkable case, and saying so is the answer — students who force a
    sinister reading here should be sent back to it.
39. `station/summariser/strain-summary` (reads it, with a 6.0 default) and
    `home/ops-bot/.bashrc` (exports it, as 6.0). One consumes what the other
    sets. Note both mention 6.0 and the value is therefore *unchanged* by the
    export — the export changes nothing about the output today. What it changes
    is where the number lives.
40. `says`: the report states peak reported 6.0, mean 4.7, 2016 cycles and 0
    exceedances for the week ending 2187-05-24. `means`: given the summariser
    replaces values above 6 with 6.0, "0 exceedances" is consistent both with
    no value exceeding tolerance and with every excess having been clamped
    before it was counted; the report cannot distinguish these. Reject anything
    stronger. Reject "the report is falsified".

## F. Manifests and mounts

41. **None.** Zero of the six.
42. `ls -d /mnt/eng-archive/strain/raw/2186` — `No such file or directory`,
    exit 2. `test -e … ; echo $?` giving 1 is equally good.
43. 6 × 118400 = **710400** bytes. At one sample a second a year is ~31.5
    million samples, so 710 KB for a year is implausible unless these are
    summaries rather than raw samples, or the sample rate is far lower, or the
    entries are truncated records. The assumption is the exercise; any stated
    assumption with correct arithmetic passes.
44. `2186-q1.sum` and `2186-q2.sum`. Presumably summaries or checksum
    sidecars — and "presumably" belongs on a `means` line. Note the manifest has
    `.sum` files for q1 and q2 only, and the checksum file covers q1–q4; the
    asymmetry is real and unexplained.
45. A symlink to `/mnt/eng-archive/strain/raw`, 27 bytes, dangling. `cat` gives
    `cat: station/mounts/raw-strain: No such file or directory`, exit 1 —
    the error names the link, not the target, which misleads people.
46. Because `find -type f` never matches a symlink, and the stderr block only
    reports it. The responsible line is the `find "$root" -type l` loop at the
    end, and the `-type f` on the line that builds the timeline.
47. Add `-type l` to the find, or drop `-type f` and use `-printf '%T@'` — but
    `find` reports the **link's** own mtime by default (it does not follow),
    which is what is wanted. `find . \( -type f -o -type l \) -printf …`.
48. **2187-05-22 21:40** — after both clusters, before the 05-24 files. It sits
    alone.
49. `says`: `station/mounts/raw-strain` is a symbolic link, 27 bytes, mtime
    2187-05-22 21:40, containing the path `/mnt/eng-archive/strain/raw`, which
    does not resolve on this system. `means`: it cannot be hashed and its
    target's history is unavailable here. Any claim that the target once
    existed, or was removed, fails — the lab contains no evidence either way.

## G. Stretch

50. ```bash
    find . -type f ! -newermt '2187-06-14 07:29' -o -type f ! -path './case/*' ! -path './bin/*' \
      -printf '%T@\t%TY-%Tm-%Td %TH:%TM\t%u\t%p\n' | sort -n | cut -f2-
    ```
    Accept any correct exclusion; the simplest is `! -path './case/*' !
    -path './bin/*'`. Watch for `-o` precedence bugs — a student whose output
    still contains `TEMPLATE.md` has hit one.
51. ```bash
    #!/bin/bash
    set -euo pipefail
    d="${1:?usage: mine DIR}"
    find "$d" -type f ! -user "$(id -un)" -printf '%T@\t%TY-%Tm-%Td %TH:%TM\t%u\t%p\n' |
        sort -rn | cut -f2-
    ```
52. `-newerct FILE_TIME_STRING` compares **ctime** against a time. It beats
    `-newermt` whenever mtime may have been set — a file chowned, chmodded or
    written yesterday has a recent ctime no matter what its mtime claims, so
    `-newerct` finds it and `-newermt` does not.
53. Every file lands within the same fraction of a second — the seeding — so the order is
    arbitrary. Useless because ctime here records the lab's creation, not the
    station's history. That is exactly the limitation of ctime on any copied
    evidence tree, which is why forensic practice images the disk.
54. mtime and atime can be set freely with `touch -d`. ctime cannot be set at
    all by any ordinary command; it moves to now on any inode change, including
    the `touch` itself. Birth cannot be set either. So the fake looks like this
    lab looks: an mtime in the past with a ctime of today. Someone doing this
    exercise sees an inconsistency, not a date.

## H. Dig

55. Yes — all fourteen have `.000000000`, because `touch -d` with no fractional
    part sets exactly zero nanoseconds, and the three scaffolding files share
    `2187-06-14 07:30:00.000000000` exactly. Real activity does not produce
    identical nanoseconds; a set of files agreeing to the nanosecond were
    stamped, not written.
56. `%T@` is epoch seconds with a fraction (`6862087800.0000000000`); `%T+` is
    `2187-06-14+07:30:00.0000000000`. `%T+` sorts correctly with plain `sort`
    because ISO-ish fixed-width date strings are lexicographically ordered,
    which means no `sort -n` and no `cut` to strip the key.

---

## Load-bearing

Exercises **5, 7, 12, 17, 23, 24, 26, 27, 29, 35, 36, 39, 40, 45, 49, 53**.
26, 29 and 40 are where students commit the chapter's characteristic error —
naming a purpose. Do not let 40 pass with a strong reading.
