# DONE.md — What exists so far

Status: **planning complete. Phases 1 and 2 complete, Phase 3 under way — skeleton, all shared docs, working
container, scenario bank, and Chapters 0 through 9 written in full.** Chapters 10–15 are stubs.

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

**Chapter 3 complete** (Phase 3) — 6 lessons x 6 files, no stubs, chapter README written:

| Lesson | Exercises |
|---|---|
| `01-everything-is-a-file` | 22 |
| `02-inodes` | 28 |
| `03-hard-vs-symlinks` | 34 |
| `04-timestamps` | 51 |
| `05-devices-fifos-sockets` | 52 |
| `06-incident-03` | 28, incl. the chapter flag |

**215 exercises in Chapter 3.** One flag registered: `03/06`, hash in `container/flags.tsv`.

Verified, not just written:
- all 6 `setup.sh` run under `kestrel seed` from a clean `/labs` and are idempotent — the incident
  lab proven by identical `find -printf | md5sum` tree hashes across a second seed
- every factual claim checked against the running image; the corrections that changed exercises are
  in the per-lesson commit messages (`ls --time-style=full` and `--sort=mtime` are both invalid
  spellings; ext4 clamps timestamps at 2446; `mknod` is refused to `cadet` without `CAP_MKNOD`;
  `/dev/tty` is unusable from `docker exec` without a tty; `touch` without `-h` on a dangling
  symlink *creates* the target when its parent exists and only fails when the parent is missing;
  `readlink -f` still succeeds on a fully dead chain because it requires only the components before
  the last — `readlink -e` is what fails; `find -newer notes/dangling.txt` returns two names
  because one of them is the hard link)
- the incident solved from a clean lab: the chain followed, the flag derived, `kestrel flags submit`
  accepts it
- flag is not greppable — it is stored in no file; the log line has spaces and a colon where the
  flag has underscores, so `grep -rl the_link_outlived_the_target /labs` returns nothing
- **known and accepted:** the flag *line* is readable with Chapter 2 tools alone, since `cat`
  through a symlink chain needs no `readlink`. The chapter-3 content is in following and describing
  the chain, not in reaching the bytes; the red herring and the hard-link discrimination are what
  actually require `ls -i` and `stat -c %h`. Not replanted.
- trace 3 planted: `deck3/console/strain-feed`, a dangling symlink to
  `/mnt/eng-array/strain/strain-2187-05-22.csv`, own mtime `2187-05-08 17:44`, unattributed. That
  mount path is invented here and is the artefact Chapter 15 reads back. `help.md`, `validation.md`
  and `solutions.md` all forbid naming an author; `notes/dangling.txt` names nobody.

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

**Chapter 4 complete** (Phase 3) — 5 lessons x 6 files, no stubs, chapter README written:

| Lesson | Exercises |
|---|---|
| `01-cat-and-friends` | 39 |
| `02-touch-mkdir` | 42 |
| `03-cp-mv` | 46 |
| `04-rm-safely` | 48 |
| `05-incident-04` | 33, incl. the chapter flag |

**208 exercises in Chapter 4.** One flag registered: `04/05`, hash in `container/flags.tsv`.

Verified, not just written:
- all 5 `setup.sh` run under `kestrel seed` from a clean `/labs` and are idempotent, each proven by
  identical `find . -printf "%p %y %m %U:%G %s\n" | sort | md5sum` across two seeds
  (`05-incident-04` = `c50b33a757a3e67ebb2b39661c73d538`, `04-rm-safely` =
  `d482909308e593426f89d3bcba1a391a`)
