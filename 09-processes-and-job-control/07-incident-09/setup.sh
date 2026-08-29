#!/usr/bin/env bash
# setup.sh -- seeds /labs/09-processes-and-job-control/07-incident-09
#
# THE ANSWER KEY. Students are told not to open this.
#
# Incident: a door-log summariser was started by hand under the ops-bot
# automation account on 2186-10-06 and has never stopped. Nothing schedules it
# -- this station schedules nothing -- which is exactly why nobody ever looked
# at it again. It spins, so the station's CPU never goes idle, and rhea's jobs
# are genuinely slower because of it. She blames the student's changes. The
# timing lines up. She is wrong and she is not being unreasonable.
#
# THE FLAG lives in the running process's ENVIRONMENT and nowhere else:
#   LR_NOTE_1=nobody LR_NOTE_2=ever LR_NOTE_3=stopped LR_NOTE_4=it
#   -> KESTREL{nobody_ever_stopped_it}
# notes/launch-records.txt gives the LR convention (numbered note fields carried
# in the environment, one word each, read in numeric order). Reading them needs
#   sudo tr '\0' '\n' < /proc/<pid>/environ
# because environ is mode 0400 and owned by ops-bot. KILL THE PROCESS AND THE
# FLAG IS GONE -- there is no other copy anywhere in the tree or the image, and
# the only fix is `kestrel reset 09/07`. That is the whole point of the lesson.
#
# THE TRACE (arc, chapter 9). The summariser's cwd is spool/door, which is not
# its own directory, and its output file was deleted while still open: it is
# readable only through /proc/<pid>/fd/9. The recovered file shows a door-log
# entry count for every night since 2186-10-06 -- and zero for the two nights in
# May 2187 that chapter 8 pointed at. The lab NEVER names a person.
#
# Chained CTF (the Dig), four stages, STAGE{} tokens, none registered:
#   1 ps/pgrep    the runaway's argv carries --tag lr-07 -> records/lr-07.txt
#   2 signals     bin/warden answers SIGUSR1 only; TERM kills it and says so
#   3 /proc fd    the deleted-but-open output on fd 9
#   4 nice        one ops-bot job has a non-default nice value (11), which is a
#                 line number in records/index-d.txt
#
# Idempotent: kills the processes it started, removes its own tree, restarts.
set -euo pipefail

LAB="/labs/09-processes-and-job-control/07-incident-09"

# --- stop anything a previous seeding left running --------------------------
pkill -f "$LAB/bin/" 2>/dev/null || true
sleep 1
pkill -9 -f "$LAB/bin/" 2>/dev/null || true

rm -rf "$LAB"
mkdir -p "$LAB"/{bin,logs,notes,records,spool/door,scratch}
cd "$LAB"

########## bin: the things that are running ##########

# The runaway. Spins with a small duty cycle so it is plainly the busiest thing
# on the station without cooking the host. Opens its output, deletes the name,
# keeps the descriptor.
cat > bin/door-summariser <<'EOF'
#!/usr/bin/env bash
# door-log summariser. Reads the door log, writes a nightly count.
# Started with --tag and --since; see notes/launch-records.txt.
out="${LR_OUTPUT:-/tmp/door-summary}"
cd "$(dirname "$0")/../spool/door"
exec 9> "$out"
cat >&9 <<'BODY'
door-log summary -- deck 05, all decks fed through panel p-07
one line per night: date, entries counted, entries summarised

  2187-05-11   214   214
  2187-05-12   198   198
  2187-05-13     0     0
  2187-05-14     0     0
  2187-05-15   203   203
  2187-05-16   221   221

Two nights with nothing to count. The door log for those nights was present and
its size was normal. Nothing was summarised because nothing parsed.

STAGE{third_stage_still_open}

Next: three jobs run under ops-bot. Two of them share a priority and one does
not. That one's nice value is a line number in records/index-d.txt.
BODY
rm -f "$out"
# Spin with a small duty cycle: enough to keep one CPU busy and the load off
# zero, not enough to be a nuisance. A heartbeat goes to the open descriptor
# once a minute -- the file has no name, so this is the only way it grows.
n=0
while :; do
  i=0
  while [ "$i" -lt 30000 ]; do i=$(( i + 1 )); done
  sleep 0.05
  n=$(( n + 1 ))
  if [ "$n" -ge 600 ]; then printf 'still here\n' >&9; n=0; fi
done
EOF

cat > bin/panel-poller <<'EOF'
#!/usr/bin/env bash
# polls the panel bus. Sleeps between polls. Costs nothing and never has.
while :; do sleep 30; done
EOF

