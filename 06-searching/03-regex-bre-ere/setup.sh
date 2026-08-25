#!/usr/bin/env bash
# setup.sh -- seeds /labs/06-searching/03-regex-bre-ere
#
# Artifacts -> exercises:
#   ids.txt        station identifiers, most well formed, some not -> anchors,
#                  classes, quantifiers, and the difference between "contains"
#                  and "is"
#   log.txt        one mixed log with three timestamp formats -> alternation,
#                  \{n\}, and why BRE needs backslashes
#   pairs.txt      lines with a repeated word or code -> backreferences \(..\)\1
#   spacing.txt    the same record written with tabs, single and multiple spaces
#   greedy.txt     lines with several bracketed fields -> greedy .* with -o
#   dots.txt       lines that contain literal dots and lines that do not
#   scratch/       student space
#
# Everything here is BRE-first. ERE (-E) is introduced as the same language with
# a different escaping convention, not as a more powerful one. -P is mentioned
# in the readme and used in exactly one exercise, as a warning.
#
# Idempotent: removes its own tree first, creates nothing outside LAB.
set -euo pipefail

LAB="/labs/06-searching/03-regex-bre-ere"
rm -rf "$LAB"
mkdir -p "$LAB/scratch"
cd "$LAB"

cat > ids.txt <<'EOF'
BAY-01
BAY-02
BAY-13
BAY-7
BAY-007
bay-04
BAY-01-A
PANEL-03
PANEL-11
PANEL-3B
DECK-03
DECK-3
BAY-
-BAY-05
BAY-05 spare
 BAY-06
BAY_07
BAY-99
EOF

cat > log.txt <<'EOF'
2187-06-09 04:00:00 report start
2187-06-09 04:00:01 entry 001 ok
09/06/2187 04:00:02 entry 002 ok
2187-06-09 04:00:03 entry 003 FAULT
04:00:04 entry 004 ok
2187-06-09 04:00:05 entry 005 ok
09/06/2187 04:00:06 entry 006 FAULT
04:00:07 entry 007 ok
2187-06-09 04:00:08 entry 008 ok
2187-6-9 04:00:09 entry 009 ok
2187-06-09 4:00:10 entry 010 ok
2187-06-09 04:00:11 report end
EOF

cat > pairs.txt <<'EOF'
strain strain reported twice
bay-01 bay-01 duplicated
panel 03 panel 04 different
the the cat
report reported
E-104 E-104
E-104 E-105
ok ok ok
one two three
EOF

printf 'deck\t03\tbay\t01\tok\n'      > spacing.txt
printf 'deck 03 bay 01 ok\n'         >> spacing.txt
printf 'deck  03  bay  01  ok\n'     >> spacing.txt
printf 'deck   03\tbay 01  ok\n'     >> spacing.txt
printf 'deck03bay01ok\n'             >> spacing.txt
printf 'deck \t 03 bay 01 ok\n'      >> spacing.txt

cat > greedy.txt <<'EOF'
[alpha] plain [beta] plain [gamma]
[one] [two]
[only]
no brackets here
[unclosed and then [closed]
EOF

cat > dots.txt <<'EOF'
0.41
0x41
0-41
041
0.4.1
strain 0.41 nominal
version 1.2.3
no dots at all
.
..
EOF

touch -d '2187-06-09 10:00:00' ids.txt log.txt pairs.txt spacing.txt greedy.txt dots.txt

echo "seeded $LAB"
