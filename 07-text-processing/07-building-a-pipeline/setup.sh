#!/usr/bin/env bash
# setup.sh -- seeds /labs/07-text-processing/07-building-a-pipeline
#
# Artifacts -> exercises:
#   logs/access-2187-06-10.log   the chapter's log, unchanged from lesson 01
#   logs/maint-raw.txt           a real-shaped maintenance dump: key=value fields,
#                                comments, blank lines, a severity column, two
#                                trailing junk lines. The nine-stage pipeline is
#                                built against this, one stage at a time.
#   data/panels.csv              panel letter -> criticality -> owner, for a
#                                lookup by hand (awk array, no join(1): out of
#                                scope). Deliberately missing p-d's owner.
#   notes/method.txt             the method in six lines, written down so the
#                                student can check themselves against it
#   notes/broken.txt             five pipelines that are wrong in five different
#                                ways -> the debugging half of the lesson
#   reports/                     empty; finished pipelines write here
#   scratch/                     empty; stage-by-stage output lands here
#
# Everything is derived from the access log by a deterministic rule, so every
# count in solutions.md can be checked two ways.
set -euo pipefail

LAB=/labs/07-text-processing/07-building-a-pipeline
rm -rf "$LAB"
mkdir -p "$LAB"/{logs,data,notes,reports,scratch}
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

gen_access 2187-06-10 412 96 54 21 12 4 1 | sort -k2,2 > logs/access-2187-06-10.log

# ---- the maintenance dump ------------------------------------------------
# Derived from the access log so the answers are checkable: every 5th record
# becomes a maintenance line, severity cycles INFO/WARN/ERROR by position,
# and the panel letter is a function of the second.
{
  printf '# maintenance daemon dump -- deck panels\n'
  printf '# fields are key=value, order is not guaranteed\n'
  printf '\n'
  awk 'NR % 5 == 1 {
         n++
         sev = (n % 9 == 0) ? "ERROR" : ((n % 3 == 0) ? "WARN " : "INFO ")
         split($2, t, ":")
         letter = substr("abcd", (t[3] % 4) + 1, 1)
         printf "%sT%sZ  [%s] panel=%s/p-%s actor=%s action=%s dur=%dms\n",
                $1, $2, sev, $5, letter, $3, $4, (t[3] * 7) % 900 + 12
         if (n % 40 == 0) printf "\n"
       }' logs/access-2187-06-10.log
  printf '# end of dump\n'
  printf 'dump complete: rc=0\n'
} > logs/maint-raw.txt

cat > data/panels.csv <<'CSV'
panel,criticality,owner
p-a,low,maintenance
p-b,high,vint
p-c,low,maintenance
p-d,critical,
CSV

cat > notes/method.txt <<'TXT'
How to build a pipeline (taped inside the locker door)

1. Look at the input. head -5. Not a guess about the input, the input.
2. Write stage one. Run it. Look at it.
3. Add one stage. Run it. Look at it.
4. When the output surprises you, stop. The surprise is the bug, and it is
   in the stage you just added.
5. Check the count at every stage. A number that does not change when it
   should have is the loudest bug you will ever get for free.
6. Only when it is right, redirect it to a file.

Nobody writes a nine-stage pipeline. They write one stage nine times.
TXT

cat > notes/broken.txt <<'TXT'
Five pipelines that do not do what their author thought. One bug each.

A) grep ERROR logs/maint-raw.txt | uniq -c | sort -rn
B) awk '{print $3}' logs/maint-raw.txt | sort | uniq -c | sort -n | head -5
C) cat logs/access-2187-06-10.log | grep rhea | wc -l
D) awk '{print $5}' logs/access-2187-06-10.log | sort -u | wc -l > reports/decks.txt | cat
E) grep -c write logs/access-2187-06-10.log | sort | uniq -c
TXT

: > scratch/.keep
: > reports/.keep

find . -exec touch -h -d '2187-06-12 08:00:00' {} +
