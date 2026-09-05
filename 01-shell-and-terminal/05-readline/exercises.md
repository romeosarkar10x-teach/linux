# 01/05 — Exercises

```bash
kestrel seed 01/05
kestrel enter
lab 01/05
```

Answers in `~/01-05-answers.md`.

> **How this lesson is checked.** Keystrokes leave almost no trace. A validator cannot tell
> `Ctrl-A` from thirty presses of the left arrow after the fact. So this lesson is graded on a
> **recorded session** (`docs/RECORDING.md`) or a live demonstration, plus your written answers.
>
> That is not a formality. If you do these with arrow keys and backspace, everything will still
> work, you will have learned nothing, and the only person you will have fooled is yourself.
>
> **Record this lesson.** Start with `script ~/01-05-session.log` or asciinema before exercise 1.

---

**Ahead of the syllabus.** This lesson uses `wc -l`, which Chapter 4 teaches properly. Use it
exactly as written here; you are not expected to know it yet.

## Warmup

**1.** Type a long command — a `cat` of the long `.log` filename in this lab — but do **not** press
Enter. Jump to the start of the line. Jump back to the end. Then abandon the line without running
it.

*Done looks like:* three keystrokes used, nothing executed, and the three keys named in your
answers.

**2.** Type any command, then delete the last word of it, then delete the entire line, both without
using backspace.

*Done looks like:* the two keys named.

**3.** Delete a word, then put it back where it was.

*Done looks like:* the two keys named, and confirmation the text returned intact.

---

## Core

**4.** Type the following line exactly, then — without retyping anything and without using the
arrow keys more than five times — change `--05.log` to `--06.log`:

```
cat deck-3-structural-strain-sampler-output-2187-05.log
```

*Done looks like:* the corrected line, and the sequence of keys you used, written out.

**5.** Run `ls -l` on the long June log file. Then, on the **next** line, run `wc -l` on the same
file — without typing or pasting the filename again, and without using the up-arrow to recall and
edit the previous line.

*Done looks like:* both commands run, and the single key you used named.

**6.** Do exercise 5 again, but three commands deep: `ls -l` the file, then `wc -l` it, then `head
-2` it, each time pulling the filename from the line before.

*Done looks like:* three commands and one sentence on what the key does when the previous line's
last argument is not what you want.

**7.** Type a command with a long argument at the end. Cut that argument off the end of the line,
type a different command in front of what remains, then paste the argument back.

*Done looks like:* the final line, and the two keys used.

**8.** Get to the start of a fully typed line, insert a word at the front, and get back to the end —
using only the keys in the "Moving" table. Report how many keystrokes it took.

*Done looks like:* the count and the keys.

---

## Experiment

**9.** **Predict first, then run.** In `readings/` there are five files. You are going to type
`cat readings/s` and press Tab.

Predict: what will happen on the first press? On the second? Now type `cat readings/str` and press
Tab — predict that too.

Then do all of it and record what actually happened.

*Done looks like:* three predictions, three observations, and one sentence on what "nothing
happened" told you.

**10.** **Predict first, then run.** Type a partial filename that matches nothing — for instance
`cat zzz` — and press Tab.

Predict what happens. Then do it. Then say how you could use this behaviour as a *check* before
committing to a long path.

*Done looks like:* prediction, observation, and the use case.

**11.** **Predict first, then run.** With text on the line, press `Ctrl-D`. Then, on an empty line,
predict what `Ctrl-D` will do before you press it.

If your prediction is "it exits the shell", you are right — so do this in a **child shell** you
started with `bash`, not in your main session.

*Done looks like:* both predictions, both observations, and one sentence on why one key has two
behaviours.

---

## Stretch

**12.** Using 01/01: after `Ctrl-D` closes a child shell, confirm from the process table that you
are back in the parent, using the PID you noted before.

*Done looks like:* PIDs before and after, and the confirmation.

**13.** `Ctrl-L` and the `clear` command look identical on screen. Find a situation where they are
not, demonstrate it, and describe the difference in one sentence.

*Done looks like:* the demonstration described, and the sentence.

**14.** Using 01/03: is `clear` a builtin or a program? Classify it, and say why `Ctrl-L` cannot be
either of those things.

*Done looks like:* the classification and the reasoning.

**15.** Time yourself honestly. Take the long June filename and produce this line **twice**: once
by typing every character, once using Tab completion. Report both durations and the ratio.

*Done looks like:* two timings and the ratio, plus one sentence on what that means across forty
thousand commands.

---

## Dig

**16.** readline can be configured. There is a file it reads at startup for key bindings and
settings. Find its name from `man bash` (search for the section on readline), and find the setting
that makes Tab **list matches immediately** on the first press instead of requiring a second.

Do not configure it permanently yet — Chapter 11 owns your dotfiles. Report the file and the
setting.

*Done looks like:* the filename and the setting name, with the man-page section you found them in.

**17.** There is a bash builtin that shows every key binding readline currently has. Find it, use it
to list the bindings, and locate the entries for two keys from this lesson.

*Done looks like:* the command, and the two binding lines quoted.

**18.** readline has a second editing mode, based on a different editor's key bindings, and one
command switches your shell into it. Find it, switch, observe that `Ctrl-A` no longer does what it
did, then switch back.

*Done looks like:* both commands, what changed, and — importantly — confirmation you switched back.
