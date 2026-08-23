#!/usr/bin/env bash
# setup.sh -- seeds /labs/05-globbing-and-quoting/01-globs
#
# Artifacts -> exercises:
#   panels/     twelve panel logs, one misnumbered (panel-7.log), one uppercase
#               (PANEL-09.LOG), one backup (panel-03.log.bak), one dot-file
#               (.panel-00.log)  -> ex 5-20, the ?/[]/[!]/class tier
#   readings/   date-stamped extracts, two per day, 2187-05-15..20  -> ex 21-28
#   mixed/      the names that break naive patterns: A.txt, -dash.txt, a space,
#               a trailing tilde, a literal '*' in a name  -> ex 29-36
#   deep/       a three-level tree plus a symlink to a sibling  -> globstar, ex 37-42
#   empty/      an empty directory, for nullglob/failglob  -> ex 43-46
#   spec/sweep-notes.txt   housekeeping's stated pattern; read again in 05/05
#
# Idempotent: removes its own tree first, creates nothing outside LAB.
set -euo pipefail

LAB="/labs/05-globbing-and-quoting/01-globs"
rm -rf "$LAB"
mkdir -p "$LAB"/{panels,readings,mixed,deep,empty,spec}
cd "$LAB"

# --- panels ------------------------------------------------------------------
for n in 01 02 03 04 05 06 08 10 11 12; do
  printf 'panel %s\nstrain 0.4%s\nstatus nominal\n' "$n" "${n#0}" > "panels/panel-$n.log"
done
printf 'panel 07\nstrain 0.47\nstatus nominal\n'      > 'panels/panel-7.log'
printf 'panel 09\nSTRAIN 0.49\nSTATUS NOMINAL\n'      > 'panels/PANEL-09.LOG'
printf 'panel 03\nstrain 0.43\nstatus nominal\n'      > 'panels/panel-03.log.bak'
printf 'panel 00\nstrain 0.40\nstatus nominal\n'      > 'panels/.panel-00.log'

# --- readings ----------------------------------------------------------------
for d in 15 16 17 18 19 20; do
  for t in 0800 1600; do
    printf '2187-05-%s %s\nstrain 0.4%s\n' "$d" "$t" "${d#1}" \
      > "readings/2187-05-$d-$t.txt"
  done
done
printf 'partial extract, do not use\n' > 'readings/2187-05-17-1600.txt.partial'

# --- mixed -------------------------------------------------------------------
printf 'lowercase a\n'          > 'mixed/a.txt'
printf 'uppercase A\n'          > 'mixed/A.txt'
printf 'begins with a dash\n'   > 'mixed/-dash.txt'
printf 'has a space in it\n'    > 'mixed/two words.txt'
printf 'editor backup\n'        > 'mixed/notes.txt~'
printf 'a literal asterisk\n'   > 'mixed/star*.txt'
printf 'a literal question\n'   > 'mixed/what?.txt'
printf 'a bracket pair\n'       > 'mixed/[set].txt'
printf 'no extension\n'         > 'mixed/README'
printf 'digit first\n'          > 'mixed/1st.txt'
printf 'hidden config\n'        > 'mixed/.cfg'

# --- deep --------------------------------------------------------------------
for bay in 01 02 03; do
  mkdir -p "deep/deck-03/bay-$bay"/{readings,faults}
  printf 'strain 0.4%s\n' "${bay#0}" > "deep/deck-03/bay-$bay/readings/2187-05-17.txt"
  printf 'none\n'                    > "deep/deck-03/bay-$bay/faults/2187-05-17.txt"
done
mkdir -p deep/archive
printf 'archived 2187-04\n' > deep/archive/2187-04.txt
ln -s ../archive deep/deck-03/archive-link
printf 'hidden inside the tree\n' > deep/deck-03/.private.txt

# --- spec --------------------------------------------------------------------
cat > spec/sweep-notes.txt <<'EOF'
Housekeeping, standing pattern
------------------------------
The overnight sweep removes, from each working directory:

    *.log        panel and run logs
    *.txt        extracts and notes
    *.bak        anything a previous sweep renamed

It runs as the operator's own account, in the directory it is pointed at, with
no recursion. It does not enable dotglob. Anything it does not match is left
exactly where it is.

Nobody has changed the pattern in four years. It is written on the wall in
engineering, which is the reason everybody knows it.
EOF

touch -d '2187-06-01 03:00:00' spec/sweep-notes.txt

echo "seeded $LAB"
