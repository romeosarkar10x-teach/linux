#!/bin/bash
# Lesson 13/06 — Incident 12: the package nobody added.
# Idempotent: safe to re-run.
set -euo pipefail

LAB="/labs/13-packages-docs-editors/06-incident-12"
export SOURCE_DATE_EPOCH=1577836800

# Leave the station's apt configuration as we found it on a re-run.
rm -f /etc/apt/sources.list.d/bay-tools.list
rm -rf "$LAB"
mkdir -p "$LAB"/{repo-station,repo-unknown,notes,scratch,build}

# ---------------------------------------------------------------------------
# The flag is produced by deck-verify --attest, and only when the station has
# actually been put right. It is stored base64 so that the .deb, the repo and
# the installed binary are not greppable for KESTREL.
# ---------------------------------------------------------------------------
# shellcheck disable=SC2034  # documentation: the value embedded in deck-verify
FLAG_B64="S0VTVFJFTHthX3NvdXJjZV9ub19vbmVfc2lnbmVkX2FuZF9ub19vbmVfYWRkZWR9"

pkg_root() {  # pkg_root NAME VERSION
    printf '%s/build/%s-%s' "$LAB" "$1" "$2"
}

finish_pkg() {  # finish_pkg NAME VERSION OUTDIR
    local name=$1 version=$2 outdir=$3 root
    root=$(pkg_root "$name" "$version")
    chmod -R go-w "$root"
    dpkg-deb --root-owner-group --build "$root" \
        "$outdir/${name}_${version}_all.deb" >/dev/null
}

write_index() {  # write_index DIR
    local dir=$1 deb
    : > "$dir/Packages"
    for deb in "$dir"/*.deb; do
        [ -e "$deb" ] || continue
        dpkg-deb -f "$deb" >> "$dir/Packages"
        printf 'Filename: %s\n' "$(basename "$deb")" >> "$dir/Packages"
        printf 'Size: %s\n' "$(stat -c %s "$deb")" >> "$dir/Packages"
        printf 'SHA256: %s\n' "$(sha256sum "$deb" | cut -d' ' -f1)" >> "$dir/Packages"
        printf '\n' >> "$dir/Packages"
    done
}

# ------------------------------------------------- the station's own package --
root=$(pkg_root deck-verify 1.0.0)
mkdir -p "$root"/{DEBIAN,usr/bin,usr/share/doc/deck-verify}
cat > "$root/DEBIAN/control" <<CTL
Package: deck-verify
Version: 1.0.0
Section: admin
Priority: optional
Architecture: all
Depends: libhatch-telemetry0
Maintainer: Kestrel Station Engineering <engineering@kestrel.example>
X-Station-Token: STAGE{one-tool-two-sources}
Description: verify deck configuration against the hatch telemetry log
 Reads the deck configuration and the telemetry log and reports decks whose
 recorded settling time does not match the configured one.
 .
 Built and signed off by station engineering. This is the station's own
 build; anything offering deck-verify from elsewhere is not.
CTL

cat > "$root/usr/bin/deck-verify" <<'PROG'
#!/usr/bin/env bash
# deck-verify 1.0.0 — station build.
set -uo pipefail

VERSION=1.0.0
LAB=/labs/13-packages-docs-editors/06-incident-12
B64_PAYLOAD='S0VTVFJFTHthX3NvdXJjZV9ub19vbmVfc2lnbmVkX2FuZF9ub19vbmVfYWRkZWR9'

die() { printf 'deck-verify: %s\n' "$1" >&2; exit "${2:-1}"; }

usage() {
    cat <<'USAGE'
usage: deck-verify [--version] [--self-test] [--attest FILE]

  --self-test    check that this station's package sources are in a state
                 deck-verify is willing to run under
  --attest FILE  submit findings; FILE has three lines, in order:
                   1. the file that configured the source you did not expect
                   2. the version of deck-verify that should be installed
                   3. the package you were asked about that turned out to be
                      an ordinary dependency
USAGE
}

untrusted_sources() {
    grep -rl 'trusted=yes' /etc/apt/sources.list.d/ 2>/dev/null | grep -v '/station[.-]' || true
}

self_test() {
    local bad
    bad=$(untrusted_sources)
    if [ -n "$bad" ]; then
        printf 'deck-verify: REFUSING TO RUN\n' >&2
        printf 'deck-verify: an unverified package source is still configured:\n' >&2
        printf '  %s\n' $bad >&2
        printf 'deck-verify: remove it and run --self-test again.\n' >&2
        exit 3
    fi
    if [ "$(dpkg-query -W -f='${Version}' deck-verify 2>/dev/null)" != "$VERSION" ]; then
        die "the installed deck-verify is not the station build ($VERSION)" 4
    fi
    printf 'deck-verify: sources clean, station build %s installed\n' "$VERSION"
    printf 'deck-verify: STAGE{the-source-comes-off-first}\n'
}

attest() {
    local file=$1 a b c
    [ -r "$file" ] || die "cannot read $file" 2
    a=$(sed -n 1p "$file" | tr -d ' \t\r' | tr 'A-Z' 'a-z')
    b=$(sed -n 2p "$file" | tr -d ' \t\r')
    c=$(sed -n 3p "$file" | tr -d ' \t\r' | tr 'A-Z' 'a-z')
    a=${a##*/}

    local ok=1
    [ "$a" = "bay-tools.list" ] || { printf 'deck-verify: line 1 does not name the file that configured it\n' >&2; ok=0; }
    [ "$b" = "1.0.0" ] || { printf 'deck-verify: line 2 is not the version this station should be running\n' >&2; ok=0; }
    [ "$c" = "libhatch-telemetry0" ] || { printf 'deck-verify: line 3 is not the package that turned out to be ordinary\n' >&2; ok=0; }
    [ "$ok" -eq 1 ] || exit 5

    if [ -n "$(untrusted_sources)" ]; then
        die 'findings accepted, but the source is still configured. Fix it first.' 3
    fi
    printf 'deck-verify: findings accepted.\n'
    printf '%s\n' "$B64_PAYLOAD" | base64 -d
    printf '\n'
}

