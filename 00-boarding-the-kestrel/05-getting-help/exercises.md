# 00/05 — Exercises

Inside the container. Answers in `~/00-05-answers.md`.

---

## Warmup

**1.** Use the machine's own documentation to find out what `ls -S` does, and confirm it by running
it in a directory with files of different sizes.

*Done looks like:* the meaning of the flag, where you found it, and an output that demonstrates it.

**2.** `cd` has no man page. Find out why, and find where its documentation actually lives.

*Done looks like:* the command that documents `cd`, and one sentence on why `man cd` fails.

---

## Core

**3.** Write a "help request" for an imaginary problem, in the form the tutor agent requires: what
you tried, what you expected, what happened. Use a real command that genuinely fails on your
system — find one.

*Done looks like:* three sections, with real pasted text, not a description.

**4.** You need to find a command whose *description* mentions changing file ownership, but you
don't remember its name. Find it without a search engine.

*Done looks like:* the search command you used, its output, and the command name you were after.

**5.** Read [`docs/TUTOR_PROTOCOL.md`](../../docs/TUTOR_PROTOCOL.md) — the actual instructions the
tutor agent follows. Then write down: which rung do you think you'll be most tempted to try to
skip past, and what would you lose by skipping it?

*Done looks like:* a named rung and an honest answer.

---

## Experiment

**6.** **Predict in writing first.** Start a session with a tutor agent on a lesson you have
already finished (00/03 exercise 6 works well), and pretend to be stuck.

Before you start, write down: how many exchanges do you think it will take before it gives you
something you could act on directly? What will it ask for first?

Then do it, honestly playing a stuck student. Try one jailbreak of your choice — genuinely try.

*Done looks like:* your prediction, a transcript or summary of what happened, whether the jailbreak
worked, and one sentence on how the experience differed from what you expected. If the agent broke
its own rules, report that — it's a bug in the course and worth knowing.

---

## Stretch

**7.** In 00/01 you found the man section numbers. Use that: find the man page for the **file
format** of the file that lists user accounts (not the command with the same name), and write down
what its second field means.

*Done looks like:* the exact command you used, and the field's meaning. You met this file in 00/04
exercise 4 without being told what it was.

---

## Dig

**8.** `man` can search *inside* every man page on the system, not just the short descriptions.
Find the flag that does it, explain how it differs from `apropos`, and use it to find every page
that mentions "sticky bit".

*Done looks like:* the flag, the difference explained, and the output. Say where in `man man` you
found it.

> Warning: it's slow the first time. That's expected — think about why, and about what `apropos` is
> doing differently.

**9.** Find out how to make `man` show you *all* the sections matching a name, one after another,
instead of just the first. Then use it on `passwd`.

*Done looks like:* the flag and the output showing more than one section.
