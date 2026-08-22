# AUTHORING.md — extending the course

For agents (or humans) adding lessons, exercises, or chapters after the initial build.

Authoritative specs live in `_handoff/`. This file is the operational summary; when they disagree,
`_handoff/` wins.

## The rules that cannot be relaxed

1. **Dependency discipline.** Before an exercise uses a command, flag, or concept, confirm the
   syllabus (`_handoff/SYLLABUS.md`) introduces it in an *earlier* lesson. The student's starting
   ceiling — everything they knew on day one — is in `_handoff/SOURCE_COURSE.md`. Anything outside
   that ceiling must be taught here before it is used.
2. **The 6-file lesson set is mandatory**: `readme.md`, `exercises.md`, `help.md`, `validation.md`,
   `solutions.md`, `setup.sh`. A lesson missing any of them is not shippable. Spec:
   `_handoff/LESSON_SPEC.md`.
3. **Never weaken the tutoring rules** to make a lesson easier to support. If an exercise can only
   be helped by giving away the answer, the exercise is wrong — rewrite it, usually by splitting it.
4. **Volume is the point.** Up to ~50 exercises per chapter, by explicit request. Do not trim for
   elegance. Every lesson needs Warmup, Core, and at least one Dig; every chapter needs at least one
   Flag.
5. **Fun is a requirement, not a bonus.** Experiments with surprising output, adversarial filenames,
   CTF flags, the station narrative. A lesson that is technically complete and joyless is not done.

## Adding a lesson

- Slug: `NN-kebab-case`, zero-padded, numbered in reading order within its chapter.
- Write `readme.md` first, then `exercises.md`, then `solutions.md` — solving your own exercises is
  how you discover the ambiguous ones.
- Write `help.md` **after** `solutions.md`, and check every rung-3 worked example against the rule
  that it must use different data and filenames than the exercise. If it can be pasted into a
  terminal and produce the answer, rewrite it.
- Write `validation.md` last; all seven fields per exercise, plus the load-bearing roll-up.
- Update the chapter `README.md` lesson list and `SYLLABUS.md`.

## `setup.sh`

- Seeds `/labs/<chapter-slug>/<lesson-slug>/` and nothing else.
- **Idempotent.** Safe to run twice. `kestrel reset` wipes the lab dir and re-runs it.
- Only tools present in the image. **No network.**
- Creates every artifact the exercises reference, including the deliberately broken ones: dangling
  symlinks, wrong permissions, adversarial filenames, sabotaged configs.
- Header comment maps artifacts to the exercises that need them.
- If the lesson needs state outside the lab dir (users, packages, `/etc`), say so in the chapter
  README — `reset` will not restore it.

## Flags

- Format: `KESTREL{lowercase_words_with_underscores}`.
- A flag must be **unobtainable without the chapter's skill.** If a `find` one-liner from Chapter 6
  cracks a Chapter 12 flag, replant it.
- Plaintext lives **only** in that lesson's `solutions.md`.
- Register the salted hash in `container/bin/kestrel` so `kestrel flags submit` can verify it.
- Never put a flag, or a recognizable fragment of one, in `readme.md`, `exercises.md`, `help.md`,
  `validation.md`, or any `setup.sh` in cleartext form the student could `grep` for.

## Before you call it done

- Run `setup.sh` twice in the container; confirm idempotency.
- `kestrel reset <chapter>/<lesson>` and solve the lesson yourself from a clean lab.
- Grep the lesson for commands and flags; check each against syllabus order.
- Read `help.md` as if you were a student trying to cheat with it. If it works, it's broken.
