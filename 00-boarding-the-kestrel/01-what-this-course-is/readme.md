# 00/01 — What this course is

You've done a Linux course already. You can probably name what `chmod 755` does. Can you write,
right now, without looking: a command that finds every file under `/var/log` modified in the last
day, larger than 10 KB, and prints them newest-first?

That gap — recognising versus producing — is what this course is built to close. There is only one
known way to close it, and it isn't more explanation. It's volume.

## What's different here

**Roughly 630 exercises.** boot.dev's Linux course has about one task per lesson. This one has five
to twelve per lesson and up to fifty per chapter. That is the entire design. If a chapter feels
repetitive, that's not a flaw in the chapter.

**Nothing is used before it's taught.** The syllabus is a strict dependency order. If you see a
command in an exercise, an earlier lesson introduced it — with one deliberate exception, below.

**The last exercises don't have their answers in the notes.** That's the Dig tier. The notes teach
you the concept and most of the flags; the Dig exercises need a flag the notes never mentioned, and
it lives in `man`. Reading man pages is a skill, it is learnable, and nobody learns it from being
told to.

**Agents won't give you answers.** More on that in 00/05.

## The shape of a lesson

Every lesson is a directory with six files. You read two:

- **`readme.md`** — the notes. Read all of it before starting, including the code blocks. The
  exercises assume you have.
- **`exercises.md`** — the work.

The other four are `help.md` (the tutor agent's hint ladder), `validation.md` (the validator's
rubric), `solutions.md`, and `setup.sh` (which builds your lab directory).

**Do not open `solutions.md`.** It's not locked; nothing here is locked. It's the one file where
looking costs you something real and gains you nothing, since nobody is checking whether you
*could* have solved it. Only whether you can.

Every `readme.md` ends with a **"Before you move on"** list — three to five facts you should be able
to state from memory. Use it. It's the cheapest revision in the course.

## The six tiers

Exercises are numbered continuously through a lesson and grouped into tiers:

| Tier | What it asks | How to treat it |
|---|---|---|
| **Warmup** | one command, straight from the notes | If you can't, you didn't read them. Go back. |
| **Core** | the real skill, from several angles | Most of your time. The repetition is the mechanism. |
| **Experiment** | predict the output **in writing**, then run it, then explain the gap | A wrong prediction is a *success* — you just found a broken piece of your model. Don't skip the writing-down part. |
| **Stretch** | this lesson combined with an earlier chapter | Notice which chapter it's pulling from. |
| **Dig** | needs a flag the notes never showed you | It's in `man`. Search the man page (`/`), don't search the web. |
| **Flag** | CTF — chain tools to produce a `KESTREL{...}` | Fun, and a genuine test that the chapter stuck. |

Experiment exercises are the ones people skip, and they're the ones that change how you think. A
prediction you never wrote down is a prediction you can retroactively claim you made.

## Flags

Hidden throughout the station, one per chapter minimum, shaped like:

```
KESTREL{lowercase_words_here}
```

Each is planted so only that chapter's skill reaches it. Submit with:

```bash
kestrel flags submit 'KESTREL{...}'
```

The helper compares a salted hash, so the answers aren't sitting in a file you could `grep`. Note
the **single quotes** — `{` and `}` mean something to the shell, and you'll learn exactly what in
Chapter 5.

## The one exception to the dependency rule

Chapter 0 uses commands you haven't been taught: `apt install`, `usermod -aG`, `curl`, `sudo tee`.
You're going to copy-paste some of it, and that's fine — this chapter is scaffolding, not content.
Every one of those commands gets taught properly later:

| You'll copy-paste here | Taught properly in |
|---|---|
| `apt update` / `apt install` | 13/01 |
| `usermod -aG` and why you must log out | 10/02 |
| `curl`, `sudo tee`, `\|` | 8/02, 8/04 |
| `chmod`, `install -m` | 10/05 |

Nowhere else in the course does this happen.

## Where things live

| Path | What |
|---|---|
| `/course` (in the container) | this course tree, read-only |
| `/labs/<chapter>/<lesson>/` | your work area for one lesson |
| `/home/cadet` | your home directory, yours to modify |

Inside the container, `lab 06/03` jumps you to that lesson's lab directory.

## How you'll be graded

Two mechanisms, and the second one matters more:

1. **A video** of you working through the course.
2. **An AI validator agent** that inspects your lab directories, reads your `history` — including
   your failed attempts — asks you *why* questions, and can ask you to redo a random exercise live
   from a freshly reset lab.

There are no auto-grading scripts, on purpose. Too many correct answers exist for a script to judge
them, and a script would happily pass an answer you typed in by hand.

Practical consequence: **don't clean your history.** Failed attempts are evidence you did the work.
A hard lesson with no mistakes in the history is the single loudest copy-paste signal there is.

## Before you move on

1. Six files per lesson; you read `readme.md` and `exercises.md`, and never `solutions.md`.
2. Six tiers: Warmup, Core, Experiment, Stretch, Dig, Flag. Dig means "go read `man`".
3. Experiment exercises require a **written prediction before running anything**.
4. Flags are `KESTREL{...}`, submitted via `kestrel flags submit`, one per chapter minimum.
5. Your `history` is graded evidence. Keep the failures in it.
