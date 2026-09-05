#!/usr/bin/env bash
# setup.sh -- seeds /labs/06-searching/07-incident-06
#
# THE ANSWER KEY. Students are told not to open this.
#
# Incident: the strain monitor writes one numbered line per sample, every 15s,
# 03:00:00 -> 05:59:45 on 2187-06-13. That is 720 entries, #0001..#0720.
# Nineteen of them -- #0246..#0264, covering 04:01:15..04:05:45 -- were DELETED
# from the file after the fact. The timestamps skip and, decisively, so do the
# sequence numbers: the writer numbered them, so their absence is provable.
#   grep -c '^#'   -> 701
#   highest seq    -> 0720
#   difference     -> 19
#
# THE RED HERRING: logs/panel-run-2187-06-13.log begins at #0401 and looks like
# it is missing 400 entries. It is not: the log rotated at 04:00 and #0001..#0400
# are in panel-run-2187-06-13.log.1. `cat` them together and nothing is missing.
# A student who runs the count trick without reading notes/rotation.txt reports
# the wrong log, loudly and wrongly.
#
# THE FLAG. Exactly one file in the whole tree carries an mtime inside the gap:
#   spool/.hold-2187-06-13   mtime 2187-06-13 04:03:20   (hidden; ls will not show it)
# It is a form SH-12 sampler hold record. notes/forms.txt gives the convention:
# an SH-12 summary is five words, one per numbered field, f1..f5. Here:
#   f1=the f2=gap f3=is f4=the f5=message
#   f6 (authorised by) and f7 (reason) are BLANK -- nobody signed it, and the
#   lab says nothing about who. Do not let any agent supply a name.
# -> KESTREL{the_gap_is_the_message}
# The literal flag string appears nowhere in the tree; it must be assembled.
#
# Chained CTF (the Dig), four stages, STAGE{} tokens, none registered:
#   1 find by time   in records/, exactly one file touched on 2187-06-13
#   2 grep -c / -n   the 701-vs-720 difference (19) is a line number in records/index-b.txt
#   3 ERE + grep -o  which sampler id never appears after the gap (3) -> records/sampler-3.txt
#   4 find -exec     the one other file containing "SH-12" is the hold record
#
# Idempotent: removes its own tree first, creates nothing outside LAB.
set -euo pipefail

LAB="/labs/06-searching/07-incident-06"
rm -rf "$LAB"
mkdir -p "$LAB"/{logs,spool,records,notes,scratch}
cd "$LAB"

########## logs: the strain run log, with nineteen entries removed ##########

gen_strain() {
  # $1 date, $2 first seq, $3 last seq, $4 skip-from, $5 skip-to
  local d=$1 seq h m sec off id
  for (( seq=$2; seq<=$3; seq++ )); do
    if [ -n "${4:-}" ] && [ "$seq" -ge "$4" ] && [ "$seq" -le "$5" ]; then continue; fi
    off=$(( (seq - 1) * 15 ))
    h=$(( 3 + off / 3600 )); m=$(( (off % 3600) / 60 )); sec=$(( off % 60 ))
    # sampler ids rotate 1,2,3,4 -- except sampler 3 never reports after the gap
    id=$(( (seq - 1) % 4 + 1 ))
    if [ -n "${4:-}" ] && [ "$seq" -gt "${5:-0}" ] && [ "$id" -eq 3 ]; then id=1; fi
    printf '#%04d %s %02d:%02d:%02d sampler=%d strain=0.%03d status=nominal\n' \
      "$seq" "$d" "$h" "$m" "$sec" "$id" "$(( 280 + (seq * 7) % 90 ))"
  done
}

{
  echo "# strain monitor, deck 05, sampler bank A"
  echo "# one entry per sample, 15s interval, sequence is monotonic and never reused"
  gen_strain 2187-06-13 1 720 246 264
} > logs/strain-run-2187-06-13.log

{
  echo "# strain monitor, deck 05, sampler bank A"
  echo "# one entry per sample, 15s interval, sequence is monotonic and never reused"
  gen_strain 2187-06-12 1 720
} > logs/strain-run-2187-06-12.log

# The red herring: panel log, rotated at 04:00. Nothing is missing.
{
  echo "# panel monitor, deck 05 -- rotated file, see rotation.txt"
  gen_strain 2187-06-13 241 720 | sed 's/sampler=/panel=/; s/strain=/reading=/'
} > logs/panel-run-2187-06-13.log
{
  echo "# panel monitor, deck 05 -- rotated file, see rotation.txt"
  gen_strain 2187-06-13 1 240 | sed 's/sampler=/panel=/; s/strain=/reading=/'
} > logs/panel-run-2187-06-13.log.1

########## notes ##########

cat > notes/page.txt <<'EOF'
From: cass
To: whoever is on shift

The overnight logs look fine. I have been through them twice. Strain is nominal
all night, the panel numbers are boring, nothing tripped.

I am sending this anyway because the summary the monitor prints stops early and
I do not know why. It says it covers the run and then it does not cover all of
it. When I open the log everything I can see is normal, so I assume I am reading
the summary wrong.

If it is nothing, tell me it is nothing and I will stop.
EOF

cat > notes/forms.txt <<'EOF'
Station forms, the two you will actually meet
---------------------------------------------

