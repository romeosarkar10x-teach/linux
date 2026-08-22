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

Tracked in `TODO.md` Phase 1.75.

- [x] All 16 chapter incidents to the 5-beat structure (`CHALLENGE_DESIGN.md` §1A) — §7 below
- [x] Flag texts fixed for all 16 chapters — inline in §7
- [x] Chained-CTF outlines, chapters 5–15 — §8
- [x] Roleplay scene outlines, chapters 6–15 — §9
- [x] Per-lesson page text → all 16 per-chapter `story.md` files

One chapter has no `NN-incident-NN` lesson: Chapter 10, which folds its incident into
`08-special-bits` — the syllabus already describes that lesson as "CTF: find the setuid backdoor",
so it is intended and needs no action. Chapter 14 was in the same position and **gained a fifth
lesson**, `05-incident-13`, on 2026-08-23; it carries the arc's proof and had no finale.

---

## 7. The sixteen incidents

Each written to the 5-beat structure in `CHALLENGE_DESIGN.md` §1A: **page → constraint → dig →
fix/find → debrief.** The page states a symptom and never a cause. Every dig carries at least one
red herring.

**Dependency rule** (`AGENTS.md` rule 1): an incident may use only tools introduced in its own
chapter or earlier. The "Tools" line on each is the ceiling, not a suggestion.

**Flag texts are fixed here.** They are written into `solutions.md` at authoring time and their
salted hashes into `container/flags.tsv`. Do not improvise replacements — several are callbacks.

> **Open structural issue.** Chapter 14 is four lessons and has no `NN-incident-NN` lesson, unlike
> every other chapter. Its incident is written below as folding into `04-checksums`, whose syllabus
> entry already says "tamper-detection exercise". Either that is fine, or Chapter 14 gains a fifth
> lesson. **Needs a decision before Phase 3 reaches it.**

---

### Ch 1 — `07-incident-01` · The command he didn't finish
**Trace:** 1 · **Hand:** dorn · **Flag:** `KESTREL{he_never_finished_typing}`
**Tools:** `history`, `!!`, `!$`, `!n`, Ctrl-R, `HISTSIZE`, `HISTCONTROL`, variables, `type`

- **Page.** Your predecessor's account still has a shell history. The last line in it stops in the
  middle of a word. Three weeks and nobody has looked.
- **Constraint.** The history file is the only source. It is not to be edited — you may read it and
  copy from it, and the validator checks it is unmodified. (Diegetic reason: it is the only record
  of a departed employee's account, and you don't get to be the second person to alter it.)
- **Dig.** The truncated line is the tail of a verification run against a data file. Two other
  lines nearby look more interesting and are not — one is a long `find` that is genuinely just
  housekeeping (**red herring**), one is a typo he corrected on the next line. The student needs
  the *shape* of the truncated command, not its output.
- **Find.** Reconstructing the fragment and running the completed command against the file it names
  prints the flag.
- **Debrief.** Three sentences: what the fragment was doing, how you knew where it was cut, and why
  the last line of a history file is often incomplete.

**Continuity:** 2187-05-24, 04:12. He was clearing his own history when the session ended. Nothing
in this lesson may state that he was hiding anything — at Chapter 1 it reads as a tired person who
got disconnected.

---

### Ch 2 — `07-incident-02` · The stowaway
**Trace:** 2 · **Hand:** dorn · **Flag:** `KESTREL{a_name_you_cannot_type}`
**Tools:** `ls -a -l -d`, `cd -`, `stat`, `file`, `tree`, `du -sh`, `--` end-of-options, `/proc`

- **Page.** Disk accounting says a directory holds forty megabytes. `ls` says it holds nothing.
- **Constraint.** No searching tools. `find` and `grep` are Chapter 6; this one is solved by
  looking properly, which is the point.
- **Dig.** A dotfile-hiding directory whose name also contains a space and a trailing character
  that makes naive `cd` fail. Leads: `du` disagreeing with `ls`, `ls -a` showing a name that looks
  like an artefact of the terminal, `stat` proving it is real. **Red herring:** a genuinely empty
  `.cache` directory next to it, which explains nothing and is very tempting.
- **Find.** Entering the directory correctly — quoting or `--` or tab completion — and reading the
  file inside.
