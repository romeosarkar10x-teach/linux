#!/usr/bin/env bash
# setup.sh -- seeds /labs/06-searching/05-find-advanced
#
# Teaches: -size, -mtime/-mmin, -newer/-newermt, -perm (exact, /any, -all),
# -user/-group, -empty, -exec \; vs -exec +, -ok, -delete (and why it
# implies -depth), -print0 with xargs -0, and the cost of getting any of
# these wrong on a tree you did not create.
#
# The chapter's incident is solved with -newermt on a time window, so
# that predicate gets the most exercises here.
#
# Two time bases on purpose:
#   spool/   mtimes RELATIVE TO NOW ("3 days ago") so -mtime/-mmin work
#   deck/    mtimes FIXED in 2187 so -newermt windows are reproducible
# A student who mixes them up gets nonsense, which is exercise 22.
#
# Artifacts -> exercises:
#   sizes: 0, 1 byte, 900, 1c-boundary cases, 3k, 40k   -size c/k/b rounding
#   spool/: 5 min, 90 min, 3 d, 8 d, 40 d old            -mmin/-mtime/-daystart
#   deck/: a five-minute window with exactly one file    -newermt (the incident skill)
#   perms/: 600 644 755 640 444 dir 700, one setgid      -perm exact vs / vs -
#   owners: all one owner after the harness chown        -user is useless here; -perm is not
#   empty file, empty dir, dir with only a dotfile       -empty
#   names with spaces/newline/leading dash               -print0, xargs -0
# Idempotent: removes its own tree first, creates nothing outside LAB.
set -euo pipefail

LAB="/labs/06-searching/05-find-advanced"
rm -rf "$LAB"
mkdir -p "$LAB"/{sizes,spool,deck,perms,owners,awkward,scratch,notes}
cd "$LAB"

########## sizes ##########
: > sizes/zero.log
printf 'x' > sizes/one-byte.log
head -c 511  /dev/zero | tr '\0' 'a' > sizes/just-under-512.log
head -c 512  /dev/zero | tr '\0' 'a' > sizes/exactly-512.log
head -c 513  /dev/zero | tr '\0' 'a' > sizes/just-over-512.log
head -c 1024 /dev/zero | tr '\0' 'a' > sizes/exactly-1k.log
head -c 1025 /dev/zero | tr '\0' 'a' > sizes/just-over-1k.log
head -c 3072 /dev/zero | tr '\0' 'a' > sizes/three-k.log
head -c 40960 /dev/zero | tr '\0' 'a' > sizes/forty-k.log

########## spool: mtimes relative to NOW ##########
mk_spool() {  # $1 name, $2 touch spec
    printf 'spool entry %s\n' "$1" > "spool/$1"
    touch -d "$2" "spool/$1"
}
mk_spool 'run-05min.log'  '5 minutes ago'
mk_spool 'run-90min.log'  '90 minutes ago'
mk_spool 'run-25h.log'    '25 hours ago'
mk_spool 'run-3d.log'     '3 days ago'
mk_spool 'run-8d.log'     '8 days ago'
mk_spool 'run-40d.log'    '40 days ago'

########## deck: fixed 2187 mtimes, one five-minute window ##########
mk_deck() {  # $1 name, $2 stamp, $3 body
    printf '%s\n' "$3" > "deck/$1"
    touch -d "$2" "deck/$1"
}
mk_deck panel-03.log  '2187-06-09 04:00:00' '2187-06-09 04:00  panel-03  strain 0.41'
mk_deck panel-05.log  '2187-06-09 04:00:00' '2187-06-09 04:00  panel-05  strain 0.44'
mk_deck panel-09.log  '2187-06-09 05:00:00' '2187-06-09 05:00  panel-09  strain 0.43'
mk_deck strain-01.log '2187-06-09 06:00:00' '2187-06-09 06:00  bay-01  strain 0.52'
mk_deck strain-02.log '2187-06-10 04:00:00' '2187-06-10 04:00  bay-02  strain 0.47'
mk_deck summary.txt   '2187-06-10 09:00:00' 'deck summary, generated 2187-06-10 09:00'
# the one file inside the window 2187-06-09 04:30 .. 04:35
mk_deck adjustment.note '2187-06-09 04:32:00' 'value adjusted by hand; no entry made'
mk_deck marker-before   '2187-06-09 04:30:00' 'window start marker'
mk_deck marker-after    '2187-06-09 04:35:00' 'window end marker'

########## perms ##########
printf 'private\n'    > perms/secret.txt        ; chmod 600 perms/secret.txt
printf 'normal\n'     > perms/notes.txt         ; chmod 644 perms/notes.txt
printf '#!/bin/sh\n'  > perms/run.sh            ; chmod 755 perms/run.sh
printf 'group read\n' > perms/shared.txt        ; chmod 640 perms/shared.txt
printf 'read only\n'  > perms/readonly.txt      ; chmod 444 perms/readonly.txt
printf 'odd\n'        > perms/group-write.txt   ; chmod 664 perms/group-write.txt
printf 'world write\n'> perms/world-write.txt   ; chmod 666 perms/world-write.txt
mkdir -p perms/closed  ; printf 'inside\n' > perms/closed/inside.txt ; chmod 700 perms/closed

########## owners ##########
# NOTE: the harness runs `chown -R cadet:crew` after every setup.sh, so a
# file seeded root-owned does not stay root-owned. That is deliberate here:
# the lesson's -user/-group exercises are about a predicate that CANNOT
# discriminate in this tree, and what you use instead.
printf 'owned by cadet\n' > owners/cadet-file.txt
printf 'group crew\n'     > owners/crew-file.txt
printf 'same owner, different mode\n' > owners/mode-differs.txt
chmod 600 owners/mode-differs.txt

########## empty ##########
: > notes/empty.log
mkdir -p notes/empty-dir notes/dot-only
printf 'hidden\n' > notes/dot-only/.keep

########## awkward names ##########
printf 'spaces\n'  > 'awkward/run report.log'
printf 'dash\n'    > 'awkward/-summary.log'
printf 'newline\n' > "$(printf 'awkward/two\nlines.log')"
printf 'quote\n'   > "awkward/it's.log"

########## notes ##########
cat > notes/index.txt <<'EOF'
Deck 03 file conventions and the housekeeping rules that use them.

Rotation: a run log is kept for seven days and then removed. The sweep
runs on size as well: anything over 32k is compressed first.

Time predicates in the tooling are written against modification time.
Nobody has ever checked whether that is the right time to use.

The deck/ directory carries station dates. The spool/ directory carries
real ones, because it is written by the running system. Do not mix them
in one expression; the answer will be empty and it will not say why.
EOF

cat > notes/handover.txt <<'EOF'
Handover.

If you need to know what changed during a specific stretch of time, do
not go looking for the change. Go looking for what carries the time.

A five-minute window on a quiet tree usually holds nothing. When it
holds exactly one thing, that is worth a sentence in the report.
EOF

touch -d '2187-06-10 09:00:00' notes/index.txt notes/handover.txt
echo "seeded $LAB"
