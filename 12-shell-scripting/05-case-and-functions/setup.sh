#!/bin/bash
# Lab setup for 12/05 — case, functions, local, return codes vs echo
set -euo pipefail

LAB="/labs/12-shell-scripting/05-case-and-functions"

rm -rf "$LAB"
mkdir -p "$LAB"/{bin,decks,lib,notes,ops,scratch}

# ---------------------------------------------------------------- decks
for d in alpha beta gamma; do
    printf '%s-01 nominal\n%s-02 nominal\n%s-03 nominal\n' "$d" "$d" "$d" > "$LAB/decks/$d.log"
done
printf 'epsilon-01 FAULT\nepsilon-02 nominal\n' > "$LAB/decks/epsilon.log"

# ---------------------------------------------------------------- bin
cat > "$LAB/bin/mode" <<'EOF'
#!/usr/bin/env bash
# Four modes, one dispatcher. This is what case is for.
case "$1" in
    status)  echo "all decks nominal" ;;
    count)   echo "decks: 4" ;;
    faults)  echo "faults: 1" ;;
    help|-h|--help)
             echo "usage: mode {status|count|faults|help}" ;;
    *)       echo "mode: unknown mode: $1" >&2; exit 64 ;;
esac
EOF

cat > "$LAB/bin/dispatch" <<'EOF'
#!/usr/bin/env bash
# rhea, 2186-04-02. Reordered while adding the debug catch-all.
case "$1" in
    deck-*)  echo "deck command: $1" ;;
    *)       echo "unrecognised: $1" ;;
    deck-01) echo "the bridge deck, which is special" ;;
    status)  echo "status" ;;
esac
EOF

cat > "$LAB/bin/fallthrough" <<'EOF'
#!/usr/bin/env bash
# ;; stops. ;& runs the next body without testing it. ;;& tests the rest.
echo "-- with ;;"
case "$1" in
    a*) echo "A" ;;
    *x) echo "X" ;;
esac
echo "-- with ;&"
case "$1" in
    a*) echo "A" ;&
    *x) echo "X" ;;
esac
echo "-- with ;;&"
case "$1" in
    a*) echo "A" ;;&
    *x) echo "X" ;;
esac
EOF

cat > "$LAB/bin/classify-deck" <<'EOF'
#!/usr/bin/env bash
for f in "$@"; do
    case "$f" in
        *.log)     kind="log" ;;
        *.log.gz)  kind="compressed log" ;;
        *.txt)     kind="notes" ;;
        *)         kind="unknown" ;;
    esac
    echo "$f: $kind"
done
EOF

cat > "$LAB/bin/echo-vs-return" <<'EOF'
#!/usr/bin/env bash
# Two functions that answer the same question two different ways.

# Answers by printing. The caller captures it.
deck_lines() {
    wc -l < "$1"
}

# Answers by status. The caller tests it.
deck_has_fault() {
    grep -q FAULT "$1"
}

for f in "$@"; do
    n=$(deck_lines "$f")
    if deck_has_fault "$f"; then
        echo "$f: $n lines, FAULT"
    else
        echo "$f: $n lines, clean"
    fi
done
EOF

cat > "$LAB/bin/leaky" <<'EOF'
#!/usr/bin/env bash
# One of these two functions changes its caller's variable.
count=start

with_local()    { local count=inner; }
without_local() {       count=inner; }

with_local
echo "after with_local:    count=$count"
without_local
echo "after without_local: count=$count"
EOF

cat > "$LAB/bin/status-trap" <<'EOF'
#!/usr/bin/env bash
# Both functions run the same failing command. They do not report the same thing.
masked()   { local n=$(grep -c FAULT "$1"); }
unmasked() { local n; n=$(grep -c FAULT "$1"); }

masked   "$1"; echo "masked:   $?"
unmasked "$1"; echo "unmasked: $?"
EOF

cat > "$LAB/bin/big-return" <<'EOF'
#!/usr/bin/env bash
too_big()  { return 300; }
not_a_num() { return abc; }

too_big;   echo "return 300 -> $?"
not_a_num; echo "return abc -> $?"
EOF

# ---------------------------------------------------------------- lib
cat > "$LAB/lib/deck.sh" <<'EOF'
# Sourced, not executed. No shebang on purpose (12/01).

DECKS="${DECKS:-/labs/12-shell-scripting/05-case-and-functions/decks}"

deck_path() {
    printf '%s/%s.log\n' "$DECKS" "$1"
}

deck_exists() {
    [ -f "$(deck_path "$1")" ]
}

