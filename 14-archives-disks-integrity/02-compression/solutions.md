# Compression — Solutions

Measured on the station. gzip 1.14.

## A. Reading without decompressing

1. `zcat logs/telemetry-2187-06.log.gz | wc -l` → **2161**.
2. `zcat logs/*.gz | wc -l` → **3507**.
3. `zcat logs/telemetry-2187-06.log.gz | head -2`:
   ```
   # deck telemetry, 2187-06
   2187-06-01 00:00:00 deck-01 settle 2.0 ok
   ```
   `head` on the `.gz` would print compressed bytes — binary noise. The file on
   disk is not text.
4. `zgrep -c CLAMPED logs/*.gz`:
   ```
   logs/telemetry-2187-04.log.gz:4
   logs/telemetry-2187-05.log.gz:4
   logs/telemetry-2187-06.log.gz:6
   ```
5. June, with 6.
6. June: `deck-01`, `deck-04`, `deck-09`. April: `deck-09` only.
7. `zgrep -l deck-01 logs/*.gz` → only `logs/telemetry-2187-06.log.gz`.
8. `ls -l logs/` — three `.gz` files, same sizes, no `.log` files. Or
   `sha256sum logs/*.gz` before and after.
9. Yes. `zgrep -c 'record 40' scratch/records.txt` returns a count on an
   uncompressed file; `zgrep` checks the file rather than the name.
10. A directory of rotated logs usually holds today's `.log` uncompressed and
    older ones as `.gz`. `zgrep` handles both, so the script needs no `case` on
    the extension and no test that could get it wrong.
11. `q`. `zless` is `less` on a decompressed pipe, and all of `less`'s keys
    work.
12. Ordinary `diff` output — `<`/`>` lines — computed on the decompressed
    contents. `zdiff` compresses nothing and writes nothing.
13. **No.** `cmp` reports
    `logs/telemetry-2187-04.log.gz logs/telemetry-2187-05.log.gz differ: byte 47, line 1`
    and exits 1. They compress to the same 2016 bytes because they hold the same
    *amount* of equally repetitive data. Equal size is not equal content, and
    this is the same mistake a checksum exists to prevent (lesson 04).
14. `gzip -l logs/*.gz` gives a totals line: 11812 compressed, **147316**
    uncompressed. That is 144 KB — decompressing these three would have cost
    nothing at all, and saying otherwise would be dishonest. The lesson's
    argument holds when the numbers are gigabytes, which is what a real
    telemetry archive is; the technique is the same and the lab is small so it
    runs fast. Do not claim a saving you cannot measure.

## B. gzip on one file

15. No. `gzip` replaced `records.txt` with `records.txt.gz`.
16. No. `gunzip` replaced it back. Both directions consume their input.
17. `gzip -k records.txt` leaves both `records.txt` and `records.txt.gz`.
18. ```
    gzip: records.txt already exists;	not overwritten
    ```
    It refuses rather than clobbering — the opposite of `tar -x` in lesson 01,
    and worth noticing that the two tools made different choices.
19. `-1` → **9922** bytes, `-9` → **9434** bytes.
20. 488 bytes, about 5%. Not worth thinking about for one file; on a nightly
    job over gigabytes it is, and that is when the extra CPU time also starts
    to matter.
21. Compressed size 9422, uncompressed size 46893, ratio 79.9%.
22. No. It is instant on files where decompression would not be, and it can
    report the *stored* uncompressed size — a number written into the trailer —
    without producing a single byte of output.
23. It reports the size modulo 2^32, so a 5 GB file (5368709120) reports as
    about 1073741824 — a plausible 1 GB. That is worse than nothing because a
    wrong number that looks right gets used; "unknown" would have been checked.
24. Nothing, exit **0**. Silence is success.
25. ```
    gzip: data/truncated.gz: not in gzip format
    ```
    Exit status **1**.
26. `file data/truncated.gz` → `ASCII text`. `file` disagrees with the
    extension, because the extension is a claim and the bytes are the fact.
27. ```
    gzip: data/half.log.gz: unexpected end of file
    ```
    Exit status **1**.
28. `file` says
    `gzip compressed data, max compression, from Unix, original size modulo 2^32 …`
    — it agrees. `file` reads the first few bytes and finds a valid gzip header,
    which is genuinely there; `gzip -t` decompresses the whole stream and checks
    the trailer's CRC, which is missing. Put `gzip -t` in a verification script:
    `file` answers "what is this", never "is this intact".

