#!/usr/bin/env bash
# setup.sh -- seeds /labs/06-searching/01-grep-basics
#
# Artifacts -> exercises:
#   logs/comms-2187-06-10.log   cass's traffic. 240 lines, mixed case, the word
#                               "error" appears as Error/ERROR/error -> -i exercises
#   logs/panel-2187-06-10.log   short, 40 lines, has lines with no match at all
#   logs/strain-2187-06-10.log  numeric readings, for anchors and word matching
#   logs/empty.log              zero bytes -- grep exit status 1, no output
#   notes/handover.txt          contains the literal string "grep" and a line with
#                               a leading dash -> the `--` / `-e` exercises
#   notes/patterns.txt          holds patterns, one per line -> grep -f
#   notes/binary.dat            has a NUL byte -> "Binary file ... matches"
#   crew.txt                    60 lines: name:role:deck, for fixed-string matching
#
# No regex metacharacters are taught here beyond what a student needs to be
# bitten by them -- lesson 03 owns BRE/ERE. This lesson is: pattern, file,
# case, exit status, and what grep does when you give it more than one file.
#
# Idempotent: removes its own tree first, creates nothing outside LAB.
set -euo pipefail

LAB="/labs/06-searching/01-grep-basics"
rm -rf "$LAB"
mkdir -p "$LAB"/{logs,notes,scratch}
cd "$LAB"

########## crew.txt ##########
{
  printf 'rhea:systems:deck-03\n'
  printf 'cass:comms:deck-01\n'
  printf 'vint:stores:deck-04\n'
  printf 'orla:medical:deck-02\n'
  printf 'bex:structural:deck-03\n'
  for i in $(seq -w 1 55); do
    printf 'crew-%s:general:deck-0%d\n' "$i" "$(( (10#$i % 4) + 1 ))"
  done
} > crew.txt

########## comms log ##########
{
  h=0; m=0; t=0
  for i in $(seq -w 1 240); do
    t=$(( (10#$i - 1) * 6 )); m=$(( t % 60 )); h=$(( t / 60 ))
    case $(( 10#$i % 12 )) in
      0) sev='ERROR';   msg='relay handshake refused' ;;
      3) sev='Error';   msg='retry queued' ;;
      6) sev='error';   msg='downlink window missed' ;;
      1|7) sev='WARN';  msg='buffer above 80 percent' ;;
      *) sev='INFO';    msg='traffic nominal' ;;
    esac
    printf '2187-06-10 %02d:%02d:00  comms  %-5s  %s\n' "$h" "$m" "$sev" "$msg"
  done
} > logs/comms-2187-06-10.log

########## panel log ##########
{
  for i in $(seq -w 1 40); do
    printf '2187-06-10 %02d:00:00  panel-%02d  reading ok\n' "$(( 10#$i % 24 ))" "$(( 10#$i % 12 + 1 ))"
  done
} > logs/panel-2187-06-10.log

########## strain log ##########
{
  for i in $(seq -w 1 60); do
    v=$(( 40 + 10#$i % 37 ))
    printf 'bay-%02d strain 0.%02d\n' "$(( 10#$i % 8 + 1 ))" "$v"
  done
} > logs/strain-2187-06-10.log

: > logs/empty.log

########## notes ##########
cat > notes/handover.txt <<'EOF'
handover, comms to engineering, 2187-06-10

The overnight report is generated at 0400 and mailed to nobody.
If you want to know whether it ran, grep the run log for the word "run".
-v is not a flag we use here. It is a note somebody left, and this line
starts with a dash on purpose.
Panel 03 has been reading high. Panel 3 is the same panel; the log is
inconsistent about the leading zero and always has been.
EOF

cat > notes/patterns.txt <<'EOF'
ERROR
WARN
downlink
EOF

printf 'strain readings, packed\n\x00\x01\x02binary payload ERROR marker\n' > notes/binary.dat

########## timestamps ##########
touch -d '2187-06-10 23:59:00' logs/*.log
touch -d '2187-06-10 18:00:00' notes/handover.txt notes/patterns.txt notes/binary.dat
touch -d '2187-06-01 09:00:00' crew.txt

echo "seeded $LAB"
