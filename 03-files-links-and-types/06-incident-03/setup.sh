#!/usr/bin/env bash
# setup.sh -- seeds /labs/03-files-links-and-types/06-incident-03
#
# CHAPTER 3 INCIDENT. Spoilers below; students are told not to read setup scripts.
#
# The shape of it:
#   deck3/console/          four links, three resolve, one dangles
#     panel-current  -> ../links/panel-active          symlink to a symlink
#     handbook       -> ../docs/panel-handbook.txt     ordinary live symlink
#     logs           -> ../archive                     live symlink to a DIRECTORY
#     strain-feed    -> /mnt/eng-array/strain/strain-2187-05-22.csv
#                                                      DANGLING. Trace 3.
#                                                      The mount left with dorn.
#                                                      That path name matters in ch15.
#   deck3/links/panel-active -> ../store/panel-log.txt  second hop of the chain
#   deck3/store/panel-log.txt      HARD LINK, same inode as ...
#   deck3/archive/panel-07.log     ... this. The chain's target. Holds the flag line.
#   deck3/archive/panel-05.log, panel-06.log   ordinary, no links, filler
#   deck3/docs/panel-handbook.txt              the handbook symlink's target
#   deck3/readings/                RED HERRING: sensor-a.txt and sensor-b.txt are
#                                  two names for ONE inode; sensor-c.txt is a real
#                                  copy with identical bytes and its own inode.
#                                  Spotting the pair is a true finding and is NOT
#                                  the finding. ls -l gives it away only via the
#                                  link count column.
#   deck3/notes/dangling.txt       dorn-adjacent note, mtime 2187-05-22. Says the
#                                  feed "went quiet". Never names dorn.
#
# The chain: console/panel-current -> links/panel-active -> store/panel-log.txt
#            =(hard link)= archive/panel-07.log
#
# The flag is NOT stored as KESTREL{...} anywhere. It is the last five words of
# the last line of panel-07.log, lowercased and underscored. See solutions.md.
#
# Artifacts -> exercises:
#   console/*                -> ex 1-9, 12-14
#   strain-feed + notes/     -> ex 10-11, 20, 22 (the debrief)
#   readings/                -> ex 15-17 (the red herring)
#   the chain + link counts  -> ex 18-19, 21 (the flag)
#
# Idempotent: removes its own tree first, creates nothing outside LAB.
set -euo pipefail

LAB="/labs/03-files-links-and-types/06-incident-03"
rm -rf "$LAB"
mkdir -p "$LAB"
cd "$LAB"

mkdir -p deck3/console deck3/links deck3/store deck3/archive deck3/docs \
         deck3/readings deck3/notes

# --- the chain's target -------------------------------------------------------
cat > deck3/archive/panel-07.log <<'EOF'
2187-05-19 22:04  panel-07  reseated, deck 3, bay 4
2187-05-20 01:17  panel-07  strain within tolerance
2187-05-21 09:30  panel-07  summariser input stopped arriving
2187-05-22 06:02  panel-07  feed path unreachable; console link left in place
2187-05-24 04:09  audit     deck-3 console links checked: 4 present, 3 resolve, 1 does not
2187-05-24 04:11  audit     nothing that runs depends on it, so it stays: the link outlived the target
EOF

# Second name for that same inode. This is the chain's hard-link hop.
ln deck3/archive/panel-07.log deck3/store/panel-log.txt

printf '2187-05-1%s 03:%s2  panel-0%s  strain within tolerance\n' 2 1 5 \
  > deck3/archive/panel-05.log
printf '2187-05-1%s 03:%s4  panel-0%s  strain within tolerance\n' 4 3 6 \
  > deck3/archive/panel-06.log

cat > deck3/docs/panel-handbook.txt <<'EOF'
deck 3 console, panel handbook (extract)
----------------------------------------
Every console entry is a link. Nothing on this deck is stored where it is read
from; the console is a set of names pointing at the places the data actually
lives, so that a panel can be swapped without moving a single log file.

A console entry that resolves is doing its job. A console entry that does not
resolve is still a console entry -- the name exists, is listed, has a mode and
an owner and a timestamp of its own, and tells you exactly where it was aimed
when it was made. What it cannot tell you is whether that place is still there.
EOF

# --- the four console links ---------------------------------------------------
cd deck3/console
ln -s ../links/panel-active   panel-current
ln -s ../docs/panel-handbook.txt handbook
ln -s ../archive              logs
# Trace 3. The engineering mount went away after dorn did; the link did not.
ln -s /mnt/eng-array/strain/strain-2187-05-22.csv strain-feed
cd "$LAB"

ln -s ../store/panel-log.txt deck3/links/panel-active

# --- red herring: two names, one inode, next to a genuine copy ----------------
cat > deck3/readings/sensor-a.txt <<'EOF'
deck3 bay4 strain, hourly
0.41 0.40 0.42 0.41 0.44 0.43
0.42 0.41 0.41 0.40 0.39 0.41
EOF
ln    deck3/readings/sensor-a.txt deck3/readings/sensor-b.txt
cp    deck3/readings/sensor-a.txt deck3/readings/sensor-c.txt

cat > deck3/notes/dangling.txt <<'EOF'
console entry 4 went quiet sometime on the 22nd. the name is still on the
console and still points where it always pointed. the other end is what left.

leaving it. removing it would be the only record of where it used to point,
and that path is the only thing here worth keeping.
EOF

# Story dates. Timeline: _handoff/SCENARIOS.md, trace 3, 2187-05-2x.
touch -d '2187-05-22 06:02:00' deck3/notes/dangling.txt
touch -d '2187-05-24 04:11:00' deck3/archive/panel-07.log
touch -d '2187-05-12 03:12:00' deck3/archive/panel-05.log
touch -d '2187-05-14 03:34:00' deck3/archive/panel-06.log
touch -d '2187-04-02 11:00:00' deck3/docs/panel-handbook.txt
touch -d '2187-05-21 09:31:00' deck3/readings/sensor-a.txt
touch -d '2187-05-21 09:31:00' deck3/readings/sensor-c.txt

# Link timestamps: -h sets the symlink itself, not its target.
touch -h -d '2187-03-30 08:00:00' deck3/console/handbook
touch -h -d '2187-03-30 08:00:00' deck3/console/logs
touch -h -d '2187-03-30 08:00:00' deck3/console/panel-current
touch -h -d '2187-03-30 08:00:00' deck3/links/panel-active
# The dangling one was re-aimed later than the other three. That is a finding.
touch -h -d '2187-05-08 17:44:00' deck3/console/strain-feed

echo "seeded $LAB"
