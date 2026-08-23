#!/usr/bin/env bash
# setup.sh -- seeds /labs/02-navigating-the-filesystem/04-proc-and-sys
#
# Nearly everything in this lesson is read out of /proc directly. The lab seeds
# only the things the student needs to *own* a process and write answers.
#
# Artifacts -> exercises:
#   waiter.sh   -> ex 9-14, 19 (a script that sleeps, so the student has a process of their own
#                  to inspect in /proc -- named distinctively so its cmdline is recognisable)
#   answers.md  -> ex 6, 15, 16, 20 (written answers)
#
# Idempotent: removes its own tree first, creates nothing outside LAB.
set -euo pipefail

LAB="/labs/02-navigating-the-filesystem/04-proc-and-sys"
rm -rf "$LAB"
mkdir -p "$LAB"
cd "$LAB"

cat > waiter.sh <<'EOF'
#!/usr/bin/env bash
# Sits still so you have something to look at in /proc.
# Run it in the background:  ./waiter.sh deck-3 &
echo "waiter: pid $$, args: $*"
sleep 900
EOF
chmod +x waiter.sh

cat > answers.md <<'EOF'
# 02/04 answers

## Exercise 6 -- three facts about this machine, and where each came from

## Exercise 15 -- what /proc/version says, and what /etc/os-release says

## Exercise 16 -- why the two disagree

## Exercise 20 -- size zero
EOF

echo "seeded $LAB"
