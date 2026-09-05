# 02/01 — Exercises

Lab: `/labs/02-navigating-the-filesystem/01-filesystem-tree`

Seed or reset it from the VM with `kestrel seed 02/01` / `kestrel reset 02/01`.

Unless an exercise says otherwise, start each one from the lab directory.

---

## Warmup

**1.** Print your working directory. Then `cd` with no arguments at all, print it again, and write
down in one line what `cd` with no arguments means.

**2.** From your home directory, display `roster.txt` in the lab using an **absolute** path. Do not
`cd` first.

**3.** Change into the lab directory, then display `roster.txt` again using a **relative** path
consisting of nothing but the filename.

---

## Core

**4.** Standing in the lab directory, list the entries of `deck-3` three different ways: by relative
path, by absolute path, and by a relative path that starts by going *up* and coming back down.
Record all three commands.

**5.** Change into `deck-3/bay-3`. Without using an absolute path and without using `cd` more than
once, display `deck-3/bay-1/survey.txt`.

**6.** Still in `deck-3/bay-3`, display `roster.txt` — which is two levels above you — using a
relative path.

**7.** From `deck-3/bay-1`, change directly to `deck-3/bay-2` in a single `cd` with a relative
path. There is no correct answer that uses an absolute path here.

**8.** Change into `deck-3/bay-2/panels/panel-07` in one command from the lab root, then get back to
the lab root in one command using a relative path. Write down how many `..` components you needed
and why that number.

**9.** From `deck-3/bay-2/panels/panel-07`, display `deck-3/bay-3/survey.txt` with a relative path.
Then display the same file with an absolute path. Say in one line which one you would put in a
script and why.

**10.** Change into `shortcut`. Print the working directory. Then print the working directory
again in the form the kernel would report — every symlink resolved. Record both outputs.

**11.** Without changing directory, print the fully resolved physical path of `shortcut/survey.txt`.

**12.** From inside `shortcut`, run `cd ..` and print the working directory. You are not where the
physical path from exercise 10 would predict. Explain in two lines which of the two paths the shell
used to compute `..`, and why the shell chose that behaviour.

**13.** Standing in `deck-3/bay-2/panels/panel-07`, use `..` to display `readings.log`, which lives
in `bay-2`.

**14.** Using `deck-3/bay-2/readings.log`, produce these three outputs, one command each:
the directory part, the filename part, and the filename with its `.log` extension stripped.

---

## Experiment

**15.** **Predict first, in writing.** You are about to run these four commands from the lab
directory. For each one, write down what you expect *before* running anything:

```bash
ls deck-3//bay-1
ls deck-3///
ls //deck-3
ls roster.txt/
```

Now run them. Two succeed and two fail, and the two failures have **different causes**. Explain
what happens to repeated slashes in the middle of a path, why the third command is not the same
kind of path as the first two, and what a trailing slash asserts. Your deliverable is the
prediction, the observation, and the explanation of any difference.

**16.** **Predict first, in writing.** Write down what you expect from each of these, then run them:

```bash
echo ~
echo "~"
echo '~'
ls ~/..
cd / ; cd ../../.. ; pwd
```

Two of the first three differ from the others. Name the mechanism responsible, and say which
program — the shell or `echo` — is doing the work. Then explain why the last line does not produce
an error.

---

## Stretch

**17.** Using only what Chapter 1 taught you about variables, print your working directory twice —
once with the `pwd` builtin and once without running `pwd` at all. Then `cd` somewhere else and
show that the second method tracked the change.

**18.** Create a directory in the lab, `cd` into it, delete it from *another* terminal (or from the
same one — you can delete the directory you are standing in), and then run `pwd`, `pwd -P`, and
`ls`. Record what each does. Write two lines on what state your shell is now in and how you get
out of it.

---

## Dig

**19.** Print the directory part of all three `survey.txt` paths in **one** invocation of
`dirname`. Now try the same trick with `basename` — it refuses. Find the flag in `man basename`
that makes it accept several operands, and the second flag that strips a suffix from each, and
print all three filenames without their `.txt` extension in one command. Write one line on why the
two tools needed different treatment.

**20.** `realpath` has a mode that produces a path *relative to* some other directory rather than an
absolute one. Find it, and use it to express `deck-3/bay-3/survey.txt` as a path relative to
`deck-3/bay-2/panels/panel-07`. Check your answer by `cd`-ing there and using it.

**21.** There is a flag that makes `cd` resolve symlinks as it moves, so that `pwd` afterwards
reports the physical path immediately. Find it — it is documented in bash's builtins, not in a man
page of its own — and demonstrate it on `shortcut`. Then name the `set -o` option that makes that
behaviour the default for every `cd`.

---

## Core — the two kinds of path, drilled

**22.** Standing in `deck-3/bay-2/panels/panel-07`, write down the absolute path of every one of the
seven files and directories in this lab, without running `ls` anywhere but the lab root.

*Done looks like:* seven absolute paths.

**23.** Now write the relative path to each of those seven, from where you are standing in exercise
22. Check three of them by displaying or listing them.

*Done looks like:* seven relative paths and three checks.

**24.** For each of the seven, say whether you would use the absolute or the relative form in a
script that runs from an unknown directory, and why.

*Done looks like:* seven choices with a one-line rule at the end.

**25.** `cd` to five different directories in this lab using only relative paths, never touching the
lab root in between. Record the sequence.

