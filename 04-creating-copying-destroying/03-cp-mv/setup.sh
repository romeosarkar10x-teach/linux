#!/usr/bin/env bash
# setup.sh -- seeds /labs/04-creating-copying-destroying/03-cp-mv
#
# Artifacts -> exercises:
#   source/                 a small deck-03 tree to copy: three files, two subdirectories,
#                           one symlink and one hard-link pair -> ex 5-16, 33-38
#   dest/                   EXISTS and is a directory. cp source dest vs cp source dest/
#                             -> ex 9-14 (the trailing-slash and -T exercises)
#   dest-file               EXISTS and is a regular file, so it can be clobbered -> ex 15-17
#   stale/                  three files whose mtimes are older than their source/ twins,
#                           and one that is NEWER -> ex 21-25 (cp -u, mv -u)
#   perms/exec.sh           mode 755, and perms/secret.txt mode 600 -> ex 26-29 (cp vs cp -p / -a)
#   rename/                 six panel logs with a wrong prefix -> ex 30-32 (mv is rename)
#   scratch/                empty; anything destructive happens in here
#
# Idempotent: removes its own tree first, creates nothing outside LAB.
set -euo pipefail

LAB="/labs/04-creating-copying-destroying/03-cp-mv"
rm -rf "$LAB"
mkdir -p "$LAB"/{source,dest,stale,perms,rename,scratch}
cd "$LAB"

# --- source/: the tree that gets copied all lesson -------------------------
mkdir -p source/readings source/faults
printf 'strain 0.41\nstrain 0.43\nstrain 0.44\n'          > source/readings/2187-05-17.txt
printf 'strain 0.51\nstrain 0.58\n'                        > source/readings/2187-05-18.txt
printf 'f-0117 seal, deck 3, cleared\nf-0118 open\n'       > source/faults/open.txt
printf 'deck 3 handover, shift 2\nnothing outstanding\n'   > source/handover.txt
ln -s readings/2187-05-17.txt source/latest.txt
ln source/faults/open.txt source/open-hardlink.txt

# --- dest/: already a directory, with one file already in it ---------------
printf 'placed here 2187-05-16\n' > dest/handover.txt

# --- dest-file: already a regular file -------------------------------------
printf 'this is a file, not a directory\n' > dest-file

# --- stale/: for cp -u and mv -u -------------------------------------------
printf 'strain 0.10\n'                > stale/2187-05-17.txt
printf 'strain 0.20\n'                > stale/2187-05-18.txt
printf 'older handover\n'             > stale/handover.txt
printf 'NEWER than the source copy\n' > stale/open.txt

# --- perms/: modes and times that a plain cp does not carry ----------------
printf '#!/usr/bin/env bash\necho "panel check ok"\n' > perms/exec.sh
printf 'crew rota, deck 3\ndo not circulate\n'        > perms/secret.txt
chmod 755 perms/exec.sh
chmod 600 perms/secret.txt

# --- rename/: six files with the wrong prefix ------------------------------
for n in 01 02 03 04 05 06; do
  printf 'panel log %s\n' "$n" > "rename/pnl_$n.log"
done

# --- timestamps ------------------------------------------------------------
# source/ is the recent copy; stale/ is mostly older, except stale/open.txt.
touch -d '2187-05-18 06:00:00' source/readings/2187-05-17.txt \
                               source/readings/2187-05-18.txt \
                               source/faults/open.txt \
                               source/handover.txt \
                               source/open-hardlink.txt
touch -d '2187-05-17 01:00:00' stale/2187-05-17.txt stale/2187-05-18.txt stale/handover.txt
touch -d '2187-05-19 23:00:00' stale/open.txt
touch -d '2187-05-17 08:00:00' perms/exec.sh perms/secret.txt
touch -d '2187-05-16 12:00:00' dest/handover.txt dest-file

echo "seeded $LAB"