- **Debrief.** Why `ls` hid it, why `du` didn't, and one sentence on what a filename actually is.

**Continuity:** 2187-05-15. This is dorn's audit directory, and the student is not told so. It
contains notes they cannot yet interpret. Plant them; do not explain them.

---

### Ch 3 — `06-incident-03` · The maintenance-deck maze
**Trace:** 3 · **Hand:** dorn · **Flag:** `KESTREL{the_link_outlived_the_target}`
**Tools:** the 7 file types, `ls -i`, `stat`, `ln`, `ln -s`, `readlink -f`, `touch -t`, `find -newer`

- **Page.** Four links in the maintenance tree. Three go somewhere. One has been pointing at
  nothing since before you arrived, and nobody noticed because nothing that runs depends on it.
- **Constraint.** You may not create, delete or repair any link until you can say, in writing,
  where each one currently points.
- **Dig.** A chain: symlink → symlink → hard link → the file. One arm of the chain dangles into a
  path that no longer exists. **Red herring:** two files that appear to be copies and are actually
  hard links to one inode — noticing that is a real finding, but it is not this finding.
- **Find.** Following the live chain to the target file; the flag is in it. The dangling arm's
  *target path* is itself the interesting artefact and gets recorded in the debrief.
- **Debrief.** What the dangling link pointed at, why a symlink can outlive its target, and how you
  told the hard links from the copies.

**Continuity:** the dead target names the engineering mount that went away after dorn did
(2187-05-2x). By Chapter 15 that path name matters. Here it is just a broken link.

---

### Ch 4 — `05-incident-04` · Deleted, not moved
**Trace:** 4 · **Hand:** dorn · **Flag:** `KESTREL{deleted_not_moved}`
**Tools:** `cat`, `nl`, `head`, `tail`, `less`, `mkdir -p`, brace expansion, `cp`, `mv`, `rm`, `mktemp`

- **Page.** There is a manifest. There is no tree. Rebuild what the manifest describes.
- **Constraint.** Build it with brace expansion and `mkdir -p`, not with forty `mkdir` calls. The
  validator counts commands; a student who brute-forces it passes with notes, not clean.
- **Dig.** The manifest lists paths, sizes and a one-line note per file. Most reconstruct cleanly.
  Two entries describe files that cannot both exist as written — same path, different sizes,
  recorded four minutes apart. **Red herring:** a `.bak` of the manifest that is subtly *older* and
  disagrees; students who trust it rebuild the wrong tree and the flag doesn't appear.
- **Find.** A correctly rebuilt tree; the flag is assembled from the notes column in manifest order.
- **Debrief.** What the manifest was for, what the four-minute duplicate means, and why "deleted"
  and "moved" leave different evidence.

**Continuity:** 2187-05-17 (written) and 2187-05-2x (source wiped). The duplicate entry is dorn
re-taking a file after the first copy came out wrong.

---

### Ch 5 — `05-incident-05` · Named to survive the sweep
**Trace:** 5 · **Hand:** dorn · **Flag:** `KESTREL{named_to_survive_the_sweep}`
**Tools:** globs, `shopt dotglob nullglob globstar`, brace expansion, quoting, IFS, `set -x`

- **Page.** Housekeeping ran a fortnight ago and removed everything matching its pattern. Some
  files are still here. They were not missed by accident.
- **Constraint.** Select exactly the surviving set with a single glob. No `find`, no loops, no
  listing filenames by hand.
- **Dig.** The survivors are named to fall outside a plausible cleanup pattern — leading dot, a
  trailing tilde, an embedded space, a name beginning with a dash. **Red herring:** two files that
  look adversarial and are just badly named by a human in a hurry. The glob must include the
  deliberate ones and exclude those.
- **Find.** The correct glob prints the file set; concatenating them in glob order gives the flag.
- **Debrief.** Which naming trick defeats which pattern, why `-` at the start of a name is a
  different problem from a space, and what `nullglob` would have changed.

**Continuity:** 2187-06-01, the housekeeping run. The student is meant to conclude "somebody chose
these names" and nothing more.

---

