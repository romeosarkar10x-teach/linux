#!/bin/bash
# Lesson 15/02 — triage.
#
# Seeds:
#   bin/strain-summary     long-running job the student starts as ops-bot  (ex 20-40)
#   bin/deck-watch         a second, shorter-lived process for contrast    (ex 26-29)
#   var/                   where strain-summary writes; empty at seed      (ex 30-35)
#   access/eng-access.log  holds one eng-svc entry, 2187-01-18             (ex 41-48)
#   access/crew-shell.log  ordinary shell logins for contrast              (ex 41-48)
#   case/                  claim files carry forward from lesson 01        (ex 49-56)
#
# The lesson deliberately starts NO process at seed time. The student starts
# strain-summary themselves in exercise 20 and triages it afterwards, so this
# script stays idempotent and leaves nothing running.
#
# Idempotent: the tree is rebuilt from scratch and every mtime is set.

set -eu

LAB="/labs/15-capstone-kestrel-breach/02-triage"

rm -rf "$LAB"
mkdir -p "$LAB"/{bin,var,access,case/artefacts,case/notes}
cd "$LAB"

# --------------------------------------------------------- strain-summary ---

cat > bin/strain-summary <<'EOF'
#!/bin/bash
# strain-summary -- deck 3 strain summariser.
#
# Reads the raw series, applies the configured tolerance, writes a summary
# line per cycle. Runs until stopped.

set -u

LAB="/labs/15-capstone-kestrel-breach/02-triage"
OUT="$LAB/var/summary.log"
ERR="$LAB/var/summary.err"
TOLERANCE="${STRAIN_TOLERANCE:-6.0}"

exec 3>>"$OUT"
exec 4>>"$ERR"

echo "strain-summary: start pid=$$ tolerance=$TOLERANCE" >&3

n=0
while true; do
    n=$(( n + 1 ))
    raw=$(( 40 + (n * 7) % 45 ))
    v="$(( raw / 10 )).$(( raw % 10 ))"
    clamped="$v"
    if [ "$raw" -gt 60 ]; then
        clamped="$TOLERANCE"
        echo "strain-summary: value $v above tolerance $TOLERANCE, clamped" >&4
    fi
    printf 'cycle=%d raw=%s reported=%s\n' "$n" "$v" "$clamped" >&3
    sleep 5
done
EOF
chmod 755 bin/strain-summary

cat > bin/deck-watch <<'EOF'
#!/bin/bash
# deck-watch -- prints a heartbeat and exits after the given number of cycles.
set -u
n="${1:-12}"
i=0
while [ "$i" -lt "$n" ]; do
    i=$(( i + 1 ))
    echo "deck-watch: heartbeat $i/$n"
    sleep 5
done
EOF
chmod 755 bin/deck-watch

# ------------------------------------------------------------------ access --

cat > access/eng-access.log <<'EOF'
2186-12-04 08:12:41 rhea      open   /mnt/eng-archive/strain/summary/2186-12-03.csv
2186-12-19 14:03:07 rhea      open   /mnt/eng-archive/strain/summary/2186-12-18.csv
2187-01-04 09:41:55 rhea      open   /mnt/eng-archive/strain/summary/2187-01-03.csv
2187-01-18 03:26:12 eng-svc   move   /mnt/eng-archive/strain/summary/pre-2186-10/ -> /mnt/eng-archive/.retired/
2187-01-18 03:26:12 eng-svc   close  session
2187-02-02 10:15:33 rhea      open   /mnt/eng-archive/strain/summary/2187-02-01.csv
2187-03-11 11:47:20 rhea      open   /mnt/eng-archive/strain/summary/2187-03-10.csv
2187-04-27 16:02:09 rhea      open   /mnt/eng-archive/strain/summary/2187-04-26.csv
2187-05-13 22:58:44 dorn      open   /mnt/eng-archive/strain/summary/2186-10-06.csv
2187-05-13 23:04:02 dorn      open   /mnt/eng-archive/strain/raw/2186/10/raw-2186-10-06.dat
2187-05-18 01:33:57 dorn      denied /mnt/eng-archive/strain/raw/2186/10/
2187-05-20 02:41:16 dorn      open   /mnt/eng-archive/strain/summary/2186-10-06.csv
2187-06-03 09:22:38 rhea      open   /mnt/eng-archive/strain/summary/2187-06-02.csv
EOF

cat > access/crew-shell.log <<'EOF'
2187-05-21 08:02:11 rhea    login  pts/1
2187-05-21 17:44:03 rhea    logout pts/1
2187-05-22 07:58:40 cass    login  pts/2
2187-05-22 19:11:27 cass    logout pts/2
2187-05-23 22:14:09 dorn    login  pts/3
2187-05-24 04:12:38 dorn    logout pts/3
2187-05-24 08:01:02 rhea    login  pts/1
2187-05-24 18:30:55 rhea    logout pts/1
2187-05-23 09:00:14 cadet   login  pts/0
EOF

cat > access/README.txt <<'EOF'
Copies of two station logs, taken 2187-06-14 for review. Read-only.

eng-access.log  engineering archive access, as recorded by the archive host
crew-shell.log  interactive shell sessions on the station host
EOF

printf 'Case file continues from lesson 01. Claims numbered from 04.\n' \
    > case/notes/00-open.md
printf '# Claim <n>\n\n- **artefact:** <absolute path>\n- **bytes:** <size in bytes>\n- **mtime:** <YYYY-MM-DD HH:MM>\n- **sha256:** <full hash of the bytes as found>\n- **says:** <what the artefact literally contains>\n- **means:** <what you take from it>\n' \
    > case/TEMPLATE.md

# ----------------------------------------------------------------- mtimes ---

chmod -R u+rwX,go+rX "$LAB"
chmod 755 bin/strain-summary bin/deck-watch
chmod 1777 var

touch -h -d '2186-10-06 02:14' bin/strain-summary
touch -h -d '2187-06-03 09:22' access/eng-access.log
touch -h -d '2187-05-24 18:30' access/crew-shell.log
touch -h -d '2187-06-14 07:30' access/README.txt access bin/deck-watch bin var \
    case case/artefacts case/notes case/TEMPLATE.md case/notes/00-open.md "$LAB"
