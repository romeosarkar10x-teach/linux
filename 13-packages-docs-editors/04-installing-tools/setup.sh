#!/bin/bash
# Lesson 13/04 — installing tools: from the archive, and by hand.
# Idempotent: safe to re-run.
set -euo pipefail

LAB="/labs/13-packages-docs-editors/04-installing-tools"
export SOURCE_DATE_EPOCH=1577836800

rm -rf "$LAB"
mkdir -p "$LAB"/{dist,notes,scratch}

# ------------------------------------------------------- a tarball to install --
# Upstream software that ships as a tar archive and not as a package: a script,
# a man page, a README and a config sample, laid out the way a well-behaved
# tarball lays itself out.
build="$LAB/scratch/.build/deck-tools-1.3"
mkdir -p "$build"/{bin,share/man/man1,etc}

cat > "$build/bin/deck-lint" <<'PROG'
#!/usr/bin/env bash
# deck-lint 1.3 — check a deck-cycle.conf for obvious mistakes.
set -euo pipefail

usage() { printf 'usage: deck-lint [--quiet] FILE\n'; }

quiet=0
case ${1-} in
    --help) usage; exit 0 ;;
    --version) printf 'deck-lint 1.3\n'; exit 0 ;;
    --quiet) quiet=1; shift ;;
esac

file=${1-}
if [ -z "$file" ]; then usage >&2; exit 2; fi
if [ ! -r "$file" ]; then printf 'deck-lint: cannot read %s\n' "$file" >&2; exit 2; fi

bad=0
lineno=0
while IFS= read -r line; do
    lineno=$((lineno + 1))
    case $line in
        ''|'#'*) continue ;;
    esac
    if ! printf '%s\n' "$line" | grep -Eq '^deck-[0-9]{2} [0-9]+$'; then
        bad=$((bad + 1))
        [ "$quiet" -eq 1 ] || printf '%s:%d: not "deck-NN SECONDS": %s\n' "$file" "$lineno" "$line"
    fi
done < "$file"

[ "$bad" -eq 0 ] || exit 1
[ "$quiet" -eq 1 ] || printf '%s: ok\n' "$file"
PROG
chmod 0755 "$build/bin/deck-lint"

cat > "$build/share/man/man1/deck-lint.1" <<'PAGE'
.TH DECK-LINT 1 "2187-06-11" "deck-tools 1.3" "Station Commands"
.SH NAME
deck-lint \- check a deck-cycle configuration file for mistakes
.SH SYNOPSIS
.B deck-lint
[\fB\-\-quiet\fR]
.I FILE
.SH DESCRIPTION
Reads
.I FILE
and reports every line that is not blank, not a comment, and not of the form
.IR deck-NN " " SECONDS .
.SH EXIT STATUS
.TP
.B 0
No problems found.
.TP
.B 1
At least one bad line.
.TP
.B 2
Usage error, or the file could not be read.
.SH SEE ALSO
.BR deck-cycle.conf (5)
PAGE

cat > "$build/README" <<'DOC'
deck-tools 1.3
==============

Contents:

  bin/deck-lint                  the program
  share/man/man1/deck-lint.1     its manual page
  etc/deck-lint.conf.sample      a sample configuration

Installing
----------

There is no installer. Copy the tree into a prefix you own:

  cp -r bin share /usr/local/

Everything is relocatable; deck-tools reads no absolute paths of its own.
If you install somewhere other than /usr/local you will need that prefix's
bin/ on PATH and its share/man on MANPATH.

Uninstalling
------------

Delete the files you copied. There is no record of them anywhere else.
DOC

cat > "$build/etc/deck-lint.conf.sample" <<'DOC'
# deck-lint has no configuration yet. This file is a placeholder so that
# packagers know where one would go.
DOC

tar --sort=name --owner=0 --group=0 --numeric-owner \
    --mtime="@$SOURCE_DATE_EPOCH" \
    -C "$LAB/scratch/.build" -czf "$LAB/dist/deck-tools-1.3.tar.gz" deck-tools-1.3
rm -rf "$LAB/scratch/.build"

# ------------------------------------------------------------ a config to lint --
cat > "$LAB/scratch/deck-cycle.conf" <<'DOC'
# settling times, seconds
deck-04 45
deck-07 30
deck-9 60
deck-11 forty
# cargo deck vents slowly since the refit
deck-09 120
DOC

# ------------------------------------------------------------------- notes -----
cat > "$LAB/notes/tools.txt" <<'NOTE'
Kestrel Station — getting a tool you do not have
================================================

Three ways, in the order to try them.

1. It is in the archive.

     apt search WORD          find it
     apt show NAME            read about it before installing
     sudo apt install NAME    install it

   Upgrades and removal are handled for you afterwards. Prefer this.

2. It ships as a .deb but is not in any archive.

     sudo apt install ./thing.deb    (apt, so dependencies are resolved)

   Still tracked by dpkg. See lesson 02.

3. It ships as a tarball, or as source.

     tar -tzf thing.tar.gz | head    look before extracting
     tar -xzf thing.tar.gz           extract
     cp -r bin share /usr/local/     install into a prefix

   Nothing tracks this. dpkg -S will not find it, apt will not upgrade it,
   and removing it means remembering what you copied.

Where things go
---------------

  /usr/bin          the distribution's programs. Not yours.
  /usr/local/bin    programs you installed by hand. Yours.
  ~/.local/bin      programs for one user only. No root needed.
  /opt/NAME         a self-contained third-party tree.

/usr/local exists precisely so that hand-installed software and the package
manager never fight over the same file.

Checking
--------

  command -v NAME     which one will run
  type -a NAME        every one, in PATH order
  echo "$PATH"        the order itself
NOTE

cat > "$LAB/notes/candidates.txt" <<'NOTE'
Tools worth having on a station, and what they replace
======================================================

  htop        top, but readable                            in the archive
  tree        ls -R, but shaped like a tree                in the archive
  jq          reading JSON without regex                   in the archive
  ripgrep     grep -r, faster, respects ignore files       in the archive
  ncdu        du, interactive                              in the archive
  shellcheck  finds the bugs in your shell scripts         already installed
  plocate     find, precomputed                            already installed

Check before you install. Three of these are already here, and one of the
three is not called what you would guess.
NOTE

cat > "$LAB/notes/page.txt" <<'NOTE'
2187-07-06 16:45

Cadet asked why deck-lint is not a package like everything else. It is not.
It came as a tarball from whoever wrote it and was copied into /usr/local by
hand, which is why it never shows up in dpkg -l and never gets upgraded.

Not a complaint. That is what /usr/local is for. But it does mean that if
someone puts something in /usr/local, nothing on this station will tell you
it appeared, when, or who did it. Worth remembering next time we go looking
for where a program came from.
NOTE

chmod 0644 "$LAB"/notes/* "$LAB"/dist/* "$LAB"/scratch/deck-cycle.conf
find "$LAB" -type d -exec chmod 0755 {} +
find "$LAB" -exec touch -h -d '2187-07-06 16:45' {} +
