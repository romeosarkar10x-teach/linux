# 01/06 — Exercises

```bash
kestrel seed 01/06
kestrel enter
lab 01/06
```

Answers in `~/01-06-answers.md`.

> **Two warnings before you start.**
>
> Several exercises change history settings. Do them in a **child shell** (`bash`) wherever the
> exercise says so, and do not leave `HISTFILE` unset or `HISTSIZE` tiny in your main session — you
> will lose work you want later, including the evidence a validator needs.
>
> Nothing in this lesson asks you to delete `~/.bash_history`. Do not.

---

**Ahead of the syllabus.** This lesson uses `wc -l`, `head -1`, which Chapter 4 teaches properly.
Use it exactly as written here; you are not expected to know it yet.

## Warmup

**1.** Show the last ten commands you ran, with their numbers.

*Done looks like:* the listing.

**2.** Re-run your previous command without retyping it.

*Done looks like:* the same command run twice, visible in history.

**3.** Run `wc -l` on `sampler-notes.txt`, then run `head -1` on the same file using the
last-argument shortcut. Note what bash prints before it runs.

*Done looks like:* both commands, and the echoed expansion quoted.

---

## Core

**4.** Find a command you ran earlier in this course by searching for a fragment of it, and put it
**on your line without running it**. Then abandon it.

*Done looks like:* the key you used to search, the key you used to stop it running, and the command
you found.

**5.** Do it again, but this time run the found command.

*Done looks like:* the command re-run, and one sentence on why you would usually want the other key
first.

**6.** Recall a specific command by its history number. Then recall the most recent command that
*starts with* `cat`, then the most recent command that *contains* `strain` — three different forms.

*Done looks like:* three recalls with the form used for each.

**7.** Show that the history list and the history file disagree. Concretely: run a distinctive
command, show it in the list, and show it is **not** yet in `~/.bash_history`. Then make it appear
in the file without exiting the shell.

*Done looks like:* the command absent from the file, then present, with the step you took between.

**8.** `maint-old-history` is a history file recovered from a decommissioned account. Read it and
report: how many commands it holds, what the `#` lines are, and what the account's last complete
command was.

*Done looks like:* the count, the explanation of the `#` lines, and the last complete command.

**9.** The final line of `maint-old-history` is not a complete command. Say what it was probably
going to be — the lab directory contains the answer — and give a specific reason a history file's
last line ends up like that.

*Done looks like:* the reconstruction and the reason.

**10.** One of the commands in `maint-old-history` clears the history list. Say what it does **not**
do, and explain why the commands after it still appear in the file.

*Done looks like:* two sentences, both precise.

**11.** In a **child shell**, prefix a command with a single space, run it, and show it is absent
from that shell's history. Then show which setting made that happen.

*Done looks like:* the command, its absence, and the setting's value.

**12.** In a **child shell**, set `HISTSIZE` to `3`. Run five distinct commands in `scratch/`. Show
what the history list contains afterwards, then exit that shell and report whether your main
session's history was affected.

*Done looks like:* the truncated list, and the main-session check.

---

## Experiment

**13.** **Predict first, then run.** You are going to run:

```
echo one
echo two
!!
```

Predict what the third line runs. Then predict what a **fourth** `!!` immediately after would run.

*Done looks like:* two predictions, the actual outputs, and one sentence on what `!!` refers to
after it has been used once.

**14.** **Predict first, then run.** Predict the output of:

```
ls sampler-notes.txt scratch
echo !$
echo !^
```

Write all three predictions before running anything.

*Done looks like:* three predictions, three observations, and an explanation of any mismatch.

**15.** **Predict first, then run.** Open two shells at once. In shell A run a distinctive command.
In shell B, immediately run `history` and look for it.

Predict whether B sees it. Then predict what happens if A exits and B *then* runs `history -r`.

*Done looks like:* two predictions, two observations, and one sentence on why terminals do not share
history live.

---

## Stretch

**16.** Using 01/04: `HISTCONTROL`, `HISTSIZE` and `HISTFILE` are variables. In a child shell,
demonstrate the difference between `HISTFILE` being **unset** and being set to an **empty string**,
in terms of what happens on exit.

Predict first — this is the unset-versus-empty distinction landing somewhere real.

*Done looks like:* both cases, what you observed, and whether the distinction mattered here.

**17.** Using 01/05: `Alt-.` and `!$` give you the same text. Construct a situation where using `!$`
does something you did not intend and `Alt-.` would have shown you the problem first.

*Done looks like:* the situation, both attempts, and one sentence on the general lesson.

**18.** Using 01/03: classify `history` — builtin, program, or something else. Then explain why the
answer has to be what it is, in terms of where the history list lives.

*Done looks like:* the classification and the reasoning.

---

## Dig

**19.** `maint-old-history`'s `#` lines are seconds since an epoch. Find a command that converts one
into a readable date, and report the date of that account's last complete command.

*Done looks like:* the command, the date, and the man-page section you found it in.

**20.** You can load another history file into your own shell's list without exiting or losing what
you have. Find the flag, load `maint-old-history` **in a child shell**, and show its commands
appearing in `history` — with dates, because your shell displays timestamps.

Then say why doing this in your main shell would be a bad idea.

*Done looks like:* the command, the dated listing, and the reason.

**21.** There is a history-expansion form that lets you re-run a previous command **with a
substitution applied** — fixing a typo without retyping the line. Find it in `man bash` (search for
"Event Designators" and read on into "Modifiers"), and use it to turn a command that referenced
`sampler-notes.txt` into one that references `maint-old-history`.

*Done looks like:* the form, the command, and the echoed expansion.
