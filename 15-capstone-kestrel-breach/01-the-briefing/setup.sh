#!/bin/bash
# Lesson 15/01 — the briefing.
#
# Seeds:
#   brief/                 rules of engagement, recert notice, dorn's handover
#   station/               three sample artefacts to practise sourcing on:
#                            run-log with a sequence gap        (ex 20-27)
#                            dangling symlink                   (ex 28-33)
#                            manifest with no tree              (ex 34-39)
#   case/                  the student's case file skeleton     (ex 12-19, 40-52)
#   bin/roe-check          claim-format linter                  (ex 14-19, 47-52)
#
# Idempotent: every path is rebuilt from scratch each run and every mtime is
# set explicitly, so two runs produce identical metadata and identical bytes.

set -eu

LAB="/labs/15-capstone-kestrel-breach/01-the-briefing"

rm -rf "$LAB"
mkdir -p "$LAB"/{brief,station,case/artefacts,case/notes,bin}
cd "$LAB"

# ---------------------------------------------------------------- brief ----

cat > brief/rules-of-engagement.txt <<'EOF'
KESTREL STATION -- INTERNAL REVIEW
Rules of engagement for a single-investigator review
Issued to: cadet (sysadmin, sole)
Scope:     station systems and station-held data

1.  A claim is a sentence you can put a file path next to. If you cannot name
    the artefact, you do not have a claim; you have an impression.

2.  An artefact is sourced when the reader can get back to it without you.
    That means: absolute path, size, mtime, and a hash of the bytes you read.

3.  Record the hash before you touch anything. A hash taken after your first
    edit proves what you made, not what you found.

4.  Separate what the artefact says from what you think it means. Two lines,
    always, in that order. The first is evidence. The second is yours.

5.  Timestamps are evidence. Do not preserve them by being careful; preserve
    them by not writing to the original at all. Work on copies.

6.  Do not name a person unless the artefact does. "The account dorn owns this
    file" is a fact. "dorn did this" is a conclusion and needs its own line.

7.  A conclusion you cannot source is struck from the report, however correct
    it happens to be. This is not a formality. An unsourced finding cannot be
    checked by the next person, and a review nobody can check is worth nothing.

8.  You may be wrong in the report. You may not be vague in it.
EOF

cat > brief/deck-3-recert-notice.txt <<'EOF'
NOTICE -- STRUCTURAL RECERTIFICATION
Deck 3, Kestrel Station
Scheduled: 2187-09

Deck 3 last certified 2181-09. Recertification requires eleven years of
continuous strain telemetry submitted groundside, with the engineering
summaries generated from it.

Groundside reads the summaries. The raw series is submitted alongside and is
not normally examined.

Any deck failing recertification is closed to habitation until remediated.
Deck 3 currently berths 61 of the station's 94 crew.
EOF

mkdir -p brief/handover
printf 'later\n' > brief/handover/notes.txt
cat > brief/handover/README.txt <<'EOF'
Handover directory. Left by the previous sysadmin at end of contract.

Contract closed 2187-05-24, "personal leave, indefinite". Home directory was
not cleared. Nobody has had the authority or the interest to clear it since.
EOF

# --------------------------------------------------------- station sample ---

mkdir -p station/summariser
cat > station/summariser/run.log <<'EOF'
seq=0412 2187-05-12 02:00:03 strain-summary start deck=03 window=24h
seq=0413 2187-05-12 02:00:31 strain-summary ok records=1440 out=/var/eng/summary/2187-05-12.csv
seq=0414 2187-05-13 02:00:03 strain-summary start deck=03 window=24h
seq=0415 2187-05-13 02:00:29 strain-summary ok records=1440 out=/var/eng/summary/2187-05-13.csv
seq=0416 2187-05-14 02:00:03 strain-summary start deck=03 window=24h
seq=0417 2187-05-14 02:00:33 strain-summary ok records=1440 out=/var/eng/summary/2187-05-14.csv
seq=0418 2187-05-15 02:00:02 strain-summary start deck=03 window=24h
seq=0419 2187-05-15 02:00:28 strain-summary ok records=1440 out=/var/eng/summary/2187-05-15.csv
seq=0420 2187-05-16 02:00:04 strain-summary start deck=03 window=24h
seq=0421 2187-05-16 02:00:34 strain-summary ok records=1440 out=/var/eng/summary/2187-05-16.csv
seq=0422 2187-05-17 02:00:03 strain-summary start deck=03 window=24h
seq=0423 2187-05-17 02:00:30 strain-summary ok records=1440 out=/var/eng/summary/2187-05-17.csv
seq=0424 2187-05-18 02:00:03 strain-summary start deck=03 window=24h
seq=0425 2187-05-18 02:00:29 strain-summary ok records=1440 out=/var/eng/summary/2187-05-18.csv
seq=0426 2187-05-19 02:00:02 strain-summary start deck=03 window=24h
seq=0427 2187-05-19 02:00:33 strain-summary ok records=1440 out=/var/eng/summary/2187-05-19.csv
seq=0428 2187-05-20 02:00:03 strain-summary start deck=03 window=24h
seq=0429 2187-05-20 02:00:27 strain-summary ok records=1440 out=/var/eng/summary/2187-05-20.csv
seq=0430 2187-05-21 02:00:04 strain-summary start deck=03 window=24h
seq=0431 2187-05-21 02:00:31 strain-summary ok records=1440 out=/var/eng/summary/2187-05-21.csv
seq=0438 2187-05-22 02:00:03 strain-summary start deck=03 window=24h
seq=0439 2187-05-22 02:00:30 strain-summary ok records=1440 out=/var/eng/summary/2187-05-22.csv
seq=0440 2187-05-23 02:00:03 strain-summary start deck=03 window=24h
seq=0441 2187-05-23 02:00:30 strain-summary ok records=1440 out=/var/eng/summary/2187-05-23.csv
seq=0442 2187-05-24 02:00:04 strain-summary start deck=03 window=24h
seq=0443 2187-05-24 02:00:28 strain-summary ok records=1440 out=/var/eng/summary/2187-05-24.csv
EOF