### Ch 6 — `07-incident-06` · The gap in the record
**Trace:** 6 · **Hand:** the adjustment · **Flag:** `KESTREL{the_gap_is_the_message}`
**Tools:** `grep` and flags, BRE/ERE, `find` basics and advanced, `-exec`, `-print0`, `locate`

- **Page.** cass says the overnight logs "look fine." A run log in the engineering tree numbers its
  own entries. The numbers do not run consecutively.
- **Constraint.** Chapter 6 is the first chapter where the arc becomes *noticeable*
  (`CHALLENGE_DESIGN.md` §4) — so this incident must be solvable without any arc knowledge, and
  must leave a student who notices with something real. Both, not either.
- **Dig.** Multi-flag, per the syllabus. Locate the run log among many; find the sequence gap;
  find what else in the tree was written in the same minutes as the missing entries. **Red
  herring:** a second log with a genuine gap caused by a rotation, which is boring and correct.
- **Find.** The flag is in a file that was written during the gap and is the only thing in the tree
  timestamped there.
- **Debrief.** How you proved the gap wasn't rotation, what was happening in those minutes, and one
  sentence on why numbered records survive deletion better than unnumbered ones.

**Continuity:** 2187-05-22. Whoever removed the lines didn't know the records were numbered. Do not
say who. Nobody in-story knows.

---

### Ch 7 — `08-incident-07` · One login, fourteen months ago
**Trace:** 7 · **Hand:** the adjustment · **Flag:** `KESTREL{eng_svc_logged_in_once}`
**Tools:** `sort`, `uniq -c`, `cut`, `paste`, `column`, `tr`, `sed`, `awk`, `tee`, `xargs`

- **Page.** The captain wants the access log as a ranked report by account. Top talkers, counts,
  readable. By the end of the shift.
- **Constraint.** One pipeline, built left to right, inspected at each stage — the method taught in
  `07-building-a-pipeline`. The report goes to a file *and* to the terminal, which is what `tee` is
  for.
- **Dig.** The ranking is the exercise. The finding is in its tail: an account with a count of
  exactly one, from fourteen months ago, that appears nowhere in `/etc/passwd`. **Red herring:**
  `ops-bot` dominates the ranking so completely that students stop reading at the top. The report is
  ranked descending; the answer is at the bottom.
- **Find.** Isolating that account's single entry; the flag is built from the fields of that line.
- **Debrief.** Your pipeline, stage by stage, plus: which account has no business existing, and how
  a count of one is more suspicious than a count of forty thousand.

**Continuity:** 2187-01-18, `eng-svc`. It predates dorn noticing anything, which is the point — the
student meets the adjustment's fingerprint before they meet dorn's investigation.

---

### Ch 8 — `06-incident-08` · It has been complaining for months
**Trace:** 8 · **Hand:** the adjustment · **Flag:** `KESTREL{it_complained_for_months}`
**Tools:** fd 0/1/2, `>`, `>>`, `2>`, `2>&1`, `&>`, heredocs, `<<<`, pipes, `$?`, `&&`, `||`

- **Page.** A diagnostic tool prints a clean report and exits zero. Run it and it looks healthy.
  Somebody has arranged for it to look healthy.
- **Constraint.** Capture its stderr without losing a byte of its stdout, and do it in one
  invocation. The order of redirections matters and the lesson taught why.
- **Dig.** The tool writes complaints to fd 2, and its wrapper sends fd 2 somewhere that gets
  recycled. Leads: exit code zero despite the complaints, a wrapper script with the redirection in
  it, the recycled path. **Red herring:** a log file with the tool's name on it, which contains only
  stdout and looks authoritative.
- **Find.** Separating the streams reveals a repeated complaint. The flag is in the complaint text,
  which the student has to run the tool to see — it exists in no file.
- **Debrief.** Why `2>&1 >file` and `>file 2>&1` differ, what the tool was complaining about, and
  why exit zero was honest rather than a lie.

**Continuity:** 2187-05-13 and 05-14 — dorn's route into the whole thing. The complaint is the clamp
announcing itself, in the dullest possible words, for fourteen months, to nobody.

---

