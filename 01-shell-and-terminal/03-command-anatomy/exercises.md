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

---

## Core — words, splitting, and what the command sees

**20.** Run `deck-report` with the argument list `a  b` (two spaces). How many arguments arrive, and
where did the second space go?

*Done looks like:* the count and the explanation.

**21.** Now `deck-report "a  b"`. One argument, spaces intact. State the rule in one sentence.

*Done looks like:* the output and the rule.

**22.** `deck-report ''` — an empty argument. Does it arrive? Prove it from the report.

*Done looks like:* the output and a yes or no with evidence.

**23.** `deck-report` with no arguments at all. How does the report distinguish this from
exercise 22?

*Done looks like:* both outputs side by side.

**24.** Pass `deck-report` an argument that begins with a dash and is not a flag it knows. What does
it do, and what *could* a program do in that situation?

*Done looks like:* the observed behaviour and two alternatives named.

**25.** Use `--` to pass that same dashed word as a plain argument. Report the difference.

*Done looks like:* both invocations and the effect of `--` in one sentence.

**26.** `deck-report $UNSET_THING` where the variable does not exist. How many arguments arrive?
Now quote it. How many now?

*Done looks like:* two counts and the reason they differ.

**27.** Name the four things the shell does to a command line before the program ever starts, in
order, using only what you have seen in this lesson.

*Done looks like:* four named steps. Chapter 5 makes this list longer and exact; a rough correct
order is the goal here.

---

## Core — resolution order in anger

**28.** Build the full precedence list from evidence: alias, function, builtin, keyword, file on
`PATH`. Demonstrate at least three of the five winning over something below them.

*Done looks like:* three demonstrations and the ordered list.

**29.** Define a shell function named `deck-report` that prints one line. Now run `deck-report`.
Which one ran, and how do you get the file instead without deleting the function?

*Done looks like:* the function, the run, and the escape route.

**30.** Do the same with an alias named `cat`. Then defeat the alias three different ways.

*Done looks like:* three working escapes.

**31.** `unset -f` and `unalias` remove your two overrides. Confirm with the classifier command that
each is gone.

*Done looks like:* two before-and-after classifications.

**32.** `command` and `builtin` are both ways of skipping part of the resolution order. Run each on
`echo` and say precisely what each one skips.

*Done looks like:* two outputs and two sentences.

**33.** Print `PATH` one directory per line and say which of them you can write to. Then say why the
order of that list is a security question and not just a convenience.

*Done looks like:* the list and the argument.

**34.** Put the lab's `bin/` at the *front* of `PATH` in a throwaway shell and run `ls`. Then put it
at the *back* and run `ls` again. Report both, then leave that shell.

*Done looks like:* two results and the conclusion about where a directory sits in `PATH`.

---

## Core — reading a command line you did not write

**35.** `bin/deck-report -v --deck 5 spares -- -x` — before running it, write down how many
arguments you expect the program to receive and what each is. Then run it and compare.

*Done looks like:* the prediction, the report, and any correction.

**36.** In that line, which words did the shell interpret and which did it hand over untouched?

*Done looks like:* two lists.

**37.** Someone writes `deck-report -deck 5`. It behaves differently from `--deck 5`. Say what the
program most likely did with the single-dash form, and why guessing is not enough.

*Done looks like:* the reading and the reason to check the program's own documentation.

**38.** Write down the shape of a command: name, options, option arguments, operands, `--`. Label
every word of the exercise-35 line with one of those.

*Done looks like:* a fully labelled line.

---

## Experiment — predict before you run

**39.** **Predict first.** `type type`. Predict the classification, then run it.

*Done looks like:* prediction and output.

**40.** **Predict first.** After `hash -r`, will the shell find `deck-report` faster or slower on the
next run? Predict, then reason about what `hash -r` actually discarded.

*Done looks like:* the prediction and the corrected reasoning.

**41.** **Predict first.** You add the lab's `bin/` to `PATH`, then move `bin/ls` away, then run `ls`
without `hash -r`. Predict what happens. Then do it.

*Done looks like:* prediction, the error quoted exactly, and the fix.

**42.** **Predict first.** `alias echo='echo prefix:'` and then `echo hello`. Predict the output.
Then predict what `\echo hello` prints. Then run both.

*Done looks like:* two predictions, two outputs, one sentence on recursion in aliases.

**43.** **Predict first.** Does `type` consult the disk for a name that is already hashed? Predict,
then use `type -a` and `hash` together to argue for your answer.

*Done looks like:* the argument, whichever way it comes out.

---

## Stretch

**44.** Write the shortest command line you trust to answer "what will run if I type `X` right
now?", and justify each part of it against a case where a simpler answer would mislead.

*Done looks like:* the command and three misleading cases it survives.

**45.** A script fails only when run from `cron`-like environments with a minimal `PATH`. Using this
lesson, explain the failure and give two fixes, one good and one bad.

*Done looks like:* the diagnosis and both fixes, labelled.

**46.** Explain to a colleague why `which` is the wrong tool inside a script, in two sentences.

*Done looks like:* two sentences naming the shell's own knowledge.

**47.** The lab's fake `ls` is a real hazard in miniature. Describe how the same shape could be an
attack, and one habit that prevents it.

*Done looks like:* the scenario and the habit.

---

## Dig

**48.** Find out whether an alias defined in an interactive shell is visible to a script you run
from that shell. Prove it either way.

*Done looks like:* the experiment and the result.

**49.** Find the shell option that makes aliases work in a non-interactive shell, and say why it is
off by default.

*Done looks like:* the option and a reason.

**50.** `enable` can turn a builtin off. Turn off `echo`, run `echo`, and report what runs instead.
Then turn it back on.

*Done looks like:* the three states and the path of whatever took over.

**51.** Find out how the shell decides a file is executable when it searches `PATH`, and confirm a
non-executable file with the right name is skipped rather than reported.

*Done looks like:* the experiment and the result.

**52.** Find out what `PATH=` with an empty element (a leading, trailing or doubled colon) means.
Then check whether this machine's `PATH` has one.

*Done looks like:* the meaning, the check, and one sentence on why it matters.