- every factual claim measured in the running image before shipping, and the exercises rebuilt
  around actual behaviour where a draft was wrong. The corrections are in the per-lesson commit
  messages; the ones that changed a whole exercise:
  - `chmod 400` does not protect a file from deletion — a 0400 file in a writable directory is
    removed after a courtesy prompt, while a 0644 file in a 0555 directory cannot be removed at all
    and `-f` does not help. Deleting is editing the directory that names it.
  - `rm -i ... </dev/null` prints every prompt, deletes nothing, and exits **0**; `cp -i </dev/null`
    exits 1. The exit status is not evidence that anything happened.
  - `rm -f` in a directory containing a file named `-f` exits 0, prints nothing, deletes nothing:
    the name is consumed as an option *and* the empty operand list stops being an error.
  - `rm -rf --preserve-root=all /labs` fails with `skipping '/labs', since it's on a different
    device` and exits 1 — `/labs` is `/dev/nvme2n1p2`, `/` is `overlay`. The plain `rm -rf /`
    failsafe matches the literal argument, so `rm -rf /*` defeats it; the danger is the expansion.
  - `find … -delete` on a non-empty directory reports `Directory not empty` and exits 1.
  - trailing slash on a symlink to a directory: `rm link/` says `Is a directory`, `rm -r link/` says
    `Not a directory`, both exit 1.
- the incident solved from a clean lab: the manifest read back with the convention it states, the
  duplicate row settled against the file in `salvage/`, `kestrel flags submit` accepts the result
- flag is not greppable — it is stored in no file. `grep -ri "deleted_not_moved\|KESTREL{"` over the
  lab returns rc 1. The readback of the seeded manifest spells `deleetednotmoved`, which is the flag
  only after the superseded row is discarded.
- the `.bak` manifest is a red herring and not a decoy: it is nine hours older, three files short,
  and agrees on every size it shares, so a tree built from it looks consistent — but its readback
  spells `notdetedmoed`, visibly not three words, so it never functions as a submittable flag
- trace 4 planted: `records/copy-notes.txt`, dorn's record of what he copied on 2187-05-17,
  unattributed. `help.md`, `validation.md` and `solutions.md` all forbid naming an author.
- **the lesson's Distinction, deliberate:** the flag text is somebody's *conclusion*, while
  exercises 26–27 require the student to state that the evidence for deletion-versus-move is not
  present in what survives. Answering the flag and answering the question are not the same act.

**Chapter 5 complete** (Phase 3) — 5 lessons x 6 files, no stubs, chapter README written:

| Lesson | Exercises |
|---|---|
| `01-globs` | 52 |
| `02-brace-expansion` | 52 |
| `03-quoting` | 60 |
| `04-word-splitting` | 64 |
| `05-incident-05` | 50, incl. the chapter flag and the first chained CTF |

**278 exercises in Chapter 5.** One flag registered: `05/05`, hash in `container/flags.tsv`.

Verified, not just written:
- all 5 `setup.sh` proven idempotent the `run_setup` way (wipe as root, pipe on stdin, chown, then
  identical `find . -printf "%p %y %m %U:%G %s\n" | sort | md5sum` twice). Incident lab =
  `72a941de1c0ef0fc532b2a50d3edb4c6`; `04-word-splitting` = `c6a27af14dae0ad55525fd1ca9a162ba`;
  `03-quoting` = `ad481e3fa3bc15248c16411f0baf9b58`.
- every expansion claim measured in bash 5.2.21 inside the image. The ones that rewrote an exercise:
  - `IFS=:` with `a:::b` gives **4** fields, two empty — non-whitespace separators do not collapse —
    while a *trailing* separator makes no field at all (`a:b:` is 2).
  - `IFS=` and `unset IFS` are opposites: one disables splitting, the other restores the default.
  - `for p in $(cat data/paths.txt)` runs **9** times over a 5-line file; `while IFS= read -r` runs
    5. `for d in $(ls bays)` runs 11; `for d in bays/*/` runs 8.
  - an unset variable expanded unquoted produces **no word** — hence `[ $e = x ]` fails with
    `[: =: unary operator expected` — while `"$u"` produces one empty word.
  - a bare `IFS=:` inside a function leaks to the caller; `local IFS=:` and a subshell do not.
  - splitting does not happen on assignment RHS, in `[[ ]]`, `case` or `$(( ))`, or on glob results.
- the incident solved from a clean lab, one glob, flag accepted by `kestrel flags submit`. Four
  design defects were caught by *running* the incident and fixed before shipping: the sweep log
  claimed 3 `rm` failures when the loop produces exactly 1; CTF stage 2 had three files matching its
  own brace expression; stage 3 was unsolvable as drafted; stage 4's record had 7 fields where the
  text said 6.
- flag is not greppable: `grep -r KESTREL /labs` surfaces only 00/04's deliberate tutorial flag and
  01/07's generated token. The five tag words are one per file and mean nothing apart.