SH-12  sampler hold record
  Raised automatically whenever a sampler is held out of the run. The monitor
  writes the stub; the operator on duty completes it before the end of shift.

  Fields are numbered and keyed f1..f7. Fields f1 to f5 are the summary: five
  words, one per field, read in numeric order. Terse by design -- the point of
  a summary is that it fits on one line of a shift board.

  f6 is who authorised the hold. f7 is why. A hold record with f6 or f7 blank
  is an incomplete record and should have been rejected at end of shift.

MR-04  maintenance request
  Not used on deck 05 since 2186. Ignore it.
EOF

cat > notes/rotation.txt <<'EOF'
Log rotation on deck 05
-----------------------

Monitors rotate their run log at 04:00. The live file keeps the plain name;
the previous portion becomes the same name with `.1` appended. Sequence
numbering does NOT restart across a rotation -- it is monotonic for the whole
run, which is exactly what lets you check a rotated pair for completeness.

So a rotated log, read alone, always looks like it is missing everything before
the rotation. It is not missing. It is in the other file. Check before you
report it.

The strain monitor on bank A does not rotate. Its run log is one file.
EOF

cat > notes/monitor-summary.txt <<'EOF'
strain monitor, bank A -- run summary, 2187-06-13
  run window ......... 03:00:00 to 05:59:45
  interval ........... 15s
  entries expected ... 720
  samplers reporting . 1 2 3 4
  status ............. nominal throughout
EOF

########## spool: the flag file, and neighbours ##########

cat > spool/queue-2187-06-13.txt <<'EOF'
spool queue, deck 05
  03:12  strain-summary  ok
  04:20  strain-summary  ok
  05:44  strain-summary  ok
EOF

cat > spool/.hold-2187-06-13 <<'EOF'
form SH-12 -- sampler hold record (auto-generated stub)
  sampler ....... 3
  held .......... 2187-06-13 04:01:15
  released ...... 2187-06-13 04:05:45
  f1=the
  f2=gap
  f3=is
  f4=the
  f5=message
  f6=
  f7=
STAGE{four_of_four_and_nobody_signed}
EOF

cat > spool/README <<'EOF'
Spool directory. Completed jobs are removed nightly; held records are not.
EOF

########## records: the Dig ##########

for d in 06-01 06-04 06-07 06-09 06-11 06-12; do
  printf 'deck-05 daily index, 2187-%s\n  panels 01-12 walked, nothing outstanding\n' "$d" \
    > "records/index-2187-$d.txt"
done

cat > records/hold-log.txt <<'EOF'
Holds raised on deck 05 this quarter. One line per hold, no detail kept here;
the detail lives in the record itself, wherever the monitor spooled it.

  2187-04-02  sampler 1  released same shift
  2187-05-19  sampler 4  released same shift
  2187-06-13  sampler 3  released same shift

STAGE{first_stage_holds}

Next: the strain run log for the 13th claims a number of entries and contains a
different number. Take the difference. It is a line number in records/index-b.txt.
EOF

{
  for i in $(seq 1 40); do
    if [ "$i" -eq 19 ]; then
      echo "$i STAGE{nineteen_that_were_never_written} -- now: in that same run log, one sampler id stops appearing after the gap and never comes back. Which one? Look for records/sampler-<id>.txt"
    else
      echo "$i STAGE{wrong_line_count_again}"
    fi
  done
} > records/index-b.txt

for i in 1 2 4; do
  printf 'sampler %s: reported normally all night. STAGE{wrong_sampler_recount_it}\n' "$i" \
    > "records/sampler-$i.txt"
done
cat > records/sampler-3.txt <<'EOF'
sampler 3 -- held 2187-06-13, deck 05.

STAGE{third_stage_the_one_that_stopped}

Last: a hold on this station raises a form SH-12. Three files in this lab mention
SH-12 by name. One is notes/forms.txt, one is this file, and the third is the
record itself. Find all three with a single `find`, using `-exec` to do the
reading -- and do not go looking with `ls`, because `ls` will not show you the
one you want. That is the point.
EOF

cat > records/naming.txt <<'EOF'
Run logs are named <monitor>-run-<date>.log. Rotated portions take a numeric
suffix. Nothing else in this directory is a log.
EOF

########## scratch ##########
printf 'Yours. Copy things here before you experiment on them.\n' > scratch/README

########## timestamps: one clock, the station clock ##########

find . -exec touch -h -d '2187-06-13 06:00:00' {} +
touch -d '2187-06-01 08:00:00' notes/forms.txt notes/rotation.txt records/naming.txt
touch -d '2187-06-13 09:40:00' notes/page.txt
touch -d '2187-06-13 06:00:05' notes/monitor-summary.txt
for d in 06-01 06-04 06-07 06-09 06-11 06-12; do
  touch -d "2187-$d 18:00:00" "records/index-2187-$d.txt"
done
touch -d '2187-06-13 07:15:00' records/hold-log.txt
touch -d '2187-06-05 12:00:00' records/index-b.txt records/sampler-1.txt \
        records/sampler-2.txt records/sampler-3.txt records/sampler-4.txt

# The only mtime inside the gap. This is the whole incident.
touch -d '2187-06-13 04:03:20' spool/.hold-2187-06-13

echo "seeded $LAB"
