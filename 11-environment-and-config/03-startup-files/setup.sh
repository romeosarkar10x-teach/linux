#!/usr/bin/env bash
# Seeds 11/03 -- startup files.
#
# The lab is three fake home directories. The student points bash at one with
# HOME=... bash -l and watches which files it reads. Everything is measurable
# and nothing here touches the student's own dotfiles -- that is deliberate:
# the one home directory you must not experiment in is your own.
#
# Measured in the container before writing:
#   login shell        -> /etc/profile (which sources /etc/profile.d/*.sh and,
#                         when interactive, /etc/bash.bashrc), then the FIRST
#                         of ~/.bash_profile, ~/.bash_login, ~/.profile.
#   interactive nonlogin -> /etc/bash.bashrc then ~/.bashrc.
#   non-interactive    -> nothing at all, except $BASH_ENV if set.
#   ~/.bash_logout runs only on login-shell exit, and not for `bash -lc cmd`.
set -euo pipefail

LAB="/labs/11-environment-and-config/03-startup-files"

rm -rf "$LAB"
mkdir -p "$LAB"/{homes,notes,scratch}
mkdir -p "$LAB"/homes/{full,station,split}

# --- homes/full: all four candidates, each announcing itself ----------------
# Nothing sources anything. This home exists to answer one question: when all
# four are present, how many does a login shell read?
cat > "$LAB/homes/full/.bash_profile" <<'EOF'
echo "read: ~/.bash_profile"
EOF
cat > "$LAB/homes/full/.bash_login" <<'EOF'
echo "read: ~/.bash_login"
EOF
cat > "$LAB/homes/full/.profile" <<'EOF'
echo "read: ~/.profile"
EOF
cat > "$LAB/homes/full/.bashrc" <<'EOF'
echo "read: ~/.bashrc"
EOF
cat > "$LAB/homes/full/.bash_logout" <<'EOF'
echo "read: ~/.bash_logout"
EOF

# --- homes/station: the arrangement the real station uses -------------------
# No .bash_profile, no .bash_login. ~/.profile exists and sources ~/.bashrc.
# This is why a login shell here still gets the aliases: not because bash reads
# .bashrc for login shells -- it does not -- but because one file asks for it.
cat > "$LAB/homes/station/.profile" <<'EOF'
# Read by login shells only, and only because no .bash_profile or .bash_login
# exists to take priority over it.
echo "read: ~/.profile"