mkdir -p station/mounts
ln -s /mnt/eng-archive/strain/raw station/mounts/raw-strain

mkdir -p station/audit
cat > station/audit/MANIFEST.txt <<'EOF'
# copied 2187-05-17
# source: /mnt/eng-archive/strain/raw/2186
path                          bytes
2186/10/raw-2186-10-01.dat    118400
2186/10/raw-2186-10-05.dat    118400
2186/10/raw-2186-10-06.dat    118400
2186/10/raw-2186-10-07.dat    118400
2186/11/raw-2186-11-01.dat    118400
2186/12/raw-2186-12-01.dat    118400
EOF

# ------------------------------------------------------------ case skeleton -

cat > case/TEMPLATE.md <<'EOF'
# Claim <n>

- **artefact:** <absolute path>
- **bytes:** <size in bytes>
- **mtime:** <YYYY-MM-DD HH:MM>
- **sha256:** <full hash of the bytes as found>
- **says:** <what the artefact literally contains, one sentence, no reading in>
- **means:** <what you take from it, one sentence, marked as yours>
EOF

printf 'Case file opened. One claim per file in artefacts/, named claim-NN.md.\n' \
    > case/notes/00-open.md

# ---------------------------------------------------------------- roe-check -

cat > bin/roe-check <<'EOF'
#!/bin/bash
# roe-check FILE -- check one claim against the rules of engagement.
#
# exit 0  claim is well formed
# exit 2  file missing or unreadable
# exit 3  a required field is absent
# exit 4  a field is present but still holds its placeholder
# exit 5  the sha256 field is not 64 hex characters
# exit 6  the artefact path does not exist

set -u

f="${1:-}"
if [ -z "$f" ]; then
    echo "usage: roe-check FILE" >&2
    exit 2
fi
if [ ! -r "$f" ]; then
    echo "roe-check: cannot read: $f" >&2
    exit 2
fi

fail=0
for k in artefact bytes mtime sha256 says means; do
    if ! grep -q "^- \*\*$k:\*\*" "$f"; then
        echo "roe-check: missing field: $k" >&2
        fail=3
    fi
done
[ "$fail" -eq 0 ] || exit "$fail"

if grep -q '^- \*\*[a-z0-9]*:\*\* *<' "$f"; then
    echo "roe-check: field still holds a placeholder" >&2
    exit 4
fi

h=$(sed -n 's/^- \*\*sha256:\*\* *//p' "$f" | head -1 | tr -d ' ')
if ! printf '%s' "$h" | grep -Eq '^[0-9a-f]{64}$'; then
    echo "roe-check: sha256 is not 64 hex characters: $h" >&2
    exit 5
fi

p=$(sed -n 's/^- \*\*artefact:\*\* *//p' "$f" | head -1)
if [ ! -e "$p" ]; then
    echo "roe-check: artefact path does not exist: $p" >&2
    exit 6
fi

echo "roe-check: ok"
EOF
chmod 755 bin/roe-check

# ----------------------------------------------------------------- mtimes ---

chmod -R u+rwX,go+rX "$LAB"

touch -h -d '2186-09-30 11:00' brief/deck-3-recert-notice.txt
touch -h -d '2187-05-24 04:12' brief/handover/notes.txt
touch -h -d '2187-06-02 09:00' brief/handover/README.txt
touch -h -d '2187-06-14 07:30' brief/rules-of-engagement.txt brief brief/handover
touch -h -d '2187-05-24 02:00' station/summariser/run.log station/summariser
touch -h -d '2187-05-22 21:40' station/mounts/raw-strain station/mounts
touch -h -d '2187-05-17 23:51' station/audit/MANIFEST.txt station/audit
touch -h -d '2187-06-14 07:30' station case case/artefacts case/notes \
    case/TEMPLATE.md case/notes/00-open.md bin bin/roe-check "$LAB"
