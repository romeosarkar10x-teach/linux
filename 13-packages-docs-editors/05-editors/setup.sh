#!/bin/bash
# Lesson 13/05 — editing files in place: nano, vim, and $EDITOR.
# Idempotent: safe to re-run.
set -euo pipefail

LAB="/labs/13-packages-docs-editors/05-editors"

rm -rf "$LAB"
mkdir -p "$LAB"/{conf,text,notes,scratch}

# --------------------------------------------------------------- edit these ---
cat > "$LAB/conf/deck-cycle.conf" <<'DOC'
# settling times, seconds
# one line per deck: deck-NN SECONDS
deck-04 45
deck-07 30
deck-9 60
deck-11 forty
# cargo deck vents slowly since the refit
deck-09 120
DOC

cat > "$LAB/conf/hatch-alarms.conf" <<'DOC'
# hatch alarm thresholds
# WARN and FAIL are pressure deltas in kPa. FAIL must exceed WARN.
[deck-04]
warn = 2.0
fail = 1.5

[deck-07]
warn = 2.0
fail = 6.0

[deck-09]
warn = 2.0
fail = 6.0

[deck-11]
warn = 2.0
fail = 6.0
DOC

# A file with mixed tabs and spaces, which is invisible until you look for it.
printf 'deck-04\t45\n' > "$LAB/conf/settling.tsv"
printf 'deck-07 30\n' >> "$LAB/conf/settling.tsv"
printf 'deck-09\t120\n' >> "$LAB/conf/settling.tsv"
printf 'deck-11\t90\n' >> "$LAB/conf/settling.tsv"

# A file with CRLF line endings, as if it came off someone's laptop.
printf 'deck-04,45\r\ndeck-07,30\r\ndeck-09,120\r\n' > "$LAB/conf/from-laptop.csv"

# Something long enough that scrolling is not a strategy.
{
    printf '# hatch cycle log, deck 09\n'
    i=1
    while [ "$i" -le 400 ]; do
        printf '2187-07-0%d 0%d:%02d cycle %04d ok\n' \
            $(( (i % 5) + 1 )) $(( (i % 9) + 1 )) $(( i % 60 )) "$i"
        i=$((i + 1))
    done
    printf '2187-07-06 11:02 cycle 0401 SKIPPED pressure did not settle\n'
    i=402
    while [ "$i" -le 600 ]; do
        printf '2187-07-06 1%d:%02d cycle %04d ok\n' \
            $(( i % 10 )) $(( i % 60 )) "$i"
        i=$((i + 1))
    done
} > "$LAB/text/cycles.log"

cat > "$LAB/text/handover.txt" <<'DOC'
Deck 09 handover
================

The cargo deck vents slowly since the refit. Settling time is 120 seconds and
should not be lowered without talking to whoever is on deck.

TODO: write this up properly.
TODO: check the alarm thresholds, one of them looks wrong.
TODO: ask about the tally page not showing up in apropos.
DOC

# ------------------------------------------------------------------ notes -----
cat > "$LAB/notes/editors.txt" <<'NOTE'
Kestrel Station — editing a file where it lives
==============================================

nano — the one to reach for when you do not care which editor you are using.

  nano FILE
  ^O  write out (save)        ^K  cut line
  ^X  exit                    ^U  paste
  ^W  search                  ^\  search and replace
  ^G  help                    ^C  where am I

  ^ is Ctrl. The two-line bar at the bottom is the whole interface.
  M- in the help means Alt.

vim — the one that is on every machine, including the broken ones.

  vim FILE
  Normal mode is where you start. i enters insert mode. Esc leaves it.

  :w   write          :q   quit        :wq  both       :q!  quit, discard
  :e!  reload from disk, discarding changes

  0 ^ $      start of line / first non-blank / end of line
  gg G       top / bottom            NNgg  go to line NN
  w b        word forward / back     dd    delete line
  x  u       delete char / undo      Ctrl-r  redo
  /word n N  search, next, previous
  :%s/a/b/g  replace a with b everywhere
  :set number   :set list   :set paste

  If you are stuck: Esc, then :q! and start again. Esc always goes back to
  normal mode, including from insert mode you did not know you were in.

Which editor runs when a program picks one for you
--------------------------------------------------

  $EDITOR    what programs should use
  $VISUAL    the same, for full-screen editors; usually checked first

Programs that open an editor for you: sudo -e, git commit, and others.
If neither variable is set, the program falls back to something built in,
and what that is depends on the program.

Editing a root-owned file
-------------------------

  sudo -e FILE      (same as sudoedit)

This copies the file to a temporary location, runs YOUR editor as YOU, and
copies it back with the original ownership and mode. Compare against
"sudo vim FILE", which runs the whole editor as root — including its
configuration, its plugins, and its shell escapes.
NOTE

cat > "$LAB/notes/page.txt" <<'NOTE'
2187-07-06 17:30

Note for whoever picks up deck 09. The alarm config has fail below warn on
deck-04, which means the alarm can never fire in the right order. I have not
touched it because I do not know whether it is a typo or someone tuning it
deliberately, and the file has no comment saying which.

That is my own fault as much as anyone's. We do not write down why we change
a config, only what we changed it to, and after a month nobody can tell a
mistake from a decision.
NOTE

chmod 0644 "$LAB"/conf/* "$LAB"/text/* "$LAB"/notes/*
find "$LAB" -type d -exec chmod 0755 {} +
find "$LAB" -exec touch -h -d '2187-07-06 17:30' {} +
