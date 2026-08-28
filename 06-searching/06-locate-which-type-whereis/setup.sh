#!/usr/bin/env bash
# setup.sh -- seeds /labs/06-searching/06-locate-which-type-whereis
#
# THE ANSWER KEY. Students are told not to open this.
#
# Two halves:
#   1. locate vs find. The image builds its locate database at image build
#      time, when /labs is still an empty volume mount point, so the index
#      knows the system and knows NOTHING about any lab. `locate strain`
#      finds nothing here until `sudo updatedb` runs. That is the lesson:
#      an index answers instantly and answers about the past.
#   2. which / type / command -v / whereis. tools/ and tools-b/ both hold a
#      `strain-report`, so PATH order decides. tools/ also holds an `echo`
#      and a `test`, which are builtins and therefore unreachable by name
#      no matter what PATH says -- `which` lies about this and `type` does
#      not.
#
# Idempotent: removes its own tree first, creates nothing outside LAB.
set -euo pipefail

LAB="/labs/06-searching/06-locate-which-type-whereis"
rm -rf "$LAB"
mkdir -p "$LAB"/{tools,tools-b,notes,archive,scratch}
cd "$LAB"

########## tools/ -- first on PATH in the exercises ##########

cat > tools/strain-report <<'EOF'
#!/usr/bin/env bash
echo "strain-report: tools/ version -- 2186 build, superseded"
EOF

cat > tools/deck-scan <<'EOF'
#!/usr/bin/env bash
echo "deck-scan: walks a deck and prints panel ids"
EOF

# a name that collides with a shell builtin
cat > tools/echo <<'EOF'
#!/usr/bin/env bash
printf 'tools/echo was run, with args: %s\n' "$*"
EOF

# a name that collides with a builtin AND with /usr/bin
cat > tools/test <<'EOF'
#!/usr/bin/env bash
echo "tools/test was run"
EOF

# executable bit deliberately missing
cat > tools/panel-check <<'EOF'
#!/usr/bin/env bash
echo "panel-check: never runs, because nobody set the execute bit"
EOF

chmod 755 tools/strain-report tools/deck-scan tools/echo tools/test
chmod 644 tools/panel-check

########## tools-b/ -- second on PATH, shadowed ##########

cat > tools-b/strain-report <<'EOF'
#!/usr/bin/env bash
echo "strain-report: tools-b/ version -- corrected 2187 build"
EOF

cat > tools-b/bay-audit <<'EOF'
#!/usr/bin/env bash
echo "bay-audit: only exists in tools-b/"
EOF

chmod 755 tools-b/strain-report tools-b/bay-audit

########## archive/ -- material for the locate half ##########

mkdir -p archive/2187-05 archive/2187-06
for m in 05 06; do
    for d in 03 09 17; do
        printf '2187-%s-%s  strain sample\n' "$m" "$d" \
            > "archive/2187-$m/strain-2187-$m-$d.log"
    done
done
printf 'panel index, deck 03\n' > archive/panel-index.txt
printf 'panel index, deck 05\n' > archive/panel-index-05.txt

########## notes/ ##########

cat > notes/handover.txt <<'EOF'
handover, deck 03

Two things people keep getting wrong on this station.

First: `locate` is not a fast `find`. It is a fast `find` OF AN OLD LIST.
Somebody built that list at some point in the past and nothing has updated
it since. When it says a file is not there, what it means is that the file
was not there when the list was made. When it says a file IS there, the
file may well have been deleted an hour ago. Both mistakes look like an
answer, which is why they are dangerous.

Second: when a command does not do what you expect, find out WHICH command
you actually ran before you start reading its source. There is more than
one way for a name to resolve, they are not all files, and the tool most
people reach for only knows about one of them.

If two directories on PATH both hold a script with the same name, the one
that runs is not the newer one, and it is not the better one.
EOF

cat > notes/paths.txt <<'EOF'
Suggested PATH for the exercises in this lesson. Run it in your own shell;
it lasts until you close the shell, and nothing outside this shell sees it.

    export PATH="$PWD/tools:$PWD/tools-b:$PATH"

To put it back:

    exec bash -l

Do not edit ~/.bashrc for this lesson. Chapter 8 is where the environment
is made to persist, and doing it early makes the exercises here lie.
EOF

########## scratch ##########
printf 'yours to break\n' > scratch/README

find . -exec touch -h -d '2187-06-11 09:00:00' {} +

# The copy that WINS the PATH search is the older one. That is the point of
# the pair, and exercise 61 checks it with stat, so the two must differ.
touch -d '2186-11-02 16:20:00' tools/strain-report
touch -d '2187-06-10 08:05:00' tools-b/strain-report

echo "seeded $LAB"
