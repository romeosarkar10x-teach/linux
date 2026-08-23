#!/usr/bin/env bash
# setup.sh -- seeds /labs/05-globbing-and-quoting/02-brace-expansion
#
# Artifacts -> exercises:
#   spec/deck-spec.txt      the tree the student builds with one brace expression -> ex 14-22
#   spec/gaps.txt           the three irregularities that break the naive expression -> ex 20-24
#   build/                  empty; the student's tree goes here
#   existing/               a half-built tree, to show brace expansion has no idea
#                           what exists -> ex 25-28
#   backup/                 four files with the {,.bak} idiom already applied to two
#                             -> ex 29-33
#   seq/                    empty; sequence-expression exercises write here -> ex 34-42
#   scratch/                student's own
#
# Idempotent: removes its own tree first, creates nothing outside LAB.
set -euo pipefail

LAB="/labs/05-globbing-and-quoting/02-brace-expansion"
rm -rf "$LAB"
mkdir -p "$LAB"/{spec,build,existing,backup,seq,scratch}
cd "$LAB"

cat > spec/deck-spec.txt <<'SPEC'
deck-05 layout, as issued 2187-05-30

  deck-05/
    bay-01 .. bay-08/
      readings/  faults/  handover/
    panel-03/  panel-05/  panel-09/
      logs/  spares/

Every bay has the same three subdirectories. Every panel has the same two.
SPEC

cat > spec/gaps.txt <<'GAPS'
Three ways the deck-05 layout is not as regular as it looks.

1. bay-06 was never fitted. The number is reserved, the space is empty, and
   there is no directory for it anywhere on the station.
2. bay-08 has a fourth subdirectory, spares/, because it holds the deck's
   spares locker. The other seven bays do not.
3. Panel numbers are 03, 05 and 09. There is no arithmetic that produces that
   list. Somebody chose them.
GAPS

mkdir -p existing/deck-05/bay-01/{readings,faults}
mkdir -p existing/deck-05/bay-02/readings
printf 'strain 0.41\n' > existing/deck-05/bay-01/readings/2187-05-30.txt

for f in panel-03.cfg panel-05.cfg; do
    printf 'threshold=0.50\nsweep=on\n' > "backup/$f"
    printf 'threshold=0.44\nsweep=on\n' > "backup/$f.bak"
done
printf 'threshold=0.50\nsweep=on\n' > backup/panel-09.cfg
printf 'threshold=0.50\nsweep=off\n' > backup/panel-11.cfg

touch -d '2187-05-30 08:00:00' spec/deck-spec.txt spec/gaps.txt
touch -d '2187-05-30 09:15:00' backup/*.cfg
touch -d '2187-05-28 22:40:00' backup/*.bak

echo "seeded $LAB"
