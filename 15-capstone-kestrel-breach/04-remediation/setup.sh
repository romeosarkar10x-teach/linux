#!/bin/bash
# Seeds the remediation lab. Five things are wrong on purpose:
#   1. an unsigned third-party apt source (trusted=yes)
#   2. a world-writable directory holding the summariser's output
#   3. the setuid bit on a shell script (which Linux ignores - that is the point)
#   4. a clamp in the live summariser that the .orig does not have
#   5. an environment export that feeds the clamp, in a nologin account's .bashrc
# postcheck verifies system state, not the student's reasoning.
# Idempotent: the lab tree is removed and rebuilt from scratch every run.
set -euo pipefail

LAB="/labs/15-capstone-kestrel-breach/04-remediation"
rm -rf "$LAB"
mkdir -p "$LAB"/{bin,eng/repo.d,station/summariser,station/var,home/ops-bot,case/notes,backup}

# ------------------------------------------------------------------ 1. apt

cat > "$LAB/eng/repo.d/station.list" <<'EOF'
deb http://apt.kestrel.local/station stable main
EOF

cat > "$LAB/eng/repo.d/third-party.list" <<'EOF'
# added for the recert toolchain
deb [trusted=yes] http://eng-mirror.kestrel.local/apt stable main
EOF

cat > "$LAB/eng/repo.d/README.txt" <<'EOF'
Station apt sources.

Station policy: every source is signed, and every source is fetched over a
channel that can be authenticated. A source marked trusted=yes tells the
package manager to install from it without checking any signature at all.
EOF

# ---------------------------------------------------------- 2. summariser

cat > "$LAB/station/summariser/strain-summary" <<'EOF'
#!/bin/bash
# strain summariser - reads "cycle raw" pairs on stdin, writes one line each.
TOLERANCE="${STRAIN_TOLERANCE:-6.0}"
while read -r cycle raw; do
    reported="$raw"
    if [ "${raw/./}" -gt 60 ]; then
        reported="$TOLERANCE"
        echo "strain-summary: cycle $cycle value $raw clamped to $TOLERANCE" >&2
    fi
    printf 'cycle=%s raw=%s reported=%s\n' "$cycle" "$raw" "$reported"
done
EOF
chmod 755 "$LAB/station/summariser/strain-summary"

cat > "$LAB/backup/strain-summary.orig" <<'EOF'
#!/bin/bash
# strain summariser - reads "cycle raw" pairs on stdin, writes one line each.
while read -r cycle raw; do
    printf 'cycle=%s raw=%s reported=%s\n' "$cycle" "$raw" "$raw"
done
EOF
chmod 644 "$LAB/backup/strain-summary.orig"

cat > "$LAB/station/summariser/loop" <<'EOF'
#!/bin/bash
# loop - feeds the summariser forever. Started by hand; stopped by hand.
set -u
here="$(cd "$(dirname "$0")" && pwd)"
n=0
while true; do
    n=$(( n + 1 ))
    raw=$(( 40 + (n * 7) % 45 ))
    printf '%d %d.%d\n' "$n" "$(( raw / 10 ))" "$(( raw % 10 ))"
    sleep 3
done | "$here/strain-summary" >> "$here/../var/summary.log" 2>> "$here/../var/summary.err"
EOF
chmod 755 "$LAB/station/summariser/loop"

# ------------------------------------------------------- 3. the raw sample

cat > "$LAB/station/var/raw-sample.txt" <<'EOF'
1 4.7
2 5.4
3 6.1
4 6.8
5 5.9
6 6.6
7 7.3
8 4.4
9 5.1
10 6.5
EOF

cat > "$LAB/station/var/deck3-report.txt" <<'EOF'
deck 3 strain, sample of ten cycles

peak reported   6.0
mean reported   5.6
exceedances     0
EOF

# ------------------------------------------------------ 4. the setuid script

cat > "$LAB/bin/eng-scan" <<'EOF'
#!/bin/bash
# eng-scan - list a tree. Installed setuid during the recert.
set -euo pipefail
printf 'eng-scan: running as uid %s, euid %s\n' "$(id -ru)" "$(id -u)" >&2
find "${1:-.}" -type f -printf '%u %m %p\n'
EOF

