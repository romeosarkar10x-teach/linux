#!/usr/bin/env bash
# setup.sh -- seeds /labs/05-globbing-and-quoting/04-word-splitting
#
# Artifacts -> exercises:
#   data/crew.csv          colon-separated records for IFS= read -r          -> ex 20-29
#   data/paths.txt         one path per line, several with spaces            -> ex 30-35
#   data/bad-line.txt      a line with a trailing backslash and one with \t  -> ex 33-35
#   data/spaced.txt        leading/trailing/multiple spaces, tabs, blanks    -> ex 12-19
#   bays/                  eight directories, three with spaces in the name  -> ex 36-42
#   scripts/count.sh       counts its arguments; the measuring instrument
#   scripts/deploy.sh      buggy: unquoted "$@" analogue, splits on paths    -> ex 43-49
#   scripts/tally.sh       buggy: uses $* where it needs "$@"                -> ex 43-49
#   scratch/               the student's own wreckage
#
# Idempotent: removes its own tree first, creates nothing outside LAB.
set -euo pipefail

LAB="/labs/05-globbing-and-quoting/04-word-splitting"
rm -rf "$LAB"
mkdir -p "$LAB"/{data,bays,scripts,scratch}
cd "$LAB"

cat > data/crew.csv <<'EOF'
rhea:systems:deck-05:2187-04-02
cass:comms:deck-02:2187-04-02
mikko:power:deck-05:2187-05-11
sal:galley:deck-01:2186-11-30
teodor:hull:deck-07:2187-01-19
EOF

cat > data/paths.txt <<'EOF'
/labs/05-globbing-and-quoting/01-globs/spec
/labs/05-globbing-and-quoting/03-quoting/names
/labs/deck 05/bay 01
/labs/deck 05/bay 02
/labs/05-globbing-and-quoting/04-word-splitting/bays
EOF

printf 'first line ends in a backslash \\\n' >  data/bad-line.txt
printf 'second line\thas a real tab in it\n'  >> data/bad-line.txt
printf '   third line has leading spaces\n'   >> data/bad-line.txt

printf '  leading and trailing  \n'      >  data/spaced.txt
printf 'one\ttab\tseparated\tline\n'     >> data/spaced.txt
printf '\n'                              >> data/spaced.txt
printf 'multiple    internal    spaces\n' >> data/spaced.txt
printf 'trailing-only   \n'              >> data/spaced.txt

mkdir -p 'bays/bay-01' 'bays/bay-02' 'bays/bay 03' 'bays/bay-04' \
         'bays/bay 05' 'bays/bay-06' 'bays/bay 07' 'bays/bay-08'
for d in bays/*/; do
    printf 'strain 0.41\nstrain 0.44\n' > "$d/readings.txt"
done

cat > scripts/count.sh <<'EOF'
#!/usr/bin/env bash
# Prints how many arguments it received, then each one in brackets.
printf 'argc=%d\n' "$#"
printf '[%s]\n' "$@"
EOF

cat > scripts/deploy.sh <<'EOF'
#!/usr/bin/env bash
# Copies each path named on stdin into the destination given as $1.
DEST=$1
while read line; do
    cp -r $line $DEST/
done
EOF

cat > scripts/tally.sh <<'EOF'
#!/usr/bin/env bash
# Passes its arguments on to count.sh so we can see how many survived.
HERE=$(dirname "$0")
bash "$HERE/count.sh" $*
EOF

chmod 755 scripts/*.sh

touch -d '2187-05-30 03:00:00' data/*.txt data/crew.csv
touch -d '2187-05-17 08:00:00' scripts/*.sh

echo "seeded $LAB"
