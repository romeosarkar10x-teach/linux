# CHALLENGE_DESIGN.md — incidents, CTF, and roleplay

Direct user instruction, and now a hard requirement on every chapter:

> "Maybe more exercises / challenges. Better CTF / story based / role play type challenges! Create
> interesting scenarios, etc."

Fun is not decoration here. It's the retention mechanism, and the difference between a student who
finishes Chapter 9 and one who doesn't. This document specifies the machinery.

---

## 1. The three challenge formats

Beyond the six tiers in `LESSON_SPEC.md`, each chapter carries at least one of these. The capstone
carries all three.

### A. Incident (chapter finale)
The `NN-incident-NN` lesson. A thing has broken. The student diagnoses and fixes it using only that
chapter's tools. Structure:

1. **The page** — an in-character message: a ticket from rhea, a log excerpt, a note from the
   captain. Two to five sentences. States the *symptom*, never the cause.
2. **The constraint** — something that rules out brute force. "The comms window closes in ten
   commands." "You may not read the file directly." "rhea is watching; don't touch engineering
   data."
3. **The dig** — investigation. Multiple plausible leads, at least one **red herring**.
4. **The fix or the find** — the flag, or a verified repair the validator checks.
5. **The debrief** — the student writes 3 sentences: what broke, how they knew, what they did.
   The debrief is graded. Repairing something you can't explain is a PASS-WITH-NOTES at best.

### B. Chained CTF (multi-stage)
A flag that unlocks the next stage rather than ending the exercise. Each stage uses a *different*
skill from the chapter, so the chain audits the whole chapter rather than one lesson.

```
stage 1: find a filename        (chapter skill A)
stage 2: the file is a decoy; the real one is named in its header   (skill B)
stage 3: the real file is unreadable as-is                          (skill C)
stage 4: KESTREL{...}
```

Rules:
- Every stage must fail **loudly and informatively** when done wrong. A stage that fails silently
  teaches nothing and gets abandoned.
- Stage 1 must be solvable by a student who has read the notes and nothing else. The cliff comes at
  stage 2 or 3, never stage 1.
- Maximum four stages. Five is where students quit.
- Intermediate stage tokens use the format `STAGE{...}` so they're visibly distinct from a real
  flag. Only the terminal `KESTREL{...}` registers with `kestrel flags`.

### C. Roleplay (live, with an agent)
The student interacts with a crew member played by an AI agent in **GAMEMASTER** mode
(`docs/GAMEMASTER_PROTOCOL.md`). The crew member has knowledge, an attitude, and a reason not to
just hand over the answer.

This exists because half of real sysadmin work is extracting a usable problem statement from a
human who is describing symptoms badly. That's a skill, it's teachable, and no static exercise
teaches it.

Examples:
- **cass** reports "the logs are broken." She means one specific thing. The student has to ask
  questions until they know what.
- **rhea** refuses to grant access until the student can state *precisely* what they need and why —
  a least-privilege exercise disguised as a conversation (Chapter 10).
- **ops-bot** answers only in exact, literal terms and never infers intent. Ask a sloppy question,
  get a useless answer. (Chapters 9 and 12. It is a machine; treat it like one.)

---

## 2. Flag design rules

- **Unobtainable without the chapter's skill.** Before shipping, try to crack it with only earlier
  chapters' tools. If it falls, replant it.
- **Never greppable.** No flag in plaintext anywhere a `grep -r KESTREL /` would surface it early.
  Common plants: inside an archive, past a permission boundary, in a file only reachable by
  following links, split across records that must be joined, in a process's environment, in an
  inode-linked file with a misleading name, produced only by running a repaired script.
- **The flag text should mean something.** `KESTREL{ops_bot_never_slept}` earns a reaction;
  `KESTREL{a7f3d9}` does not. The reaction is the memory hook.
- **Red herrings are required, decoy flags are banned.** Plant misleading *files*, never a
  plausible-looking `KESTREL{...}` that fails on submission. Submitting a good-faith find and being
  told "no" with no explanation is demoralising, not challenging.
- Plaintext lives only in `solutions.md`; register the salted hash in `container/flags.tsv`.

## 3. Scenario quality bar

A scenario earns its place if a student would repeat it to someone else. Concretely:

- **Symptom first, cause never.** "The disk is full but `du` says it isn't" beats "practice using
  `lsof`". (That one is real, and it's Chapter 14.)
- **One surprising fact per incident.** Deleted-but-open files still consume disk. A process can
  outlive the terminal that started it. A directory's `x` bit means traverse, not execute. Build the
  incident around the surprise.
- **The tool must be the natural move**, not a hoop. If the student's honest instinct is to open a
  text editor, the scenario is wrong — scale it up until the editor stops being viable. Three files
  invite an editor; four thousand do not.
- **Failure must be recoverable.** Everything lives in a lab dir; `kestrel reset` restores it. Say
  so in the briefing so students take real risks.
- **Time pressure only when diegetic.** "The comms window closes" is fine. A real stopwatch is not
  — this course is not a timed exam, and a hurried student copy-pastes.

## 4. The sabotage arc

A thread runs under all sixteen chapters and resolves in Chapter 15. It should be *noticeable* by
Chapter 6 and *undeniable* by Chapter 11.

| Ch | Trace left |
|---|---|
| 1 | a truncated command in history, cut off mid-word |
| 2 | a directory with a name designed not to be typed |
| 3 | a symlink pointing somewhere that no longer exists |
| 4 | a manifest for a tree that was deleted, not moved |
| 5 | files named to defeat globbing — deliberately, not accidentally |
| 6 | log lines removed; the gap is visible in the sequence numbers |
| 7 | one access-log entry from an account that shouldn't exist |
| 8 | a program writing errors to a place nobody would look |
| 9 | a process running under `ops-bot` that `ops-bot` never scheduled |
| 10 | a setuid binary, owner `dorn`, dated the night he left |
| 11 | a `.bashrc` line that quietly hides one thing from `ls` |
| 12 | a "cleanup" script that is not cleaning up |
| 13 | a package installed from a repository nobody added |
| 14 | an archive whose checksum doesn't match its manifest |
| 15 | all of it, assembled into a timeline |

Each trace must be **solvable and complete on its own** — a student who never notices the arc still
passes every chapter. The arc is a reward for attention, never a dependency.

Rule for authors: plant the trace as an *artifact*, never as narration. The student should find it,
not be told about it.

## 5. Volume

The user asked for more. Per chapter, on top of the tier minimums:

- **≥ 1 Incident** (the chapter finale)
- **≥ 1 chained CTF** from Chapter 5 onward
- **≥ 1 roleplay** exercise from Chapter 6 onward
- **≥ 1 sabotage-arc artifact**, findable but never required

These are exercises, not extras: they count toward the ~50-per-chapter target and get full
`help.md` / `validation.md` / `solutions.md` treatment like everything else.

## 6. What not to do

- No puzzle that hinges on guessing a filename or a password.
- No riddles, no wordplay-as-obstacle, no lore quizzes. The Linux system is the puzzle.
- No scenario requiring an untaught tool. Check the syllabus order first, every time.
- No fake urgency, no scolding, no "you have failed the station" framing. Dry, competent, a little
  gallows-humoured — the voice of a station log.
- No story prose crowding out the technical explanation. The notes are the product; the station is
  the room it happens in.
