# TODO.md — Remaining work

Ordered. Don't skip ahead — later phases depend on the format set by Phase 2.

## Phase 1 — Skeleton, shared docs, container — **DONE**

- [x] Skeleton for all 16 chapters / 102 lessons, 6 files each
- [x] Student-facing `README.md`, `SETUP.md`, `SYLLABUS.md`, `STORY.md`
- [x] All 9 `docs/` files (`CHEATSHEET.md` intentionally a stub until Phase 4)
- [x] `container/` — Dockerfile, bashrc-seed, flags.tsv, wrappers, `bin/kestrel`
- [x] Container built and verified end-to-end (build, start, enter, seed, reset scope, flags, man
      pages, read-only `/course`, reserved tools absent)
- [x] Chapter 0 complete — 6 lessons, 50 exercises, 1 flag
- [x] `_handoff/CHALLENGE_DESIGN.md` + `docs/GAMEMASTER_PROTOCOL.md` (user's richer-CTF request)

## Phase 1.75 — The scenario bank — **blocks Phase 2**

Locked 2026-08-23 (`CONTEXT.md` §4.6, `_handoff/CHALLENGE_DESIGN.md` §5a). Nothing in Phase 2 starts
until this is done — Chapter 1 must be authored against a fixed story target, not improvised.

- [ ] `_handoff/SCENARIOS.md` — the bible:
  - [ ] **The dorn timeline.** Who he was, what he actually did, with whom, why, and on what dates.
        This is the spine Chapter 15 assembles; it does not exist yet in any file.
  - [ ] Cast continuity sheet — where each of rhea / cass / dorn / ops-bot / the captain is, and
        what they know, at each chapter. A character cannot know in ch3 what they learn in ch9.
  - [ ] All 16 chapter incidents written to the 5-beat structure in `CHALLENGE_DESIGN.md` §1A
        (page → constraint → dig with a red herring → fix/find → debrief)
  - [ ] Reconcile the 16 sabotage traces (§4) against the timeline — each must be something dorn
        plausibly did, on a date that fits, for a reason the capstone can state
  - [ ] Chained-CTF outlines for chapters 5–15; roleplay scene outlines for chapters 6–15
- [ ] Per-chapter `NN-chapter-slug/story.md` for all 16 chapters — scene text per lesson, expanding
      the bible without contradicting it
- [ ] Update `_handoff/LESSON_SPEC.md`: the lesson file set now includes an opening in-character
      page in `readme.md` (≤ 4 sentences, frames but never teaches)
- [ ] Update `AGENTS.md` build rule 7 — story is per lesson now, not only per chapter
- [ ] Rewrite Chapter 0 in-story (decision (d)): VM as quarters, container as workstation, across
      all 6 lessons. **Guard:** no framing may obscure a literal install instruction; where the two
      conflict, the instruction wins. The 50 existing exercises stay — this is a framing pass, not a
      content cut.
- [ ] Update `_handoff/SYLLABUS.md` per-chapter exercise estimates to match reality (Ch0: ~12 → 50)
      and drop the stale `~630` headline total

## Phase 2 — Chapter 1 as the format exemplar

- [ ] Chapter `README.md` — incident briefing, objectives, prereqs, flag count
- [ ] 7 lessons × 6 files, ~45 exercises
- [ ] `07-incident-01` built to `_handoff/CHALLENGE_DESIGN.md`: symptom-first briefing, a
      constraint, a red herring, a graded debrief
- [ ] Plant the Chapter 1 sabotage-arc trace (a truncated command in history)
- [ ] Register the flag hash in `container/flags.tsv`
- [ ] Run every `setup.sh` in the container; verify idempotency under `kestrel reset`
- [ ] Solve the chapter myself from a clean lab before shipping it
- [ ] **Stop and get the user's review** — this sets the format for the remaining 14 chapters

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
- [ ] Ch 2 Navigating the Filesystem · [ ] Ch 3 Files, Links & Types · [ ] Ch 4 Creating/Copying/Destroying
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
- [ ] Sabotage-arc pass: all 16 traces plantable, none load-bearing
- [ ] Count check: ~630 exercises; every lesson has Warmup + Core + Dig; every chapter has a Flag

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
