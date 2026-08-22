# Kestrel Linux

A hands-on Linux course. Notes to teach the concept, then a lot of exercises — hundreds of them
across 16 chapters — because reading about `find` and being able to use `find` are different
skills, and only one of them survives contact with a real machine.

You already did boot.dev's *Learn Linux*. This covers the same ground much harder, then keeps going.

> **Story:** you are the new junior sysadmin aboard **Orbital Station Kestrel**. The previous
> sysadmin left abruptly and left a mess. Each chapter is an incident. See [STORY.md](STORY.md).

---

## Getting started

1. Read [SETUP.md](SETUP.md) — VirtualBox VM, Docker, and the course container.
2. Read Chapter 0, `00-boarding-the-kestrel/`, start to finish. It's short and it sets up
   everything else.
3. Work through the chapters in order. They build on each other strictly; nothing is used before
   the lesson that teaches it.

The full table of contents is in [SYLLABUS.md](SYLLABUS.md).

## How a lesson works

Each lesson is a directory with six files. You read two of them:

| File | For you? |
|---|---|
| `readme.md` | **Yes.** The notes. Read first, all of it. |
| `exercises.md` | **Yes.** The work. |
| `help.md` | No — the tutor agent reads this. |
| `validation.md` | No — the validator agent reads this. |
| `solutions.md` | **No.** Don't open it. Opening it is the only way to actually fail this course. |
| `setup.sh` | No — it seeds your lab directory. |

Work in `/labs/<chapter>/<lesson>/` inside the container. The `lab` helper jumps you there:

```bash
lab 06/03
```

## The six exercise tiers

| Tier | What it is |
|---|---|
| **Warmup** | One command, straight out of the notes. Free points, and a check that you read them. |
| **Core** | The actual skill, from several angles. Most of your time goes here. |
| **Experiment** | Predict the output **in writing**, then run it, then explain the difference. A wrong prediction is the point — that's where your mental model was broken. |
| **Stretch** | Combines this lesson with earlier chapters. |
| **Dig** | Needs a flag or behaviour the notes never showed you. It's in `man`. Go get it. |
| **Flag** | CTF. Chain tools together to produce a `KESTREL{...}` flag. Verify with `kestrel flags submit`. |

Every chapter hides at least one flag, and every flag is planted so that only that chapter's skill
can reach it.

## Working with AI agents

Agents play three roles here, and they are strictly separated.

**Tutor** — when you're stuck. It will ask what you tried, what you expected, and what happened,
then walk a hint ladder: a question, then where to look, then the concept explained on *different*
data, then a decomposition, then a near-miss repair.

**It will never tell you the answer.** Not if you ask nicely, not if you're out of time, not if you
say you already solved it. That's deliberate and it's the whole point. If you get genuinely stuck,
it will hand you a parallel problem instead and send you back.

**Gamemaster** — for roleplay exercises. The agent plays a crew member: cass, who says "the logs
are broken" and means one specific thing she can't name; rhea, who won't grant access until you can
say exactly what you need and why; ops-bot, which answers precisely the question you asked and never
the one you meant. Getting a usable problem statement out of a person is a real skill, and it's the
one static exercises can't teach. The character is not a loophole — rhea doesn't know the answer
either.

**Validator** — when you're done. It inspects your lab directory, reads your `history` for the
failed attempts, may ask you to redo a random exercise live, and asks you *why* questions. Verdicts
are PASS / PASS-WITH-NOTES / REDO per exercise, plus what to re-drill.

To use one, point the agent at [`docs/AGENT_MODES.md`](docs/AGENT_MODES.md) and say which mode you
want and which lesson you're on.

### Challenges

Beyond the six tiers, each chapter carries an **Incident** — a thing that has broken, described by
symptom only, with red herrings and a constraint that rules out brute force. From Chapter 5 the
flags come in **chains**: a `STAGE{...}` token unlocks the next stage, each stage needing a
different skill, ending in a real `KESTREL{...}`. From Chapter 6 there are **roleplay** scenes.

A thread of sabotage runs under all of it and resolves in Chapter 15. You'll start noticing it
around Chapter 6. Every chapter stands alone — the arc is a reward for paying attention, never a
dependency.

## Proving your work

- Record a terminal transcript per lesson, and a screen recording of the course.
- Keep your `history` — **including the failures.** A history with no mistakes reads as copy-paste
  and gets you a live re-demonstration.
- Details: [`docs/RECORDING.md`](docs/RECORDING.md).

## Reference

| | |
|---|---|
| [SETUP.md](SETUP.md) | VM, Docker, container |
| [SYLLABUS.md](SYLLABUS.md) | full table of contents |
| [STORY.md](STORY.md) | the Kestrel |
| [`docs/SELF_CHECK.md`](docs/SELF_CHECK.md) | checking your own work; spaced repetition |
| [`docs/RECORDING.md`](docs/RECORDING.md) | transcripts and video |
| [`docs/INSTALL_GUIDE.md`](docs/INSTALL_GUIDE.md) | installing tools, and troubleshooting |
| [`docs/CHEATSHEET.md`](docs/CHEATSHEET.md) | cumulative command reference |

## The container

```bash
kestrel build            # pull the image (once; --local to build it yourself)
kestrel start            # start the long-lived container
kestrel enter            # shell in as cadet
kestrel seed 06/03       # seed a lesson's lab
kestrel reset 06/03      # WIPE that lab and re-seed it
kestrel status           # what's running, what's seeded, flags captured
kestrel flags submit 'KESTREL{...}'
```

One container for the whole course, on purpose: your `.bashrc`, your aliases, your `~/bin` tools
and the users you create in Chapter 10 all have to survive. Isolation comes from per-lesson lab
directories instead. `reset` wipes one lab directory and nothing else — never your home directory.

Break things freely. It's a disposable container inside a disposable VM. That's what it's for.
