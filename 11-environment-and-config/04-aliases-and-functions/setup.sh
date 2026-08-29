#!/usr/bin/env bash
# Seeds 11/04 -- aliases and functions.
#
# Measured before writing:
#   alias defined and used on the SAME line does not expand (the line is parsed
#     whole before the alias exists)                     -> exercises 6-9
#   alias beats function; \name and `command name` bypass it differently
#   an alias used inside a function body is baked in at DEFINITION time
#   a trailing space in an alias makes the NEXT word alias-expandable
#   `command f` finds neither the function nor an alias, and reports not found
#   local scoping, return status, export -f, declare -f/-F
set -euo pipefail

LAB="/labs/11-environment-and-config/04-aliases-and-functions"

rm -rf "$LAB"
mkdir -p "$LAB"/{bin,rc,notes,scratch}

# --- a real program, so that a shell function has something to shadow --------
cat > "$LAB/bin/deck-report" <<'EOF'
#!/usr/bin/env bash
# The station's real deck report. Unchanged since 2185-11-02.
terse=no
if [ "${1:-}" = "--terse" ]; then
    terse=yes
    shift
fi
echo "deck   : ${1:-all}"
echo "status : nominal"
[ "$terse" = yes ] || echo "source : /var/lib/kestrel/decks"
EOF
chmod 755 "$LAB/bin/deck-report"

# --- rc/aliases.sh: harmless, ordinary, and one landmine --------------------
cat > "$LAB/rc/aliases.sh" <<'EOF'
# Source this. Nothing here is hostile; one line is a trap anyway.

alias ll='ls -l'
alias la='ls -la'
alias ..='cd ..'

# The trailing space is not a typo. It is the difference between this alias
# chaining into the next word and not. Exercise 24.
alias please='sudo '

# This one is the landmine, and it is the most-copied line on the network:
# it silently changes what a command MEANS for everyone who sources this file,
# and `which deck-report` will never mention it.
alias deck-report='deck-report --terse'
EOF

# --- rc/functions.sh: the same jobs, done as functions ----------------------
cat > "$LAB/rc/functions.sh" <<'EOF'
# Source this. Everything here is a function.

# Takes arguments properly. An alias cannot do this -- it has no $1.
mkcd() {
    if [ $# -ne 1 ]; then
        echo "usage: mkcd <dir>" >&2
        return 2
    fi
    mkdir -p -- "$1" && cd -- "$1"
}

# `local` keeps the variable out of the caller's shell. Delete the word and
# this function starts editing its caller. Exercise 33.
deck_summary() {
    local deck count
    deck=${1:-all}
    count=$(deck-report "$deck" | wc -l)
    echo "$deck: $count lines"
}

# A function that wraps a program of the same name. The `command` builtin is
# what stops it calling itself forever. Exercise 40.
deck-report() {
    echo "[wrapped]" >&2
    command deck-report "$@"
}
EOF

# --- rc/broken.sh: three plausible mistakes ---------------------------------
cat > "$LAB/rc/broken.sh" <<'EOF'
# Three things people write. Each is wrong in a different way, and each looks
# fine. Do not fix them until you can say what each one does.

# 1. An alias that wants an argument.
alias deck='deck-report $1'

# 2. A wrapper that forgot `command`.
report() { report --all; }

# 3. A function that leaks. No `local`, and the name is a common one.
count() { i=$(deck-report | wc -l); echo "$i"; }
EOF

# --- notes ------------------------------------------------------------------
cat > "$LAB/notes/aliases.txt" <<'EOF'
Aliases
=======

An alias is a text substitution. Bash replaces the first word of a command with
the alias's text, before it decides what to run. That is all it is, and every
surprising thing about aliases follows from it.

    alias ll='ls -l'

Rules that catch people
-----------------------
* Only the FIRST word of a command is checked. `echo ll` does not expand.
* Expansion happens when the line is READ. An alias defined and used on the
  same line does not expand -- bash had already parsed the line.
* Aliases are off in non-interactive shells (shopt expand_aliases). A script
  that sources your aliases file gets nothing usable. Use a function.
* An alias has no arguments. There is no $1. Whatever you type after the name
  is simply left where it is, after the replacement text.
* A trailing space in the replacement text makes bash check the NEXT word for
  an alias too. That is the whole mechanism behind `alias sudo='sudo '`.

Getting past one
----------------
    \ll          a backslash on the name suppresses alias expansion
    'll'         so does quoting it
    command ll   bypasses aliases AND functions, and runs the program

Undoing one
-----------
    unalias ll
    unalias -a   all of them
EOF

cat > "$LAB/notes/functions.txt" <<'EOF'
Functions
=========

    name() { body; }

A function is a named piece of shell, run in your current shell. Not a child
process -- so it can change your directory, set your variables, and alter your
shell's state, which is exactly why `cd` could never be a program.

What it has that an alias does not
----------------------------------
* Arguments: $1, $2, $@, $#. Quote them: "$@", not $@.
* An exit status, set with `return N` (not `exit`, which would end your shell).
* `local`, which keeps a variable inside the function. Without it, a function
  assigning to `count` or `i` silently overwrites the caller's variable of the
  same name.
* It works in non-interactive shells, so scripts can use it.

Resolution order, again
-----------------------
    alias -> function -> builtin -> hash -> PATH

A function therefore shadows a program of the same name completely -- more
completely than any PATH change, because PATH is never consulted. `which` looks
only at PATH, so it will confidently name a file that is not what runs.
`type` sees the function. This is the same disagreement as lesson 02, with a
different cause.

Wrapping without infinite recursion
-----------------------------------
    deck-report() { command deck-report "$@"; }

`command` skips aliases and functions and goes to the builtin/PATH stage. Leave
it out and the function calls itself until bash gives up.

Inspecting and removing
-----------------------
    declare -F          list function names
    declare -F name     is it a function?
    declare -f name     print its body
    type name           what will actually run
    unset -f name       remove it (unset alone removes a variable)
    export -f name      pass it to child bash shells
EOF

cat > "$LAB/notes/page.txt" <<'EOF'
    ops-bot -- 2187-06-24 03:12

    AUTOMATED. DO NOT REPLY.

    Discrepancy, deck report line counts.

    Interactive submissions, cycle 41: 2 lines.
    Scheduled submissions, cycle 41: 3 lines.
    Source file unchanged since 2185-11-02.
    Both submissions accepted. Both recorded as authoritative.

    No fault detected. Report is informational.
EOF

cat > "$LAB/scratch/README" <<'EOF'
Yours.

You will define aliases and functions in your own shell in this lesson. That is
fine and it is temporary: they live in one shell and die with it, which is
lesson 03's point arriving from the other direction. Nothing here asks you to
edit a startup file.
EOF

# --- backdating -------------------------------------------------------------
find "$LAB" -exec touch -d '2187-06-24 09:00:00' {} +
touch -d '2186-08-02 11:30:00' "$LAB"/notes/aliases.txt "$LAB"/notes/functions.txt
touch -d '2187-06-24 03:12:00' "$LAB"/notes/page.txt
# ops-bot's claim is checkable: the program really has not changed since 2185.
touch -d '2185-11-02 14:20:00' "$LAB"/bin/deck-report
