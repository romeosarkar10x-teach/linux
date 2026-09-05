#!/bin/bash
# Lesson 14/01 — tar.
# Idempotent: safe to re-run.
set -euo pipefail

LAB="/labs/14-archives-disks-integrity/01-tar"
export SOURCE_DATE_EPOCH=1577836800

rm -rf "$LAB"
mkdir -p "$LAB"/{archives,scratch,notes,src}

# Deterministic tar. Every archive in this lab is byte-reproducible so that
# re-running setup.sh does not change a single checksum.
mktar() {  # mktar OUTPUT DIR MEMBER...
    local out=$1 dir=$2; shift 2
    tar --sort=name --owner=0 --group=0 --numeric-owner \
        --mtime="@$SOURCE_DATE_EPOCH" --format=gnu \
        -C "$dir" -cf "$out" "$@"
}

B="$LAB/src"

# ---------------------------------------------------------- deck-logs-2187 ---
# The ordinary case: one top-level directory, relative paths, gzip.
mkdir -p "$B/deck-logs-2187"/{deck-01,deck-04,deck-09}
for d in 01 04 09; do
    for day in 03 04 05; do
        printf 'deck-%s 2187-07-%s\n' "$d" "$day" > "$B/deck-logs-2187/deck-$d/2187-07-$day.log"
        for h in 00 06 12 18; do
            printf '%s:00 settle %d.%d ok\n' "$h" "$((10#$d % 4 + 1))" "$((10#$day % 9))" \
                >> "$B/deck-logs-2187/deck-$d/2187-07-$day.log"
        done
    done
done
printf 'Deck logs, July 2187. Three decks, three days each.\n' \
    > "$B/deck-logs-2187/README"
mktar "$LAB/archives/deck-logs-2187.tar" "$B" deck-logs-2187
gzip -n -9 -c "$LAB/archives/deck-logs-2187.tar" > "$LAB/archives/deck-logs-2187.tar.gz"

# ------------------------------------------------------------- hatch-tally ---
# bzip2, so -j is not a theoretical flag.
mkdir -p "$B/hatch-tally"
for m in 04 05 06; do
    printf 'month\tcycles\tfaults\n' > "$B/hatch-tally/2187-$m.tsv"
    printf '2187-%s\t%d\t%d\n' "$m" "$((1200 + 10#$m * 7))" "$((10#$m % 5))" \
        >> "$B/hatch-tally/2187-$m.tsv"
done
mktar "$LAB/archives/hatch-tally.tar" "$B" hatch-tally
bzip2 -9 -c "$LAB/archives/hatch-tally.tar" > "$LAB/archives/hatch-tally.tar.bz2"
rm -f "$LAB/archives/hatch-tally.tar"

# ----------------------------------------------------------------- tarbomb ---
# No top-level directory. Extracting this in the wrong place scatters 9 files.
mkdir -p "$B/bomb"
for f in settle.conf hatch.conf deck.conf report.tsv notes.txt \
         a.log b.log c.log MANIFEST; do
    printf 'calibration export, file %s\n' "$f" > "$B/bomb/$f"
done
mktar "$LAB/archives/calibration-export.tar.tmp" "$B/bomb" \
    settle.conf hatch.conf deck.conf report.tsv notes.txt a.log b.log c.log MANIFEST
gzip -n -9 -c "$LAB/archives/calibration-export.tar.tmp" \
    > "$LAB/archives/calibration-export.tar.gz"
rm -f "$LAB/archives/calibration-export.tar.tmp"

# -------------------------------------------------------------- deep paths ---
# Four wrapper levels, so --strip-components has something to strip.
mkdir -p "$B/deep/export/2187/07/06/deck-09"
printf 'deck-09 strain export, 2187-07-06\n' \
    > "$B/deep/export/2187/07/06/deck-09/strain.tsv"
printf 'day\tpeak\n2187-07-06\t3.9\n' \
    >> "$B/deep/export/2187/07/06/deck-09/strain.tsv"
printf 'exported by the strain toolchain\n' \
    > "$B/deep/export/2187/07/06/deck-09/README"
mktar "$LAB/archives/strain-export.tar.tmp" "$B/deep" export
gzip -n -9 -c "$LAB/archives/strain-export.tar.tmp" > "$LAB/archives/strain-export.tar.gz"
rm -f "$LAB/archives/strain-export.tar.tmp"

