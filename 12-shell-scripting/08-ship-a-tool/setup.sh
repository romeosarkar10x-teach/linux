#!/bin/bash
# Lab setup for 12/08 — shipping a tool: PATH, +x, shebang, --help, exit codes
set -euo pipefail

LAB="/labs/12-shell-scripting/08-ship-a-tool"

rm -rf "$LAB"
mkdir -p "$LAB"/{bin,data,examples,broken,notes,scratch}

# ---------------------------------------------------------------- data
cat > "$LAB/data/decks.txt" <<'EOF'
deck-01 engineering
deck-02 hydroponics
deck-03 cargo
deck-04 medical
deck-05 observation
EOF

cat > "$LAB/data/faults.txt" <<'EOF'
2187-07-01 deck-03 seal-pressure
2187-07-01 deck-03 seal-pressure
2187-07-02 deck-01 coolant-loop
2187-07-03 deck-03 hatch-sensor
2187-07-04 deck-05 lamp
EOF

# ---------------------------------------------------------------- examples
# The tool the station already has. It works, and nobody can use it.
cat > "$LAB/examples/deckinfo" <<'EOF'
#!/usr/bin/env bash
# deckinfo -- no usage, no exit codes, no help, one behaviour
grep "$1" /labs/12-shell-scripting/08-ship-a-tool/data/decks.txt
EOF

# The tool worth imitating.
cat > "$LAB/examples/logsize" <<'EOF'
#!/usr/bin/env bash
# logsize -- report the size of a log file
# exit: 0 ok, 64 usage, 66 no such file
set -euo pipefail

usage() {
    cat <<'USAGE'
usage: logsize FILE

Report the size of FILE in bytes and lines.

exit codes:
  0   ok
  64  usage error
  66  no such file
USAGE
}

case "${1:-}" in
    -h|--help) usage; exit 0 ;;
    '')        usage >&2; exit 64 ;;
esac

file=$1
[ -f "$file" ] || { echo "logsize: no such file: $file" >&2; exit 66; }

printf '%s: %s bytes, %s lines\n' \
    "$file" "$(wc -c < "$file")" "$(wc -l < "$file")"
EOF

# ---------------------------------------------------------------- broken
printf '#!/usr/bin/env bash\necho ran\n'  > "$LAB/broken/noexec"
printf 'echo ran\n'                       > "$LAB/broken/no-shebang"
printf '#!/bin/bahs\necho ran\n'          > "$LAB/broken/bad-shebang"
printf '#!/usr/bin/env bash\r\necho ran\n' > "$LAB/broken/crlf"
chmod +x "$LAB/broken/no-shebang" "$LAB/broken/bad-shebang" "$LAB/broken/crlf"
chmod 644 "$LAB/broken/noexec"

# ---------------------------------------------------------------- notes
cat > "$LAB/notes/shipping.txt" <<'EOF'
notes -- what turns a script into a tool

  1. a shebang        #!/usr/bin/env bash on line 1, column 1
  2. the x bit        chmod +x
  3. a name on PATH   ~/.local/bin, not the directory you happened to be in
  4. --help           that answers the question people ask, not the one you like
  5. exit codes       documented in a comment at the top
  6. no surprises     no writes outside its arguments, nothing on stdout but
                      the answer

Anything missing from that list is a thing the next person has to discover by
reading your source.
EOF

cat > "$LAB/notes/path.txt" <<'EOF'
notes -- PATH, again

  ~/.profile already has:

      if [ -d "$HOME/.local/bin" ] ; then
          PATH="$HOME/.local/bin:$PATH"
      fi

  Two facts follow from that "if".  Work out both before you complain that
  your tool is not on PATH.

  Also:
      command -v NAME     where would the shell go
      type -a NAME        every place it could go, in order
      hash -r             forget what you learned last time
EOF

cat > "$LAB/notes/exit-codes.txt" <<'EOF'
notes -- statuses the shell produces itself

  126   found it, could not run it
  127   could not find it -- or found it and could not find its interpreter

  The second half of 127 has cost this station more hours than any real bug.
EOF

cat > "$LAB/notes/page.txt" <<'EOF'
station log -- crew note
2186-04-30 17:12

  deckinfo works. It is not documented anywhere and nobody but me knows the
  argument order. Will write it up later.

  -- rhea

  [no follow-up on file]
EOF

# ---------------------------------------------------------------- permissions
chmod +x "$LAB/examples/deckinfo" "$LAB/examples/logsize"

# ---------------------------------------------------------------- times
find "$LAB" -exec touch -h -d '2187-07-06 09:00:00' {} +
find "$LAB/notes" -type f -exec touch -h -d '2186-08-02 12:00:00' {} +
touch -h -d '2186-04-30 17:12:00' "$LAB/notes/page.txt"
touch -h -d '2186-04-29 11:05:00' "$LAB/examples/deckinfo"