### Ch 9 — `07-incident-09` · Nobody started it
**Trace:** 9 · **Hand:** the adjustment · **Flag:** `KESTREL{ops_bot_never_slept}`
**Tools:** `ps -ef`, `ps aux`, `pstree`, `top`/`htop`, signals, `kill`/`pkill`/`pgrep`, job control,
`/proc/<pid>/cmdline|environ|fd`, `lsof`, `nice`

- **Page.** Station CPU is at a permanent low simmer and rhea wants to know why her jobs are slow.
  Something under `ops-bot` has been running for a long time.
- **Constraint.** Identify it and trace it fully *before* signalling it. Killing it first is a
  fail — the process's environment and open files are the evidence, and they vanish with it.
- **Dig.** `/proc/<pid>/environ` carries how it was configured; `/proc/<pid>/fd` shows what it has
  open, including a file that has been deleted and is still held. **Red herring:** an `htop` view
  where a short-lived process spikes higher and is completely innocent.
- **Find.** The flag is in the process's environment. It cannot be found from the filesystem, which
  is the whole design of this one.
- **Debrief.** Its pid, ppid and what that parentage means; what it has open; why you looked before
  you killed; and TERM versus KILL for this specific process.

**Continuity:** started 2186-10-06, never stopped. Nothing scheduled it — say so explicitly if a
student asks, because their instinct will be cron and cron is out of scope.

---

### Ch 10 — `08-special-bits` · The helper he shouldn't have built
**Trace:** 10 · **Hand:** dorn · **Flag:** `KESTREL{he_needed_to_read_it}`
**Tools:** `/etc/passwd`, `/etc/group`, `id`, `usermod -aG`, `useradd`, rwx and octal, `chmod`,
`chown`, `umask`, `sudo`, `visudo`, setuid/setgid/sticky

- **Page.** A permissions audit of the engineering tree. Also: there is a setuid binary in a place
  setuid binaries do not belong, owned by an account whose holder left three weeks ago.
- **Constraint.** rhea's data is not yours to read. You may fix the hole, and you may not use it to
  read anything you weren't already entitled to — a rule the validator checks by asking what you
  read, not just what you ran.
- **Dig.** Finding it by permission bits rather than by name. What it actually does: reads and
  hashes, nothing else — narrower than a backdoor and still a hole. **Red herring:** a legitimately
  setgid directory that is supposed to be that way, and a student who "fixes" it breaks group
  collaboration for the whole `engineering` group.
- **Find.** Reading the binary's strings or running it within its intended scope yields the flag.
- **Debrief.** What the bit does, why this specific binary is dangerous despite being narrow, what
  you changed, and what would have been the correct way to get the access it was taking.

**Continuity:** 2187-05-18, mtime exactly. This is the first artefact that is unambiguously
deliberate, and Chapter 11 makes it undeniable.

---

### Ch 11 — `06-incident-10` · Hidden from his own shell
**Trace:** 11 · **Hand:** dorn · **Flag:** `KESTREL{hidden_from_his_own_shell}`
**Tools:** env vars, `export`, PATH, `which -a`, `hash`, startup files, aliases and functions,
`\cmd`, `PS1`, `shopt`, `set -o`

- **Page.** dorn's shell configuration does something one of yours does not. Two people running the
  same command in the same directory see different things.
- **Constraint.** Repair it without deleting the file, and without deleting the line — you have to
  be able to explain what it did, and a deleted line explains nothing. The validator diffs.
- **Dig.** A function shadowing a command, defined in a startup file that only runs in one of the
  three shell modes taught in `03-startup-files`. Leads: `type` disagreeing with `which`, the same
  command behaving differently in a login shell, a PATH entry that shouldn't be there. **Red
  herring:** a genuinely useful alias further up the file that looks suspicious and is not.
- **Find.** Bypassing the shadow (`\cmd`, or the absolute path) reveals what was being hidden. The
  flag is in it.
- **Debrief.** Which startup file, which shell mode, what the line hid, and why `\ls` and
  `/usr/bin/ls` both work but for different reasons.

**Continuity:** 2187-05-19. What it hides is the Chapter 2 directory. A student who connects those
is doing exactly what Chapter 15 asks of them — and by design gets no acknowledgement here.

---

