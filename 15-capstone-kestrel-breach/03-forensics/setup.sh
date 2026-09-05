#!/bin/bash
# Seeds the forensics lab: fourteen artefacts across three trees, with mtimes
# that separate two sets of hands. Nothing here is greppable for a conclusion;
# the split is only visible by sorting timestamps and comparing ownership.
# Idempotent: the lab tree is removed and rebuilt from scratch every run.
set -euo pipefail

LAB="/labs/15-capstone-kestrel-breach/03-forensics"
rm -rf "$LAB"
mkdir -p "$LAB"/{engineering,station,home,case/artefacts,case/notes,bin}
mkdir -p "$LAB"/engineering/{audit,manifests,repo.d}
mkdir -p "$LAB"/station/{summariser,mounts,var}
mkdir -p "$LAB"/home/{rhea,dorn,cass,ops-bot}

# ---------------------------------------------------------------- engineering

cat > "$LAB/engineering/audit/README.txt" <<'EOF'
Strain audit working directory.

Created for the deck 3 recertification. Anything in here is a copy; the
originals live on the engineering archive mount. Copies are made with cp -a so
the archive timestamps come across intact.
EOF

cat > "$LAB/engineering/audit/checksums-2186.txt" <<'EOF'
# strain raw, calendar year 2186, as recorded at copy time
2f7c1d3a4b5e6f708192a3b4c5d6e7f8091a2b3c4d5e6f708192a3b4c5d6e7f8  2186-q1.dat
3a8d2e4b5c6f708192a3b4c5d6e7f8091a2b3c4d5e6f708192a3b4c5d6e7f809  2186-q2.dat
4b9e3f5c6d708192a3b4c5d6e7f8091a2b3c4d5e6f708192a3b4c5d6e7f8091a  2186-q3.dat
5caf4a6d7e819203b4c5d6e7f8091a2b3c4d5e6f708192a3b4c5d6e7f8091a2b  2186-q4.dat
EOF

cat > "$LAB/engineering/audit/checksums-2186.recheck.txt" <<'EOF'
# same four files, rechecked
2f7c1d3a4b5e6f708192a3b4c5d6e7f8091a2b3c4d5e6f708192a3b4c5d6e7f8  2186-q1.dat
3a8d2e4b5c6f708192a3b4c5d6e7f8091a2b3c4d5e6f708192a3b4c5d6e7f809  2186-q2.dat
7e1c8b2a3d4f5061728394a5b6c7d8e9f0a1b2c3d4e5f60718293a4b5c6d7e8f  2186-q3.dat
5cef4a6d7e819203b4c5d6e7f8091a2b3c4d5e6f708192a3b4c5d6e7f8091a2b  2186-q4.dat
EOF

cat > "$LAB/engineering/manifests/MANIFEST-2186.txt" <<'EOF'
# copied 2187-05-17
# source /mnt/eng-archive/strain/raw/2186
118400  2186-q1.dat
118400  2186-q2.dat
118400  2186-q3.dat
118400  2186-q4.dat
118400  2186-q1.sum
118400  2186-q2.sum
EOF

cat > "$LAB/engineering/repo.d/third-party.list" <<'EOF'
# added for the recert toolchain
deb [trusted=yes] http://eng-mirror.kestrel.local/apt stable main
EOF

cat > "$LAB/engineering/repo.d/station.list" <<'EOF'
deb http://apt.kestrel.local/station stable main
EOF

# ------------------------------------------------------------------- station

cat > "$LAB/station/summariser/strain-summary" <<'EOF'
#!/bin/bash
# strain summariser
TOLERANCE="${STRAIN_TOLERANCE:-6.0}"
while read -r cycle raw; do
    reported="$raw"
    if [ "${raw%%.*}" -gt 6 ]; then
        reported="$TOLERANCE"
    fi
    printf 'cycle=%s raw=%s reported=%s\n' "$cycle" "$raw" "$reported"
done
EOF
chmod 755 "$LAB/station/summariser/strain-summary"

cat > "$LAB/station/summariser/strain-summary.orig" <<'EOF'
#!/bin/bash
# strain summariser
while read -r cycle raw; do
    printf 'cycle=%s raw=%s reported=%s\n' "$cycle" "$raw" "$raw"
done
EOF
chmod 644 "$LAB/station/summariser/strain-summary.orig"

cat > "$LAB/station/summariser/run.log" <<'EOF'
seq=0438 2187-05-22 02:00:03 strain-summary start
seq=0438 2187-05-22 02:00:31 strain-summary ok
seq=0439 2187-05-23 02:00:02 strain-summary start
seq=0439 2187-05-23 02:00:29 strain-summary ok
seq=0440 2187-05-24 02:00:04 strain-summary start
seq=0440 2187-05-24 02:00:30 strain-summary ok
EOF

cat > "$LAB/station/var/deck3-report.txt" <<'EOF'
deck 3 strain, weekly rollup
week ending 2187-05-24

peak reported   6.0
mean reported   4.7
cycles          2016
exceedances     0
EOF

ln -s /mnt/eng-archive/strain/raw "$LAB/station/mounts/raw-strain"

# ---------------------------------------------------------------------- home

cat > "$LAB/home/dorn/notes-recert.txt" <<'EOF'
recert prep, deck 3

- pull raw 2186 + 2187, check against the summary the panel gets
- q3 does not match. rechecked twice.
- asked for read on the archive summary dir. denied.
- summariser reports a ceiling, not a peak. need to say this out loud.
EOF

