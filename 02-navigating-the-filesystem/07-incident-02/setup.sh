#!/usr/bin/env bash
# setup.sh -- seeds /labs/02-navigating-the-filesystem/07-incident-02
#
# CHAPTER 2 INCIDENT. Spoilers below; students are told not to read setup scripts.
#
# The shape of it:
#   maintenance/                 ls says empty, du -sh says 40M
#   maintenance/.cache/          RED HERRING: genuinely empty, and very tempting
#   maintenance/.a name you cannot type      <- note: leading dot, spaces, one
#                                NO-BREAK SPACE (U+00A0) between "cannot" and
#                                "type", and a TRAILING SPACE. Naive cd fails
#                                three different ways.
#     ballast.bin                40 MiB, explains the du figure
#     audit-notes.txt            dorn's audit notes -- trace 2. Not explained
#                                anywhere in the chapter. mtime 2187-05-15.
#     .keep
#   overnight/                   RED HERRING: a real, boring, visible directory
#
# The flag is NOT stored anywhere. It is derived from the directory's name:
# the visible words, lowercased, joined with underscores. See solutions.md.
#
# Artifacts -> exercises:
#   maintenance/                 -> ex 1-5, 9-12
#   maintenance/.cache           -> ex 6 (the red herring)
#   overnight/                   -> ex 7 (the other red herring)
#   audit-notes.txt              -> ex 13 (the debrief), and chapter 15
#
# Idempotent: removes its own tree first, creates nothing outside LAB.
set -euo pipefail

LAB="/labs/02-navigating-the-filesystem/07-incident-02"
rm -rf "$LAB"
mkdir -p "$LAB"
cd "$LAB"

# The name, built byte by byte so it is unambiguous in this script:
#   .  a  SP name SP you SP cannot NBSP type SP
STOWAWAY=$(printf '.a name you cannot\302\240type ')

mkdir -p maintenance/.cache
mkdir -p "maintenance/$STOWAWAY"

head -c 41926656 /dev/zero | tr '\0' 'e' > "maintenance/$STOWAWAY/ballast.bin"
: > "maintenance/$STOWAWAY/.keep"

cat > "maintenance/$STOWAWAY/audit-notes.txt" <<'EOF'
audit, deck 3, continued
------------------------
strain series does not match the maintenance log. the log says the panels were
reseated on the 11th. the series says nothing happened on the 11th.

three possibilities:
  1. the log is wrong
  2. the series is wrong
  3. both are right and they are describing different panels

checked (3) first. they are not.

the summariser is the only thing that touches both. keeping a copy of what it
produced before I ask anyone about this, because if I ask and I am wrong I have
accused someone of something, and if I ask and I am right the copy stops
existing.

next: whether the difference is in what the summariser reads or in what it
writes.
EOF

# Trace 2's date. Timeline: _handoff/SCENARIOS.md, 2187-05-15.
touch -d '2187-05-15 23:41:00' "maintenance/$STOWAWAY/audit-notes.txt"

# --- red herring: an ordinary, visible, boring directory ---------------------
mkdir -p overnight
for n in 10 11 12 13; do
  printf 'summariser run, deck 3, 2187-06-%s: 4 series, 0 anomalies\n' "$n" \
    > "overnight/run-2187-06-$n.log"
done
printf 'nothing unusual overnight.\n' > overnight/NOTES

echo "seeded $LAB"