cat > bin/index-sweeper <<'EOF'
#!/usr/bin/env bash
# nightly index sweep. Deliberately run at a low priority so it never gets in
# the way of anything that matters.
while :; do sleep 30; done
EOF

cat > bin/warden <<'EOF'
#!/usr/bin/env bash
# deck warden. Answers one question, and only when it is asked properly.
log="$(dirname "$0")/../records/warden.log"
trap 'printf "warden: asked, and answering.\n  STAGE{second_stage_asked_politely}\n  Next: the summariser has been writing its answer to a file that no longer\n  has a name. The descriptor is still open. Read it there.\n" >> "$log"' USR1
trap 'printf "warden: terminated before it was asked anything. Nothing to report.\n" >> "$log"; exit 143' TERM
printf 'warden: up, waiting.\n' >> "$log"
# sleep in the background and wait for it, so a trap runs the instant the
# signal lands instead of at the end of the current sleep.
while :; do sleep 5 & wait $!; done
EOF

chmod 755 bin/*

########## notes ##########

cat > notes/page.txt <<'EOF'
From: rhea
To: cadet

My jobs have been slow since you started working on this deck. Not failing --
slow. The panel rebuild took eleven minutes last night and it has taken four
minutes every night for a year.

I am not accusing you of breaking anything. I am telling you the timing, because
the timing is the only thing I have. You started, it got slow. If that is a
coincidence then something else changed at the same time and I would like to
know what it is.

Before you tell me it is fine: the station is asleep. Sixty people, none of them
awake, and the load average has not been under 1.0 all week. Something is
running. Find out what it is before you switch anything off -- if you kill it
first we will never know what it was doing, and I would rather be slow than
ignorant.
EOF

cat > notes/launch-records.txt <<'EOF'
Launch records (LR forms)
-------------------------

Anything started by hand on this station is supposed to get a launch record: a
tag, a date, and a one-line note saying why it was started.

The launcher does not write the note to a file. It passes it to the job in the
job's ENVIRONMENT, as numbered fields:

    LR_NOTE_1, LR_NOTE_2, LR_NOTE_3, ...

one word per field, read in numeric order. The reason it works that way is that
a job restarted for a different reason gets a different note, and a note on disk
would go stale without anyone noticing.

The consequence no one weighs until it matters: the note exists only for
as long as the job does. There is no copy. If you stop the job, the record of
why it was started stops with it.

LR_TAG names the record in records/. LR_STARTED is the date it went up.
EOF

cat > notes/scheduling.txt <<'EOF'
What schedules jobs on the Kestrel
----------------------------------

Nothing.

There is no scheduler on this station. No timer, no job table, no nightly
runner other than the one a person types. Every long-running thing you find is
running because somebody started it in a shell and walked away, and it is still
running because nothing ever shuts it down either.

This is worth saying plainly because the instinct is to go looking for the thing
that started it. There is no such thing. The question is not "what runs this",
it is "who typed this, when, and did they mean it to still be here".
EOF

cat > notes/load.txt <<'EOF'
Load average, one more time
---------------------------

Load is the count of processes that want to run (plus, on Linux, the ones stuck
in uninterruptible I/O). It is not a percentage and it is not CPU usage.

This station has 24 CPUs. A load average of 1.0 means one runnable process on
average -- about 4% of the machine. That is nothing, and it is also a fact: on
a station with everybody asleep the number should be sitting near zero.

A single process that never blocks holds the load at 1.0 for as long as it
lives. It will not show up as a slow machine. It shows up as a machine that is
never idle.
EOF

########## logs ##########

cat > logs/rebuild-times.txt <<'EOF'
panel rebuild, wall-clock minutes, one line per night (rhea's job)
  2187-06-05   4.1
  2187-06-06   4.0
  2187-06-07   4.2
  2187-06-08   4.1
  2187-06-09   9.6
  2187-06-10  10.8
  2187-06-11  11.0
  2187-06-12  10.4
  2187-06-13  11.2
EOF

cat > logs/deck-05-shift.txt <<'EOF'
shift log, deck 05 -- entries kept short by convention

  2187-06-08  cadet assigned to deck 05
  2187-06-09  cadet: file permissions audit, no changes to running jobs
  2187-06-10  cadet: log tidy, scratch dirs only
  2187-06-11  rhea: panel rebuild slow, raised with shift
  2187-06-13  rhea: panel rebuild slow again
EOF

########## spool ##########

cat > spool/door/README <<'EOF'
Door-log spool. The summariser writes here. Nothing else should.
EOF

cat > spool/queue.txt <<'EOF'
spool queue, deck 05
  06:00  panel-rebuild   ok
  06:00  index-sweep     ok
EOF

########## records: the Dig ##########

cat > records/lr-07.txt <<'EOF'
LR-07 -- launch record
  tag ........ lr-07
  started .... 2186-10-06
  job ........ door-log summariser, deck 05
  note ....... carried in the job's environment; see notes/launch-records.txt
  authorised . (blank)

STAGE{first_stage_by_its_own_name}

Next: something on this deck is waiting to be asked. bin/warden is running. It
answers exactly one signal, and it is not one of the two that stop it. Its log
is records/warden.log -- and if you get it wrong, the log will tell you so and
you will have to reset the lab.
EOF

cat > records/lr-03.txt <<'EOF'
LR-03 -- launch record
  tag ........ lr-03
  started .... 2187-02-11
  job ........ panel bus poller, deck 05
  note ....... carried in the job's environment
  authorised . shift
EOF

cat > records/lr-05.txt <<'EOF'
LR-05 -- launch record
  tag ........ lr-05
  started .... 2187-01-20
  job ........ index sweeper, deck 05
  note ....... carried in the job's environment
  authorised . shift
EOF

{
  for i in $(seq 1 40); do
    if [ "$i" -eq 11 ]; then
      echo "$i STAGE{fourth_stage_low_priority} -- last: the note was never written down anywhere. Ask the process for it, and mind that it is not yours to read."
    else
      echo "$i STAGE{wrong_priority_read_it_again}"
    fi
  done
} > records/index-d.txt

cat > records/naming.txt <<'EOF'
Launch records are named lr-<nn>.txt. The tag is the name; the name is the tag.
Nothing else in this directory is a launch record.
EOF

printf 'Yours. Copy things here before you experiment on them.\n' > scratch/README

########## timestamps ##########

find . -exec touch -h -d '2187-06-14 06:00:00' {} +
touch -d '2186-10-06 02:14:00' records/lr-07.txt
touch -d '2187-02-11 09:00:00' records/lr-03.txt
touch -d '2187-01-20 09:00:00' records/lr-05.txt
touch -d '2187-06-01 08:00:00' notes/launch-records.txt notes/scheduling.txt \
        notes/load.txt records/naming.txt records/index-d.txt
touch -d '2187-06-14 09:30:00' notes/page.txt
touch -d '2187-06-14 06:05:00' logs/rebuild-times.txt logs/deck-05-shift.txt

chown -R cadet:crew "$LAB"
chmod 777 "$LAB/records" "$LAB/spool/door"

########## start the jobs ##########

# The runaway: ops-bot, default priority, started "2186-10-06", note in the
# environment and nowhere else. The note must NOT appear in argv, so it is
# exported here and inherited -- `ps` shows the command line to everyone.
(
  cd /; unset OLDPWD DEBIAN_FRONTEND; export HOME=/var/lib/ops-bot
  export LR_TAG=lr-07 LR_STARTED=2186-10-06 \
         LR_OUTPUT="$LAB/spool/door/summary-2186-10-06.txt" \
         LR_NOTE_1=nobody LR_NOTE_2=ever LR_NOTE_3=stopped LR_NOTE_4=it
  setsid --fork setpriv --reuid=ops-bot --regid=ops-bot --init-groups \
    bash "$LAB/bin/door-summariser" --tag lr-07 --since 2186-10-06 \
    >/dev/null 2>&1 </dev/null
)

# Two innocent ops-bot jobs. One of them is the nice-value stage.
(
  cd /; unset OLDPWD DEBIAN_FRONTEND; export HOME=/var/lib/ops-bot
  export LR_TAG=lr-03 LR_STARTED=2187-02-11
  setsid --fork setpriv --reuid=ops-bot --regid=ops-bot --init-groups \
    bash "$LAB/bin/panel-poller" --tag lr-03 >/dev/null 2>&1 </dev/null
)
(
  cd /; unset OLDPWD DEBIAN_FRONTEND; export HOME=/var/lib/ops-bot
  export LR_TAG=lr-05 LR_STARTED=2187-01-20
  setsid --fork setpriv --reuid=ops-bot --regid=ops-bot --init-groups \
    nice -n 11 bash "$LAB/bin/index-sweeper" --tag lr-05 >/dev/null 2>&1 </dev/null
)

# The warden runs as the student, so the student can signal it.
setsid --fork setpriv --reuid=cadet --regid=cadet --init-groups \
  bash "$LAB/bin/warden" >/dev/null 2>&1 </dev/null

sleep 1
chown cadet:crew "$LAB/records/warden.log" 2>/dev/null || true

echo "seeded $LAB"
