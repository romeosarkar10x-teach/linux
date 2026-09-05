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

---

## Core — the columns of a long listing

**26.** Run `ls -l logs`. Name all seven fields on one line, left to right, and say which of the
seven is *not* stored in the file's inode.

*Done looks like:* seven names and the odd one out.

**27.** The first line of `ls -l logs` is not a file. Quote it, say what the number counts, and find
out what unit it is in.

*Done looks like:* the line, the meaning, and the unit with your evidence.

**28.** Get the same listing with numeric user and group instead of names. Report the flag and the
two numbers, and say where `ls` was looking up the names before.

*Done looks like:* the flag, the output, and the lookup source.

**29.** The link-count column reads `1` for every file in `logs` but not for the directories in the
lab root. Report `logs`'s own count, and account for the number exactly.

*Done looks like:* the number and the arithmetic.

**30.** Print the listing with each file's inode number. Say what an inode number identifies, and
whether two files in different directories could share one.

*Done looks like:* the flag, the numbers, and the answer.

**31.** Show that the inode numbers in `logs` are consecutive, and say what that tells you about the
order the files were created in — and how confident you can be.

*Done looks like:* the numbers and a hedged conclusion.

---

## Core — three times, not one

**32.** `ls -l` shows one time. There are two others. Find the flags for all three on `logs` and
record what each is called.

*Done looks like:* three commands and three names.

**33.** Two of those three show dates in 2187 and one shows today. Report which, and explain the
split from what the seed script did.

*Done looks like:* the split and the explanation.

**34.** Sort `logs` by each of the three times in turn. Report where the three orders differ.

*Done looks like:* three orders and the differences.

**35.** Get the modification times of `logs` printed in full ISO form, to the second. Report the
flag and one line of output.

*Done looks like:* the flag and the line.

**36.** Say which of the three times you would trust to answer "when did somebody last read this
file", and give one reason that trust is weaker than it looks.

*Done looks like:* the answer and the caveat.

---

## Experiment — predict before you run

**37.** **Predict first.** Predict the output shape of `ls logs` versus `ls logs | cat`, then run
both. Explain what `ls` is detecting.

*Done looks like:* two predictions, two outputs, and the mechanism.

**38.** **Predict first.** Predict what `ls -w 40 logs` does to the columns, then run it. Then work
out what `ls` uses when there is no `-w` and no terminal.

*Done looks like:* the prediction, the run, and the fallback.

**39.** **Predict first.** Predict the difference between `ls -F` and `ls -p` on the lab root. Run
both. Name the character each gives `current`, if any.

*Done looks like:* the prediction and the two outputs.

**40.** **Predict first.** Predict what `ls -m logs` produces from the flag letter alone, then run
it.

*Done looks like:* the guess, the output, and whether the letter was a fair hint.

**41.** **Predict first.** Predict whether `ls --hide='*.log' logs` prints anything at all. Then run
it and account for the result.

*Done looks like:* the prediction and the explanation.

---

## Stretch

**42.** Write one command that lists, from the lab root, every `.log` file under `logs` with a
human-readable size, newest first, dotfiles included but not `.` or `..`. Expand every flag.

*Done looks like:* the command and one line per flag.

**43.** Using 01/02: `ls` is aliased in your interactive shell but not in a script. Prove both, and
say in one sentence why that difference is deliberate.

*Done looks like:* two proofs and the sentence.

**44.** Using 01/04: `ls` behaves differently when its output is a terminal. Name two other
behaviours in this lesson that depend on that same test, and say why a script should never rely on
any of them.

*Done looks like:* two behaviours and the rule.

**45.** `ls -l current` and `ls -lL current` do not just differ in one field — they answer two
different questions. Run both, report what each printed, and name the flag's job in one sentence.

*Done looks like:* both outputs and the sentence.

**46.** Someone asks for "the five biggest files under `deep` and `logs` together". Say honestly
what `ls` can and cannot do here, and what tool you would want. Do not use it.

*Done looks like:* the limitation named and the wish.

---

## Dig

**47.** Find the flag that suppresses sorting *and* implies `-a`, and use it on `logs`. Compare its
output to `-U`. Report the two differences.

*Done looks like:* both flags, both outputs, two differences.

**48.** From `ls -f logs`, report the position of `.` and `..` in the raw directory order. Say what
that suggests about how the directory was built.

*Done looks like:* the positions and the inference.

**49.** Find the flag that quotes every name in the output. Run it on `logs` and say what problem
the flag exists to solve, with an example filename that would need it.

*Done looks like:* the flag, the output, and the example.

**50.** Find how to make `ls` print the whole listing with `\0` between entries instead of newlines,
and say what consumes that form. Show the flag; you do not need to make sense of the raw output.

*Done looks like:* the flag and the consumer.

**51.** `ls -s` on `logs` reports 4 for a 180-byte file and 4 for a 1400-byte file. Report both, and
work out the smallest number of bytes that would push a file to 8. Test your answer with a file you
create in your home directory.

*Done looks like:* the numbers, the prediction, and the test.

**52.** `ls -s` totals do not equal the sum of the byte sizes divided by the block size. Report both
totals for `logs` and account for the gap in one sentence.

*Done looks like:* two numbers and the sentence.
