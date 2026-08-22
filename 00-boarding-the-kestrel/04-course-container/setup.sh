#!/usr/bin/env bash
# setup.sh -- seeds /labs/00-boarding-the-kestrel/04-course-container
#
# Artifacts -> exercises:
#   station-log.txt   -> ex 10 (FLAG), ex 2 (something to list)
#   .hidden-note      -> ex 2, ex 10 (rewards `ls -a`; harmless either way)
#   scratch/          -> ex 5, ex 7 (a place to create test files)
#
# Idempotent: rewrites its own artifacts, creates nothing outside LAB.
set -euo pipefail

LAB="/labs/00-boarding-the-kestrel/04-course-container"
mkdir -p "$LAB/scratch"
cd "$LAB"

cat > station-log.txt <<'EOF'
ORBITAL STATION KESTREL -- WORKSTATION PROVISIONING LOG
-------------------------------------------------------
0311.02  Workstation 7 (cracked bezel) reassigned: cadet
0311.02  Account created. Groups: crew.
0311.02  Home directory provisioned at /home/cadet.
0311.03  Lab volume mounted at /labs.
0311.03  Course tree mounted read-only at /course.
0311.03  Provisioning complete. Registration token follows.

         KESTREL{workstation_online}

0311.03  Submit the token to confirm receipt:
             kestrel flags submit 'KESTREL{...}'
0311.03  -- automated provisioning system, ops-bot
EOF

cat > .hidden-note <<'EOF'
dorn kept notes in dotfiles so nobody would read them.
`ls` hides anything starting with a dot unless you ask.
You'll learn the flag for that in 02/02. Try to guess it now.
EOF

cat > scratch/README <<'EOF'
Scratch space. Create files here for exercises 5 and 7.
This whole directory is wiped by: kestrel reset 00/04
EOF

echo "seeded $LAB"
