# Checksums — Solutions

Measured on the station. coreutils 9.11.

## A. Computing

1. 64 hex characters, 256 bits (4 bits per hex digit).
2. 32 characters, 128 bits.
3. Identical. A hash is a pure function of the bytes; if it were not
   repeatable it would be useless.
4. Identical. `cp` copies the contents, and the hash depends on nothing else —
   not the name, not the mtime, not the owner.
5. The same hash, `b1b56e2c…`, for both.
6. Yes — `cmp` is silent and exits 0. The files are byte-identical.
7. Nothing. The name is not hashed. Two names for the same bytes hash the
   same; the same name with different bytes does not.
8. `full.log` `1ecd2d30…`, `truncated.log` `db142458…`. Two hex characters
   happen to coincide somewhere in the string; **zero** leading characters
   match.
9. 6300 bytes against 6260 — 40 bytes shorter — and effectively the entire
   hash changed. There is no "40 bytes' worth" of difference in a hash.
10. Everything changes. You would have to compare the whole hash, and in
    practice you compare it with a tool rather than an eye, which is what `-c`
    is for.
11. `-`, meaning standard input. There was no filename to report because
    `sha256sum` never saw one.
12. `e3b0c442…` — the SHA-256 of the empty input.
13. **Yes.** It is the recorded hash of `./strain-2187-07.log`. Whoever wrote
    that line recorded a zero-byte file: either the export produced nothing for
    July, or the line was written by hand from an empty placeholder. Either way
    the manifest is asserting that an empty file is the correct content.

## B. Verifying

14. Six `OK`, one `FAILED`, one `FAILED open or read`, exit status **1**.
    ```
    ./strain-2187-05.log: FAILED
    sha256sum: ./strain-2187-07.log: No such file or directory
    sha256sum: WARNING: 1 listed file could not be read
    sha256sum: WARNING: 1 computed checksum did NOT match
    ```
15. `./strain-2187-05.log`.
16. `./strain-2187-07.log`. Not the same kind of problem at all: one file is
    present and wrong, the other is absent. The first is corruption; the second
    could be corruption, an incomplete transfer, or a manifest describing a
    different set of files.
17. `--quiet` suppresses the `OK` lines. The `FAILED` line, the missing-file
    error and both warnings all still print.
18. Nothing at all. You read `$?`, which is 1.
19. It hides the missing file. The mismatch still fails.
20. `sha256sum -c --strict --quiet SHA256SUMS` — no `--ignore-missing`, and act
    on a non-zero exit status. `--strict` is there for section C.
21. Yes. `./strain-2187-05.log: FAILED`, exit 1.
22. MD5 is broken against an *adversary* who gets to choose both files. It is
    perfectly good at noticing an accident, which is what happened here.
    "Broken" is a statement about a threat model, not about the arithmetic.
23. Exit **0**, one `OK`.
24. Not from the output alone. What told you is the *shape* of the corruption:
    one character in the middle of a 300-line file, with the manifest listing a
    hash for the uncorrupted version. The manifest must therefore predate the
    change. `-c` reported a difference; the story is yours to reconstruct.

## C. Manifest edges

25. One space, then `*`, then the name.
26. Yes — both `OK`, exit 0. `-c` accepts the binary marker.
27. Same format; `-b` is what produces it. It requests binary reading mode,
    which on Linux is identical to text mode, so the hash does not change. The
    flag is there for platforms where it does.
28. `^M$` at the end of each line — a carriage return before the newline.
29. It **passes**, exit 0.
30. Modern coreutils strips a trailing `\r` when parsing a manifest, so CRLF
    manifests verify fine here. Older implementations, and non-GNU ones, do
    not. The accurate claim is "CRLF may fail depending on the tool", and the
    way to know is to run it.
31. **0.** The prose line is skipped silently and the two valid lines pass.
32. `sha256sum: FILE: 3: improperly formatted SHA256 checksum line` and
    `WARNING: 1 line is improperly formatted`. Exit status is still **0**.
33. **1.**
34. Five files were verified. Nothing was said about the other 195, and the
    exit status did not mention them.
