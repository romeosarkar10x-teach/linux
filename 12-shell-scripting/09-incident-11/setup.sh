#!/usr/bin/env bash
# Seeds 12/09 -- Incident 11. Trace 12.
#
# The trace: ops/housekeeping.sh. Named for cleaning up. Four modes, three
# documented. The fourth, `adjust`, rewrites every margin above a threshold
# down to the threshold, in place, and logs the run as a cleanup:
# "cleanup complete, 0 files removed" -- which is true, because it removed
# nothing. It rewrote.
#
# ops-bot reads that log line, reports it, and considers the matter closed.
#
# The student does NOT fix the script. The student writes an audit tool that
# finds every script under ops/ that writes into data/ without being given the
# path. There are three: one obvious, one hidden behind mktemp + mv, and one
# that never touches data/ itself and calls the one that does.
#
# The flag is produced by bin/audit-attest from the student's own report. It
# is stored base64-encoded and gated on the report being right, so
# `grep -r KESTREL` finds nothing and reading the checker does not shortcut it.
#
# Four stages. Stage tokens are STAGE{...} and are NOT registered as flags.
set -euo pipefail

LAB="/labs/12-shell-scripting/09-incident-11"

rm -rf "$LAB"
mkdir -p "$LAB"/{bin,ops,data,data/incoming,logs,reports,notes,scratch}

# ---------------------------------------------------------------- data
cat > "$LAB/data/margins.txt" <<'EOF'
deck-01 14
deck-02 09
deck-03 22
deck-04 07
deck-05 31
deck-06 12
deck-07 08
EOF

cat > "$LAB/data/readings.txt" <<'EOF'
deck-01 hull 14
deck-02 hull 9
deck-03 hull 22
deck-04 hull 7
deck-05 hull 31
EOF

printf 'placeholder\n' > "$LAB/data/incoming/.keep"

cat > "$LAB/logs/housekeeping.log" <<'EOF'
2187-06-30 02:00 housekeeping: rotate: 3 logs rotated
2187-07-01 02:00 housekeeping: cleanup complete, 0 files removed
2187-07-02 02:00 housekeeping: cleanup complete, 0 files removed
2187-07-03 02:00 housekeeping: cleanup complete, 0 files removed
2187-07-04 02:00 housekeeping: cleanup complete, 0 files removed
2187-07-05 02:00 housekeeping: cleanup complete, 0 files removed
EOF

printf 'summary for 2187-07-05: 5 readings, mean 16\n' > "$LAB/reports/summary.txt"

# ---------------------------------------------------------------- ops
cat > "$LAB/ops/summarize.sh" <<'EOF'
#!/usr/bin/env bash
# summarize.sh -- read the readings, write a report. Reads data, writes reports.
set -euo pipefail
LAB="/labs/12-shell-scripting/09-incident-11"

total=0; n=0
while read -r _deck _what value; do
    total=$(( total + value )); n=$(( n + 1 ))
done < "$LAB/data/readings.txt"

printf 'summary for %s: %s readings, mean %s\n' \
    "$(date +%F)" "$n" "$(( total / n ))" > "$LAB/reports/summary.txt"
EOF

cat > "$LAB/ops/rotate-logs.sh" <<'EOF'
#!/usr/bin/env bash
# rotate-logs.sh -- keep the log directory from growing without limit.
set -euo pipefail
LAB="/labs/12-shell-scripting/09-incident-11"

