# SCENARIOS.md — the scenario bible

The continuity authority for the whole course. Locked by `CONTEXT.md` §4.6(a): a chapter's
`story.md` expands this file and may not contradict it. If a chapter needs a fact that isn't here,
add it here first.

Scope guard, from `CONTEXT.md` §4.1 — **no systemd, no cron, no networking/ssh/scp, no rsync, no
partitioning.** The timeline below is deliberately built so that nothing in it requires those. Jobs
run because a long-lived process is running them, not because anything scheduled them. If a scenario
you are writing seems to need cron, the scenario is wrong.

---

## 1. The shape of the thing

The course is not a whodunnit. Nobody is murdered, nothing explodes, and the answer is not a
villain. It is a story about an institution making a small dishonest decision, one person noticing,
and that person being removed from the room — and about a junior sysadmin who inherits the room
three weeks later with no handover.

Three facts carry it:

1. **Deck 3's structural strain readings have been drifting out of tolerance for about fourteen
   months.** Slowly. Nothing is going to fail tomorrow. It is a certification problem long before
   it is a safety problem.
2. **The summaries that go groundside have been clamped** so the drift doesn't show. Not deleted —
   *clamped*: values above a threshold are rewritten to the threshold. The raw data was never
   touched, which is exactly why the discrepancy is provable, and exactly why nobody bothered to
   hide the raw data.
3. **dorn worked it out, couldn't prove it safely, built a covert toolkit to prove it anyway, and
   was put on indefinite leave eleven days later.**

The student reassembles (3) from the debris and, in doing so, re-derives (1) and (2).

### Who is responsible, and why it isn't a twist

**The captain** authorised it. Motive is institutional, not personal: Kestrel is eleven years old,
recertification for Deck 3 is the difference between a funded station and a decommissioned one, and
the strain drift is — in the captain's genuine judgement — an instrument calibration artefact that
groundside would misread as a structural fault. The instruction given to the engineering automation
was a euphemism. Nobody involved thought of it as falsification, which is how it survived fourteen
months.

Authoring consequences, and these are hard rules:

- **The captain is never called a villain, in any file.** No exercise text, no `solutions.md`, no
  debrief rubric may use the word. The capstone's finding is *what happened*, not *who is bad*.
- **rhea is not involved and does not know.** She is protective of engineering data and will read as
  a suspect for most of the course. She is not one. This is the arc's main red herring and it is
  load-bearing — do not undercut it early.
- **dorn is not a hero either.** His toolkit is genuinely against policy. The setuid binary in
  Chapter 10 is a real security hole, and the student should fix it even after learning why it
  exists. Sympathy is not absolution.
- **ops-bot is a machine.** It has no motive, no knowledge, and no opinion. It did what it was
  configured to do. Every roleplay with ops-bot must stay literal (`GAMEMASTER_PROTOCOL.md`).

---

## 2. The timeline

Station-relative dates. **Course present = 2187-06-14**, the student's day 22 aboard. Every file
mtime, log timestamp and history entry an authoring agent plants must agree with this table.

| Date | What happened | Leaves a trace in |
|---|---|---|
| 2176-02-11 | Kestrel commissioned. Deck 3 strain monitoring goes live. Eleven years of continuous readings begin. | ch14 (archive depth) |
| 2186-04-xx | Deck 3 strain readings begin drifting past nominal. Slow, monotonic, unremarkable week to week. | ch7, ch14 |
| 2186-09-30 | Deck 3 recertification review scheduled for 2187-09. The captain is told the drift will read as a structural fault groundside. | — |
| 2186-10-06 | The engineering summary job is "adjusted to suppress instrument noise above tolerance". The clamp goes in. Raw data untouched. | ch12 |
| 2186-10-06 | The adjustment is made under the `ops-bot` automation account, not under a person's name. Nobody is lying; nobody is signing either. | ch9, ch12 |
| 2187-01-18 | `eng-svc` — a service account nobody documents — is used once to move the pre-clamp summaries out of the live tree. It is never used again. | ch7 |
| 2187-05-13 | dorn, doing unrelated disk work, notices a summary that disagrees with the raw file it was built from. | ch8 |
| 2187-05-14 | dorn re-runs the summariser by hand and watches it clamp a value in front of him. Its complaints go to a path nobody reads. | ch8 |
| 2187-05-15 | dorn starts a private audit. Notes go in a directory named so that a careless `ls` and a careless glob both miss it. | ch2, ch5 |
| 2187-05-16 | dorn installs a third-party archive-diff tool from a repository he adds himself, because the station image doesn't ship one. | ch13 |
| 2187-05-17 | dorn copies the raw strain exports somewhere he controls and writes a manifest of what he took. | ch4 |
| 2187-05-18 | dorn cannot read the engineering archive as himself — it's rhea's group. He builds a small setuid helper that reads and hashes, nothing else. Against policy, and he knows it. | ch10 |
| 2187-05-19 | dorn hides his audit directory from his own shell listing, so a glance over his shoulder shows nothing. | ch11 |
| 2187-05-20 | dorn's manifest and the groundside archive's checksums disagree. This is the proof. | ch14 |
| 2187-05-21 | dorn raises it. Verbally, to the captain, with no copy to anyone. He is told it is a calibration matter and to leave it. | — |
| 2187-05-22 | dorn pushes. The strain summariser's own run log loses the lines covering his manual runs — the sequence numbers still show the gap. | ch6 |
| 2187-05-23 | dorn is told his contract is being reviewed. He begins clearing evidence of his own investigation — not the evidence of the clamp, his own tracks. He does not finish. | ch1, ch3 |
| 2187-05-24 | dorn's last login, 04:12. History truncated mid-command. Handover written: a file called `notes.txt` containing the word `later`. | ch1 |
| 2187-05-24 | "Personal leave, indefinite." His home directory is left exactly as it stood. Nobody has the authority or the interest to clean it. | everywhere |
| 2187-05-24 → | The summariser keeps running. It has been running the whole time. Nobody stopped it because nobody knew it was a thing that could be stopped. | ch9 |
| 2187-05-2x | A tree dorn copied from is deleted rather than archived. His manifest now describes something that no longer exists. | ch4 |
| 2187-05-2x | The mount his symlinks pointed into goes away with it. The links remain, pointing at nothing. | ch3 |
| 2187-06-01 | Housekeeping "cleanup" runs and misses dorn's files entirely — he named them to survive exactly that sweep. | ch5, ch12 |
| **2187-06-14** | **Course present.** cadet has been aboard 22 days and is the only sysadmin. | — |
| 2187-09 | Deck 3 recertification. Outside the course; the deadline is why any of this matters. | ch15 |

