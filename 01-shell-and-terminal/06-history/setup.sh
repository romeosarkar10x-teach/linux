#!/usr/bin/env bash
# setup.sh -- seeds /labs/01-shell-and-terminal/06-history
#
# Artifacts -> exercises:
#   maint-old-history       -> ex 8, 9, 10 (a history file from a decommissioned account:
#         timestamped, ends mid-line, contains one leading-space gap in the numbering of events)
#   sampler-notes.txt       -> ex 4, 5 (a long-named file to drive !$ and Ctrl-R practice)
#   scratch/                -> ex 12 (a place to run throwaway commands)
#
# NOTE: this file is a WARM-UP for 01/07. It is NOT dorn's history and must not be
# confused with it -- different account, different dates, no arc content. Dates here are
# 2186 deliberately, well before the timeline in _handoff/SCENARIOS.md section 2.
#
# Idempotent: rewrites its own artifacts, creates nothing outside LAB.
set -euo pipefail

LAB="/labs/01-shell-and-terminal/06-history"
mkdir -p "$LAB/scratch"
cd "$LAB"

cat > sampler-notes.txt <<'EOF'
Sampler notes, deck 3.
Interval 360s. Output rotates monthly.
EOF

# 2186-09-22, maint-old's last session. Timestamps are real epoch seconds.
cat > maint-old-history <<'EOF'
#6839203200
cd /var/log/station
#6839203260
ls -l
#6839203331
wc -l structural.log
#6839203402
history -c
#6839203404
ls -l
#6839203590
cat sampler-not
EOF

echo "seeded $LAB"
