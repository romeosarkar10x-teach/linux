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
