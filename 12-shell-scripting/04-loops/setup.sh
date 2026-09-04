#!/usr/bin/env bash
# Lab setup — 12/04 loops
set -euo pipefail

LAB="/labs/12-shell-scripting/04-loops"
rm -rf "$LAB"
mkdir -p "$LAB"/{bin,decks,manifests,notes,scratch}

# --- deck files, one with a space in the name -------------------------------
cd "$LAB/decks"
for d in alpha beta gamma delta; do
    seq -w 1 5 | sed "s/^/$d-/; s/$/ nominal/" > "$d.log"
done
seq -w 1 3 | sed 's/^/hold-/; s/$/ nominal/' > "cargo hold.log"
printf 'epsilon-01 FAULT\nepsilon-02 nominal\n' > epsilon.log
cd - >/dev/null

# --- manifests: text to read line by line -----------------------------------
cat > "$LAB/manifests/decks.txt" <<'TXT'
alpha.log
beta.log
cargo hold.log
gamma.log
delta.log
epsilon.log
TXT

# a manifest with the awkward cases, and no trailing newline on the last line
printf '%s\n' \
    '  leading and trailing   ' \
    'back\slash stays' \
    'tab	separated' > "$LAB/manifests/awkward.txt"
printf 'no-trailing-newline' >> "$LAB/manifests/awkward.txt"

cat > "$LAB/manifests/counts.txt" <<'TXT'
alpha 5
beta 5
gamma 5
delta 5
epsilon 2
TXT

# --- scripts ----------------------------------------------------------------
cat > "$LAB/bin/count-decks-glob" <<'SH'
#!/usr/bin/env bash
# Loops over the glob directly. Boring, and correct.
cd /labs/12-shell-scripting/04-loops/decks || exit 66
for f in *.log; do
    printf '%s: %s\n' "$f" "$(wc -l < "$f")"
done
SH

cat > "$LAB/bin/count-decks-ls" <<'SH'
#!/usr/bin/env bash
# rhea's earlier version. Same job, one habit borrowed from another language.
cd /labs/12-shell-scripting/04-loops/decks || exit 66
for f in $(ls *.log); do
    printf '%s: %s\n' "$f" "$(wc -l < "$f")"
done
SH

cat > "$LAB/bin/read-manifest" <<'SH'
#!/usr/bin/env bash
# Reads a manifest line by line. Three ways, so you can see what each one eats.
M=/labs/12-shell-scripting/04-loops/manifests/awkward.txt
echo "--- read"
while read line;            do echo "  <$line>"; done < "$M"
echo "--- read -r"
while read -r line;         do echo "  <$line>"; done < "$M"
echo "--- IFS= read -r"
while IFS= read -r line;    do echo "  <$line>"; done < "$M"
SH

cat > "$LAB/bin/tally" <<'SH'
#!/usr/bin/env bash
# Counts faults across the deck logs. Reports a total. The total is wrong and
# the script is not obviously wrong, which is the exercise.
cd /labs/12-shell-scripting/04-loops/decks || exit 66
faults=0
grep -l FAULT *.log | while read -r f; do
    faults=$((faults + 1))
done
echo "decks with faults: $faults"
SH

cat > "$LAB/bin/first-fault" <<'SH'
#!/usr/bin/env bash
# Stops at the first fault it finds. Demonstrates break; also demonstrates
# what a loop's exit status is when you leave early.
cd /labs/12-shell-scripting/04-loops/decks || exit 66
for f in *.log; do
    if grep -q FAULT "$f"; then
        echo "first fault: $f"
        break
    fi
done
SH

chmod 755 "$LAB"/bin/*

# --- notes ------------------------------------------------------------------
cat > "$LAB/notes/for.txt" <<'TXT'
for NAME in WORDS; do ... done

WORDS is a word list, produced by the same expansions as any command line:
globs, brace expansion, variables, command substitution. The loop itself does
no splitting -- the shell did that before the loop started.

    for f in *.log            one iteration per file. Spaces are safe.
    for f in $(ls *.log)      ls prints names joined by newlines; the shell
                              then splits that text on whitespace. "cargo
                              hold.log" becomes two words that are not files.
    for x in {1..5}           brace expansion, done before anything else
    for ((i=0; i<5; i++))     C-style, arithmetic, bash only
    for f in "$@"             the arguments, correctly

Never loop over `ls`. There is no flag that makes it safe; the damage happens
after ls has printed, in the shell.

A glob that matches nothing expands to ITSELF, so `for f in nomatch*` runs once
with f set to the literal `nomatch*`. `shopt -s nullglob` makes it run zero
times instead (11/05).
TXT

cat > "$LAB/notes/while-read.txt" <<'TXT'
The line that reads files correctly:

    while IFS= read -r line; do ... done < file

Three parts, three separate jobs:
  IFS=    empty for this command only. Without it, read strips leading and
          trailing whitespace from the line.
  -r      do not treat backslash as an escape. Without it, back\slash becomes
          backslash and a line ending in \ swallows the next one.
  < file  redirect ONCE, on the loop. Not `cat file |`.

And the fourth thing nobody mentions: `read` returns false at end of file,
which means a final line with no newline after it is read into the variable
AND reported as failure -- so the loop body never runs for it. If your input
might lack a trailing newline:

    while IFS= read -r line || [ -n "$line" ]; do
TXT

cat > "$LAB/notes/subshell.txt" <<'TXT'
Each stage of a pipeline runs in its own process.

    n=0
    printf '%s\n' a b c | while read -r x; do n=$((n+1)); done
    echo "$n"        ->  0

The loop counted correctly. It counted in a child process, and the child is
gone. Same rule as sourcing versus executing (12/01), same rule as exporting
(11/01): a child cannot change its parent.

Fixes, in order of preference:
    while ... done < <(command)      process substitution; loop stays in shell
    while ... done < file            no pipeline at all
    n=$(command | wc -l)             let the pipeline produce the answer

This is the single most common shell bug that produces a plausible number.
TXT

cat > "$LAB/notes/page.txt" <<'TXT'
ops-bot -- 2187-07-02 05:30

Automated notice. Fault tally executed. Result: "decks with faults: 0".
Exit status 0. Deck epsilon flagged FAULT at 04:58 by deck sensor. Tally does
not reflect sensor. No action required by tally.
TXT

find "$LAB" -exec touch -h -d '2187-07-02 09:00:00' {} +
touch -d '2186-08-02 12:00:00' "$LAB"/notes/for.txt "$LAB"/notes/while-read.txt "$LAB"/notes/subshell.txt
touch -d '2187-07-02 05:30:00' "$LAB/notes/page.txt"
touch -d '2186-03-11 09:15:00' "$LAB/bin/count-decks-ls" "$LAB/bin/tally"