### Ch 12 — `09-incident-11` · The cleanup that isn't
**Trace:** 12 · **Hand:** the adjustment · **Flag:** `KESTREL{cleanup_that_rewrites}`
**Tools:** all of Chapter 12 — arguments, conditionals, loops, `case`, functions, arithmetic,
`set -euo pipefail`, `trap`, `mktemp`, `shellcheck`, and `stationctl` from `08-ship-a-tool`

- **Page.** There is a housekeeping script in the ops tree. It is named for cleaning up. Read it
  before you run it.
- **Constraint.** You are writing an auditing tool, not fixing the script. `stationctl audit` must
  report what it found and exit non-zero when it finds it, and it must pass `shellcheck` clean.
- **Dig.** The script deletes almost nothing. What it mostly does is rewrite values above a
  threshold, in place, and log the run as a cleanup. **Red herring:** it *does* have a real cleanup
  branch that works fine, and a student who reads only the first `case` arm finds nothing wrong.
- **Find.** The flag is produced by running the student's own audit tool against the ops tree — it
  exists nowhere until their script is correct, which is the point of the chapter.
- **Debrief.** What the script claims to do, what it does, the one line that is the whole problem,
  and what your audit tool would catch if somebody renamed the script tomorrow.

**Continuity:** 2186-10-06. This is the adjustment itself, in source, readable. Chapter 12 is where
the student can finally see it — and cannot yet prove what it means. That is Chapter 14's job.

---

### Ch 13 — `06-incident-12` · A repository nobody added
**Trace:** 13 · **Hand:** dorn · **Flag:** `KESTREL{a_repo_nobody_added}`
**Tools:** `apt`, `dpkg -l/-L/-S`, sources, `man` sections, `apropos`, `tldr`, `nano`/`vim`

- **Page.** A tool you need is not installed. Also, something on this station is installed that did
  not come from anywhere the station configures.
- **Constraint.** Find out where the stray package came from *before* installing anything new, so
  the "before" state is recorded. (`kestrel reset` restores the lab, so this is safe to get wrong.)
- **Dig.** `dpkg -l` against the configured sources; the stray package's files via `dpkg -L`; the
  source entry that was added by hand. **Red herring:** a package that looks exotic and is a
  perfectly ordinary dependency of something the image installs.
- **Find.** Installing the tool the incident needs, then using it to read a file that is not
  readable without it. The flag is in that file.
- **Debrief.** Which package is stray, where it came from, what it does, and why an unlisted
  repository is a supply-chain problem and not just untidiness.

**Continuity:** 2187-05-16. dorn added the repo to get an archive-diff tool, and left it configured
because he expected to be back on Monday.

---

### Ch 14 — `05-incident-13` · The manifest says otherwise
**Trace:** 14 · **Hand:** both · **Flag:** `KESTREL{manifest_says_otherwise}`
**Tools:** `tar`, `gzip`/`zip`, `zcat`, `zgrep`, `df`, `du`, `ncdu`, `sha256sum`, `md5sum`, `-c`

Given its own lesson rather than folded into `04-checksums`. It is the only artefact belonging to
both hands (§2), it is the arc's proof, and it sits immediately before the capstone — a chapter
whose finale is a graded exercise inside a teaching lesson would be the one place the arc goes
quiet right before it has to land.

- **Page.** The archive checks out against its own checksum file. It does not check out against the
  manifest somebody wrote by hand at the time. Both cannot be right.
- **Constraint.** The archive is not to be modified. Extract to a scratch directory, verify there,
  and leave the original bit-identical — checked by hashing it before and after. (Diegetic reason:
  it is the copy that goes groundside in September.)
- **Dig.** `sha256sum -c` passes against the shipped checksums and fails against the manifest, for a
  subset of files. The subset has a property, and finding the property is the exercise — the files
  that disagree are the days the strain readings exceeded the clamp threshold. Leads: the two
  verification results disagreeing, the manifest's mtime predating the archive's, the shape of the
  failing set once sorted by date. **Red herrings:** a compression-format mismatch that looks like
  corruption and is just `zcat` on the wrong file, and one manifest line with a genuine typo in its
  hash — a human error in a document that is otherwise correct, which tempts students to dismiss
  the whole manifest.
- **Find.** Identifying the failing subset and what its members have in common. The flag is derived
  from that shared property.
