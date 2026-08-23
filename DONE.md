# DONE.md — What exists so far

Status: **planning complete. Phases 1 and 2 complete, Phase 3 under way — skeleton, all shared docs, working
container, scenario bank, and Chapters 0, 1 and 2 written in full.** Chapters 3–15 are stubs.

## Completed

### Research
- [x] Read the full boot.dev *Learn Linux* course at
      `/home/romeo/github/romeosarkar10x_hack/boot_dev_course_scraper/courses/learn-linux`
      — 7 chapters, 66 lessons, 133 files.
- [x] Mapped all three boot.dev lesson types and their check mechanisms.
- [x] Extracted the student's exact knowledge ceiling and gap list → `_handoff/SOURCE_COURSE.md`.
- [x] Researched the current agent-instruction file standard (AGENTS.md) and applied it.

### Decisions (all confirmed by the user)
- [x] Scope: drill + moderate extension; no full sysadmin path
- [x] Validation: AI agent rubric only, no auto-grader scripts
- [x] Sandbox: Docker inside the student's Ubuntu VM, one long-lived container
- [x] Pedagogy: teach then stretch
- [x] Volume: up to ~50 exercises per chapter
- [x] Story: CTF world — Orbital Station Kestrel
- [x] Filenames: `AGENTS.md` standard, `CLAUDE.md` as pointer
- [x] **Challenges: richer CTF / story / roleplay scenarios** (user, mid-Phase-1) →
      `_handoff/CHALLENGE_DESIGN.md`, `docs/GAMEMASTER_PROTOCOL.md`

All captured verbatim in `_handoff/QA_LOG.md`.

### Planning documents
| File | Contents |
|---|---|
| `AGENTS.md` | Root entrypoint for the building agent; read-order table; 8 build rules |
| `CLAUDE.md` | One-line pointer to `AGENTS.md` |
| `CONTEXT.md` | Mission, student, environment, every locked decision, output layout, non-goals |
| `_handoff/SYLLABUS.md` | **Approved TOC** — 16 chapters, 103 lessons |
| `_handoff/LESSON_SPEC.md` | The 6-file lesson set, templates, six exercise tiers, authoring rules |
| `_handoff/PROTOCOLS_SPEC.md` | Specs for the tutor / validator / authoring docs |
| `_handoff/CHALLENGE_DESIGN.md` | Incident format, chained CTFs, roleplay, flag-planting rules, the 16-chapter sabotage arc |
| `_handoff/CONTAINER.md` | Docker image, fixture users and groups, `kestrel` helper, reset semantics |
| `_handoff/STORY.md` | Narrative bible, cast, per-chapter incidents, flag rules |
| `_handoff/SOURCE_COURSE.md` | Complete boot.dev breakdown + the gap list |
| `_handoff/QA_LOG.md` | The user's decisions in their own words, plus the standards research |

### Phase 1 — shipped

**Skeleton** — 16 chapter directories, 102 lesson directories, 628 files. Every lesson has its 6
files; unwritten ones are marked `STUB`.

**Student-facing root docs** — `README.md`, `SETUP.md`, `SYLLABUS.md` (linked TOC), `STORY.md`.

**`docs/`** — all 9 shipped:
`AGENT_MODES.md` · `TUTOR_PROTOCOL.md` · `VALIDATION_PROTOCOL.md` · `GAMEMASTER_PROTOCOL.md` ·
`AUTHORING.md` · `SELF_CHECK.md` · `RECORDING.md` · `INSTALL_GUIDE.md` ·
`CHEATSHEET.md` (deliberate stub — assembled in Phase 4).

**`container/`** — `Dockerfile`, `nix/flake.nix`, `nix/flake.lock`, `bashrc-seed`, `build.sh`,
`run.sh`, `reset.sh`, `flags.tsv`, `bin/kestrel`. Plus `.github/workflows/image.yml`.

**Container verified working**, not just written:
- `kestrel build --local` succeeds; `kestrel build` pulls from GHCR with a local fallback
- image pinned three ways — base by digest, apt to a `snapshot.ubuntu.com` timestamp, course tools
  to `container/nix/flake.lock`
