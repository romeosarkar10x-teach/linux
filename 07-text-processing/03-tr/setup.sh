#!/usr/bin/env bash
# setup.sh -- seeds /labs/07-text-processing/03-tr
#
# Artifacts -> exercises:
#   data/mixed-case.txt   account names in inconsistent case -> tr 'A-Z' 'a-z',
#                         and the [:upper:]/[:lower:] classes. This is the file
#                         that fixes lesson 02 exercise 49.
#   data/roster-display.txt  the roster's display names, so the fold has something
#                         to be compared against
#   data/log-accounts.txt the account column of the access log, already cut
#   data/aligned.txt      columns padded with runs of spaces -> tr -s ' '
#   data/crlf.txt         CRLF line endings -> tr -d '\r', and what it looks
#                         like before you know that is what is wrong
#   data/ctrl.txt         embedded control characters -> tr -d '[:cntrl:]' and -c
#   data/prose.txt        the station note as prose -> tr -cs '[:alpha:]' '\n'
#                         for a word frequency table
#   data/digits.txt       identifiers with punctuation -> tr -d and tr -c
#   data/table.txt        tab separated -> tr '\t' ',' and why that is a bad idea
#   data/short-sets.txt   input for SET1 longer than SET2 -> padding rule
#   data/utf8.txt         a multi-byte character -> tr operates on BYTES
#   notes/rot13.txt       the note that motivates the rot13 exercise
#   scratch/              empty
#
# No sed, no awk. tr's whole point in this chapter is that it is not either of
# those: it maps and deletes CHARACTERS, has no patterns, and cannot read a file
# by name. Every exercise that wants a pattern is deferred to lesson 04.
set -euo pipefail

LAB=/labs/07-text-processing/03-tr
rm -rf "$LAB"
mkdir -p "$LAB"/{data,notes,scratch}
cd "$LAB"

printf '%s\n' Rhea rhea RHEA Cass CASS cass Vint vint Orla ORLA orla Bex bex \
              Ops-Bot ops-bot OPS-BOT Maintenance maintenance > data/mixed-case.txt

printf '%s\n' Rhea Cass Vint Orla Bex Ops-Bot Maintenance > data/roster-display.txt

# the account column of 2187-06-10, in log order, 600 lines
{
  for k in $(seq 1 412); do echo ops-bot; done
  for k in $(seq 1 96);  do echo rhea; done
  for k in $(seq 1 54);  do echo cass; done
  for k in $(seq 1 21);  do echo vint; done
  for k in $(seq 1 12);  do echo orla; done
  for k in $(seq 1 4);   do echo bex; done
  echo maintenance
} | shuf --random-source=<(yes kestrel) > data/log-accounts.txt

printf '%-10s%-10s%-10s%s\n' \
  account deck shift role \
  rhea deck-02 day systems \
  cass deck-01 day medical \
  vint deck-03 night cargo \
  > data/aligned.txt

printf 'deck-01\tsealed\r\ndeck-02\topen\r\ndeck-03\tsealed\r\ndeck-04\topen\r\n' > data/crlf.txt

# a line with a BEL, a form feed and a vertical tab buried in it
printf 'panel-a\aok\ndeck\f-02 sealed\npressure\v normal\nplain line\n' > data/ctrl.txt

cat > data/prose.txt <<'PROSE'
The station keeps three logs and reads none of them. A log that nobody reads
is not a record, it is a habit. The habit is cheap and the reading is not,
which is why the reading is what gets dropped first and why the log that
mattered is always the one nobody read.
PROSE

printf '%s\n' 'id-0041' 'id-0193' 'id-2187' 'ID-0007' 'id_0412' 'id.0096' > data/digits.txt

printf 'account\tdeck\trole\nrhea\tdeck-02\tsystems\ncass\tdeck-01\tmedical\nbex\tdeck-04\tgalley, night\n' > data/table.txt

printf '%s\n' abcdef ABCDEF a1b2c3 xyz > data/short-sets.txt

printf 'caf\xc3\xa9\nna\xc3\xafve\nplain\n' > data/utf8.txt

# stored rot13'd on purpose; the lesson decodes it
tr 'A-Za-z' 'N-ZA-Mn-za-m' > notes/rot13.txt <<'NOTE'
Nobody encrypts anything with rot13. It is not encryption; it survives one
guess and one command.

It stays in use for exactly one thing: hiding text from a reader who has not
decided to read it. Answers on a puzzle sheet, the punchline of a joke, a
spoiler in a message. The reader does the one command deliberately, which is
the point -- the barrier is a decision, not a secret.

If you find rot13 protecting something that matters, what you have found is
not a cipher. You have found somebody who believed it was one.
NOTE

find . -exec touch -h -d '2187-06-12 08:00:00' {} +
