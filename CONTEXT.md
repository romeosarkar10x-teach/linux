# CONTEXT.md — Everything you need to take over this task

## 1. The mission

Build a **fully interactive Linux course** from scratch: teaching notes plus large volumes of
hands-on exercises. Target directory: **`/home/romeo/tejaswi/linux`** (was empty at start; now
holds only these handoff docs).

The course is for **one specific student**, who has already completed boot.dev's *Learn Linux*
course. That course was judged **not enough practice**. This new course covers **mostly the same
concepts but with many more exercises**, plus deliberate extensions.

The course mirrors boot.dev's structure: **chapters containing lessons**. Chapter and lesson
selection was left to the building agent's judgement, subject to one hard constraint below.

## 2. The student — what they already know

Everything in `_handoff/SOURCE_COURSE.md` (the complete boot.dev *Learn Linux* breakdown: 7
chapters, 66 lessons). **Assume nothing beyond that.**

> **Hard constraint:** the student knows only what was in the boot.dev course. New concepts must be
> introduced systematically, in dependency order. Before writing any exercise, verify every command
> and flag in it was already taught — either by boot.dev or by an earlier chapter of this course.

The source course material is at:
`/home/romeo/github/romeosarkar10x_hack/boot_dev_course_scraper/courses/learn-linux`
(structure: `NN-chapter/NN-lesson/{readme.md, response.json}` + `metadata.json`).

## 3. Environment the student will use

- Student runs an **Oracle VirtualBox VM with Ubuntu** on it.
- Student installs **Docker inside that VM**.
- All labs run inside a **course Docker container** — chosen so `sudo`, `apt`, `chown`, user and
  group management, and setuid experiments are safe and reproducible.
- **Container model: one long-lived container**, not one per lesson. Each lesson seeds its own lab
  directory; `kestrel reset <lesson>` re-seeds only that directory. Rationale: the student's
  `.bashrc`, aliases, users, and PATH work must persist across lessons; per-lesson containers would
  destroy that continuity.
- **Docs must guide the student through installing anything required**, both in the VM and in the
  container. This is an explicit user request, not an afterthought — see `docs/INSTALL_GUIDE.md`
  in the TODO.

## 4. Locked decisions

### 4.1 Scope
Boot.dev's concepts drilled hard, **plus** extensions. Explicitly requested emphasis:
- users, **groups**, processes
- **different kinds of files** (file types, links, inodes, devices, FIFOs)
- piping, redirecting to files
- shell scripts, `.bashrc` and related config, environment variables
- package managers, with install guidance
- "lots of experiments" — the course should be **fun**
- **CTF-type challenges** where they fit

**Explicitly out of scope** (user said no full sysadmin path): systemd, cron, networking/ssh/scp,
rsync, jq-as-a-topic (jq appears only as an installable tool), disk partitioning, LVM.

Overall goal in the user's framing: *"the student should be able to navigate through Linux
properly."*

### 4.2 Validation — agent rubric only
**No auto-grader scripts. No `check.sh`.** The user's reasoning: the work "cannot be that
deterministic."

Instead, an **AI agent validates**. It may run `history`, inspect filesystem state, read terminal
transcripts, and question the student. The student will **also record a video** of themselves
solving the course; agent validation runs alongside that, and the user considers agent validation
the stronger of the two.

Two agent-facing documents are required (spec in `_handoff/PROTOCOLS_SPEC.md`):
- a **validation protocol** telling agents how each assignment can be validated
- a **help protocol** telling agents how to assist a stuck student

A **student-facing self-validation doc** is also required, but agent validation stays primary.

### 4.3 Tutoring — never give the answer
Direct user instruction, non-negotiable:

> The agents should **not simply tell the user the solution**. It should **guide** the user towards
> the solution. It should **ask questions** to the user, try to understand what the user knows.
> **It should never tell the answer directly to the user.**

Implemented as a 5-rung hint ladder with an anti-copy-paste rule: any worked example the tutor
gives must use **different data and filenames** than the exercise, so pasting it cannot succeed.
Full spec in `_handoff/PROTOCOLS_SPEC.md`.

### 4.4 Pedagogy — "teach then stretch"
Notes explain the concept fully (boot.dev style but deeper). Exercises are graded easy→hard, and
the last exercises in each lesson require reading `man` pages or `--help` for flags the notes never
showed.

### 4.5 Volume
**~50 exercises per chapter is the floor, not the ceiling.** User: *"Let the student practice
hard!"* and, on seeing Chapter 0 ship 50 against a planned ~12: *"the written is the original one,
and it's okay to increase. there should be lots of exercises actually."*

The per-chapter estimates and the `~630` total were **removed** from both syllabus files on
2026-08-23 rather than corrected. They were guesses, they were wrong, and a number in a spec invites
trimming a chapter to hit it. Where a count is needed, count the written exercises.

