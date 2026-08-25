#!/usr/bin/env bash
# setup.sh -- seeds /labs/06-searching/02-grep-flags
#
# Artifacts -> exercises:
#   reports/            three daily reports, numbered entries, one per deck
#                       -> -n, -c, -l, -L, -A/-B/-C context exercises
#   reports/quiet.log   a file that mentions no fault at all -> -L
#   archive/            older copies, same names, so -r finds duplicates -> -r,
#                       --include, --exclude-dir
#   archive/.cache/     junk that must be excluded -> --exclude-dir
#   words.txt           bay / bays / embayed / BAY etc -> -w and -x
#   codes.txt           one code per line plus lines that CONTAIN a code -> -x
#   readings.csv        comma-separated, values to pull out with -o
#   scratch/            student space
#
# The -o exercises are deliberately built on a field that repeats within a
# line, so `grep -c` and `grep -o | wc -l` disagree by construction.
#
# Idempotent: removes its own tree first, creates nothing outside LAB.
set -euo pipefail

LAB="/labs/06-searching/02-grep-flags"
rm -rf "$LAB"
mkdir -p "$LAB"/{reports,archive/.cache,scratch}
cd "$LAB"

########## reports ##########
mk_report() {
    # $1 date, $2 deck, $3 number of entries, $4 entry numbers that fault
    # deck-03 reports put two detail lines after each FAULT; deck-04 has none.
    local d="$1" deck="$2" n="$3" faults="$4" i num
    printf 'run report %s, deck %s\n' "$d" "$deck"
    printf 'generated 04:00, entries numbered from 001\n'
    for i in $(seq -w 1 "$n"); do
        num=$(printf '%03d' "$((10#$i))")
        if printf '%s\n' $faults | grep -qx "$((10#$i))"; then
            printf '%s  entry %s  bay-%02d  FAULT strain above limit\n' "$d" "$num" "$(( 10#$i % 8 + 1 ))"
            if [ "$deck" = 03 ]; then
                printf '%s  entry %s  detail  peak 0.%02d held %ds\n' "$d" "$num" "$(( 70 + 10#$i % 9 ))" "$(( 10#$i * 3 ))"
                printf '%s  entry %s  detail  cleared by hand\n' "$d" "$num"
            fi
        else
            printf '%s  entry %s  bay-%02d  ok\n' "$d" "$num" "$(( 10#$i % 8 + 1 ))"
        fi
    done
    printf 'end of report, %03d entries\n' "$((10#$n))"
}

mk_report 2187-06-08 03 30 '7
19' > reports/deck-03-2187-06-08.log
mk_report 2187-06-09 03 30 '7
8
9
22' > reports/deck-03-2187-06-09.log
mk_report 2187-06-09 04 30 '' > reports/deck-04-2187-06-09.log

cat > reports/quiet.log <<'EOF'
run report 2187-06-09, deck 05
generated 04:00, entries numbered from 001
2187-06-09  entry 001  bay-01  ok
2187-06-09  entry 002  bay-02  ok
2187-06-09  entry 003  bay-03  ok
end of report, 003 entries
EOF

cat > reports/notes.txt <<'EOF'
The reports number their own entries. That is deliberate: an unnumbered
record cannot tell you that something is missing, only that it is absent,
and those are not the same claim.

A FAULT line is always followed by two lines of detail in the deck-03
reports and by nothing at all in deck-04, because deck-04 was never fitted
with the detail sensor.
EOF

########## archive ##########
cp reports/deck-03-2187-06-08.log archive/deck-03-2187-06-08.log
sed 's/FAULT/fault/' reports/deck-03-2187-06-09.log > archive/deck-03-2187-06-09.log
cp reports/quiet.log archive/quiet.log
printf 'index rebuilt\nFAULT\n' > archive/.cache/index.tmp
printf 'FAULT FAULT FAULT\n' > archive/.cache/scan.tmp
printf 'archive index, deck 03 and deck 04, 2187-06\n' > archive/index.txt

########## words ##########
cat > words.txt <<'EOF'
bay
bays
bay-01
embayed
BAY
subbay
bay.
the bay is clear
bay bay bay
EOF

cat > codes.txt <<'EOF'
E-104
E-1041
xE-104
E-104 confirmed
E-104
 E-104
E-105
EOF

########## readings ##########
{
  printf 'deck,bay,strain,strain,note\n'
  for i in $(seq -w 1 20); do
    printf '0%d,bay-%02d,0.%02d,0.%02d,ok\n' \
      "$(( 10#$i % 4 + 1 ))" "$(( 10#$i % 8 + 1 ))" \
      "$(( 40 + 10#$i ))" "$(( 51 + 10#$i % 9 ))"
  done
} > readings.csv

########## timestamps ##########
touch -d '2187-06-09 04:00:00' reports/*.log
touch -d '2187-06-09 09:00:00' reports/notes.txt
touch -d '2187-06-02 04:00:00' archive/*.log archive/index.txt
touch -d '2187-06-09 04:05:00' archive/.cache/*
touch -d '2187-05-30 12:00:00' words.txt codes.txt readings.csv

echo "seeded $LAB"
