#!/usr/bin/env bash
# setup.sh -- seeds /labs/02-navigating-the-filesystem/03-the-fhs-tour
#
# Most of this lesson explores the real filesystem read-only. The lab seeds only
# the paper exercises.
#
# Artifacts -> exercises:
#   deliveries/          -> ex 12-14 (six unsorted files; the student says where each belongs)
#   deliveries/MANIFEST  -> ex 12    (what each delivered file is for)
#   answers.md           -> ex 12-14, 16 (where the student writes their classifications)
#
# Idempotent: removes its own tree first, creates nothing outside LAB.
set -euo pipefail

LAB="/labs/02-navigating-the-filesystem/03-the-fhs-tour"
rm -rf "$LAB"
mkdir -p "$LAB/deliveries"
cd "$LAB"

cat > deliveries/MANIFEST <<'EOF'
Deck 3 resupply, 2187-06-12. Six items, no filing instructions attached.

hullscan            a compiled tool the whole crew is expected to be able to run
hullscan.conf       settings for the above, edited per-station
hullscan.1          the manual page for the above
strain-archive.csv  eleven years of readings, 900 MB, changes only when appended to
scratch-run.tmp     output of a run that has already been read; nobody needs it tomorrow
kestrel-ops.pid     a number written at start-up, meaningless after a reboot
EOF

printf '#!/bin/sh\necho "hullscan: not the real thing"\n' > deliveries/hullscan
chmod 755 deliveries/hullscan
printf 'threshold = 0.42\nbay = 2\n'                      > deliveries/hullscan.conf
printf '.TH HULLSCAN 1\n.SH NAME\nhullscan \\- pretend\n' > deliveries/hullscan.1
printf 'date,bay,strain\n2187-06-13,2,0.421\n'            > deliveries/strain-archive.csv
printf 'run finished, output already read\n'              > deliveries/scratch-run.tmp
printf '4127\n'                                           > deliveries/kestrel-ops.pid

cat > answers.md <<'EOF'
# 02/03 answers

Fill this in as you go. One line per item; a wrong answer with a stated reason is worth more than
a right answer with none.

## Exercise 12 -- where each delivery belongs

| file | directory | why |
|---|---|---|
| hullscan | | |
| hullscan.conf | | |
| hullscan.1 | | |
| strain-archive.csv | | |
| scratch-run.tmp | | |
| kestrel-ops.pid | | |

## Exercise 13 -- the two that could go in more than one place

## Exercise 14 -- /usr/local vs /opt

## Exercise 16 -- the four empty directories
EOF

echo "seeded $LAB"
