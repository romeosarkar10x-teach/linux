#!/usr/bin/env bash
# setup.sh -- seeds /labs/04-creating-copying-destroying/01-cat-and-friends
#
# Artifacts -> exercises:
#   logs/comms-0517.log     120 numbered-by-content lines, 6 of them blank, 3 consecutive blanks
#                           in one place -> cat -n vs nl (nl skips blanks by default), cat -s
#   logs/deck3-strain.csv   40 lines, each ~300 chars -> less horizontal scroll, -S in less
#   logs/roster.txt         5000 lines, "crew NNNN ..." -> head/tail/less line addressing, wc -l
#   logs/panel-07.log       12 lines, tail -n +N and tac
#   notes/no-newline.txt    ends WITHOUT a newline -> cat glues the prompt on, cat -e shows no $
#   notes/tabs.txt          real tabs -> cat -T, expand
#   notes/crlf.txt          CRLF line endings -> cat -A shows ^M$; nothing else reveals it
#   notes/mixed.txt         one 0x07 BEL and one 0xE9 (latin-1) -> cat -v, and a terminal beep
#   notes/blank-run.txt     nine consecutive blank lines -> cat -s
#   fragments/              three numbered fragments, meant to be cat'd together in order;
#                           fragments/03 is the one that reads correctly only under tac
#   feed/                   empty at seed time; the tail -f exercises create feed/live.log
#
# Story: these are comms and deck logs from 2187-05-17, the day the Chapter 4 manifest was
# written. Nothing here is a trace. The manifest itself is lesson 05's lab.
#
# Idempotent: removes its own tree first, creates nothing outside LAB.
set -euo pipefail

LAB="/labs/04-creating-copying-destroying/01-cat-and-friends"
rm -rf "$LAB"
mkdir -p "$LAB"/{logs,notes,fragments,feed}
cd "$LAB"

# --- comms log: 120 lines, blanks scattered, one run of three -----------------
{
  i=1
  while [ $i -le 120 ]; do
    case $i in
      17|43|88) printf '\n' ;;
      60|61|62) printf '\n' ;;
      *) printf '2187-05-17 %02d:%02d  comms  channel %d handshake ok\n' \
           $(( (i / 6) % 24 )) $(( (i * 7) % 60 )) $(( (i % 9) + 1 )) ;;
    esac
    i=$(( i + 1 ))
  done
} > logs/comms-0517.log

# --- wide CSV: 40 rows, each row well past 80 columns -------------------------
{
  printf 'ts'
  for c in $(seq 1 24); do printf ',bay%02d_strain' "$c"; done
  printf '\n'
  for r in $(seq 1 40); do
    printf '2187-05-17T%02d:00' $(( r % 24 ))
    for c in $(seq 1 24); do printf ',0.%03d' $(( (r * c * 7) % 1000 )); done
    printf '\n'
  done
} > logs/deck3-strain.csv

# --- 5000-line roster ---------------------------------------------------------
awk 'BEGIN { for (i = 1; i <= 5000; i++)
        printf "crew %04d  deck %d  shift %d\n", i, (i % 6) + 1, (i % 3) + 1 }' \
  > logs/roster.txt

cat > logs/panel-07.log <<'EOF'
2187-05-17 04:02  panel-07  power on
2187-05-17 04:03  panel-07  self-test start
2187-05-17 04:03  panel-07  self-test pass
2187-05-17 04:07  panel-07  strain 0.41
2187-05-17 04:12  panel-07  strain 0.43
2187-05-17 04:19  panel-07  strain 0.42
2187-05-17 05:01  panel-07  operator ack
2187-05-17 05:44  panel-07  strain 0.44
2187-05-17 06:30  panel-07  summariser input ok
2187-05-17 07:15  panel-07  strain 0.41
2187-05-17 08:02  panel-07  shift handover
2187-05-17 08:03  panel-07  idle
EOF

# --- notes --------------------------------------------------------------------
printf 'the last line of this file has no newline on the end of it' \
  > notes/no-newline.txt

printf 'deck\tbay\tstrain\n3\t4\t0.41\n3\t5\t0.44\n11\t1\t0.39\n' > notes/tabs.txt

printf 'received 05-17\r\nlogged 05-17\r\nfiled 05-18\r\n' > notes/crlf.txt

printf 'alarm test:\007 and a latin-1 e-acute: \351\ndone\n' > notes/mixed.txt

{ printf 'before\n'; for i in $(seq 1 9); do printf '\n'; done; printf 'after\n'; } \
  > notes/blank-run.txt

# --- fragments: reassembled with cat, one of them stored backwards ------------
printf 'deck 3 console handover, part one:\nthe panel was reseated at 04:02.\n' \
  > fragments/01-head.txt
printf 'part two:\nself-test passed on the first attempt.\n' \
  > fragments/02-body.txt
# Written last line first, on purpose. Reads correctly only through tac.
printf 'and that is the whole of part three.\nthe summariser accepted the input at 06:30,\npart three:\n' \
  > fragments/03-tail.txt

touch -d '2187-05-17 08:05:00' logs/comms-0517.log logs/panel-07.log
touch -d '2187-05-17 09:00:00' logs/deck3-strain.csv logs/roster.txt
touch -d '2187-05-17 09:30:00' notes/*.txt fragments/*.txt

echo "seeded $LAB"