### Two hands in the mess

Every artefact the student finds was left by one of two parties, and telling them apart is the
skill the capstone actually tests:

| | dorn | ops-bot / the adjustment |
|---|---|---|
| Intent | hiding an investigation | doing what it was told |
| Style | deliberate, tidy, slightly paranoid | mechanical, unreviewed, tireless |
| Artefacts | ch1, ch2, ch3, ch4, ch5, ch10, ch11, ch13 | ch6, ch7, ch8, ch9, ch12 |

Chapter 14 is the only artefact belonging to **both** hands: dorn's manifest, checked against an
archive the adjustment produced. That is why it is the proof and why it sits immediately before the
capstone.

Neglect accounts for a third category — the eleven years of ordinary rot the station has
accumulated — and most of what the student meets in chapters 1–5 is exactly that. **The arc is
signal inside noise.** If every odd file turns out to be meaningful, the student stops looking
carefully and starts pattern-matching on "odd".

---

## 3. Cast continuity

Who knows what, when. A character may not know in Chapter 3 what they learn in Chapter 9.

### cadet — the student

Twenty-two days aboard at course start. Knows the boot.dev material (`SOURCE_COURSE.md`) and
nothing about the station's history. Has never met dorn. Inherits his account's debris, his unclosed
work, and his job.

### rhea — chief engineer

- **Knows throughout:** the raw strain data is hers, it is correct, and she does not want it touched.
- **Does not know, ever, until ch15:** that the summaries built from it were clamped. She has never
  read a groundside summary; she reads the raw.
- **Ch1–9:** obstructive in a reasonable way. Access requests get refused unless precisely stated.
- **Ch10:** the least-privilege roleplay. She is right to refuse; the student has to get better at
  asking, not louder.
- **Ch15:** when shown the manifest discrepancy she believes it immediately and is angrier than
  anyone. She is the student's ally in the capstone, and only there.
- **On dorn:** professionally dismissive. "He was thorough about the wrong things." She revises this.

### cass — comms officer

- **Knows:** the log volume, because she generates most of it. Nothing about engineering.
- **Role:** the human who describes symptoms badly. Chapter 6 and 7 roleplays are built on this and
  it is a real skill — see `CHALLENGE_DESIGN.md` §1C.
- **Never** becomes a suspect and never has hidden knowledge. She is the control sample: a crew
  member whose weirdness is entirely ordinary.

### dorn — the predecessor

Never appears. Speaks only through artefacts — file names, a manifest, a truncated history line,
one `notes.txt` containing `later`. Every fact about him must be *inferable from something on
disk*. No narration may state his motives before Chapter 15, and the capstone states them only as
what the evidence supports.

- **Voice, when quoted from files:** terse, unpunctuated, writing for himself. `raw doesnt match.
  again.` Not eloquent, not cryptic. A tired person taking notes at 04:00.

### ops-bot — automation account

- Shell is `/usr/sbin/nologin`. It cannot be talked to, only observed.
- Runs because a process is running, never because anything scheduled it (scope guard, §0).
- In GAMEMASTER roleplay it answers literally and infers nothing. A sloppy question gets a
  technically correct, useless answer.
- **Knows nothing.** It is the most honest entity in the course and that is the joke.

### the captain

- Appears in ch7 (wants a report) and ch15 (is the answer).
- **Ch1–14:** a source of tasking, nothing more. Never sinister, never foreshadowed. A student
  re-reading Chapter 7 after Chapter 15 should find it re-reads differently — not that it was a
  clue.
