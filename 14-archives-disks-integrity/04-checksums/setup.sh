#!/bin/bash
# Lab setup for 14-archives-disks-integrity/04-checksums.
# Idempotent: safe to run repeatedly.
set -euo pipefail

LAB="/labs/14-archives-disks-integrity/04-checksums"

rm -rf "$LAB"
mkdir -p "$LAB"/{dist,copies,notes,scratch}

gen() {  # gen PATH LINES SEED
    local out=$1 n=$2 seed=$3 i=1
    : > "$out"
    while [ "$i" -le "$n" ]; do
        printf '%s %04d strain %d.%d\n' "$seed" "$i" \
            $(( (i * 7 + 3) % 9 )) $(( (i * 13) % 10 )) >> "$out"
        i=$(( i + 1 ))
    done
}

cd "$LAB/dist"
gen strain-2187-04.log 300 deck
gen strain-2187-05.log 300 hatch
gen strain-2187-06.log 300 bay
gen calibration.csv 60 cal
printf 'deck ops handover\nsigned: station\n' > handover.txt
printf 'deck ops handover\nsigned: station\n' > handover-copy.txt
printf 'run one\n' > 'sensor log 04.txt'

# The manifest is written while every file is correct.
sha256sum ./*.log ./*.csv ./*.txt > SHA256SUMS
md5sum ./*.log > MD5SUMS

# ...and one file changes afterwards. A single character.
sed -i '150s/strain/strian/' strain-2187-05.log

# A file the manifest names but which is not here.
printf 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855  ./strain-2187-07.log\n' \
    >> SHA256SUMS

cd "$LAB/copies"
cp "$LAB/dist/strain-2187-04.log" full.log
cp "$LAB/dist/strain-2187-04.log" truncated.log
truncate -s -40 truncated.log
cp "$LAB/dist/strain-2187-04.log" renamed.log

# A manifest saved from a machine that ended its lines with CRLF.
sha256sum full.log renamed.log | sed 's/$/\r/' > CRLF-SUMS

# A manifest with the same hashes and a leading * on each name.
sha256sum full.log renamed.log | sed 's|  | *|' > BINARY-SUMS

cat > "$LAB/notes/checksums.txt" <<'EOF'
Bay note -- deck ops

Every export ships with a SHA256SUMS file written by the exporter.
sha256sum -c passes. The export is still wrong.

Work out what -c actually proved before you decide that means anything.
EOF

cat > "$LAB/notes/page.txt" <<'EOF'
From: ops-bot
To: cadet

INTEGRITY ADVISORY. Checksum verification confirms that bytes have not
changed since the checksum was computed. It does not establish who
computed it, when, or against what. No key material is configured on
this station.

End of message.
EOF

chmod -R u+rwX,go+rX "$LAB"
find "$LAB" -exec touch -h -d '2187-07-14 16:05' {} +
