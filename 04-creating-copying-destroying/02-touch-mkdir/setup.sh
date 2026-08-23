#!/usr/bin/env bash
# setup.sh -- seeds /labs/04-creating-copying-destroying/02-touch-mkdir
#
# Artifacts -> exercises:
#   spec/deck-tree.txt      the tree the student must build with brace expansion -> ex 12-20
#   spec/naming-notes.txt   two rules that make the naive brace expression wrong -> ex 18-20
#   existing/               a partially built tree: existing/deck-03/bay-01 exists, and
#                           existing/deck-03/bay-02 exists as a FILE, not a directory
#                             -> ex 6-11 (mkdir vs mkdir -p, and the error -p cannot swallow)
#   perms/                  empty; ex 21-27 create directories in it with -m and with umask
#   times/                  three files with known mtimes for touch -c / -r / -a -m -> ex 28-35
#   build/                  empty; the student's own tree goes here
#
# Idempotent: removes its own tree first, creates nothing outside LAB.
set -euo pipefail

LAB="/labs/04-creating-copying-destroying/02-touch-mkdir"
rm -rf "$LAB"
mkdir -p "$LAB"/{spec,existing,perms,times,build}
cd "$LAB"

cat > spec/deck-tree.txt <<'EOF'
deck-03 tree, as issued 2187-05-17

  deck-03/
    bay-01/  bay-02/  bay-03/  bay-04/
      each bay contains: readings/  faults/  handover/
    panel-07/
      logs/  spares/
    panel-11/
      logs/  spares/

deck-04 tree: identical shape, bays 01 through 06.
EOF

cat > spec/naming-notes.txt <<'EOF'
Two rules the deck tree follows and a naive expansion does not.

1. Bay numbers are always two digits with a leading zero. bay-1 is not a name
   that exists anywhere on this station.
2. deck-04 has six bays, not four. The shape is identical; the count is not.

A third thing, recorded because it caused an argument: panel numbers are 07 and
11, and there is no panel-08, panel-09 or panel-10. They were never installed.
EOF

mkdir -p existing/deck-03/bay-01/readings
printf 'bay 02 is not a directory. that is the point.\n' > existing/deck-03/bay-02
printf 'strain 0.41\nstrain 0.43\n' > existing/deck-03/bay-01/readings/2187-05-17.txt

printf 'first\n'  > times/anchor.txt
printf 'second\n' > times/one.txt
printf 'third\n'  > times/two.txt
touch -d '2187-05-17 04:02:00' times/anchor.txt
touch -d '2187-05-17 09:30:00' times/one.txt
touch -d '2187-05-18 22:15:00' times/two.txt

touch -d '2187-05-17 08:00:00' spec/deck-tree.txt spec/naming-notes.txt

echo "seeded $LAB"
