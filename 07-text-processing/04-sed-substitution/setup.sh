#!/usr/bin/env bash
# setup.sh -- seeds /labs/07-text-processing/04-sed-substitution
#
# Artifacts -> exercises:
#   data/counts.txt      uniq -c output, counts right-aligned in 7 -> sed 's/^ *//'
#                        This is the padding lesson 01 ex37 and lesson 02 ex45
#                        both had to live with. sed is where it finally goes.
#   data/dates.txt       DD/MM/YYYY -> backreferences rebuild them as YYYY-MM-DD
#   data/paths.txt       absolute paths -> why you change the s/// delimiter
#   data/quoted.txt      quoted fields -> greedy .* versus [^"]*
#   data/report.txt      a draft report with the usual cosmetic damage:
#                        trailing whitespace, double spaces, a stray CR, TODOs
#   data/blocks.txt      BEGIN/END delimited sections -> address ranges
#   data/roster.tsv      tab separated, for -E, capture groups and \t
#   data/case.txt        lowercase names -> GNU \U \L \u \l
#   data/amp.txt         values to wrap -> & in the replacement
#   data/nums.txt        numbers to renumber -> the Nth-occurrence flag
#   logs/access-2187-06-10.log   the chapter's log, unchanged
#   notes/style.txt      the report style rules the exercises implement
#   scratch/             empty; the -i exercises write here
#
# No awk. Anything needing a computed value, a comparison or a running total is
# lesson 05. sed here is substitution, addresses, p/d, and -i.
set -euo pipefail

LAB=/labs/07-text-processing/04-sed-substitution
rm -rf "$LAB"
mkdir -p "$LAB"/{logs,data,notes,scratch}
cd "$LAB"

gen_access() {
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
gen_access 2187-06-10 412 96 54 21 12 4 1 | sort -k2,2 > logs/access-2187-06-10.log

cut -d' ' -f3 logs/access-2187-06-10.log | sort | uniq -c | sort -rn > data/counts.txt

printf '%s\n' \
'10/06/2187 hull sweep' \
'11/06/2187 filter change' \
'03/12/2186 panel swap' \
'18/01/2187 access review' \
'07/07/2187 galley inventory' \
> data/dates.txt

printf '%s\n' \
'/var/log/station/access.log' \
'/var/log/station/panel.log' \
'/opt/kestrel/bin/kestrel' \
'/home/cadet/notes/forms.txt' \
> data/paths.txt

printf '%s\n' \
'deck-01 "sealed" 2187-06-10 "routine"' \
'deck-02 "open" 2187-06-10 "routine"' \
'deck-03 "sealed" 2187-06-10 "manual override"' \
'deck-04 "open" 2187-06-10 "routine"' \
> data/quoted.txt

# trailing spaces, a double space, one CRLF line, TODO markers
printf 'Access review, draft   \nprepared by the  duty officer\r\nTODO check the tail   \nDeck 01 sealed  at 04:00\nTODO confirm with ops\nEnd of draft \n' > data/report.txt

printf '%s\n' \
'preamble line' \
'BEGIN summary' \
'ops-bot dominates every count' \
'nothing else is remarkable' \
'END summary' \
'middle line' \
'BEGIN appendix' \
'raw counts follow' \
'END appendix' \
'trailing line' \
> data/blocks.txt

printf '%s\n' \
'account	deck	shift	role' \
'rhea	deck-02	day	systems' \
'cass	deck-01	day	medical' \
'vint	deck-03	night	cargo' \
'orla	deck-02	day	comms' \
'bex	deck-04	night	galley' \
> data/roster.tsv

printf '%s\n' rhea cass vint orla bex ops-bot maintenance > data/case.txt

printf '%s\n' 41 193 2187 7 412 96 > data/amp.txt

printf '%s\n' \
'panel 1 of 1 in bay 1' \
'panel 2 of 4 in bay 1' \
'panel 3 of 4 in bay 2' \
> data/nums.txt

cat > notes/style.txt <<'NOTE'
Report style, station standard, second page.

No trailing whitespace. It is invisible, it survives every copy, and it makes
two identical lines compare unequal.

One space between words. Two is a typing habit from paper and it breaks
every tool that splits on a single space.

Dates are YYYY-MM-DD. Not because it is prettier but because it sorts.
Any other order sorts into nonsense and somebody will sort it.

Leave no TODO in a filed report. If it is not done, say what is not done in
a sentence, in the report, where the reader will see it.
NOTE

find . -exec touch -h -d '2187-06-12 08:00:00' {} +
