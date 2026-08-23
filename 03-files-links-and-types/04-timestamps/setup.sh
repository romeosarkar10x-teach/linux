#!/usr/bin/env bash
# setup.sh -- seeds /labs/03-files-links-and-types/04-timestamps
#
# Artifacts -> exercises:
#   logs/strain-2187-05-*.csv  -> ex 1-10  (six dated files, mtimes days apart, so `ls -lt` and
#                                 `stat` have something to sort and so the newest is not the last
#                                 one alphabetically)
#   logs/strain-summary        ->          (mtime older than every file it claims to summarise)
#   reads/warm.txt             -> ex 11-15 (atime already newer than mtime: on a relatime mount a
#   reads/cold.txt             ->          second read does not move it. cold.txt has an mtime a
#                                 century in the future (2287, well inside what ext4 can store),
#                                 the future, so every read *does* move its atime)
#   meta/panel-07.txt          -> ex 16-22 (mtime old, ctime new: chmod and rename change the inode
#   meta/panel-07-alias        ->          without changing the contents. The hard link proves the
#                                 timestamps live in the inode, not the name)
#   meta/moved.txt             ->
#   copies/source.csv          -> ex 23-27 (cp resets mtime, cp -p preserves it: the reason a
#   copies/                    ->          restored-from-backup tree looks freshly written)
#   refs/anchor.txt            -> ex 28-30 (touch -r: copy a timestamp from one file to another
#   refs/{one,two,three}.txt   ->          without knowing what it is)
#   stamps/bay-2/              -> ex 31-34 (a directory's mtime tracks its *entry list*, not the
#   stamps/bay-2/clearance.txt ->          contents of the files inside it)
#   birth/first.txt            -> ex 35-36 (%w birth time: present on this ext4 lab volume, absent
#                                 on many real filesystems, and not settable by touch)
#
# Every mtime/atime below is set after the contents, the modes and the ownership are final,
# because chmod and chown move ctime and would otherwise be the last word on the inode.
# ctime is deliberately left at "now" everywhere: it cannot be set, and that is the lesson.
#
# Idempotent: removes its own tree first, creates nothing outside LAB.
set -euo pipefail

LAB="/labs/03-files-links-and-types/04-timestamps"
chmod -R u+w "$LAB" 2>/dev/null || true
rm -rf "$LAB"
mkdir -p "$LAB"
cd "$LAB"

# ---- logs/ : six dated files, deliberately not in name order by time -------
mkdir -p logs
printf 'deck,strain,ts\n3,0.41,2187-05-19T02:00\n' > logs/strain-2187-05-19.csv
printf 'deck,strain,ts\n3,0.44,2187-05-20T02:00\n' > logs/strain-2187-05-20.csv
printf 'deck,strain,ts\n3,0.52,2187-05-21T02:00\n' > logs/strain-2187-05-21.csv
printf 'deck,strain,ts\n3,0.71,2187-05-22T02:00\n' > logs/strain-2187-05-22.csv
printf 'deck,strain,ts\n3,0.68,2187-05-23T02:00\n' > logs/strain-2187-05-23.csv
printf 'deck,strain,ts\n3,0.66,2187-05-24T02:00\n' > logs/strain-2187-05-24.csv
printf 'six days, deck 3, mean 0.57\n' > logs/strain-summary

# ---- reads/ : one warm file, one whose mtime is in the future -------------
mkdir -p reads
printf 'this file has been read before\n' > reads/warm.txt
printf 'the clock on this one is wrong\n' > reads/cold.txt

# ---- meta/ : contents old, inode touched recently -------------------------
mkdir -p meta
printf 'panel 07\nseated 2187-06-09\ntorque 42 Nm\n' > meta/panel-07.txt
ln meta/panel-07.txt meta/panel-07-alias
printf 'bay 2 clearance 0.6mm\n' > meta/moved.txt

# ---- copies/ : cp versus cp -p --------------------------------------------
mkdir -p copies
printf 'deck,strain,ts\n3,0.71,2187-05-22T02:00\n' > copies/source.csv

# ---- refs/ : touch -r ------------------------------------------------------
mkdir -p refs
printf 'reference timestamp lives here\n' > refs/anchor.txt
printf 'one\n'   > refs/one.txt
printf 'two\n'   > refs/two.txt
printf 'three\n' > refs/three.txt

# ---- stamps/ : a directory's mtime is its entry list ----------------------
mkdir -p stamps/bay-2
printf 'clearance 0.6mm\n' > stamps/bay-2/clearance.txt
printf 'torque 42 Nm\n'    > stamps/bay-2/torque.txt

# ---- birth/ ----------------------------------------------------------------
mkdir -p birth
printf 'created once, never edited\n' > birth/first.txt

chown -R cadet:crew "$LAB" 2>/dev/null || true
chmod 600 meta/panel-07.txt

# ---- timestamps last: chmod and chown above would outrank them on ctime ---
touch -d '2187-05-19 02:04' logs/strain-2187-05-19.csv
touch -d '2187-05-20 02:03' logs/strain-2187-05-20.csv
touch -d '2187-05-21 02:07' logs/strain-2187-05-21.csv
touch -d '2187-05-22 03:14' logs/strain-2187-05-22.csv
touch -d '2187-05-23 02:02' logs/strain-2187-05-23.csv
touch -d '2187-05-24 02:05' logs/strain-2187-05-24.csv
touch -d '2187-05-21 09:30' logs/strain-summary

touch -m -d '2187-05-22 03:14' reads/warm.txt
touch -a -d '2187-06-01 11:00' reads/warm.txt
touch -m -d '2287-01-01 00:00' reads/cold.txt

touch -d '2187-05-24 04:12' meta/panel-07.txt
touch -d '2187-05-24 04:12' meta/moved.txt

touch -d '2187-05-22 03:14' copies/source.csv

touch -d '2187-05-24 04:12' refs/anchor.txt
touch -d '2187-06-14 08:00' refs/one.txt
touch -d '2187-06-14 08:00' refs/two.txt
touch -d '2187-06-14 08:00' refs/three.txt

touch -d '2187-05-30 07:45' stamps/bay-2/clearance.txt
touch -d '2187-05-30 07:45' stamps/bay-2/torque.txt
touch -d '2187-05-30 07:45' stamps/bay-2

echo "seeded $LAB"