case ${1-} in
    --version)   printf 'deck-verify %s (station build)\n' "$VERSION" ;;
    --self-test) self_test ;;
    --attest)    attest "${2:?usage: deck-verify --attest FILE}" ;;
    --help|'')   usage ;;
    *)           usage >&2; exit 2 ;;
esac
PROG
chmod 0755 "$root/usr/bin/deck-verify"
cat > "$root/usr/share/doc/deck-verify/README" <<'DOC'
deck-verify, station build.

Depends on libhatch-telemetry0, which is the telemetry log reader every
station tool that touches the hatch log links against. It is not exciting.
DOC

# ------------------------------------------------- the ordinary dependency ----
root=$(pkg_root libhatch-telemetry0 2.4.1)
mkdir -p "$root"/{DEBIAN,usr/lib/kestrel,usr/share/doc/libhatch-telemetry0}
cat > "$root/DEBIAN/control" <<'CTL'
Package: libhatch-telemetry0
Version: 2.4.1
Section: libs
Priority: optional
Architecture: all
Maintainer: Kestrel Station Engineering <engineering@kestrel.example>
Description: hatch telemetry log reader
 Shared reader for the hatch telemetry log format. Used by deck-verify,
 deck-audit and the tally tools. Installed as a dependency; there is no
 reason to install it directly.
CTL
printf '# hatch telemetry reader, shared\n' > "$root/usr/lib/kestrel/hatch-telemetry.sh"
printf 'Shared library package. Nothing to configure.\n' \
    > "$root/usr/share/doc/libhatch-telemetry0/README"

finish_pkg deck-verify 1.0.0 "$LAB/repo-station"
finish_pkg libhatch-telemetry0 2.4.1 "$LAB/repo-station"

# ------------------------------------------------------ the other deck-verify --
root=$(pkg_root deck-verify 1.4.0)
mkdir -p "$root"/{DEBIAN,usr/bin,usr/share/doc/deck-verify}
cat > "$root/DEBIAN/control" <<CTL
Package: deck-verify
Version: 1.4.0
Section: admin
Priority: optional
Architecture: all
Maintainer: unknown <unknown@localhost>
X-Station-Token: STAGE{higher-version-wins}
Description: verify deck configuration against the hatch telemetry log
 Reads the deck configuration and the telemetry log and reports decks whose
 recorded settling time does not match the configured one.
CTL
cat > "$root/usr/bin/deck-verify" <<'PROG'
#!/usr/bin/env bash
# deck-verify 1.4.0
set -uo pipefail
case ${1-} in
    --version) printf 'deck-verify 1.4.0\n' ;;
    *) printf 'deck-verify 1.4.0: nothing to do\n' ;;
esac
PROG
chmod 0755 "$root/usr/bin/deck-verify"
printf 'No documentation was shipped with this build.\n' \
    > "$root/usr/share/doc/deck-verify/README"
finish_pkg deck-verify 1.4.0 "$LAB/repo-unknown"

rm -rf "$LAB/build"

