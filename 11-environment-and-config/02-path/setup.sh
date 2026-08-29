#!/usr/bin/env bash
#
# setup.sh -- seeds /labs/11-environment-and-config/02-path
#
# THE ANSWER KEY. Students are told not to open this.
#
# Teaches: PATH as an ordered list, first match wins, which -a vs type -a vs
# command -v, builtins and aliases taking precedence over files, the hash
# cache and how it goes stale, the empty-PATH-entry hazard, and shadowing --
# the mechanism the chapter's incident is built on.
#
# Two directories hold commands of the same name. Which one wins is decided
# entirely by the order the student puts them in, and station-status prints
# which copy it is, so the answer is never ambiguous.
#
# broken/station-status is deliberately non-executable. Measured behaviour:
# bash SKIPS it and runs a later copy if one exists (rc 0); with no executable
# copy anywhere it reports "Permission denied" and rc 126, not 127. And the
# five lookup tools disagree about it -- `type` names it, `type -a` says not
# found, `type -t` says file, `command -v` prints the path, `which -a` prints
# nothing. Three different answers from five commands, all correct.
#
# Idempotent: removes its own tree first, creates nothing outside LAB.
set -euo pipefail

LAB="/labs/11-environment-and-config/02-path"
rm -rf "$LAB"
mkdir -p "$LAB"/{bin,override,broken,notes,scratch}
cd "$LAB"

# --- bin/ : the station copies --------------------------------------------

cat > bin/station-status <<'EOF'
#!/usr/bin/env bash
echo "station-status v1  (from bin/)"
echo "reactor : nominal"
echo "decks   : 12 of 12 pressurised"
EOF

cat > bin/deck-report <<'EOF'
#!/usr/bin/env bash
echo "deck-report v1  (from bin/)  -- reads /var/lib/kestrel/decks"
EOF

# --- override/ : somebody else's copies, same names -------------------------

cat > override/station-status <<'EOF'
#!/usr/bin/env bash
echo "station-status v2  (from override/)"
echo "reactor : nominal"
echo "decks   : 12 of 12 pressurised"
echo "note    : this copy prints one extra line. That is the only difference."
EOF

cat > override/deck-report <<'EOF'
#!/usr/bin/env bash
echo "deck-report v2  (from override/)  -- reads /srv/decks"
EOF

cat > override/ls <<'EOF'
#!/usr/bin/env bash
# A wrapper. It is not hostile and it does not hide anything -- it says what
# it is and then runs the real one. A hostile version would do neither, and
# would be exactly as easy to install.
echo "[wrapped ls]" >&2
exec /usr/bin/ls "$@"
EOF

chmod 755 bin/* override/*

# --- broken/ : found, and still not run -------------------------------------

cat > broken/station-status <<'EOF'
#!/usr/bin/env bash
echo "station-status v3  (from broken/)  -- you should never see this line"
EOF
chmod 644 broken/station-status

cat > broken/README <<'EOF'
One file, one missing bit. Put this directory first on your PATH and run
station-status -- twice: once with bin/ also on the PATH, and once without.

The two results are different, and neither is the one most people predict.
Then ask five tools where station-status is. They do not all agree, and the
one that disagrees loudest is the one people reach for first.
EOF

# --- notes ------------------------------------------------------------------

cat > notes/path.txt <<'EOF'
PATH: the list that decides what a command name means
-----------------------------------------------------

PATH is one environment variable holding directories separated by colons,
searched LEFT TO RIGHT. The first executable file with a matching name wins
and the search stops. There is no scoring, no "best" match, no preference for
the newest -- only order.

  echo "$PATH"
  echo "$PATH" | tr : '\n'        one per line, in search order
  echo "$PATH" | tr : '\n' | nl   numbered, which is how to talk about it

Yours, on this station:

  /opt/kestrel/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

Seven entries, and two of them are the same directory: /bin is a symlink to
usr/bin and /sbin to usr/sbin. Historical, harmless, and the reason a command
can appear three times in `which -a` output while being two files.

Not everything you type is looked up in PATH. The order bash actually uses:

  1. aliases
  2. shell functions
  3. shell builtins            (cd, echo, export, type, hash ...)
  4. the hash table            (remembered results of earlier searches)
  5. PATH, left to right

`cd` is not in any directory on your PATH. It cannot be: a program cannot
change its parent's working directory, for the reason lesson 01 gave you.

The tools that answer "what would run":

  type NAME       what bash would do with this name. Knows about all five
                  levels above. This is the one to trust.
  type -a NAME    every candidate, in order, alias and builtin included
  type -t NAME    one word: alias, function, builtin, file, keyword
  command -v NAME just the path (or the alias text). Script-friendly, and it
                  exits nonzero if there is nothing.
  which NAME      searches PATH only. Knows nothing about aliases, functions
                  or builtins, so it can confidently give you the wrong
                  answer. `which cd` finds nothing on many systems.
  which -a NAME   every match in PATH, in order -- useful, unlike which

Prefer `type`. Use `which -a` when you specifically want the files and not
bash's opinion.
EOF

cat > notes/lookup.txt <<'EOF'
Editing PATH, and the two ways to get it wrong
----------------------------------------------

Adding a directory is string surgery on a variable, and the position you
choose is a decision about trust:

  export PATH="$HOME/bin:$PATH"     yours wins over the system's
  export PATH="$PATH:$HOME/bin"     the system wins over yours

Quote it, and keep the "$PATH" -- a bare `export PATH=$HOME/bin` replaces the
whole list, and the next command you type will not be found.

Two hazards.

**The empty entry.** An empty element means the current directory. All of
these contain one:

  PATH=":/usr/bin"        leading
  PATH="/usr/bin:"        trailing
  PATH="/usr/bin::/bin"   in the middle

So a file called `ls` in whatever directory you happen to have cd'd into can
become the `ls` you run. `.` written out has the same effect and the same
problem. Never put either in PATH -- not for convenience, not temporarily.
Type `./thing` when you mean the thing that is here.

**The hash table.** Bash remembers where it found a command so it does not
search again:

  hash            show what is remembered, with hit counts
  hash -t NAME    where bash thinks NAME lives
  hash -r         forget everything
  hash -d NAME    forget one

If a program moves, or you install a copy earlier in PATH, bash keeps using
the old location -- and if the old file is gone you get

  bash: /old/path/thing: No such file or directory

which names a path you did not type and is the clearest possible fingerprint
of a stale hash entry. `hash -r` fixes it.

Bash flushes the whole table whenever PATH is ASSIGNED -- even to the same
value it already had -- so installing a copy earlier in PATH is safe as long
as you edited PATH to do it. The table goes stale in the other case: the file
moves or is deleted and PATH never changes. That is the one to recognise, and
its error message names a path you did not type.
EOF

cat > notes/page.txt <<'EOF'
From: rhea
To: cadet
Re: two people, one command

cass ran station-status on the bridge terminal and got three lines. I ran it
in the same directory, thirty seconds later, and got four. Neither of us is
lying and neither terminal is broken.

Work out how that happens. Then tell me what you would have to be able to see
to say which of us got the right answer -- and notice that "the right answer"
is doing a lot of work in that sentence.

I am not asking you to change anybody's configuration. I am asking whether
you could detect it.
EOF

printf 'Yours. A good place for a personal bin/ if you want one.\n' > scratch/README

find . -exec touch -d '2187-06-20 09:00:00' {} +
touch -d '2186-08-02 11:20:00' notes/path.txt notes/lookup.txt
touch -d '2187-06-20 07:55:00' notes/page.txt

echo "seeded $LAB"
