# 01/03 — Exercises

```bash
kestrel seed 01/03
kestrel enter
lab 01/03
```

Answers in `~/01-03-answers.md`.

> **Note.** This lab deliberately contains files named `-l` and `--help`. That is not a mistake and
> you should not rename them. Deleting them by accident is fine — `kestrel reset 01/03` puts them
> back.

---

## Warmup

**1.** Classify these five words, using the one command that answers "what will actually run":
`cd`, `ls`, `if`, `echo`, `type`.

*Done looks like:* five classifications.

**2.** Run `deck-report` from the lab's `bin/` with three arguments of your choosing. Read its
output and say, in one sentence, what it proves about how the shell splits a line.

*Done looks like:* the output and the sentence.

**3.** Pass `deck-report` a single argument that contains a space, so it reports **one** argument
rather than two.

*Done looks like:* output showing `1 argument(s)`.

---

## Core

**4.** Find every `echo` on this system, in resolution order. Say how many there are, which one runs
when you type `echo`, and why.

*Done looks like:* the full list, the count, and the reason.

**5.** Ask the same question with `which` instead. Report what `which` shows that the first command
did not, and what it **misses**. Then do the same pair for `cd`, and explain the difference in the
results.

*Done looks like:* both outputs for both words, and a sentence naming what `which` cannot see.

**6.** There is a file in this lab named `-l`. Read its contents. `cat -l` will not work — find out
why from the error, then get the contents out **two different ways**.

*Done looks like:* the file's contents, both methods, and one sentence on why the naive attempt
failed.

**7.** Same problem, worse: read the file named `--help`. Start with the naive attempt again.

This time the *failure* is different — you do not get an error, you get something else entirely, and
a careless reader would not even notice their file was never read. Report what you got, then read
the file properly with both of your exercise-6 methods.

*Done looks like:* the naive attempt's output, the contents via both methods, and one sentence on
why this failure mode is more dangerous than exercise 6's.

**8.** Make an alias `ll` that gives you a long listing. Prove with a classifier command that `ll`
is an alias and not a program. Then run the underlying command with the alias bypassed. Then remove
the alias and prove it is gone.

*Done looks like:* four steps, each with its output.

**9.** `bin/deck-report` is executable but typing `deck-report` gives you `command not found`.
Explain why in one sentence, then run it anyway — twice, by two different paths that both refer to
the same file.

*Done looks like:* the sentence and two successful runs.

**10.** Pass `deck-report` these four things and record exactly what it reports for each:
a word with a space in it, an empty string, the two characters `-l`, and the single character `*`
while standing in the lab directory.

The last one will surprise you. Do not try to explain it — just record it accurately. Chapter 5 is
about exactly that.

*Done looks like:* four recorded outputs, honestly transcribed.

**11.** There is an `ls` in this lab's `bin/`. It is not the real `ls`. Without changing `PATH` —
that is Chapter 11 — run it, then run the real one, then say in one sentence what would happen if
`bin/` were early on your `PATH`.

*Done looks like:* both runs and the sentence.

---

## Experiment

**12.** **Predict first, then run.** The shell's builtin `echo` and the external `/usr/bin/echo`
are different programs. Predict whether these two produce the same output:

```
echo --version
/usr/bin/echo --version
```

Write the prediction, run both, and explain the difference in terms of the five kinds of command
word.

*Done looks like:* prediction, both outputs, explanation.

**13.** **Predict first, then run.** Define `alias ls='ls -l'`. Predict what happens when you then
run `ls`: does it expand once, or does the alias's own `ls` expand again, and again, forever?

Write your prediction and your *reasoning*, then run it. Then remove the alias.

*Done looks like:* prediction with reasoning, observation, and one sentence on what the shell does
to prevent the obvious disaster.

---

## Stretch

**14.** Combine this lesson with 01/02: `type` classifies `[[` as a keyword in bash. Start a dash
shell and find out how dash classifies these three words — `cd`, `echo`, `[[` — using the portable
classifier the notes mention. Report all three and note any that differ from bash.

*Done looks like:* three dash results, compared against bash.

**15.** Using 01/01: `deck-report` is a shell script. Run it and, while it is running, you cannot
inspect it — it is too fast. Instead, answer from what you know: when you run it, how many processes
exist that did not before? Name them and say which is the parent of which.

*Done looks like:* a count, the names, and the parent relationship. Reasoning, not measurement.

**16.** Write one line in your answers file that a colleague could run to find out whether `grep` on
their machine is a program, a builtin, an alias, or a function — and that would also show them where
it is if it is a program.

*Done looks like:* one command, and one sentence on why you chose it over the alternatives.

---

## Dig

**17.** `type` has a flag that makes it report a bare path and nothing else, the way `which` does.
Find it in `help type`, then run it on `ls` **and** on `echo`.

One of those two prints nothing at all. Work out why — the answer is in the resolution order — and
say when this flag would be the right choice and when it would silently mislead you.

*Done looks like:* the flag, both outputs, the explanation of the empty one, and the two use cases.

**18.** The shell caches where it found each program, so it does not search `PATH` every single
time. There is a builtin that shows and clears that cache. Find it, show your cache, clear it, and
show it again.

*Done looks like:* three outputs, plus one sentence on the bug this cache can cause — a program
moved on disk while the shell was running.

**19.** In exercise 4 you found that the builtin `echo` wins over the three on disk, and that you
could only reach the others by naming a full path. That is not quite true — bash has a builtin that
lets you **switch a builtin off**, so the disk version wins instead.

Find it, use it to make a bare `echo` run the external program, prove it worked by getting version
output from a plain `echo --version`, then switch the builtin back on and prove *that*.

*Done looks like:* four steps with outputs, plus one sentence on why you would rather do this than
edit `PATH`.
