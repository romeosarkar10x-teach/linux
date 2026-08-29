#!/usr/bin/env bash
# setup.sh -- seeds /labs/08-streams-and-redirection/05-exit-codes-and-chaining
#
# THE ANSWER KEY. Students are told not to open this.
#
# Subject: a command's exit status is its answer, and && || are how you use it.
#   0 = success, 1..255 = failure of some kind
#   126 found-but-not-executable, 127 not found, 128+N killed by signal N
#   $? is the LAST command's status and is replaced by every command, including [
#   && and || are LEFT ASSOCIATIVE and equal precedence -- a && b || c is not
#     an if/else, and c runs when b fails too
#   ! inverts. `!` in front of a pipeline flips only the final status.
#   a; b runs b unconditionally. Newline is the same as ;.
#
# The lab's bug: bin/checkbank exits 0 no matter what happens, because its last
# command is an echo. bin/deckcheck wraps it with `checkbank && echo ok` and so
# has reported ok for every bank on the station since 2186 -- including bank B,
# which has been printing a failure line on fd 2 the whole time.
# bin/checkbank-fixed is the same script with the status propagated.
#
# Red herring: logs/deckcheck.log records the WRAPPER's exit status (always 0),
# so the log is a perfect record of nothing.
#
# Idempotent: removes its own tree first, creates nothing outside LAB.
set -euo pipefail

LAB="/labs/08-streams-and-redirection/05-exit-codes-and-chaining"
rm -rf "$LAB"
mkdir -p "$LAB"/{bin,data,logs,notes,scratch}
cd "$LAB"

cat > bin/checkbank <<'OUTER'
#!/usr/bin/env bash
# checkbank BANK -- checks one sampler bank. Prints a line either way.
bank=${1:?usage: checkbank BANK}
case "$bank" in
  A|C|D)
    echo "bank $bank: 6 panels, all responding"
    ;;
  B)
    echo "checkbank: bank $bank did not answer" >&2
    echo "bank $bank: check incomplete"
    ;;
  *)
    echo "checkbank: no such bank: $bank" >&2
    exit 2
    ;;
esac
echo "checkbank: done"
OUTER

cat > bin/checkbank-fixed <<'OUTER'
#!/usr/bin/env bash
# checkbank-fixed BANK -- same checks, status preserved.
bank=${1:?usage: checkbank-fixed BANK}
rc=0
case "$bank" in
  A|C|D)
    echo "bank $bank: 6 panels, all responding"
    ;;
  B)
    echo "checkbank-fixed: bank $bank did not answer" >&2
    echo "bank $bank: check incomplete"
    rc=1
    ;;
  *)
    echo "checkbank-fixed: no such bank: $bank" >&2
    exit 2
    ;;
esac
echo "checkbank-fixed: done"
exit "$rc"
OUTER

cat > bin/deckcheck <<'OUTER'
#!/usr/bin/env bash
# deckcheck -- walks every bank and appends a line to logs/deckcheck.log.
cd "$(dirname "$0")/.."
STATION_DATE=2187-06-14
for b in A B C D; do
  if bin/checkbank "$b" >/dev/null 2>&1; then
    printf '%s bank %s ok\n' "$STATION_DATE" "$b" >> logs/deckcheck.log
  else
    printf '%s bank %s FAILED\n' "$STATION_DATE" "$b" >> logs/deckcheck.log
  fi
done
echo "deckcheck: 4 banks walked"
OUTER

cat > bin/rc <<'OUTER'
#!/usr/bin/env bash
# rc N -- exits with status N. Prints nothing.
exit "${1:?usage: rc N}"
OUTER

cat > bin/slowfail <<'OUTER'
#!/usr/bin/env bash
# slowfail -- prints, waits, fails.
echo "working"
sleep 1
echo "slowfail: gave up" >&2
exit 5
OUTER

cat > bin/notexec <<'OUTER'
#!/usr/bin/env bash
echo "you should not be able to run me directly"
OUTER

chmod 755 bin/checkbank bin/checkbank-fixed bin/deckcheck bin/rc bin/slowfail
chmod 644 bin/notexec

printf 'p-%02d %3d\n' 1 41 > data/readings.txt
for i in $(seq 2 12); do printf 'p-%02d %3d\n' "$i" $(( 38 + (i * 5) % 9 )); done >> data/readings.txt

# A log that has said "ok" every day for months.
for d in 09 10 11 12 13; do
  for b in A B C D; do printf '2187-06-%s bank %s ok\n' "$d" "$b"; done
done > logs/deckcheck.log

cat > notes/status.txt <<'OUTER'
Exit status
-----------

Every command that finishes leaves a number behind. 0 means it did what it was
asked. Anything from 1 to 255 means it did not, and the number is the command's
own business -- read its manual.

  $?    the status of the LAST command to finish

$? is replaced by every command, including `[`, `echo` and `true`. Read it once,
into a variable, or you will be reading the status of the thing you read it with.

Numbers with meanings the shell assigns:

  126   found, but could not be executed (not executable, or a directory)
  127   command not found
  128+N killed by signal N. 130 = Ctrl-C (SIGINT, 2). 141 = SIGPIPE (13).
  0-125 the command's own choice

Conventions worth knowing: grep 0 = matched, 1 = no match, 2 = error. diff 0 =
same, 1 = differ, 2 = trouble. Many tools use 1 for "the answer is no" and 2 for
"I could not answer", which are very different things.

CHAINING

  a && b     run b only if a succeeded
  a || b     run b only if a failed
  a ; b      run b either way
  ! a        invert a's status

&& and || have EQUAL precedence and group LEFT TO RIGHT. So

  a && b || c

is not if/else. It is ((a && b) || c): c runs if a fails, and also if a succeeds
but b fails. If you want if/else, write if/else. Grouping with { } changes it:

  a && { b; c; }      both b and c only if a succeeded
  { a; b; } && c      c if b succeeded -- a's status is discarded

A FUNCTION OR SCRIPT RETURNS THE STATUS OF ITS LAST COMMAND

unless you say otherwise with `exit N` / `return N`. This is the single most
common way a status is lost: a script ends with an `echo`, and `echo` always
succeeds, so the script always succeeds.
OUTER

cat > notes/page.txt <<'OUTER'
From: cass
To: deck 05

The nightly bank walk has said "ok" for every bank every night since I started
keeping the log, and the log is in logs/deckcheck.log if you want to see it.

Bank B has been on the maintenance list for over a year. Two different people
have told me bank B does not answer. The walk says ok.

I do not think the walk is lying. I think it is not being asked the question.
OUTER

printf 'Yours.\n' > scratch/README

find . -exec touch -h -d '2187-06-14 08:00:00' {} +
touch -d '2186-04-02 11:20:00' bin/checkbank bin/deckcheck
touch -d '2187-06-13 23:05:00' logs/deckcheck.log

echo "seeded $LAB"
