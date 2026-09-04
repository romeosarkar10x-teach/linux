#!/bin/bash
# Lab setup for 12/07 — set -euo pipefail, quoting, trap, mktemp, shellcheck
set -euo pipefail

LAB="/labs/12-shell-scripting/07-robust-scripts"

rm -rf "$LAB"
mkdir -p "$LAB"/{bin,data,notes,scratch}

# ---------------------------------------------------------------- data
printf 'alpha 12\nbeta 7\ngamma 19\n' > "$LAB/data/readings.txt"
printf 'header\nrow one\nrow two\n' > "$LAB/data/report.txt"
: > "$LAB/data/empty.txt"
mkdir -p "$LAB/data/reports"
printf 'old report\n' > "$LAB/data/reports/2186-01.txt"

# ---------------------------------------------------------------- bin
cat > "$LAB/bin/unsafe" <<'EOF'
#!/usr/bin/env bash
# No options, no quoting. Every line here is a lesson.
dir=$1
out=/tmp/summary.txt
cd $dir
count=$(ls | wc -l)
echo "files: $count" > $out
echo wrote $out
EOF

cat > "$LAB/bin/safe" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

usage() { echo "usage: safe DIR" >&2; exit 64; }
[ $# -eq 1 ] || usage
dir=$1
[ -d "$dir" ] || { echo "not a directory: $dir" >&2; exit 66; }

out=$(mktemp) || { echo "mktemp failed" >&2; exit 74; }
trap 'rm -f "$out"' EXIT

count=$(find "$dir" -maxdepth 1 -mindepth 1 | wc -l)
printf 'files: %s\n' "$count" > "$out"
cat "$out"
EOF

cat > "$LAB/bin/e-in-if" <<'EOF'
#!/usr/bin/env bash
# set -e is switched OFF inside a command used as a condition.
set -e
check() {
    false
    echo "check: still running after false"
    return 0
}
if check; then
    echo "condition was true"
fi
echo "script reached the end"
EOF

cat > "$LAB/bin/e-limits" <<'EOF'
#!/usr/bin/env bash
set -e
echo "1. a false in a condition does not stop us:"
false && echo "  not printed"
echo "2. ... and neither does the left of ||:"
false || echo "  printed"
echo "3. but a bare false does. Nothing below this line runs."
false
echo "4. never printed"
EOF

cat > "$LAB/bin/pipefail-demo" <<'EOF'
#!/usr/bin/env bash
echo -n "without pipefail: "; false | true; echo "$?"
set -o pipefail
echo -n "with pipefail:    "; false | true; echo "$?"
echo -n "yes | head -1:    "; yes | head -1 >/dev/null; echo "$?"
EOF

cat > "$LAB/bin/u-demo" <<'EOF'
#!/usr/bin/env bash
set -u
echo "with a default: ${missing:-default}"
echo "without one:"
echo "$missing"
echo "never printed"
EOF

cat > "$LAB/bin/tempfile-bad" <<'EOF'
#!/usr/bin/env bash
# rhea, 2186-07-14. Writes a report, then compresses it.
tmp=/tmp/report.$$
echo "building report" > "$tmp"
cat /labs/12-shell-scripting/07-robust-scripts/data/report.txt >> "$tmp"
if [ ! -s "$tmp" ]; then
    echo "empty report, aborting" >&2
    exit 1
fi
wc -l < "$tmp"
rm -f "$tmp"
EOF

cat > "$LAB/bin/tempfile-good" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

tmp=$(mktemp) || exit 74
trap 'rm -f "$tmp"' EXIT

echo "building report" > "$tmp"
cat /labs/12-shell-scripting/07-robust-scripts/data/report.txt >> "$tmp"
[ -s "$tmp" ] || { echo "empty report, aborting" >&2; exit 1; }
wc -l < "$tmp"
EOF

cat > "$LAB/bin/trap-tour" <<'EOF'
#!/usr/bin/env bash
trap 'echo "EXIT trap ran"' EXIT
trap 'echo "ERR trap: line $LINENO"' ERR
trap 'echo "INT: cleaning up"; exit 130' INT

echo "body"
false
echo "still here (ERR does not stop anything on its own)"
exit 3
EOF

cat > "$LAB/bin/lint-me" <<'EOF'
#!/bin/bash
# Written in a hurry. shellcheck has opinions about every line.
FILES=`ls *.txt`
for f in $FILES
do
  if [ $f != "" ]; then
    cat $f | grep row | wc -l
  fi
done
cd /tmp
rm -rf $TMPDIR/*
EOF

chmod 755 "$LAB"/bin/*

# ---------------------------------------------------------------- notes
cat > "$LAB/notes/options.txt" <<'EOF'
set -euo pipefail
-----------------
    set -e            exit if a command fails
    set -u            error on an unset variable
    set -o pipefail   a pipeline fails if ANY stage fails
    set -x            print each command as it runs (debugging)

Put them on line 2, after the shebang. Together, in one line:
    set -euo pipefail

WHAT -e DOES NOT DO. It is off for:
  * anything in an if/while/until CONDITION -- including deep inside a
    function called from there
  * the left-hand side of && or ||
  * any command whose status is inverted with !
  * every stage of a pipeline except the last (that is what pipefail is for)

So `if check; then` runs `check` with -e disabled for its whole body.
That is not a bug; it is the only way `if` could work. But it means a
function you wrote to be strict is not strict when tested.

-u errors on an UNSET name. An empty one is fine. ${v:-default} and
${v:?message} are the ways to say what you meant.

pipefail makes `yes | head -1` fail with 141: head exits, yes gets
SIGPIPE, 128+13. Correct behaviour, unwelcome status. Guard the pipelines
where you expect it.

None of this replaces checking things yourself. It is a floor.
EOF

cat > "$LAB/notes/quoting.txt" <<'EOF'
quoting discipline
------------------
Quote EVERY expansion. "$var" "$1" "$@" "$(cmd)" "${arr[@]}".

The three places people forget:
    [ $x = y ]           -> [ "$x" = y ]        (12/03)
    for f in $(ls)       -> for f in *          (12/04)
    cd $dir              -> cd "$dir"

Not quoted, deliberately, and commented when you do it:
    $flags               when you MEAN to split a list of options
                         (better: use an array)

Two more habits:
    cd "$dir" || exit    a cd that fails leaves you somewhere else,
                         and every following line runs in the wrong place
    rm -f -- "$f"        -- ends option parsing; a file named -rf is a file
EOF

cat > "$LAB/notes/trap-and-temp.txt" <<'EOF'
trap and temporary files
------------------------
    trap 'commands' EXIT     runs on any exit, including error exits
    trap 'commands' ERR      runs when a command fails (does not stop it)
    trap 'commands' INT TERM Ctrl-C and kill

EXIT is the one you want for cleanup. It runs after `exit 3` and keeps
the 3. Single-quote the trap body so $variables are expanded when the
trap RUNS, not when it is set.

A trap set inside a function is the script's trap, not the function's.

Temporary files:
    tmp=$(mktemp)            creates it, 600, unique name, prints the path
    dir=$(mktemp -d)         a directory
    trap 'rm -rf "$dir"' EXIT   set this on the NEXT line. Always.

Never /tmp/name.$$ -- the PID is predictable, the file may exist, and
somebody else may own it. mktemp exists precisely because that pattern
was a security bug for twenty years.
EOF

cat > "$LAB/notes/shellcheck.txt" <<'EOF'
shellcheck
----------
    shellcheck script          check it
    shellcheck -s bash script  when there is no shebang
    shellcheck -f gcc script   one line per finding

Every finding has a number (SC2086) and a wiki page explaining it. Read
the page before you argue with it.

To silence one check on one line, and only when you can say why:
    # shellcheck disable=SC2086  # word splitting is intended here
Never disable globally. A file full of disables is a file nobody reads.

Ones you will meet this week:
    SC2086  unquoted expansion -- word splitting and globbing
    SC2046  unquoted $(...)
    SC2006  backticks; use $( )
    SC2164  cd without || exit
    SC2035  a glob that could produce a leading dash; use ./*
    SC2126  grep | wc -l; use grep -c
    SC2155  local x=$(cmd) masks the status   (12/05)
    SC2115  rm -rf "$x/" where $x may be empty
EOF

cat > "$LAB/notes/page.txt" <<'EOF'
station log — ops-bot
2187-07-05 04:02

  Standing request from crew, unresolved.

  "Scripts in ops/ have no consistent error handling. Several exit 0 on
   failure. Requesting a review pass."

  Filed 2186-11-02. Assigned to: unassigned.
  Status: open, 246 days.
EOF

# ---------------------------------------------------------------- times
find "$LAB" -exec touch -h -d '2187-07-05 09:00:00' {} +
find "$LAB/notes" -type f -exec touch -h -d '2186-08-02 12:00:00' {} +
touch -h -d '2187-07-05 04:02:00' "$LAB/notes/page.txt"
touch -h -d '2186-07-14 15:30:00' "$LAB/bin/tempfile-bad"
