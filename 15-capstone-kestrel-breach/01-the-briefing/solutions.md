# Solutions — The briefing  ·  AGENT EYES ONLY

**Student: do not open this file.** Reading it does not make you a sysadmin; it
makes you a person who has read a file. The tutor agent may read it to know
where it is steering and must never quote from it.

No flag in this lesson. The chapter's flag is in `05-report`.

---

## A. Warmup

1. **Rule 7.** "A conclusion you cannot source is struck from the report,
   however correct it happens to be."
2. **Rule 3** — record the hash before you touch anything; a hash taken after
   your first edit proves what you made, not what you found.
3. `stat -c '%n %s %y' brief/handover/notes.txt` → **6 bytes**, mtime
   **2187-05-24 04:12:00**. (The six bytes are `later\n`.)
4. The word `later` and a newline. That is the entire handover.
5. `0bd7226e…` (full:
   `0bd7226ea868984d97d517ccc35c0bc9a04d93e81c5a25b6c8eaded088626944` — hash is
   deterministic; accept whatever `sha256sum` prints, the point is that they
   recorded it).
6. **2187-09**, and **61 of 94 crew** berth on deck 3.

## B. Core — sourcing an artefact

7. `644 cadet crew 2145` — mode `rw-r--r--`, owner `cadet`, group `crew`,
   2145 bytes.
8. `stat -c '%Y' station/summariser/run.log` → `6860253600`. `%Y` is mtime as
   seconds since the epoch; `%y` is the human string.
9. `ac781cb71c8e614f6ce42f8881d1a75a0361ae3e81248dc199f039334f565ea9`.
10. The symlink. `stat -c` reports it fine (27 bytes — the length of the target
    path string), but `sha256sum` fails:
    `sha256sum: station/mounts/raw-strain: No such file or directory`, exit 1.
11. `sha256sum` **dereferences** — it opens the path and reads what it lands on.
    For a symlink that means the target's bytes, not the link's. The target
    `/mnt/eng-archive/strain/raw` does not exist, so the open fails. Accept any
    answer that has "it followed the link and there was nothing at the end".
12. `artefact`, `bytes`, `mtime`, `sha256`, `says`, `means`. The last two are
    the split.
13. Any correctly filled file. The four facts must match exercises 7–9.
14. **Exit 4** — `roe-check: field still holds a placeholder`. (Not 3: the
    fields are all present, they just still contain `<…>`.)
15. Still **4** — `means` is still a placeholder.
16. **0**, `roe-check: ok`.
17. **Exit 5**, `roe-check: sha256 is not 64 hex characters: <63-char string>`.
18. **Exit 6**, `roe-check: artefact path does not exist: …`.
19. **Exit 3**, `roe-check: missing field: mtime`. Different from 17 because 3
    is "the field is not there at all" and 5 is "the field is there and its
    value is wrong shape". A checker that collapsed those two would be less
    useful, and saying so is the better answer.

## C. Core — the three sample artefacts

20. **26**.
21. `2187-05-12 02:00:03` through `2187-05-24 02:00:28`.
22. **No date is missing.** Thirteen consecutive days, two lines each.
    Acceptable checks: `awk '{print $2}' … | sort -u | wc -l` → 13, or
    `cut -d' ' -f2 … | uniq | wc -l`. Reject "I looked at it" for full credit
    on a chapter-15 exercise; the point of the capstone is showing the work.
23. `sed -n 's/^seq=\([0-9]*\).*/\1/p'`, or `cut -d= -f2 | cut -d' ' -f1`, or
    `awk -F'[= ]' '{print $2}'`. Any is fine. `grep -o 'seq=[0-9]*'` also
    works. What matters is that it is extracted, not eyeballed.
24. Gap found by comparing consecutive numbers — e.g.
    `awk -F'[= ]' 'NR>1 && $2 != prev+1 {print prev, $2} {prev=$2}'`, or by
    diffing against `seq 412 443`. Both are accepted.
25. **Six** records missing — 0432 through 0437 — between
    `seq=0431 2187-05-21 02:00:31` and `seq=0438 2187-05-22 02:00:03`.
