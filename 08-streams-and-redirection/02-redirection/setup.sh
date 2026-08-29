#!/usr/bin/env bash
# setup.sh -- seeds /labs/08-streams-and-redirection/02-redirection
#
# THE ANSWER KEY. Students are told not to open this.
#
# Teaching goal: redirection is a sequence of assignments to the process's fd
# table, performed left to right by the shell BEFORE the program starts.
# `>f 2>&1` and `2>&1 >f` differ for exactly that reason, and no amount of
# reading the words out loud will explain it -- the student has to see the fd
# table as state that gets mutated in order.
#
# Measured facts used by the exercises (all re-checked on every edit):
#   bin/deckreport  writes 12 lines to fd 1 and 5 to fd 2, exits 0
#   bin/failhard    writes 1 line to fd 1, 2 to fd 2, exits 3
#   data/readings.txt is 20 lines
#
# THE TRUNCATION TRAP: exercises walk the student into `sort f > f` losing the
# file, in scratch/, on a copy. data/readings.txt itself is never at risk
# because the lab is reset-able, but the exercise says to copy first anyway.
#
# NOTE: notes/wrong.txt is a red herring by construction -- entry C is correct
# and the student is told the file "collects mistakes". Being able to say which
# entry is not a mistake is exercise 41.
#
# Idempotent: removes its own tree first, creates nothing outside LAB.
set -euo pipefail

LAB="/labs/08-streams-and-redirection/02-redirection"
rm -rf "$LAB"
mkdir -p "$LAB"/{bin,data,logs,notes,scratch}
cd "$LAB"

########## programs ##########

cat > bin/deckreport <<'EOF'
#!/usr/bin/env bash
# deckreport -- deck 05 summary. Report on fd 1, notes on fd 2.
echo "deck 05 summary, 2187-06-14"
echo "sensor bank A ..... online" 
echo "sensor bank B ..... online"
echo "sensor bank C ..... degraded"
echo "deckreport: bank C running on two of three sensors" >&2
for p in 01 02 03 04 05 06; do
  printf 'panel %s   %s\n' "$p" "nominal"
done
echo "deckreport: panel 04 last calibrated 2186-11" >&2
echo "deckreport: panel 05 last calibrated 2186-11" >&2
echo "6 panels, 3 banks"
echo "end of summary"
echo "deckreport: 2 panels overdue for calibration" >&2
echo "deckreport: report written by dorn, 2186-04" >&2
exit 0
EOF

cat > bin/failhard <<'EOF'
#!/usr/bin/env bash
# failhard -- fails, says so, and means it.
echo "attempting bank D"
echo "failhard: bank D does not answer" >&2
echo "failhard: giving up" >&2
exit 3
EOF

cat > bin/chatty <<'EOF'
#!/usr/bin/env bash
# chatty -- one line to fd 1 and one to fd 2 per argument, in order.
for a in "$@"; do
  echo "out: $a"
  echo "err: $a" >&2
done
EOF

chmod 755 bin/deckreport bin/failhard bin/chatty

########## data ##########

{
  for i in $(seq 1 20); do
    printf 'p-%02d %3d\n' "$i" $(( 40 + (i * 7) % 23 ))
  done
} > data/readings.txt

printf 'deck 05\ndeck 03\ndeck 05\ndeck 11\ndeck 03\n' > data/visits.txt

########## logs: one that already exists, to make >> vs > matter ##########

cat > logs/deck05.log <<'EOF'
2187-06-12 08:00  summary run, ok
2187-06-13 08:00  summary run, ok
EOF

########## notes ##########

cat > notes/order.txt <<'EOF'
Redirection is assignment, and assignments have an order
--------------------------------------------------------

Before the program starts, the shell builds its file descriptor table. Every
redirection on the command line is one assignment to that table, applied left
to right. Then the program runs and never learns any of this happened.

  > file      fd 1 := file        (created, or TRUNCATED to zero length)
  >> file     fd 1 := file        (created, or appended to)
  2> file     fd 2 := file
  < file      fd 0 := file        (must exist)
  2>&1        fd 2 := a copy of whatever fd 1 IS RIGHT NOW
  1>&2        fd 1 := a copy of whatever fd 2 IS RIGHT NOW
  &> file     both fd 1 and fd 2 := file        (bash shorthand)
  2>&1 is not "merge the streams". It is "point 2 at 1's current target".

The word RIGHT NOW is the whole thing. Read left to right:

  prog > out.txt 2>&1
     fd 1 := out.txt
     fd 2 := copy of fd 1, which is now out.txt
     -> both in out.txt

  prog 2>&1 > out.txt
     fd 2 := copy of fd 1, which is still the terminal
     fd 1 := out.txt
     -> stdout in the file, stderr on the terminal

Both are legal, neither is a typo, and they are used for different jobs. The
second one is how you throw away stdout and keep only complaints:

  prog 2>&1 >/dev/null | grep something

TRUNCATION happens when the shell sets the table up -- BEFORE the program runs,
and before its input is read. This is why

  sort file > file

leaves you with an empty file. The shell truncated it, then handed sort an
empty file to sort. Nothing is recoverable and nothing warned you.

/dev/null accepts every write and returns end-of-file on every read. It is not
a special case in the shell; it is an ordinary device file that happens to be
a hole.
EOF

cat > notes/wrong.txt <<'EOF'
Redirections collected off the deck 05 shift board. Somebody has been writing
down the ones that misbehaved. No annotations, no author, and no promise that
every entry belongs on this list.

  A   deckreport > out.txt 2>&1 > out2.txt

  B   deckreport 2> out.txt 1>&2

  C   deckreport 2>&1 >/dev/null | wc -l

  D   sort data/readings.txt > data/readings.txt

  E   deckreport &> out.txt 2>/dev/null

  F   deckreport > /dev/null 2>&1 | wc -l
EOF

cat > notes/page.txt <<'EOF'
From: rhea
To: deck 05

The nightly summary writes to logs/deck05.log and the file is always exactly
one run long. It should be three weeks long by now. I do not want a discussion
about it, I want it fixed, and I want to know which character did it.
EOF

printf 'Yours. Copy things here before you experiment on them.\n' > scratch/README

find . -exec touch -h -d '2187-06-14 08:00:00' {} +
touch -d '2186-04-02 11:20:00' bin/deckreport
touch -d '2187-06-13 08:00:00' logs/deck05.log

echo "seeded $LAB"
