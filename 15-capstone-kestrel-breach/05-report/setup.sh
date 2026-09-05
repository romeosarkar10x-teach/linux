#!/bin/bash
# Seeds the report lab and the four-stage chain.
#
#   stage 1  evidence/handover.tar.gz            easy: extract it
#   stage 2  the six run-log records that are missing, recovered from archive/
#   stage 3  a sha256 in those records, matched against the tree
#   stage 4  a file only ops-bot can read, plus a stationctl subcommand
#
# Nothing here contains the flag. The two halves are ordinary words in two
# ordinary files; the student assembles them.
# Idempotent: the lab tree is removed and rebuilt from scratch every run.
set -euo pipefail

LAB="/labs/15-capstone-kestrel-breach/05-report"
rm -rf "$LAB"
mkdir -p "$LAB"/{bin,evidence,archive,station/summariser,station/.calibration,case/notes,report,data}

# --------------------------------------------------------------- the run log
# 05-12 to 05-24, two lines a day, seq 0412..0443, with 0432..0437 absent.

log="$LAB/station/summariser/run.log"
: > "$log"
# One record a night, 2187-04-28 onward, numbered without gaps -- except that
# 0432..0437 never reached this file.
seq_n=412
epoch=$(date -u -d '2187-04-23' +%s)
while [ "$seq_n" -le 443 ]; do
    stamp=$(date -u -d "@$(( epoch + (seq_n - 412) * 86400 ))" '+%Y-%m-%d')
    if [ "$seq_n" -lt 432 ] || [ "$seq_n" -gt 437 ]; then
        printf 'seq=%04d %s 02:00:0%d strain-summary start\n' \
            "$seq_n" "$stamp" "$(( seq_n % 8 ))" >> "$log"
        printf 'seq=%04d %s 02:00:3%d strain-summary ok\n' \
            "$seq_n" "$stamp" "$(( seq_n % 7 ))" >> "$log"
    fi
    seq_n=$(( seq_n + 1 ))
done

# ------------------------------------------------------------------- stage 1

mkdir -p "$LAB/.build/handover"
cat > "$LAB/.build/handover/notes.txt" <<'EOF'
later
EOF
cat > "$LAB/.build/handover/README" <<'EOF'
Deck 3 handover, incomplete.

The summariser writes one record per night and numbers them without gaps. The
run log on this machine does not agree with that. Whatever is missing from the
log was still written to the nightly archive, because the archive is filled by
a different job.

STAGE{handover_incomplete}

Next: work out exactly which records the log is missing, then find them.
EOF
tar --sort=name --mtime='2187-05-24 04:12:00' \
    --owner=0 --group=0 --numeric-owner \
    -cf - -C "$LAB/.build" handover | gzip -n -9 > "$LAB/evidence/handover.tar.gz"
rm -rf "$LAB/.build"

# ------------------------------------------------------------------- stage 2
# 0400..0443 archived. The six the log lost carry the continuation; the rest
# are ordinary nightly records.

for n in $(seq 400 443); do
    f="$LAB/archive/rec-$(printf '%04d' "$n").txt"
    if [ "$n" -ge 432 ] && [ "$n" -le 437 ]; then
        {
            printf 'seq=%04d subject=deck-3-strain\n' "$n"
            printf 'clamped=%d\n' "$(( (n - 430) * 3 ))"
            printf 'note=record not present in run.log\n'
            case "$n" in
                437) printf 'STAGE{six_records_recovered}\n'
                     printf 'match=da7abeda9b1341f59208052d15834916642d331771d1125f192dc565dc3fe5db\n'
                     printf 'hint=one file under this lab hashes to match=\n' ;;
                *)   printf 'continues=%04d\n' "$(( n + 1 ))" ;;
            esac
        } > "$f"
    else
        {
            printf 'seq=%04d subject=deck-3-strain\n' "$n"
            printf 'clamped=0\n'
            printf 'note=nightly\n'
        } > "$f"
    fi
    gzip -n -9 "$f"
done

# ------------------------------------------------------------------- stage 3
# The file the hash points at. Its own text carries the first half.

cat > "$LAB/report/calibration-note.txt" <<'EOF'
Deck 3 strain, tolerance note.

The summariser's ceiling was entered as a calibration value. A calibration
value is a property of an instrument. A ceiling applied to a reading is a
property of a report. The two are not the same thing and this note does not
say which one was intended.

