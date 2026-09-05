# Chapter 15 — Final Capstone: The Kestrel Breach

> "You have the accounts. That is not the same as having the people."

## Incident briefing

Everything in this course has been preparation for five days of work. There is
nothing new to learn here — no command in this chapter that an earlier chapter
did not teach you — and that is the point. The chapter asks whether you can
run an investigation with the tools you already have, and whether you can stop
where the evidence stops.

Deck 3's strain summariser has been reporting figures that the deck's own raw
samples do not support. The summariser was changed once, in October 2186, and
then edited again over six days in May 2187 by two different sets of hands. A
nightly run log numbers its records and is missing six of them. A report signed
off in May contains a peak, a mean, and an exceedance count that match the
summariser's clamped output exactly, and match the raw data not at all.

It goes in order. Lesson 01 is the briefing and the rules of engagement: what
you may touch, what you must not, and what it means to source a claim. Lesson
02 is triage — who is in the system, what is running, what is open, and the
difference between an account and a person. Lesson 03 is forensics: fourteen
artefacts, three timestamps each, and the clustering that makes two sets of
hands visible without anyone saying so. Lesson 04 is remediation, in the only
order that works — close, fix, stop, restore, prove — and the discovery that
one of the five faults never did what it looks like it did. Lesson 05 is the
report, a four-stage chain, and an extension to the tool you shipped in
chapter 12.

Then you talk to the captain, who does not deny anything, does not apologise,
and will not tell you what to think about it. Neither will this course.

## Learning objectives

- [ ] Run an investigation from a briefing without being told which commands to use
- [ ] Distinguish what you measured, what you inferred, and what you are guessing
- [ ] Enumerate accounts, shells and login history, and say why an account is not a person
- [ ] Read a running process through `/proc`, including its environment and open files
- [ ] Explain why `sudo cmd < file` fails when the shell, not the command, opens the redirect
- [ ] Use `stat` to read mtime, ctime, atime and birth time, and say what each one can be trusted for
- [ ] Recognise `touch -d` from the relationship between mtime and ctime
- [ ] Build a timeline with `find -printf` and `sort`, and cluster it by time and owner
- [ ] Compare two checksum manifests and identify a single-character difference
- [ ] Remediate in the order close, fix, stop, restore, prove — and say why that order
- [ ] Read the sticky bit and the setuid bit from `stat` output, and remove them
- [ ] Know that Linux ignores the setuid bit on `#!` scripts, and that the mode is still evidence
- [ ] Understand why a running program does not re-read its own file
- [ ] Restore from a backup and prove the restore with a checksum, not by eye
- [ ] Say what a post-check script can and cannot establish
- [ ] Detect a gap in an append-only log by counting, not by reading
- [ ] Follow a sha256 to the one file in a tree that produces it
- [ ] Extend a shipped tool without changing any existing subcommand's output or exit codes
- [ ] Write an incident report in five beats, with every sentence sourced
- [ ] Leave a conclusion unwritten when the evidence does not reach it

## Prerequisites

This chapter uses every earlier chapter and introduces nothing.

- Chapter 2 — paths; every `find` root and every `stat` argument
- Chapter 3 — `ls -l`, and knowing when it is the wrong tool for a timestamp
- Chapter 4 — `cat`, `head`, `tail`, `wc`; the whole of lesson 02's triage
- Chapter 5 — redirection; lesson 02's `sudo` redirection failure lives here
- Chapter 6 — `grep`, `sort`, `cut`, `comm`; the log gap is a `comm` away
- Chapter 7 — `find`, including `-printf`, `-newermt` and `-perm`
- Chapter 8 — exit status; `postcheck` and `stationctl gaps` both answer through it
- Chapter 9 — processes, `pgrep`, `pkill`, signals; lesson 04 stops a running loop
- Chapter 10 — ownership, modes, sticky and setuid; lessons 03 and 04 turn on them
- Chapter 11 — `sudo -u`, environment variables, `PATH`
- Chapter 12 — shell scripting; lesson 05 extends `stationctl` from 12/08
- Chapter 13 — packages; you will not install anything, and should not need to
- Chapter 14 — `tar`, `gzip`, `sha256sum`; lesson 05's chain is all three

## Lessons

- [`01-the-briefing`](01-the-briefing/readme.md) — rules of engagement, and what a sourced claim is
- [`02-triage`](02-triage/readme.md) — accounts, processes, `/proc`, and open files
- [`03-forensics`](03-forensics/readme.md) — mtime, ctime, and two sets of hands
- [`04-remediation`](04-remediation/readme.md) — close, fix, stop, restore, prove
- [`05-report`](05-report/readme.md) — **the finale.** The report, the chain, and the captain

## Roleplay

`05-report/scene.md` — **the captain.** They authorised the October change,
they have read the cadet's report, and they asked for the meeting. They do not
deny the mechanism; the first time the cadet states it plainly, the captain
says yes. They do not apologise, because they are not sorry and performing
sorrow would be a lie. Asked why, they explain the reasoning once, in four or
five sentences: the raw instrument was throwing figures nobody could act on,
the station had one shift's margin, and a number that stops work is not free.
They will not name who edited the file — *"You have the accounts. I'm not going
to improve on your evidence with my memory."* Asked whether it was right, they
say *"That's not mine to hand you."* The captain is never called a villain and
the scene never editorialises. Ten exchanges, maximum.

## Flags in this chapter

**1** — in `05-report`, behind a four-stage chain of `STAGE{...}` receipts that
do not register with `kestrel flags`.

The flag is not written in any file, in any encoding. Its two halves are
ordinary words in two ordinary artefacts — one in a note the student reaches by
hash, one in a file readable only by `ops-bot` — and the `KESTREL{a_b}` wrapper
comes from the course's documented format, not from the lab.

The stages are: extract an incomplete handover; work out from the run log's own
numbering which six records are missing and recover them from the archive;
follow a sha256 in the sixth record to the one file in the tree that produces
it; then read the second half as the account that owns it and extend
`stationctl` with a `gaps` subcommand. **Stage 2 is the cliff** — the handover
says the log disagrees with itself and nothing else, and the gap is invisible
to anyone reading the log forwards. It becomes visible only by counting
distinct sequence numbers against the span between the lowest and the highest.