*Done looks like:* five `cd` commands and five `pwd` outputs.

**26.** Do the same five in the same order using only absolute paths. Compare the total number of
characters typed.

*Done looks like:* both sequences and both counts, with one sentence.

**27.** `cd -` returns you to your previous directory. Use it to bounce between two bays five times,
and say what it does on the very first use in a fresh shell.

*Done looks like:* the bounces and the first-use answer.

**28.** `cd` prints something when you use `-` that it does not print otherwise. Say what and why.

*Done looks like:* the output and one sentence.

**29.** Standing anywhere, get to `deck-3/bay-3` using a path that contains at least one `.` and at
least two `..` components and is still correct.

*Done looks like:* the path and the `pwd` that proves it worked.

**30.** Show that `.` and `..` are real directory entries, not shell syntax, by finding them in a
listing. Then say what `..` in `/` points at and prove it.

*Done looks like:* the listing, the answer, and the proof.

---

## Core — symlinks and two kinds of truth

**31.** `shortcut` points somewhere. Show what it points at without following it, and show where it
lands when you do follow it.

*Done looks like:* both, with the commands used.

**32.** Standing in `shortcut`, list the entries. Then list the entries of the directory it points
at directly. Show they are the same directory and not two copies.

*Done looks like:* both listings and your argument.

**33.** From inside `shortcut`, work out — before running anything — where `cd ../..` will land you,
under the shell's logical rule. Then say where it would land under the physical rule. Run it and
report which happened.

*Done looks like:* two predictions, the result, and the rule that governed it.

**34.** Print `$PWD` and `pwd` and `pwd -P` from inside `shortcut`. Two agree and one does not. Say
which and why.

*Done looks like:* three outputs and the explanation.

**35.** Give the physical path of `shortcut/panels/panel-07/panel.txt` without changing directory.
Then give the same file's logical path as you would have typed it.

*Done looks like:* both paths.

**36.** Construct a path that goes *through* `shortcut` and back out via `..` to reach
`deck-3/bay-1/survey.txt`. Explain why it works.

*Done looks like:* the path and the explanation.

---

## Experiment — predict before you run

**37.** **Predict first.** From the lab root, predict the output of each, then run:

```bash
ls .
ls ./.
ls ././deck-3
ls deck-3/..
ls deck-3/../..
```

*Done looks like:* five predictions and five observations.

**38.** **Predict first.** Predict what `cd deck-3/bay-1/survey.txt` does — the message and the
working directory afterwards.

*Done looks like:* the prediction, the error quoted, and the `pwd` after.

**39.** **Predict first.** Predict the difference between `ls ~` and `ls "~"` and `ls ~/`. Then run
all three.

*Done looks like:* three predictions and three results.

**40.** **Predict first.** Predict what `basename /` and `dirname /` print. Then what `basename ""`
and `dirname ""` print. Run all four.

*Done looks like:* four predictions and four outputs.

**41.** **Predict first.** Predict what `realpath` says about a path that does not exist, and
whether it fails. Then test it on `deck-3/bay-9/nothing.txt`.

*Done looks like:* the prediction, the output, and the exit status.

---

## Stretch

**42.** A colleague's script does `cd $1` unquoted. Give a value of `$1` that breaks it and a value
that makes it do something unintended but silent, using only this lab. Then give the fix.

*Done looks like:* two values, both effects, and the fix.

**43.** Write down the shortest correct answer to "how do I get from A to B" as a procedure someone
could follow without thinking — a rule, not an example. Test it on three pairs from this lab.

*Done looks like:* the rule and three tests.

**44.** Using 01/04: `$PWD` and `$OLDPWD` are variables. Change one of them by hand and then run
`pwd` and `cd -`. Report what breaks and what does not, in a **child shell**.

*Done looks like:* the experiment and the two results.

**45.** `type -a pwd` lists more than one `pwd`. Explain in three sentences why `pwd` exists both as
a shell builtin and as a program on disk, and which one a bare `pwd` runs. Prove which one you got.

*Done looks like:* three sentences and the proof.

**46.** Write two sentences on why a script that uses `cd` should almost always check whether it
worked, with a concrete failure from this lab.

*Done looks like:* two sentences and the failure.

---

## Dig

**47.** Find out what `cd` does with a path that has a trailing slash on a symlink —
`cd shortcut/` versus `cd shortcut`. Report any difference in `pwd` and `pwd -P`.

*Done looks like:* both runs and the verdict.

**48.** Find the shell option that makes `..` resolve physically for every `cd`, turn it on in a
child shell, and repeat exercise 33.

*Done looks like:* the option, the command, and the changed result.

**49.** Find out how `realpath` behaves on a symlink loop. Do not create one in the lab — read the
man page and say what the failure would be, and which error `realpath` would report.

*Done looks like:* the documented behaviour and the error name.

**50.** `realpath` and `readlink -f` overlap. Find one thing each does that the other does not, from
their man pages, and demonstrate one of them.

*Done looks like:* two differences and one demonstration.

**51.** Find out whether `dirname` and `basename` ever touch the disk. Prove it with a path that
cannot possibly exist.

*Done looks like:* the proof and one sentence on why that matters in a script.

**52.** Find the longest path this lab can produce and count its components. Then find the system's
limit on the length of a path and on a single name, using `getconf`. Report both numbers and name
the manual page that describes how paths are resolved.

*Done looks like:* the path, the count, the limit, and the source.