write_index "$LAB/repo-station"
write_index "$LAB/repo-unknown"

# ------------------------------------------------------------ the source file --
# Planted: unsigned, added to the station's apt configuration by nobody who
# will admit to it. No name appears anywhere.
cat > /etc/apt/sources.list.d/bay-tools.list <<SRC
deb [trusted=yes] file:$LAB/repo-unknown ./
SRC
chmod 0644 /etc/apt/sources.list.d/bay-tools.list
touch -d '2187-06-28 03:41' /etc/apt/sources.list.d/bay-tools.list

# The station's own source, which is signed off and expected to be here.
cat > "$LAB/notes/station-source.txt" <<SRC
The station's own package source, for reference. It is already configured:

  deb [trusted=yes] file:$LAB/repo-station ./

installed as /etc/apt/sources.list.d/station-13.list by station engineering
when this lab was set up.
SRC
cat > /etc/apt/sources.list.d/station-13.list <<SRC
deb [trusted=yes] file:$LAB/repo-station ./
SRC
chmod 0644 /etc/apt/sources.list.d/station-13.list

# ------------------------------------------------------------------- notes ----
cat > "$LAB/notes/incident.txt" <<'NOTE'
INCIDENT 12 — 2187-07-06 18:20
==============================

Deck 09 will not be signed off tonight without a deck-verify run, and
deck-verify is not installed. apt can see it. Install it and run it.

Two things before you do.

First: I ran `apt-cache policy deck-verify` on my shift and it offered me a
version I have never heard of, from somewhere I did not put. I stopped there.
Do not install anything until you can say where it is coming from.

Second: while looking, I found a package called libhatch-telemetry0 already
installed on this station. I do not know what it is. It may be nothing. Find
out what it is before you decide it is something.

What I want back, in writing:

  1. the file that configured the source we did not expect
  2. the version of deck-verify this station should be running
  3. what libhatch-telemetry0 actually is

Then get deck-verify running and produce its attestation. It will not produce
one until the station is actually in a state it will run under.

  deck-verify --self-test
  deck-verify --attest FILE      (three lines, in the order above)

Nothing in this incident requires you to name a person. If your write-up names
one, you have gone further than the evidence.
NOTE

cat > "$LAB/notes/rhea.txt" <<'NOTE'
2187-07-06 18:35
From: Rhea Calloway, Deck Officer

Deck 09 is held until deck-verify runs. I am told there is a question about
which version. There is one deck-verify, it is in apt, install it.

I do not have an opinion about where packages come from. I have an opinion
about deck 09 being open by 22:00.
NOTE

cat > "$LAB/notes/checklist.txt" <<'NOTE'
Working an unexplained package source
=====================================

Before installing anything:

  apt-cache policy PACKAGE       what versions exist, and from where
  apt list -a PACKAGE            the same, shorter
  grep -r . /etc/apt/sources.list.d/   what is configured, and in which file
  ls -l /etc/apt/sources.list.d/       when each file appeared

Reading a package without installing it (lesson 02):

  dpkg -I FILE.deb               control fields, including custom ones
  dpkg -c FILE.deb               what it would put on disk

Deciding which version you get:

  apt install PACKAGE=VERSION    ask for one explicitly
  apt-cache policy               the candidate is what you get by default,
                                 and the highest version usually wins

Establishing that an installed package is ordinary:

  dpkg -s PACKAGE                its status and description
  apt-cache rdepends PACKAGE     what depends on it
  dpkg -L PACKAGE                what it put on disk
  dpkg -V PACKAGE                whether what it put there is still there
NOTE

# libhatch-telemetry0 is already on the station when the incident opens: it
# arrived as a dependency of an earlier tool and nobody remembers it.
if [ "$(dpkg-query -W -f='${Version}' libhatch-telemetry0 2>/dev/null)" != "2.4.1" ]; then
    dpkg -i "$LAB/repo-station/libhatch-telemetry0_2.4.1_all.deb" >/dev/null
fi
# deck-verify must not be installed when the incident opens.
if dpkg-query -W deck-verify >/dev/null 2>&1; then
    dpkg -P deck-verify >/dev/null 2>&1 || true
fi
apt-get update -qq >/dev/null 2>&1 || true

chmod 0644 "$LAB"/notes/* "$LAB"/repo-*/Packages "$LAB"/repo-*/*.deb
find "$LAB" -type d -exec chmod 0755 {} +
find "$LAB" -exec touch -h -d '2187-07-06 18:20' {} +
touch -h -d '2187-06-28 03:41' "$LAB/repo-unknown" "$LAB/repo-unknown"/*
