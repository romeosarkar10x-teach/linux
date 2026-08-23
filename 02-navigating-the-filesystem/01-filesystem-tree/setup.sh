#!/usr/bin/env bash
# setup.sh -- seeds /labs/02-navigating-the-filesystem/01-filesystem-tree
#
# Artifacts -> exercises:
#   roster.txt                       -> ex 2, 6 (a file at the lab root, reachable by many paths)
#   deck-3/bay-{1,2,3}/              -> ex 5-9 (a tree deep enough for real relative walking)
#   deck-3/bay-2/panels/panel-07/    -> ex 8, 9, 13 (four levels down; makes `..` chains worth it)
#   shortcut -> deck-3/bay-2         -> ex 10-12, 16 (logical vs physical pwd, realpath)
#   deck-3/bay-2/readings.log        -> ex 14 (basename/dirname with a suffix)
#
# Idempotent: removes its own tree first, creates nothing outside LAB.
set -euo pipefail

LAB="/labs/02-navigating-the-filesystem/01-filesystem-tree"
rm -rf "$LAB"
mkdir -p "$LAB"
cd "$LAB"

cat > roster.txt <<'EOF'
DECK 3  bay 1   strain sensors      12 panels
DECK 3  bay 2   strain sensors      18 panels
DECK 3  bay 3   thermal sensors      6 panels
EOF

mkdir -p deck-3/bay-1 deck-3/bay-2/panels/panel-07 deck-3/bay-3

printf 'bay 1: 12 panels, last survey 2187-04-02\n' > deck-3/bay-1/survey.txt
printf 'bay 2: 18 panels, last survey 2187-05-11\n' > deck-3/bay-2/survey.txt
printf 'bay 3: 6 panels, last survey 2186-11-30\n'  > deck-3/bay-3/survey.txt

cat > deck-3/bay-2/readings.log <<'EOF'
2187-06-13 04:00  panel-07  strain 0.412
2187-06-13 08:00  panel-07  strain 0.418
2187-06-13 12:00  panel-07  strain 0.421
EOF

printf 'panel 07 -- replaced 2186-08-19, no faults logged since\n' \
    > deck-3/bay-2/panels/panel-07/panel.txt

ln -sfn deck-3/bay-2 shortcut

echo "seeded $LAB"