- the chain is four stages, one skill each (globs, braces, quoting, splitting), every stage fails
  loudly, and its `STAGE{...}` receipts do not register with `kestrel flags`.
- trace 5 planted: five files last written at 02:58 against a sweep published four days earlier —
  the first artefact that is unambiguously chosen rather than careless. No file in the lesson names
  an author, and `help.md`, `solutions.md` and `validation.md` all forbid supplying one.


## Chapter 6 — searching: grep, regex & find — **COMPLETE**

7 lessons, 1 flag, a four-stage chain, and the course's first roleplay scene (cass).

- every factual claim measured against the container before shipping. Corrections the pass forced:
  06/06's two `strain-report` copies had identical mtimes so exercise 61 was unanswerable; `which`
  on a non-executable file prints nothing and returns 1 (the drafted answer was wrong); this image
  has no `/etc/updatedb.conf`, so `updatedb` indexes `/proc` (2765 entries) and two exercises were
  rebuilt around the measured behaviour.
- 06/07's incident: 19 entries excised from a numbered run log, provable only by count-versus-range
  (701 present, #0001–#0720). The red herring is arithmetic, not fiction — a second monitor's log
  reads −240 alone and is complete once its rotated `.1` half is counted with it.
- the chain's stage-2 cliff is deliberate: `grep -c '^#'` counts two header lines, and the wrong
  deficit lands on a line that fails loudly by name.
- flag is not greppable: `grep -rl KESTREL` in the lab returns rc 1. The five words are spelled by
  form fields `f1`–`f5` of a hidden hold record.
- trace 6 planted: the first artefact that is unambiguously an edit rather than a naming choice.
  No name appears anywhere in the chapter; `f6` (authorised by) and `f7` (reason) are blank, and
  `validation.md` fails a student who attributes the deletion to a person.
- `container/` gained plocate so 06/06 can teach index-versus-walk (`33a9d86`).

## Chapter 7 — text processing — **COMPLETE**

8 lessons, 1 flag, a four-stage chain, and a roleplay scene.

- the incident is arithmetic on a column: a report that is internally consistent and wrong, caught by
  re-deriving the total from the rows rather than reading the total.
- every claim measured in the container first; `sort`'s locale collation and `uniq`'s
  adjacent-only rule were both rebuilt around observed behaviour rather than the drafted answer.

## Chapter 8 — streams, redirection & exit codes — **COMPLETE**

6 lessons, 1 flag, a four-stage chain, and a roleplay scene.

- the incident is fourteen months of `nominal`: a summariser writing warnings to fd 2 while the
  nightly wrapper kept fd 1 only and sent fd 2 to a recycled path under `/tmp`. Two of the discarded
  warnings are the panel that is not supposed to clamp, on 2187-05-13 and -14.
- the flag is spoken on a stream, never written to a file — `grep -r KESTREL` and grepping the words
  both return rc 1, and that is the lesson rather than a hiding place.
- the chain's four stages are the `2>&1 >/dev/null` split, a combined-stream count, a here-string on
  standard input, and an exit status read with `&&`.

## Chapter 9 — processes & job control — **COMPLETE**

7 lessons, 1 flag, a four-stage chain, and a roleplay scene (rhea).

- the incident is a door-log summariser started by hand on 2186-10-06 under the ops-bot account and
  still spinning at ~50% of a core. Nothing schedules it. Its output file was deleted while still
  open, so the summary is reachable only through `/proc/<pid>/fd/9`, and the reason it was started
  lives only in `LR_NOTE_1..4` in its environment.
- the flag is in no file: `grep -r KESTREL .` and `grep -rlw` for each of its words both return rc 1.
- corrections the measurement pass forced: `setsid` needs `--fork` inside `docker exec`; `setpriv`
  replaces `runuser` so the flag words never reach argv; a bash `trap` does not run until the current
  foreground child returns; `sudo cmd < /proc/PID/environ` fails because the *shell* opens the file.
- `container/` gained `--cap-add=SYS_PTRACE` (reading another user's `environ`/`cwd`/`fd` is checked
  as a ptrace access, denied even to root without it) and `--init` (PID 1 was not reaping; 26 zombies
  accumulated across reseeds). Existing containers must be recreated to pick both up.
- trace 9 planted: two nights with a zero door count, tying back to chapter 8's discarded warnings.

## Chapter 10 — users, groups & permissions — **COMPLETE**

8 lessons, 1 flag, a four-stage chain, and a roleplay scene (rhea, least privilege).

- the incident is a setuid helper in the engineering tree, owned by an account whose holder left
  three weeks ago and dated 2187-05-18. It reads and hashes, nothing else — and that is the hole:
  a setuid program does its ordinary thing with somebody else's privileges, for anything you ask.
- five objects in the lab carry a special bit. One of them is correct as it stands and breaking it
  breaks other people's work silently for months; deciding which is the audit.
- the flag is in a `0600 dorn:dorn` file, so `grep -r KESTREL .` returns nothing and no `find` will
  open it. Exactly one identity can read it and exactly one program has that identity.
- the chain's four stages are a `-perm` search, an octal mode read correctly (`0004` — a file you
  own and cannot read, the cliff), a group joined and actually logged into, and setuid semantics.
