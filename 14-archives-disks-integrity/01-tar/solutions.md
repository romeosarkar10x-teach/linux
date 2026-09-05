# tar — Solutions

All output measured on the station. GNU tar 1.35.

## A. Listing

1. `tar -tf archives/deck-logs-2187.tar | wc -l` → **14**: the top directory,
   the README, three deck directories, nine logs.
2. Identical. `tar -tzf` works, but `-z` is not needed — since tar 1.15 the
   compression is detected when reading.
3. `-v` adds the mode string, owner/group (`0/0` here), size in bytes, and the
   mtime. Any three of those.
4. No. `-t` opens the archive read-only. Prove it by hashing the archive before
   and after (`sha256sum`), or by `ls -l` on the directory — nothing new
   appears.
5. Yes: `tar -tf archives/hatch-tally.tar.bz2` lists four entries.
6. Yes. `-j` is redundant on read and correct, so nothing changes.
7. Nine members, **zero** directories — `tar -tzf ... | grep -c /` returns 0.
8. No top-level directory. Extracting it in your home directory would drop nine
   loose files (`settle.conf`, `hatch.conf`, `deck.conf`, `report.tsv`,
   `notes.txt`, `a.log`, `b.log`, `c.log`, `MANIFEST`) directly into it,
   overwriting anything with those names.
9. Four: `export/2187/07/06/` before `deck-09/strain.tsv`.
10. ```
    tar: Removing leading `/' from member names
    ```
    Not an error. tar exits 0 and lists the members normally.
11. They *do* start with `/` — the listing shows `/etc/`, `/etc/kestrel/`,
    `/etc/kestrel/clamp.conf`. The archive was built with `--absolute-names`,
    so the slashes are stored. The warning is tar telling you it will strip
    them on the way out, which is why extraction cannot escape your current
    directory.
12. `tar -tzf archives/deck-logs-2187.tar.gz --wildcards '*/deck-04/*'` → **3**.

## B. Extracting safely

13. `mkdir -p scratch/logs && tar -xzf archives/deck-logs-2187.tar.gz -C scratch/logs`
    → `scratch/logs/deck-logs-2187/`.
14. Nothing printed, exit 0. It overwrote every file with an identical copy.
    Silence is the point: tar does not report what it replaced.
15. `tar -xzf archives/deck-logs-2187.tar.gz -C scratch deck-logs-2187/README`
    → `scratch/deck-logs-2187/README`. The wrapper directory is recreated
    because it is part of the member's path.
16. Nine.
17. `calibration-export.tar.gz` has no top-level directory, so without `-C` its
    nine members land loose in whatever directory you are standing in;
    `deck-logs-2187.tar.gz` would have made exactly one directory.
18. `scratch/strain/export/2187/07/06/deck-09/strain.tsv`.
19. `scratch/strain/deck-09/strain.tsv`.
20. Nothing is extracted. Every member has fewer than six components, so every
    member is skipped. tar prints nothing and exits **0** — a silent no-op, and
    the reason to count with `-t` first.
21. `scratch/etc-test/etc/kestrel/clamp.conf`. tar printed
    `tar: Removing leading `/' from member names` again.
22. `ls -ld /etc/kestrel` → no such directory. It never existed and was not
    created.
23. It would keep the stored leading `/` and try to write `/etc/kestrel/`
    directly. As `cadet` it would fail on permissions; as root it would silently
    overwrite the live system configuration. Neither is what you wanted from an
    unpacking check.
24. Three: `2187-04.tsv`, `2187-05.tsv`, `2187-06.tsv` under
    `scratch/tally/hatch-tally/`.
