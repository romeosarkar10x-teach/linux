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

## Core — reading the record properly

**15.** List every command in `dorn-bash-history` in order, numbered, with its timestamp converted
to a readable time. Do it with the tools Chapter 1 gave you.

*Done looks like:* eleven numbered lines with times.

**16.** Work out the gap between each pair of consecutive commands. Report the three longest gaps
and where they fall.

*Done looks like:* three intervals with their positions.

**17.** From the gaps alone, say which parts of that session were someone working steadily and which
were someone reading, waiting, or away. Mark clearly which of your statements are read from the file
and which are inference.

*Done looks like:* two or three sentences with inference marked.

**18.** The session's first command is `cd /var/log/station` and its sixth is `cd ~/samples`. Say
what the working directory was for **every** command in the file, and how you know for each.

*Done looks like:* eleven commands with a directory each.

**19.** One command in the history names a directory that differs from the one on the line after it
by two transposed letters. Identify both lines and say what the pair tells you about the person
typing, not about the station.

*Done looks like:* the line and one sentence.

**20.** Two commands in the file are the *same* command run twice. Find them, and say what happened
between them that makes the repeat sensible.

*Done looks like:* both line numbers and the explanation.

**21.** The `find` line carries four conditions. Without knowing `find`, say what each of the four
words after the path appears to constrain, from their names alone, and how confident you are in
each.

*Done looks like:* four readings with a confidence for each.

---

## Core — the truncated line

**22.** The last line is `./check-sample-integrity.sh strain-2187-0`. List every filename in the lab
directory that this fragment could have been the start of.

*Done looks like:* the candidate list.

**23.** Run the script against every candidate from exercise 22. Record the output and the exit
status of each.

*Done looks like:* one output and one status per candidate.

**24.** From those statuses alone — not the output text — say which candidate was the intended one
and what the other statuses mean. Use 01/03's exit-status material.

*Done looks like:* the identification and the meaning of each status.

**25.** Run the script with **no** argument at all, and with an argument naming a file that does not
exist. Two different failures. Quote both and give both statuses.

*Done looks like:* both messages and both numbers.

**26.** Run the script with the truncated string exactly as it appears in the history —
`strain-2187-0`, no extension. Quote what happens. Say why this is the single most useful thing you
can do before guessing.

*Done looks like:* the output, the status, and the sentence.

**27.** Read `check-sample-integrity.sh` and say, in one sentence each, what its two `exit 2` cases
are for and why they use the same number.

*Done looks like:* two sentences.

**28.** The script prints three lines before it decides anything. Say why a diagnostic tool prints
what it measured before it prints its verdict.

*Done looks like:* two sentences.

---

## Experiment — predict before you run

**29.** **Predict first.** Predict the exit status of the script on the file that passes, before you
run it. Then check with `echo $?`.

*Done looks like:* the prediction and the number.

**30.** **Predict first.** Predict what the script prints for `strain-2187-03.dat` — specifically,
what the two record numbers will be — by reading the data file first.

*Done looks like:* both predicted numbers and the actual output.

**31.** **Predict first.** Predict whether `cat dorn-bash-history > dorn-bash-history` would be
allowed. Do **not** run it. Say what the file's mode tells you and what the redirection would attempt.

*Done looks like:* the prediction and the reasoning. Nothing run.

**32.** **Predict first.** You copy `dorn-bash-history` to your home directory. Predict the copy's
mode before you look.

*Done looks like:* the prediction, the actual mode, and one sentence if they differ.

**33.** **Predict first.** Predict what `head -3` of the passing data file shows, given what the
script reads out of it.

*Done looks like:* the prediction and the run.

---

## Stretch

**34.** Using 01/02: dorn's history file was written by a shell. Name two things in the file that
tell you *which* shell, or say honestly that nothing in it does.

*Done looks like:* the evidence, or the honest negative.

**35.** Using 01/06: the file contains `history -c` two commands before the end, and yet those two
commands are in the file. Give the mechanical account — what was in memory, what was on disk, and
when each was written.

*Done looks like:* three sentences that account for the file exactly as it is.

**36.** Using 01/04: the script uses `${1:-}` and `${declared:-x}`. Explain both, and say what would
break if the second were written `$declared`.

*Done looks like:* both explanations and the failure mode.

**37.** Write the one-line summary of this incident you would put at the top of a handover note.
Facts only, no speculation about the person.

*Done looks like:* one line.

**38.** List three things you would want to look at next that this lab does not contain, and say
what each would tell you.

*Done looks like:* three items with justifications.

**39.** Someone proposes to "fix" the history file by completing its last line so the record is
tidy. Give two reasons that is wrong, one practical and one about evidence.

*Done looks like:* two reasons.

**40.** The two red-herring data files are not mistakes; they are files that exist for a reason.
Give a plausible operational reason each exists, from the data alone.

*Done looks like:* two reasons drawn from the file contents.

---

## Dig

**41.** Produce, in your home directory, a file containing only the timestamps from
`dorn-bash-history` and not the commands. Same constraint as exercise 13: no filtering tool.

*Done looks like:* the file and the method.

**42.** Compare the file's modification time to the timestamp of its last command. Report both and
say whether they agree.

*Done looks like:* both times and the verdict.

**43.** Compare the modification times of all four files in the lab. Put them in order and say what
order that implies for when things were touched.

*Done looks like:* four times in order and one sentence.

**44.** `check-sample-integrity.sh` is mode 755 and `dorn-bash-history` is mode 444. Say what each
of those permits, in words, without using Chapter 10's vocabulary.

*Done looks like:* two plain-language descriptions.

**45.** Find out what happens if you run the script by name without `./`, and explain the result
using 01/03.

*Done looks like:* the message and the explanation.

**46.** Run the script through an explicit interpreter — `bash check-sample-integrity.sh <file>` —
and say why that works even when the mode would not allow the other form.

*Done looks like:* the run and the explanation.

**47.** The script's first line names an interpreter by a path that goes through `env`. Find that
line, and say what it is doing that a direct path would not.

*Done looks like:* the line quoted and the explanation.

**48.** Determine, from the file only, whether the truncated last line was ever actually *run*.
State what evidence would settle it and whether you have that evidence.

*Done looks like:* the answer and the reasoning, including the honest gap.

**49.** Take the token the script printed and say exactly which parts of the data file it came from.
Then say why the script can print it without containing it.

*Done looks like:* the derivation and the sentence.

**50.** Modify a **copy** of the passing data file so the integrity check fails, in the smallest edit
you can manage. Then say what that proves about the check.

*Done looks like:* the edit, the failure, and the conclusion.

**51.** Modify a **copy** of a failing data file so the check passes. Report what token comes out and
whether it means anything.

*Done looks like:* the edit, the output, and the judgement.

**52.** From exercises 50 and 51 together, write two sentences on what an integrity check of this
design can and cannot establish.

*Done looks like:* two sentences.


## The debrief — required

In `~/01-07-debrief.md`, three sentences:

1. What was the truncated command doing?
2. How did you know where it had been cut, and what the missing part was?
3. Why is the last line of a history file so often incomplete?

This is graded. A correct flag with no debrief is a PASS-WITH-NOTES.
