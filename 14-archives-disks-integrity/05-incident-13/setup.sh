#!/bin/bash
# Lab setup for 14-archives-disks-integrity/05-incident-13.
# Idempotent: safe to run repeatedly.
set -euo pipefail

LAB="/labs/14-archives-disks-integrity/05-incident-13"
export SOURCE_DATE_EPOCH=1577836800

rm -rf "$LAB"
mkdir -p "$LAB"/{export,readings,notes,scratch,bin}

BUILD=$(mktemp -d)
trap 'rm -rf "$BUILD"' EXIT
mkdir -p "$BUILD/strain-2187-06"

# Days that were clamped, and are also the days the export cut short.
SHORT="02 07 11 16 19"

is_short() {
    case " $SHORT " in *" $1 "*) return 0 ;; *) return 1 ;; esac
}

day_max() {  # deterministic daily maximum; clamped days read at or above 6.0
    local d=$1
    if is_short "$d"; then
        printf '6.%d\n' $(( (10#$d * 3) % 5 ))
    else
        printf '%d.%d\n' $(( 3 + (10#$d % 3) )) $(( (10#$d * 7) % 10 ))
    fi
}

for d in $(seq -w 1 20); do
    f="$BUILD/strain-2187-06/strain-2187-06-$d.log"
    : > "$f"
    lines=144
    is_short "$d" && lines=97
    # the day's peak sample sits at index 120 on clamped days -- past the
    # point where the short files stop -- and at index 60 otherwise.
    peak=60
    is_short "$d" && peak=120
    i=0
    while [ "$i" -lt "$lines" ]; do
        if [ "$i" -eq "$peak" ]; then
            v=$(day_max "$d")
        else
            v=$(printf '2.%d' $(( (i * 3) % 10 )))
        fi
        printf '2187-06-%s %02d:%02d:00 deck-04 strain %s\n' \
            "$d" $(( i / 6 )) $(( (i % 6) * 10 )) "$v" >> "$f"
        i=$(( i + 1 ))
    done
done

tar --sort=name --owner=0 --group=0 --numeric-owner \
    --mtime="@$SOURCE_DATE_EPOCH" --format=gnu \
    -C "$BUILD" -czf "$LAB/export/strain-archive-2187-06.tar.gz" strain-2187-06

# --- the export's own checksum file: correct, and it will pass -----------
( cd "$LAB/export" && sha256sum strain-archive-2187-06.tar.gz > SHA256SUMS )

# --- the handwritten manifest: what the export was supposed to contain ---
{
    printf '# strain export manifest -- deck-04, 2187-06\n'
    printf '# expected 144 samples per day (10 minute interval)\n'
    printf '# file  lines  sha256\n'
    for d in $(seq -w 1 20); do
        f="$BUILD/strain-2187-06/strain-2187-06-$d.log"
        h=$(sha256sum "$f" | cut -d' ' -f1)
        # One line carries a human typo in its hash. The file is fine.
        if [ "$d" = "13" ]; then
            h="${h:0:8}$(printf '%s' "${h:9:1}${h:8:1}")${h:10}"
        fi
        printf 'strain-2187-06-%s.log  144  %s\n' "$d" "$h"
    done
} > "$LAB/export/MANIFEST.txt"

# --- readings: the independent record of daily maxima --------------------
{
    printf 'date,deck,max_strain,clamp_threshold\n'
    for d in $(seq -w 1 20); do
        printf '2187-06-%s,deck-04,%s,6.0\n' "$d" "$(day_max "$d")"
    done
} > "$LAB/readings/deck-04-daily-max.csv"

# --- red herring: a .gz that is not gzip ---------------------------------
printf 'export produced by bay console, operator on shift\n' \
    > "$BUILD/console-note.txt"
bzip2 -c "$BUILD/console-note.txt" > "$LAB/export/console-note.txt.gz"

cat > "$LAB/notes/handover.txt" <<'EOF'
Deck ops handover

The strain export for 2187-06 passes its checksum. The bay console says the
export completed. The captain has asked for it to be signed off.

There is a manifest in the export directory that nobody has checked against
the archive. Check it.

Do not modify the archive. Whatever you conclude, the archive has to be
byte-identical when you are done, and you have to be able to show that.
EOF

cat > "$LAB/notes/page.txt" <<'EOF'
From: ops-bot
To: cadet

EXPORT ADVISORY. Archive strain-archive-2187-06.tar.gz verified against
SHA256SUMS. Result: pass. Twenty members. No further checks configured.

End of message.
EOF

# --- the audit tool -------------------------------------------------------
cat > "$LAB/bin/manifest-audit" <<'TOOL'
#!/bin/bash
# manifest-audit -- deck ops export auditor
set -uo pipefail

LAB="/labs/14-archives-disks-integrity/05-incident-13"
ARCHIVE="$LAB/export/strain-archive-2187-06.tar.gz"
ARCHIVE_SHA="__ARCHIVE_SHA__"
B64_PAYLOAD='__PAYLOAD__'

die() { printf '%s\n' "$*" >&2; }

archive_unchanged() {
    [ -f "$ARCHIVE" ] || return 1
    [ "$(sha256sum "$ARCHIVE" | cut -d' ' -f1)" = "$ARCHIVE_SHA" ]
}

usage() {
    cat <<'USAGE'
usage: manifest-audit <command>

  verify            check the export against its own SHA256SUMS
  shortfall DIR     audit an extracted copy of the archive in DIR
  attest FILE       submit findings

exit: 0 ok, 2 usage, 3 archive modified, 4 audit incomplete, 5 findings wrong
USAGE
}

case "${1-}" in
verify)
    if ! archive_unchanged; then
        die "manifest-audit: archive does not match its recorded hash"
        exit 3
    fi
    printf 'archive verified: bytes unchanged since export\n'
    printf 'STAGE{bytes-unchanged}\n'
    printf 'next: audit an extracted copy. the archive stays where it is.\n'
    exit 0
    ;;
shortfall)
    dir=${2-}
    [ -n "$dir" ] || { usage >&2; exit 2; }
    if ! archive_unchanged; then
        die "manifest-audit: archive does not match its recorded hash"
        exit 3
    fi
    case "$(readlink -f "$dir")" in
        "$LAB/export"|"$LAB/export/"*)
            die "manifest-audit: refusing to audit inside the export directory"
            exit 3 ;;
    esac
    found=0 short=0
    for d in $(seq -w 1 20); do
        f=$(find "$dir" -type f -name "strain-2187-06-$d.log" 2>/dev/null \
            | head -1)
        [ -n "$f" ] || continue
        found=$(( found + 1 ))
        n=$(wc -l < "$f")
        [ "$n" -lt 144 ] && short=$(( short + 1 ))
    done
    if [ "$found" -ne 20 ]; then
        die "manifest-audit: found $found of 20 day files under $dir"
        die "manifest-audit: audit incomplete"
        exit 4
    fi
    printf 'audited 20 day files\n'
    printf 'short of the manifest: %d\n' "$short"
    printf 'STAGE{five-days-fell-short}\n'
    printf 'next: those days are not arbitrary. attest what they have in common.\n'
    exit 0
    ;;
attest)
    file=${2-}
    [ -f "$file" ] || { usage >&2; exit 2; }
    if ! archive_unchanged; then
        die "manifest-audit: archive does not match its recorded hash"
        exit 3
    fi
    want="2187-06-02
2187-06-07
2187-06-11
2187-06-16
2187-06-19"
    got=$(grep -oE '2187-06-[0-9]{2}' "$file" | sort -u)
    if [ "$got" != "$want" ]; then
        die "manifest-audit: the attested dates are not the short days"
        exit 5
    fi
    if ! grep -qE '(^|[^0-9])6\.0([^0-9]|$)' "$file"; then
        die "manifest-audit: attestation names no threshold"
        exit 5
    fi
    printf 'attestation accepted\n'
    printf '%s\n' "$B64_PAYLOAD" | base64 -d
    printf '\n'
    exit 0
    ;;
*)
    usage >&2
    exit 2
    ;;
esac
TOOL

ARCHIVE_SHA=$(sha256sum "$LAB/export/strain-archive-2187-06.tar.gz" \
    | cut -d' ' -f1)
PAYLOAD=$(printf 'KESTREL{manifest_says_otherwise}' | base64 -w0)
sed -i "s|__ARCHIVE_SHA__|$ARCHIVE_SHA|; s|__PAYLOAD__|$PAYLOAD|" \
    "$LAB/bin/manifest-audit"
chmod 755 "$LAB/bin/manifest-audit"

chmod -R u+rwX,go+rX "$LAB"
find "$LAB" -exec touch -h -d '2187-07-16 08:30' {} +
