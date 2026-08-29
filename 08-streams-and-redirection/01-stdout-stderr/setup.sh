#!/usr/bin/env bash
# setup.sh -- seeds /labs/08-streams-and-redirection/01-stdout-stderr
#
# THE ANSWER KEY. Students are told not to open this.
#
# Teaching goal: a process has three streams open before it runs a line of its
# own code. fd 0 stdin, fd 1 stdout, fd 2 stderr. They are separate destinations
# that HAPPEN to point at the same terminal, which is why a beginner never
# notices they are separate until the day one of them is redirected.
#
# The lab ships four small programs, all readable, none magic:
#   bin/panelcheck   report on fd 1, complaints on fd 2, exit 0.   <- the chapter
#   bin/twovoices    strict alternation, 1 2 1 2 1 2, to prove interleaving
#   bin/askdeck      reads fd 0, so `echo | askdeck` and `askdeck < file` work
#   bin/fdreport     prints where each of its own three fds points (/proc/self/fd)
#
# NOTE for anyone changing panelcheck: it writes 10 lines to fd 1 and 6 to fd 2.
# Both counts are measured, not intended, and exercises 12, 19 and 33 use them.
# Exit status is 0 ON PURPOSE and is the seed of the chapter's incident.
#
# Idempotent: removes its own tree first, creates nothing outside LAB.
set -euo pipefail

LAB="/labs/08-streams-and-redirection/01-stdout-stderr"
rm -rf "$LAB"
mkdir -p "$LAB"/{bin,data,notes,scratch}
cd "$LAB"

########## the programs ##########

cat > bin/panelcheck <<'EOF'
#!/usr/bin/env bash
# panelcheck -- deck 05 panel diagnostic
# Report goes to stdout. Anything the operator should look at goes to stderr.
echo "panel diagnostic, deck 05"
echo "----------------------------------------"
for p in a b c d e f; do
  reading=$(( 40 + (RANDOM % 3) ))
  case "$p" in
    b|e) echo "panel p-$p: reading out of band, clamped to 40" >&2 ;;
  esac
  printf 'panel p-%s   %2d   ok\n' "$p" "$reading"
done
echo "----------------------------------------"
echo "6 panels checked"
echo "clamp applied 2 times this run" >&2
echo "see /var/tmp/panelcheck.d for details" >&2
echo "written by dorn, 2186-04" >&2
echo "(this warning has printed on every run since)" >&2
exit 0
EOF

cat > bin/twovoices <<'EOF'
#!/usr/bin/env bash
# twovoices -- alternates strictly between the two output streams.
for i in 1 2 3 4 5; do
  echo "out $i"
  echo "err $i" >&2
done
EOF

cat > bin/askdeck <<'EOF'
#!/usr/bin/env bash
# askdeck -- reads one line from stdin and answers on stdout.
echo "which deck? " >&2
read -r deck || { echo "askdeck: no input on stdin" >&2; exit 3; }
case "$deck" in
  0[1-9]|1[0-2]) echo "deck $deck: crew accessible" ;;
  *)             echo "askdeck: not a deck: $deck" >&2; exit 4 ;;
esac
EOF

cat > bin/fdreport <<'EOF'
#!/usr/bin/env bash
# fdreport -- says where this process's own three standard fds point.
# NOTE: /proc/$$/fd, not /proc/self/fd. $$ is this script. `self` inside a
# command substitution would be the subshell, whose fd 1 is the substitution
# pipe -- it would report a pipe no matter what you did on the command line.
for fd in 0 1 2; do
  if [ -e "/proc/$$/fd/$fd" ]; then
    printf 'fd %s -> ' "$fd"
    readlink "/proc/$$/fd/$fd"
  else
    printf 'fd %s -> CLOSED\n' "$fd"
  fi
done
EOF

chmod 755 bin/panelcheck bin/twovoices bin/askdeck bin/fdreport

########## data ##########

printf '%s\n' 03 05 07 11 > data/decks.txt
printf '%s\n' 03 05 99 11 > data/decks-bad.txt

cat > data/panels.txt <<'EOF'
p-a  nominal
p-b  clamped
p-c  nominal
p-d  nominal
p-e  clamped
p-f  nominal
EOF

########## notes ##########

cat > notes/streams.txt <<'EOF'
Three streams, opened for you
-----------------------------

Every process on this station starts with three file descriptors already open.
It does not open them. The shell that launched it did.

  fd 0   stdin    where the program reads from
  fd 1   stdout   where the program writes its RESULT
  fd 2   stderr   where the program writes everything else

"Everything else" is the important part. stderr is not an error channel. It is
the not-the-answer channel: warnings, progress, prompts, diagnostics, and the
sentence "3 files copied" all belong on fd 2, because none of them are the
thing the next program in a pipeline wants to read.

The test an author should apply, and most do not:

  If somebody pipes my output into another program, is this line something
  that program should have to parse? If no, it goes to fd 2.

At a terminal both streams land on your screen, in the order they were
written, with nothing marking which is which. That is the whole reason this
lesson exists. You cannot see the difference until you separate them, and by
then it is usually a year later and somebody is asking why nobody noticed.
EOF

cat > notes/dorn-readme.txt <<'EOF'
deck 05 tooling -- notes left for whoever is next

panelcheck is mine. It reports on stdout and complains on stderr, which is the
right way round, and I want that written down somewhere because the first
version had it backwards and the summariser choked on the warnings.

It exits 0 even when it clamps. That was deliberate: a clamp is not a failure,
it is a measurement outside the band being brought back inside it, and I did
not want the shift script to page anybody at 04:00 over one panel.

If the clamping ever becomes interesting, read stderr. It has been saying the
same thing for a while.

  -- dorn
EOF

printf 'Yours. Copy things here before you experiment on them.\n' > scratch/README

find . -exec touch -h -d '2187-06-14 08:00:00' {} +
touch -d '2186-04-02 11:20:00' bin/panelcheck notes/dorn-readme.txt

echo "seeded $LAB"
