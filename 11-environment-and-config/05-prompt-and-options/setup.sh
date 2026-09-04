#!/usr/bin/env bash
# Seeds 11/05 -- the prompt, and the switches that change what the shell means.
#
# Measured in the container before writing:
#   set -u on an unbound variable exits a SCRIPT with rc 127 (not 1); in an
#     interactive shell it prints the error and the shell stays alive
#   ${NOPE:-fallback} is not "unbound" -- set -u is happy with it
#   set -e is not triggered by a failing command in an `if` condition, and not
#     by `false | true` unless pipefail is also on
#   noclobber: "cannot overwrite existing file", rc 1; >| overrides it
#   failglob: "no match: *.zzz", rc 1; nullglob makes the pattern vanish
#   dotglob adds .hidden; nocaseglob adds B.TXT; globstar makes **/ recurse
#   shopt -s extglob on the SAME -c string as the pattern is a syntax error --
#     the line is parsed before the option is set (11/04's lesson, again)
#   extglob is already ON in an interactive shell here, and OFF in a script
#   PROMPT_COMMAND runs before every prompt, including the one right after you
#     set it; \! in PS1 is the history number
#   ~/.bashrc sets HISTSIZE=1000 on line 19 and HISTSIZE=100000 on line 122
set -euo pipefail

LAB="/labs/11-environment-and-config/05-prompt-and-options"

rm -rf "$LAB"
mkdir -p "$LAB"/{rc,scripts,glob/deck/e,data,notes,scratch}

# --- prompts: four candidates, one of them subtly broken --------------------
cat > "$LAB/rc/prompts.sh" <<'EOF'
# Four prompts the crew has actually used. Source this file, then set PS1 to
# one of them by hand:  PS1="$PROMPT_PLAIN"
#
# Do not source this and expect a prompt to change by itself. It only defines
# variables. Choosing is your job.

# 1. What you already have, minus the chroot part.
PROMPT_PLAIN='\u@\h:\w\$ '

# 2. Working directory only, plus the history number.
PROMPT_SHORT='[\W \!]\$ '

# 3. Colour. This one is written correctly: every non-printing run is wrapped
#    in \[ ... \] so readline knows it takes up no screen columns.
PROMPT_COLOUR='\[\e[1;32m\]\u@\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]\$ '

# 4. The same colours, written the way rhea wrote them in her page. The escape
#    sequences are identical. The \[ \] are missing. Nothing about this prompt
#    is wrong until you type a long command and then press Home.
PROMPT_BROKEN='\e[1;32m\u@\h\e[0m:\e[1;34m\w\e[0m\$ '

# 5. A prompt that runs a command every time it is drawn.
PROMPT_COUNT='[$(ls -1 | wc -l) files]\$ '
EOF

# --- options: a file that turns on things worth arguing about ---------------
cat > "$LAB/rc/options.sh" <<'EOF'
# Source this in a SCRATCH shell. It changes how the shell behaves, not how it
# looks. Every line here is defensible and at least two of them will bite you.

set -o noclobber        # > refuses to overwrite an existing file
shopt -s globstar       # ** crosses directory boundaries
shopt -s dotglob        # * matches dotfiles too
shopt -s nocaseglob     # *.txt matches B.TXT
shopt -s cdspell        # cd /ect/init.d silently becomes /etc/init.d
EOF

# --- scripts: the audit script from ops-bot's page, and its neighbours -------
cat > "$LAB/scripts/deck-audit.sh" <<'EOF'
#!/usr/bin/env bash
# Station deck audit. Writes a count to stdout. Exits 0 when it works.
#
# It also exits 0 when it does not work. That is the whole lesson.

count=$(cat /var/lib/kestrel/decks | wc -l)
echo "decks audited: $count"
EOF
chmod 755 "$LAB/scripts/deck-audit.sh"

cat > "$LAB/scripts/deck-audit-strict.sh" <<'EOF'
#!/usr/bin/env bash
# The same audit, with the three switches an engineer would add.
set -euo pipefail

count=$(cat /var/lib/kestrel/decks | wc -l)
echo "decks audited: $count"
EOF
chmod 755 "$LAB/scripts/deck-audit-strict.sh"

cat > "$LAB/scripts/greet.sh" <<'EOF'
#!/usr/bin/env bash
# Run it with no argument. Then run it under `set -u`. Then decide which of the
# two behaviours you would rather ship.

echo "greetings, $OPERATOR"
echo "shift: ${SHIFT_NAME:-unassigned}"
echo "done"
EOF
chmod 755 "$LAB/scripts/greet.sh"

cat > "$LAB/scripts/checks.sh" <<'EOF'
#!/usr/bin/env bash
# Four ways for a command to fail. set -e reacts to exactly two of them.
set -e

if false; then
    echo "unreachable"
fi
echo "checkpoint 1"

false || echo "handled"
echo "checkpoint 2"

false | true
echo "checkpoint 3"

false
echo "checkpoint 4"
EOF
chmod 755 "$LAB/scripts/checks.sh"

# --- the data the audit used to read ---------------------------------------
# /var/lib/kestrel/decks does not exist on this station. It did once. The deck
# list lives here now, and nobody told the script.
for n in $(seq -w 1 12); do
    echo "deck-$n nominal"
done > "$LAB/data/decks"

# --- glob: the fixtures the option flags act on -----------------------------
: > "$LAB/glob/report.txt"
: > "$LAB/glob/REPORT.TXT"
: > "$LAB/glob/.hidden.txt"
: > "$LAB/glob/notes.log"
: > "$LAB/glob/deck/e/deep.txt"
: > "$LAB/glob/deck/mid.txt"

