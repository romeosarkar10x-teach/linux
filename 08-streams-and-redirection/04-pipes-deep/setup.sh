#!/usr/bin/env bash
# setup.sh -- seeds /labs/08-streams-and-redirection/04-pipes-deep
#
# THE ANSWER KEY. Students are told not to open this.
#
# Chapter 5 taught what a pipe does. This lesson is what a pipe IS:
#   - every stage is a separate process, started at the same time, in a subshell
#   - only fd 1 goes down the pipe; fd 2 goes past it
#   - the pipeline's exit status is the LAST stage's, unless pipefail; PIPESTATUS
#     has all of them
#   - a reader that exits early kills the writer with SIGPIPE (exit 141)
#   - output to a pipe is BLOCK buffered, to a terminal LINE buffered. This is
#     the fact that makes `tail -f | grep` look broken.
#
# Programs seeded:
#   bin/slowtick   prints a numbered line every 0.2s on fd 1, warning on fd 2
#   bin/noisy      interleaves fd1/fd2, exits 0
#   bin/failmid    prints, then exits 4
#   bin/countdown  writes 30 lines fast; used for SIGPIPE with `head -1`
#   bin/bufdemo    prints one line then sleeps, to show buffering at a tty vs pipe
#
# Data: data/readings.txt (60 lines), data/panels.csv (from ch7 shape, 24 rows)
#
# Idempotent: removes its own tree first, creates nothing outside LAB.
set -euo pipefail

LAB="/labs/08-streams-and-redirection/04-pipes-deep"
rm -rf "$LAB"
mkdir -p "$LAB"/{bin,data,notes,scratch}
cd "$LAB"

cat > bin/slowtick <<'OUTER'
#!/usr/bin/env bash
# slowtick [N] -- one line per 0.2s on fd 1, plus a note on fd 2 every 5th.
n=${1:-20}
for (( i=1; i<=n; i++ )); do
  echo "tick $i"
  if (( i % 5 == 0 )); then echo "slowtick: $i ticks" >&2; fi
  sleep 0.2
done
OUTER

cat > bin/noisy <<'OUTER'
#!/usr/bin/env bash
# noisy -- alternates streams. Exits 0.
for i in 1 2 3 4 5 6; do
  echo "out $i"
  echo "err $i" >&2
done
exit 0
OUTER

cat > bin/failmid <<'OUTER'
#!/usr/bin/env bash
# failmid -- three lines of output, then failure.
echo "reading p-a 41"
echo "reading p-b 40"
echo "failmid: bank B did not answer" >&2
echo "reading p-c 44"
exit 4
OUTER

cat > bin/countdown <<'OUTER'
#!/usr/bin/env bash
# countdown -- 30 lines as fast as it can, then a completion line on fd 2.
for i in $(seq 30 -1 1); do echo "line $i"; done
echo "countdown: finished all 30" >&2
exit 0
OUTER

cat > bin/bufdemo <<'OUTER'
#!/usr/bin/env bash
# bufdemo -- prints a line, waits 3s, prints another. Nothing else.
echo "first"
sleep 3
echo "second"
OUTER

chmod 755 bin/slowtick bin/noisy bin/failmid bin/countdown bin/bufdemo

seq 1 60 | while read -r i; do printf 'p-%02d %3d\n' "$i" $(( 40 + (i * 7) % 23 )); done \
  > data/readings.txt

{
  echo "panel,deck,reading,status"
  for i in $(seq 1 24); do
    printf 'p-%02d,%02d,%d,%s\n' "$i" $(( (i % 6) * 2 + 3 )) $(( 38 + (i*5) % 9 )) \
      "$( (( i % 7 == 0 )) && echo clamped || echo nominal )"
  done
} > data/panels.csv

cat > notes/pipes.txt <<'OUTER'
Pipes, past the first day
-------------------------

  a | b

is not "run a, then feed b". Both processes start at the same time. The kernel
gives them a buffer between them, `a` writes into it, `b` reads out of it, and
whichever one gets ahead is made to wait. That is the whole mechanism.

WHAT GOES DOWN THE PIPE

Only fd 1. Standard error is not redirected by `|` and goes wherever it was
already going -- usually your terminal, straight past the whole pipeline. To
include it:

  a 2>&1 | b        the portable spelling
  a |& b            bash shorthand for the same thing

EXIT STATUS

The pipeline's status is the LAST stage's, no matter what happened upstream.
`false | true` is 0. Two ways to see the rest:

  ${PIPESTATUS[@]}      array of every stage's status, valid only immediately after
  set -o pipefail       pipeline fails with the rightmost non-zero status

SUBSHELLS

Every stage runs in its own process, so a variable set in a stage is gone when
the stage exits. This is why

  cmd | while read -r l; do n=$((n+1)); done

leaves n at zero. Redirect the loop instead, or use process substitution.

SIGPIPE

If the reader exits while the writer is still writing, the writer gets SIGPIPE
and dies. `yes | head -1` terminates; it does not run forever. The writer's
status is 141 (128 + 13). This is normal and usually desirable.

BUFFERING -- the one that wastes afternoons

The C library picks a buffering mode by asking whether fd 1 is a terminal:

  terminal   line buffered   you see each line as it is produced
  pipe/file  block buffered  nothing appears until ~4-8KB has accumulated

So a command that prints happily on your screen can appear to produce nothing
at all once you put it in a pipeline. Nothing is broken and nothing is lost --
it is sitting in a buffer. `stdbuf -oL cmd | ...` forces line buffering on the
first stage; some tools have their own flag (`grep --line-buffered`, `sed -u`,
`awk` with fflush()). Note that bash's own `echo` writes immediately and is not
affected, which is why shell scripts hide the problem.

tee

  a | tee f | b     writes a's output to f AND passes it on
  a | tee -a f | b  append instead of truncate
  a | tee f1 f2     several files at once
  a | tee /dev/tty | b   keep a copy on the terminal

tee is how you inspect a pipeline without breaking it.
OUTER

cat > notes/page.txt <<'OUTER'
From: rhea
To: deck 05

Two things, and I do not think they are the same thing.

The panel walk script pipes its output into a filter and the filter never sees
the warnings. I checked the filter, it is fine.

Separately: when I watch a long-running check through a pipe I get nothing for
a long time and then a wall of text all at once. Running it on its own I get a
line at a time. Nobody has touched either script.
OUTER

printf 'Yours.\n' > scratch/README

find . -exec touch -h -d '2187-06-14 08:00:00' {} +

echo "seeded $LAB"
