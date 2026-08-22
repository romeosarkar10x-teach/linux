#!/usr/bin/env bash
# setup.sh -- seeds /labs/00-boarding-the-kestrel/05-getting-help
#
# Artifacts -> exercises:
#   sizes/    -> ex 1 (files of clearly different sizes, so `ls -S` shows something)
#
# Idempotent: rewrites its own artifacts, creates nothing outside LAB.
set -euo pipefail

LAB="/labs/00-boarding-the-kestrel/05-getting-help"
mkdir -p "$LAB/sizes"
cd "$LAB/sizes"

# Deterministic, no network, no randomness -- reset must reproduce this exactly.
: > tiny.txt
printf 'a%.0s' $(seq 1 200)    > small.txt
printf 'b%.0s' $(seq 1 20000)  > medium.txt
printf 'c%.0s' $(seq 1 500000) > large.txt

cat > "$LAB/README" <<'EOF'
Lab for 00/05.

  sizes/   four files of deliberately different sizes -- exercise 1

Everything else in this lesson is done against the machine's own documentation,
not against files here.
EOF

echo "seeded $LAB"
