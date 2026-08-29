#!/usr/bin/env bash
#
# setup.sh -- seeds /labs/11-environment-and-config/01-env-vars
#
# THE ANSWER KEY. Students are told not to open this.
#
# Teaches: shell variable vs environment variable, export, env, printenv,
# unset, export -n, inheritance into children, and the fact that a child can
# never write back to its parent.
#
# The lab's centrepiece is bin/deck-report: it works when the student types
# the assignment and the command on one line, and fails when they type them
# on two, which is the whole "it works when I type it" complaint in a form
# they can reproduce on demand.
#
# Idempotent: removes its own tree first, creates nothing outside LAB.
set -euo pipefail

LAB="/labs/11-environment-and-config/01-env-vars"
rm -rf "$LAB"
mkdir -p "$LAB"/{bin,notes,scratch,logs}
cd "$LAB"

# --- bin/ : small programs that read the environment and nothing else -------

cat > bin/deck-report <<'EOF'
#!/usr/bin/env bash
# Prints a deck summary. Reads its configuration from the environment,
# because that is how the station's tooling has always been wired.
: "${DECK:?DECK is not set in my environment}"
: "${CYCLE:=41}"
echo "deck   : $DECK"
echo "cycle  : $CYCLE"
echo "reader : $(id -un)"
echo "source : ${REPORT_SOURCE:-/var/lib/kestrel/decks}"
EOF

cat > bin/show-inherited <<'EOF'
#!/usr/bin/env bash
# Prints only what was handed to it. Everything here crossed a process
# boundary to arrive; anything missing never left the shell that ran me.
for name in DECK CYCLE REPORT_SOURCE STATION EDITOR; do
    if printenv "$name" >/dev/null; then
        printf '%-14s %s\n' "$name" "$(printenv "$name")"
    else
        printf '%-14s (not in my environment)\n' "$name"
    fi
done
EOF

cat > bin/count-env <<'EOF'
#!/usr/bin/env bash
# How big is the environment I was handed?
env | wc -l
EOF

cat > bin/set-station <<'EOF'
#!/usr/bin/env bash
# Sets STATION and prints it. Run this and then look for STATION in your
# own shell. The result is the point of the exercise, not a bug.
export STATION=kestrel-7
echo "STATION is now $STATION"
EOF

