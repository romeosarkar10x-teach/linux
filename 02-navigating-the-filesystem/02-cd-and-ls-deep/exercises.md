# 02/02 — Exercises

Lab: `/labs/02-navigating-the-filesystem/02-cd-and-ls-deep`

Seed or reset from the VM with `kestrel seed 02/02` / `kestrel reset 02/02`.

Start each exercise from the lab directory unless told otherwise.

---

## Warmup

**1.** List `logs`. Then list it again showing every entry including the ones beginning with a dot.
Write down how many entries each command printed and account for the difference. Then run the same
pair on the lab directory itself and explain why the two counts there differ by exactly two.

**2.** Show the two `ls` flags that both reveal dotfiles, and state in one line what one of them
shows that the other does not.

**3.** Produce a long listing of `logs` in which the sizes read as `879K` rather than `900000`.

---

## Core

**4.** Of the entries a plain `ls logs` will not show you, one is a directory. Name it, say how you
could tell it was a directory from the listing, and say what makes it invisible by default.

**5.** List the contents of the hidden directory inside `logs` without changing directory into it.

**6.** Produce a listing of `logs` sorted so that the file modified **most recently** is at the top.
Then produce one where it is at the bottom. Record both commands.

**7.** Produce a listing of `logs` sorted with the **largest file first**.

**8.** Compare your answers to exercises 6 and 7 against a plain `ls logs`. Write down, in one line
each, the three different orders and confirm that no two of them agree.

**9.** Run `ls current` and then `ls -l current`. One of them lists five files and the other prints
a single line about `current` itself. Record both, read the first character and the last field of
the single line, and say what kind of thing `current` is. Then state, in one line, the rule you have
just discovered about how `-l` treats this kind of argument.

**10.** Get a long listing that describes the directory `logs` itself — one line, not five. Write
down the flag that made the difference and what it means.

**11.** Two entries in the lab differ only in the case of their first letter. Run `ls` and record
which one comes first. Then find out what decides that — it is not a property of `ls` — and name the
setting responsible. Now check whether you can actually change it on this station: list the
settings of that kind the image has installed. Report what you find and what it means for your
ability to demonstrate the alternative here.

**12.** Produce a listing of `logs` where every entry is on its own line, and confirm you can get
the same output without using that flag at all — by changing where the output goes instead. Explain
in one line why the second method works.

**13.** List `runs`. The order is wrong for a human. Find the sort flag that fixes it and record
both orders side by side. Say in one line what the flag is comparing that the default is not.

**14.** Produce a recursive listing of `deep`. Then answer from that output alone: how many
directories does `deep` contain, at any depth, and how do you know `empty-bay` is empty rather than
skipped?

**15.** Run `ls Archive logs` in one command. The output has a shape that `ls logs` does not.
Describe the shape in one line, and say what would happen to a script that assumed the first line of
`ls`'s output is always a filename.

---

## Experiment

**16.** **Predict first, in writing.** For each of these, write what you expect before running any
of them:

```bash
ls current
ls -l current
ls -ld current
ls current/
ls -ld current/
```

Now run them. At least two pairs disagree. Explain what the trailing slash did, and what `-d` did,
and why those are two different mechanisms that happen to overlap here.

**17.** **Predict first, in writing.** `cd` into `logs`, then `cd` into `deep`, then run `cd -`
twice, printing `pwd` after every single command. Write your predicted `pwd` output for all five
steps first. Then explain, in two lines, why `cd -` cannot take you back three directories, and what
the shell is actually storing.

**18.** **Predict first, in writing.** Run `ls -l logs` and look at the time column. Some lines show
a clock time and some show a year. Predict which of the five will show which, *before* looking, then
check. Explain the rule. (`date` will tell you what "now" is, and it is not 2187.)

---

## Stretch

**19.** Using only Chapter 1's tools, demonstrate that `ls` in your interactive shell is not the
same command as the `ls` in `/opt/kestrel/bin`. Then run the unaliased one two different ways.

**20.** Get a long, human-readable listing of `logs`, oldest first, including dotfiles but excluding
`.` and `..`, in a single command. Write the flag bundle you ended up with and expand it into the
separate flags it stands for.

**21.** From inside `deep/deck-3/bay-2`, list the contents of the previous directory you were in —
without typing its path and without moving. (There is a tilde form for this.)

**22.** `logs` and `current` list the same five files. Prove, with a command whose output differs
between the two, that they are not the same *entry* in the lab directory.

---

## Dig

**23.** `ls --color=auto` produces no colour at all in this container. Work out why — the answer is
a variable, and you can inspect it. Then find the program whose job is to populate that variable,
turn colour on for your current shell, and show that `ls` now emits colour. Record the one line you
ran. Finally, say what would make this permanent, without doing it yet — Chapter 11 owns that.

**24.** Find the `ls` flag that prints each entry's size in **allocated blocks** rather than bytes,
and use it alongside the long format on `logs`. Two of the five files have byte sizes that differ by
almost eightfold and yet report the same allocation. Report which two, and offer an explanation of
what is being rounded and to what — you are not expected to be certain, and Chapter 3 confirms it.

**25.** There is an `ls` flag that turns off sorting entirely and prints entries in the order the
directory itself stores them. Find it, use it on `logs`, and say why a listing in that order is
almost never what a person wants but is sometimes exactly what a forensic examiner wants.