- **Debrief.** What passed, what failed, what the failing set has in common, why the manifest is
  more trustworthy than the checksum file despite being handwritten, and one sentence on why a
  checksum file shipped alongside its own archive proves less than people think.

**Continuity:** 2187-05-20 — dorn's proof, and the last artefact before the capstone. The student
should be able to state *that* the failing set is date-correlated without yet knowing what clamped
it. Chapter 15 supplies the why.

**Note on the disk-full finding.** The deleted-but-open file holding disk space (`du`/`df`
disagreement) belongs to `03-disk-usage`, not here. It is a genuine Chapter 14 surprise and it is
unrelated to the tamper — keeping it in its own lesson stops this incident from having two answers.

### Ch 15 — the capstone · The Kestrel Breach
**Trace:** 15 · **Hand:** both · **Flag:** `KESTREL{calibration_matter}`
**Tools:** everything. Five lessons: briefing, triage, forensics, remediation, report.

- **Page.** Deck 3 recertifies in September. You have been on this station twenty-two days, you are
  the only sysadmin, and you have found fourteen things that individually looked like neglect.
- **Constraint.** The report is the deliverable. Every claim in it must name the artefact it rests
  on. A conclusion the student cannot source is struck, however correct it happens to be.
- **Dig.** Sorting fourteen artefacts into two hands (§2). The dates do the work: dorn's cluster
  inside eleven days in May 2187; the adjustment's spread across fourteen months from October 2186.
  **Red herring — the big one:** rhea. She owns the data, guards it aggressively, refused the
  student access repeatedly, and is innocent. A student who indicts her has followed the evidence
  badly, and the rubric says so without saying who is right.
- **Find.** The flag is the euphemism, recoverable from the artefacts: what the adjustment was
  called by the person who authorised it.
- **Debrief.** The report itself, plus `stationctl` extended to re-run the checks that found it. The
  five beats: what happened, when, who did what, what you changed, and what you would have needed
  to catch it in October rather than in June.

**Continuity:** the captain does not deny it, does not apologise, and explains the reasoning. The
course does not tell the student what to conclude about that, and no file in the course may.

---

## 8. Chained CTFs — chapters 5 onward

Rules from `CHALLENGE_DESIGN.md` §1B, restated because they get violated: **max four stages**,
stage 1 solvable by anyone who read the notes, the cliff at stage 2 or 3, every stage fails
**loudly**, intermediate tokens are `STAGE{...}` and never register with `kestrel flags`.

Each chain uses a *different* skill per stage, so it audits the chapter rather than one lesson.
Where a chain and the chapter's incident are the same lesson, the chain **is** the incident's dig.

| Ch | Chain | Stage skills |
|---|---|---|
| 5 | glob selects a file set → its names spell an order → that order concatenates the survivors → flag | globs → brace expansion → quoting → IFS/word splitting |
| 6 | `find` by mtime narrows to a day → `grep -c` finds the numbering gap → `grep -o` extracts what was written in the gap → flag | `find -mtime` → `grep -n/-c` → ERE + `-o` → `find -exec` |
| 7 | rank accounts → the tail names a file → `cut`/`awk` pulls a field from it → `tr`/`sed` decodes it → flag | `sort`/`uniq -c` → `awk` fields → `cut`/`paste` → `tr`/`sed` |
| 8 | run the tool, separate the streams → stderr names a path → the path is a herestring-fed command → its exit code selects one of two files → flag | `2>` split → `&>`/`tee` → heredoc/`<<<` → `$?` + `&&`/`||` |
| 9 | find the process → `/proc/<pid>/fd` names a deleted file → recover it through the fd → its contents name a second process → flag in that one's environ | `ps`/`pgrep` → `/proc/fd` + `lsof` → reading through `/proc` → `/proc/environ` |
| 10 | find files by permission bits → one is setgid and legitimate, one is not → the illegitimate one is readable only as a group you must join → flag | `find -perm` → octal decoding → `usermod -aG` + re-login → setuid semantics |
| 11 | `type` disagrees with `which` → the shadow is defined in one startup file of three → bypassing it reveals a PATH entry → a binary there prints the flag | `type`/`which -a` → startup-file modes → `\cmd`/absolute path → PATH + `hash` |
| 12 | read the script → its `case` has an unreachable arm → making it reachable exposes the rewrite → your audit tool detects it → flag | reading control flow → `case` → loops + `[[ ]]` → `stationctl` + `set -euo pipefail` |
| 13 | `dpkg -S` on a stray file names its package → `dpkg -l` dates it → the source that shipped it is hand-added → the tool you install reads the flag | `dpkg -S` → `dpkg -l/-L` → sources/repos → `apt install` + use |
| 14 | verify twice, two answers → the failing subset sorts by date → its members share a property → flag | `sha256sum -c` → `tar -t`/extract → `sort`/`du` → the property |
| 15 | triage names the processes → forensics dates the artefacts → the two clusters split by hand → the euphemism → flag | all four capstone lessons, one stage each |