26. Model answer:
    > **says:** `station/summariser/run.log` contains 26 lines covering every
    > day from 2187-05-12 to 2187-05-24 with no missing date, and its `seq=`
    > numbers run 0412–0431 and then resume at 0438.

    Must contain 26, the date range, and 0431/0438. Must not say "deleted" —
    the file does not record a deletion, it records an absence.
27. Model answer:
    > **means:** six numbered records that this log once assigned numbers to are
    > not present in it.

    Accept anything of that shape. Reject naming a person, and reject any
    sentence asserting *who* removed them or *why* — nothing in this artefact
    supports either.
28. Symbolic link (`l` in the first column of `ls -l`), pointing at
    `/mnt/eng-archive/strain/raw`.
29. `cat: station/mounts/raw-strain: No such file or directory`, exit 1.
30. `test -e` → **1**: `-e` follows the link and the target is not there.
    `test -L` → **0**: the link itself exists and is a link. The pair is the
    cleanest possible demonstration that a dangling symlink both exists and
    does not, depending on which question you asked.
31. `stat` reports the link (27 bytes, type "symbolic link"). `stat -L`
    dereferences and fails:
    `stat: cannot statx '…/raw-strain': No such file or directory`.
32. **Six** files, **710400** bytes total (6 × 118400). Header says
    `# copied 2187-05-17`, source `/mnt/eng-archive/strain/raw/2186`.
33. No. `find . -name 'raw-2186-*'` returns nothing. Accept `ls` of the paths,
    or a loop over the manifest's first column testing `-e`. The strongest
    answer notices that the manifest's source path is the same tree the
    dangling symlink points into.
34. Two more claim files, both exit 0 from `roe-check`. **The symlink claim is
    the interesting one**: `sha256sum` cannot hash it, so a student who wrote a
    64-hex value there has hashed something else. The honest options are to
    hash the link's *target string*
    (`readlink station/mounts/raw-strain | tr -d '\n' | sha256sum`) and say so
    in `says`, or to hash the containing directory listing. Either is accepted
    **if the claim states which**; a bare hash with no explanation is the
    failure mode to catch. This exercise is deliberately a little unfair, in
    the way the job is.

## D. Experiment

35. Prediction usually: "the link's own bytes". **Reality: the target's
    contents.** `sha256sum real.txt link.txt` prints the *same* hash twice.
    `sha256sum` has no `-h`/`--no-dereference`; it opens the path.
36. Plain `cp` gives the copy the **current** time; `cp -p` (or `-a`) preserves
    the original's mtime. Bears on rule 5: you preserve timestamps by not
    writing to the original, and if you must copy, you copy with `-p` and say
    in the claim that the mtime you quote came from the original.
37. **Exit 0.** A well-formed claim about the wrong file passes. The lesson: a
    format checker proves form and nothing else, and every checker the student
    writes for the rest of this chapter has the same ceiling. Students who
    answer "it would catch it" have not run it.
38. `stat` changes nothing. `cat` **does not change mtime**; it may change
    **atime** (`%x`). On this container atime updates are `relatime`, so the
    first `cat` after an mtime-newer atime does move `%x` and a second `cat`
    immediately after may not. Accept any answer that says mtime is untouched
    by reading and correctly identifies atime as the one that can move; a
    student who observed no atime change and explained `relatime` gets full
    credit and should be told they are right.
39. `wc -l` counts newlines, so a file ending `a\nb` reports **1** while
    `grep -c .` reports **2**. The run log **does** end with a newline: `wc -l`
    and `grep -c .` both say 26, and `tail -c 1 … | od -c` shows `\n`.
40. **Same hash.** Content is the only one of the four facts that the hash
    describes; name, size and mtime are all metadata, and size is implied by
    content but does not identify it.

## E. Stretch

41. `find station -newermt '2187-05-01' ! -newermt '2187-06-01' -printf '%T+ %p\n' | sort`
    → `station/audit` and `MANIFEST.txt` (05-17 23:51), `station/mounts` and
    `raw-strain` (05-22 21:40), `station/summariser` and `run.log`
    (05-24 02:00).
