# 03/02 — Exercises

**Lab:** `/labs/03-files-links-and-types/02-inodes`
Seed it with `kestrel seed 03/02`. Reset with `kestrel reset 03/02`.

Tools: `ls`, `stat`, `ln`, `rm`, `mv`, `cp`, `cmp`, `cat`, `wc`, `df`, `chmod`, plus everything from
Chapters 1–2. `find` appears once, in the Dig tier, and is properly taught in Chapter 6.

**This lesson deletes things on purpose.** That is the point of it. `kestrel reset 03/02` puts the
lab back whenever you want a clean start, so delete without flinching — but record the numbers
*before* you delete, because you cannot get them back afterwards.

---

## Warmup

**1.** List `roster` with inode numbers and hidden entries in one command. Write down the inode
number of every entry, including `.` and `..`.

**2.** Two visible entries in `roster` share an inode number. Name them. Then name the entry that has
its own number.

**3.** In the long listing of `roster/roster.txt`, which column is the link count, and what is its
value? State the column by position, counting from the left.

## Core

**4.** Use one `stat` format string to print inode number, link count and size for all four files
under `roster` (remember the one in `.backup`). Present it as four lines.

**5.** `roster/copy.txt` and `roster/roster.txt` have the same size. Prove their contents are
identical too, with a command that compares bytes rather than sizes. Then state in one sentence why
that result tells you nothing about whether they are the same file.

**6.** `roster/roster.txt` has link count 3, but only two names in `roster` itself share that inode.
Find the third. Say where it is and how you knew to look there.

**7.** Append a line to `roster/crew-list.txt`. Then `cat roster/roster.txt` and
`cat roster/copy.txt`. Explain both results in terms of inodes — one changed and one did not.

**8.** Reset the lab. Now create a fourth name for the roster inode, `roster/manifest.txt`, using
`ln`. Show the link count before and after. Then delete `roster/roster.txt` and show that
`roster/manifest.txt` still reads correctly. State the link count now.

**9.** After exercise 8, `roster.txt` is gone. Which of the remaining names is "the original"? Answer
with a command that supports your answer, or state that the question has no answer and say why.

**10.** Print inode number and link count for `decks` and for each of `decks/deck-3`,
`decks/deck-4`, `decks/deck-5`. Four lines.

**11.** `decks` has link count 5 and contains three subdirectories. Account for all five links. Name
each one specifically — not "there are two extra".

**12.** Predict `decks/deck-3`'s link count from the rule you just used, then check it. Then make a
new empty directory in the lab and check that one too.

**13.** Show that `.` and `..` are ordinary directory entries and not shell notation, by printing
inode numbers that prove it. Use at least three different paths that all resolve to one inode.

**14.** In `scratch`, record the inode number and link count of both names. Then
`rm scratch/expendable.txt` and record them again for the survivor. State exactly what the `rm`
changed and what it did not.

**15.** After exercise 14, `cat scratch/keeper.txt`. It is intact. Explain in one sentence why the
command that "deleted a file" deleted no data — name the system call `rm` actually makes.

**16.** Reset the lab, then copy `roster` to `roster-copy` with `cp -r` and compare inode numbers and
link counts between the two directories. State what `cp` did to the hard links, and find the option
in `man cp` that would have preserved them.

**17.** `locked/notes.txt` is mode 444. Try to append a line to it and record the exact error. Then
delete it. Record what `rm` asked you and what happened. Explain why the second thing succeeded when
the first failed — the answer names two objects, one of which is a directory.

**18.** Reset the lab. State, before running anything, which permission on which object would have to
change to make `locked/notes.txt` undeletable. Then verify with `ls -ld`.

**19.** `sealed` is mode 555 and `sealed/bolted.txt` is mode 666. Try three things and record each
result: append to `bolted.txt`, delete `bolted.txt`, create a new file inside `sealed`. Summarise the
rule in one sentence.

## Experiment

**20.** **Write your prediction down before running anything.** You are going to try
`ln decks decks-link` — a hard link to a directory. Predict whether it succeeds, and if it fails,
what the error says. Then run it. Then explain in two or three sentences why the kernel refuses this
even for root: what would go wrong in the tree, and which everyday commands would stop terminating.

**21.** **Predict first.** `df /labs /home/cadet` reports both as the same physical device. Predict
what `ln /labs/03-files-links-and-types/02-inodes/roster/copy.txt /home/cadet/x` does. Run it, record
the exact error, then run `stat -c '%d %n' /labs /home/cadet` and reconcile the two outputs: `df` and
the kernel disagree about what "the same device" means, and only one of them decides.

## Stretch

**22.** Show that renaming does not touch the file. Capture a file's inode number, `mv` it to a new
name in the same directory, capture it again. Then answer: why is `mv` of a 40 GB file inside one
filesystem instantaneous, and what must `mv` do differently when the destination is another
filesystem?

**23.** Inode numbers get reused. In a scratch directory of your own making, create a file, record
its inode number, delete it, immediately create a different file. Report whether the number came
back. Then state in one sentence what that means for using an inode number as an identifier in a
script — be precise about *when* the number is trustworthy.

**24.** `stat` can print the device number as well as the inode. Find both format specifiers and
build one command that prints a globally unambiguous identity for a file. Explain why the inode
number alone is not enough on a system with several mounts.

**25.** A text editor can silently break a hard link. Reproduce the effect without an editor:
starting from two names on one inode, use `cp` and `mv` to leave the two names pointing at different
inodes with different contents, without ever running `rm`. Show the before-and-after link counts.

## Dig

**26.** `find` has two options for locating every name of one inode: one takes a file, the other
takes a number. Find both in `man find`, run each against `roster/roster.txt`, report all three
paths. Then say which of the two you would use in a script, and why.

**27.** `man 2 unlink` describes what `rm` actually calls. Read the opening paragraphs and report the
one condition, other than the link count reaching zero, under which the data is *not* freed even
though every name is gone. You will meet this again in Chapter 9.

**28.** `df -i` reports inodes rather than blocks. Run it on `/labs`. Report how many inodes exist
and how many are used, and explain what failure mode this number predicts that `df -h` cannot.