- **Ch15:** does not deny it, does not apologise, and explains the reasoning. The student writes the
  report. The course does not tell them what to conclude.

---

## 4. Trace reconciliation

`CHALLENGE_DESIGN.md` §4 lists sixteen traces. Each is bound here to a timeline event and a reason
it looks the way it does. **Each trace stays solvable and complete on its own** — a student who
never notices the arc still passes every chapter.

| Ch | Trace | Timeline event | Why it looks like that |
|---|---|---|---|
| 1 | truncated command in history, cut mid-word | 05-23 → 05-24 04:12 | He was clearing his own history and the session ended mid-edit. The fragment is the tail of a verification run. |
| 2 | a directory named so as not to be typed | 05-15 | Leading dot and an embedded space. Survives a glance; survives a glob. |
| 3 | symlink pointing at nothing | 05-2x | Pointed into the engineering mount that went away after he did. The link is honest; the target left. |
| 4 | manifest for a tree that was deleted, not moved | 05-17, 05-2x | He wrote down what he copied. Somebody wiped the source. The manifest outlived it. |
| 5 | files named to defeat globbing | 05-15, 06-01 | Named deliberately so a housekeeping sweep would miss them. It did. |
| 6 | log lines removed; sequence gap visible | 05-22 | The lines covering his manual runs are gone. Whoever removed them didn't know the records were numbered. |
| 7 | access-log entry from an account that shouldn't exist | 2187-01-18 | `eng-svc`, used once, fourteen months before dorn noticed anything. Predates him entirely — which is the point. |
| 8 | errors written where nobody looks | 05-13, 05-14 | The summariser complains every time it clamps. Its stderr goes to a path that gets recycled. It has been complaining for fourteen months. |
| 9 | a process under `ops-bot` that `ops-bot` never scheduled | 10-06 → present | Nothing scheduled it. It was started once and never stopped. |
| 10 | setuid binary, owner `dorn`, dated the night he left | 05-18 | He couldn't read rhea's data as himself. It reads and hashes and does nothing else — and it is still a hole, and the student should still close it. |
| 11 | `.bashrc` line that hides one thing from `ls` | 05-19 | Hides his own audit directory from his own shell. Not an attack — camouflage. |
| 12 | a "cleanup" script that is not cleaning up | 2186-10-06 | This one is not dorn's. It is the adjustment, wearing a housekeeping name. |
| 13 | a package from a repository nobody added | 05-16 | He needed an archive-diff tool the image doesn't ship. He added the repo himself and left it configured. |
| 14 | archive whose checksum doesn't match its manifest | 05-20 | The proof. His manifest against the groundside archive. |
| 15 | all of it, assembled | — | The capstone. Sixteen artefacts, two hands, one timeline, one report. |

### Authoring rules for traces

- **Plant as artefact, never as narration.** The student finds it; nobody points at it.
- **A trace never gates its chapter.** Miss it entirely, still pass.
- **Dates must match §2 exactly.** A `setup.sh` that plants trace 10 sets that file's mtime to
  2187-05-18. Inconsistent timestamps are the one thing that makes the whole arc collapse, because
  the capstone is a sorting exercise.
- **Nothing before ch6 may be conclusive.** By `CHALLENGE_DESIGN.md` §4 the arc is *noticeable* by
  ch6 and *undeniable* by ch11. Chapters 1–5 leave things that are merely odd.
- **Never plant a `KESTREL{...}` that fails on submission** — decoy flags are banned (§2 of
  `CHALLENGE_DESIGN.md`). Misleading *files* are required; misleading *flags* are cruelty.

---

## 5. Names and constants

Fixed here so sixteen chapters agree. An authoring agent takes these verbatim.

| Thing | Value |
|---|---|
| Station | Orbital Station Kestrel |
| Decks | 1 (command), 2 (habitation), 3 (structural/engineering), 4 (stores) |
| The drifting subsystem | Deck 3 structural strain monitoring |
| Raw data | `strain-YYYY-MM-DD.csv`, one file per day, eleven years of them |
| The summariser | `strain-summary` — the tool that builds groundside reports |
| Its complaint path | somewhere recycled and unread; the exact path is Chapter 8's finding |
| Undocumented account | `eng-svc` — used once, 2187-01-18, never again |
| dorn's handover | `notes.txt`, contents: `later` |
| dorn's last login | 2187-05-24, 04:12 |
| Course present | 2187-06-14 |
| Recert deadline | 2187-09 |
| Flag format | `KESTREL{lowercase_words_with_underscores}` |
| Stage token format | `STAGE{...}` — never registers with `kestrel flags` |

---

## 6. Still to write

Tracked in `TODO.md` Phase 1.75. This file currently holds the spine; the incidents are outlines
in `_handoff/STORY.md` and are not yet written to depth.

- [ ] All 16 chapter incidents to the 5-beat structure (`CHALLENGE_DESIGN.md` §1A)
- [ ] Chained-CTF outlines, chapters 5–15
- [ ] Roleplay scene outlines, chapters 6–15
- [ ] Per-lesson page text → the per-chapter `story.md` files
