# 01/04 — Exercises

```bash
kestrel seed 01/04
kestrel enter
lab 01/04
```

Answers in `~/01-04-answers.md`.

---

## Warmup

**1.** Set a variable `deck` to `3` and print it. Then print it with the word `plating` appended
directly, with no space.

*Done looks like:* two outputs, the second reading `3plating`.

**2.** Print the exit status of a command that succeeds, and of one that fails.

*Done looks like:* two readings, one `0` and one non-zero, each taken immediately after the command
it describes.

**3.** Print your home directory and your current directory using variables the shell already set,
without typing either path.

*Done looks like:* two outputs.

---

## Core

**4.** Reproduce all three of these errors deliberately, and explain each one in terms of how the
shell splits a line:

```
deck = 3
deck =3
deck= 3
```

The third produces a *different* error from the first two. Say why.

*Done looks like:* three errors quoted verbatim and three explanations.

**5.** Demonstrate the three states of a variable — unset, set-but-empty, set-with-a-value — and
show that `echo` cannot tell the first two apart. Then find an expansion that can, and prove it
distinguishes them.

*Done looks like:* the three states, the identical `echo` output for two of them, and the
distinguishing test.

**6.** `sample-names.txt` contains three values, each containing spaces. Assign the first one to a
variable and print it back so that it comes out identical to the file. Then do the same without
quoting the expansion, and describe the difference in the output.

*Done looks like:* both outputs, and one sentence on what happened to the spaces.

**7.** Set a variable and then remove it so that it no longer exists at all — not merely emptied.
Prove the difference between what you did and simply assigning an empty string.

*Done looks like:* both operations, and a test that distinguishes the results.

**8.** `deck-config` describes three settings. One has a value, one is explicitly blank, one is not
listed. For each, say which of the three variable states it corresponds to, and which default-value
expansion a script should use to read it correctly.

Note the file's own comment about what a blank value means. That comment changes the right answer
for one of the three.

*Done looks like:* three settings, three states, three expansions, with the reasoning for the blank
one spelled out.

**9.** Set `ALERT_THRESHOLD` to the empty string in your shell. Now write two expansions of it side
by side: one that substitutes `default` and one that does not. Explain what single character
separates them.

*Done looks like:* both expansions, both outputs, the character named.

**10.** Show that `${x:-d}` does not change `x`, and that `${x:=d}` does. Use a fresh variable name
for each so the results are unambiguous.

*Done looks like:* four readings — before and after, for each form.

**11.** Use the fail-if-unset expansion on a variable you have not set. Record the message and the
exit status. Then set it and show the same expansion now succeeds.

*Done looks like:* the failure, its exit status, and the success.

---

## Experiment

**12.** **Predict first, then run.** Read `report.sh` without running it. Predict all three lines it
will print.

Then run it. One line will not match your prediction. Explain what the shell did with that line,
using the notes' rule about where a variable name ends.

*Done looks like:* three predictions, actual output, and the explanation.

**13.** **Predict first, then run.** `report.sh` has a second problem that the current values hide.

Predict what happens if you change `title` to be assigned **without quotes** — i.e. `title=deck 3
bay 2`. Will it error? Will it assign something odd? Write your prediction *and your reasoning*,
then edit a copy of the script and find out.

Work on a copy — `report.sh` should still be original when you finish.

*Done looks like:* prediction with reasoning, the observed result, and one sentence connecting it
to exercise 4.

**14.** **Predict first, then run.** Predict the output of this sequence:

```
ls /nonexistent
echo $?
echo $?
```

Write down both numbers before running. Then explain the second one.

*Done looks like:* two predictions, two observations, one explanation.

---

## Stretch

**15.** Using 01/03: is `unset` a program on disk or something the shell does itself? Answer with a
classifier command, then explain in one sentence why the answer has to be what it is.

*Done looks like:* the classification and the reasoning.

**16.** Using 01/01 and 01/02: print, in a single `echo` line, this shell's PID, how it was invoked,
and its exit-status-of-last-command — all via variables, with each labelled. Get the punctuation
right so the labels stay readable when the values are adjacent to letters.

*Done looks like:* one line of output with three labelled values, using braces where they are
needed.

**17.** Write a single line that prints the value of `EDITOR` if it is set to something, and the
word `nano` otherwise — without setting `EDITOR`, and without an `if` statement (which you have not
been taught).

Then set `EDITOR` to an empty string and run the same line again. Report whether the answer changed,
and say whether that behaviour is the one you would want in a real script.

*Done looks like:* two runs and a judgement with a reason.

---

## Dig

**18.** There is an expansion that gives you the **length** of a variable's value. Find it, and use
it to show the length of one of the values from `sample-names.txt`. Then use it on an unset variable
and report what you get.

*Done looks like:* the expansion, two results, and one sentence on the unset case.

**19.** The `:+` form is the mirror of `:-`. Work out what it does from the notes' table, then find
a use for it: write one line that prints `interval is set` when `SAMPLE_INTERVAL` has a value and
prints **nothing at all** — not even a blank line — when it does not.

Getting "nothing at all" exactly right is the exercise. Check with something that reveals whether a
newline was printed.

*Done looks like:* the line, both cases demonstrated, and evidence about the newline.

**20.** bash has an option that makes the shell treat any reference to an unset variable as a fatal
error. Find it, turn it on in a **subshell** so you do not wreck your session, and show that
referencing an unset variable now fails. Then show that `${x:-default}` still works with the option
on.

*Done looks like:* the option named, the failure, and the surviving expansion. Say in one sentence
why that last fact makes the option usable in practice.