STAGE{ceiling_is_not_calibration}

What you are looking for has two halves. The first half is the word this
note is about -- the word in the second sentence that names a property of an
instrument. The second half is one word, in station/.calibration/second,
which is readable by exactly one account. Lesson 02 showed you how to run a
command as an account that cannot log in.

Wrap the two halves in the station's usual flag format, joined by an
underscore.
EOF
printf 'matter\n' > "$LAB/station/.calibration/second"

# ------------------------------------------------------------------- stage 4

cat > "$LAB/data/decks.txt" <<'EOF'
deck-1
deck-2
deck-3
EOF

cat > "$LAB/data/faults.txt" <<'EOF'
deck-1 2
deck-2 0
deck-3 5
EOF

cat > "$LAB/bin/stationctl" <<'EOF'
#!/usr/bin/env bash
# stationctl -- station deck and fault reporting
#
# exit: 0 ok, 1 check failed (a result, not an error),
#       64 usage error, 66 data missing
set -euo pipefail

: "${STATIONCTL_DATA:=/labs/15-capstone-kestrel-breach/05-report/data}"
VERSION="stationctl 1.0"

usage() {
    cat <<USAGE
usage: stationctl COMMAND [ARGS]

commands:
  decks              list decks
  faults [DECK]      fault counts, all decks or one
  check              exit 1 if any deck is over the fault threshold

  --help             this text
  --version          version string

environment:
  STATIONCTL_DATA    data directory (default: $STATIONCTL_DATA)

exit codes:
  0   ok
  1   check failed -- a result, not an error
  64  usage error
  66  data missing
USAGE
}

need_data() {
    [ -d "$STATIONCTL_DATA" ] || {
        echo "stationctl: no data directory: $STATIONCTL_DATA" >&2; exit 66; }
    [ -f "$STATIONCTL_DATA/$1" ] || {
        echo "stationctl: missing data file: $STATIONCTL_DATA/$1" >&2; exit 66; }
}

[ $# -ge 1 ] || { usage >&2; exit 64; }

case "$1" in
    decks)   need_data decks.txt;  cat "$STATIONCTL_DATA/decks.txt" ;;
    faults)  need_data faults.txt
             if [ $# -ge 2 ]; then
                 grep -- "^$2 " "$STATIONCTL_DATA/faults.txt" ||
                     { echo "stationctl: no such deck: $2" >&2; exit 66; }
             else
                 cat "$STATIONCTL_DATA/faults.txt"
             fi ;;
    check)   need_data faults.txt
             if awk '$2 > 3 { found = 1 } END { exit !found }' \
                    "$STATIONCTL_DATA/faults.txt"; then
                 echo "stationctl: at least one deck over threshold"
                 exit 1
             fi
             echo "stationctl: all decks within threshold" ;;
    --help)    usage ;;
    --version) echo "$VERSION" ;;
    *) echo "stationctl: unknown command: $1" >&2; usage >&2; exit 64 ;;
esac
EOF
chmod 755 "$LAB/bin/stationctl"

# ---------------------------------------------------------------- the report

cat > "$LAB/report/TEMPLATE.md" <<'EOF'
# Deck 3 strain — incident report

## What happened

## When

## Who did what

## What I changed

## What would have caught this in October
EOF

cat > "$LAB/case/notes/00-carried.md" <<'EOF'
Carried forward:

- two edit clusters, 2187-05-15..17 and 2187-05-19..20
- the live summariser clamped; the backup did not
- deck3-report.txt's figures match the clamped output, not the raw sample
- the run log numbers its records without gaps, and has one
- five faults closed in lesson 04; one open item recorded, not fixed
EOF

# --------------------------------------------------- ownership, modes, mtimes

chown -Rh cadet:crew "$LAB"
chown -h ops-bot:ops "$LAB/station/.calibration" "$LAB/station/.calibration/second"
chmod 750 "$LAB/station/.calibration"
chmod 400 "$LAB/station/.calibration/second"

find "$LAB" -exec touch -h -d '2187-06-14 07:30:00' {} +
touch -h -d '2187-05-24 02:00:30' "$LAB/station/summariser/run.log"
touch -h -d '2187-05-24 04:12:00' "$LAB/evidence/handover.tar.gz"
touch -h -d '2187-05-21 02:14:00' "$LAB/report/calibration-note.txt"
