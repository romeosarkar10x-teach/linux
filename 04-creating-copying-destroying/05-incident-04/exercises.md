# 04/05 — Exercises: Incident, deleted or moved

Work in `/labs/04-creating-copying-destroying/05-incident-04`.

```
cd /labs/04-creating-copying-destroying/05-incident-04
ls -F
```

In-chapter tools only. No `grep`, no `find -name`, no `sed`, no `awk`. If you mangle the lab:
`kestrel reset 04/05` from the repo root.

---

## Warmup

**1.** `ls -lR`. Write down what exists: three directories, and what is in each. How many files
survived in `salvage/`?

**2.** `cat records/tree-manifest.txt`. Read the header, not just the table. What are the four
columns, and what does the header say the notes column is for?

**3.** `nl records/tree-manifest.txt` — how many lines is the file, and how many of them are actual
manifest rows? The footer states a row count; check it yourself rather than believing it.

**4.** `ls -l records/`. There are two manifests. Which is older, and by how long? Which one says on
its own face that it is not to be used?

## Core

**5.** `cat records/tree-manifest.txt.bak`. List every way it disagrees with the manifest: rows it
does not have, rows in a different order, and any value that differs for the same path.

**6.** The `.bak` is *older*. State, in one sentence, why "older" makes it less authoritative here —
and then state the case somebody could make for the opposite. Both arguments are real; say which one
the files themselves settle and how.

**7.** Which manifest are you going to build from? Write the decision down with the reason before you
run another command. You will be asked for this again in exercise 22.

**8.** How many *files* does the authoritative manifest describe? It is not the number of rows.
Explain the difference in one sentence.

**9.** Find the two rows that are the same path. Report both lines exactly, with their sizes and
their recorded times. How far apart were they recorded?

**10.** Both rows cannot describe the same file as it existed. Say what the two possible stories are:
(a) the file changed between the two recordings, (b) something else. Read the notes column of both
rows before you answer.

**11.** `ls -l salvage/readings/2187-05-17-1804.txt` and `stat -c '%s %y' ` on it. Which of the two
manifest rows does the surviving file match?

**12.** Given exercise 11: which row describes a file that existed, and which describes something
that did not survive to be copied? Now re-read `records/copy-notes.txt` and say whether it agrees.

**13.** State the resolution rule you have just derived, in a form you could apply to a manifest you
have never seen: when two rows share a path, which one wins, and what evidence would overturn that?

**14.** Build the directories. Three of them, under `rebuild/`, in **one** command using `mkdir -p`
and brace expansion. Show the command. Then `ls -F rebuild`.

**15.** Build the files in `rebuild/faults/` — three of them — in one command, at the right sizes.
(Chapter 3: there is more than one way to make a file of exactly N bytes; `head -c` is the one you
have met.) Then `ls -l rebuild/faults` and check the three sizes against the manifest.

**16.** Build `rebuild/handover/` — five files. The names differ only in the date, so brace
expansion covers the names; the sizes differ, so they do not. Say what part of this a single brace
expression *cannot* do, and then do it in as few commands as you are willing to defend.

**17.** Build `rebuild/readings/`. Seven files, and one of them has two candidate sizes — use the one
you settled in exercise 12.

**18.** The two salvaged files belong in your tree. Put them there **without** removing them from
`salvage/`. Show the command and say why you chose it over the alternative.

**19.** Check your work: `ls -lR rebuild` against the manifest, row by row. Report any size that does
not match. Then `du -sb rebuild` — is the total meaningful? Say why or why not.

**20.** `find rebuild -type f | wc -l` — the count you expect, and the count you got.

## Experiment

Write your prediction down before you run each of these.

**21.** Predict what `du -sb rebuild` will report versus the sum of the manifest's size column. Then
compute both. If they differ, the difference is not an error — explain it.

**22.** Predict what you would get if you had built from the `.bak` instead. Then actually do it:
build a second tree in `mktemp -d` from the `.bak` manifest, and compare the two with `ls -R`. How
many files differ, and would you have noticed the difference by looking only at the second tree?

**23.** Predict what the readback (manifest header, exercise 2) gives you for the `.bak` manifest.
Then do it. Report what you got and say what it tells you about whether the `.bak` was ever a
complete record.

**24.** Predict whether a file you created with `head -c 1180 /dev/zero` and the salvaged
`2187-05-17-1804.txt` are the same file in any sense. Then check: same size? same contents
(`cmp`)? same inode? Say precisely what your reconstruction has reproduced and what it has not.

## Stretch

**25.** The archivist asked two questions and you have only answered one. State what evidence on a
filesystem distinguishes "this tree was deleted" from "this tree was moved" — for a `mv` within one
filesystem, and for a `mv` across filesystems. Use what you measured in lesson 03.

**26.** Now state which of that evidence is available to you **here**, in this lab, right now. Be
strict. If the answer is "none of it", say so and say what would have had to be recorded, and when,
for the question to be answerable.

**27.** Write the two-sentence answer you would send back to the archivist. It must not claim more
than exercise 26 supports.

**28.** A manifest taken off the copy instead of off the original proves less. Read
`records/copy-notes.txt` again and explain, in one sentence, exactly what a manifest-of-a-copy fails
to establish that a manifest-of-the-original establishes.

## Dig

**29.** Do the readback on the authoritative manifest, exactly as the header describes: notes column,
first letter only, in row order, one word per directory. Report the letter sequence you get, before
you tidy it.

**30.** Your raw sequence has one letter too many and the readback rule says three words. Fix it
using what you established in exercises 9 to 13. State which letter you dropped and why that letter
and not the other one — the answer is not "because the words look right".

**31.** **Flag.** Three words, joined with underscores, inside `KESTREL{...}`. Submit from the VM:
```
./container/bin/kestrel flags submit 'KESTREL{...}'
```

**32.** The flag is three words. Two of them are the archivist's question. Write the debrief: what
the manifest was for, what the four-minute duplicate was, and why the tree turning out to have been
deleted rather than moved changes what happens next — for the archivist, and for whoever has to
explain the week between the copy and the wipe.

**33.** One question the lab does not answer and you should not pretend it does: who wiped the
source. Say what you would need to look at to find out, name the two chapters' worth of tools you do
not have yet, and leave it there.
