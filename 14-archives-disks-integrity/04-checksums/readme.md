# 04 — Checksums, and what they prove

A checksum is a short number computed from a file's bytes. Change one bit of
the file and the number changes completely. That gives you one very useful
property and, more importantly, several properties it does not give you.

## Computing

```
sha256sum strain-2187-04.log
md5sum strain-2187-04.log
```

Each prints the hash, two spaces, and the filename. That layout is not
decoration — it is a format, and `-c` reads it back:

```
sha256sum ./*.log > SHA256SUMS
sha256sum -c SHA256SUMS
```

`-c` prints `OK` or `FAILED` per line and exits non-zero if anything failed.
Useful flags: `--quiet` prints only failures, `--status` prints nothing and
reports through the exit status alone, `--ignore-missing` skips files the
manifest names but that are not here.

## The format has edges

- **`--strict`.** A line `-c` cannot parse is *skipped*, and by default that
  is not a failure. A manifest of two hundred lines where one hundred and
  ninety are malformed will happily exit 0. `--strict` makes an unparseable
  line an error, and any verification you actually rely on should use it.
- **The `*` marker.** `sha256sum -b` writes `hash *name` — one space and a
  star — meaning "read in binary mode". On Linux there is no difference
  between the modes, and `-c` accepts both forms.
- **CRLF.** A manifest written on Windows has `\r` at the end of every line.
  Modern coreutils strips it and verification passes. Older ones did not, and
  you will still meet the folklore.
- **Filenames with spaces** survive, and names with backslashes or newlines
  get an escaped form with a leading `\` on the line.

## md5 vs sha256

`md5sum` is faster and shorter and you will see it everywhere. It is
**broken for security**: it is possible to construct two different files with
the same MD5, and people have done it with real certificates. It is still fine
for "did this file survive the copy", where nobody is trying to fool you.
`sha256sum` is the default choice; use md5 only when something else demands it.

## What a checksum proves

It proves that the bytes now are the bytes that were there when the hash was
computed.

That is all. In particular it does not prove:

- **Who computed it.** Anyone who can edit the file can recompute the manifest.
  A manifest that ships next to the file it describes verifies that the file
  matches the manifest, not that either is the one you were meant to get.
- **When.** A hash carries no timestamp.
- **That the file is correct.** A perfectly-verified export can be missing
  half its rows. The manifest says nothing about what *should* have been in it.
- **That the manifest is complete.** Verification walks the manifest's lines.
  A file that is not listed is not checked, and a file that should exist but
  is missing from both is invisible to `-c` entirely.

Signatures — GPG and friends — are the tool that adds "who", by involving a
key the attacker does not have. The station carries Ubuntu's archive keys in
`/etc/apt/trusted.gpg.d/`, which is how apt verifies packages; it carries no key
of its own, and `gpg` is not even installed. So nothing produced *here* can be
signed, which is worth remembering when someone tells you an export
"checks out".

The `dist/` manifest here passes for six files, fails for one, and names one
that is not there. Find out which, and then work out which of those three
outcomes actually tells you something about the export.
