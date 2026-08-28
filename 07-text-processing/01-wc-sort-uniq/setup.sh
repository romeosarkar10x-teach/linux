#!/usr/bin/env bash
# setup.sh -- seeds /labs/07-text-processing/01-wc-sort-uniq
#
# Artifacts -> exercises:
#   logs/access-2187-06-10.log  account access records, "date time account action deck"
#                               600 lines. ops-bot dominates. Feeds the
#                               sort|uniq -c|sort -rn idiom, and previews the
#                               shape of the chapter's incident without spoiling it.
#   logs/access-2187-06-11.log  second day, so wc gets more than one file and prints
#                               a total line
#   logs/no-newline.log         3 lines of text, LAST LINE HAS NO \n -> wc -l says 2
#   logs/wide.log               one very long line -> wc -L
#   data/decks.txt              unsorted, has duplicates, mixed case -> sort -u vs -fu
#   data/sizes.txt              plain integers with a header-free format -> sort -n
#   data/sizes-h.txt            1K/2M/512/1.5G -> sort -h, and what -n does to them
#   data/versions.txt           v1.9 v1.10 v1.2 -> sort -V vs sort vs sort -n
#   data/duty.txt               "account deck shift" columns -> sort -k and -t
#   data/tasks.txt          TAB separated with a space INSIDE field 2 -> why -t matters
#   data/ties.txt               same key, different payload -> stability, sort -s
#   data/adjacent.txt           duplicates that are NOT adjacent -> uniq's one rule
#   data/nums-mixed.txt         leading spaces and negatives -> sort -n vs -b
#   scratch/                    empty, for the student's own files
#
# No cut/awk/sed here. Field selection in this lesson is sort's -k/-t only;
# lesson 02 owns cut. Anything a student would reach for awk to do, they are
# meant to feel the absence of.
#
# Idempotent: removes its own tree first, creates nothing outside LAB.
set -euo pipefail

LAB="/labs/07-text-processing/01-wc-sort-uniq"
rm -rf "$LAB"
mkdir -p "$LAB"/{logs,data,notes,scratch}
cd "$LAB"

########## access logs ##########
# Counts are chosen so the ranked report has an unambiguous order and one
# account with a count of exactly 1. That shape is the chapter's whole subject.
gen_access() {           # $1 = date
  local d="$1" off="${9:-0}" h m s t action deck i
  i=0
  emit() {               # $1 = account, $2 = how many
    local a="$1" n="$2" k
    for k in $(seq 1 "$n"); do
      # 281 is coprime with 86400, so every entry gets a distinct time-of-day
      # and the log contains no two identical records.
      t=$(( (i * 281 + off) % 86400 ))
      h=$(( t / 3600 )); m=$(( (t % 3600) / 60 )); s=$(( t % 60 ))
      case $(( i % 4 )) in
        0) action=read ;;
        1) action=write ;;
        2) action=read ;;
        3) action=exec ;;
      esac
      deck=$(( (i / 3) % 4 + 1 ))
      printf '%s %02d:%02d:%02d %s %s deck-0%d\n' "$d" "$h" "$m" "$s" "$a" "$action" "$deck"
      i=$(( i + 1 ))
    done
  }
  emit ops-bot "$2"
  emit rhea "$3"
  emit cass "$4"
  emit vint "$5"
  emit orla "$6"
  emit bex "$7"
  emit maintenance "$8"
}
gen_access 2187-06-10 412 96 54 21 12 4 1 | sort -k2,2 > logs/access-2187-06-10.log
gen_access 2187-06-11 380 88 61 17 9 6 2 617 | sort -k2,2 > logs/access-2187-06-11.log