# ------------------------------------------------------------ absolute paths --
# Built with a leading slash so tar prints its "Removing leading `/'" warning.
mkdir -p "$B/abs/etc/kestrel"
printf 'threshold = 3.5\n' > "$B/abs/etc/kestrel/clamp.conf"
printf 'window = 30\n' > "$B/abs/etc/kestrel/settle.conf"
( cd "$B/abs" && tar --sort=name --owner=0 --group=0 --numeric-owner \
    --mtime="@$SOURCE_DATE_EPOCH" --format=gnu --absolute-names \
    -cf "$LAB/archives/etc-backup.tar" /etc/kestrel 2>/dev/null ) || {
    # /etc/kestrel does not exist on the station; build the member list by hand.
    tar --sort=name --owner=0 --group=0 --numeric-owner \
        --mtime="@$SOURCE_DATE_EPOCH" --format=gnu \
        --transform='s,^,/,' --absolute-names \
        -C "$B/abs" -cf "$LAB/archives/etc-backup.tar" etc 2>/dev/null
}

# --------------------------------------------------------------- one that is --
# not what its name says: gzip data with a .tar.bz2 name.
cp "$LAB/archives/deck-logs-2187.tar.gz" "$LAB/archives/spare-logs.tar.bz2"

rm -rf "$B"

# ----------------------------------------------------------------- notes -----
cat > "$LAB/notes/tar.txt" <<'NOTE'
tar — three jobs, one letter each
=================================

  -c   create      make an archive out of files
  -t   list        show what is inside one, without extracting
  -x   extract     take the files out

Exactly one of those per command. The rest are modifiers:

  -f FILE   the archive file. ALWAYS write -f last: it takes the next word as
            its argument, so `tar -cfz a.tar.gz d` hands "z" to -f and makes a
            file called z. Write `tar -czf a.tar.gz d`.
  -v        verbose: list members as they go past
  -z        gzip           (.tar.gz, .tgz)
  -j        bzip2          (.tar.bz2)
  -J        xz             (.tar.xz)
  -C DIR    change to DIR first — for -x, this is where files land
  -a        pick the compressor from the file name (create only)

Since tar 1.15 the decompressor is detected automatically when reading, so
`tar -tf x.tar.bz2` works without -j. -j is still needed on create.

The habit
---------

  tar -tzf archive.tar.gz | head        look first
  mkdir scratch && tar -xzf a.tar.gz -C scratch    extract somewhere empty

Never extract an unknown archive into a directory you care about. tar
overwrites without asking and does not tell you what it replaced.

--strip-components=N
--------------------

Drops N leading path components from every member as it extracts. An archive
whose members are export/2187/07/06/deck-09/strain.tsv extracted with
--strip-components=4 gives you deck-09/strain.tsv.

Absolute paths
--------------

On create, tar strips a leading / and says so:
  tar: Removing leading `/' from member names
On extract it stays stripped, so the files land under the current directory.
That is the safe behaviour; --absolute-names on extract switches it off, and
you should have a reason.
NOTE

cat > "$LAB/notes/archives.txt" <<'NOTE'
What is in archives/
====================

  deck-logs-2187.tar        uncompressed, one top-level directory
  deck-logs-2187.tar.gz     the same thing, gzipped
  hatch-tally.tar.bz2       bzip2
  calibration-export.tar.gz no top-level directory — check before extracting
  strain-export.tar.gz      four wrapper directories nobody wants
  etc-backup.tar            built from absolute paths
  spare-logs.tar.bz2        named .tar.bz2

One of these files is not the format its name claims. `file` will tell you,
and so will tar, less politely.
NOTE

cat > "$LAB/notes/page.txt" <<'NOTE'
2187-07-07

Eleven years of station data lives in archives nobody has opened since they
were written. Groundside wants a copy in September, which means somebody has
to establish that they open at all.

Opening them is the easy part. What is not obvious until you have done it once
is that an archive records paths, and the paths decide where the contents land.
An archive that was made carelessly extracts carelessly, into whatever
directory you happened to be standing in.
NOTE

chmod 0644 "$LAB"/notes/* "$LAB"/archives/*
find "$LAB" -type d -exec chmod 0755 {} +
find "$LAB" -exec touch -h -d '2187-07-07 09:15' {} +
