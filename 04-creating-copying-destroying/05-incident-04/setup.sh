#!/usr/bin/env bash
# setup.sh -- seeds /labs/04-creating-copying-destroying/05-incident-04
#
# Artifacts -> exercises:
#   records/tree-manifest.txt      the authoritative manifest: 16 rows for 15 files, four
#                                  columns (path, size, recorded, note) -> ex 1-8, 14-18
#                                  Row 5 and row 6 are the SAME PATH four minutes apart:
#                                  512 bytes at 18:04, 1180 bytes at 18:08. The later one is
#                                  the retake and is the one that existed. -> ex 9-13
#   records/tree-manifest.txt.bak  RED HERRING. Older (09:12 vs 18:20), 14 rows, faults listed
#                                  before readings, and handover/2187-05-15.txt missing entirely.
#                                  Reading the notes column down this file gives three words that
#                                  are not the flag. -> ex 6-8
#   records/copy-notes.txt         trace 4. Why the copy was made. Names nobody.
#   salvage/                       two of the fifteen files survived, at their real sizes:
#                                  readings/2187-05-17-1804.txt (1180) and
#                                  handover/2187-05-15.txt (704). These settle the duplicate
#                                  empirically instead of by argument. -> ex 11-13
#   rebuild/                       empty. The student's reconstructed tree goes here.
#
# The flag is the notes column, first letter of each note, in manifest order, one word per
# directory. It is not written anywhere in the lab and does not survive grep.
#
# Idempotent: removes its own tree first, creates nothing outside LAB.
set -euo pipefail

LAB="/labs/04-creating-copying-destroying/05-incident-04"
rm -rf "$LAB"
mkdir -p "$LAB"/{records,salvage/readings,salvage/handover,rebuild}
cd "$LAB"

cat > records/tree-manifest.txt <<'EOF'
DECK-03 SALVAGE MANIFEST
issued 2187-05-17 18:20, station time
recorded off the deck-03 tree before transfer

Readback convention: engineering confirms a manifest by reading the notes
column down, first letter only, one word per directory, in the order the
rows appear. If the readback is not three words, the manifest is incomplete
and must not be acted on.

path                                size   recorded    note
----------------------------------------------------------------------------
readings/2187-05-17-0600.txt        1024   06:12       deck 3 strain, morning pass
readings/2187-05-17-0900.txt        1536   09:20       eight sensors reporting, two silent
readings/2187-05-17-1200.txt        2048   12:07       levels within tolerance all shift
readings/2187-05-17-1804.txt         512   18:04       end of shift copy, unverified
readings/2187-05-17-1804.txt        1180   18:08       extract retaken, first copy came out short
readings/2187-05-16-2200.txt         768   18:10       taken from the panel feed directly
readings/2187-05-15-0600.txt         640   18:11       engineering asked for this one twice
readings/2187-05-14-0600.txt         896   18:12       duplicate of the 05-16 series, kept
faults/open.txt                      320   18:13       nothing outstanding on deck 3
faults/closed.txt                    448   18:13       one item closed on 05-16, bearing housing
faults/deferred.txt                  256   18:14       two items deferred to next rotation
handover/2187-05-17.txt             1120   18:15       morning handover, quiet
handover/2187-05-16.txt              960   18:16       one open question about panel 07
handover/2187-05-15.txt              704   18:17       verified against the panel log
handover/2187-05-14.txt              832   18:18       everything signed off
handover/2187-05-13.txt              576   18:19       day shift only, no night entry
----------------------------------------------------------------------------
16 rows.
EOF

cat > records/tree-manifest.txt.bak <<'EOF'
DECK-03 SALVAGE MANIFEST
issued 2187-05-17 09:12, station time
working copy, not for readback

path                                size   recorded    note
----------------------------------------------------------------------------
faults/open.txt                      320   08:40       nothing outstanding on deck 3
faults/closed.txt                    448   08:41       one item closed on 05-16, bearing housing
faults/deferred.txt                  256   08:41       two items deferred to next rotation
readings/2187-05-17-0600.txt        1024   06:12       deck 3 strain, morning pass
readings/2187-05-17-0900.txt        1536   09:02       eight sensors reporting, two silent
readings/2187-05-16-2200.txt         768   08:50       taken from the panel feed directly
readings/2187-05-15-0600.txt         640   08:52       engineering asked for this one twice
readings/2187-05-14-0600.txt         896   08:53       duplicate of the 05-16 series, kept
handover/2187-05-17.txt             1120   09:05       morning handover, quiet
handover/2187-05-16.txt              960   09:06       one open question about panel 07
handover/2187-05-14.txt              832   09:08       everything signed off
handover/2187-05-13.txt              576   09:09       day shift only, no night entry
----------------------------------------------------------------------------
12 rows. Midday and evening readings not yet taken. Panel-log check outstanding.
EOF

cat > records/copy-notes.txt <<'EOF'
2187-05-17, evening.

Took a copy of the whole deck-03 tree tonight. Wrote the manifest at the same
time, off the tree and not off the copy, because a manifest taken off a copy
only proves the copy exists.

The 18:04 extract came out short. I do not know why. Ran it again at 18:08 and
got a sensible file, and left both lines in the manifest rather than tidying one
away, because a manifest that has been tidied is not a record of anything.

If the tree is ever gone, this is what was in it. That is the entire point of
writing it down.
EOF

# --- salvage: two files that survived, at their true sizes -----------------
awk 'BEGIN { while (length(s) < 1180) s = s "strain 0.41 0.43 0.44 deck3 panel07 nominal\n"
             printf "%s", substr(s, 1, 1180) }' > salvage/readings/2187-05-17-1804.txt
awk 'BEGIN { while (length(s) <  704) s = s "handover: verified against the panel log, no exceptions\n"
             printf "%s", substr(s, 1, 704) }'  > salvage/handover/2187-05-15.txt

touch -d '2187-05-17 18:08:00' salvage/readings/2187-05-17-1804.txt
touch -d '2187-05-17 18:17:00' salvage/handover/2187-05-15.txt
touch -d '2187-05-17 18:20:00' records/tree-manifest.txt
touch -d '2187-05-17 09:12:00' records/tree-manifest.txt.bak
touch -d '2187-05-17 22:40:00' records/copy-notes.txt

echo "seeded $LAB"
