# 05 — Solutions

**AGENT EYES ONLY.** Do not show a student a solution. Use these to check
work and to steer.

Load-bearing exercises: **12, 13, 17, 20, 23, 27, 32, 36, 37, 41, 44, 48,
50, 55, 57, 58, 63**. A student who has those has the lesson.

## A. Survey

1. Seven: `archive bin case data evidence report station`.
2. The `.bashrc` in the ops-bot home from lesson 03 — recorded as an open
   item, not fixed. (`00-carried.md` phrases it as "one open item recorded,
   not fixed".)
3. 44 files, all `.gz`. `ls archive | wc -l`.
4. 4.0K (`du -h`). Small; the interesting thing is how little is in it.
5. Oldest: `report/calibration-note.txt`, 2187-05-21 02:14. Newest: the bulk
   of the tree at 2187-06-14 07:30. `run.log` is 2187-05-24 02:00:30 and
   `handover.tar.gz` 2187-05-24 04:12.
6. `cp report/TEMPLATE.md report/report.md` — plain `cp` preserves nothing,
   which is the point; `stat` shows today's date.

## B. The run log's shape

7. 52.
8. `sed -n '1p;$p' station/summariser/run.log`.
9. `cut -d' ' -f1 station/summariser/run.log | sort -u | wc -l` → **26**.
10. The fourth field: `start` and `ok`. Same sequence, ~30 seconds apart.
11. `seq=0412` and `seq=0443`.
12. 443 − 412 + 1 = **32**. The log has 26. Six are missing. This is the
    exercise the chain turns on: the student computes a gap without having
    been told there is one.
13. ```
    cut -d' ' -f1 run.log | sed 's/seq=//' | sort -u > /tmp/have
    seq -w 412 443 | sort > /tmp/want
    comm -13 /tmp/have /tmp/want
    ```
    → 0432 0433 0434 0435 0436 0437. `seq -w` for the zero padding; without
    it `comm` compares `412` against `0412` and reports everything.
14. "Records 0432 through 0437 inclusive are absent from `run.log`."
15. Before: 0431, 2187-05-17. After: 0438, 2187-05-24.
16. Six nights: 05-18 through 05-23.
17. It begins the day *after* the first cluster (2187-05-15..17) ends and
    ends the day before the second cluster's last edit. It overlaps the
    second cluster (05-19..20). Accept either "the second" or a careful
    "it starts where the first ends and contains the second".
18. Something like: "`run.log` numbers its records without gaps; records
    0432–0437, covering the nights of 2187-05-18 to 05-23, are absent."

## C. Stage 1

19. `tar -tzf evidence/handover.tar.gz` → `handover/`, `handover/README`,
    `handover/notes.txt`.
20. `mkdir /tmp/w && tar -xzf .../handover.tar.gz -C /tmp/w`. tar prints
    `time stamp 2187-05-24 04:12:00 is ... s in the future` for each member —
    a warning, not an error; the members carry station-era mtimes and the
    container's clock does not. Exit status is still 0. Not into the
    lab tree because extracting into evidence changes evidence — new files,
    new timestamps, and a later reader cannot tell yours from the
    original's.
21. `STAGE{handover_incomplete}`.
22. No. It says `later`. A student who builds a theory on it has stopped
    distinguishing evidence from noise; say so.
23. The gap itself: six records the log lost are present in the archive. If
    one job wrote both, they would be missing from both.
24. Work out precisely which records the log is missing, then go and find
    them in the archive.

## D. Stage 2

25. `zcat archive/rec-0432.txt.gz` (or `zless`, `gunzip -c`, `zgrep`).
26. 44 records, `rec-0400` … `rec-0443`. Note the archive starts earlier
    than the log does.
27. Six. `zcat archive/*.gz | grep -c 'clamped=[1-9]'`.
28. 0432–0437 — exactly the missing set. This is the confirmation that the
    two artefacts are talking about the same six nights.
29. `zcat archive/rec-043[2-7].txt.gz`.
30. `STAGE{six_records_recovered}`, a `match=` field and a `hint=` field.
31. `STAGE{six_records_recovered}`.
32. A sha256: 64 lowercase hex characters. The length and alphabet are the
    tell. A student who says "a hash" without saying which should be pushed
    to count the characters.
33. 6+9+12+15+18+21 = **81**. It appears nowhere else. The right answer is
    "no" — and the exercise exists so that a student who *wants* it to mean
    something has to notice they are pattern-matching. (`bc` is not
    installed; `awk '{s+=$1} END {print s}'` or `$(( ))`.)
34. "Six nightly records (0432–0437) are present in the archive and absent
    from the run log."

## E. Stage 3

35. 64 characters.
36. `find . -type f ! -name '*.gz' -exec sha256sum {} + | grep <hash>` →
    `./report/calibration-note.txt`.
37. It does not *need* to — `sha256sum` will happily hash the `.gz` files
    and none of them will match. Excluding them is a speed choice, not a
    correctness one. A student who says "because you cannot hash compressed
    files" has a misconception worth correcting: you can, and the hash is of
    the compressed bytes.
38. `STAGE{ceiling_is_not_calibration}`.
39. A calibration value (a property of an instrument) and a ceiling applied
    to a reading (a property of a report).
40. `calibration`.
41. `cat: station/.calibration/second: Permission denied`, exit 1. The
    failure is on the **directory**, not the file — cadet cannot traverse
    `.calibration` at all, so the file's own `400` never comes into it.
42. `drwxr-x--- ops-bot ops`, mode 750. No bits for other; cadet is not
    ops-bot and not in `ops`.

## F. Stage 4

43. `sudo -u ops-bot cat station/.calibration/second` → `matter`. The
    account is `nologin`; `sudo -u` does not need a shell.
44. `KESTREL{calibration_matter}`. The format is `KESTREL{...}` with
    lowercase words joined by underscores — documented in the course, not in
    this lab. Do not confirm it for a student who has one half; ask which
    half they are missing and point at the exercise for it.
45. `decks`, `faults [DECK]`, `check`, plus `--help` and `--version`.
46. `faults deck-3` → `deck-3 5`, exit 0. `faults deck-9` → 
    `stationctl: no such deck: deck-9` on stderr, exit **66** — data
    missing, the same class as a missing file.
47. Exit **1**. It is a result: deck-3 has 5 faults, over the threshold of
    3. The command did its job. This is the distinction chapter 12 spent a
    lesson on and it is worth re-testing here.
48. A correct `gaps`:
    ```bash
    gaps)  [ $# -ge 2 ] || { usage >&2; exit 64; }
           [ -f "$2" ] || {
               echo "stationctl: no such log: $2" >&2; exit 66; }
           have=$(cut -d' ' -f1 "$2" | sed 's/seq=//' | sort -u)
           lo=$(printf '%s\n' "$have" | head -1)
           hi=$(printf '%s\n' "$have" | tail -1)
           missing=$(comm -13 <(printf '%s\n' "$have") <(seq -w "$lo" "$hi"))
           [ -n "$missing" ] || exit 0
           printf '%s\n' "$missing"
           exit 1 ;;
    ```
    Accept any shape that gets the exit codes right. Common errors: no
    `seq -w`, so the padding mismatches and everything is reported; using
    `exit 66` for "gaps found"; forgetting that `set -euo pipefail` will
    kill the script when `comm` output is empty if it is used in a
    condition.
49. One line in the `usage()` heredoc. A `gaps` that works but is not in
    `--help` is marked incomplete.
50. `bin/stationctl faults > /tmp/after; diff /tmp/before /tmp/after` — and
    the exit codes captured with `$?`. "It looked the same" is not a
    verification; `diff` or `cmp` or `sha256sum` is.
51. Yes: 0432–0437.
52. e.g. `grep -v 'seq=043[2-7]' ` is the wrong direction — they need a log
    whose numbering is dense. Simplest: `head -20 run.log > /tmp/dense`
    (0412–0421, no gap) → exit 0, no output.

## G. The report

53. Look for: the ceiling, the clamping, the report figures matching the
    clamped output. Reject any paragraph containing a person's name or the
    word "deliberately".
54. Must name sources. A bare list of timestamps with no files beside them
    is the failure to catch.
55. Accept: "the account `ops-bot` ran the summariser"; "edits under
    `engineering/` are owned by `rhea`, with one file owned by `dorn`"; "a
    session for `dorn` was open until 2187-05-24 04:12". Require the
    sentence that says the evidence stops at accounts, and require at least
    one named next step (rota, interview, badge log).
56. Five closures from lesson 04, plus the ops-bot `.bashrc` left alone.
57. Good answers: a checksum or signature check on the summariser, run
    nightly, which would have printed a mismatch against
    `strain-summary.orig` on 2186-10-06; or a gap check on `run.log`; or an
    alert on any clamp line reaching stderr. The requirement is that the
    control would have produced *output on a specific date*.
58. Any number is fine. Zero is suspicious — ask them to read the "Who did
    what" section again.

## H. Stretch

59. Guard before the pipeline: `grep -q '^seq=' "$2" || { echo
    "stationctl: no seq records in $2" >&2; exit 66; }`.
60. `STATIONCTL_DATA=/nope bin/stationctl decks` → `stationctl: no data
    directory: /nope`, exit 66. `:=` only supplies a default when the
    variable is unset; it does not validate.
61. `zcat archive/*.gz | paste - - - | sed 's/seq=//; s/clamped=//' |
    awk '{print $1, $3}' | sort -k2 -nr` — accept any pipeline giving
    0437 21 first.
62. Reasonable both ways. What matters is that the list is honest: the
    `.bashrc`, who was at the keyboard, whether the October change was ever
    reviewed. A student who writes "nothing" has not been reading.

## I. Dig deeper

63. `grep -l 'match=' archive/*.gz` exits **1** and matches nothing. gzip
    output is compressed bytes; the literal string is not present. `zgrep`
    decompresses first. Some students will see `grep: binary file matches`
    on other data and conclude grep "works on gz" — it does not, it just
    sometimes gets lucky on stored literals.
64. Later would mean something wrote to the file after the last record —
    truncation, an editor, an append that was then removed. Earlier is
    impossible for an append-only file unless the mtime was set by hand.
    Here they agree, which is the boring, honest case, and worth saying so
    in the report.