cat > "$LAB/bin/postcheck" <<'EOF'
#!/bin/bash
# postcheck - verifies the state of this lab. Says what is wrong, never why.
# Exit 0 if every check passes, 1 otherwise.
set -uo pipefail
here="$(cd "$(dirname "$0")/.." && pwd)"
fail=0
report() {
    if [ "$1" -eq 0 ]; then
        printf 'PASS  %s\n' "$2"
    else
        printf 'FAIL  %s\n' "$2"
        fail=1
    fi
}

grep -rqs 'trusted=yes' "$here/eng/repo.d"
report "$(( 1 - $? ))" "no apt source is marked trusted=yes"

mode=$(stat -c '%a' "$here/station/var")
case "$mode" in
    *7) report 1 "station/var is not world-writable (is $mode)" ;;
    *)  report 0 "station/var is not world-writable (is $mode)" ;;
esac

suid=$(find "$here" -type f -perm -4000 2>/dev/null | wc -l)
[ "$suid" -eq 0 ]
report $? "no setuid file under the lab (found $suid)"

if [ -f "$here/backup/strain-summary.orig" ] &&
   diff -q "$here/backup/strain-summary.orig" \
           "$here/station/summariser/strain-summary" >/dev/null 2>&1; then
    report 0 "the live summariser matches the backup"
else
    report 1 "the live summariser matches the backup"
fi

grep -qs 'STRAIN_TOLERANCE' "$here/home/ops-bot/.bashrc"
report "$(( 1 - $? ))" "no STRAIN_TOLERANCE export in ops-bot's .bashrc"

if pgrep -f 'summariser/loop' >/dev/null 2>&1; then
    report 1 "the summariser loop is not running"
else
    report 0 "the summariser loop is not running"
fi

exit "$fail"
EOF
chmod 755 "$LAB/bin/postcheck"

# ------------------------------------------------------------- 5. the export

cat > "$LAB/home/ops-bot/.bashrc" <<'EOF'
# ops-bot environment
export PATH=/opt/eng/bin:$PATH
export STRAIN_TOLERANCE=6.0
EOF

# ----------------------------------------------------------------- the case

cat > "$LAB/case/notes/00-carried.md" <<'EOF'
Carried forward from lesson 03:

- two edit clusters, 2187-05-15..17 and 2187-05-19..20
- checksums-2186.recheck.txt disagrees with checksums-2186.txt on q3 and q4
- the live summariser clamps; the backup does not
- ops-bot's .bashrc exports STRAIN_TOLERANCE and ops-bot has a nologin shell
- station/mounts/raw-strain is a dangling symlink

Nothing above says what anyone intended. Keep it that way.
EOF

cat > "$LAB/case/TEMPLATE.md" <<'EOF'
change:
why:
before:
after:
verified by:
reversible:
EOF

# ------------------------------------------------------- ownership and modes

chown -Rh cadet:crew "$LAB"
chown -Rh root:root "$LAB/bin/eng-scan"
chown -Rh ops-bot:ops "$LAB/home/ops-bot" "$LAB/station/summariser" "$LAB/station/var"
chown -h cadet:crew "$LAB/station/var/raw-sample.txt"

chmod 755 "$LAB/bin"
chmod 4755 "$LAB/bin/eng-scan"
chmod 1777 "$LAB/station/var"
chmod 775 "$LAB/station/summariser"

# ------------------------------------------------------------------- mtimes
# Dates carried over from lesson 03 so the two lessons agree.

find "$LAB" -exec touch -h -d '2187-06-14 07:30:00' {} +

touch -h -d '2186-04-11 09:00:00' "$LAB/eng/repo.d/station.list"
touch -h -d '2187-05-16 03:18:00' "$LAB/eng/repo.d/third-party.list"
touch -h -d '2186-09-28 14:22:00' "$LAB/backup/strain-summary.orig"
touch -h -d '2186-10-06 02:14:00' "$LAB/station/summariser/strain-summary"
touch -h -d '2187-05-18 01:33:00' "$LAB/bin/eng-scan"
touch -h -d '2187-05-19 23:58:00' "$LAB/home/ops-bot/.bashrc"
touch -h -d '2187-05-24 06:15:00' "$LAB/station/var/deck3-report.txt"
touch -h -d '2187-05-24 05:50:00' "$LAB/station/var/raw-sample.txt"
