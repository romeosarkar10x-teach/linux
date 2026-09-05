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

**21.** **Predict first.** `df /labs /home/cadet` reports identical size, used and available
figures for both. Predict
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

## Core — counting links exactly

**29.** `ls -lai roster` prints six lines including `.` and `..`. Give the inode number of each of
the six, and say which two of the six numbers appear twice in the listing and why they do.

**30.** `roster/.` and `roster/..` have inode numbers you have already seen elsewhere. For each,
name another path in the lab that resolves to the same inode, and prove it with `ls -id`.

**31.** `decks` has link count 5. Delete `decks/deck-5` (it has one file in it — remove that first)
and report the new count. Then make two new subdirectories and report it again. State the arithmetic
rule as a formula.

**32.** `stat -c '%h'` on a brand-new empty directory gives 2. Explain both links precisely, then say
what the link count of a directory tells you about its contents that `ls` would take longer to
answer.

**33.** Reset the lab. In a scratch directory of your own, create one file and three hard links to
it. After each `ln`, record the link count. Then remove them one at a time, recording the count after
each `rm`. Present the whole sequence as a table of eight rows.

**34.** From exercise 33: at which step did the data actually become unreachable, and what was the
link count immediately before that step? Say which single number the kernel is watching.

**35.** `stat -c '%b %B %s'` on `roster/roster.txt` reports blocks, block size and byte size. Run it
on all three names of that inode. Explain why the three answers are identical in one sentence, and
what that means for the disk cost of adding a fourth name.

## Core — deletion, and what it removes

**36.** `rm` removes a name. Show, without deleting anything, which directory's *contents* would
change if you ran `rm roster/.backup/names.txt` — and which file's contents would not.

**37.** Create a file with two names in one directory. Delete one name with `rm`, and delete the
other by overwriting it with `mv` from a third file. Show that the link count went 2, 1, and then the
inode disappeared — and say which of the two operations is the one that actually calls `unlink`.

**38.** Make a 100 KB file, hard-link it, and run `du -sh` on the directory. Then run
`du -ah .`. Report which of the two names `du` charged for, and what `du --count-links` changes.
Explain in one sentence why the default is the right one for "how much disk am I using".

**39.** Open a file for reading, delete it while the descriptor is still open, then look at
`ls -l /proc/self/fd/`. Quote what the link shows. Say what the link count is now and why the data is
still there.

**40.** From exercise 39: state the exact condition under which the kernel frees the blocks. It is
two conditions, not one, and `man 2 unlink` gives both.

**41.** `locked/notes.txt` is mode 444 and you can delete it. `sealed/bolted.txt` is mode 666 and you
cannot. Write the rule as a single sentence that mentions both the file and the directory, then say
which of the two objects the mode bits of a *file* never govern.

## Experiment — predict before you run

**42.** **Predict first.** You run `cp -r roster roster-copy`, then
`stat -c '%i %h %n' roster-copy/*`. Predict the link counts. Then run it, and explain what `cp -r`
did to the relationship between `roster.txt` and `crew-list.txt`.

**43.** **Predict first.** Now try `cp -a roster roster-a` and check the same numbers. Predict
whether the two names inside the *copy* share an inode, and whether either of them shares an inode
with the original. Then run it and account for both answers.

**44.** **Predict first.** `cp -l` makes hard links instead of copying. Predict what
`cp -rl roster /home/cadet/roster-l` does, then run it and quote the error. Reconcile it with
exercise 21.

**45.** **Predict first.** Predict whether `ln -s decks decks-slink` succeeds, given that exercise 20
showed `ln decks decks-link` does not. Run it. Then say, in two sentences, what a symlink can
represent that a hard link cannot, and why the loop argument from exercise 20 does not forbid it.

**46.** **Predict first.** Create a file, note its inode number, delete it, and create ten new files
in a row. Predict whether the old number reappears among them. Run it, report the result, and say why
you must not treat either outcome as a rule.

## Stretch

**47.** `stat -c '%d:%i'` gives the pair that identifies a file uniquely on one running system. Run
it on `/labs/…/roster/roster.txt` and on `/home/cadet`. Report both pairs, and say what has to be
true of two paths for them to be the same file — both halves, not one.

**48.** Two names for one inode can have different *paths* but never different permissions, owners or
timestamps. Prove one of those: `chmod` one name and show the other changed too. Then say where the
mode bits are stored, and why that makes the result inevitable rather than surprising.

**49.** Reproduce the "editor broke my hard link" effect deliberately and then repair it: starting
from `roster.txt` and `crew-list.txt` sharing an inode, split them, then re-join them so the link
count is 2 again and both names show the *newer* content. Say which of the two contents you had to
choose, and why re-joining is a decision rather than an undo.

## Dig

**50.** `find -samefile` and `find -inum` both located the three names in exercise 26. Construct the
case where they give different answers: name a situation in which `-inum` returns a path that
`-samefile` does not, and say what the deciding factor is.

**51.** `df -i /labs` reports the inode table. Report total, used and free, then compute how many
bytes per inode the filesystem was formatted with, using `df /labs` for the block figures. Say what
that ratio implies about the kind of files the filesystem was expected to hold.

**52.** A backup tool copies a tree containing a thousand names on ten inodes. Describe what the
restored tree looks like under `cp -r`, under `cp -a`, and under a tool that records inode numbers
and re-creates the links. Then say which of the three you would want for `/etc` and which for a
directory of build artefacts, with a reason each.
