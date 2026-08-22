#!/usr/bin/env bash
# setup.sh -- seeds /labs/01-shell-and-terminal/04-variables
#
# Artifacts -> exercises:
#   deck-config       -> ex 8, 9 (three settings: one set, one empty, one absent --
#                                 the unset-vs-empty distinction, in a real-looking file)
#   report.sh         -> ex 12, 13 (a script that misbehaves because of a missing brace
#                                   and an unquoted expansion; student diagnoses, does not fix)
#   sample-names.txt  -> ex 6 (values with spaces, to be assigned and echoed back)
#
# Idempotent: rewrites its own artifacts, creates nothing outside LAB.
set -euo pipefail

LAB="/labs/01-shell-and-terminal/04-variables"
mkdir -p "$LAB"
cd "$LAB"

cat > deck-config <<'EOF'
# Deck 3 structural monitoring -- sampler settings
# Read by the summariser. Blank value means "use the built-in default".
SAMPLE_INTERVAL=360
ALERT_THRESHOLD=
# RETENTION_DAYS is not listed here at all.
EOF

cat > sample-names.txt <<'EOF'
deck 3 bay 2
structural strain
hull temp
EOF

cat > report.sh <<'EOF'
#!/usr/bin/env bash
# Prints a one-line summary. Two bugs. Do not fix them yet -- 01/04 ex 12 and 13.
deck=3
unit=bay
label=$deck$unit
title="deck 3 bay 2"

echo "label:  $label"
echo "padded: $labelplate"
echo "title:  $title"
EOF
chmod +x report.sh

echo "seeded $LAB"