cat > "$LAB/home/rhea/toolchain.txt" <<'EOF'
recert toolchain

added the eng mirror to repo.d so the panel machines can pull the analysis
package without waiting on the station apt sync. trusted=yes because the
mirror has no key yet - raised as a ticket, not resolved.
EOF

cat > "$LAB/home/cass/rota.txt" <<'EOF'
deck 3 berth rota, week ending 2187-05-24
61 of 94 crew. no changes requested.
EOF

: > "$LAB/home/ops-bot/.bashrc"
cat > "$LAB/home/ops-bot/.bashrc" <<'EOF'
# ops-bot environment
export PATH=/opt/eng/bin:$PATH
export STRAIN_TOLERANCE=6.0
EOF

# ---------------------------------------------------------------------- case

cat > "$LAB/case/TEMPLATE.md" <<'EOF'
artefact:
bytes:
mtime:
sha256:
says:
means:
EOF

cat > "$LAB/case/notes/00-open.md" <<'EOF'
Open questions carried in from lesson 02:

- eng-svc appears in eng-access.log on 2187-01-18 and is not in /etc/passwd
- bin/strain-summary carried an mtime of 2186-10-06 02:14
EOF

# ------------------------------------------------------------------- the tool

cat > "$LAB/bin/timeline" <<'EOF'
#!/bin/bash
# timeline - print every regular file under a tree, oldest mtime first.
# Reports what it can stat. Anything it cannot stat is listed on stderr and
# does not appear in the timeline at all.
set -euo pipefail

root="${1:-.}"
[ -d "$root" ] || { echo "timeline: $root: not a directory" >&2; exit 2; }

find "$root" -type f -printf '%T@\t%TY-%Tm-%Td %TH:%TM:%TS\t%u\t%p\n' 2>/dev/null |
    sort -n |
    cut -f2-

find "$root" -type l -print 2>/dev/null | while read -r l; do
    [ -e "$l" ] || echo "timeline: $l: unreadable, not in timeline" >&2
done
EOF
chmod 755 "$LAB/bin/timeline"

# --------------------------------------------------------------------- mtimes

chmod -R u+rwX,go+rX "$LAB"

# Ownership is evidence. The engineering tree and the repo list belong to the
# account that did the recert toolchain work; the summariser belongs to the
# account that runs it; the recheck and the notes belong to a third account.
chown -Rh rhea:engineering "$LAB/engineering"
chown -h dorn:crew "$LAB/engineering/audit/checksums-2186.recheck.txt"
chown -Rh ops-bot:ops "$LAB/station"
chown -h rhea:crew "$LAB/home/rhea/toolchain.txt"
chown -h dorn:crew "$LAB/home/dorn/notes-recert.txt"
chown -h cass:crew "$LAB/home/cass/rota.txt"
chown -h ops-bot:ops "$LAB/home/ops-bot/.bashrc"
chown -Rh cadet:crew "$LAB/case" "$LAB/bin"

touch -h -d '2187-05-15 22:40:00' "$LAB/engineering/audit/README.txt"
touch -h -d '2187-05-15 23:05:00' "$LAB/engineering/audit/checksums-2186.txt"
touch -h -d '2187-05-20 01:12:00' "$LAB/engineering/audit/checksums-2186.recheck.txt"
touch -h -d '2187-05-17 23:51:00' "$LAB/engineering/manifests/MANIFEST-2186.txt"
touch -h -d '2187-05-16 03:18:00' "$LAB/engineering/repo.d/third-party.list"
touch -h -d '2186-04-11 09:00:00' "$LAB/engineering/repo.d/station.list"

touch -h -d '2186-10-06 02:14:00' "$LAB/station/summariser/strain-summary"
touch -h -d '2186-09-28 14:22:00' "$LAB/station/summariser/strain-summary.orig"
touch -h -d '2187-05-24 02:00:30' "$LAB/station/summariser/run.log"
touch -h -d '2187-05-24 06:15:00' "$LAB/station/var/deck3-report.txt"
touch -h -d '2187-05-22 21:40:00' "$LAB/station/mounts/raw-strain"

touch -h -d '2187-05-20 01:31:00' "$LAB/home/dorn/notes-recert.txt"
touch -h -d '2187-05-16 03:22:00' "$LAB/home/rhea/toolchain.txt"
touch -h -d '2187-05-19 11:47:00' "$LAB/home/cass/rota.txt"
touch -h -d '2187-05-19 23:58:00' "$LAB/home/ops-bot/.bashrc"

touch -h -d '2187-06-14 07:30:00' "$LAB/case/TEMPLATE.md"
touch -h -d '2187-06-14 07:30:00' "$LAB/case/notes/00-open.md"
touch -h -d '2187-06-14 07:30:00' "$LAB/bin/timeline"

for d in "$LAB/engineering/audit" "$LAB/engineering/manifests" \
         "$LAB/engineering/repo.d" "$LAB/station/summariser" \
         "$LAB/station/mounts" "$LAB/station/var" \
         "$LAB/home/rhea" "$LAB/home/dorn" "$LAB/home/cass" \
         "$LAB/home/ops-bot" "$LAB/case" "$LAB/case/artefacts" \
         "$LAB/case/notes" "$LAB/bin" "$LAB/engineering" \
         "$LAB/station" "$LAB/home" "$LAB"; do
    touch -h -d '2187-06-14 07:30:00' "$d"
done
