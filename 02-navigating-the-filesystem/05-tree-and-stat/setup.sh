#!/usr/bin/env bash
# setup.sh -- seeds /labs/02-navigating-the-filesystem/05-tree-and-stat
#
# Artifacts -> exercises:
#   bays/                 -> ex 1-6, 22 (a tree with depth, a dotfile level and a symlink, so
#                            tree's -a / -L / -d / -f / -l flags all have something to show)
#   bays/.calibration/    -> ex 3 (invisible to tree without -a; contains a file, so -a changes the
#                            reported count as well as the shape)
#   bays/deck-3/loop      -> ex 22 (symlink to an ancestor: tree -l must not be allowed to recurse
#                            forever, and reports the cycle)
#   manifest/             -> ex 9-13 (file(1) targets: the extension lies on two of them,
#                            and one entry is a symlink whose target does not exist)
#   accounting/           -> ex 14-18 (the story's case: ls shows nothing, du -sh shows 40M)
#   accounting/.staging/  -> the 40M that ls does not show
#   ledger/               -> ex 19-21 (the inverse: ls -l says 50M, du says 0 -- a sparse file)
#   stamps/               -> ex 7-8 (three files whose atime / mtime / ctime orders disagree)
#
# Idempotent: removes its own tree first, creates nothing outside LAB.
# Disk cost: ~43 MB of real blocks in the /labs volume.
set -euo pipefail

LAB="/labs/02-navigating-the-filesystem/05-tree-and-stat"
rm -rf "$LAB"
mkdir -p "$LAB"
cd "$LAB"

# ---- bays/ : a tree with something for every tree(1) flag -------------------
mkdir -p bays/deck-3/bay-{1,2}/panels bays/deck-4/bay-1 bays/.calibration
printf 'hull survey, deck 3 bay 1\n'      > bays/deck-3/bay-1/survey.txt
printf 'hull survey, deck 3 bay 2\n'      > bays/deck-3/bay-2/survey.txt
printf 'panel 07 seated\n'                > bays/deck-3/bay-2/panels/panel-07.txt
printf 'panel 08 seated\n'                > bays/deck-3/bay-2/panels/panel-08.txt
printf 'hull survey, deck 4 bay 1\n'      > bays/deck-4/bay-1/survey.txt
printf 'sensor zero offsets\n'            > bays/.calibration/offsets.txt
printf '.log\n'                           > bays/.treeignore-note
ln -sfn ../.. bays/deck-3/loop

# ---- stamps/ : three timestamps that disagree ------------------------------
mkdir -p stamps
printf 'old contents, opened recently\n'   > stamps/read-me.txt
printf 'fresh contents, never reopened\n'  > stamps/written.txt
printf 'untouched since it was filed\n'    > stamps/chmodded.txt
# atime and mtime are set independently, so their orders disagree:
#   read-me.txt  oldest mtime,  newest atime
#   written.txt  newest mtime,  oldest atime
touch -m -d '2187-06-01 08:00:00' stamps/read-me.txt
touch -a -d '2187-06-20 08:00:00' stamps/read-me.txt
touch -m -d '2187-06-14 08:00:00' stamps/written.txt
touch -a -d '2187-06-02 08:00:00' stamps/written.txt
touch -d  '2187-06-07 08:00:00' stamps/chmodded.txt
# ctime is not settable by touch: all three carry today's date, which is the
# finding for ex 8 -- a backdated mtime does not backdate the inode change.
chmod 640 stamps/chmodded.txt

# ---- manifest/ : file(1) targets, two with lying extensions ----------------
mkdir -p manifest
printf 'plain ASCII hull notes\n'                    > manifest/notes.txt
printf '#!/usr/bin/env bash\necho hull ok\n'         > manifest/check.sh
chmod +x manifest/check.sh
printf 'deck,bay,strain\n3,2,0.41\n4,1,0.38\n'       > manifest/strain.csv
: > manifest/empty.log
cp /bin/true manifest/hullscan                       # ELF, no extension
printf 'compressed hull telemetry\n' | gzip -c       > manifest/telemetry.txt   # gzip, .txt
cp /bin/true manifest/readme.txt                     # ELF, .txt
chmod 644 manifest/readme.txt                        # ...and not even executable, so the mode
                                                     # gives ex 13 no hint either
printf 'deck 3 bay 2 \xe2\x80\x94 sensor drift\n'    > manifest/drift.txt       # UTF-8, em dash
ln -sfn ../accounting/.staging/dump-2187-06-12.bin manifest/dangling.link
mkdir -p manifest/subsystem

# ---- accounting/ : ls says empty, du says 40M ------------------------------
mkdir -p accounting/.staging
head -c 41926656 /dev/zero | tr '\0' 'e' > accounting/.staging/dump.bin
printf 'staged for review 2187-06-12\n'  > accounting/.staging/note.txt

# ---- ledger/ : ls -l says 50M, du says 0 -----------------------------------
mkdir -p ledger
truncate -s 50M ledger/reserved.img
printf 'reservation opened, nothing written yet\n' > ledger/README

echo "seeded $LAB"
