# 04/05 — Validation (agent eyes only)

No auto-grading. A validating agent reads the student's transcript against this file. Full answers
are in `solutions.md`.

**Expected end state:** a fifteen-file tree under `rebuild/` at the recorded sizes, built with brace
expansion and `mkdir -p`; a written decision about which manifest is authoritative and why; the
duplicate row resolved by measurement; and the flag `KESTREL{deleted_not_moved}` accepted by
`kestrel flags submit`.

---

## Reference table

| # | Question | Correct result |
|---|---|---|
| 1 | files in `salvage/` | 2 |
| 3 | manifest rows | 16 rows, 29 lines |
| 4 | which is older | `.bak`, by 9h08m; marked "not for readback" |
| 5 | `.bak` differences | faults first; 3 files missing; morning `recorded` times; sizes agree |
| 8 | files described | **15** (16 rows) |
| 9 | the duplicate | `readings/2187-05-17-1804.txt`, 512@18:04 and 1180@18:08, 4 min apart |
| 11 | salvaged file size | 1180, mtime 18:08 — matches the second row |
| 14 | the directories | one `mkdir -p rebuild/{readings,faults,handover}` |
| 17 | the readings sizes | 1024, 1536, 2048, **1180**, 768, 640, 896 |
| 20 | file count | 15 |
| 21 | manifest total | 13,308 bytes (13,820 if the superseded row was counted) |
| 22 | `.bak` tree | 12 files; 3 missing; internally consistent |
| 23 | `.bak` readback | `notdetedmoed` — not three words |
| 24 | `cmp` | differs at byte 1; same size only |
| 29 | raw readback | `deleetednotmoved`, 16 letters |
| 30 | letter dropped | the `e` of the 18:04 row ("end of shift copy") |
| 31 | flag | `KESTREL{deleted_not_moved}` |

---

## Warmup (1–4)

**Goal.** The student reads the manifest as a document — header, table, footer — before using it.

**Accept.** The four column names; the readback instruction from the header stated in the student's
own words; both manifest mtimes with the gap; the `.bak`'s self-description.

**Reject.** An answer to exercise 2 that lists only the columns. The header instruction is the
mechanism of the entire lesson and skipping it means the flag will be reverse-engineered later
instead of read out.

**Red flags.** The student went straight to `rebuild/`. Send them back to exercise 2.

## Core (5–20)

**Goal.** Resolve two disagreeing records against physical evidence, then rebuild with the chapter's
tools rather than by brute force.

**Accept.**
- **6–7:** a decision grounded in `salvage/handover/2187-05-15.txt` existing on disk and appearing
  only in the later manifest. Accept "the `.bak` says it is a working copy" as *supporting*
  evidence; do not accept it alone, and do not accept "newer is better" alone.
- **8:** 15, with the rows-versus-files distinction stated.
- **10:** both stories offered before the notes are used to choose.
- **11–12:** the `stat` output quoted. The resolution must come from the measurement; the
  `copy-notes.txt` confirmation may follow but must not replace it.
- **13:** a rule that puts evidence above ordering.
- **14:** one command. This is the chapter's constraint made concrete.
- **15–17:** any method that produces exact sizes; `head -c`, `truncate -s`, `yes | head -c` all
  fine. `truncate` deserves a note about sparseness for exercise 21.
- **18:** `cp`, with the reason. `mv` is a fail on rule 4 even though the tree ends up correct.
- **19–20:** fifteen files, all sizes matching, and a statement that `du -sb` cannot be compared to
  the manifest total directly.

**Reject.**
- A tree built with fifteen or more separate `mkdir` calls (see Roll-up — this is the documented
  pass-with-notes case, and if the student also built the files one command each with no attempt at
  expansion, it is a Redo of 14–17).
- 512 used for `2187-05-17-1804.txt`.
- Sixteen files in `rebuild/` — meaning both duplicate rows were built, which is only possible by
  inventing a name the manifest does not contain.
- `grep`/`awk`/`sed`/`find -name` used to answer 5, 8 or 9. Out-of-chapter, and here they also skip
  the reading the exercises are testing.

