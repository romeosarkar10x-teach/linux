# Chapter 13 — Packages, Docs & Editors

> "Every file on this station arrived somehow. Some of them can tell you how."

## Incident briefing

Twelve chapters of using what was already installed. This chapter is about how
it got there, how to find out what it does without an internet connection, and
how to change a file in place without a pipeline.

It goes in order. First `apt`: search, install, remove, and the difference
between `remove` and `purge` that people discover a week too late. Then `dpkg`
underneath it, where a package is a file with a control block and a list of
paths, and where a half-configured package still runs. Then the manual, offline
and complete: sections, `apropos`, `man -k`, and the fact that `man -f fstab`
on this station says `nothing appropriate` because the page was never shipped.
Then installing something that did not come from a repository at all — three
routes, and the different things each one costs you later. Then editing: nano,
vim, getting out of both, and `sudo -e` versus `sudo vim`.

Then the incident. Deck 09 is held until `deck-verify` runs, and `deck-verify`
is not installed. `apt` will happily install it. It will also, by default, give
you a version from a source that nobody configured on purpose — because the two
sources sit at the same priority and the higher version number wins. There is
also a package already installed with an alarming name that turns out to be an
ordinary dependency of the station's own tool. One of those two things is a
finding. It is not the one that looks like one.

The chapter's evidence accumulates across all six lessons and never once
becomes an accusation: an unsigned source in lesson 02, a man page naming a
config file its package does not ship in lesson 03, `/usr/local` recording no
provenance at all in lesson 04, configuration files recording what changed and
never why in lesson 05, and in lesson 06 a source file with a modification time
and no author.

## Learning objectives

- [ ] Search, install, remove and purge with `apt`, and say what `remove` leaves behind
- [ ] Read `apt-cache policy` and name the candidate, the sources, and the priorities
- [ ] Explain why the highest version wins when two sources are at equal priority
- [ ] Inspect a `.deb` with `dpkg -I` and `dpkg -c` without installing it
- [ ] Use `dpkg -l`, `-s`, `-L`, `-S` and `-V`, and say what silence from `-V` means
- [ ] Recognise a half-configured package (`iU`) and repair it with `dpkg --configure -a`
- [ ] Say what `[trusted=yes]` in a sources file switches off
- [ ] Find a command's documentation offline: `man`, sections, `-k`, `apropos`, `-K`
- [ ] Explain why `man -f` finds nothing for a page that was never installed
- [ ] Rebuild the manual index with `mandb`, and say when you need to
- [ ] Choose between a repository package, a tarball into `/usr/local`, and a user-local install
- [ ] Say what `/usr/local` records about where its contents came from, and act accordingly
- [ ] Edit a file in nano and in vim, and leave both without losing work
- [ ] Recognise vim's modes, and recover from a swap file
- [ ] Use `$EDITOR`/`$VISUAL`, and say why `sudo -e` is not `sudo vim`
- [ ] Establish that an installed package is ordinary using `rdepends`, `-L`, `-V` and its maintainer
- [ ] Establish provenance *before* installing, and say why afterwards is too late
- [ ] Distinguish a package being available from a package being installed

## Prerequisites

- Chapter 2 — paths; `dpkg -L` and `dpkg -S` are both questions about paths
- Chapter 3 — `stat` and mtime; in lesson 06 the mtime is the whole of the evidence
- Chapter 6 — `grep -r`, which is how you read `/etc/apt/sources.list.d/` in one pass
- Chapter 8 — exit status; `man` exits 16 on a missing page and `deck-verify` uses 3, 4 and 5
- Chapter 10 — permissions and ownership, which is what `dpkg -V` is checking
- Chapter 11 — `PATH`; lesson 04 turns on which directory wins and lesson 01 on where Nix-installed tools live
- Chapter 12 — reading a script without running it, which is what inspecting a package amounts to

## Lessons

- [`01-apt`](01-apt/readme.md) — search, install, remove, purge, and what `remove` leaves behind
- [`02-dpkg-and-repos`](02-dpkg-and-repos/readme.md) — a package is a file; sources are configuration; `iU` still runs
- [`03-man-pages`](03-man-pages/readme.md) — the manual offline: sections, `apropos`, `mandb`, and a page with no NAME
- [`04-installing-tools`](04-installing-tools/readme.md) — three routes into `/usr/local`, and what each one costs later
- [`05-editors`](05-editors/readme.md) — nano, vim, getting out of both, and `sudo -e`
- [`06-incident-12`](06-incident-12/readme.md) — **the incident.** Two sources, one tool, and the alarming package that is a dependency

## Roleplay

`06-incident-12/scene.md` — **rhea.** Deck 09 opens at 22:00 or it does not
open, and she considers "where did this package come from" a question for a
quieter shift. She is not an antagonist and she is not the culprit. She moves
on exactly two things: evidence she can put in the deck log, and a time
estimate she can plan around. "I have a bad feeling about this" gets nowhere;
"apt will install a version from a source I cannot account for, give me eight
minutes" gets the eight minutes. If the student names a person, she gets colder
and asks for the file instead. She is right to.

## Flags in this chapter

**1** — in `06-incident-12`, behind a four-stage chain of `STAGE{...}` receipts
that do not register with `kestrel flags`.

The flag is not written in any file. It is stored base64-encoded inside the
installed `deck-verify` binary and printed only once the student's three
findings are correct *and* the station has actually been put right, so the lab
is not greppable and a correct write-up on a broken station earns nothing.

The stages are: read the custom control field in the station's `.deb`; read the
same field in the one from the source nobody added; then remove that source,
install the pinned version, and pass `--self-test`; then attest. **Stage 3 is
the cliff** — it is the only stage that requires changing the station rather
than reading it, and it refuses two different ways, exit 3 while the source
file is still configured and exit 4 if the wrong version got installed.
