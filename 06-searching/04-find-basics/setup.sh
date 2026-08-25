#!/usr/bin/env bash
# setup.sh -- seeds /labs/06-searching/04-find-basics
#
# Teaches: find as a walk, path arguments, -name vs -iname vs -path,
# -type, -maxdepth/-mindepth, the unquoted-glob trap, the implicit
# -print, and why option order matters.
#
# Artifacts -> exercises:
#   decks/ 3 levels deep, mixed case names       -name/-iname, -maxdepth
#   decks/deck-03/panel-03.log AND panel-03.log~ -name '*.log' misses ~
#   a file and a directory both named "readings" -type d vs -type f
#   scratch/ contains strain-01.log so an
#     unquoted *.log in the LAB root expands     the quoting trap
#   links/ symlink to file, to dir, and broken   -type l vs -type f
#   deck-03/.hidden-notes                        find does see dotfiles
#   empty dirs at two depths                     -type d, and lesson 05
#   spaces and a leading dash in names           -print0 motivation
# Idempotent: removes its own tree first, creates nothing outside LAB.
set -euo pipefail

LAB="/labs/06-searching/04-find-basics"
rm -rf "$LAB"
mkdir -p "$LAB"
cd "$LAB"

mkdir -p decks/deck-03/bay-01 decks/deck-03/bay-02 decks/deck-04/bay-01 \
         decks/deck-05/bay-01 decks/deck-05/bay-02 decks/deck-05/bay-03 \
         archive/2187-05 archive/2187-06 links scratch reports \
         decks/deck-04/empty decks/deck-05/bay-03/empty

mk_log() {  # $1 path, $2 label
    printf '2187-06-09 04:00  %s  strain 0.41\n2187-06-09 05:00  %s  strain 0.44\n' "$2" "$2" > "$1"
}

mk_log decks/deck-03/panel-03.log            panel-03
mk_log decks/deck-03/panel-09.log            panel-09
mk_log 'decks/deck-03/panel-03.log~'         panel-03-old
mk_log decks/deck-03/bay-01/strain-01.log    bay-01
mk_log decks/deck-03/bay-01/strain-02.LOG    bay-01
mk_log decks/deck-03/bay-02/strain-01.log    bay-02
mk_log decks/deck-04/panel-04.log            panel-04
mk_log decks/deck-04/bay-01/strain-01.log    bay-01
mk_log decks/deck-05/panel-05.log            panel-05
mk_log decks/deck-05/bay-01/Strain-01.log    bay-01
mk_log decks/deck-05/bay-02/strain-01.txt    bay-02
mk_log archive/2187-05/panel-03.log          panel-03
mk_log archive/2187-06/panel-03.log          panel-03
mk_log scratch/strain-01.log                 scratch

printf 'notes not meant to be read by the tooling\n' > decks/deck-03/.hidden-notes
printf 'bay 02 checklist\n' > decks/deck-03/bay-02/readings
mkdir -p decks/deck-04/readings
printf '0.41\n0.44\n' > decks/deck-04/readings/raw.txt

printf '2187-06-09  deck 05  hand check\n' > 'decks/deck-05/bay 03 notes.txt'
printf 'placeholder\n' > 'decks/deck-05/-summary.txt'

cat > reports/index.txt <<'EOF'
Deck log index, generated 2187-06-09.

Logs live under decks/<deck>/ and decks/<deck>/<bay>/. The convention is
    panel-NN.log      one per deck
    strain-NN.log     one per bay
Editors leave backup copies ending in a tilde. Those are not logs and
must not be counted as logs, but they are not deleted either.

Case is not enforced. Some bays were set up by hand.
EOF

cat > reports/handover.txt <<'EOF'
Handover, 2187-06-09.

Somebody asked for "every log on the station". Nobody has agreed what a
log is. Before you answer that question, decide whether you mean a name
that ends in .log, a file that contains log lines, or a file somebody
would be upset to lose. The three sets are different sizes here.

There is a file called readings and a directory called readings. That
was not deliberate.
EOF

ln -s ../decks/deck-03/panel-03.log links/latest.log
ln -s ../decks/deck-03                links/deck-03
ln -s ../decks/deck-99/panel-99.log   links/broken.log

find . -exec touch -h -d '2187-06-09 10:00:00' {} +

echo "seeded $LAB"
