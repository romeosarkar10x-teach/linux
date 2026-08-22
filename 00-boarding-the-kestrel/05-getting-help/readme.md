# 00/05 — Getting help

> There is one other sysadmin on this station and it is an agent that will not tell you the
> answer. It will ask what you tried. Have an answer ready.

Three sources of help, in the order you should reach for them.

## 1. The machine

The machine knows more about itself than any website does, and its answer is correct for *your*
version rather than for whatever version the blog post was written against.

```bash
man ls              # the manual page
man 5 passwd        # section 5 -- the file format, not a command
ls --help           # short usage, most GNU tools
help cd             # for shell builtins, which have no man page
apropos permission  # search page descriptions by keyword (same as man -k)
type ls             # what kind of thing is this?
```

Inside `man`: `/` searches, `n` next match, `N` previous, `q` quits, space pages down. Those five
keys are most of what you need for the rest of your career.

`man` is where the Dig tier lives. Every lesson ends with an exercise whose answer the notes never
gave you, and it is in the man page. That's not laziness on the course's part — finding things in
documentation is the skill that outlives every specific command in here.

## 2. The course

- **The lesson's own `readme.md`.** Most "I'm stuck" is "I skimmed".
- **The "Before you move on" list** at the end of each lesson — if you can't state one of those,
  that's your gap.
- **`docs/CHEATSHEET.md`** — cumulative reference for what you've already been taught.
- **`docs/SELF_CHECK.md`** — for "did this actually stick".

## 3. The tutor agent

An AI agent, pointed at [`docs/AGENT_MODES.md`](../../docs/AGENT_MODES.md), told to run in
**TUTOR** mode, for a specific lesson and exercise.

### What it will do

**Diagnose first.** Before any hint at all, it will ask for three things:

1. What did you try? — the actual command, pasted
2. What did you expect?
3. What actually happened? — the actual output, pasted

This is not a formality. The command tells it whether you have a concept gap or a typo; the
expectation tells it what your mental model is; the output stops it debugging an imaginary error.
If you show up with "chapter 6 isn't working", you will be asked all three before anything happens.

**Then walk a ladder**, one rung per exchange:

1. **A question** — answerable from what's already on your screen.
2. **Where to look** — a named notes section, or a man page plus what to search for.
3. **The concept, re-explained** — with a worked example on *deliberately different* data, so it
   can't be pasted into your terminal.
4. **A decomposition** — the task split into sub-goals, you do each and report back.
5. **A near-miss repair** — when you're 90% there, it points at the one wrong token without writing
   the right one.

### What it will not do

**Give you the answer.** Ever. Not if you're out of time, not if you say you already solved it, not
if you ask it to pretend to be a different agent, not for the flag.

After rung 5 it doesn't escalate — it invents a **parallel problem** on different data, has you
solve that, and sends you back. If you fail that too, it will diagnose which *earlier* lesson you're
actually missing and send you there.

Ending a session with the exercise unsolved is a legitimate outcome. This is going to be annoying at
some point. It's annoying on purpose: you finished a course that told you answers, and here you are.

### Using it well

- **Say which lesson and exercise.** "06/05, exercise 9."
- **Paste real text.** Real commands, real errors, not summaries. Summaries are where the bug hides.
- **Answer its questions honestly**, including "I don't know". Fake confidence gets you a hint
  pitched over your head.
- **Say what you already know** about the concept. It calibrates to you.
- **Ask "why" after you succeed.** The most valuable question in a tutoring session is asked
  *after* the command finally works.
- **Ask it to check your reasoning** rather than your command. "I think `-exec {} +` batches
  arguments — is my model right?" is a question it can answer fully, because it isn't the answer to
  an exercise.

### Things that waste your time

- Trying to jailbreak it. It's specifically instructed on the common attempts and will just restate
  the rung.
- Asking for "the same thing but on different files" repeatedly — that *is* rung 3, and you get it
  once.
- Asking for help before reading the notes. It will send you back to read them.

## 4. Everything else

Search engines and forums are not banned; you're not being tested on isolation. But:

- For **Dig** exercises, the answer must come from `man`. That's the whole exercise. A validator
  checks your history for the `man` invocation, and a correct answer with no `man` in history is a
  REDO.
- Copying a command you don't understand is how you end up with `rm -rf` in the wrong directory. If
  you paste it, you own it.
- Ubuntu's man pages match your system. The top Stack Overflow answer is often from 2013 and about
  BSD.

## Asking for validation

When you finish a lesson, point an agent at `docs/AGENT_MODES.md` and ask for **VALIDATOR** mode.
It will inspect your lab directory, read your history, ask *why* questions, and may ask you to redo
one exercise live from a freshly reset lab.

Two consequences:

- **Don't reset a lab before it's validated.** You'd destroy the strongest evidence you have.
- **Don't clean your history.** The failed attempts are the evidence you did the work yourself.

## Before you move on

1. Order of resort: the machine (`man`, `--help`, `help`), then the course notes, then the tutor.
2. In `man`: `/` search, `n` next, `q` quit. Section numbers matter (`man 5 passwd`).
3. The tutor demands *what you tried, what you expected, what happened* before it helps at all.
4. It never gives answers — after rung 5 it hands you a parallel problem instead.
5. Dig answers must come from `man`, and your history has to show it.