**Red flags.** `salvage/` empty at the end. Ask what evidence remains for exercise 12; the honest
answer is none, and the student should reset and redo 11–18.

**Distinction.** A student who notices in exercise 5 that the **sizes agree** between the two
manifests for every shared path, and says so — that is why the `.bak` is dangerous rather than
obviously wrong, and most students miss it.

## Experiment (21–24)

**Goal.** Make the red herring's damage concrete, and be precise about what a reconstruction is.

**Accept.** Written predictions before each run. For 22, an actual second tree built in a
`mktemp -d` and compared — not a thought experiment — with the answer "three files differ and no, I
would not have noticed". For 23, `notdetedmoed` and the inference that rows are missing. For 24, the
`cmp` output and a clear statement that only names, paths and byte counts were reproduced.

**Reject.** Missing predictions. "I would have noticed" for 22 without saying how — the tree from the
`.bak` is internally consistent and there is nothing in it to notice.

**Red flags.** A student who built the `.bak` tree inside `rebuild/` and contaminated their own work.
Reset and rebuild.

**Distinction.** Exercise 21 answered with the directory-inode explanation *and* a check that the
fifteen file sizes sum to 13,308, catching the 13,820 trap without being told about it.

## Stretch (25–28)

**Goal.** Answer the archivist's second question honestly, which means answering it in the negative.

**Accept.**
- **25:** `rename(2)` semantics — inode and link count unchanged within a filesystem, new inode
  across one — drawn from lesson 03's own measurements.
- **26:** "none of it". The lab holds no inode numbers, link counts or ctimes from the original
  filesystem. Accept any correct statement of what would have had to be recorded and when.
- **27:** two sentences that do not assert deletion as fact.
- **28:** the copy-versus-original point, in one sentence.

**Reject.** Exercise 27 claiming the tree was deleted. The evidence does not support it, and the
flag is not evidence — it is a readback of somebody's conclusion. This is the single most important
rejection in the lesson.

**Red flags.** A student who treats exercise 26 as a trick question and invents evidence. Ask them to
point at the file it is in.

**Distinction.** A student who spots the tension between exercise 27 and the flag text and raises it
unprompted. Agree with them. That is the strongest possible outcome for this lesson.

## Dig (29–33)

**Goal.** The readback, done by hand, with the extra letter removed for a stated reason.

**Accept.** The raw sixteen-letter sequence reported *before* tidying (29); the dropped letter
identified as the 18:04 row's `e` with the measurement as the reason (30); the flag accepted (31);
a debrief covering all three of the manifest's purpose, the duplicate, and the consequence (32); and
a 33 that stops.

**Reject.** A flag arrived at by guessing that the words should be "deleted not moved" and
back-filling. Ask for the raw sequence and the reason for the drop; if they cannot produce them, the
Dig tier is a Redo even though the flag is right.

**Red flags.** Exercise 33 answered with a name. Nothing in the lab names anyone. If the student
names somebody, ask what supports it, and record that they did — it is the exact failure the
chapter's rules of engagement are training against.

**Distinction.** A 30 that explicitly says "I dropped the letter belonging to the row whose file I
measured as non-existent, and I would have dropped the other one if `salvage/` had held a 512-byte
file" — the rule, not the instance.

---

## Added exercises (34–52)

**34.** 29 and 20. The second half is the marking: the extra lines in the authoritative file must be
identified as the readback convention, not merely counted. "The manifest is longer because it has
more rows" is wrong — it has *four* more rows and *five* more non-row lines.

**35.** Any command that prints exactly lines 12–27 passes; `head -27 | tail -16` is the expected
shape. Must state where the numbers came from (`nl -ba`, or counting). Accept `sed -n '12,27p'` from
a student who has met it. The fragility observation is required for a clean pass: the answer should
say that adding a row breaks both numbers.

**36.** 13820 and 13308, and the difference explicitly attributed to the 512-byte row with the
exercise-11/12 reasoning restated. A student who reports 13820 for both, or who subtracts the wrong
row, has not carried the duplicate resolution forward.

