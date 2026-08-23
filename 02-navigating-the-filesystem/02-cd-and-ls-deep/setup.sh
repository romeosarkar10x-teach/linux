#!/usr/bin/env bash
# setup.sh -- seeds /labs/02-navigating-the-filesystem/02-cd-and-ls-deep
#
# Artifacts -> exercises:
#   logs/            -> ex 6-13  (mixed sizes and mtimes: -t, -S, -r, -h all give different orders)
#   logs/.rotated/   -> ex 4, 5  (hidden directory; -a vs -A vs plain)
#   logs/.keep       -> ex 4     (hidden file)
#   Archive/ archive/-> ex 14    (case: C-locale sort puts uppercase first)
#   runs/            -> ex 13    (run-1 .. run-10: -v sorts them differently from the default)
#   deep/            -> ex 15-17 (three levels, for -R and -d)
#   current -> logs  -> ex 9, 18 (symlink: -l, -F, and trailing-slash behaviour)
#   empty-bay/       -> ex 16    (an empty directory that -R still names)
#
# Idempotent: removes its own tree first, creates nothing outside LAB.
set -euo pipefail

LAB="/labs/02-navigating-the-filesystem/02-cd-and-ls-deep"
rm -rf "$LAB"
mkdir -p "$LAB"
cd "$LAB"

mkdir -p logs/.rotated deep/deck-3/bay-2 empty-bay Archive archive runs

# Sizes deliberately uncorrelated with names and with times.
head -c 180    /dev/zero | tr '\0' 'a' > logs/strain-2187-06-11.log
head -c 24000  /dev/zero | tr '\0' 'b' > logs/strain-2187-06-12.log
head -c 1400   /dev/zero | tr '\0' 'c' > logs/strain-2187-06-13.log
head -c 6300   /dev/zero | tr '\0' 'd' > logs/thermal-2187-06-13.log
head -c 900000 /dev/zero | tr '\0' 'e' > logs/hull-2187-06-10.log

printf 'rotated 2187-05\n' > logs/.rotated/strain-2187-05.log.1
printf 'rotated 2187-04\n' > logs/.rotated/strain-2187-04.log.2
printf 'do not delete this directory\n' > logs/.keep

# Newest name is NOT the newest mtime, and neither matches size order.
touch -d '2187-06-11 03:00:00' logs/strain-2187-06-11.log
touch -d '2187-06-14 09:15:00' logs/strain-2187-06-12.log
touch -d '2187-06-12 22:05:00' logs/strain-2187-06-13.log
touch -d '2187-06-13 06:40:00' logs/thermal-2187-06-13.log
touch -d '2187-06-10 01:20:00' logs/hull-2187-06-10.log

printf 'archived summaries, capitalised by whoever made it in 2183\n' > Archive/note.txt
printf 'archived summaries, the other one\n'                          > archive/note.txt

printf 'panel survey\n' > deep/deck-3/bay-2/survey.txt
printf 'deck notes\n'   > deep/deck-3/notes.txt
printf 'top level\n'    > deep/index.txt

for n in 1 2 3 9 10 11 20; do
    printf 'summariser run %s\n' "$n" > "runs/run-$n.log"
done

ln -sfn logs current

echo "seeded $LAB"