# accounts-week.txt: one account name per line and nothing else -- a real
# export from the access system, and the only file in this lesson the
# sort|uniq -c|sort -rn idiom can be pointed at directly. The log cannot:
# counting a *column* of a multi-column file needs lesson 02.
{
  emit_names() { local a="$1" n="$2" k; for k in $(seq 1 "$n"); do printf '%s\n' "$a"; done; }
  emit_names rhea 61
  emit_names ops-bot 148
  emit_names cass 33
  emit_names orla 9
  emit_names vint 14
  emit_names bex 3
  emit_names sensor-cal 1
  emit_names maintenance 2
} | shuf --random-source=<(yes kestrel) > data/accounts-week.txt

########## wc corner cases ##########
printf 'first line\nsecond line\nthird line with no newline' > logs/no-newline.log
{
  printf 'short\n'
  printf 'strain sensor bank A reported nominal at every sampling interval across the full run window and the summariser had nothing to say about it, which is the least interesting sentence in this entire lab and exists only so that one line is longer than the others\n'
  printf 'also short\n'
} > logs/wide.log

########## sort corner cases ##########
{
  printf 'deck-03\ndeck-01\nDeck-03\ndeck-02\ndeck-01\ndeck-04\nDECK-02\ndeck-03\n'
} > data/decks.txt

{
  printf '9\n10\n100\n2\n21\n3\n1000\n11\n'
} > data/sizes.txt

{
  printf '1K\n2M\n512\n1.5G\n900\n3K\n'
} > data/sizes-h.txt

{
  printf 'v1.9\nv1.10\nv1.2\nv1.21\nv2.0\nv1.1\n'
} > data/versions.txt

# duty.txt: TAB-separated, on purpose. sort's default field separator is not
# "tab" and is not "space" -- it is the transition from non-blank to blank --
# and this file is where that stops being trivia.
{
  printf 'rhea\tdeck-03\tday\n'
  printf 'cass\tdeck-01\tday\n'
  printf 'vint\tdeck-04\tnight\n'
  printf 'orla\tdeck-02\tday\n'
  printf 'bex\tdeck-03\tnight\n'
  printf 'ops-bot\tdeck-01\tnight\n'
  printf 'maintenance\tdeck-03\tnight\n'
} > data/duty.txt

# tasks.txt: TAB separated, and field 2 CONTAINS SPACES. This is the file where
# -t$'\t' stops being decoration: without it, sort's default field splitting cuts
# field 2 in half at the space and -k2,2 sorts on the wrong thing.
{
  printf 'cass\tdaily comms summary\t2\n'
  printf 'rhea\tstrain audit\t1\n'
  printf 'vint\tstores audit\t3\n'
  printf 'orla\tdaily medical check\t2\n'
  printf 'bex\tstrain review\t1\n'
} > data/tasks.txt

# ties.txt: same first field, different second. Order as written matters for
# the stability exercises, so do not sort this at build time.
{
  printf '3 charlie\n1 delta\n2 bravo\n3 alpha\n1 echo\n2 foxtrot\n3 bravo\n'
} > data/ties.txt

{
  printf 'alpha\nbravo\nalpha\ncharlie\nbravo\nalpha\ndelta\n'
} > data/adjacent.txt

{
  printf '  12\n-3\n7\n  -20\n0\n  5\n-3\n'
} > data/nums-mixed.txt

########## notes ##########
{
  printf 'Reporting notes -- read before you build anything\n'
  printf '\n'
  printf 'The captain asks for "the access numbers" about once a month. What that\n'
  printf 'has meant every time so far: one line per account, a count, sorted so the\n'
  printf 'busiest is at the top. Nobody has ever asked for the tail of that list.\n'
  printf '\n'
  printf 'Two things that have burned people here:\n'
  printf '  - uniq only collapses lines that are next to each other. It is not a\n'
  printf '    duplicate finder. Sort first or it will lie to you quietly.\n'
  printf '  - sort compares text unless you tell it otherwise. 10 sorts before 9.\n'
  printf '\n'
  printf 'The duty roster is tab separated. Most of the logs are space separated.\n'
  printf 'Nothing enforces this and nothing ever will.\n'
} > notes/reporting.txt

find . -exec touch -h -d '2187-06-12 08:00:00' {} +