**37.** The exact line and status 1. The marking is on the second half: `cmp` located a difference
that does not matter and cannot report the ones that do. If the student treats "differ: byte 44" as a
finding about the incident, that is a Redo on this exercise.

**38.** The five lines, footer first. Reason must be about adjacency of claim and evidence, not "tac
is a neat trick".

**39.** All four rows, and the observation that every one is after 09:12 — with the `.bak`'s own
footer quoted. The point is that the `.bak` is *earlier*, not *wrong*; a student who calls it
falsified has misread the lab.

**40.** 12 and 12, footer correct, and — the actual content — a correct self-count says nothing about
completeness. Watch for "the count is right so the file is fine".

**41.** 15 and 4. Accept 3 directories only with an explicit note that the top of the tree was
excluded on purpose; silent 3 is a miscount. 16 files means the 512 row was rebuilt: Redo, and refer
back to exercise 12.

**42.** Two `touch -d` commands with the times grouped correctly. Then the harder half: the student
must say that these mtimes are transcribed from the manifest and are therefore not evidence. An
answer that stops at "now the tree matches the manifest" is a Pass-with-notes; an answer that offers
the rebuilt tree as corroboration of the manifest is circular and is a Redo.

**43.** `cp -p`/`cp -a` named, and 18:08/18:17 preserved. The distinction between a measured mtime
and a typed one is the exercise; both halves of the tree exist in the same `ls -l` and only the
student can tell them apart.

**44.** 13308 / 32K on `rebuild`, 1884 / 20K on `salvage`, with the 20K broken down: three
directories plus two block-rounded files. "20K is wrong" is a Redo — both numbers are right and
answer different questions.

**45.** The `*` collapse and offset `0002234` = 1180. `wc -l` 0. The conclusion — a size column
reconstructs size and nothing else — is the point of the exercise.

**46–49.** Predictions must be written before running. 46: byte 1, status 1. 47: 0 and 26, with
`wc -l` counting newlines. 48: 4, block allocation. 49: mtime set, ctime now, and the explicit
statement that the reconstruction is detectable as one — which is a *good* property, not a defect. A
student who says the ctime "gives the game away" and proposes to hide it has the ethics backwards;
say so.

**50.** `not deted moed`, and the recognition that this is a failed readback. Full marks require
citing the manifest's own rule ("must not be acted on") and noticing the `.bak` header said so
already. A student who forces the letters into three plausible words has broken the check rather than
run it.

**51.** At least three of: inode, device, link count, content hash, ctime — with the *reason*, not
the name. The inode/device pair carrying the deleted-vs-moved answer is the one that must be there
for a clean pass. Full marks also note that all of these were free to record at manifest time.

**52.** Both halves: what a manifest fixes (state at an instant) and what it cannot (anything after).
The second sentence should point at event records — audit log, journal, shell history — and admit
this lab has none. An answer that concludes the manifest settles the question fails the lesson.

**Red flags across the block.** Rebuilding the 512-byte row. Presenting the reconstructed tree as
evidence about the original. Reading `cmp`'s byte 44 as a finding. Forcing the `.bak` readback into
words. Any of these is a Redo regardless of the flag.

---

## Roll-up

**Clean pass.** Manifest read as a document; authority decided on evidence; duplicate resolved by
measuring `salvage/`; tree built with brace expansion and `mkdir -p` in a small number of commands;
`cp` not `mv`; predictions written; exercise 26 answered in the negative; readback done by hand and
the dropped letter justified; flag accepted.

**Pass with notes.** The tree is correct but was built with a directory-per-command or a file-per-
command with no attempt at expansion. The duplicate was resolved from `copy-notes.txt` alone without
measuring. `.bak` rejected for being old rather than for being incomplete.

**Redo.** The tree was built from the `.bak`. Or `512` is in the rebuilt tree. Or `salvage/` was
emptied with `mv`. Or the flag was guessed rather than read out. Or exercise 27 asserts deletion as
established fact.

**Chapter complete when** the student can say what a manifest proves, what it cannot, and why
"deleted" and "moved" are different questions that leave different evidence — and can admit that the
evidence to answer the second one is not here.