- corrections the measurement pass forced: `sudo -u rhea` does *not* bypass a `---` group triad
  because rhea is in `crew` (kept as a deliberate near-miss; `nobody`/`ops-bot` succeed);
  the sticky-bit demo was inert while `dropbox` was owned by cadet, since the directory owner may
  delete anything — fixed by `chown root:crew`; `LAB` must be hardcoded because `run_setup()` pipes
  setup.sh on stdin; `sg engineering -c` muddied the setgid demo by changing the primary group
  everywhere, so it was re-measured from a plain shell; `uptime -p` unsupported; `sudo -i` and
  `sudo -s` both give `HOME=/root`.
- trace 10 planted: ownership of the helper, and its 2187-05-18 date, three days after the door-log
  nights chapter 9 left open.

## Chapter 11 — environment & shell configuration — **COMPLETE**

6 lessons, 1 flag, a four-stage chain, and a roleplay scene (cass, the tool she does not suspect).

- the chapter builds in order: shell versus environment variable and what a child inherits; `PATH`
  as an ordered list plus shadowing and the hash table; the four startup files proved by experiment
  rather than by anybody's summary; aliases versus functions and which one can lie; then `PS1`,
  `set -o` and `shopt`, where a default nobody chose turns a failed command into a reported success.
- the incident is one directory and two answers: `GLOBIGNORE='02-navigation:02-navigation/'` **and**
  `alias ls='ls --hide=02-navigation'` in a generated `~/.config/kestrel/env.sh` three levels into
  one home. Two mechanisms, not one, which is why stage 2 is the cliff — finding either feels like
  finishing. The file's own comment says "Generated 2186-03-02"; its mtime is 2187-05-19 02:41.
- the repair may not delete the file or its lines, because it regenerates on upgrade. It has to be
  appended downstream of the sourcing block in `.bashrc` — the chapter's own "last line wins" rule.
- the flag is in no file. `bin/incident-close` decodes a base64 blob once the repair verifies, so
  `grep -rn 'KESTREL{'` over the lab returns nothing.
