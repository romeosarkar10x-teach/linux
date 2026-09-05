# Incident 13 — Solutions

Flag: `KESTREL{manifest_says_otherwise}`

Stage tokens (progress markers only, not registered):
`STAGE{bytes-unchanged}` → `STAGE{five-days-fell-short}` → the flag.

## A. Baseline

1. Any note is fine; the hash is stable across `setup.sh` runs. The point is
   having a recorded value from before you touched anything.
2. `strain-archive-2187-06.tar.gz: OK`, exit **0**.
3. `sha256sum: strain-archive-2187-06.tar.gz: No such file or directory` and
   `FAILED open or read`, exit 1. The manifest records a bare filename, so it
   only resolves from the directory it was written in. Lesson 04, exercise 16 —
   this is a missing file, not a mismatch.
4. It proves the archive's bytes are the bytes present when `SHA256SUMS` was
   written. Nothing about who wrote it, when, or whether the archive holds what
   it should.
5. `verify`, `shortfall DIR`, `attest FILE`; exit 2 usage, 3 archive modified,
   4 audit incomplete, 5 findings wrong.
6. ```
   archive verified: bytes unchanged since export
   STAGE{bytes-unchanged}
   next: audit an extracted copy. the archive stays where it is.
   ```
7. It is rejected — `STAGE{...}` tokens are not registered with
   `kestrel flags`. They mark progress through the chain; only the
   `KESTREL{...}` at the end counts.
8. Exit **3**. `archive_unchanged()` compares the file's SHA-256 against a
   value baked into the tool, and recompressing changes the bytes even if the
   contents are identical — gzip output depends on the compressor's settings
   and on the timestamp in its header.

## B. Look without touching

9. Twenty-one entries: the directory `strain-2187-06/` and twenty day files
   under it. `tar -tzf … | wc -l` says 21, and counting the directory as a
   member is a mistake worth not making in a report.
10. Owner `0/0`, mtime `2020-01-01 00:00`. Built reproducibly, with
    `--owner=0 --group=0 --mtime` — which means the mtimes tell you nothing
    about when the data was collected. Don't build an argument on them.
11. Unchanged. `tar -t` reads; it does not write.
12. `gzip: export/console-note.txt.gz: not in gzip format`
13. `bzip2 compressed data, block size = 900k`.
14. `bzcat export/console-note.txt.gz` →
    `export produced by bay console, operator on shift`.
15. Not a finding. A file was given a `.gz` name and compressed with bzip2 —
    sloppy, harmless, and it changes nothing about the data. At most one line
    in an appendix: "`console-note.txt.gz` is bzip2, not gzip."
16. Filename, expected line count, expected sha256. Header says 144 samples
    per day at a ten-minute interval.
17. Yes: 24 × 6 = 144.

## C. The audit

18. Exit **4**: `found 0 of 20 day files under scratch`, `audit incomplete`.
19. ```
    mkdir -p scratch/x
    tar -xzf export/strain-archive-2187-06.tar.gz -C scratch/x
    ```
    `-C`. Lesson 01's tarbomb: without it you extract into your current
    directory, and here that would mean writing into `export/` if you happened
    to be standing there — which is exactly the thing you were told not to do.
20. Unchanged. Extraction reads the archive.
21. `audited 20 day files`, `short of the manifest: 5`,
    `STAGE{five-days-fell-short}`.
22. ```
    cd scratch/x/strain-2187-06
    tail -n +4 ../../../export/MANIFEST.txt | while read -r f n h; do
        c=$(wc -l < "$f")
        [ "$c" = "$n" ] || echo "SHORT $f lines=$c expected=$n"
    done
    ```
    (`tail -n +4` skips the three comment lines.)
23. `2187-06-02`, `-07`, `-11`, `-16`, `-19`. All five have **97** lines
    against an expected 144.
24. 47 samples, which at ten minutes each is 7 hours 50 minutes.
25. They stop early. `tail -1` on a short file reads `16:00:00`; a full file
    ends at `23:50:00`. Every short file stops at the same clock time, which is
    itself worth noting — a truncation at a consistent point is not random
    damage.
26. `strain-2187-06-13.log`.
27. **Yes.** All five short days match their manifest hashes exactly.
28. The hash column was computed *from the files that were delivered*,
    including the truncated ones — so it was written after the truncation. The
    line-count column says 144, which describes what was supposed to be
    collected. The two columns of one file were written at different times
    about different things, and only the count column is a specification.
    A checksum computed after the damage certifies the damage.
29. Manifest: `f2b564c9f8ca4539…`. Actual: `f2b564c98fca4539…`. Characters 9
    and 10 are transposed: `f8` against `8f`. That is a hand-copying error.
30. It is not short — 144 lines — and nothing else about it is anomalous. Its
    content is fine; the manifest's transcription of its hash is not.
