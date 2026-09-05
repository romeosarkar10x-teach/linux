#!/usr/bin/env bash
# setup.sh -- seeds /labs/07-text-processing/08-incident-07
#
# THE ANSWER KEY. Students are told not to open this.
#
# Incident: the captain wants a ranked access report for Q1 2187. Building it
# is the whole task, and the finding falls out of the bottom of the ranking.
#
#   ops-bot   1800 events   <- the red herring. It is 74% of the file. Every
#                              ranked report is dominated by it, and students
#                              stop reading after row three.
#   rhea       300
#   cass       180
#   vint        90
#   orla        40
#   bex         18
#   maintenance  6
#   eng-svc      1   <- 2187-01-18 04:14:22, action='login', deck-02
#
# eng-svc appears exactly ONCE in three months, and appears in NEITHER account
# snapshot in records/ (2187-01 and 2187-06). An account that logged in once and
# is in no passwd file is the finding. It is in the tail of the ranking, which
# is why the lesson is really about reading the whole report you just built.
#
# THE FLAG. notes/forms.txt gives station form AC-9: a finding is three fields,
#   f1 = the account, written with underscores instead of dashes
#   f2 = the event, from the vocabulary table (action='login' -> logged_in)
#   f3 = the frequency word (1 -> once, 2 -> twice, 3+ -> repeatedly)
# -> KESTREL{eng_svc_logged_in_once}
# The literal string appears nowhere in the tree. It must be assembled from a
# count the student computed and a table they had to read.
#
# NOT A DECOY: no KESTREL{...} string is planted anywhere in this lab.
#
# Chained CTF (the Dig), four stages, STAGE{} tokens, none registered:
#   1 sort | uniq -c   rank records/tally.txt; the LAST row names a file
#   2 awk fields       one row of that file, one field, chosen by a condition
#   3 cut / paste      pull two columns from different files and join them
#   4 tr / sed         decode with the table in records/cipher.txt
#
# Idempotent: removes its own tree first, creates nothing outside LAB.
set -euo pipefail

LAB="/labs/07-text-processing/08-incident-07"
rm -rf "$LAB"
mkdir -p "$LAB"/{logs,records,notes,reports,scratch}
cd "$LAB"

########## the quarter's access logs ##########
# Deterministic: record i of an account lands on day ((i*13) % days)+1 and
# second (i*281 + offset) % 86400. 281 and 13 are coprime with the moduli, so
# no two records of one account collide.

gen_month() {                 # $1 month (01/02/03), $2 days, $3 offset, then account:count pairs
  local mon="$1" days="$2" off="$3" pair a n i d t h m s action deck
  shift 3
  for pair in "$@"; do
    a="${pair%%:*}"; n="${pair##*:}"
    for (( i=0; i<n; i++ )); do
      d=$(( (i * 13) % days + 1 ))
      t=$(( (i * 281 + off) % 86400 ))
      h=$(( t / 3600 )); m=$(( (t % 3600) / 60 )); s=$(( t % 60 ))
      case $(( i % 5 )) in
        0) action='read' ;; 1) action='write' ;; 2) action='read' ;;
        3) action='exec' ;; 4) action='login' ;;
      esac
      deck=$(( (i / 3) % 4 + 1 ))
      printf '2187-%s-%02d %02d:%02d:%02d %s %s deck-0%d\n' \
             "$mon" "$d" "$h" "$m" "$s" "$a" "$action" "$deck"
    done
  done
}

gen_month 01 31 0 ops-bot:640 rhea:104 cass:63 vint:31 orla:14 bex:6 maintenance:2 \
  > scratch/.m1
printf '2187-01-18 04:14:22 eng-svc login deck-02\n' >> scratch/.m1
sort -k1,2 scratch/.m1 > logs/access-2187-01.log

gen_month 02 28 3607 ops-bot:580 rhea:98 cass:58 vint:29 orla:13 bex:6 maintenance:2 |
  sort -k1,2 > logs/access-2187-02.log

gen_month 03 31 7211 ops-bot:580 rhea:98 cass:59 vint:30 orla:13 bex:6 maintenance:2 |
  sort -k1,2 > logs/access-2187-03.log

rm -f scratch/.m1

########## account snapshots -- eng-svc is in neither ##########

