#!/bin/bash
# Lesson 14/02 — compression.
# Idempotent: safe to re-run.
set -euo pipefail

LAB="/labs/14-archives-disks-integrity/02-compression"

rm -rf "$LAB"
mkdir -p "$LAB"/{logs,data,notes,scratch}

# --------------------------------------------------------------- big log ----
# 40k lines of telemetry. Compresses hard because it is repetitive, which is
# the honest reason log archives are always gzipped.
{
    printf '# deck telemetry, 2187-06\n'
    d=1
    while [ "$d" -le 30 ]; do
        h=0
        while [ "$h" -lt 24 ]; do
            printf '2187-06-%02d %02d:00:00 deck-01 settle %d.%d ok\n' \
                "$d" "$h" "$(( (d + h) % 4 + 1 ))" "$(( (d * h) % 10 ))"
            printf '2187-06-%02d %02d:00:00 deck-04 settle %d.%d ok\n' \
                "$d" "$h" "$(( (d + h) % 3 + 1 ))" "$(( (d + h) % 10 ))"
            printf '2187-06-%02d %02d:00:00 deck-09 settle %d.%d %s\n' \
                "$d" "$h" "$(( (d + h) % 5 + 1 ))" "$(( (d * 3 + h) % 10 ))" \
                "$( [ "$(( (d * 7 + h) % 97 ))" -eq 0 ] && printf CLAMPED || printf ok )"
            h=$((h + 1))
        done
        d=$((d + 1))
    done
} > "$LAB"/logs/telemetry-2187-06.log
gzip -n -9 "$LAB"/logs/telemetry-2187-06.log

# Two more months, kept compressed. zgrep across all three is the point.
for m in 04 05; do
    {
        printf '# deck telemetry, 2187-%s\n' "$m"
        d=1
        while [ "$d" -le 28 ]; do
            h=0
            while [ "$h" -lt 24 ]; do
                printf '2187-%s-%02d %02d:00:00 deck-09 settle %d.%d %s\n' \
                    "$m" "$d" "$h" "$(( (d + h) % 5 + 1 ))" "$(( (d + h) % 10 ))" \
                    "$( [ "$(( (d * 5 + h + 10#$m) % 149 ))" -eq 0 ] && printf CLAMPED || printf ok )"
                h=$((h + 1))
            done
            d=$((d + 1))
        done
    } > "$LAB/logs/telemetry-2187-$m.log"
    gzip -n -9 "$LAB/logs/telemetry-2187-$m.log"
done

# ------------------------------------------------------- one file, 3 ways ----
seq 1 4000 | sed 's/^/record /' > "$LAB"/data/records.txt
gzip  -n -9 -c "$LAB"/data/records.txt > "$LAB"/data/records.txt.gz
bzip2    -9 -c "$LAB"/data/records.txt > "$LAB"/data/records.txt.bz2
xz       -9 -c "$LAB"/data/records.txt > "$LAB"/data/records.txt.xz

# ------------------------------------------------ incompressible content -----
# Random bytes: gzip makes it BIGGER. The counterexample to "just compress it".
head -c 200000 /dev/urandom > "$LAB"/data/sensor-raw.bin
gzip -n -9 -c "$LAB"/data/sensor-raw.bin > "$LAB"/data/sensor-raw.bin.gz

# ------------------------------------------------------------- a bad file ----
printf 'this was supposed to be a gzip file\n' > "$LAB"/data/truncated.gz

# A real gzip file truncated halfway: passes `file`, fails `gzip -t`.
seq 1 5000 | sed 's/^/record /' | gzip -n -9 > "$LAB"/scratch/.whole.gz
head -c 400 "$LAB"/scratch/.whole.gz > "$LAB"/data/half.log.gz
rm -f "$LAB"/scratch/.whole.gz

# ------------------------------------------------------------------ notes ----
cat > "$LAB"/notes/compression.txt <<'NOTE'
Compressing one file
====================

  gzip FILE        replaces FILE with FILE.gz
  gunzip FILE.gz   replaces FILE.gz with FILE
  gzip -k FILE     keep the original as well
  gzip -9 / -1     hardest / fastest
  gzip -l FILE.gz  sizes and ratio, without decompressing
  gzip -t FILE.gz  integrity check; silent and 0 if good

gzip replaces its input by default. That surprises people once each.

bzip2/bunzip2 and xz/unxz work the same way, with -k, -9 and -t.

Reading without decompressing
=============================

  zcat  FILE.gz       cat
  zgrep PAT FILE.gz   grep
  zless FILE.gz       less
  zdiff A.gz B.gz     diff

These decompress to a pipe. Nothing is written to disk and the .gz stays
where it is. On a 4 GB archive that is the difference between "I need free
space first" and "I have the answer".

zcat and zgrep are gzip only. For bzip2 use bzcat/bzgrep, for xz use
xzcat/xzgrep.

zgrep also works on files that are not compressed at all, which makes it safe
in a script that handles both.

Whole directories
=================

gzip does one file. For a directory you want tar first (lesson 01), or zip,
which does both jobs at once and is what groundside sends.

  zip -r out.zip DIR
  unzip -l out.zip     list
  unzip out.zip -d DIR extract into DIR

zip and unzip are not installed on this station. Installing them is your job
and you learned how in chapter 13.
NOTE

cat > "$LAB"/notes/page.txt <<'NOTE'
2187-07-08

Three months of deck-09 telemetry, gzipped, in logs/. Somebody wants to know
how often the clamp fired. The obvious answer is to gunzip all three and grep
them, and the obvious answer needs the free space to do it.

There is a second answer that needs no free space at all.
NOTE

chmod 0644 "$LAB"/logs/* "$LAB"/data/* "$LAB"/notes/*
find "$LAB" -type d -exec chmod 0755 {} +
find "$LAB" -exec touch -h -d '2187-07-08 11:40' {} +
