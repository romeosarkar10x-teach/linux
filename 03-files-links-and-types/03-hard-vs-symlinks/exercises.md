# 03/03 — Exercises

**Lab:** `/labs/03-files-links-and-types/03-hard-vs-symlinks`
Seed it with `kestrel seed 03/03`. Reset with `kestrel reset 03/03`.

Work from the lab root unless an exercise says otherwise. Several exercises create links; a few
delete them. Reset whenever you want a clean tree back.

Keep a log. For every link you meet, write down two separate things: **where it points** and
**whether that thing exists**. They are different questions.

---

## Warmup

**1.** `ls -li panels`. Four entries. Group them by inode number and say how many distinct inodes
are in that directory.

**2.** Two of those entries share an inode and show link count 2. Name them, and say which one is
"the original". Defend the answer in one sentence.

**3.** `current` has size 12 and `panel-07.txt` has size 40. Both are in the same directory and
one points at the other. Explain the 12.

**4.** Run `readlink panels/current` and `readlink panels/current-abs`. Report both outputs and
state the one structural difference between them.

## Core

**5.** For each of the four entries in `panels/`, run `stat -c '%i %h %s %F' <name>`. Put the four
lines in a table and mark which rows describe the same underlying file.

**6.** `cat panels/current` and `cat panels/panel-07-alias`. Same bytes. Say, in one sentence each,
*by what mechanism* each of the two got you those bytes — the two mechanisms are not the same.

**7.** `ls -l chain`. Report the three arrows and the three sizes. Then say what the `total` line
reads and why that number is what it is.

**8.** Walk the chain by hand: `readlink chain/a`, then `readlink` on what that printed, and so on
until `readlink` fails. Record every hop and the final failure.

**9.** Now get the same answer in one command. Report it, and say precisely what `readlink -f` did
that plain `readlink` would not.

**10.** `stat -c '%i %s %F' panels/current` and then the same with `-L`. Report both lines and
account for every field that changed.

**11.** `ls -l panels/current` versus `ls -lL panels/current`. Which fields differ, and which one of
the two is describing a file that has a link count of 2?

**12.** `cat perms/back-door` fails. Report the exact error. Then explain it using the output of
`ls -l perms` — your explanation must say which line of that listing is the relevant one and which
line is a distraction.

**13.** `perms/open-door` is `lrwxrwxrwx` and its target is mode 600. `cat perms/open-door`
succeeds. Reconcile that with exercise 12: two `lrwxrwxrwx` links, one read works and one does not.
State the rule in one sentence.

**14.** `ls -l dangling`. Both entries list fine. Now `cat dangling/ghost`. Quote the error exactly
and answer: which of the two things named in that command does not exist?

**15.** Run `file` on `dangling/ghost`. Report what it says. Compare it with what `ls -l` told you —
`file` states something `ls` only implies.

**16.** Get the target path of `dangling/ghost` out of the link with a command whose output is
*just that path*, nothing else. Two different commands can do this; give both.

**17.** `readlink -f dangling/vanished` and `readlink -e dangling/vanished`. Report each output and
each exit status. Then do the same pair on `dangling/ghost`. You now have four results; explain the
pattern in terms of which path components exist.

**18.** `cat loop/ring-a`. Quote the error. Then run `ls -l loop` and explain why listing the same
two files does not fail.

**19.** Create a hard link and a symlink to the same file in `/labs/03-files-links-and-types/03-hard-vs-symlinks`:

```
ln    target/report.txt mine-hard
ln -s target/report.txt mine-soft
```

Report `ls -li` for all three names, and the link count on the inode before and after.

**20.** Delete `target/report.txt`. Then try to read `mine-hard` and `mine-soft`. Report both
results and say what happened to the inode's link count.

**21.** Reset the lab (`kestrel reset 03/03`). Confirm the tree is back before continuing.

**22.** `sizes/short` and `sizes/long` point at the same file by different routes. Report both sizes
from `ls -l`, then report `stat -L -c %s` for each. Explain why one pair of numbers differs and the
other pair does not.

## Experiment

**23.** **Write your prediction down before running anything.** You are going to rename a directory
out from under two links.

```
ls -l moved/inner
mv moved/inner moved/renamed
```

Predict, for `moved/renamed/near` and `moved/renamed/far` separately: does `cat` still work after
the rename? Say why for each. Then run both and record what happened. Where you were wrong, state
what you had assumed a symlink stores.

**24.** **Predict first.** `cp` on a symlink. Predict the output of `ls -l` after each of:

```
cp    panels/current copy-default
cp -P panels/current copy-P
cp    dangling/ghost copy-ghost
```

Say for each whether you expect a symlink, a regular file, or an error. Run them. Explain the third
result in terms of what `cp` has to do before it can copy anything.

**25.** **Predict first.** You have a link `d` that is a directory, and you run `ln -s ../f d`.
Predict what gets created and where. Build the case yourself somewhere under `/tmp` and check.
Then say what `ln -sfn` would have done differently and why that flag exists.

## Stretch

**26.** Without deleting anything, find every symlink in the lab tree that `readlink -e` refuses to
resolve, and list them. `readlink -e` and its exit status are the mechanism; you may not use `find`
(Chapter 6). A loop over `*/*` is fine. Report the list — there are **five** — and the command you
used. Then sort them into two groups: three fail for one reason, two fail for a different reason.
Name both reasons. Only one of the two groups is dangling.

**27.** `chain/a` resolves to `target/report.txt`. Break the chain in the middle — delete only
`chain/b` — and then report, for `chain/a`: what `readlink` says, what `readlink -f` says with its
exit status, and what `cat` says. Three different answers to three different questions.

**28.** Make `chain/a` point directly at the target instead, without deleting `chain/a` first. One
command. Then prove the chain is one hop long now.

**29.** A symlink and a hard link to the same file both exist in `panels/`. Delete `panel-07.txt`
— the *name*, not the alias. Report which of `panel-07-alias` and `current` still reads, then repair
`current` so it reads again without recreating `panel-07.txt`. Explain what you changed.

**30.** `cd panels/..` and `cd -P panels/..` behave differently when the path runs through a
symlink. Build a symlinked directory under `/tmp`, `cd` into it, and show `pwd` and `pwd -P`
disagreeing. State which of the two is the truth as the kernel sees it.

## Dig

**31.** `man ln` documents a flag that makes `ln` create a **relative** symlink from two absolute
paths you hand it. Find it, use it, and show the resulting arrow.

**32.** `man readlink` has a third resolution mode besides `-f` and `-e`. Name it, say what it
requires, and demonstrate it on a path where all three behave differently.

**33.** `ls` has a flag that appends a type marker to every name it prints. Find it in `man ls`, run
it on `panels` and `sizes`, and say which marker a symlink gets. `man ls` also has a *narrower*
marker flag that only marks one type. Run that one on the same directories and report how it treats
a symlink — including a symlink that points at a directory. Say which of the two you would reach for
to answer "which of these are links?".

## Flag

**34.** No flag in this lesson. Write four sentences instead — one each:

- what a hard link is, in terms of inodes,
- what a symlink is, in terms of file contents,
- why a dangling link can exist at all,
- what `readlink -f` gives you that `readlink -e` refuses to.

Keep them. Lesson `06-incident-03` is a maze of links and this is the map.
