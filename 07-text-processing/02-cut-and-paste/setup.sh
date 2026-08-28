#!/usr/bin/env bash
# setup.sh -- seeds /labs/07-text-processing/02-cut-and-paste
#
# Artifacts -> exercises:
#   logs/access-2187-06-10.log  same shape as lesson 01, space separated, 5 fields.
#                               cut -d' ' -f3 finally answers the question lesson 01
#                               could not: per-account counts.
#   data/roster.tsv             TAB separated -> cut's native input, no -d needed
#   data/roster.csv             the same roster as CSV, and ONE record has a comma
#                               inside a quoted field -> cut gets it wrong, silently.
#                               This is the lesson's honest limitation.
#   data/aligned.txt            columns aligned with RUNS of spaces -> cut -d' ' fails
#                               because cut does not collapse delimiters; cut -c works
#                               only while the alignment holds.
#   data/ragged.txt             the same data, alignment broken on two lines -> cut -c
#                               produces garbage that still looks like data
#   data/short.tsv              some rows have fewer fields -> what cut does with a
#                               missing field, and what -s does about lines with no
#                               delimiter at all
#   data/ids.txt data/names.txt data/decks.txt   three parallel single-column files
#                               of EQUAL length -> paste
#   data/extra.txt              a fourth file, DIFFERENT length -> paste pads
#   data/flat.txt               one value per line -> paste -s to fold into a row
#   notes/columns.txt           the note the chapter's report style comes from
#   scratch/                    empty
#
# No awk and no sed here. Anything requiring a computed field or a regex belongs
# to lessons 04 and 05; this lesson is deliberately limited to positional cutting
# and positional joining, so that its failures are felt.
set -euo pipefail

LAB=/labs/07-text-processing/02-cut-and-paste
rm -rf "$LAB"
mkdir -p "$LAB"/{logs,data,notes,scratch}
cd "$LAB"

# ---- access log (same generator as lesson 01, same day, identical file) ----
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

# ---- roster, twice ----
# Note the second field of the last record contains a comma. In the TSV it is
# just text; in the CSV it is inside quotes and cut cannot see the difference.
printf '%s\n' \
'id	name	deck	shift	role' \
'1	Rhea	deck-02	day	systems' \
'2	Cass	deck-01	day	medical' \
'3	Vint	deck-03	night	cargo' \
'4	Orla	deck-02	day	comms' \
'5	Bex	deck-04	night	galley' \
'6	Ops-Bot	deck-01	night	automation' \
'7	Maintenance, Deck	deck-03	day	facilities' \
> data/roster.tsv

printf '%s\n' \
'id,name,deck,shift,role' \
'1,Rhea,deck-02,day,systems' \
'2,Cass,deck-01,day,medical' \
'3,Vint,deck-03,night,cargo' \
'4,Orla,deck-02,day,comms' \
'5,Bex,deck-04,night,galley' \
'6,Ops-Bot,deck-01,night,automation' \
'7,"Maintenance, Deck",deck-03,day,facilities' \
> data/roster.csv

# ---- aligned columns: runs of spaces, fixed width ----
# Columns start at characters 1, 11, 21, 31.
printf '%-10s%-10s%-10s%s\n' \
  account deck shift role \
  rhea deck-02 day systems \
  cass deck-01 day medical \
  vint deck-03 night cargo \
  orla deck-02 day comms \
  bex deck-04 night galley \
  > data/aligned.txt

# ---- same data, two rows out of alignment ----
{
  printf '%-10s%-10s%-10s%s\n' account deck shift role
  printf '%-10s%-10s%-10s%s\n' rhea deck-02 day systems
  printf '%s %s %s %s\n'        cass deck-01 day medical
  printf '%-10s%-10s%-10s%s\n' vint deck-03 night cargo
  printf '%-12s%-8s%-10s%s\n'  orla deck-02 day comms
  printf '%-10s%-10s%-10s%s\n' bex deck-04 night galley
} > data/ragged.txt

# ---- rows with missing fields, and one line with no delimiter at all ----
printf '%s\n' \
'rhea	deck-02	day' \
'cass	deck-01' \
'vint' \
'orla	deck-02	day' \
'-- end of extract --' \
> data/short.tsv

# ---- parallel columns for paste ----
printf '%s\n' 1 2 3 4 5 > data/ids.txt
printf '%s\n' rhea cass vint orla bex > data/names.txt
printf '%s\n' deck-02 deck-01 deck-03 deck-02 deck-04 > data/decks.txt
printf '%s\n' systems medical cargo > data/extra.txt
printf '%s\n' 12 7 31 4 19 2 > data/flat.txt

cat > notes/columns.txt <<'NOTE'
Report style, station standard.

Columns are separated by a single tab. Not spaces. Every tool on this station
reads tabs by default and something will eventually read your report with one
of them.

Do not align columns with spaces to make them look nice in your terminal. The
alignment is for your eyes and it is the first thing to break when a value gets
longer than you expected. Let whoever is reading it pass the file through
column -t if they want it pretty.

If a value can contain the separator, the separator is wrong. Pick another one.
NOTE

find . -exec touch -h -d '2187-06-12 08:00:00' {} +
