#!/usr/bin/env bash
# setup.sh -- seeds /labs/01-shell-and-terminal/03-command-anatomy
#
# Artifacts -> exercises:
#   -l                 -> ex 6, 7 (a file whose NAME looks like a flag; needs -- or ./)
#   --help             -> ex 7 (same trick, long-flag shaped)
#   bin/deck-report    -> ex 9, 10 (an executable NOT on PATH, run by path)
#   bin/ls             -> ex 11 (a decoy `ls` that is not the real one; PATH order lesson)
#   notes.txt          -> ex 2, 3 (something harmless to pass as an operand)
#
# Idempotent: rewrites its own artifacts, creates nothing outside LAB.
set -euo pipefail

LAB="/labs/01-shell-and-terminal/03-command-anatomy"
mkdir -p "$LAB/bin"
cd "$LAB"

printf 'a file whose name looks like a short flag\n' > ./-l
printf 'a file whose name looks like a long flag\n' > ./--help

cat > notes.txt <<'EOF'
Deck 3 structural monitoring notes.
Sampling every 6 minutes. Nothing here is interesting yet.
EOF

cat > bin/deck-report <<'EOF'
#!/usr/bin/env bash
echo "deck report: $# argument(s)"
n=1
for a in "$@"; do
    printf '  arg %d: [%s]\n' "$n" "$a"
    n=$(( n + 1 ))
done
EOF

cat > bin/ls <<'EOF'
#!/usr/bin/env bash
echo "this is not the ls you are looking for"
EOF

chmod +x bin/deck-report bin/ls

echo "seeded $LAB"
