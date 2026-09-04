# Tutor notes — 11/06 Incident 10

Guide with questions. Never hand over the mechanism.

## The shape of it

A directory that is present, readable and unmodified, and one account whose
shell removes its name from every glob and from a bare `ls`. Two lines, in a
file three levels down a sourcing chain, in a place everything about which says
"generated, do not read". Nothing about permissions, nothing about deletion.

The chapter's whole argument arrives here: configuration is a decision about
what you get to see, and nobody checks it.

## Stuck points, roughly in order

- **They start by looking at the archive.** Good instinct, wrong tree — but let
  them finish, because exercises 1–4 are how they earn the right to say
  "nothing was deleted" as a fact rather than a hope. Only intervene if they are
  still in `archive/` after ten minutes: *what have you proven, and what does it
  rule out?*
- **They cannot get into the account.** Point at lesson 03, not at the answer:
  *what does a login shell use to find its startup files?*
- **Counting instead of diffing.** cass's mistake, repeated. Ask them to put
  both lists in files.
- **`grep GLOBIGNORE .bashrc` finds nothing, so they conclude it is not there.**
  This is the first cliff. Ask what `.bashrc` does on the line that mentions
  `.config`. A single-file grep tests one hypothesis; they need the recursive
  one, including dot-directories.
- **They find one mechanism and stop — the real cliff.** Almost everyone finds
  `GLOBIGNORE` (or the alias) and declares victory, and `verify-repair` tells
  them loudly which half they missed. Do not pre-empt that: the checker is a
  better teacher here than you are. Afterwards, ask *why two?* The answer —
  that a bare `ls` involves no glob at all, and a glob involves no alias — is
  the most valuable thing in the lesson.
- **They want to delete the two lines.** Ask them to read the file's first
  comment aloud, then ask what happens on the next upgrade.
- **They edit `env.sh` anyway** and the checksum rejects them. `kestrel reset
  11/06` and no drama; they keep everything they learned. Ask what the checksum
  is standing in for (an upgrade that overwrites it).
- **`unalias ls` errors in a shell where it was never set.** They will notice
  a startup file printing errors. Let them fix it with `2>/dev/null` rather than
  telling them.
- **Stage 4: they give the date from the comment.** The rejection says what to
  do. If they still hunt for the date in the notes, ask: *which of those two is
  written by a person?*

## Red herrings

- `EDITOR`, `LESS` and `TOOLCHAIN` in `env.sh` are ordinary and do nothing.
- The `HISTSIZE`/`histappend` block in `.bashrc` is real config and irrelevant.
- `notes/toolchain.txt` reads like a policy document. It is, and its last
  paragraph is the actual finding of the whole incident.
- `archive/05-globbing/README` ends with "remember this in about ten minutes",
  which is a joke and also a hint. Do not underline it.

## What not to say

Trace 11 is a trace. The file's ownership is an artefact and the student may
read it; **you do not narrate who wrote it**, and you do not use the word
sabotage first. If a student says "someone put this here deliberately", agree
that the evidence supports it and ask what the evidence actually is (a date
that contradicts the file's own comment, and a filter that hides exactly one
thing). Then stop.

If a student notices *which* archive section it is, note it and move on. Do not
confirm and do not deny.

## Integrity checks

    md5sum homes/dorn/.config/kestrel/env.sh   -> 423edca9f8d10d158b52dbb51727c871
    stat -c '%y' homes/dorn/.config/kestrel/env.sh -> 2187-05-19 02:41:00
    find archive -type d | wc -l               -> 6 (archive + five sections)

    kestrel reset 11/06