- course tools resolve to `/opt/kestrel/bin` (Nix); `apt`, `dpkg`, `useradd`, `sudo`, `man` stay
  Debian's, so chapters 10 and 13 behave as written
- man pages work for both halves — `man jq` (Nix) and `man bash` / `man 8 useradd` (apt) — and
  `apropos json` finds `jq`, which needed a `MANDB_MAP` for the Nix tree
- `hostname` → `kestrel`, `whoami` → `cadet`, groups `cadet sudo crew`
- fixture cast present: `rhea`, `cass`, `dorn`, `ops-bot`; groups `crew`, `engineering`, `ops`
- reserved tools confirmed absent (`ncdu`, `rg`, `tldr`, `ncal`) so Chapter 13 still works, and
  all four confirmed installable at runtime from the pinned snapshot archive
- `/course` mounted read-only — writes fail with `Read-only file system`
- `/labs` is a named volume on its own mount
- `lab 00/04` helper works in interactive shells; banner suppressed for non-interactive
- `kestrel flags submit` rejects a wrong flag (exit 1) and accepts the real one
- **`kestrel reset 00/04` verified to wipe only that lab** — home file, other lesson's lab, and
  captured-flag state all survived

**Scenario bank complete** (Phase 1.75) — `_handoff/SCENARIOS.md`, 669 lines: the dorn timeline
(25 dated events, 2176-02-11 → course-present 2187-06-14), a cast continuity sheet, all 16 traces
reconciled to dated events, the two-hands split the capstone tests, all 16 incidents at 5-beat
depth with fixed flag texts, 11 CTF chains and 10 roleplay scenes. Plus a `story.md` in every
chapter carrying a page per lesson.

**Chapter 0 complete** — 6 lessons × 6 files, all written, no stubs, rewritten in-story 2026-08-23:
| Lesson | Exercises |
|---|---|
| `01-what-this-course-is` | 6 |
| `02-vm-setup` | 7 |
| `03-install-docker` | 8 |
| `04-course-container` | 10, incl. the course's first flag |
| `05-getting-help` | 9 |
| `06-recording-your-work` | 10 |

**50 exercises in Chapter 0.** One flag registered: `00/04`, hash in `container/flags.tsv`.

**Chapter 1 complete** (Phase 2) — 7 lessons x 6 files, no stubs, chapter README written:

| Lesson | Exercises |
|---|---|
| `01-terminal-vs-shell-vs-tty` | 15 |
| `02-shells-on-the-box` | 17 |
| `03-command-anatomy` | 19 |
| `04-variables` | 20 |
| `05-readline` | 18 |
| `06-history` | 21 |
| `07-incident-01` | 14, incl. the chapter flag |

**124 exercises in Chapter 1.** One flag registered: `01/07`, hash in `container/flags.tsv`.

Verified, not just written:
- all 7 `setup.sh` run under `kestrel seed` from a clean `/labs`, and are idempotent — including
  re-running as `cadet`, not only as root