## C. Three compressors

29. `records.txt` 46893, `.gz` 9422, `.bz2` 4916, `.xz` 1440.
30. xz smallest (3.1% of the original), bzip2 next (10.5%), gzip largest
    (20.1%).
31. `zcat`, `bzip2 -dc`, `xz -dc` into three files; `cmp` on each pair is silent
    and exits 0. All three are lossless and produce identical bytes.
32. xz. Not a fair test at 46 KB — the difference is milliseconds and is
    dominated by process startup. The ranking is real; these measurements are
    not evidence for it.
33. ```
    gzip: data/records.txt.bz2: not in gzip format
    ```
34. `bzcat` (or `bzip2 -dc`) and `xzcat` (or `xz -dc`). `bzgrep` and `xzgrep`
    exist too.
35. The `.gz` is larger: 200053 against 200000, by **53 bytes**.
36. Random data has no redundancy to remove, so gzip stores it essentially
    verbatim and adds its own header, trailer and block framing on top.
37. JPEG/PNG images and video; anything already `.gz`, `.zip` or `.xz`. Also
    encrypted files, which look random by design.
38. It costs CPU time on every file and a little extra disk, and gains nothing —
    JPEGs are already compressed. The gain is elsewhere: one `.tar.gz` is
    easier to move than 4000 files, which is an archiving win, not a
    compression one.

## D. zip, which you have to install

39. `dpkg -s zip` → not installed. `command -v zip` prints nothing, but that
    only tells you it is not on `PATH`.
40. `apt-cache policy zip unzip` → candidates `3.0-13ubuntu0.2` and
    `6.0-28ubuntu4.1`, both from `noble-updates/main` on the snapshot mirror.
41. `sudo apt-get install -y zip unzip`
42. `/usr/bin/zip` and `/usr/bin/unzip`. `dpkg -S /usr/bin/zip` names `zip`.
    Note these are the Ubuntu packages in `/usr/bin`, while most of the
    station's tools come from `/opt/kestrel/bin` (chapter 13, lesson 04).
43. Roughly the size of the `.gz` plus per-member overhead — zip compresses each
    member separately with the same DEFLATE algorithm gzip uses, so on one
    file the two are close.
44. `unzip -l` prints the uncompressed size, date and name of each member, plus
    a totals line. `tar -tzf` prints names only; `tar -tvzf` gets you the rest.
45. `scratch/unz/data/`.
46. No — it prompts:
    ```
    replace scratch/unz/data/records.txt? [y]es, [n]o, [A]ll, [N]one, [r]ename:
    ```
    `-o` overwrites without asking, `-n` never overwrites.
47. `zip` compresses each member separately, so you can extract one file without
    reading the whole archive, and it has a central directory listing at the
    end. `tar` preserves Unix ownership, permissions, symlinks and hard links,
    which zip handles poorly or not at all.
48. `sudo apt-get purge -y zip unzip`, then `dpkg -s zip` reports not installed
    and `/usr/bin/zip` is gone.

## E. Judgement

49. "You don't have to — `zgrep` searches them where they are and writes
    nothing."
50. Almost nothing. xz cannot find redundancy gzip already removed, so the
    result is roughly the same size plus xz's own framing, and you have paid
    full CPU for it. To get xz's real advantage you decompress first and
    recompress from the original.
51. `gzip -t file.gz`. It costs zero disk space — it decompresses to nothing
    and only checks the CRC — and costs the CPU time of a full decompression.
52. The file is larger than 4 GB, so the trailer's 32-bit size field has
    wrapped. `gzip -l` cannot know it wrapped, so it reports the wrapped value
    with no warning.
53. gzip will compress a file that is still being appended to, producing an
    archive of a partial file, and the writing process keeps writing to a
    filename that no longer exists — which is lesson 03's disk-space surprise.
    Rotate first, then compress the rotated file.
54. Each month stays independently searchable and independently verifiable, and
    a corrupt month costs you one month rather than the whole archive. Also
    `zgrep -l` can tell you *which* file matched, which a single concatenated
    file cannot.
55. When there is one file. `tar -czf x.tar.gz onefile` adds 512-byte headers
    and a directory structure you did not need; `gzip onefile` is the whole
    job.
56. "`gzip` eats its input — use `-k` if you want to keep the original."
