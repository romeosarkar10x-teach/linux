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

---

## Core — the keys you have not met yet

**19.** `Ctrl-W` and `Alt-Backspace` both delete the word before the cursor, and they do not always
delete the same thing. Type `cat /labs/01-shell-and-terminal/05-readline/readings/strain-bay1.txt`
and try each on the end of that line.

*Done looks like:* what each one removed, and the rule that explains the difference.

**20.** Undo exists. Delete half a line, then undo it. Find the key by feel first; if you cannot,
exercise 39 will tell you how to look it up.

*Done looks like:* the key and a description of how far back one press goes.

**21.** Cut three different things in a row with `Ctrl-W`. Paste the last one back with `Ctrl-Y`,
then reach the one before it.

*Done looks like:* the two keys and the order things came back in.

**22.** There is a key that swaps the two characters either side of the cursor and one that swaps
the two words. Fix `cat raedings/strain-bay1.txt` with the first, and reorder a two-word argument
list with the second.

*Done looks like:* both fixes and both keys.

**23.** Type a line, then throw away everything from the cursor to the *start* of the line, and
separately everything to the *end*. Say which of those two the kill ring keeps.

*Done looks like:* both keys and the answer.

**24.** There is a key that abandons every edit you have made to a recalled line and restores it to
what it was. Find it by feel or by looking ahead to exercise 39, and demonstrate it.

*Done looks like:* the key and a before/after description.

**25.** Press `Ctrl-V` and then `Ctrl-A`. Something appears on the line instead of the cursor
jumping. Explain what you are looking at.

*Done looks like:* what appeared and one sentence on what the key does.

---

## Core — completion in anger

**26.** In `readings/`, type `cat readings/st` and press Tab twice, then `cat readings/str` and Tab
twice. Record the number of matches at each stage and where completion stopped.

*Done looks like:* both stages, and one sentence on why it stops where it does.

**27.** Complete a **directory** name with Tab and look carefully at what it appends. Then complete
a file name. The two are not the same.

*Done looks like:* both completions quoted exactly, including the last character.

**28.** Type `cat READINGS/` and press Tab. Nothing completes. Say why, and name the readline
setting that would change it — exercise 39 has the lookup method.

*Done looks like:* the reason and the setting name.

**29.** Completion at the **start** of a line completes something different from completion in the
middle. Demonstrate both with `dec<Tab>` at the start and `dec<Tab>` after `cat `.

*Done looks like:* both results and the rule.

**30.** Create a file whose name contains a space, then Tab-complete it. Look at exactly what
readline inserted.

*Done looks like:* the inserted text quoted, and how it connects to 01/04's quoting.

**31.** Tab-complete a name that has no matches at all, then one that has exactly one match, then
one that has many. Three different behaviours, one of which is silence.

*Done looks like:* three descriptions and the use of silence as a check.

---

## Core — pulling from the line before

**32.** Run three commands, each with a different last argument. Then press `Alt-.` four times on a
fresh line and record what appears each time.

*Done looks like:* four values in order and one sentence on the order.

**33.** `Alt-.` takes the *last* argument. Find the key that takes the *first* argument of the
previous line, and use it.

*Done looks like:* the key and a demonstration.

**34.** Run `ls -l` on the 05 log, then produce `wc -l` on the 06 log without typing either full
name — pull the name, then edit one character.

*Done looks like:* the final command and the keys used, in order.

---

## Experiment — predict before you run

**35.** **Predict first.** On a line reading `cat foo bar baz` with the cursor at the very end,
predict what `Ctrl-W` leaves, then what a second `Ctrl-W` leaves, then a third.

*Done looks like:* three predictions and three observations.

**36.** **Predict first.** Predict what `Ctrl-K` does with the cursor already at the end of the
line, and what `Ctrl-Y` does immediately afterwards.

*Done looks like:* both predictions and what actually happened to the kill ring.

**37.** **Predict first.** You have typed half a command. Predict what `Ctrl-L` leaves on screen and
what `clear` would leave. Then run both.

*Done looks like:* both predictions and the observed difference.

**38.** **Predict first.** Predict what `Ctrl-C` does to a half-typed line, and whether that line is
recoverable afterwards. Then test it.

*Done looks like:* the prediction, the test, and the answer about recovery.

---

## Stretch

**39.** There is a builtin that answers "which key runs this readline command" and another form that
answers "what does this key do". Use both to look up the undo key and to find out what `Ctrl-T` is
bound to.

*Done looks like:* both invocations and both answers.

**40.** Run that same builtin from a non-interactive shell — `bash -c 'bind -q undo'`. Something
extra appears. Explain it using 01/01's distinction.

*Done looks like:* the extra line quoted and the explanation.

**41.** Readline settings have current values, not just names. Print all of them and pick out three
that would change how completion behaves.

*Done looks like:* the command and three settings with their current values.

**42.** There is a key that opens your current command line in an editor, lets you edit it there,
and runs it on save. Find it, use it on a long line, and say when that is better than editing in
place.

*Done looks like:* the key, the demonstration, and the judgement.

**43.** Write, in your own words, the four-line summary of this lesson you would hand to a colleague
who types every command in full. No key may appear that you have not used yourself.

*Done looks like:* four lines.

---

## Dig

**44.** The keys in this lesson are named after an editor. Find the setting that switches readline
to the *other* editor's bindings, switch, discover what replaces `Ctrl-A`, and switch back.

*Done looks like:* both commands, the replacement, and confirmation you are back.

**45.** Find the readline command that lists every possible completion without inserting anything,
and the one that inserts *all* of them onto the line at once. Use both.

*Done looks like:* both keys and what each did.

**46.** Find the key that comments out the current line and submits it. Explain what that is for.

*Done looks like:* the key, what appeared in the history, and the use case.

**47.** `bind -l` lists readline command names. Count them. Then find three whose names describe
something this lesson never mentioned, and say what each does.

*Done looks like:* a count and three names with one line each.

**48.** Some readline commands are listed as "not bound". Find two, and say why a command might ship
with no key attached to it.

*Done looks like:* two names and the reasoning.

**49.** Find the difference between the `unix-word` family of commands and the `shell-word` family.
Demonstrate it on a path containing a hyphen.

*Done looks like:* the demonstration and the rule.

**50.** Find where readline's startup file lives, both per-user and system-wide, and confirm from
the container which of the two exists.

*Done looks like:* both paths and which is present.

**51.** Readline is a library, not a bash feature — which is why the same keys work in other
programs. Find out which programs on *this* box actually link against it, using `ldd` on a few
candidates. The answer here is surprising; report it honestly and say what that tells you about
assuming.

*Done looks like:* the command you used, the result for at least three programs, and the conclusion.

**52.** Find the setting that controls what happens when completion has too many matches to show at
once, and its current value.

*Done looks like:* the setting, its value, and what it does.