25. Real tabs. `cat -A` shows `^I` between fields (Chapter 7's habit).
26. `rm -rf scratch/*` — or `find scratch -mindepth 1 -delete`.

## C. Creating

27. `mkdir -p scratch/mine && printf 'a\n' > scratch/mine/a.txt` and so on.
28. `tar -cf scratch/mine.tar scratch/mine` — `-f` last, its argument next.
29. `scratch/mine/a.txt`. tar stores the path exactly as you wrote it on the
    command line; it does not shorten or absolutise anything.
30. `tar -czf scratch/mine.tar.gz scratch/mine`. The `.tar` is 10240 bytes
    (tar's minimum) and the `.gz` a few hundred.
31. bzip2 is usually smallest of the three, but at this size the answer is
    noise — all three are dominated by tar's 512-byte header blocks and the
    compressor's own framing. Three text files cannot support a conclusion
    about compressors.
32. ```
    tar: scratch/oops.tar.gz: Cannot stat: No such file or directory
    tar: Exiting with failure status due to previous errors
    ```
    `-f` took `z` as its argument, so tar created `z` and then tried to *add*
    `scratch/oops.tar.gz` to it.
33. Yes, `z`, about 10 KB — it contains `scratch/mine`, which was the one
    argument tar could stat.
34. `rm z; tar -czf scratch/oops.tar.gz scratch/mine`
35. `tar -caf scratch/mine.tgz scratch/mine` — yes, `file` reports gzip data.
    `-a` chooses the compressor from the *file name suffix*; `.tgz` means gzip.
36. `tar -czf scratch/mine.tar.gz -C scratch mine` — members are `mine/a.txt`.
    `-C` applies to create as well as extract.
37. stdout. `tar -cvf scratch/mine.tar scratch/mine 2>/dev/null` still prints
    the list; `1>/dev/null` silences it.
38. ```
    tar: nodir: Cannot stat: No such file or directory
    ```
    Exit status **2**.

## D. Reading the archives you were given

39. `tar -tzf archives/deck-logs-2187.tar.gz | grep -c '\.log$'` → **9**.
40. `deck-01`, `deck-04`, `deck-09`.
41. `spare-logs.tar.bz2`. Everything else matches its name.
42. ```
    archives/spare-logs.tar.bz2: gzip compressed data, max compression, from Unix, original size modulo 2^32 20480
    ```
43. ```
    bzip2: (stdin) is not a bzip2 file.
    ```
    followed by `tar: Child returned status 2` and
    `tar: Error is not recoverable: exiting now`. Exit status **2**.
44. Plain `tar -tf` works. With `-j` you *told* tar which decompressor to use
    and it obeyed you; with no flag tar looked at the file's magic bytes and
    got it right. An explicit wrong answer beats no answer only when it is
    right.
45. `cmp` is silent and exits 0 — they are byte-for-byte identical. One is a
    copy of the other with a misleading name.
46. ```
    tar (child): archives/nosuch.tar.gz: Cannot open: No such file or directory
    ```
    Exit status **2** — the same status as 43. tar's 2 means "fatal error", not
    a specific error.
47. 20480 → 446, about 46:1. The content is a handful of short, highly
    repetitive lines, and most of the 20 KB is tar's zero-padding, which
    compresses to nothing.
48. tar writes in 512-byte blocks and pads the archive to a whole number of
    20-block records — 20 × 512 = 10240 — so every uncompressed tar file is a
    multiple of 10240 bytes. 14 small members needed two records.

## E. Judgement

49. ```
    file archive.tar.gz
    tar -tf archive.tar.gz | head
    ```
    What it actually is, then whether it has a top-level directory.
50. `-C` into an empty directory would have prevented it; `tar -tf … | head`
    would have warned them.
51. Wanted: exercise 14, re-extracting over the same tree to restore a file you
    edited. Cost: extracting `calibration-export.tar.gz` into a directory that
    already had a `notes.txt` you had been writing — gone, with no message.
52. The `cd` makes the member names relative (`./passwd`, `./hosts`) instead of
    `etc/passwd`, so the archive can be unpacked over any target directory.
    Without it the members carry the `etc/` prefix and unpacking creates an
    `etc` subdirectory.
53. The archive would then only be unpackable in one place, and unpacking it
    would overwrite live files with no way to preview the result. Relative
    members plus a deliberate `-C` gives you the same outcome when you want it
    and a safe default when you do not.
54. No. The member list is stored in headers spread through the archive, one
    before each file, and for a compressed archive the whole stream has to be
    decompressed to reach them. There is no index; that is the format's design.
55. `tar -xzf big.tar.gz -C scratch path/inside/the/file` — name the member.
    tar still reads the stream but writes only that member.
56. For example: *`file` it, `tar -tf` it, then extract into an empty directory
    with `-C`. Never into a directory that has anything you want.*
