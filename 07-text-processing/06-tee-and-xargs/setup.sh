#!/usr/bin/env bash
# setup.sh -- seeds /labs/07-text-processing/06-tee-and-xargs
#
# Artifacts -> exercises:
#   logs/access-2187-06-10.log   the chapter's log, unchanged
#   logs/access-2187-06-09.log   the day before, same generator, different mix
#   data/accounts.txt    seven account names, one per line -> xargs -n, -I
#   data/awkward/        four files whose names contain a space, a newline,
#                        a quote and a leading dash -> why -0 and -- exist
#   data/empty.txt       zero bytes -> xargs with no input runs the command anyway
#   reports/             empty; tee writes here
#   scratch/             empty
#
# No find beyond the -print0 pairing (chapter 6 owns find). No parallelism,
# no xargs -P: this lesson is about where output goes and how arguments are
# built, not about speed.
set -euo pipefail

LAB=/labs/07-text-processing/06-tee-and-xargs
rm -rf "$LAB"
mkdir -p "$LAB"/{logs,data,reports,scratch}
cd "$LAB"

gen_access() {           # $1 = date, $2..$8 = counts, $9 = time offset
  local d="$1" off="${9:-0}" h m s t action deck i
  i=0
  emit() {
    local a="$1" n="$2" k
    for k in $(seq 1 "$n"); do
      t=$(( (i * 281 + off) % 86400 ))
      h=$(( t / 3600 )); m=$(( (t % 3600) / 60 )); s=$(( t % 60 ))
      case $(( i % 4 )) in 0) action=read ;; 1) action=write ;; 2) action=read ;; 3) action=exec ;; esac
      deck=$(( (i / 3) % 4 + 1 ))
      printf '%s %02d:%02d:%02d %s %s deck-0%d\n' "$d" "$h" "$m" "$s" "$a" "$action" "$deck"
      i=$(( i + 1 ))
    done
  }
  emit ops-bot "$2"; emit rhea "$3"; emit cass "$4"; emit vint "$5"
  emit orla "$6"; emit bex "$7"; emit maintenance "$8"
}
gen_access 2187-06-10 412 96 54 21 12 4 1     | sort -k2,2 > logs/access-2187-06-10.log
gen_access 2187-06-09 388 74 61 18 9 6 0 4211 | sort -k2,2 > logs/access-2187-06-09.log

printf 'ops-bot\nrhea\ncass\nvint\norla\nbex\nmaintenance\n' > data/accounts.txt

mkdir -p data/awkward
: > 'data/awkward/panel log.txt'
: > "data/awkward/it's a report.txt"
: > 'data/awkward/-n'
touch 'data/awkward/two
lines.txt'

: > data/empty.txt

find . -exec touch -h -d '2187-06-12 08:00:00' {} +