35. `--strict`. It is not the default for compatibility — manifests in the wild
    carry comments, headers and PGP wrappers, and making those fatal would
    break long-standing usage. That is a defensible decision for the tool and a
    terrible default for your script, which is why you pass the flag.
36. Plainly, with the space intact: `751da126…  ./sensor log 04.txt`. Two
    spaces separate hash from name, so a name containing a single space is
    unambiguous. (A name containing a newline or backslash gets an escaped form
    with `\` at the start of the line.)
37. Yes, it verifies. The result line quotes the name:
    `'./sensor log 04.txt': OK` — coreutils quotes names with special
    characters so you can see where they begin and end.

## D. What it does not prove

38. Yes, it passes. You altered the file and then wrote a manifest describing
    the altered file, and they agree with each other perfectly.
39. Nothing. It proves the files match the manifest that shipped with them.
    Anyone who could change the files could change the manifest in the same
    motion, and the result verifies.
40. Authenticity — evidence of *who* produced it, which requires a secret the
    forger does not have. The tool category is digital signatures (GPG, minisign,
    signed package repositories, as in chapter 13, lesson 02).
41. Partly. `/etc/apt/trusted.gpg.d/` holds two Ubuntu archive keyrings, and
    `gpgv` is installed — that is apt's verification path from chapter 13.
    But `gpg` itself is not installed (`command -v gpg` finds nothing) and
    there is no station key, so nothing produced here can be signed.
    `ops-bot`'s page says "no key material is configured", which is close
    enough to be useful and wrong enough to be worth checking. Checking rather
    than believing the page is the point.
42. Nine files in `dist/`: seven data files plus `SHA256SUMS` and `MD5SUMS`.
    The manifest lists eight: those seven, plus `strain-2187-07.log`, which is
    not there. Manifests do not usually list themselves.
43. **Nothing.** A file that appears in neither the directory nor the manifest
    is invisible to `-c`. This is the largest blind spot in the tool.
44. "Is this the set of files it should be, and does each contain what it
    should contain?" `-c` compares a directory against a list; it has no
    opinion about whether the list is right.
45. No. Every checksum here would pass. A hash of 300 correct lines is a
    correct hash.
46. A manifest that records what was *expected* — counts, ranges, dates —
    written by something other than the exporter, and checked against the
    export rather than derived from it.
47. True: the bytes match the hashes in the manifest that shipped with them.
    Assumed: that the manifest is authentic, that it is complete, and that the
    correct data was exported in the first place. Three assumptions in a
    six-word clause.
48. When you *expected* the file to have changed — for instance verifying that
    a patch was actually applied, or that a backup captured a new version
    rather than re-copying the old one. A pass there means nothing happened.

## E. Judgement

49. It defeats a corrupted or truncated download, and a mirror that served a
    damaged file. It does not defeat anyone who controls the server, because
    they served both.
50. Now the checksum and the file come from parties who would both have to be
    compromised. That is not a signature, but it is a real improvement, and it
    is why projects publish hashes on their own site and files on mirrors.
51. `--status` for silence in normal operation, `--strict` so an unparseable
    manifest is a failure. Not `--quiet`, because when it does fail you want
    the failing lines in the log — so in practice: run `--strict --status`,
    and on non-zero exit re-run without `--status` to capture the detail, then
    alert. Never let a non-zero exit be swallowed.
52. Hash the archive's size and its first and last megabyte; or hash the
    per-member checksums the archive already carries. Either catches truncation
    and a wholesale wrong file. Both miss a change in the middle, which is the
    change someone would make on purpose.
53. For: it is twice as fast, the threat is bit rot and failed transfers rather
    than an adversary, and the verifier runs on hardware you control. Against:
    the speed difference is dwarfed by disk I/O on a backup-sized dataset, and
    the day the threat model changes nobody will revisit the choice. On a
    backup verifier, sha256.
54. That the manifest actually covers the directory: compare the set of names
    it lists against the set of files present, in both directions, before
    running `-c` at all. `-c` will not tell you about files it was never told
    about.
55. "The listed files match the listed hashes. It says nothing about who wrote
    the list, or about files the list does not mention."
56. "Line 8 records the hash of an empty file for `strain-2187-07.log`. Please
    confirm whether July exported nothing, or whether that line was written by
    hand."
