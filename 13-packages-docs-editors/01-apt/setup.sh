#!/bin/bash
# Lab setup for 13/01 — apt: update, install, remove, purge, search, show, list
set -euo pipefail

LAB="/labs/13-packages-docs-editors/01-apt"

# Fixed timestamp so the built .deb files are byte-for-byte reproducible:
# dpkg-deb clamps every member's mtime to this, and without it the archives
# differ on every run and the lab is not idempotent.
export SOURCE_DATE_EPOCH=1577836800

rm -rf "$LAB"
mkdir -p "$LAB"/{repo,build,notes,scratch}

# ------------------------------------------------------------------ packages
# A tiny local repository, so this lesson works with no network at all.
# Three packages, one of which depends on another, and one of which exists in
# two versions so `apt show` and `apt list` have something to disagree about.

build_pkg() {
    # build_pkg NAME VERSION DEPENDS DESCRIPTION BODY
    local name=$1 version=$2 depends=$3 desc=$4 body=$5
    local root="$LAB/build/${name}_${version}"
    rm -rf "$root"
    mkdir -p "$root/DEBIAN" "$root/usr/bin" "$root/usr/share/doc/$name" "$root/etc"

    # A configuration file, so that remove and purge do visibly different
    # things. dpkg only treats a file as configuration if it is listed here.
    printf 'threshold=10\n# station default, edit freely\n' > "$root/etc/$name.conf"
    printf '/etc/%s.conf\n' "$name" > "$root/DEBIAN/conffiles"

    {
        printf 'Package: %s\n' "$name"
        printf 'Version: %s\n' "$version"
        printf 'Section: utils\nPriority: optional\nArchitecture: all\n'
        [ -n "$depends" ] && printf 'Depends: %s\n' "$depends"
        printf 'Maintainer: Kestrel Station Ops <ops@kestrel.invalid>\n'
        printf 'Description: %s\n' "$desc"
        printf ' Part of the station deck-tools set. Installed from the\n'
        printf ' station-local repository under this lab.\n'
    } > "$root/DEBIAN/control"

    printf '%s\n' "$body" > "$root/usr/bin/$name"
    chmod 755 "$root/usr/bin/$name"

    printf '%s %s -- station-local package, no upstream.\n' "$name" "$version" \
        > "$root/usr/share/doc/$name/README"

    dpkg-deb --build --root-owner-group "$root" \
        "$LAB/repo/${name}_${version}_all.deb" >/dev/null
}

build_pkg deck-report 1.2.0 deck-common \
    'summarise deck status from a manifest' \
    '#!/bin/sh
echo "deck-report 1.2.0"
echo "usage: deck-report MANIFEST"'

build_pkg deck-common 0.9.4 '' \
    'shared data files for the deck-tools set' \
    '#!/bin/sh
echo "deck-common 0.9.4 -- this package exists to be a dependency"'

build_pkg deck-audit 2.0.1 '' \
    'check a deck manifest for missing entries' \
    '#!/bin/sh
echo "deck-audit 2.0.1"'

build_pkg deck-audit 2.1.0 '' \
    'check a deck manifest for missing entries' \
    '#!/bin/sh
echo "deck-audit 2.1.0"'

rm -rf "$LAB/build"

# ------------------------------------------------------------------- index
# A flat repository: one Packages file listing every .deb beside it.
( cd "$LAB/repo"
  : > Packages
  for deb in *.deb; do
      dpkg-deb -f "$deb"
      printf 'Filename: ./%s\n' "$deb"
      printf 'Size: %s\n' "$(stat -c %s "$deb")"
      printf 'SHA256: %s\n' "$(sha256sum "$deb" | cut -d' ' -f1)"
      printf 'MD5sum: %s\n' "$(md5sum "$deb" | cut -d' ' -f1)"
      printf '\n'
  done > Packages )

cat > "$LAB/repo/station.list" <<EOF
# Station-local repository for the deck-tools set.
# Copy this file into /etc/apt/sources.list.d/ to use it.
deb [trusted=yes] file:$LAB/repo ./
EOF

# ------------------------------------------------------------------- notes
cat > "$LAB/notes/apt.txt" <<'EOF'
apt, in the order the words actually mean something
===================================================

  apt update      refresh the list of what is available.
                  Changes nothing you have installed.

  apt upgrade     install newer versions of what you already have.
                  Needs an up-to-date list, which is why it comes second.

  apt install P   install P and everything P needs.
  apt remove P    delete P's files. Leaves its configuration behind.
  apt purge P     delete P's files AND its configuration.

  apt search TXT  search names and descriptions of everything available.
  apt show P      one package, in detail.
  apt list --installed
                  what is on this machine, one line each.

Two of these need root. Four do not. Work out which before you type sudo.

`apt` is for people at a terminal. `apt-get` is the older interface, and it is
the one to use in a script, because its output is stable between releases and
apt's is not. apt says so itself if you pipe it.
EOF

cat > "$LAB/notes/repo.txt" <<EOF
The station-local repository
============================

$LAB/repo holds four .deb files and a Packages index.

A repository is not a service. It is a directory with an index in it, reachable
by some URL. file: is a URL. So is https:.

The line that would make apt read this one is in repo/station.list. It is not
installed anywhere yet. Installing it is exercise 12.

[trusted=yes] disables the signature check. It is here because this repository
is not signed. On a real machine, that bracket is the whole security question,
and chapter 13 lesson 02 is about what it switches off.
EOF

cat > "$LAB/notes/page.txt" <<'EOF'
2187-07-06 09:14  rhea -> cadet

I need deck-report on the maintenance account by tonight. It is in the station
repo. I do not need a discussion about where the station repo came from, I need
the tool.

-- rhea
EOF

# ------------------------------------------------------------------- scratch
cat > "$LAB/scratch/.keep" <<'EOF'
EOF

find "$LAB" -exec touch -h -d '2187-07-06 09:14' {} +
