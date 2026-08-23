#!/usr/bin/env bash
# setup.sh -- seeds /labs/04-creating-copying-destroying/04-rm-safely
#
# Artifacts -> exercises:
#   junk/                   ordinary files and a subtree to delete normally -> ex 1-9
#   awkward/                names that fight the shell: -f, --force, a space, a newline,
#                           and one ordinary name to keep -> ex 10-19 (the -- and ./ fixes)
#   protected/keep.txt      mode 0400 inside a writable directory -> ex 20-23 (rm prompts,
#                           and deletes it anyway; permission lives on the DIRECTORY)
#   locked/                 mode 0555 directory holding a 0644 file -> ex 24-27 (writable file
#                           inside an unwritable directory cannot be removed)
#   linked/                 a hard-link pair and a symlink to a file and to a directory
#                             -> ex 28-33 (rm unlinks a name, and the trailing-slash trap)
#   busy/big.log            a file to delete while something holds it open -> ex 40-42
#   trash/                  empty; the trash-pattern exercises build into it -> ex 36-38
#   scratch/                empty; anything violent happens in here
#
# Idempotent: removes its own tree first, creates nothing outside LAB.
set -euo pipefail

LAB="/labs/04-creating-copying-destroying/04-rm-safely"
rm -rf "$LAB"
mkdir -p "$LAB"/{junk,awkward,protected,locked,linked,busy,trash,scratch}
cd "$LAB"

# --- junk/: ordinary deletions ---------------------------------------------
for n in 01 02 03 04 05 06; do
  printf 'panel log %s\nnothing outstanding\n' "$n" > "junk/panel-$n.log"
done
mkdir -p junk/old/deeper
printf 'archived 2187-05-11\n' > junk/old/notes.txt
printf 'deeper still\n'        > junk/old/deeper/buried.txt

# --- awkward/: names that fight the shell ----------------------------------
printf 'a file literally named -f\n'         > awkward/-f
printf 'a file literally named --force\n'    > awkward/--force
printf 'two words, one name\n'               > 'awkward/strain report.txt'
printf 'a name with a newline in it\n'       > "$(printf 'awkward/two\nlines.txt')"
printf 'ordinary, keep me\n'                 > awkward/keep-this.txt

# --- protected/: read-only file in a writable directory --------------------
printf 'deck 3 rota. read only.\n' > protected/keep.txt
printf 'ordinary neighbour\n'      > protected/other.txt
chmod 0400 protected/keep.txt

# --- locked/: writable file in an unwritable directory ---------------------
printf 'you can edit me but you cannot unlink me\n' > locked/report.txt
chmod 0644 locked/report.txt
chmod 0555 locked

# --- linked/: two names for one file, plus symlinks ------------------------
printf 'strain 0.41\nstrain 0.43\n' > linked/readings.txt
ln linked/readings.txt linked/readings-alias.txt
ln -s readings.txt linked/latest.txt
mkdir -p linked/archive
printf 'archived reading\n' > linked/archive/2187-05-11.txt
ln -s archive linked/archive-link

# --- busy/: something to delete while it is open ---------------------------
awk 'BEGIN { for (i = 1; i <= 20000; i++) printf "line %05d of the panel feed\n", i }' \
  > busy/big.log

touch -d '2187-05-17 08:00:00' junk/panel-0*.log
touch -d '2187-05-11 22:00:00' junk/old/notes.txt junk/old/deeper/buried.txt

echo "seeded $LAB"
