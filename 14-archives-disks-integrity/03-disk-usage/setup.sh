#!/bin/bash
# Lab setup for 14-archives-disks-integrity/03-disk-usage.
# Idempotent: safe to run repeatedly.
set -euo pipefail

LAB="/labs/14-archives-disks-integrity/03-disk-usage"

rm -rf "$LAB"
mkdir -p "$LAB"/{bay,notes,scratch}
mkdir -p "$LAB"/bay/{telemetry,exports,media,old-logs,empty-run}
mkdir -p "$LAB"/bay/telemetry/{deck-01,deck-04,deck-09}

# --- telemetry: many small files, uneven per deck -------------------------
gen_log() {  # gen_log PATH LINES
    local out=$1 n=$2 i=1
    : > "$out"
    while [ "$i" -le "$n" ]; do
        printf '2187-%02d-%02d %02d:00:00 strain %d.%d ok\n' \
            $(( i % 12 + 1 )) $(( i % 28 + 1 )) $(( i % 24 )) \
            $(( i % 9 )) $(( i % 10 )) >> "$out"
        i=$(( i + 1 ))
    done
}

for d in 01 04 09; do
    n=1
    while [ "$n" -le 12 ]; do
        gen_log "$LAB/bay/telemetry/deck-$d/2187-$(printf '%02d' "$n").log" \
            $(( 40 + n * 3 ))
        n=$(( n + 1 ))
    done
done
# deck-09 has one month that ran long
gen_log "$LAB/bay/telemetry/deck-09/2187-06.log" 4000

# --- exports: a few medium files ------------------------------------------
gen_log "$LAB/bay/exports/strain-export.csv" 2500
gen_log "$LAB/bay/exports/hatch-export.csv" 900
cp "$LAB/bay/exports/strain-export.csv" "$LAB/bay/exports/strain-export.csv.bak"

# --- media: one genuinely large file --------------------------------------
head -c 3000000 /dev/zero | tr '\0' 'k' > "$LAB/bay/media/bay-cam-2187-06.raw"

# --- old-logs: hard links, so the bytes are on disk once ------------------
gen_log "$LAB/bay/old-logs/audit-2186.log" 1500
ln "$LAB/bay/old-logs/audit-2186.log" "$LAB/bay/old-logs/audit-2186.log.1"
ln "$LAB/bay/old-logs/audit-2186.log" "$LAB/bay/old-logs/audit-2186.log.2"

# --- a sparse file: apparent size is not disk usage -----------------------
dd if=/dev/null of="$LAB/bay/old-logs/preallocated.img" bs=1 seek=5000000 \
    status=none

# --- a thousand empty-ish files: inodes cost, bytes do not ----------------
mkdir -p "$LAB/bay/empty-run"
i=1
while [ "$i" -le 400 ]; do
    printf 'run %d\n' "$i" > "$LAB/bay/empty-run/run-$(printf '%04d' "$i").txt"
    i=$(( i + 1 ))
done

cat > "$LAB/notes/disk.txt" <<'EOF'
Bay storage note -- deck ops

df says the volume is filling. du says the bay directory is not that big.
Both numbers are correct. Work out why before you delete anything.

Do not delete anything in bay/. Read only.
EOF

cat > "$LAB/notes/page.txt" <<'EOF'
From: ops-bot
To: cadet

STORAGE ADVISORY. /dev/shm at 64M capacity, shared. No quota configured.
Report space by filesystem, not by directory. Directory totals do not
account for space held by open file descriptors.

End of message.
EOF

chmod -R u+rwX,go+rX "$LAB"
find "$LAB" -exec touch -h -d '2187-07-11 09:20' {} +
