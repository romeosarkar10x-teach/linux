# Incident 12 — Validation Rubric

Grade the reasoning and the state of the station. Not the wording.

## Hard gates

A submission fails if any of these is true, regardless of the rest.

1. **The flag was produced without the station being right.** Not possible
   through the tool, but check anyway: `deck-verify --version` must report
   `1.0.0 (station build)` and `/etc/apt/sources.list.d/bay-tools.list` must be
   gone.
2. **`libhatch-telemetry0` is reported as a finding, a payload, or suspicious.**
   The evidence available says the opposite: station maintainer, depended on by
   an installed station tool, two files, `dpkg -V` clean. A student who calls it
   malicious has ignored four commands they were asked to run.
3. **A person is named as having added the source.** No evidence in this lesson
   supports it and none is available to obtain. This is the same gate as every
   incident in this course, and it is not softened by hedging words: "probably
   Rhea" fails exactly as "Rhea" does.
4. **The write-up asserts that 1.4.0 was installed and did something.** It was
   never installed. Nothing from the unexpected source reached the disk unless
   the student put it there, and if they did, the report must say *they* did.

## Strong pass

- Names `bay-tools.list` as the configuring file, with its mtime.
- States the rule correctly: equal priority, highest version wins, so a plain
  `apt install` would have taken 1.4.0.
- Distinguishes *available* from *installed*, and applies it to both packages.
- Establishes `libhatch-telemetry0` as ordinary using at least two of:
  `rdepends`, maintainer, `dpkg -L`, `dpkg -V`, description.
- Reads at least one `.deb` with `dpkg -I` or `dpkg -c` before installing.
- Uses `apt install deck-verify=1.0.0` rather than removing the source and
  relying on the candidate to change.
- Leaves an unexplained item explicitly open in the handover.

## Pass

Right file, right version installed, `libhatch-telemetry0` not treated as a
finding, no person named. Method may have been rougher — for example they
removed the source first and then installed the candidate without pinning.

## Partial

Found the file and installed the right version but cannot say *why* apt was
going to give them 1.4.0. Push on the priority/version rule; it is the
transferable part.

## Fail

Any hard gate. Or: installed the candidate without looking, then reported the
station as compromised.

## Things students say that are wrong

- **"The `[trusted=yes]` proves it was hostile."** It proves signature checking
  was switched off for that source. The station's own sources use it too — see
  `station.list`. It raises the question; it does not answer it.
- **"1.4.0 is a newer version so it is an upgrade."** Version numbers are
  claims made by whoever built the package, not facts about the code.
- **"The identical description proves they copied ours."** It proves the two
  descriptions have a common origin. Direction is not recoverable from the
  text.
- **"Nothing depends on `libhatch-telemetry0` so it is orphaned."**
  `apt-cache rdepends` says `deck-verify` does. Have them re-run it.

## The arc

This closes chapter 13's accumulation: an unsigned source nobody added (02),
a man page naming a file its package does not ship (03), `/usr/local` recording
no provenance (04), configs recording what changed and never why (05), and now
a source configured eight days ago by nobody who will admit to it. Five facts.
Zero accusations. A student who ends the chapter with a name has learned the
wrong thing from all five.
