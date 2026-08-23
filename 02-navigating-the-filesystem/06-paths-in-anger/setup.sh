#!/usr/bin/env bash
# setup.sh -- seeds /labs/02-navigating-the-filesystem/06-paths-in-anger
#
# Every artefact here exists to make a naive command fail in an instructive way.
#
# Artifacts -> exercises:
#   awkward/                -> ex 1-8   (spaces, leading/trailing spaces, a tab, a newline)
#   dashes/                 -> ex 9-13  (names beginning with - : the -- and ./ escapes)
#   lookalikes/             -> ex 14-19 (two pairs that render identically: U+2011 vs '-',
#                              Cyrillic 'е' vs Latin 'e'; plus a zero-width joiner name)
#   dotted/                 -> ex 20-23 (.hidden, ..double, ..., and a plain 'dot' decoy)
#   metachars/              -> ex 24-26 (names containing * ? [ ] and a single quote)
#   report/                 -> ex 27-29 (a realistic mixed directory to apply all of it to)
#
# Idempotent: removes its own tree first, creates nothing outside LAB.
# Note: this script deliberately creates hostile filenames. Every one of them is
# inside LAB, and `kestrel reset 02/06` removes the tree wholesale with rm -rf.
set -euo pipefail

LAB="/labs/02-navigating-the-filesystem/06-paths-in-anger"
rm -rf "$LAB"
mkdir -p "$LAB"
cd "$LAB"

# ---- awkward/ : whitespace ---------------------------------------------------
mkdir -p awkward
mkdir -p 'awkward/deck 3 bay 2'
printf 'strain 0.41 nominal\n'      > 'awkward/deck 3 bay 2/strain log.txt'
printf 'filed with a trailing space\n' > 'awkward/notes.txt '
printf 'filed with a leading space\n'  > 'awkward/ notes.txt'
printf 'no whitespace at all\n'        > 'awkward/notes.txt'
printf 'tab in the middle\n'           > "$(printf 'awkward/panel\treport.txt')"
printf 'two lines in the NAME, not the file\n' > "$(printf 'awkward/two\nlines.txt')"

# ---- dashes/ : names that look like options ----------------------------------
mkdir -p dashes
printf 'not an option, a file\n'    > dashes/-audit
printf 'still not an option\n'      > dashes/--help
printf 'recursive force? no.\n'     > dashes/-rf
printf 'ordinary\n'                 > dashes/manifest.txt
mkdir -p -- '-staging'
mv -- '-staging' dashes/ 2>/dev/null || true

# ---- lookalikes/ : names that render identically -----------------------------
mkdir -p lookalikes
printf 'ASCII hyphen-minus, U+002D\n'          > 'lookalikes/strain-log.txt'
printf 'NON-BREAKING HYPHEN, U+2011\n'         > $'lookalikes/strain‑log.txt'
printf 'Latin e, U+0065\n'                     > 'lookalikes/deck.txt'
printf 'CYRILLIC SMALL LETTER IE, U+0435\n'    > $'lookalikes/dеck.txt'
printf 'a ZERO WIDTH SPACE sits before .txt\n' > $'lookalikes/panel​.txt'

# ---- dotted/ : the dot conventions -------------------------------------------
mkdir -p dotted
printf 'ordinary hidden file\n'        > dotted/.hidden-note
printf 'name begins with two dots\n'   > dotted/..double-dot
printf 'name is three dots\n'          > dotted/...
printf 'name is one visible dot word\n'> dotted/dot
mkdir -p dotted/.cache

# ---- metachars/ : characters the shell cares about ---------------------------
mkdir -p metachars
printf 'literal asterisk in the name\n' > 'metachars/glob*star.txt'
printf 'literal question mark\n'        > 'metachars/what?.txt'
printf 'literal brackets\n'             > 'metachars/range[0-9].txt'
printf 'an apostrophe in the name\n'    > "metachars/dorn's notes.txt"
printf 'a dollar sign in the name\n'    > 'metachars/$HOME.txt'

# ---- report/ : all of it at once ---------------------------------------------
mkdir -p report
printf 'deck,bay,strain\n3,2,0.41\n'         > 'report/strain 2187-06-12.csv'
printf 'deck,bay,strain\n4,1,0.38\n'         > 'report/strain 2187-06-13.csv'
printf 'summary for the week\n'              > 'report/-summary.txt'
printf 'you were not meant to see this one\n'> 'report/.draft'
mkdir -p 'report/old runs'
printf 'run 1\n' > 'report/old runs/run 1.log'
printf 'run 2\n' > 'report/old runs/run 2.log'

echo "seeded $LAB"
