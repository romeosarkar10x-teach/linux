# AGENTS.md

Project: **Kestrel Linux** — a hand-built, practice-heavy Linux course for a single student who has
already finished boot.dev's *Learn Linux* and needs far more drilling.

This file follows the [AGENTS.md open specification](https://agents.md) (originated by OpenAI et al.
in Aug 2025, donated to the Linux Foundation's Agentic AI Foundation in Dec 2025). It is the root
instruction file for any AI agent **building** this course. `CLAUDE.md` is a pointer to this file.

## Read before doing anything

| # | File | What it holds |
|---|---|---|
| 1 | [CONTEXT.md](CONTEXT.md) | Mission, the student, every locked decision and why. **Read fully. Nothing here is optional.** |
| 2 | [DONE.md](DONE.md) | What has actually been produced so far |
| 3 | [TODO.md](TODO.md) | Ordered remaining work, phase by phase |
| 4 | [_handoff/SYLLABUS.md](_handoff/SYLLABUS.md) | Approved table of contents — 16 chapters, 103 lessons |
| 5 | [_handoff/LESSON_SPEC.md](_handoff/LESSON_SPEC.md) | Exact file set, templates, exercise tiers every lesson must follow |
| 6 | [_handoff/PROTOCOLS_SPEC.md](_handoff/PROTOCOLS_SPEC.md) | Specs for the tutor/validator docs shipped under `docs/` |
| 7 | [_handoff/CONTAINER.md](_handoff/CONTAINER.md) | Docker sandbox + `kestrel` helper design |
| 8 | [_handoff/STORY.md](_handoff/STORY.md) | Narrative bible: Orbital Station Kestrel, cast, flag format |
| 9 | [_handoff/SOURCE_COURSE.md](_handoff/SOURCE_COURSE.md) | Full breakdown of the boot.dev course — the student's exact prior knowledge |
| 10 | [_handoff/CHALLENGE_DESIGN.md](_handoff/CHALLENGE_DESIGN.md) | Incidents, chained CTFs, roleplay, flag-planting rules, the sabotage arc |
| 11 | [_handoff/SCENARIOS.md](_handoff/SCENARIOS.md) | Scenario bible — dorn timeline, cast continuity, all 16 incidents |
| 12 | [_handoff/QA_LOG.md](_handoff/QA_LOG.md) | The user's own words on each decision, verbatim |

## Rules for the building agent

1. **Never teach a concept before the syllabus introduces it.** The student knows only what's in
   `_handoff/SOURCE_COURSE.md` plus earlier chapters of this course. Check TOC order before using
   any command or flag in an exercise.
2. **Every lesson ships all 6 files.** No partial lessons. See `_handoff/LESSON_SPEC.md`.
3. **Practice volume is the point.** ~50 exercises per chapter is a **floor**, not a ceiling — the
   syllabus's per-chapter estimates are stale and lose to the written count. Never trim to be
   concise. See `CONTEXT.md` §4.5.
4. **No auto-grading scripts.** Validation is by AI agent rubric only — a locked decision.
5. **A tutor agent must never give the student the answer.** See `_handoff/PROTOCOLS_SPEC.md`.
6. **Update `DONE.md` and `TODO.md` as you go.** They are the handoff state.
7. **Fun is a requirement.** Every chapter needs an Incident, and from ch5/ch6 onward a chained
   CTF and a roleplay scene. **Every *lesson* opens with an in-character page** (≤ 4 sentences,
   frames the exercises, never teaches). See `_handoff/CHALLENGE_DESIGN.md` §5a.
8. **Story continuity is checked against `_handoff/SCENARIOS.md`**, which is the authority on the
   dorn timeline and who knows what when. A chapter's `story.md` expands the bible; it never
   contradicts it.
9. Ask the user before deviating from the approved syllabus.

## Conventions

- Chapters `NN-chapter-slug/`, lessons `NN-lesson-slug/`, zero-padded, kebab-case — mirrors boot.dev.
- Lab work happens under `/labs/<chapter-slug>/<lesson-slug>/` inside the course container.
- Flags are `KESTREL{...}`; store salted hashes only, never plaintext outside `solutions.md`.
- `setup.sh` scripts must be idempotent and confined to their own lab directory.

## File naming

Two distinct audiences, kept separate:

| Path | Audience |
|---|---|
| `/AGENTS.md` (this file) | agents **building** the course |
| `/docs/TUTOR_PROTOCOL.md` | agents **helping a stuck student** — never reveal answers |
| `/docs/VALIDATION_PROTOCOL.md` | agents **grading** the student's work |
| `/docs/AUTHORING.md` | agents **extending** the course later |
| `/docs/GAMEMASTER_PROTOCOL.md` | agents **playing a crew member** in a roleplay exercise — still never reveal answers |

Per the AGENTS.md spec, nested `AGENTS.md` files may be added inside chapter directories for
chapter-specific build rules; the nearest one to the file being edited wins.
