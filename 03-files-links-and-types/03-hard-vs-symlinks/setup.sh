#!/usr/bin/env bash
# setup.sh -- seeds /labs/03-files-links-and-types/03-hard-vs-symlinks
#
# Artifacts -> exercises:
#   panels/panel-07.txt        -> ex 1-8 (one real file with a hard link and a symlink beside it,
#                                 so the two kinds can be compared on one target)
#   panels/panel-07-alias      ->        (hard link: same inode, count 2)
#   panels/current             ->        (symlink -> panel-07.txt, relative)
#   panels/current-abs         ->        (symlink -> /labs/.../panel-07.txt, absolute: ex 9-11
#                                 show the two behave identically until the tree is moved)
#   chain/{a,b,c}              -> ex 12-16 (a -> b -> c -> ../target/report.txt: readlink vs
#                                 readlink -f, and the one-hop-versus-all-hops distinction)
#   target/report.txt          ->
#   dangling/ghost, ghost-dir  -> ex 17-21 (symlinks whose targets never existed; the link is fine,
#                                 the dereference is what fails)
#   dangling/vanished          ->        (target's parent directory exists, target does not, so
#                                 readlink -f succeeds where readlink -e fails)
#   moved/inner/note.txt       -> ex 22-25 (a relative symlink that survives its directory being
#   moved/inner/near           ->          renamed, and an absolute one that does not)
#   moved/inner/far            ->
#   loop/{ring-a,ring-b}       -> ex 26-27 (two symlinks pointing at each other: ELOOP)
#   perms/secret.txt           -> ex 28-30 (mode 600 file behind a lrwxrwxrwx symlink: the link's
#   perms/open-door            ->          permission bits are decoration, the target's are real)
#   sizes/                     -> ex 31-33 (symlinks to paths of very different lengths, so the
#                                 size column is visibly the length of the target string)
#
# Idempotent: removes its own tree first, creates nothing outside LAB.
set -euo pipefail

LAB="/labs/03-files-links-and-types/03-hard-vs-symlinks"
chmod -R u+w "$LAB" 2>/dev/null || true
rm -rf "$LAB"
mkdir -p "$LAB"
cd "$LAB"

# ---- panels/ : one target, both kinds of link ------------------------------
mkdir -p panels
printf 'panel 07\nseated 2187-06-09\ntorque 42 Nm\n' > panels/panel-07.txt
ln    panels/panel-07.txt panels/panel-07-alias
ln -s panel-07.txt        panels/current
ln -s "$LAB/panels/panel-07.txt" panels/current-abs

# ---- chain/ : symlink -> symlink -> symlink -> file ------------------------
mkdir -p chain target
printf 'strain report, deck 3\nstatus: within tolerance\n' > target/report.txt
ln -s ../target/report.txt chain/c
ln -s c                    chain/b
ln -s b                    chain/a

# ---- dangling/ : links to things that are not there ------------------------
mkdir -p dangling
ln -s /mnt/engineering/strain-2187-05-22.csv dangling/ghost
ln -s /mnt/engineering                       dangling/ghost-dir
ln -s ../target/gone.csv                     dangling/vanished

# ---- moved/ : relative survives a rename, absolute does not ----------------
mkdir -p moved/inner
printf 'bay 2 clearance 0.6mm\n' > moved/inner/note.txt
ln -s note.txt                    moved/inner/near
ln -s "$LAB/moved/inner/note.txt" moved/inner/far

# ---- loop/ : two links pointing at each other ------------------------------
mkdir -p loop
ln -s ring-b loop/ring-a
ln -s ring-a loop/ring-b

# ---- perms/ : the link's mode bits are decoration --------------------------
mkdir -p perms
printf 'hull tolerance override code: 4471\n' > perms/secret.txt
chmod 600 perms/secret.txt
ln -s secret.txt perms/open-door
printf 'engineering seal, deck 3\n' > perms/sealed.txt
chmod 000 perms/sealed.txt
ln -s sealed.txt perms/back-door

# ---- sizes/ : the size column is the length of the target string -----------
mkdir -p sizes/very/deeply/nested/subdirectory
printf 'here\n' > sizes/very/deeply/nested/subdirectory/leaf.txt
ln sizes/very/deeply/nested/subdirectory/leaf.txt sizes/leaf.txt
ln -s leaf.txt sizes/short
ln -s very/deeply/nested/subdirectory/leaf.txt sizes/long

chown -R cadet:crew "$LAB" 2>/dev/null || true
echo "seeded $LAB"
