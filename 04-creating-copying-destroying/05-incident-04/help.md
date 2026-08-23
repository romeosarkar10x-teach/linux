# 04/05 — Help: Incident, deleted or moved

Five rungs. Climb one at a time. Rung 5 is a near-miss on purpose.

---

## Level 1 — Questions to ask yourself

- Have you read the manifest *header*, or only the table? The header contains an instruction.
- How many rows does the manifest have, and how many files does it describe? Those are two numbers.
- Two manifests disagree. Which of them was written by somebody who could still see the tree?
- You have two surviving files. What can a file prove that a record of a file cannot?
- When you build a file "of the right size", what exactly have you reproduced? What have you not?
- The archivist asked two questions. Which one have you actually answered?
- If the tree had been *moved*, what would still exist somewhere on this station — and how would you
  know, with only Chapter 4's tools?
- You are about to type fifteen `mkdir` commands. What was lesson 02 about?

## Level 2 — Where to look

- `records/tree-manifest.txt` — the header, then the table, then the footer. Three separate claims.
- `records/tree-manifest.txt.bak` — read its second line before you read its table.
- `records/copy-notes.txt` — short. It answers exercise 12 and half of exercise 28.
- `salvage/` — two files. `stat` them.
- `man 1 mkdir` — `-p`. And the shell's brace expansion, which is in `man bash` under EXPANSION, or
  in lesson 02's readme.
- `man 1 head` — `-c`. This is how you make a file of an exact size with tools you have.
- `man 1 cmp` — for exercise 24.
- `man 1 du` — `-b` versus the default, and why the two totals differ.
- Lesson 03's exercises on `mv` within versus across filesystems: that measurement is the evidence
  base for exercise 25.

## Level 3 — The concept, on different data

Two records of the same thing, disagreeing, somewhere harmless:

```
$ printf 'a.txt 10\nb.txt 20\n'          > /tmp/m1
$ printf 'a.txt 10\nb.txt 20\nb.txt 25\n' > /tmp/m2
```

`m2` has three rows and two files. If you rebuild from `m2` without noticing, you make `b.txt`
twice and keep whichever size you wrote last — silently, with no error, and the tree looks complete.
That is the entire failure mode this lesson is about, in four lines.

And the size-versus-contents point, on a file you can throw away:

```
$ printf 'hello world!\n' > /tmp/real.txt
$ head -c 13 /dev/zero    > /tmp/fake.txt
$ stat -c '%n %s' /tmp/real.txt /tmp/fake.txt
/tmp/real.txt 13
/tmp/fake.txt 13
$ cmp /tmp/real.txt /tmp/fake.txt
/tmp/real.txt /tmp/fake.txt differ: byte 1, line 1
```

Same size. Nothing else the same. Exercise 24 wants that stated precisely.

## Level 4 — Break it down

**"I do not know which manifest to trust."** Stop arguing from age and look for an *external* check.
Two files survived. Whichever manifest agrees with the files on the ground is the one that was
written by somebody looking at the tree. Evidence beats provenance.

**"The two rows with the same path — which one is real?"** You are not required to reason it out.
One of those two sizes is sitting in `salvage/`. Go and measure it.

**"Fifteen files, fifteen sizes, and brace expansion only handles names."** Correct, and that is the
observation exercise 16 wants. Brace expansion generates *words*; it cannot pair each word with a
different number. So use it for the part it does — the directories, and the name lists — and accept
a small number of explicit commands for the sizes. "As few as you are willing to defend" is the
actual standard; forty is not defensible, five is.

**"My readback has sixteen letters and should have fifteen."** Then you have counted a row that is
not a file. Which row? You identified it in exercise 9. Which of its two letters do you drop? The one
belonging to the row that describes a file which never existed — and you established which that is
by measuring, not by preference.

**"What distinguishes deleted from moved?"** Think about what each operation does to an inode, to a
link count, and to a directory entry — all of which you measured in lesson 03 and lesson 04. Then
ask which of those you can still observe here, a week later, with the original filesystem gone. The
honest answer to exercise 26 is short and it is allowed to be negative.

**"I want to `grep` the manifest."** You do not have `grep` in this chapter, and here it would
actively hurt: the thing that matters about this manifest is a *repeat* and a *column of first
letters*, and neither is a pattern you would think to search for.

## Level 5 — Near-miss

This looks like the tree, and it builds the wrong thing. Find both faults before you run it.

```
mkdir -p rebuild/{readings,faults,handover}/
head -c 1024 /dev/zero > rebuild/readings/2187-05-1{4,5,6,7}-0600.txt
```

Hints: the second line redirects **one** command's output, so the brace expansion produces four
words and `>` accepts exactly one destination — bash will tell you `ambiguous redirect`. And even
fixed, three of those four names are wrong: the manifest's readings are not all `-0600`, and one of
the dates is `2200`. Copy the names from the manifest; do not pattern-match them by eye.

A second near-miss, for the salvaged files:

```
mv salvage/readings/2187-05-17-1804.txt rebuild/readings/
```

It works. It also empties `salvage/`, and `salvage/` was your only evidence for which of the two
duplicate rows was real. Rule 4 in the readme exists because of this line.

---

## Never say

Do not hand over: which manifest is authoritative (exercise 7 — point at `salvage/` and stop); which
of the two duplicate rows is the real one (exercise 12); the letter to drop in exercise 30; the
readback result or any part of the flag; the brace expression for exercise 14; or the answer to
exercise 26. Exercise 26's value is entirely in the student discovering the evidence is gone.

Do not confirm or deny an Experiment-tier prediction before it has been run.

Do not name anybody as the author of `records/copy-notes.txt`, and do not speculate about who wiped
the source. Exercise 33 exists to stop that conversation, not to start it. If the student names
somebody, ask them what in the lab supports it. Nothing does.