Chapter 5's chain is deliberately the gentlest — it is the first, and stage 1 of the first chain a
student ever meets must not be where they learn that chains exist.

---

## 9. Roleplay scenes — chapters 6 onward

Run by an agent in GAMEMASTER mode (`docs/GAMEMASTER_PROTOCOL.md`). The character has knowledge, an
attitude, and a reason not to hand it over. **No character ever knows the flag**, and no scene can
be won by asking for the answer — §9's characters are people to interview, not oracles to query.

| Ch | Character | The scene | What it actually teaches |
|---|---|---|---|
| 6 | **cass** | "The logs are broken." She means one specific thing and cannot name it. She describes what she *sees*: a report that "stops early". | Turning a symptom report into a search. The student must extract a time window and a filename before any `grep` is worth running. |
| 7 | **the captain** | Wants "the access numbers." Won't specify format, then rejects the first version for being unreadable. | That "make me a report" is an unstated spec, and asking three questions up front beats three rewrites. |
| 8 | **ops-bot** | Asked why a tool "worked", it answers that the tool exited zero. It will not volunteer that the tool also wrote 40,000 lines to stderr. | Literalism. The machine answered correctly and told you nothing. Ask about streams, not about success. |
| 9 | **rhea** | Her jobs are slow. She blames the student's changes, and is wrong, and is not being unreasonable — the timing does line up. | Defending a diagnosis with evidence to somebody senior and annoyed, without either caving or getting defensive. |
| 10 | **rhea** | The least-privilege scene. She refuses access until the student states exactly what they need, on what path, for how long, and why. | That "I need access to engineering" is not a request. This is the chapter's centrepiece, not a garnish. |
| 11 | **cass** | Two people run the same command in the same directory and see different output. She is certain the machine is broken. | Isolating environment from filesystem — the student has to design the experiment that proves where the difference lives. |
| 12 | **ops-bot** | Asked what the cleanup script does, it reports the script's own log line: "cleanup complete, 0 files removed." | That a log is a claim, not a record. Zero files removed should have been the question all along. |
| 13 | **rhea** | She wants a tool installed station-wide. The student has to explain what an unlisted repository costs, to somebody who considers that pedantry. | Explaining a supply-chain risk without jargon and without moralising. |
| 14 | **the captain** | Asked about the archive discrepancy, gives the first plausible explanation — a bad export — and is satisfied. Does not lie. | Accepting a plausible answer is how fourteen months happen. The student has to keep pulling with nothing but a hash mismatch. |
| 15 | **the captain** | The final scene. Confronted with the timeline, does not deny it, does not apologise, and explains the reasoning: recertification, a calibration artefact, a station full of people. | There is no rebuttal to write. The student files the report anyway. That is the course's last lesson and it is not a technical one. |

### Scene rules for authors

- **The character is not a hint system.** A student who asks "what's the answer" gets the answer the
  character would actually give, which is usually "that's your job."
- **A scene must be finishable in ten exchanges.** If it isn't, the character is withholding too
  much — see the difficulty dial in `GAMEMASTER_PROTOCOL.md`.
- **Never let a scene stall.** If the student is lost, the character volunteers a *fact*, never a
  method. cass can say the report stopped at 03:00; she cannot say to use `grep -c`.
- **rhea is right more often than the student expects.** Two of her three scenes have her making a
  correct objection. She is an obstacle, not an antagonist, and the difference is that she updates.
- **ops-bot has no opinions and no manners.** Every ops-bot scene is a lesson in question quality.
