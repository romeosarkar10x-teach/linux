#!/usr/bin/env bash
# setup.sh -- seeds /labs/00-boarding-the-kestrel/06-recording-your-work
#
# Artifacts -> exercises:
#   README             -> orientation
#   ~/transcripts      -> ex 2, 4 (created in HOME, deliberately: evidence must
#                         not live anywhere `kestrel reset` can destroy it)
#
# Idempotent. The only thing touched outside LAB is creating an empty
# ~/transcripts directory, which every later lesson writes evidence into.
set -euo pipefail

LAB="/labs/00-boarding-the-kestrel/06-recording-your-work"
mkdir -p "$LAB"

cat > "$LAB/README" <<'EOF'
Lab for 00/06.

Almost everything in this lesson happens outside this directory:
  ~/transcripts/   where your evidence goes -- survives `kestrel reset`,
                   because it is in your home directory, not in a lab
  the VM           for docker cp and OBS

Nothing you need is wiped by a reset. That is the point: evidence must not live
somewhere a reset can destroy it.
EOF

# Home-directory scaffolding, not a lab artifact: so the student's first
# `script` invocation does not fail on a missing directory.
install -d -o cadet -g cadet -m 0755 /home/cadet/transcripts

echo "seeded $LAB"
