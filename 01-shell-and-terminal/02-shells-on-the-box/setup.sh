#!/usr/bin/env bash
# setup.sh -- seeds /labs/01-shell-and-terminal/02-shells-on-the-box
#
# Artifacts -> exercises:
#   crew-shells.txt   -> ex 6, 7 (an account-to-shell extract; one entry is a shell
#                                 that is not installed, one is /usr/sbin/nologin)
#   greet.sh          -> ex 8, 9 (bash-only syntax, no shebang; runs under bash, fails under sh)
#   station-shells    -> ex 5 (a stale copy of /etc/shells to compare against reality)
#
# Idempotent: rewrites its own artifacts, creates nothing outside LAB.
set -euo pipefail

LAB="/labs/01-shell-and-terminal/02-shells-on-the-box"
mkdir -p "$LAB"
cd "$LAB"

cat > crew-shells.txt <<'EOF'
# account-to-login-shell extract, station systems, taken 2187-06-01
cadet       /bin/bash
rhea        /bin/bash
cass        /bin/bash
dorn        /bin/bash
ops-bot     /usr/sbin/nologin
sensors     /usr/sbin/nologin
maint-old   /bin/ksh
EOF

cat > station-shells <<'EOF'
/bin/sh
/bin/bash
/usr/bin/bash
/bin/dash
/bin/ksh
/usr/bin/zsh
EOF

cat > greet.sh <<'EOF'
name="deck 3"
if [[ "$name" == deck* ]]; then
    echo "structural monitoring: $name"
fi
EOF

echo "seeded $LAB"
