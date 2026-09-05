#!/usr/bin/env bash
# setup.sh -- seeds /labs/07-text-processing/05-awk-fields
#
# Artifacts -> exercises:
#   logs/access-2187-06-10.log   the chapter's log, byte-identical to lessons
#                        01/02/04. Space separated: date time account action deck
#   data/ragged.txt      the same records with runs of spaces and leading
#                        whitespace -> awk's default FS versus cut -d' '
#   data/roster.tsv      tab separated; one row short a field, one field with a
#                        space in it -> why -F'\t' is not optional
#   data/roster.csv      the same with a quoted comma inside a field -> the
#                        exercise that proves awk is not a CSV parser
#   data/readings.txt    deck, panel, volts, amps -> arithmetic, sums, averages
#   data/blank.txt       records separated by blank lines, embedded empty lines
#   data/short.txt       lines with 2, 3, 4 and 5 fields -> NF, $NF, $(NF-1)
#   data/mixed.txt       numbers with leading zeros and units -> string vs number
#   notes/awk.txt        the six things worth memorising
#   scratch/             empty
#
# No sub()/gsub() beyond one exercise, no arrays beyond the one counting idiom,
# no getline, no user functions. Six percent of awk, chosen because it is the
# six percent that appears in real pipelines.
set -euo pipefail

LAB=/labs/07-text-processing/05-awk-fields
rm -rf "$LAB"
mkdir -p "$LAB"/{logs,data,notes,scratch}
cd "$LAB"

# ---------------------------------------------------------------- access log
gen_access() {           # $1 = date, $2..$8 = counts, $9 = time offset
  local d="$1" off="${9:-0}" h m s t action deck i
  i=0
  emit() {
    local a="$1" n="$2"
    for _ in $(seq 1 "$n"); do
      t=$(( (i * 281 + off) % 86400 ))     # 281 coprime with 86400 -> no duplicate records
      h=$(( t / 3600 )); m=$(( (t % 3600) / 60 )); s=$(( t % 60 ))
      case $(( i % 4 )) in 0) action='read' ;; 1) action='write' ;; 2) action='read' ;; 3) action='exec' ;; esac
      deck=$(( (i / 3) % 4 + 1 ))
      printf '%s %02d:%02d:%02d %s %s deck-0%d\n' "$d" "$h" "$m" "$s" "$a" "$action" "$deck"
      i=$(( i + 1 ))
    done
  }
  emit ops-bot "$2"; emit rhea "$3"; emit cass "$4"; emit vint "$5"
  emit orla "$6"; emit bex "$7"; emit maintenance "$8"
}
gen_access 2187-06-10 412 96 54 21 12 4 1 | sort -k2,2 > logs/access-2187-06-10.log

# ---------------------------------------------------------------- ragged copy
# same records, but the column discipline is gone: leading spaces on some lines,
# runs of spaces between fields. cut -d' ' cannot read this; awk does not care.
awk 'NR > 40      { exit }
     NR % 3 == 0  { printf "   %s   %s  %s     %s   %s\n", $1,$2,$3,$4,$5; next }
     NR % 3 == 1  { printf "%s  %s %s  %s %s\n",           $1,$2,$3,$4,$5; next }
                  { print }' logs/access-2187-06-10.log > data/ragged.txt

# ---------------------------------------------------------------- roster
printf 'account\tdeck\tshift\trole\n'          > data/roster.tsv
printf 'rhea\tdeck-02\tday\tsystems\n'        >> data/roster.tsv
printf 'cass\tdeck-01\tday\tmedical\n'        >> data/roster.tsv
printf 'vint\tdeck-03\tnight\tcargo\n'        >> data/roster.tsv
printf 'orla\tdeck-02\tday\n'                 >> data/roster.tsv   # role missing
printf 'bex\tdeck-04\tnight\tgalley\n'        >> data/roster.tsv
printf 'Maintenance, Deck\tdeck-03\tday\tfacilities\n' >> data/roster.tsv   # a space inside a field

printf 'account,deck,shift,role\n'                          > data/roster.csv
printf 'rhea,deck-02,day,systems\n'                        >> data/roster.csv
printf 'cass,deck-01,day,medical\n'                        >> data/roster.csv
printf 'vint,deck-03,night,cargo\n'                        >> data/roster.csv
printf 'orla,deck-02,day,comms\n'                          >> data/roster.csv
printf 'bex,deck-04,night,galley\n'                        >> data/roster.csv
printf '"Maintenance, Deck",deck-03,day,facilities\n'      >> data/roster.csv

# ---------------------------------------------------------------- readings
# deck panel volts amps -- volts*amps is watts, and one panel is flat out.
cat > data/readings.txt <<'READ'
deck-01 panel-a 24.1 3.2
deck-01 panel-b 23.8 3.0
deck-01 panel-c 24.0 0.0
deck-02 panel-a 24.2 4.1
deck-02 panel-b 23.9 3.7
deck-03 panel-a 24.0 2.2
deck-03 panel-b 12.4 9.8
deck-03 panel-c 24.1 2.0
deck-04 panel-a 23.7 1.1
deck-04 panel-b 24.0 1.4
READ

# ---------------------------------------------------------------- odds and ends
printf 'rhea day\ncass day systems\nvint night cargo deck-03\norla day comms deck-02 senior\n' > data/short.txt

printf 'record one\nfield a\nfield b\n\nrecord two\nfield c\n\n\nrecord three\nfield d\nfield e\n' > data/blank.txt

cat > data/mixed.txt <<'MIX'
007 12V 3
010 24V 10
0100 24V 2
9 5V 40
MIX

cat > notes/awk.txt <<'NOTE'
awk, the six things.

  awk '{ print $3 }' file          fields are $1..$NF, $0 is the whole line
  awk 'NF > 3'                     a bare condition prints the line
  awk '$3 == "rhea" { print $5 }'  condition and action, either can be omitted
  awk -F'\t' '{ print $2 }'        set the field separator
  awk '{ s += $3 } END { print s }'  variables need no declaration, start at 0
  awk '{ c[$3]++ } END { for (k in c) print c[k], k }'   the counting idiom

Fields are separated by runs of whitespace unless you say otherwise, which is
why awk reads a ragged file that cut cannot.

END runs once, after the last line. NR is the record number. NF is the field
count of the current record.
NOTE

find . -exec touch -h -d '2187-06-12 08:00:00' {} +
