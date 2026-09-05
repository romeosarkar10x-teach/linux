#!/bin/bash
# Lesson 13/03 — man pages, sections, and searching the documentation.
# Idempotent: safe to re-run.
set -euo pipefail

LAB="/labs/13-packages-docs-editors/03-man-pages"

rm -rf "$LAB"
mkdir -p "$LAB"/{man/man1,man/man5,man/man8,notes,scratch}

# ---------------------------------------------------------------- man pages --
# Three station-written pages, so the student has a manpath of their own to
# point man at. One of them is deliberately missing a usable NAME line, which
# is what makes it invisible to apropos/whatis but perfectly readable with man.

cat > "$LAB/man/man1/deck-cycle.1" <<'PAGE'
.TH DECK-CYCLE 1 "2187-05-02" "Kestrel Station" "Station Commands"
.SH NAME
deck-cycle \- open and close a deck hatch on a timer
.SH SYNOPSIS
.B deck-cycle
[\fB\-n\fR \fIcount\fR]
[\fB\-\-dry\-run\fR]
.IR deck ...
.SH DESCRIPTION
.B deck-cycle
cycles one or more deck hatches. Each cycle opens the hatch, waits for the
pressure reading to settle, and closes it again. A deck that fails to settle
is skipped and reported.
.PP
Cycling a deck that is currently crewed is refused. Use
.B \-\-dry\-run
to see what would happen without moving anything.
.SH OPTIONS
.TP
.BR \-n " " \fIcount\fR
Repeat each cycle \fIcount\fR times. Default 1.
.TP
.B \-\-dry\-run
Print the plan and exit without cycling.
.SH EXIT STATUS
.TP
.B 0
All requested decks cycled.
.TP
.B 1
At least one deck was skipped.
.TP
.B 2
Bad usage.
.SH FILES
.TP
.I /etc/deck-cycle.conf
Per-deck settling times. See
.BR deck-cycle.conf (5).
.SH SEE ALSO
.BR deck-cycle.conf (5),
.BR deck-audit (8)
PAGE

cat > "$LAB/man/man5/deck-cycle.conf.5" <<'PAGE'
.TH DECK-CYCLE.CONF 5 "2187-05-02" "Kestrel Station" "File Formats"
.SH NAME
deck-cycle.conf \- settling times for deck hatches
.SH DESCRIPTION
Each line names a deck and the number of seconds
.BR deck-cycle (1)
waits for its pressure reading to settle. Blank lines and lines beginning with
.B #
are ignored. Unknown decks are an error; a deck absent from the file uses the
default of 30 seconds.
.SH SYNTAX
.PP
.in +4n
.EX
deck\-04 45
deck\-07 30
.EE
.in
.SH EXAMPLES
.PP
Give the cargo deck longer to settle:
.PP
.in +4n
.EX
# cargo deck vents slowly since the refit
deck\-09 120
.EE
.in
.SH SEE ALSO
.BR deck-cycle (1)
PAGE

# No NAME section: readable, but nothing for the whatis index to extract.
cat > "$LAB/man/man8/hatch-tally.8" <<'PAGE'
.TH HATCH-TALLY 8 "2187-05-02" "Kestrel Station" "Station Administration"
.SH DESCRIPTION
.B hatch-tally
counts hatch cycles per deck since the last reset and writes the totals to
standard output. It is run by the deck officer at end of shift.
.SH OPTIONS
.TP
.B \-\-reset
Zero the counters after printing.
.SH SEE ALSO
.BR deck-cycle (1)
PAGE

gzip -n -9 -c "$LAB/man/man1/deck-cycle.1" > "$LAB/man/man1/deck-cycle-archived.1.gz"

# ------------------------------------------------------------------- notes ---
cat > "$LAB/notes/man.txt" <<'NOTE'
Kestrel Station — reading the manual
====================================

Sections. The number in parentheses after a name is the section it lives in.
The same word can appear in several.

  1  commands you can run
  2  system calls (kernel)
  3  library functions (C)
  4  device and special files (/dev)
  5  file formats and configuration files
  6  games
  7  conventions, overviews, miscellany
  8  commands for the system administrator

  man passwd      first match, searched in section order
  man 5 passwd    the file format, not the command
  man -a printf   every match, one after another

Searching.

  whatis NAME     the one-line description, exact name only
  apropos WORD    every one-line description containing WORD
  man -k WORD     the same thing as apropos
  man -K WORD     search the full text of every page (slow)

Where pages come from.

  manpath         the directories man searches, in order
  man -w NAME     the file it would open
  MANPATH=DIR man NAME     search DIR instead

Both whatis and apropos read a prebuilt index, not the pages themselves.
A page man can display is not necessarily a page apropos can find.

Reading a page.

  /word    search forward        n    next match
  ?word    search backward       N    previous match
  g / G    top / bottom          q    quit

The pager is less(1). Everything less does, man does.
NOTE

cat > "$LAB/notes/page.txt" <<'NOTE'
2187-07-06 14:20

Wrote up deck-cycle properly at last. Three pages: the command, the config
file format, and the tally tool. Put them under the lab manpath rather than
/usr/share/man so nothing on the station picks them up by accident.

The tally page is not finished. It displays fine but apropos will not find it
and I have not worked out why yet.

Separately: deck-audit's own page says it reads /etc/deck-report.conf. The
package that installs deck-audit does not ship that file. Either the page is
out of date or the file is meant to come from somewhere else. Noting it here
rather than guessing.
NOTE

cat > "$LAB/notes/mandb.txt" <<'NOTE'
Building an index for a manpath of your own
===========================================

apropos and whatis do not read man pages. They read an index, and the index
has to be built:

  mandb -c -u /path/to/manpath

  -c   build from scratch rather than updating
  -u   check for pages added or removed

The index lands in that manpath's own directory, so a manpath you can write
to is a manpath you can index. Building it prints a count of the pages it
found — compare that count against the pages you know are there.
NOTE

chmod 0644 "$LAB"/man/man*/* "$LAB"/notes/*
find "$LAB" -type d -exec chmod 0755 {} +
find "$LAB" -exec touch -h -d '2187-07-06 14:20' {} +