deck_report() {
    local name="$1" path
    path=$(deck_path "$name") || return 1
    deck_exists "$name" || { echo "no such deck: $name" >&2; return 1; }
    printf '%s: %s lines\n' "$name" "$(wc -l < "$path")"
}
EOF

# ---------------------------------------------------------------- ops
cat > "$LAB/ops/housekeeping.sh" <<'EOF'
#!/usr/bin/env bash
# housekeeping.sh — routine deck-log maintenance
# usage: housekeeping.sh {rotate|prune|verify}

LOGDIR=/var/log/decks

usage() {
    echo "usage: housekeeping.sh {rotate|prune|verify}"
}

rotate() {
    echo "rotate: 0 files rotated"
}

prune() {
    echo "cleanup complete, 0 files removed"
}

verify() {
    echo "verify: checksums ok"
}

adjust() {
    # threshold pass; see ops note 2186-05
    echo "adjust: 0 records adjusted"
}

case "${1:-prune}" in
    rotate) rotate ;;
    prune)  prune ;;
    verify) verify ;;
    adjust) adjust ;;
    *)      usage; exit 64 ;;
esac
EOF

# ---------------------------------------------------------------- notes
cat > "$LAB/notes/case.txt" <<'EOF'
case
----
    case WORD in
        pattern) commands ;;
        p1|p2)   commands ;;
        *)       commands ;;
    esac

WORD is expanded but NOT word-split and NOT globbed. `case $v in` with
v="a b" still matches the pattern "a b". This is the one place unquoted
is safe -- quote it anyway, so you never have to remember which place.

Patterns are globs, not regexes: * ? [abc] [a-z], and | for alternatives.
There is no anchoring; the pattern must match the WHOLE word.

FIRST MATCH WINS and nothing after it is tested. A `*)` branch placed
anywhere but last makes everything below it dead code. bash will not
warn you. shellcheck will.

Terminators:
    ;;   stop
    ;&   run the NEXT body without testing its pattern (fallthrough)
    ;;&  keep testing the remaining patterns
EOF

cat > "$LAB/notes/functions.txt" <<'EOF'
functions
---------
    name() { commands; }

Defined at run time, not parsed ahead: the definition must execute before
the call. A function is looked up before an external command and before
PATH, so `ls() { ... }` shadows /bin/ls -- `command ls` gets past it.

    type -t name     function, builtin, file, alias, keyword
    declare -f name  print the definition
    unset -f name    remove it

Arguments are positional, same as a script: $1 $2 $# "$@". $0 is NOT the
function name -- it is still the script. Use ${FUNCNAME[0]} for that.

A function's exit status is the status of its last command, or whatever
`return N` says. N is taken mod 256: `return 300` gives 44. A non-numeric
argument is an error (status 2) and prints a message.

`exit` inside a function exits the whole script. `return` outside a
function is an error: "can only `return' from a function or sourced
script".
EOF

cat > "$LAB/notes/local.txt" <<'EOF'
local
-----
Without `local`, an assignment inside a function writes the caller's
variable. With it, the name is private to this call and to anything it
calls (dynamic scope -- not the same as a language with real closures).

    f() { local n; n=$(command); }   good
    f() { local n=$(command); }      hides the status

The second line's status is `local`'s, which is 0 whatever the command
did. Declare on one line, assign on the next, whenever you care about
the status.

Every variable a function sets should be local unless you meant to
export it upward. The bug this prevents does not look like a scope bug;
it looks like a loop counter that was already 4 before the loop started.
EOF

cat > "$LAB/notes/page.txt" <<'EOF'
station log — ops-bot
2187-07-03 02:40

  Scheduled maintenance run: ops/housekeeping.sh
  Mode: default
  Output: "cleanup complete, 0 files removed"
  Duration: 0.02s
  Exit status: 0

  Run recorded. No action required.
EOF

# ---------------------------------------------------------------- perms
chmod 755 "$LAB"/bin/* "$LAB/ops/housekeeping.sh"
chmod 644 "$LAB/lib/deck.sh"

# ---------------------------------------------------------------- times
find "$LAB" -exec touch -h -d '2187-07-03 09:00:00' {} +
find "$LAB/notes" -type f -exec touch -h -d '2186-08-02 12:00:00' {} +
touch -h -d '2187-07-03 02:40:00' "$LAB/notes/page.txt"
touch -h -d '2186-04-02 11:20:00' "$LAB/bin/dispatch"
touch -h -d '2186-05-14 16:05:00' "$LAB/ops/housekeeping.sh"
