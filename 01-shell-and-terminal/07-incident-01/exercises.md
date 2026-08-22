# 01/07 — Exercises

```bash
kestrel seed 01/07
kestrel enter
lab 01/07
```

Answers in `~/01-07-answers.md`. The debrief goes in `~/01-07-debrief.md`.

> **The one rule:** `dorn-bash-history` is not to be modified. Read it, copy from it, do not write
> to it. It is set read-only and the validator checks.

---

## Warmup

**1.** Read `dorn-bash-history` in full. Report how many commands it contains — commands, not lines.

*Done looks like:* the count, and one sentence on why those two numbers differ.

**2.** Report the working directory dorn was in when the session ended, and how you know.

*Done looks like:* the directory and the line that establishes it.

---

## Core

**3.** Two lines in that history look like leads and are not. Identify both, and say for each what it
actually is.

Write this **before** you start reconstructing anything. Ruling things out first is the whole
technique, and doing it afterwards is just narration.

*Done looks like:* two lines quoted, two explanations.

**4.** The final line is cut. Quote it exactly as it appears, and say precisely where the cut falls
— which word, and at which character.

*Done looks like:* the fragment quoted and the cut located.

**5.** Reconstruct the complete command. You should be able to justify every character you add from
something else in the lab or the history — not from a guess.

*Done looks like:* the reconstructed command, plus, for each part you supplied, the evidence you
supplied it from.

**6.** **FLAG.** Run the reconstructed command. Submit the token.

```bash
kestrel flags submit 'KESTREL{...}'     # from the VM
```

*Done looks like:* the token accepted.

**7.** Run the same script against the other two sample sets in the lab. Report what happens, and
say what that tells you about whether your reconstruction in exercise 5 was the only possible one.

*Done looks like:* both outputs and the conclusion.

---

## Experiment

**8.** **Predict first, then run.** Before running anything: the history file has a `history -c`
two commands before the end. Predict what that means for the lines *after* it — should they be
there at all?

Then look at the file again and explain what you see.

*Done looks like:* the prediction, what the file actually contains, and the explanation.

**9.** **Predict first, then run.** Load `dorn-bash-history` into a **child shell**'s history list
and look at it there.

Predict first: will the timestamps display? Will the truncated line appear as a command you could
recall and edit?

Then do it. Then exit that child shell, and say in one sentence why you would not do this in your
main session.

*Done looks like:* two predictions, the dated listing, and the reason.

---

## Stretch

**10.** Convert the timestamp of the truncated command into a readable date and time. Then say how
long before it the previous command ran.

*Done looks like:* the date and time, and the interval.

**11.** Using 01/03: `check-sample-integrity.sh` is run as `./check-sample-integrity.sh`. Explain
why the leading `./` is there, and what would happen without it.

*Done looks like:* two sentences.

**12.** Using 01/06: dorn's session ended at the timestamp you found in exercise 10, and the file
stops mid-word. Give a specific, mechanical account of how a file ends up in that state — not "the
session ended", but what was happening at that instant.

*Done looks like:* three or four sentences describing the mechanism.

---

## Dig

**13.** Without modifying `dorn-bash-history`, produce a copy of it in your home directory that
contains **only** the commands, with the timestamp lines removed. You have not been taught a tool
that filters lines — do it with what you have, and say what you would rather have had.

*Done looks like:* the file, the method, and the wish-list.

**14.** `dorn-bash-history` is read-only. Prove it: try to modify it and quote the error. Then say
who *could* modify it and why the file being read-only is not, on its own, much protection.

*Done looks like:* the error quoted, and two sentences. Do not actually modify it.

---

## The debrief — required

In `~/01-07-debrief.md`, three sentences:

1. What was the truncated command doing?
2. How did you know where it had been cut, and what the missing part was?
3. Why is the last line of a history file so often incomplete?

This is graded. A correct flag with no debrief is a PASS-WITH-NOTES.