### 4.6 Story
**Story-driven CTF world.** The student is the new junior sysadmin aboard **Orbital Station
Kestrel**. Each chapter is an incident; stretch/flag tiers hide `KESTREL{...}` flags.

Four decisions locked on 2026-08-23, after an audit found the story machinery fully specified but
no scenario *content* written anywhere:

**(a) Two-tier story files.** `_handoff/SCENARIOS.md` is the bible — the dorn sabotage timeline,
cast continuity, and all 16 chapter incidents in outline. Each chapter additionally carries its own
`NN-chapter-slug/story.md` with the scene text for its lessons. The bible is the continuity
authority; a chapter file may not contradict it.

**(b) Story lands per lesson, not per chapter.** Every lesson opens with a short in-character page
tying its exercises to a station situation. The chapter incident remains the finale. This is a
change from `_handoff/CHALLENGE_DESIGN.md` §5, which set the floor at one incident per chapter —
that floor still holds, but it is no longer the whole story surface.

**(c) The scenario bank is written up front, before Chapter 1.** The sabotage arc has 16 traces
that Chapter 15 must assemble into one timeline. Authoring chapter by chapter would let trace 11
contradict trace 4 with no way to notice until the capstone. So: timeline and all 16 incidents get
written first, then Phase 2 authors Chapter 1 against a fixed target.

**(d) Chapter 0 gets rewritten in-story.** It is currently near story-free — 4 of its 6 lesson
readmes contain zero cast or station references. The VM becomes the student's quarters, the
container their workstation. Constraint: the install steps are genuinely fiddly and a student
following them is not yet in a position to enjoy a metaphor, so **no framing may obscure a literal
instruction**. Where the two conflict, the instruction wins.

### 4.7 Hierarchy
Same shape as boot.dev: numbered chapters containing numbered lessons —
`NN-chapter-slug/NN-lesson-slug/`. Chapter and lesson content chosen freely by the building agent,
subject to §2's dependency constraint.

## 5. Structural conventions inherited from boot.dev

Boot.dev lessons come in three types, which informed the tier design here:
- `type_shell` — auto-checked shell task (they used `RunCommand` / `MatchCommand.LastContains`)
- `type_choice` — multiple choice
- `type_text_input` — student self-reports; no automated check

This course drops the machine checks entirely (§4.2) and replaces them with tiered exercises plus
an agent rubric. Multiple-choice is replaced by **Experiment** exercises ("predict, then run, then
explain the difference"), which test the same understanding without being guessable.

Boot.dev's scenario dataset was a fictional bank, **worldbanc**, downloaded via `curl`. This course
deliberately **does not reuse worldbanc** — the student already knows that file layout. Kestrel is
the replacement scenario, seeded by per-lesson `setup.sh` scripts inside the container.

## 6. Approved output layout

```
/home/romeo/tejaswi/linux/
  AGENTS.md CLAUDE.md CONTEXT.md DONE.md TODO.md   # handoff docs (this set)
  _handoff/                                # handoff detail docs
  README.md                                # student: what this course is
  SETUP.md                                 # student: VM -> Docker -> container
  SYLLABUS.md                              # student-facing TOC
  STORY.md                                 # student-facing narrative
  docs/
    AGENT_MODES.md          # master rules: TUTOR vs VALIDATOR mode
    TUTOR_PROTOCOL.md       # Socratic tutoring protocol
    VALIDATION_PROTOCOL.md  # validation protocol
    AUTHORING.md            # rules for agents adding lessons later
    SELF_CHECK.md         # student self-validation
    RECORDING.md          # video + transcript capture
    INSTALL_GUIDE.md      # installing tools in VM and container
    CHEATSHEET.md         # cumulative command reference
  container/
    Dockerfile build.sh run.sh reset.sh bin/kestrel
  NN-chapter-slug/
    README.md
    NN-lesson-slug/
      readme.md exercises.md help.md validation.md solutions.md setup.sh
```

See `_handoff/LESSON_SPEC.md` for what goes in each lesson file.

## 7. Open items / judgement calls left to the builder

- Exact wording, examples, and per-exercise content of every lesson.
- Flag values and their salted hashes (`kestrel flags` verifies without leaking answers).
- Whether `docs/CHEATSHEET.md` is generated per-chapter or assembled at the end (currently: assembled
  at the end, Phase 4).
- The student's in-story character name is unspecified; `cadet` is the container account they start
  from.

## 8. Things the user has NOT asked for — do not add

- Auto-grading scripts of any kind
- Reusing the worldbanc dataset
- A web app, quiz engine, or any runtime beyond markdown + Docker
- Systemd, cron, networking, ssh (see §4.1)
