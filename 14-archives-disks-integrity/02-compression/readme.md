# Compression

Three months of deck-09 telemetry sit in `logs/`, gzipped. Somebody wants to
know how often the clamp fired. The obvious answer is to decompress all three
and grep them, and the obvious answer needs free space, needs cleanup
afterwards, and leaves three large files on a station that is already short of
room.

The other answer needs no free space at all.

## One file at a time

```
gzip FILE          replaces FILE with FILE.gz
gunzip FILE.gz     replaces FILE.gz with FILE
gzip -k FILE       keep the original too
gzip -1 … -9       fastest … hardest
```

`gzip` **replaces its input**. It does not leave the original behind unless you
ask with `-k`. Everybody discovers this exactly once.

`bzip2`/`bunzip2` and `xz`/`unxz` behave the same way and take the same `-k`,
`-9` and `-t`. gzip is fastest and weakest, xz is slowest and strongest, bzip2
sits between. On `data/records.txt` — 46893 bytes of repetitive text — this
station gives 9422 (gzip), 4916 (bzip2), 1440 (xz).

## Two questions you can ask without decompressing

```
gzip -l FILE.gz    compressed size, uncompressed size, ratio
gzip -t FILE.gz    integrity check: silent and exit 0 if intact
```

`gzip -l` reads the header and the trailer, not the data. Note the caveat: the
stored uncompressed size is a 32-bit field, so for files over 4 GB it reports
the size *modulo 2^32* — a real number that is a real lie.

`gzip -t` is the one worth remembering. `data/half.log.gz` is a genuine gzip
file with the second half missing: `file` calls it
`gzip compressed data, max compression`, and `gzip -t` says

```
gzip: data/half.log.gz: unexpected end of file
```

and exits 1. `file` reads the first few bytes; `gzip -t` reads all of them and
checks the CRC. When you need to know whether an archive is intact, the two
commands are not interchangeable.

## Reading through the compression

```
zcat  FILE.gz          cat
zgrep PATTERN FILE.gz  grep
zless FILE.gz          less
zdiff A.gz B.gz        diff
```

These decompress into a pipe. Nothing lands on disk, the `.gz` is untouched,
and the peak disk usage is zero. `zgrep -c CLAMPED logs/*.gz` answers the
question this lesson opens with, in one command, on a full disk.

Two details. `zgrep` also works on files that are *not* compressed, which makes
it safe in a script that has to handle both. And `zcat`/`zgrep` are gzip only —
`zcat` on a `.bz2` says `not in gzip format`. Use `bzcat`/`bzgrep` and
`xzcat`/`xzgrep`, all of which are installed here.

## Compression is not free and not always a win

`data/sensor-raw.bin` is 200000 bytes of random data. Gzipped it is **200053**
bytes — larger, because there is no redundancy to remove and gzip still has to
add a header, a trailer and its own framing. Already-compressed data (JPEG,
`.gz`, most media) behaves the same way. The 80% ratios you see on logs come
from logs being extremely repetitive, not from gzip being magic.

## Whole directories: zip

`gzip` compresses one file. A directory needs `tar` first (lesson 01), or
`zip`, which archives and compresses in one step and is what groundside sends:

```
zip -r out.zip DIR
unzip -l out.zip          list without extracting
unzip out.zip -d target   extract into target
```

`zip` and `unzip` are **not installed on this station**. Installing them is
part of the exercises, and you learned how in chapter 13.

## Files

- `logs/` — three months of telemetry, gzipped, never to be decompressed on disk
- `data/` — one file in four formats, one incompressible file, two broken ones
- `notes/compression.txt` — the commands