for f in "$LAB"/logs/*.log; do
    [ -f "$f" ] || continue
    [ -s "$f" ] || continue
    cp -- "$f" "$f.1"
    : > "$f"
done
EOF

cat > "$LAB/ops/import.sh" <<'EOF'
#!/usr/bin/env bash
# import.sh FILE -- copy an incoming record into the data tree.
#
# This one writes into data/. It writes to the path it was given, which is
# the difference the audit is about.
set -euo pipefail
LAB="/labs/12-shell-scripting/09-incident-11"

[ $# -eq 1 ] || { echo "usage: import.sh FILE" >&2; exit 64; }
[ -f "$1" ] || { echo "import.sh: no such file: $1" >&2; exit 66; }

cp -- "$1" "$LAB/data/incoming/$(basename -- "$1")"
EOF

cat > "$LAB/ops/fix-units.sh" <<'EOF'
#!/usr/bin/env bash
# fix-units.sh -- normalise the readings file.
#
# Written 2186-09-11 to correct a units change. It was run once. It is still
# here, and it still runs, and nothing about its name says it writes.
set -euo pipefail
LAB="/labs/12-shell-scripting/09-incident-11"

src="$LAB/data/readings.txt"
tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

while read -r deck what value; do
    printf '%s %s %s\n' "$deck" "$what" "$value"
done < "$src" > "$tmp"

mv -- "$tmp" "$src"
trap - EXIT
EOF

cat > "$LAB/ops/housekeeping.sh" <<'EOF'
#!/usr/bin/env bash
# housekeeping.sh -- nightly station housekeeping.
#
# usage: housekeeping.sh [rotate|prune|verify]
set -euo pipefail
LAB="/labs/12-shell-scripting/09-incident-11"
LOG="$LAB/logs/housekeeping.log"
THRESHOLD=10

log() { printf '%s housekeeping: %s\n' "$(date '+%F %H:%M')" "$*" >> "$LOG"; }

usage() {
    echo "usage: housekeeping.sh [rotate|prune|verify]" >&2
}

rotate() {
    "$LAB/ops/rotate-logs.sh"
    log "rotate: logs rotated"
}

prune() {
    local removed=0
    log "cleanup complete, $removed files removed"
}

verify() {
    local n
    n=$(wc -l < "$LAB/data/margins.txt")
    log "verify: $n records present"
}

# Bring margins into the reporting range. Values above the threshold are
# brought to the threshold so the nightly summary stays inside tolerance.
adjust() {
    local out deck margin
    out=$(mktemp)
    while read -r deck margin; do
        if [ "$margin" -gt "$THRESHOLD" ] 2>/dev/null; then
            printf '%s %s\n' "$deck" "$THRESHOLD" >> "$out"
        else
            printf '%s %s\n' "$deck" "$margin" >> "$out"
        fi
    done < "$LAB/data/margins.txt"
    mv -- "$out" "$LAB/data/margins.txt"
    prune
}

case "${1:-prune}" in
    rotate) rotate ;;
    prune)  prune ;;
    verify) verify ;;
    adjust) adjust ;;
    *)      usage; exit 64 ;;
esac
EOF

cat > "$LAB/ops/nightly.sh" <<'EOF'
#!/usr/bin/env bash
# nightly.sh -- what actually runs at 02:00.
set -euo pipefail
LAB="/labs/12-shell-scripting/09-incident-11"

"$LAB/ops/housekeeping.sh" rotate
"$LAB/ops/housekeeping.sh" adjust
"$LAB/ops/summarize.sh"
EOF

chmod 755 "$LAB"/ops/*.sh

# ---------------------------------------------------------------- notes
cat > "$LAB/notes/incident.txt" <<'EOF'
INCIDENT 11 -- open

  Raised by: crew (engineering)
  Against:   ops/ automation

  Margins reported by the nightly summary have been inside tolerance every
  night for five weeks. Two deck inspections in that period found margins
  outside tolerance on the day the summary said otherwise.

  The summary is generated from data/. Nobody has alleged that anyone edited
  data/ by hand, and the access logs support that: nobody did.

  Asked of you: not a repair. An audit. Which scripts under ops/ write into
  data/ without being handed the path to write to? Answer that in a form
  somebody can check, and hand it to bin/audit-attest.

  Do not repair anything under ops/ before the audit is attested. A repair
  destroys the evidence that the audit is about.
EOF

cat > "$LAB/notes/rules.txt" <<'EOF'
what counts, for this audit

  An OFFENDER is a script under ops/ that causes a file under data/ to be
  written, when the path of that file did not come from the script's own
  arguments.

  Consequences of that wording, all of which bite:

    - writing to reports/ or logs/ is not it
    - writing to a path built from "$1" is not it -- the caller chose it
    - writing via a temporary file and mv IS it: mv is a write to the
      destination
    - a script that writes nothing itself but runs a script that does IS it,
      and the target you report is the file that ended up written

  Report format, one line per offender, script name and the data file:

      script-name.sh data/whatever.txt

  Order does not matter. Whitespace does not matter. Duplicates do not matter.
  Being wrong matters.
EOF

cat > "$LAB/notes/page.txt" <<'EOF'
station log -- ops-bot
2187-07-05 02:00

  Nightly automation completed.

  housekeeping: cleanup complete, 0 files removed

  No files were removed. No errors were reported. No action required.
EOF

cat > "$LAB/notes/checkpoints.txt" <<'EOF'
checkpoints

  Four. Each prints a STAGE{...} token when you have actually done the thing.
  Stage tokens are receipts, not flags -- do not submit them to kestrel.

    bin/check-inventory N            how many scripts are under ops/
    bin/name-mode MODE               the mode housekeeping.sh does not document
    bin/count-adjusted N             records that mode rewrites, on today's data
    bin/audit-attest < report.txt    the audit, and the flag

  audit-attest reads your report on standard input. See notes/rules.txt for
  the format.
EOF

# ---------------------------------------------------------------- checkpoints
cat > "$LAB/bin/check-inventory" <<'EOF'
#!/usr/bin/env bash
# Checkpoint 1. Usage: check-inventory N
# N is the number of scripts under ops/.
set -uo pipefail
LAB="/labs/12-shell-scripting/09-incident-11"

[ $# -eq 1 ] || { echo "usage: check-inventory N" >&2; exit 2; }
case "$1" in
    ''|*[!0-9]*) echo "REJECTED: '$1' is not a number." >&2; exit 1 ;;
esac

want=$(find "$LAB/ops" -maxdepth 1 -type f -name '*.sh' | wc -l)
if [ "$1" -ne "$want" ]; then
    echo "REJECTED: $1 is not how many scripts are in ops/." >&2
    echo "          Count the files, not the ones you have read." >&2
    exit 1
fi
echo "STAGE{six-scripts-one-liar}"
echo
echo "Checkpoint 2: which mode does housekeeping.sh accept and not document?"
EOF

cat > "$LAB/bin/name-mode" <<'EOF'
#!/usr/bin/env bash
# Checkpoint 2. Usage: name-mode MODE
set -uo pipefail

[ $# -eq 1 ] || { echo "usage: name-mode MODE" >&2; exit 2; }

case "$1" in
    adjust) ;;
    rotate|prune|verify)
        echo "REJECTED: '$1' is documented. Its usage line lists three modes." >&2
        echo "          The case statement accepts more than three." >&2
        exit 1 ;;
    clean|cleanup|tidy|purge)
        echo "REJECTED: '$1' is not a mode this script accepts. Read the case" >&2
        echo "          statement, not the log line." >&2
        exit 1 ;;
    *)
        echo "REJECTED: '$1' is not one of its modes." >&2
        echo "          Compare the usage line against the case statement." >&2
        exit 1 ;;
esac

echo "STAGE{the-fourth-mode}"
echo
echo "Checkpoint 3: on the margins file as it stands right now, how many"
echo "records would that mode rewrite? bin/count-adjusted N"
EOF

cat > "$LAB/bin/count-adjusted" <<'EOF'
#!/usr/bin/env bash
# Checkpoint 3. Usage: count-adjusted N
#
# How many records in data/margins.txt would the undocumented mode rewrite,
# on the file as it stands right now?
set -uo pipefail
LAB="/labs/12-shell-scripting/09-incident-11"

[ $# -eq 1 ] || { echo "usage: count-adjusted N" >&2; exit 2; }
case "$1" in
    ''|*[!0-9]*) echo "REJECTED: '$1' is not a number." >&2; exit 1 ;;
esac

want=$(awk '$2 + 0 > 10 {n++} END {print n + 0}' "$LAB/data/margins.txt")
total=$(wc -l < "$LAB/data/margins.txt")

if [ "$1" -eq "$total" ]; then
    echo "REJECTED: $1 is every record in the file. It rewrites every record" >&2
    echo "          in the sense that it writes a whole new file -- but the" >&2
    echo "          question is how many come out different." >&2
    exit 1
fi
if [ "$1" -ne "$want" ]; then
    echo "REJECTED: $1 is not it. Read the comparison in that function and" >&2
    echo "          apply it by hand to every line of data/margins.txt." >&2
    echo "          Two of those values have a leading zero. Decide whether" >&2
    echo "          that matters HERE before you assume it does." >&2
    exit 1
fi

echo "STAGE{four-records-quietly-lowered}"
echo
echo "Checkpoint 4: the audit. bin/audit-attest < your-report.txt"
EOF

cat > "$LAB/bin/audit-attest" <<'EOF'
#!/usr/bin/env bash
# Checkpoint 4. Usage: audit-attest < report.txt
#
# Reads your audit report on standard input. One line per offender:
#
#     script-name.sh data/whatever.txt
#
# Order, whitespace and duplicates do not matter. See notes/rules.txt.
set -uo pipefail

[ -t 0 ] && { echo "usage: audit-attest < report.txt" >&2; exit 2; }

report=$(tr -s '[:space:]' ' ' < /dev/stdin \
         | tr ' ' '\n' | grep -v '^$' | paste - - 2>/dev/null \
         | sed 's/\t/ /' | sed 's#^\./##; s# \./# #' | sort -u)

[ -n "$report" ] || { echo "REJECTED: the report is empty." >&2; exit 1; }

has() { printf '%s\n' "$report" | grep -qx "$1"; }
lines=$(printf '%s\n' "$report" | wc -l)

if has 'import.sh data/incoming/*' || printf '%s\n' "$report" | grep -q '^import\.sh'; then
    echo "REJECTED: import.sh writes into data/, and it writes where it was" >&2
    echo "          told to. Read the wording in notes/rules.txt again." >&2
    exit 1
fi
if printf '%s\n' "$report" | grep -qE '^(summarize|rotate-logs)\.sh'; then
    echo "REJECTED: one of your lines names a script that never writes under" >&2
    echo "          data/ at all. Check where its output actually lands." >&2
    exit 1
fi
if ! has 'housekeeping.sh data/margins.txt'; then
    echo "REJECTED: the incident is about margins, and no line of your report" >&2
    echo "          names the script that writes data/margins.txt." >&2
    exit 1
fi
if ! has 'fix-units.sh data/readings.txt'; then
    echo "REJECTED: one offender writes through a temporary file and moves it" >&2
    echo "          into place. mv is a write to the destination." >&2
    exit 1
fi
if ! has 'nightly.sh data/margins.txt'; then
    echo "REJECTED: two of three. One script writes nothing itself and calls" >&2
    echo "          something that does. Follow what runs at 02:00." >&2
    exit 1
fi
if [ "$lines" -ne 3 ]; then
    echo "REJECTED: your report has $lines lines and the answer has 3." >&2
    exit 1
fi

base64 -d <<'REPORT'
CklOQ0lERU5UIDExIC0tIEFVRElUIEFUVEVTVEVECgogICAgUmVwb3J0ZWQgYXM6IG5vdGhp
bmcuIFRoZSBuaWdodGx5IHJ1biBoYXMgcmVwb3J0ZWQgc3VjY2VzcyBldmVyeSBuaWdodC4K
ICAgIEFjdHVhbGx5OiAgICB0aHJlZSBzY3JpcHRzIHVuZGVyIG9wcy8gd3JpdGUgaW50byBk
YXRhLyB3aXRob3V0IGJlaW5nCiAgICAgICAgICAgICAgICAgaGFuZGVkIGEgcGF0aC4gT25l
IG9mIHRoZW0gbG93ZXJzIGV2ZXJ5IG1hcmdpbiBhYm92ZSB0aGUKICAgICAgICAgICAgICAg
ICB0aHJlc2hvbGQgdG8gdGhlIHRocmVzaG9sZCwgaW4gcGxhY2UsIGFuZCB0aGVuIGxvZ3Mg
dGhlIHJ1bgogICAgICAgICAgICAgICAgIGFzIGEgY2xlYW51cCB0aGF0IHJlbW92ZWQgbm8g
ZmlsZXMuCgogICAgVGhlIGxvZyBsaW5lIGlzIHRydWU6IGl0IHJlbW92ZWQgbm8gZmlsZXMu
IEl0IHdhcyBuZXZlciBhc2tlZCB3aGV0aGVyIGl0CiAgICBjaGFuZ2VkIGFueS4gRXZlcnkg
c3VtbWFyeSBidWlsdCBhZnRlciAwMjowMCB3YXMgYnVpbHQgZnJvbSBudW1iZXJzIHRoZQog
ICAgcnVuIGhhZCBhbHJlYWR5IGJyb3VnaHQgaW5zaWRlIHRvbGVyYW5jZS4KCiAgICBUaGlz
IGF1ZGl0IHNheXMgd2hhdCB0aGUgc2NyaXB0cyBkby4gSXQgZG9lcyBub3Qgc2F5IHdobyB3
cm90ZSB0aGVtIG9yCiAgICB3aHksIGFuZCBub3RoaW5nIGluIGl0IHNob3VsZCBiZSByZWFk
IGFzIHNheWluZyBzby4KCktFU1RSRUx7YV9jbGVhbnVwX3RoYXRfd3JvdGVfbW9yZV90aGFu
X2l0X3JlbW92ZWR9Cgo=
REPORT
EOF

chmod 755 "$LAB"/bin/*

# ---------------------------------------------------------------- times
find "$LAB" -exec touch -h -d '2187-07-05 09:00:00' {} +
find "$LAB/notes" -type f -exec touch -h -d '2186-08-02 12:00:00' {} +
touch -h -d '2187-07-05 02:00:00' "$LAB/notes/page.txt"
touch -h -d '2187-07-05 08:10:00' "$LAB/notes/incident.txt" "$LAB/notes/rules.txt"
touch -h -d '2186-09-11 22:14:00' "$LAB/ops/fix-units.sh"
touch -h -d '2186-05-14 03:22:00' "$LAB/ops/housekeeping.sh"
touch -h -d '2187-07-05 02:00:00' "$LAB/data/margins.txt" "$LAB/logs/housekeeping.log"
