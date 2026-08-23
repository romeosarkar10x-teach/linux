#!/usr/bin/env bash
# setup.sh -- seeds /labs/03-files-links-and-types/02-inodes
#
# Artifacts -> exercises:
#   roster/roster.txt        -> ex 4-9 (one inode, three names: link count 3)
#   roster/crew-list.txt     ->        (hard link, made second)
#   roster/.backup/names.txt ->        (third name, in a subdirectory, so the student sees that a
#                                       hard link is not confined to one directory)
#   roster/copy.txt          -> ex 6-8 (byte-identical to roster.txt, different inode -- the whole
#                                       point: identical contents prove nothing about identity)
#   decks/                   -> ex 10-12 (a directory whose link count is subdirectories + 2)
#   decks/deck-{3,4,5}/      ->        (three of them, so the count is 5 and not a coincidence)
#   scratch/expendable.txt   -> ex 13-15 (removed during the lesson; link count drops, contents stay)
#   scratch/keeper.txt       ->        (its second name, in the same directory)
#   locked/notes.txt         -> ex 17-18 (mode 444 in a writable directory: rm succeeds anyway,
#                                       because deletion is a directory write, not a file write)
#   sealed/                  -> ex 19 (mode 555 directory holding a mode 666 file: the inverse --
#                                       the file is writable and undeletable)
#   sealed/bolted.txt        ->
#
# Idempotent: removes its own tree first, creates nothing outside LAB.
set -euo pipefail

LAB="/labs/03-files-links-and-types/02-inodes"
chmod -R u+w "$LAB" 2>/dev/null || true
rm -rf "$LAB"
mkdir -p "$LAB"
cd "$LAB"

# ---- roster/ : one inode wearing three names, plus a decoy copy ------------
mkdir -p roster/.backup
printf 'rhea  ops\ncass  ops\ndorn  engineering\n' > roster/roster.txt
ln roster/roster.txt roster/crew-list.txt
ln roster/roster.txt roster/.backup/names.txt
cp roster/roster.txt roster/copy.txt

# ---- decks/ : directory link count = subdirectories + 2 --------------------
mkdir -p decks/deck-3 decks/deck-4 decks/deck-5
printf 'deck 3 online\n' > decks/deck-3/status.txt
printf 'deck 4 online\n' > decks/deck-4/status.txt
printf 'deck 5 offline\n' > decks/deck-5/status.txt

# ---- scratch/ : a name the student deletes ---------------------------------
mkdir -p scratch
printf 'strain readings, deck 3, 2187-06-11\n0.41\n0.38\n0.44\n' > scratch/keeper.txt
ln scratch/keeper.txt scratch/expendable.txt

# ---- locked/ : unwritable file, writable directory -------------------------
mkdir -p locked
printf 'sensor calibration, do not edit\n' > locked/notes.txt
chmod 444 locked/notes.txt

# ---- sealed/ : writable file, unwritable directory -------------------------
mkdir -p sealed
printf 'bolt torque log\n' > sealed/bolted.txt
chmod 666 sealed/bolted.txt
chmod 555 sealed

chown -R cadet:crew "$LAB" 2>/dev/null || true
echo "seeded $LAB"
