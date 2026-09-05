#!/bin/bash
# Lab setup for 13/02 — dpkg, .deb files, and where a repository is configured
set -euo pipefail

LAB="/labs/13-packages-docs-editors/02-dpkg-and-repos"

# Fixed timestamp so dpkg-deb produces byte-identical archives on every run.
export SOURCE_DATE_EPOCH=1577836800

rm -rf "$LAB"
mkdir -p "$LAB"/{debs,build,sources,notes,scratch}

build_pkg() {
    # build_pkg NAME VERSION DEPENDS DESCRIPTION BODY
    local name=$1 version=$2 depends=$3 desc=$4 body=$5
    local root="$LAB/build/${name}_${version}"
    rm -rf "$root"
    mkdir -p "$root/DEBIAN" "$root/usr/bin" "$root/usr/share/doc/$name" "$root/etc"

    {
        printf 'Package: %s\n' "$name"
        printf 'Version: %s\n' "$version"
        printf 'Section: utils\nPriority: optional\nArchitecture: all\n'
        [ -n "$depends" ] && printf 'Depends: %s\n' "$depends"
        printf 'Maintainer: Kestrel Station Ops <ops@kestrel.invalid>\n'
        printf 'Description: %s\n' "$desc"
        printf ' Station-local package. Built for lesson 13/02.\n'
    } > "$root/DEBIAN/control"

    printf 'threshold=10\n' > "$root/etc/$name.conf"
    printf '/etc/%s.conf\n' "$name" > "$root/DEBIAN/conffiles"

    printf '%s\n' "$body" > "$root/usr/bin/$name"
    chmod 755 "$root/usr/bin/$name"
    printf '%s %s -- station-local package.\n' "$name" "$version" \
        > "$root/usr/share/doc/$name/README"

    dpkg-deb --build --root-owner-group "$root" \
        "$LAB/debs/${name}_${version}_all.deb" >/dev/null
}

# Installs cleanly by hand.
build_pkg hatch-log 1.0.0 '' \
    'record hatch cycles to a log file' \
    '#!/bin/sh
echo "hatch-log 1.0.0"'

# Depends on something that is not in any repository this station knows about,
# so `dpkg -i` will unpack it and refuse to configure it.
build_pkg hatch-report 1.4.2 'hatch-common (>= 2.0)' \
    'summarise hatch cycles' \
    '#!/bin/sh
echo "hatch-report 1.4.2"'

# The dependency, kept out of debs/ on purpose. Students find it in exercise 30.
build_pkg hatch-common 2.1.0 '' \
    'shared data for the hatch tools' \
    '#!/bin/sh
echo "hatch-common 2.1.0"'
mkdir -p "$LAB/scratch/found"
mv "$LAB/debs/hatch-common_2.1.0_all.deb" "$LAB/scratch/found/"

rm -rf "$LAB/build"

# ----------------------------------------------------------------- sources
# Copies of source configuration, to read. None of these are installed.

cat > "$LAB/sources/one-line.list" <<'EOF'
# The old one-line format. Still read, still valid, still everywhere.
#
#   deb [options] URI SUITE [COMPONENT...]
#
deb http://archive.example.net/ubuntu noble main restricted
deb-src http://archive.example.net/ubuntu noble main restricted
EOF

cat > "$LAB/sources/deb822.sources" <<'EOF'
# The newer deb822 format. Same information, one field per line, and it can
# carry a Signed-By path without inventing bracket syntax for it.
Types: deb
URIs: http://archive.example.net/ubuntu
Suites: noble noble-updates
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/example-archive-keyring.gpg
EOF

cat > "$LAB/sources/unsigned.list" <<'EOF'
# A repository with no signature at all. apt refuses this unless told not to
# care, and the way you tell it not to care is the bracket.
deb [trusted=yes] file:/srv/station-repo ./
EOF

cat > "$LAB/sources/ppa-style.list" <<'EOF'
# A third-party archive, of the shape a PPA line takes once it has been added.
# Note that the key it trusts is a separate file, named here, and that adding
# the line without the key gets you an unauthenticated repository.
deb [signed-by=/usr/share/keyrings/deck-tools-archive-keyring.gpg] https://packages.example.org/deck-tools noble main
EOF

# ------------------------------------------------------------------- notes
cat > "$LAB/notes/dpkg.txt" <<'EOF'
dpkg, the layer underneath apt
==============================

apt decides WHAT to install. dpkg installs it. Everything apt knows about your
installed software, it reads out of dpkg's database.

  dpkg -l [PATTERN]    list installed packages, one line each
  dpkg -L PACKAGE      list the files that package put on disk
  dpkg -S PATH         which package owns this file
  dpkg -s PACKAGE      the package's status stanza, in full
  dpkg -i FILE.deb     install a .deb file directly
  dpkg -r PACKAGE      remove
  dpkg -P PACKAGE      purge

And two that read a .deb file without installing anything:

  dpkg -c FILE.deb     list the files inside it
  dpkg -I FILE.deb     show its control information

The first two characters of a `dpkg -l` line are a state:

    ii   installed, and configured
    rc   removed, configuration files remain
    iU   unpacked, NOT configured -- something went wrong
    un   not installed, known only as a name someone mentioned

First character: what you asked for. Second: what is actually true.
EOF

cat > "$LAB/notes/repos.txt" <<'EOF'
Where a repository is configured
================================

  /etc/apt/sources.list          the old single file. Ubuntu now ships a
                                 comment here pointing at the directory.
  /etc/apt/sources.list.d/*.list one-line format, one file per source.
  /etc/apt/sources.list.d/*.sources
                                 deb822 format, one field per line.

apt reads all of them. There is no ordering rule that makes one authoritative;
they are simply a set.

A source is trusted when apt can verify the archive's signature against a key
it holds. Keys live in /usr/share/keyrings and /etc/apt/keyrings, and a source
line names the one it expects with signed-by.

Two ways to end up with an unverified archive:

  no Release file        apt refuses outright.
  [trusted=yes]          apt stops asking. Nothing else changes: the packages
                         are not checked, and dpkg installs whatever arrives.

The second one is not an attack. It is what you write for a local mirror you
built yourself. It is also what you write when you are in a hurry.
EOF

cat > "$LAB/notes/page.txt" <<'EOF'
2187-07-06 11:02  cadet -> self

sources.list.d has more in it than the image ships with. One file, one line,
not from any station build. Noted here so it is written down somewhere before I
touch anything.

Nothing else in this note. I do not know who added it and the file does not say.
EOF

cat > "$LAB/notes/manifest.txt" <<'EOF'
debs/
  hatch-log_1.0.0_all.deb        installs by itself
  hatch-report_1.4.2_all.deb     wants something it will not find

sources/
  four files, for reading. None of them is installed anywhere.
EOF

find "$LAB" -path "$LAB/debs" -prune -o -exec touch -h -d '2187-07-06 11:02' {} +
touch -h -d '2020-01-01 00:00' "$LAB/debs" "$LAB/debs"/*.deb "$LAB/scratch/found"/*.deb
