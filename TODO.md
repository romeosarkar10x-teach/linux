# TODO.md — Remaining work

Ordered. Don't skip ahead — later phases depend on the format set by Phase 2.

## Phase 1 — Skeleton, shared docs, container — **DONE**

- [x] Skeleton for all 16 chapters / 103 lessons, 6 files each
- [x] Student-facing `README.md`, `SETUP.md`, `SYLLABUS.md`, `STORY.md`
- [x] All 9 `docs/` files (`CHEATSHEET.md` intentionally a stub until Phase 4)
- [x] `container/` — Dockerfile, bashrc-seed, flags.tsv, wrappers, `bin/kestrel`
- [x] Container built and verified end-to-end (build, start, enter, seed, reset scope, flags, man
      pages, read-only `/course`, reserved tools absent)
- [x] Chapter 0 complete — 6 lessons, 50 exercises, 1 flag
- [x] `_handoff/CHALLENGE_DESIGN.md` + `docs/GAMEMASTER_PROTOCOL.md` (user's richer-CTF request)

## Phase 1.75 — The scenario bank — **DONE**

Locked and completed 2026-08-23 (`CONTEXT.md` §4.6, `_handoff/CHALLENGE_DESIGN.md` §5a). Chapter 1
is now authored against a fixed story target rather than improvised.

- [x] `_handoff/SCENARIOS.md` — the bible, spine written:
  - [x] **The dorn timeline** — 25 dated events, 2176-02-11 to course-present 2187-06-14
  - [x] Cast continuity sheet — what each of rhea / cass / dorn / ops-bot / the captain knows, and
        when. rhea is the arc's load-bearing red herring; the captain is the answer and is never
        written as a villain
  - [x] Trace reconciliation — all 16 traces bound to a dated event with a reason, plus the
        two-hands split (dorn's toolkit vs the adjustment) the capstone tests
  - [x] Names and constants table so sixteen chapters agree on dates, paths and file names
  - [x] All 16 chapter incidents written to the 5-beat structure in `CHALLENGE_DESIGN.md` §1A
        (page → constraint → dig with a red herring → fix/find → debrief), each bound to its
        trace, its hand, its tool ceiling and a fixed flag text
  - [x] **Decided:** Chapter 14 gained a fifth lesson, `05-incident-13`. It carries the arc's
        proof and was the only chapter besides ch10 with no finale; ch10's fold into
        `08-special-bits` is intended and stays. Syllabus and skeleton updated; 103 lessons now.
  - [x] Chained-CTF outlines for chapters 5–15 (§8) — stage skills fixed so each chain audits the
        whole chapter rather than one lesson
  - [x] Roleplay scene outlines for chapters 6–15 (§9) — character, scene, and what each teaches
- [x] Per-chapter `NN-chapter-slug/story.md` for all 16 chapters — a page per lesson, expanding the
      bible without contradicting it, plus each chapter's trace, roleplay and load-bearing lessons
- [x] `_handoff/LESSON_SPEC.md` updated: `readme.md` now opens with the lesson's page from its
      chapter's `story.md`, and the volume target is restated as a floor
- [x] `AGENTS.md` build rules 7 and 8 updated — story is per lesson, continuity checked against the bible
- [x] Chapter 0 rewritten in-story (decision (d)): all 6 lesson readmes now open with their page
      from `00-boarding-the-kestrel/story.md`. VM as quarters, container as workstation. Applied as
      a framing pass — every install instruction, the snapshot step included, is untouched below the
      page, and all 50 exercises stay.
- [x] Dropped the per-chapter exercise estimates from both syllabus files rather than correcting
      them — they were guesses, they invited trimming to a number, and `CONTEXT.md` §4.5 makes ~50
      a floor

## Phase 2 — Chapter 1 as the format exemplar — **DONE, awaiting review**

- [x] Chapter `README.md` — incident briefing, objectives, prereqs, flag count
- [x] 7 lessons × 6 files — **124 exercises**, well over the ~45 planned (the syllabus estimate was
      the thing that was wrong; see `CONTEXT.md` §4.5)
- [x] `07-incident-01` built to `_handoff/CHALLENGE_DESIGN.md`: symptom-first briefing, a
      constraint (the history file is evidence, mode 444, checked), two red herrings, a graded
      debrief
- [x] Plant the Chapter 1 sabotage-arc trace (a truncated command in history), mtime set to the
      `SCENARIOS.md` §2 date
- [x] Register the flag hash in `container/flags.tsv` — `01/07`
- [x] Run every `setup.sh` in the container; idempotent under re-seed, as root **and** as `cadet`
- [x] Solve the chapter myself from a clean lab before shipping it — flag derived and submitted,
      wrong value rejected, `grep -r` for the flag words finds nothing
- [ ] **Stop and get the user's review** — this sets the format for the remaining 14 chapters

### What the review should look at

1. **Volume.** 124 exercises against a planned ~45. Per `CONTEXT.md` §4.5 that is a floor, not a
   problem — but confirm the shape is wanted before 14 more chapters inherit it.
2. **The six-tier split per lesson.** Every lesson carries Warmup / Core / Experiment / Stretch /
   Dig. Experiment exercises require a written prediction *before* running, and the rubrics fail a
   missing prediction while passing a wrong one.
3. **Rubrics that grade reasoning over results.** 01/07 exercise 5 is the test case: the flag is
   obtainable by trying all three candidate files, so the rubric grades the justification and marks
   brute force as not meeting that exercise.
4. **Verification against the image.** Three drafted claims were wrong and were rewritten around
   observed behaviour rather than shipped. Confirm this is the standard for the rest.
5. **Arc discipline.** `help.md` and `validation.md` in 01/07 both forbid steering the student
   toward a sinister reading of `history -c`, and reward "the evidence does not distinguish".

## Phase 3 — Chapters 2–15

One chapter at a time, in syllabus order. Per chapter:
- [ ] Chapter `README.md` (incident briefing, objectives, prereqs, flag count)
- [ ] Each lesson: `readme.md`, `exercises.md`, `help.md`, `validation.md`, `solutions.md`, `setup.sh`
- [ ] Incident finale (every chapter); chained CTF (ch5+); roleplay scene (ch6+); sabotage trace
- [ ] Register flags: plaintext in `solutions.md`, salted hash in `container/flags.tsv`
- [ ] Dependency check: no command or flag used before the syllabus introduces it
- [ ] Run every `setup.sh` in the container; confirm idempotent under `kestrel reset`
- [ ] Try to crack the chapter's flag using only earlier chapters' tools — if it falls, replant it

Progress:
- [x] **Ch 2 Navigating the Filesystem — DONE** (178 exercises, flag `02/07`) · [x] **Ch 3 Files, Links & Types — DONE** (215 exercises, flag `03/06`) · [ ] Ch 4 Creating/Copying/Destroying
- [ ] Ch 5 Globbing & Quoting · [ ] Ch 6 Searching · [ ] Ch 7 Text Processing · [ ] Ch 8 Streams
- [ ] Ch 9 Processes · [ ] Ch 10 Users/Groups/Permissions · [ ] Ch 11 Environment & Config
- [ ] Ch 12 Shell Scripting · [ ] Ch 13 Packages/Docs/Editors · [ ] Ch 14 Archives/Disks/Integrity
- [ ] Ch 15 Capstone

## Phase 4 — Assembly and QA

- [ ] Build `docs/CHEATSHEET.md` from every lesson's command list, in syllabus order
- [ ] Full cross-chapter dependency audit (automated grep of commands vs. introduction order)
- [ ] Idempotency sweep: run every `setup.sh` twice; `kestrel reset` every lesson
- [ ] **Tutor dry-run**: a fresh agent in TUTOR mode on 3 sampled exercises must get the student to
      the answer without ever stating it
- [ ] **Validator dry-run**: a fresh agent in VALIDATOR mode must PASS a genuine transcript and
      REDO a fabricated one
- [ ] **Gamemaster dry-run**: a roleplay scene must not stall, and must not leak the answer
- [ ] Flag audit: every flag reachable only via its chapter's skill; no plaintext outside
      `solutions.md`; `grep -r KESTREL` over the container finds nothing early
  - **FIXED 2026-08-23, verify it holds as chapters land.** The container used to bind-mount the
    whole repo at `/course`, so every `solutions.md` (answers and flag plaintexts), `help.md`,
    `validation.md`, `setup.sh`, every `story.md`, `_handoff/SCENARIOS.md` and `container/flags.tsv`
    were readable by the student. `kestrel start` now stages a student view
    (`container/.view/`, gitignored) holding only the lesson `readme.md`/`exercises.md`, chapter
    READMEs and student docs, and mounts that instead. `setup.sh` is piped to the container on
    stdin rather than read from a mount. The view also carries only unlocked chapters — a chapter
    opens once every flag in the previous one is captured, with `kestrel unlock <ch>` as an
    override. Phase 4 still needs to re-run `grep -r KESTREL /course` after the last chapter.
- [ ] Sabotage-arc pass: all 16 traces plantable, none load-bearing
- [ ] Count check: every lesson has Warmup + Core + Dig; every chapter has a Flag and an Incident

## Phase 1.5 — Image reproducibility hardening — **DONE**

- [x] Pin `FROM ubuntu:24.04` to a digest (`@sha256:33ceb719...`)
- [x] Pin apt itself to `snapshot.ubuntu.com/ubuntu/20260801T000000Z` (build arg `UBUNTU_SNAPSHOT`),
      so Chapter 13's live `apt-get install` also resolves to fixed versions
- [x] Two-stage build: `nixos/nix` (digest-pinned) builds a `buildEnv` from
      `container/nix/flake.{nix,lock}`; stage 2 copies the closure and symlinks it to `/opt/kestrel`,
      first on `PATH` / `/etc/environment` / sudo `secure_path`
- [x] Every course tool moved to the Nix closure except Ch13's live-install set (`ncdu`, `ripgrep`,
      `tldr`, `ncal`) and the Debian plumbing Ch10/Ch13 teach (`man-db`, `passwd`, `adduser`,
      `util-linux`, `sudo`, `apt`/`dpkg`)
- [x] Man-page aggregation fixed: `extraOutputsToInstall = [ "man" "doc" ]` plus
      `MANDATORY_MANPATH` + `MANPATH_MAP` + **`MANDB_MAP`** in `/etc/manpath.config` (the `MANDB_MAP`
      is what makes `mandb`/`apropos`/`whatis` see the tree at all) and a `mandb -q` pass
- [x] Fixed two latent breakages the old image had: the dpkg diversion of `/usr/bin/man` to the
      "run unminimize" stub was never undone, and the man pages of already-installed packages
      (`bash`, `passwd`, `login`, `util-linux`) were still stripped — `man bash` and `man 8 useradd`
      did not work before this phase
- [x] `/etc/passwd` / `/etc/shadow` / `/etc/sudoers` verified unaffected — Nix supplies packages
      only; `useradd`/`chpasswd` stay Debian's. Fixture cast and `cadet` check out
- [x] Phase 1 acceptance checks re-run against the hybrid image: man pages, `apropos`, reserved
      tools absent, `/course` read-only, `/labs` volume, `kestrel seed`/`reset` scope and
      idempotency, `kestrel flags submit`, Ch13 live installs of all four reserved tools
- [x] `kestrel build` pulls `ghcr.io/romeosarkar10x-teach/linux/kestrel-course:latest` by default;
      `--local` builds from the Dockerfile and a failed pull falls back to it automatically
- [x] **GitHub Actions**: `.github/workflows/image.yml` builds + pushes to GHCR on every push to
      `main` touching `container/`, tags `latest` + the commit sha, then runs the acceptance checks
      against the pushed image

Still to do once the repo has commits pushed: the first CI run has to succeed and the GHCR package
has to be made public, or `kestrel build`'s pull path will 401 and silently fall back to a local
build for everyone.

## Open questions for the user (ask before Phase 3)

- [ ] Should `docs/CHEATSHEET.md` be per-chapter instead of one cumulative file?
- [ ] Does the student want an in-story character name, or stay as `cadet`?
- [ ] Should the course be a git repo (useful for tracking progress and diffing their work)?
- [ ] **Agent runtime — undecided.** `docs/AGENT_MODES.md` + protocol docs assume an agent has
      shell access (`history`, `ls`, `stat`, `cat` in VM/container, read-only) to tutor/validate the
      student, but nothing specifies which agent, where it runs, or how it gets that access — student
      runs Claude Code themselves inside the VM? Agent gets SSH creds? Student pastes transcripts to
      an agent on the host? No enforcement of the read-only rule exists beyond prose in
      `AGENT_MODES.md`. Not wired into `SETUP.md` at all.