- every factual claim in the notes checked against the running image; three first-draft claims were
  wrong and were rewritten around what the image actually does (`bash --posix` does not disable
  `[[`; `bash -l` does not put a dash in `$0`; every path in this image's `/etc/shells` exists)
- the incident solved from a clean lab: flag derived, `kestrel flags submit` accepts it and rejects
  a wrong value
- flag is not greppable — `grep -r he_never_finished_typing /labs` returns nothing
- `dorn-bash-history` mtime set to the `SCENARIOS.md` timeline date, mode 444

**Chapter 2 complete** (Phase 3) — 7 lessons x 6 files, no stubs, chapter README written:

| Lesson | Exercises |
|---|---|
| `01-filesystem-tree` | 21 |
| `02-cd-and-ls-deep` | 25 |
| `03-the-fhs-tour` | 22 |
| `04-proc-and-sys` | 24 |
| `05-tree-and-stat` | 30 |
| `06-paths-in-anger` | 36 |
| `07-incident-02` | 20, incl. the chapter flag |

**178 exercises in Chapter 2.** One flag registered: `02/07`, hash in `container/flags.tsv`.

Verified, not just written:
- all 7 `setup.sh` run under `kestrel seed` from a clean `/labs`, idempotent under `kestrel reset`,
  and re-runnable as root without leaving a root-owned lab after the next reset
- every factual claim checked against the running image; the corrections that changed exercises are
  recorded in the per-lesson commit messages (`/proc/<pid>/exe` points at the interpreter, not the
  script; `man ulimit` resolves to `ulimit(3)`; `/proc/sys` refusals are EROFS not EACCES;
  `stat -f` and `df -T` disagree about the ext family; `tree --du -L 1` does not sum; `file -L` on a
  broken link fails outright; `ls -b` escapes nothing under `C.UTF-8` without `LC_ALL=C`)
- the incident solved from a clean lab: flag derived from the directory name, `kestrel flags submit`
  accepts it and rejects the same words with spaces instead of underscores
- flag is not greppable — it is stored in no file; the on-disk name carries U+00A0 and spaces where
  the flag has underscores, so `grep -r a_name_you_cannot_type /labs` returns nothing
- trace 2 planted: `audit-notes.txt`, mtime `2187-05-15 23:41`, unattributed. `help.md` and
  `validation.md` both forbid supplying an author, and grade "the evidence does not distinguish"

Chapter 1 set the format; Chapter 2 is the first chapter built to it.

### Container: the `/course` mount narrowed (2026-08-23)

The container bind-mounted the whole repo read-only at `/course`. That handed the student every
`solutions.md` — answers and flag plaintexts for all sixteen chapters — plus `help.md`,
`validation.md`, every `setup.sh`, every `story.md` (each carries its chapter's flag text),
`_handoff/SCENARIOS.md` and `container/flags.tsv`. `grep -r KESTREL /course` was the loudest
symptom, not the whole problem.

`kestrel start` now stages a student view at `container/.view/` (gitignored) and mounts that:

- per lesson, `readme.md` and `exercises.md` only; per chapter, `README.md`
- root student docs and the seven student-facing `docs/` files
- **unlocked chapters only.** Chapters 00 and 01 are always open; chapter N opens once every flag
  registered for chapter N-1 is in `container/.captured`. `kestrel unlock <ch>` forces one open.
  `kestrel status` lists what is visible, and capturing a flag restages automatically.
- `setup.sh` is no longer read from a mount — `run_setup` pipes it to the container on stdin

Verified: `/course` inside the container holds no `solutions.md`, `setup.sh`, `story.md` or
`flags.tsv`; the nine remaining `KESTREL{` hits are all the literal `KESTREL{...}` placeholder;
`/course` is still read-only (`touch` fails with `Read-only file system`), so the Chapter 0 and 1
exercises built on that fact still hold; `kestrel seed`/`reset 02/07` reproduce the lab byte for
byte and stay idempotent; gating checked (ch03 open with `02/07` captured, ch04 closed, `unlock 06`
opens it, `unlock 99` refused).

## Not started

Chapters 3–15 — 82 lessons, all stubs. `docs/CHEATSHEET.md` content. See `TODO.md`.

## Current tree

```
/home/romeo/tejaswi/linux/
  AGENTS.md  CLAUDE.md  CONTEXT.md  DONE.md  TODO.md
  README.md  SETUP.md  SYLLABUS.md  STORY.md  .gitignore
  _handoff/    SYLLABUS  LESSON_SPEC  PROTOCOLS_SPEC  CHALLENGE_DESIGN
               CONTAINER  STORY  SOURCE_COURSE  QA_LOG
  docs/        AGENT_MODES  TUTOR_PROTOCOL  VALIDATION_PROTOCOL  GAMEMASTER_PROTOCOL
               AUTHORING  SELF_CHECK  RECORDING  INSTALL_GUIDE  CHEATSHEET
  container/   Dockerfile  bashrc-seed  flags.tsv  build.sh  run.sh  reset.sh  bin/kestrel
  00-boarding-the-kestrel/     COMPLETE — 6 lessons
  01-shell-and-terminal/ ... 15-capstone-kestrel-breach/     stubs
```
