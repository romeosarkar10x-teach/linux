# LESSON_SPEC.md — What every lesson must contain

## Directory shape

```
NN-chapter-slug/
  README.md                  # chapter intro: incident briefing, objectives, lesson list, prereqs
  NN-lesson-slug/
    readme.md                # the notes — in-character page, then concept teaching
    exercises.md             # numbered, tiered exercises
    help.md                  # per-exercise hint ladder (tutor agent reads this)
    validation.md            # per-exercise agent rubric (validator agent reads this)
    solutions.md             # agent-eyes-only reference answers
    setup.sh                 # seeds this lesson's lab dir inside the container
```

Numbering is zero-padded two digits, slugs kebab-case, mirroring boot.dev's convention.

## `readme.md` — the notes

- Boot.dev style but **deeper**. ~400–1200 words.
- **Opens with the lesson's page** — the in-character framing, taken from that chapter's
  `story.md`. At most four sentences. It states a situation, never a method: "cass says the
  overnight logs are twice the size they should be", never "in this lesson you will learn `wc -l`".
  A reader who skips it must lose nothing they need for the exercises. Rules: `CONTEXT.md` §4.6(b)
  and `_handoff/CHALLENGE_DESIGN.md` §5a. Continuity authority: `_handoff/SCENARIOS.md`.
- Structure: **page** → concept → mechanism → worked examples → gotchas → what's next.
- Every command introduced gets: what it does, its most useful flags, and one runnable example.
- Explicitly name the flags the exercises will need — **except** those reserved for the Dig tier.
- Use callouts for warnings and gotchas. Prefer showing wrong-then-right over prose.
- End with a **"Before you move on"** list: 3–5 one-line facts the student should be able to recite.
- Do **not** put exercises here (boot.dev merged them; this course separates them for volume).

## `exercises.md` — the practice

Numbered continuously within the lesson (`1.`, `2.`, …), grouped into six tiers. Every lesson has
Warmup, Core, and at least one Dig. Experiment/Stretch/Flag as appropriate; every chapter must
contain at least one Flag exercise, normally in its `incident-NN` lesson.

| Tier | Purpose | Typical count/lesson |
|---|---|---|
| **Warmup** | 1-command recall straight from the notes | 2–4 |
| **Core** | the real skill, attacked from several angles | 4–12 |
| **Experiment** | "predict the output, then run it, then explain the difference" — no single right command; the deliverable is a written prediction + observation | 1–4 |
| **Stretch** | combines this lesson with earlier chapters | 2–5 |
| **Dig** | requires a flag or behavior found only in `man`/`--help`, never shown in the notes | 1–3 |
| **Flag** | CTF: chain tools to produce a `KESTREL{...}` flag | 0–2 |

Each exercise states: the task, the lab path it operates in, and what "done" looks like — but
**never the command**. Experiment exercises must ask the student to write their prediction down
before running, so the tutor and validator can compare it against reality.

Volume target: **~50 exercises per chapter is a floor, not a ceiling** (user's explicit ask — "let
the student practice hard", and later "there should be lots of exercises actually"). The syllabus no
longer carries per-chapter estimates, deliberately — see `CONTEXT.md` §4.5. Never trim for brevity
and never trim to hit a number.

## `help.md` — the tutor's hint ladder

Per exercise, five rungs, one per exchange, in this fixed order. See
`_handoff/PROTOCOLS_SPEC.md` for the governing rules.

```markdown
### Exercise 7
- **L1 question:** What does the first character of an `ls -l` line tell you?
- **L2 locate:** Notes section "The seven types"; or `man ls`, search for `-l`.
- **L3 concept:** <restate the mechanism in different words + an example on DIFFERENT data>
- **L4 decompose:** step 1 … step 2 … step 3 (student does each)
- **L5 near-miss:** if they have `find . -type d` but need files, point at `-type`'s argument — do not write it.
- **Never say:** <the specific strings that would give it away, e.g. the exact command or flag combo>
```

Worked examples at L3 **must** use different filenames and data than the exercise, so copy-pasting
them cannot solve it.

## `validation.md` — the validator's rubric

Per exercise, a fixed table:

| Field | Meaning |
|---|---|
| **Goal** | the skill this exercise proves |
| **Expected end state** | observable facts: files, permissions, contents, output |
| **Evidence commands** | read-only commands the validator runs to check |
| **Accept** | every approach that legitimately counts as correct |
| **Reject** | wrong approach even when output matches (hand-typed answer, unnecessary `sudo`, GUI/editor instead of the tool being taught) |
| **Red flags** | copy-paste tells: no failed attempts in history, impossible speed, tool never invoked |
| **Probe question** | the "why" question to ask the student |

Also include a **lesson roll-up**: which exercises are load-bearing (must PASS) versus nice-to-have.

## `solutions.md` — agent-eyes-only

- Header must carry the warning that the student is not to open it.
- One canonical solution per exercise, plus notable alternates.
- For Experiment exercises: the correct *explanation*, not just output.
- For Flag exercises: the flag plaintext **and** its salted hash as registered in `kestrel flags`.
- The tutor agent may read this to know where it's steering but must never quote it.

## `setup.sh` — lab seeding

- Seeds `/labs/<chapter-slug>/<lesson-slug>/` inside the container. Touches nothing else.
- **Must be idempotent**: safe to re-run; `kestrel reset <lesson>` wipes the dir and re-runs it.
- Uses only tools present in the image. No network access.
- Any file the exercises reference must be created here, including deliberately broken artifacts
  (dangling symlinks, wrong permissions, adversarial filenames, sabotaged configs).
- Flag files must be planted such that reading them requires the lesson's skill.
- Header comment lists which exercises depend on which seeded artifacts.

## Chapter `README.md`

Incident briefing in-story, learning objectives as a checklist, lesson list with one-line
descriptions, prerequisites (which earlier chapters must be done), and the chapter's flag count.

## Cross-cutting authoring rules

1. **Dependency discipline** — before using a command or flag, confirm the syllabus introduces it
   earlier. `_handoff/SOURCE_COURSE.md` lists the student's starting ceiling.
2. **Every lesson is self-contained in its lab dir.** No exercise depends on another lesson's
   leftover state, except where a chapter README explicitly says so (e.g. the ch11 `.bashrc` arc).
3. **Destructive exercises stay inside `/labs`.** Anything touching `/etc`, users, or packages is
   fine — it's a disposable container — but must be reversible by `kestrel reset`.
4. **Fun is a requirement**, not a bonus. Experiments, surprising outputs, and CTF flags are the
   mechanism.
