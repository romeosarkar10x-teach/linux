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

---

## Core — the settings, one at a time

**22.** Print the current value of `HISTCONTROL`, `HISTSIZE`, `HISTFILESIZE`, `HISTFILE` and
`HISTTIMEFORMAT`, each labelled. Then find the file that sets them.

*Done looks like:* five labelled values and the file's path.

**23.** Run `bash -c 'echo "[$HISTSIZE]"'` and then the same thing in your interactive shell. The
answers differ. Explain the difference using 01/01.

*Done looks like:* both outputs and the explanation.

**24.** `HISTSIZE` and `HISTFILESIZE` are two different numbers. Say precisely which one governs
memory and which governs disk, and construct a setting pair where the file would hold *more* than
the list ever did.

*Done looks like:* the two roles and the pair, with one sentence on when that is useful.

**25.** In a **child shell**, set `HISTCONTROL=ignoredups`, run the same command three times in a
row, then run something else and the first command again. Report exactly which of the five entered
the list.

*Done looks like:* the list and the rule stated from evidence.

**26.** In a **child shell**, set `HISTCONTROL=` (empty) and repeat exercise 25. Compare.

*Done looks like:* both lists side by side and one sentence on what an empty value means here.

**27.** There is a variable that stops specific *patterns* from being recorded, rather than
duplicates or leading spaces. Find its name in `man bash`, and set it in a child shell so that
`history` itself is never recorded.

*Done looks like:* the variable, the setting, and evidence it worked.

**28.** In a child shell, set `HISTSIZE=0`. Run three commands and check the list. Then say what
distinguishes this from `HISTFILE=`.

*Done looks like:* the observation and the distinction.

---

## Core — the file on disk

**29.** Without exiting, get this session's new lines into `~/.bash_history`, then show the last
three lines of the file and match them against what you ran.

*Done looks like:* the command, the three lines, and the match.

**30.** Count the entries in `maint-old-history` two ways: by counting all lines, and by counting
only the command lines. The numbers differ by a factor.

*Done looks like:* both numbers, the factor, and why.

**31.** `maint-old-history` contains `history -c` followed by more commands. Using the README's
description of when the file is written, explain in three sentences how both facts can be true at
once.

*Done looks like:* three sentences that account for the file's contents.

**32.** Take the timestamp of the *first* command in `maint-old-history` and the *last*, and work
out how long that session lasted. Show your arithmetic.

*Done looks like:* both epochs, the difference, and the duration in minutes.

**33.** Look at the gaps between consecutive timestamps in `maint-old-history`. One gap is much
larger than the others. Say where it is and offer one plausible account of it.

*Done looks like:* the gap in seconds, its position, and the account.

**34.** Say what the history file does *not* record. List three kinds of thing a person did at that
terminal that leave no trace in it.

*Done looks like:* three items, each with one clause of justification.

---

## Experiment — predict before you run

**35.** **Predict first.** Predict what `!-2` runs after you have run exactly three commands in a
fresh child shell. Then run it.

*Done looks like:* the prediction, the echoed expansion, and the result.

**36.** **Predict first.** Predict what `echo !*` prints after `ls sampler-notes.txt scratch`.
Compare to `!$` and `!^`.

*Done looks like:* three predictions and three echoed expansions.

**37.** **Predict first.** In a child shell, prefix `echo secret` with a space and run it, then run
`history | tail -3`. Predict what you will see. Then predict whether the *space-prefixed* command
appears in `$HISTFILE` after the shell exits.

*Done looks like:* two predictions, two observations.

**38.** **Predict first.** Run `!nosuchcommandprefix`. Predict the message and the exit status
before you press Enter.

*Done looks like:* the prediction, the message quoted, and the status.

**39.** **Predict first.** You type `!$` inside **single quotes**: `echo '!$'`. Predict whether
history expansion happens. Then try it inside double quotes.

*Done looks like:* both predictions, both results, and the rule about when expansion runs.

---

## Stretch

**40.** History expansion happens before the command runs and before you can see the result. Write
down two rules you will follow to keep that from hurting you, and justify each in one sentence.

*Done looks like:* two rules with justifications.

**41.** Using 01/04: `HISTFILE` is an ordinary variable, so it can be changed mid-session. In a
child shell, point it at a file in `scratch/`, run three commands, exit, and read that file.

*Done looks like:* the file's contents and one sentence on what this means for trusting any single
history file.

**42.** Someone claims "the history file proves what the account did". Write three sentences on
where that claim is strong and where it is weak, using only what you have demonstrated in this
lesson.

*Done looks like:* three sentences, with at least one concrete weakness you have shown yourself.

**43.** Using 01/05: name the two keys that make `Ctrl-R` safe, and describe a scenario where using
the wrong one runs a command you did not intend.

*Done looks like:* both keys and the scenario.

**44.** Reconstruct, from `maint-old-history` alone, a short account of what that person was doing
and in what order. Mark clearly which parts are read from the file and which are your inference.

*Done looks like:* a short paragraph with inference marked.

---

## Dig

**45.** There is a builtin that lists, edits and re-runs history entries and is the ancestor of `!!`.
Find it, use it to list a range of entries by number, and use it to re-run one.

*Done looks like:* both invocations and their output.

**46.** That builtin has a form that re-runs the previous command with a substitution. There is also
a shorter `^old^new` form. Use both to fix `cat sampler-note` into `cat sampler-notes.txt`.

*Done looks like:* both forms and both echoed expansions.

**47.** Find the history-expansion **modifier** that prints the expansion instead of running it.
Attach it to a `!!` and show that nothing ran.

*Done looks like:* the modifier and the evidence nothing ran.

**48.** Find the modifiers that extract just the directory part and just the file part of a
`!$`-style word. Use both on a path from this lab.

*Done looks like:* both modifiers and both outputs.

**49.** There is a shell option, settable with `shopt`, that makes history expansion put the result
on your line for confirmation instead of running it immediately. Find it, turn it on in a child
shell, and demonstrate the change.

*Done looks like:* the option name, the command, and the before/after.

**50.** Find the `history` flag that reads only the file's *new* lines into your list, and say how it
differs from `history -r` when you have run it once already.

*Done looks like:* the flag and the difference.

**51.** Find the shell option that appends to the history file on exit instead of overwriting it.
Say which of the README's two-shells problems it fixes and which it does not.

*Done looks like:* the option and both halves of the answer.

**52.** Convert every `#` line in `maint-old-history` into a readable date, in one command, without
editing the file. You may reach ahead for a tool; name the chapter that owns it.

*Done looks like:* the command, the dated output, and the chapter named.