# bash does not read ~/.bashrc for a login shell. If you want your aliases and
# functions in a login shell, some file has to ask for them. This is that line.
if [ -n "$BASH_VERSION" ] && [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
fi

# A directory that does not exist yet changes nothing. Create it and log in
# again, and PATH is different. Nothing "reloaded" -- the file simply ran again.
if [ -d "$HOME/bin" ]; then
    PATH="$HOME/bin:$PATH"
fi

export STATION_ROLE=cadet
EOF
cat > "$LAB/homes/station/.bashrc" <<'EOF'
echo "read: ~/.bashrc"
alias decks='deck-report --all'
station-status() { echo "all decks nominal"; }
EOF

# --- homes/split: the arrangement that produces the complaint ---------------
# A .bash_profile exists, so ~/.profile is never read -- and .bash_profile does
# not source .bashrc. Aliases and functions therefore exist in every shell
# EXCEPT the login shell. This is the mechanism behind the page in 11/02:
# two people, same command, different output, neither terminal broken.
cat > "$LAB/homes/split/.bash_profile" <<'EOF'
echo "read: ~/.bash_profile"
export STATION_ROLE=engineer
EOF
cat > "$LAB/homes/split/.profile" <<'EOF'
echo "read: ~/.profile"
echo "if you are seeing this line, something took priority away from .bash_profile"
EOF
cat > "$LAB/homes/split/.bashrc" <<'EOF'
echo "read: ~/.bashrc"
alias decks='deck-report --all'
EOF

# --- notes ------------------------------------------------------------------
cat > "$LAB/notes/startup.txt" <<'EOF'
Which files bash reads, and when
================================

Bash reads different files depending on two independent questions. Not one
question -- two, and they cross:

  is it a LOGIN shell?          (did something pass -l, or --login, or was it
                                 started as the first shell of a session?)
  is it INTERACTIVE?            (is it reading commands from a terminal, or
                                 running a script?)

Login shell
-----------
  /etc/profile
      ...which on this system loops over /etc/profile.d/*.sh, and which also
      sources /etc/bash.bashrc when the shell is interactive. So the system-wide
      bashrc DOES run for a login shell. The user's ~/.bashrc does not.
  then the FIRST of these that exists, and only the first:
      ~/.bash_profile
      ~/.bash_login
      ~/.profile

That word "first" is the one people lose money on. If ~/.bash_profile exists,
~/.profile is never read. Not merged. Not read.

Interactive, not a login shell
------------------------------
  /etc/bash.bashrc
  ~/.bashrc

Neither login nor interactive (a script, a pipeline, `bash -c`)
---------------------------------------------------------------
  nothing.
  ...unless BASH_ENV is set, in which case bash reads the file it names. This
  is the only startup file a script reads, and almost nobody knows it exists.

On exit
-------
  ~/.bash_logout, for login shells only.

The consequence
---------------
Your aliases live in ~/.bashrc. Login shells do not read ~/.bashrc. If your
login shells have your aliases anyway, it is because one of the three login
files asked for them, by hand, in a line somebody wrote. Look at that line
before you assume it is there.
EOF

cat > "$LAB/notes/order.txt" <<'EOF'
Reading the chain instead of guessing at it
===========================================

Put a marker line in a file and start a shell. That is the whole technique.

    echo 'echo "read: ~/.bashrc"' >> ~/.bashrc

Then start each kind of shell and see which markers appear:

    bash -l -c true          login, not interactive
    bash -i -c true          interactive, not login
    bash -c true             neither
    echo exit | bash -li     login and interactive, exits cleanly

You do not have to do this in your own home directory, and you should not.
HOME is just a variable. Point bash at a directory you own and can ruin:

    HOME=/somewhere/else bash -l -c true

Switches worth knowing
----------------------
    --noprofile      skip /etc/profile and all three login files
    --norc           skip /etc/bash.bashrc and ~/.bashrc
    --rcfile FILE    read FILE instead of ~/.bashrc

Long options must come before the short ones. `bash --noprofile -l` works;
`bash -l --noprofile` is an error, and the error blames `--`, which is not
where the problem is.

Two rules that will save you an evening
---------------------------------------
1. A startup file is a script that runs on every login. If it can hang, your
   logins hang. If it can fail, and you wrote `set -e`, your logins fail.
2. Nothing "reloads" configuration. The file runs again, in a new shell, and
   whatever it did last time is gone unless it did it again. `source ~/.bashrc`
   runs it a second time in the shell you already have -- which is not the same
   as a clean start, because the first run's effects are still there.
EOF

cat > "$LAB/notes/page.txt" <<'EOF'
    rhea -- 2187-06-22 08:10

    Following up on the thing I asked you last week, because it happened again
    and this time it was mine.

    I have a shell function called station-status. It works. I have used it for
    a year. This morning I opened a terminal, ran station-status, and got the
    program in /opt, not my function. Same account, same machine, same word.

    I have not changed anything. I know everyone says that. In my case I can
    prove it, because the file has not been written to since last August and
    you can check that yourself.

    What I want to know is not how to fix it. I can fix it. I want to know what
    is DIFFERENT about the terminal I opened this morning, because until I know
    that I am going to keep being surprised, and I would rather be wrong on
    purpose than right by accident.
EOF

cat > "$LAB/scratch/README" <<'EOF'
Yours. Make homes here, break them, delete them.

Nothing in this lesson asks you to edit your own ~/.bashrc, and the validator
checks that you did not. The habit of testing configuration somewhere other
than the account you need to stay logged into is most of the lesson.
EOF

chmod 644 "$LAB"/homes/*/.* 2>/dev/null || true

# --- backdating -------------------------------------------------------------
find "$LAB" -exec touch -d '2187-06-22 09:00:00' {} +
touch -d '2186-08-02 11:25:00' "$LAB"/notes/startup.txt "$LAB"/notes/order.txt
touch -d '2187-06-22 08:10:00' "$LAB"/notes/page.txt
# rhea's claim in the page is checkable: her function's file really has not been
# touched since last August. The thing that changed was not the file.
touch -d '2186-08-14 16:02:00' "$LAB"/homes/station/.bashrc
