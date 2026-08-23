#!/usr/bin/env bash
# setup.sh -- seeds /labs/05-globbing-and-quoting/03-quoting
#
# Artifacts -> exercises:
#   names/          filenames that punish unquoted use: spaces, a leading dash,
#                   a newline, a tab, a quote, a dollar sign, a semicolon,
#                   a backtick, a glob character   -> ex 12-26
#   logs/           three logs whose CONTENT contains quotes and dollar signs,
#                   for grep-pattern quoting        -> ex 27-34
#   scripts/        two working scripts with quoting bugs the student fixes
#                     -> ex 40-46
#   msg/            files whose contents are used with $(cat) to show what
#                   quoting does to command substitution -> ex 35-39
#   scratch/        student's own
#
# Idempotent: removes its own tree first, creates nothing outside LAB.
set -euo pipefail

LAB="/labs/05-globbing-and-quoting/03-quoting"
rm -rf "$LAB"
mkdir -p "$LAB"/{names,logs,scripts,msg,scratch}
cd "$LAB"

cd names
printf 'panel 3 strain readings\n'  > 'deck 03 readings.txt'
printf 'a name that starts with a dash\n' > ./'-report.txt'
printf 'two lines in the name\n'    > "$(printf 'two\nlines.txt')"
printf 'a tab in the name\n'        > "$(printf 'tab\there.txt')"
printf "an apostrophe\n"            > "captain's log.txt"
printf 'a dollar sign\n'            > 'cost$5.txt'
printf 'a semicolon\n'              > 'a;b.txt'
printf 'a backtick\n'               > 'back`tick.txt'
printf 'a literal star\n'           > 'star*.txt'
printf 'plain\n'                    > plain.txt
cd ..

cat > logs/comms.log <<'LOG'
2187-05-30 08:02 rhea: panel-03 reading is 0.47, that's outside spec
2187-05-30 08:04 cass: engineering says "outside spec" by whose numbers
2187-05-30 08:05 rhea: the ones in $SPEC_DIR/thresholds.txt
2187-05-30 08:09 cass: they say those were revised, use the ones on the wall
2187-05-30 08:11 rhea: the wall says sweep *.log *.txt *.bak nightly
2187-05-30 08:12 cass: different wall, apparently
LOG

cat > logs/sweep.log <<'LOG'
2187-05-30 03:00 sweep start
2187-05-30 03:00 pattern: *.log
2187-05-30 03:00 pattern: *.txt
2187-05-30 03:00 pattern: *.bak
2187-05-30 03:00 removed 41 files
2187-05-30 03:00 sweep end
LOG

cat > logs/errors.log <<'LOG'
ERROR: cannot open $HOME/readings: no such file
ERROR: pattern "panel-*.log" matched 0 files
ERROR: variable SPEC_DIR was empty; used /
WARN:  cost was $5 over budget
LOG

printf 'the readings for deck 03\n' > msg/note.txt
printf 'line one\nline two\nline three\n' > msg/three.txt
printf '  leading and trailing spaces  \n' > msg/spaces.txt

cat > scripts/backup.sh <<'SH'
#!/usr/bin/env bash
# Copies every .txt in a directory into a backup directory.
# It works on tidy names and fails on the ones in ../names.
# Do not run it on ../names until you have read it.
DIR=$1
DEST=$2
for f in $DIR/*.txt; do
    cp $f $DEST/$f.bak
done
SH

cat > scripts/report.sh <<'SH'
#!/usr/bin/env bash
# Prints a one-line summary. Three quoting bugs, all in the last four lines.
NAME=$1
COUNT=$(ls | wc -l)
MSG=$(cat ../msg/note.txt)
echo $NAME: $COUNT entries, note says $MSG
echo done at $(date +%H:%M) *
SH
chmod +x scripts/*.sh

touch -d '2187-05-30 08:15:00' logs/*.log
echo "seeded $LAB"