# --- notes ------------------------------------------------------------------
cat > "$LAB/notes/prompt.txt" <<'EOF'
    PS1 -- the primary prompt
    ---------------------------------------------------------------

    PS1 is a string. The shell expands it every time it is about to ask you for
    a command. The backslash escapes are the shell's, not echo's:

        \u  user            \h  hostname to the first dot     \H  full hostname
        \w  working dir     \W  basename of the working dir
        \$  # for root, $ for everyone else
        \!  history number  \#  command number   \t  time
        \n  newline         \\  a literal backslash

    Anything else in PS1 is literal text, including the output of $( ).

    PS2 is the continuation prompt ("> ") -- you see it when you press Enter
    with a quote still open. PS4 is the prefix xtrace puts on every traced
    line ("+ "). PROMPT_COMMAND is not a prompt at all: it is a command the
    shell runs BEFORE drawing the prompt.

    Colour is escape sequences: \e[1;32m turns text bold green, \e[0m turns
    everything off. They print nothing, but readline still counts characters
    to know where your cursor is -- so every non-printing run must be wrapped
    in \[ and \]. Get that wrong and short commands look fine, long ones
    overwrite themselves.
EOF

cat > "$LAB/notes/options.txt" <<'EOF'
    Two lists of switches, and they are not the same list
    ---------------------------------------------------------------

        set -o          POSIX shell options.   set -u  / set +u  / set -o nounset
        shopt           bash's own options.    shopt -s x / shopt -u x / shopt x

    Read that again: for `set`, minus turns a thing ON. For `shopt`, -s sets and
    -u unsets. They are opposite letters for opposite meanings and nobody is
    coming to fix it.

    The ones worth knowing:

        set -e   errexit    stop the script at the first command that fails
        set -u   nounset    an unset variable is an error, not an empty string
        set -o pipefail     a pipeline fails if ANY stage failed, not just the last
        set -C   noclobber  > will not overwrite an existing file
        set -x   xtrace     print each command before running it
        set -v   verbose    print each line as it is read

        shopt -s globstar   **/ descends into subdirectories
        shopt -s dotglob    * matches .hidden files
        shopt -s nullglob   a pattern that matches nothing becomes nothing
        shopt -s failglob   a pattern that matches nothing is an error
        shopt -s extglob    !(x) ?(x) *(x) +(x) @(x) patterns
        shopt -s nocaseglob globs stop caring about case

    `set -euo pipefail` is the line at the top of a script that means "I would
    rather this stop than continue while wrong".
EOF

cat > "$LAB/notes/history.txt" <<'EOF'
    History
    ---------------------------------------------------------------

    HISTSIZE       commands kept in memory
    HISTFILESIZE   commands kept in the file
    HISTFILE       which file (default ~/.bash_history)
    HISTCONTROL    ignoredups / ignorespace / ignoreboth / erasedups
    HISTIGNORE     colon-separated patterns never recorded
    HISTTIMEFORMAT if set, history prints a timestamp

    shopt -s histappend appends on exit instead of overwriting -- which matters
    the moment you have two shells open, because without it the last one to
    exit wins and the other's history is gone.

    A command typed with a leading space is not recorded when HISTCONTROL
    contains ignorespace. This is how people keep secrets out of the file, and
    it is also how people lose the command they needed to remember.

    Your ~/.bashrc on this station sets HISTSIZE twice. Find both lines and
    work out which one is in force.
EOF

cat > "$LAB/notes/page.txt" <<'EOF'
    ops-bot -- 2187-06-26 02:40

    AUTOMATED. DO NOT REPLY.

    Scheduled task deck-audit completed. Exit status 0.
    Output: "decks audited: 0".
    Previous 40 cycles: "decks audited: 12".

    Source path: /var/lib/kestrel/decks
    Path exists: no.

    Exit status 0 recorded as success.
    Trend flag not raised: task is configured to alert on non-zero status only.
EOF

cat > "$LAB/notes/page-2.txt" <<'EOF'
    rhea -- 2187-06-26 07:55

    My prompt eats itself. Not always. Only when the command is long enough to
    wrap, and only after I press Home to go back and fix a typo -- then the
    line redraws over the prompt and I cannot tell what I am editing.

    Cass says it is the terminal. I copied my PS1 into rc/prompts.sh next to a
    version that works so somebody can tell me what the difference is, because
    the escape sequences are character for character identical and I have
    compared them four times.

    While I am here: the deck audit reports zero and the scheduler calls that
    a success. I do not think those two complaints are related. I would like
    someone to check whether I am wrong about that.
EOF

cat > "$LAB/scratch/README" <<'EOF'
Yours.

Several exercises in this lesson turn on options that make the shell refuse to
do things -- noclobber, failglob, errexit. Turn them on here, in a shell you
are willing to lose, and turn them off again with the opposite letter. None of
this lesson asks you to edit a startup file. Chapter 11 lesson 06 does.
EOF

# --- backdating -------------------------------------------------------------
find "$LAB" -exec touch -d '2187-06-26 09:00:00' {} +
touch -d '2186-08-02 11:35:00' "$LAB"/notes/prompt.txt "$LAB"/notes/options.txt "$LAB"/notes/history.txt
touch -d '2187-06-26 02:40:00' "$LAB"/notes/page.txt
touch -d '2187-06-26 07:55:00' "$LAB"/notes/page-2.txt
# The audit script has not been edited since it was written. The data it reads
# is what changed -- and the script cannot see the difference.
touch -d '2186-04-18 10:05:00' "$LAB"/scripts/deck-audit.sh
