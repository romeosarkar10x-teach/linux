#!/usr/bin/env bash
# Lab setup — 12/02 arguments
set -euo pipefail

LAB="/labs/12-shell-scripting/02-arguments"
rm -rf "$LAB"
mkdir -p "$LAB"/{bin,decks,notes,scratch}

cat > "$LAB/bin/show-args" <<'SH'
#!/usr/bin/env bash
# Prints exactly what it was handed. The only honest witness in this lab.
echo "\$0 = [$0]"
echo "\$# = $#"
i=1
for a in "$@"; do
    echo "  \$$i = [$a]"
    i=$((i + 1))
done
SH

cat > "$LAB/bin/count-at" <<'SH'
#!/usr/bin/env bash
# Same loop, three ways. Count the iterations, not the characters.
echo "--- \"\$@\""
for a in "$@";  do echo "  <$a>"; done
echo "--- \$@"
for a in $@;    do echo "  <$a>"; done
echo "--- \"\$*\""
for a in "$*";  do echo "  <$a>"; done
SH

cat > "$LAB/bin/deck-report" <<'SH'
#!/usr/bin/env bash
# rhea's, from 2186. Works on every deck name that has never had a space in it.
DECKS=/labs/12-shell-scripting/02-arguments/decks
lines=$(wc -l < $DECKS/$1)
echo "$1: $lines entries"
SH

cat > "$LAB/bin/deck-report-2" <<'SH'
#!/usr/bin/env bash
# Second attempt. One of the two bugs above is fixed here. Only one.
DECKS=/labs/12-shell-scripting/02-arguments/decks
lines=$(wc -l < "$DECKS/$1")
echo "$1: $lines entries"
SH

cat > "$LAB/bin/relay" <<'SH'
#!/usr/bin/env bash
# Hands its arguments to show-args. How it hands them over is the exercise.
/labs/12-shell-scripting/02-arguments/bin/show-args $@
SH

cat > "$LAB/bin/relay-quoted" <<'SH'
#!/usr/bin/env bash
/labs/12-shell-scripting/02-arguments/bin/show-args "$@"
SH

cat > "$LAB/bin/needs-two" <<'SH'
#!/usr/bin/env bash
# Refuses to guess. Notice what it costs to be this polite: four lines.
if [ "$#" -ne 2 ]; then
    echo "usage: $(basename "$0") <deck> <shift>" >&2
    exit 64
fi
echo "deck=$1 shift=$2"
SH

chmod 755 "$LAB"/bin/*

# --- deck records, one with a space in the name -----------------------------
mkdir -p "$LAB/decks"
for d in alpha beta gamma; do
    seq -w 1 6 | sed "s/^/$d-/; s/$/ nominal/" > "$LAB/decks/$d"
done
seq -w 1 4 | sed 's/^/hold-/; s/$/ nominal/' > "$LAB/decks/cargo hold"
printf 'deck-99 nominal\n' > "$LAB/decks/-n"

cat > "$LAB/notes/positional.txt" <<'TXT'
$0   the name the script was invoked as. Not the script's location, not its
     name on disk -- the string the caller used. Sourced, it is the shell's
     own $0 instead.
$1.. the positional parameters. ${10} needs braces; $10 is $1 followed by 0.
$#   how many there are. Not counting $0.
$@   all of them
$*   all of them, joined into one string with the first character of IFS

Quoted, "$@" becomes one word per argument and an empty list when there are
none. Unquoted, $@ and $* are both split on whitespace and then globbed, which
is how "cargo hold" becomes two decks that do not exist.

Rule: write "$@". Every time. The only reason to write "$*" is when you
genuinely want one string, and then you should say so in a comment.
TXT

cat > "$LAB/notes/shift.txt" <<'TXT'
shift    drops $1; everything moves down one; $# decreases.
shift N  drops N.

shift with nothing left returns 1 and changes nothing. That return value is
the loop condition you want:

    while [ "$#" -gt 0 ]; do
        echo "handling $1"
        shift
    done

set -- a b c  replaces the positional parameters entirely. Useful for
defaults: if the caller gave none, put your own in.
TXT

cat > "$LAB/notes/page.txt" <<'TXT'
rhea -- 2187-06-30 08:20

deck-report gives me "cargo hold:  entries" -- no number at all -- and the
correct count for every other deck. It also says something about an ambiguous
redirect, which I do not think is a word about my typing. And then it exits 0,
so the shift report records it as a successful run.

The file is there. I can cat it. I typed the name the same way both times.

I have checked the file. Twice. It is fine. Please look at the script.
TXT

cat > "$LAB/notes/usage.txt" <<'TXT'
A script that guesses is a script that will one day guess wrong on your data.

Three things a script owes its caller:
  - check $# before using $1
  - print usage to stderr, not stdout
  - exit nonzero, so the caller's `if` sees it

Exit 64 is a convention (sysexits: EX_USAGE). Any nonzero works. Being
consistent matters more than which number you pick.
TXT

find "$LAB" -exec touch -d '2187-06-30 09:00:00' {} +
touch -d '2186-08-02 11:50:00' "$LAB"/notes/positional.txt "$LAB"/notes/shift.txt "$LAB"/notes/usage.txt
touch -d '2187-06-30 08:20:00' "$LAB/notes/page.txt"
touch -d '2186-02-19 10:30:00' "$LAB/bin/deck-report"