42. `find station -newermt '2187-05-17' ! -newermt '2187-05-18' …`. `-newermt`
    alone is a strictly-greater-than test with no upper bound, so it would also
    match everything later. The idiom is a `-newermt` pair.
43. e.g.
    ```bash
    find station -type f -printf '%p\t%s\t%TY-%Tm-%Td %TH:%TM\t' \
        -exec sha256sum -- {} \; | cut -f1-3 --complement ...
    ```
    Any generated result is accepted. A clean version:
    ```bash
    for f in station/summariser/run.log station/audit/MANIFEST.txt; do
        printf '%s\t%s\t%s\t%s\n' "$f" "$(stat -c %s "$f")" \
            "$(stat -c %y "$f")" "$(sha256sum "$f" | cut -d' ' -f1)"
    done > case/notes/01-index.tsv
    ```
    The symlink has no content hash — see exercise 34. A student who silently
    dropped it from the index should be asked why; a student who included it
    with a note is doing the better job.
44. `sort -t$'\t' -k3` → `station/audit/MANIFEST.txt` (2187-05-17) is oldest of
    the two hashable files; if the symlink is in the index it is 05-22, still
    not oldest.
45. `awk -F'[= ]' '$2 > 431' station/summariser/run.log` → **six** lines,
    first is `seq=0438 2187-05-22 02:00:03 …`. (Leading zeros: `awk` compares
    numerically here, so `0438 > 431` is true. A student who used string
    comparison and got the wrong answer has found a real gotcha worth writing
    up.)
46. `awk '{print $5}' … | sort | uniq -c` → 13 `start`, 13 `ok`. Balanced. An
    imbalance would mean a run that started and never reported a result — a
    different and more alarming finding than a numbering gap.
47. ```bash
    for f in case/artefacts/*.md; do
        bin/roe-check "$f" >/dev/null 2>&1; echo "$f $?"
    done
    ```
48. ```bash
    rc=0
    for f in case/artefacts/*.md; do
        if ! out=$(bin/roe-check "$f" 2>&1); then
            printf '%s: %s\n' "$f" "$out"; rc=1
        fi
    done
    exit "$rc"
    ```
49. Same (26) on the run log. They disagree on a file with no trailing newline
    (`printf 'a\nb' > x`: `wc -l` 1, `grep -c .` 2) and on a file containing
    blank lines (`grep -c .` skips them).
50. `cp -a station /tmp/work` (or `cp -rp`; `-r` alone copies symlinks as
    symlinks in GNU `cp` but does **not** preserve mtimes — verified: after
    `cp -r`, `raw-strain` is still a symlink to the same target but
    `stat -c %y` on the copies shows the time of the copy). Proof:
    `ls -l /tmp/work/mounts/raw-strain` still shows `l` and the same target,
    and `stat -c %y` on the copies matches the originals.

## F. Dig

51. `%i` inode, `%h` link count → `136880 1` (inode number varies per build;
    link count is 1).
52. `-c` appends a newline after the format; `--printf` does not, and it
    interprets backslash escapes (`\n`, `\t`) in the format string.
    Demonstration: `stat --printf '%s' file` leaves the shell prompt on the
    same line.
53. `--tag` →
    `SHA256 (station/summariser/run.log) = ac781cb7…`. And **yes**,
    `sha256sum -c` reads that format back and prints `…: OK`, exit 0. The
    symlink still fails to hash, in either format. A student who guessed "no"
    without testing is exactly the student rule 7 exists for.
54. `-newer FILE`: `find station -newer station/audit/MANIFEST.txt` →
    `station`, `station/mounts`, `station/mounts/raw-strain`,
    `station/summariser`, `station/summariser/run.log`.
55. `ls -ltr --full-time station/` — `-t` sort by mtime, `-r` reverse to make
    it oldest-first, `--full-time` for the unabbreviated stamp.
56. `%Y`. A report prefers it because it is unambiguous about timezone and
    sorts lexically as well as numerically, and because the human string's
    format changes with locale.

---

## Load-bearing

Exercises **9, 14, 16, 24, 25, 26, 27, 30, 34, 37, 40, 50** are the ones the
rest of the chapter rests on. 26/27 and 37 are the two that carry the lesson's
actual argument.
