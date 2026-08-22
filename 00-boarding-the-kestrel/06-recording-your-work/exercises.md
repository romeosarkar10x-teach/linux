# 00/06 — Exercises

Inside the container unless stated. Answers in `~/00-06-answers.md`.

---

## Warmup

**1.** Confirm your history is configured to record timestamps, and show a few history entries with
their times.

*Done looks like:* history output with dates and times visible, and the name of the setting
responsible.

**2.** Record a short `script` transcript: start it, run three commands (one of which fails on
purpose), stop it, then view the file.

*Done looks like:* `~/transcripts/00-06-practice.log` exists and contains all three commands with
their output, including the failure.

---

## Core

**3.** Replay your practice transcript at its original speed.

*Done looks like:* the replay runs, and you can state what the timing file contributes that the log
alone does not.

**4.** Take a proper per-lesson snapshot for this lesson: flush your history, save it as
`~/transcripts/00-06.history`, and confirm the file contains this session's commands.

*Done looks like:* the file exists, and you can point to a command in it that you ran five minutes
ago.

**5.** From the VM, copy your `transcripts` directory out of the container. Verify it arrived, then
stop and start the container and confirm the originals are still inside.

*Done looks like:* the directory exists in both places, and you can state which copy would survive
the container being deleted.

**6.** Set up OBS in the VM and record 30 seconds of yourself running commands in the container.
Play it back **and read the smallest text on screen from the recording, not from your monitor.**

*Done looks like:* a playable file where the terminal text is genuinely legible. If it isn't,
increase the font size and record again. Do this now, not in Chapter 9.

---

## Experiment

**7.** **Predict in writing first.** You're about to test what actually gets into your history file.
Before running anything, predict whether each of these ends up in `~/.bash_history`:

- a command you typed and ran normally
- a command that failed with `command not found`
- a command you typed but killed with Ctrl-C before it ran
- a command run inside a `script` session
- a command typed with a leading space
- the same command run twice in a row

Then test each, and check the file.

*Done looks like:* six predictions, six observations, and — for any you got wrong — the setting
responsible. At least two of these will probably surprise you.

---

## Stretch

**8.** A validator wants to know how long you spent on a lesson and whether you paused to read
documentation. Using only your history file, work out how much time elapsed between your first and
last command in this session, and find the longest gap between two consecutive commands.

*Done looks like:* both figures, and the method you used. You have not been taught text processing
yet (Chapter 7) — do it by eye if you must, and say so.

---

## Dig

**9.** `script` has a flag that **appends** to an existing transcript instead of overwriting it, and
another that flushes output after every write. Find both, explain when each matters, and say which
one you'd want if the container crashed mid-lesson.

*Done looks like:* both flags, explained, plus your answer on the crash case and why.

**10.** Your history file records commands, but by default bash decides *which* ones to record. Find
the environment variable that controls this, list its possible values, and say which value would
make your history useless as evidence.

*Done looks like:* the variable, its values with meanings, and your answer. Say where you found it —
`man bash` is large, so name the section.