- corrections the measurement pass forced: a `GLOBIGNORE` pattern without the trailing-slash variant
  does not hide `echo */`; `bash -l -c 'shopt -s expand_aliases; ... ls'` passes spuriously because
  the whole `-c` string parses before the shopt runs (lesson 04's own rule), so the checkpoint pipes
  newline-separated commands into `bash -l`; under `TERM=xterm` the default `PS1` carries a
  title-bar escape, so lesson 05's solution gives both forms; `set -u` on a bare `$NOPE` exits 127
  under `bash -c` but 1 from a script file; `extglob` is on interactively and off in scripts.
- trace 11 planted: the file is owned by the account, and the toolchain that writes it never reads
  it back and never compares two accounts — the systemic finding in `notes/toolchain.txt`.

## Chapter 12 — shell scripting — **COMPLETE**

9 lessons, 1 flag, a four-stage chain, and a roleplay scene (ops-bot, which records status and
never state).

- the order is the point: a file that runs (shebang, `x` bit, source versus run); arguments; `if`
  as "run a command and check its status", with `[`, `[[` and `test` as three answers; loops, and
  a counter that dies in a subshell; `case` and functions, and a fourth mode nobody reads down to;
  `read` and `(( ))`, and exactly where shell arithmetic stops; `set -euo pipefail`, `trap`,
  `mktemp`, and what the header still misses; then shipping `stationctl` with `--help`, exit codes
  and `PATH`.
- the incident is an audit the student is forbidden to turn into a repair: six scripts, and the
  question is which of them write to a fixed path under `data/` — including one that writes via
  `mv`, one via `sed -i`, and one that writes nothing at all. The nightly log line
  `cleanup complete, 0 files removed` has never been false; it counts removals and says nothing
  about writes.
- stage 3 is the cliff: students answer seven because seven records were rewritten, and the
  question asks how many were *lowered*. The skipped ones were already under the threshold — not
  the leading zero that lesson 06 primed them to blame.
- the flag is base64 inside `bin/audit-attest` and printed only on a correct report, so the lab is
  not greppable and reading the checker shortcuts nothing.

## Chapter 13 — packages, docs & editors — **COMPLETE**

6 lessons, 1 flag, a four-stage chain, and a roleplay scene (rhea, who moves on evidence and a
time estimate and on nothing else).

- `apt` first, then `dpkg` underneath it, then the manual offline, then the three routes for
  installing something that never came from a repository, then editing in place.
- measured behaviour drove several rewrites: `man -f fstab` says `nothing appropriate` because the
  mount(8) family was never shipped, so lesson 03 uses `sudoers(5)` and keeps fstab as the
  deliberate contrast; `apropos -e passwd` still returns `getpwent_r(3)` because `-e` matches whole
  words in *descriptions*; timing `rg` against `grep -r` measured nothing at this lab's size, so
  lesson 04 compares `rg -l` = 76 against `grep -rl` = 79 and the hidden-file default instead;
  `apt-cache policy htop` reports `Installed: (none)` while `htop` runs from the Nix side, which is
  the honest groundwork the incident needs.
- lesson 02's downgrade experiments can leave dpkg interrupted; lesson 04's validation makes
  purging `ripgrep`/`ncdu` a hard gate, because leaving `ripgrep` installed defuses the incident's
  opening move.
- the incident is two sources at equal priority and one tool: the candidate is 1.4.0 from a source
  nobody configured on purpose, and the rule that produces it — highest version wins — is the
  transferable lesson. The counterweight is `libhatch-telemetry0`, which looks exotic and is an
  ordinary dependency of the station's own `deck-verify`; `validation.md` fails any report that
  calls it a finding.
- stage 3 is the cliff and the only stage that changes the station rather than reading it. It
  refuses two ways: exit 3 while the source file is configured, exit 4 if the wrong version is
  installed. The flag is base64 inside the installed binary; `grep -r KESTREL` over the lab and
  over `/usr/bin/deck-verify` returns nothing.
- the chapter's arc material accumulates as facts and never as an accusation: an unsigned source
  (02), a man page naming a file its package does not ship (03), `/usr/local` recording no
  provenance (04), configs recording what changed and never why (05), a source file with an mtime
  and no author (06).

## Not started

Chapters 14–15 — 10 lessons, all stubs. `docs/CHEATSHEET.md` content. See `TODO.md`.

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
  01-shell-and-terminal/       COMPLETE — 7 lessons
  02-navigating-the-filesystem/ COMPLETE — 7 lessons
  03-files-links-and-types/    COMPLETE — 6 lessons
  04-creating-copying-destroying/ COMPLETE — 5 lessons
  05-globbing-and-quoting/      COMPLETE — 5 lessons
  06-searching/                COMPLETE — 7 lessons
  07-text-processing/          COMPLETE — 8 lessons
  08-streams-and-redirection/  COMPLETE — 6 lessons
  09-processes-and-job-control/ COMPLETE — 7 lessons
  10-users-groups-permissions/  COMPLETE — 8 lessons
  11-environment-and-config/    COMPLETE — 6 lessons
  12-shell-scripting/          COMPLETE — 9 lessons
  13-packages-docs-editors/    COMPLETE — 6 lessons
  14-.../ 15-capstone-kestrel-breach/   stubs
```