write_passwd() {              # $1 outfile, $2 label
  {
    printf '# %s\n' "$2"
    printf '# name:uid:gid:role:deck\n'
    printf 'ops-bot:900:900:automation:all\n'
    printf 'rhea:1004:1004:engineer:deck-03\n'
    printf 'cass:1005:1005:comms:deck-01\n'
    printf 'vint:1006:1006:engineer:deck-04\n'
    printf 'orla:1007:1007:medical:deck-01\n'
    printf 'bex:1008:1008:galley:deck-02\n'
    printf 'maintenance:901:901:automation:all\n'
  } > "$1"
}
write_passwd records/accounts-2187-01.txt 'station account snapshot, taken 2187-01-31'
write_passwd records/accounts-2187-06.txt 'station account snapshot, taken 2187-06-30'

########## notes ##########

cat > notes/page.txt <<'TXT'
From: the captain
To: you
Subject: access numbers

I want the access log as a ranked report by account for the quarter. Top talkers,
counts, readable. By the end of the shift.

Do not send me the log.
TXT

cat > notes/forms.txt <<'TXT'
Station report forms -- the two you will need this shift.

FORM AC-3  Access summary
  A ranked table. One row per account. Columns: account, count, share of total
  to one decimal place. Ordered by count, highest first. A header row, and the
  period the report covers stated on the report itself. A report that does not
  say what dates it covers is not a report, it is a number.

FORM AC-9  Access finding
  A finding is exactly three fields, in order, lowercase, joined by underscores.
    f1  the account, with any dash written as an underscore
    f2  the event, from the vocabulary table below
    f3  the frequency word, from the frequency table below

  Vocabulary (log action -> event)
    read   -> read_data
    write  -> wrote_data
    exec   -> ran_process
    login  -> logged_in

  Frequency (number of occurrences in the period -> word)
    1        -> once
    2        -> twice
    3 to 9   -> repeatedly
    10+      -> routinely

  A completed AC-9 finding is submitted as the flag for the incident.
TXT

cat > notes/handover.txt <<'TXT'
Handover, night watch to day watch.

ops-bot is loud. It always has been. It polls every deck on a fixed cycle and it
logs every poll, so it is roughly three quarters of every access log we produce.
Nobody has ever found anything in the ops-bot rows and nobody expects to.

Standing advice from the last three watches: rank the report, read the top three,
move on. It has never been wrong.
TXT

########## the Dig ##########

cat > records/tally.txt <<'TXT'
# console tally, deck-02 terminal, Q1
# one line per session open
console-a
console-b
console-a
console-c
console-a
console-b
console-a
console-b
console-c
console-a
console-b
console-a
console-c
console-a
console-b
console-a
console-d
TXT

cat > records/console-d.txt <<'TXT'
STAGE{tally_read_to_the_end}
# deck-02 terminal, session records
# seat  account      started   ended     deck      idle_min
s-01    rhea         03:58:11  05:02:40  deck-03   4
s-02    ops-bot      04:01:00  04:01:03  deck-02   0
s-03    eng-svc      04:14:22  04:14:29  deck-02   0
s-04    cass         06:20:05  07:41:19  deck-01   11
s-05    ops-bot      08:00:00  08:00:04  deck-02   0
# stage 2: the only session whose account is in no account snapshot.
# field 2 of that row names the next file, with the dash written as a dash.
TXT

cat > records/eng-svc.txt <<'TXT'
STAGE{account_named_by_a_field}
# stage 3: two columns, two files.
# cut column 3 (delimiter :) from records/left.txt
# cut column 1 (delimiter :) from records/right.txt
# paste them together with ':' as the delimiter, then read the line whose
# number equals the number of times eng-svc appears in the whole quarter.
# records/cipher.txt says what to do with it.
TXT

cat > records/left.txt <<'TXT'
a:b:bapr
c:d:gjvpr
e:f:ercrngrqyl
g:h:ebhgvaryl
TXT

cat > records/right.txt <<'TXT'
pbhagf:1
vtaberq:2
ybttrq:3
cbyyrq:4
TXT

cat > records/cipher.txt <<'TXT'
# deck-02 console writes its stage tokens with the letters rotated by thirteen.
# Digits and punctuation are untouched.
#
#   tr 'A-Za-z' 'N-ZA-Mn-za-m'
#
# The line you pasted is two rot13 words separated by a colon. Decode it with
# tr, turn the colon into an underscore with sed, and wrap the result in
# STAGE{} -- that is stage 4, and it is the last one.
TXT

: > scratch/.keep
: > reports/.keep

find . -exec touch -h -d '2187-04-01 08:00:00' {} +