chmod 755 bin/*

# --- logs/ : evidence that the wiring has failed before ---------------------

cat > logs/nightly.log <<'EOF'
2187-06-14 02:00:01  deck-report starting
2187-06-14 02:00:01  deck   : 05
2187-06-14 02:00:01  cycle  : 41
2187-06-14 02:00:01  source : /var/lib/kestrel/decks
2187-06-15 02:00:01  deck-report starting
2187-06-15 02:00:01  deck   : 05
2187-06-15 02:00:01  cycle  : 41
2187-06-15 02:00:01  source : /var/lib/kestrel/decks
2187-06-16 02:00:01  deck-report starting
2187-06-16 02:00:01  /labs/bin/deck-report: line 4: DECK: DECK is not set in my environment
2187-06-17 02:00:01  deck-report starting
2187-06-17 02:00:01  /labs/bin/deck-report: line 4: DECK: DECK is not set in my environment
2187-06-18 02:00:01  deck-report starting
2187-06-18 02:00:01  /labs/bin/deck-report: line 4: DECK: DECK is not set in my environment
EOF

cat > logs/README <<'EOF'
Three nights of nightly.log are missing their report. The command did not
change and neither did the script. Something about the environment it was
handed did.

You are not expected to fix the nightly job in this lesson. You are expected
to be able to say, in one sentence, what kind of thing went wrong.
EOF

# --- notes ------------------------------------------------------------------

cat > notes/variables.txt <<'EOF'
Shell variables and environment variables
-----------------------------------------

They look identical when you set them and they are not the same thing.

  DECK=05           a SHELL variable. Lives in this shell. Goes no further.
  export DECK=05    an ENVIRONMENT variable. Copied into every child process
                    this shell starts from now on.
  export DECK       promote an existing shell variable without retyping it.

No spaces around the `=`. `DECK = 05` is the command `DECK` with two
arguments, and bash will tell you so.

Seeing them:

  set          every shell variable, every function. Long. Includes the
               exported ones, because exported variables are still shell
               variables.
  set -o posix; set    the same list without the function bodies.
  env          only the exported ones -- and specifically, only the ones
               `env` itself was handed.
  printenv     the same list; `printenv NAME` prints one.
  export -p    the exported ones, printed as commands that would recreate
               them.

The difference between `set` and `env` is not cosmetic. `set` asks your shell
what it knows. `env` is a separate program reporting what it received. That
is why `env` can answer a question about inheritance and `set` cannot.

Reading one:

  echo "$DECK"        prints nothing whether DECK is empty or unset
  printenv DECK       exits 1 if it is not in the environment. Testable.
  echo "${DECK-none}"   substitute if UNSET
  echo "${DECK:-none}"  substitute if unset OR empty
  echo "${DECK:?why}"   fail, loudly, with your message, if unset or empty

That last one is how a program insists. It is not error handling bolted on;
it is one line and it fires before anything else happens.

Removing one:

  unset DECK        gone entirely, shell variable and environment both
  export -n DECK    demoted. Still a shell variable here, no longer given
                    to children. This is not the same as unset and the
                    difference is visible in exactly one place: a child.

Inheritance runs one way, downward, and it is a COPY:

  - a child gets a snapshot of the environment at the moment it starts
  - changing it in the child changes the child's copy
  - the parent never sees the change, and there is no flag that makes it
  - a variable exported after the child started does not reach that child

There is no mechanism in any Unix shell for a child process to set a variable
in its parent. If somebody tells you otherwise they are describing `source`,
which is not running a child at all.

For one command only:

  DECK=05 bin/deck-report      DECK exists for that command and nothing else

The assignment is a prefix, not a separate statement. Afterwards DECK is not
set in your shell -- not empty, not set.

  env -i CMD          run CMD with an empty environment
  env -u DECK CMD     run CMD with DECK removed
  env DECK=05 CMD     the long spelling of the prefix above
EOF

cat > notes/inheritance.txt <<'EOF'
Where a variable stops
----------------------

Four ways to run something, and only two of them share your variables.

  ./script          a NEW shell. Gets your exported variables. Its own
                    variables die with it.
  bash script       identical, and it does not need the execute bit.
  source script     no new process. Runs in THIS shell. Its assignments
  . script          are your assignments. This is why login configuration
                    is sourced and never executed.
  ( commands )      a subshell: a child that is a copy of this shell. It
                    sees everything, including unexported variables, and
                    still cannot write back.

The subshell is the one that surprises people. `( DECK=99 )` sees your
DECK, changes it, and the change vanishes at the closing parenthesis --
even though you never started a new program.

A useful test with no ambiguity in it:

  DECK=05                 bash -c 'echo "[$DECK]"'    -> []
  export DECK=05          bash -c 'echo "[$DECK]"'    -> [05]

Note the single quotes. Double quotes would have your own shell expand
$DECK before bash ever saw it, and you would prove nothing.

SHLVL counts how deep you are. It is incremented by each shell that starts,
so it is the one variable that is different in the child on purpose.
EOF

cat > notes/page.txt <<'EOF'
From: rhea
To: cadet
Re: the nightly deck report

It ran for eleven months. It has failed the last three nights with a message
about a variable. Nobody edited the script -- I checked the mtime before I
wrote this, and you should check it too rather than believing me.

I can run it by hand and it works. That is the part I want you to explain,
because "it works when I type it" is the sentence that precedes every wasted
afternoon I have had on this station.

Do not fix the nightly job. It is not in this lab and you would be guessing.
Tell me what CLASS of thing broke.
EOF

printf 'Yours. Set anything you like in here.\n' > scratch/README

find . -exec touch -d '2187-06-18 09:00:00' {} +
touch -d '2186-08-02 11:15:00' notes/variables.txt notes/inheritance.txt
touch -d '2187-06-18 07:40:00' notes/page.txt
touch -d '2186-07-19 04:31:00' bin/deck-report

echo "seeded $LAB"