31. "One transposed pair of characters in one hash is a typing mistake. The
    other nineteen lines are consistent with each other and with the archive,
    and five of them disagree with it in the same way for the same reason.
    Throwing the document out would have thrown out the finding."
32. `manifest-audit: refusing to audit inside the export directory`, exit 3.
    The tool will not let you point the audit at the evidence, because an
    audit that writes into the directory it is auditing is not one.

## D. The correlation

33. `date,deck,max_strain,clamp_threshold`. It lives in `readings/`, outside
    the export, and it was recorded by the deck rather than produced by the
    exporter. That independence is the entire reason it is usable here.
34. **6.0**.
35. `2187-06-02` (6.1), `-07` (6.1), `-11` (6.3), `-16` (6.3), `-19` (6.2).
36. They are the same five days. Every day whose maximum exceeded the clamp
    threshold is a day the export cut short, and no other day did.
37. Twenty days; five short; five at or above the threshold. The same set —
    not one containing the other, which matters: there is no short day that was
    within limits, and no over-threshold day that exported completely.
38. One in 15504 for a specific set of five from twenty. Not a number you
    build a conclusion on by itself, but combined with the truncations all
    stopping at the same clock time, it is well past coincidence. Say it that
    way in the report: state the correlation, do not claim it proves intent.
39. No. On `2187-06-02` the highest reading in the archive is **2.9**, and the
    file ends at 16:00. The readings file records a maximum of 6.1 for that
    day. On every *full* day the archive's maximum matches the readings file
    exactly — 4.7 on the 1st, 3.1 on the 3rd, 5.0 on the 20th.
40. The evidence supports: the exported files for those five days do not
    contain the samples that exceeded the threshold, and the exports stop
    before the time of day when the peak was recorded. It does **not** support
    a claim about whether those samples were collected and then removed, or
    never written to the export in the first place. You cannot tell truncation
    from a short read from this side, and the report has to say so.
41. ```
    printf '2187-06-02\n2187-06-07\n2187-06-11\n2187-06-16\n2187-06-19\nclamp threshold 6.0\n' \
        > scratch/attest.txt
    ```
42. `bin/manifest-audit attest scratch/attest.txt` →
    `attestation accepted` and `KESTREL{manifest_says_otherwise}`.
43. `kestrel flags submit KESTREL{manifest_says_otherwise}`
44. Exit **5**: `manifest-audit: the attested dates are not the short days`.
45. Exit **5**: `manifest-audit: attestation names no threshold`. The dates
    alone are an observation; the threshold is what makes them a finding.

## E. Close it out

46. Same hash as exercise 1, and `strain-archive-2187-06.tar.gz: OK`, exit 0.
47. Because it is the only thing that makes the rest of the report usable. An
    auditor who cannot show the evidence is unchanged has produced an opinion,
    not a finding — and everything else you wrote is now arguable.
48. `rm -rf scratch/x`; `ls -l export/` and the hash both unchanged.
49. "No further checks configured" is true and is the problem, not a
    reassurance. The false part is the implication carried by the whole message
    — that a passing SHA256SUMS means the export is good. `ops-bot` does not
    lie; it reports exactly what it did, and reading it as more than that is
    the mistake this incident is built on.
50. A report that says: the archive is intact and byte-identical before and
    after (hash quoted); `SHA256SUMS` passes; `MANIFEST.txt` specifies 144
    samples per day for twenty days; five days contain 97, all stopping at
    16:00; the manifest's hash column matches the delivered files including the
    short ones, so it was computed after the shortfall; one further hash line
    differs by a transposed character pair and its file is otherwise sound;
    `readings/deck-04-daily-max.csv`, recorded outside the export, shows those
    same five days and only those days at or above the 6.0 clamp threshold; on
    complete days the archive's maximum matches that file exactly, and on the
    five short days it does not. Not established: whether the samples were
    removed or never exported, who produced the export, and when.
51. "The export passes its checksum and is missing 235 samples. Please do not
    sign it off today."
52. "The archive has not been altered since its checksum was written, and I can
    show that. Whether the export was *produced* correctly is a different
    question, and the answer to that one is no."
53. "I don't know, and nothing I looked at would tell me. The export carries no
    record of who ran it."
54. The bay console's own export log — whatever recorded that the export
    completed — and the deck's raw sample store for those five days, to
    establish whether the samples exist outside the export. Ask for records,
    not people.
55. The line-count column of `MANIFEST.txt` was load-bearing: it is the only
    artefact that says what the export was *supposed* to contain. Without it
    the shortfall would still have been visible against
    `deck-04-daily-max.csv`, but you would have had to know to look, and you
    would have had no specification to measure against. The checksums, both
    the export's and the manifest's, were worth nothing here — they certified
    the damaged files perfectly.
56. "Before signing off an export, check it against a specification written
    before the export ran. A checksum only tells you it has not changed since
    somebody hashed it."
