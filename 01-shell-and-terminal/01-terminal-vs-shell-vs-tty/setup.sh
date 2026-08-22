#!/usr/bin/env bash
# setup.sh -- seeds /labs/01-shell-and-terminal/01-terminal-vs-shell-vs-tty
#
# Artifacts -> exercises:
#   deck-roster.txt  -> ex 4 (a file to pipe, to compare tty vs not-a-tty)
#   consoles/        -> ex 5 (12 entries: `ls` columnises on a tty, one-per-line in a pipe)
#
# Idempotent: rewrites its own artifacts, creates nothing outside LAB.
set -euo pipefail

LAB="/labs/01-shell-and-terminal/01-terminal-vs-shell-vs-tty"
mkdir -p "$LAB/consoles"
cd "$LAB"

cat > deck-roster.txt <<'EOF'
DECK 1  bridge          console tty1
DECK 1  comms           console tty2   cass
DECK 2  crew quarters   no console
DECK 3  engineering     console tty3   rhea
DECK 3  structural bay  console tty4
DECK 4  systems         console tty5   (vacant)
EOF

for n in 01 02 03 04 05 06 07 08 09 10 11 12; do
    printf 'console %s\n' "$n" > "consoles/console-$n.txt"
done

echo "seeded $LAB"
