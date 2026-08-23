# 04/02 — Exercises: touch and mkdir

Work in `/labs/04-creating-copying-destroying/02-touch-mkdir`.

```
cd /labs/04-creating-copying-destroying/02-touch-mkdir
ls -F
```

Create things under `build/`, `perms/` and `times/` only. `spec/` is reference material — read it,
do not edit it.

If you mangle the lab: `kestrel reset 04/02` from the repo root. You will need it.

---

## Warmup

**1.** `echo bay-{01,02,03}`, `echo bay-{1..4}`, `echo bay-{01..06}`. Report all three outputs. State
the rule that decides whether the numbers come out padded.

**2.** `echo deck-0{3,4}/bay-{01..04}`. How many words did the shell produce? Multiply two numbers to
predict it before you count.

**3.** `echo bay-{01}` and `echo bay-{01,}`. One of these is not an expansion. Say which, and what
the difference between them is.

**4.** `mkdir build/one/two`. Report the exact error. Then `mkdir -p build/one/two` and report the
exit status. Then run the `-p` version **again** and report the exit status a second time.

---

## Core

**5.** `mkdir -pv build/a/b/c`. What did `-v` print, and how many directories did it actually create?
Now `rm -rf build/a` to clean up.

**6.** `ls -F existing/deck-03`. Two entries. Which one is a directory and which one is not? Say how
you can tell from `ls -F` alone.

**7.** `mkdir existing/deck-03/bay-01`. Report the exact error and exit status.

**8.** `mkdir -p existing/deck-03/bay-01`. Report the exit status. Explain the difference from
exercise 7 in one sentence about what `-p` does when the target already exists.

**9.** `mkdir -p existing/deck-03/bay-02/readings`. Report the exact error and exit status. This is a
different error from exercise 7 — say what makes it different.

**10.** `mkdir -p existing/deck-03/bay-02`. A third error, different again. Report it, and state the
rule: `-p` forgives one specific situation and only one. Name it.

**11.** Given exercises 7–10, write a one-sentence rule for when `mkdir -p` exits 0 on a path that
already exists.

**12.** Read `spec/deck-tree.txt` in full. Write down, by hand, how many directories the deck-03
subtree contains, counting `deck-03` itself. Do the same for deck-04. Do not build anything yet.

**13.** Read `spec/naming-notes.txt`. Name the two ways a naive brace expression would get the tree
wrong, and the third fact the note records.

**14.** Build the deck-03 bays and their three subdirectories each, under `build/`, in **one**
command. Then verify with `find build -type d | wc -l`.

**15.** Add the two panels and their `logs/` and `spares/` to `build/deck-03`, again in one command.

**16.** Build all of `build/deck-04` — six bays, three subdirectories each, two panels — in one
command. Note that this is one command for a different-shaped tree, not a copy of exercise 14.

**17.** `find build -type d | wc -l`. Compare with your hand count from exercise 12. If they
disagree, find out which of the two is wrong before reading on.

**18.** `find build -type d | sort`. Read the list. Is every bay number two digits? Is there a
`panel-08`? If either answer is wrong, fix it — and say what your brace expression did to cause it.

**19.** Someone suggests building both decks in a single expansion:
`mkdir -p build/deck-0{3,4}/bay-{01..06}/{readings,faults,handover}`. Say exactly what is wrong with
the result, in terms of `spec/naming-notes.txt`. Do not run it on `build/`; if you want to see it,
run it under a fresh `mktemp -d`.

**20.** `tree build` if `tree` is available, or `find build -type d | sort`. Confirm the tree matches
`spec/deck-tree.txt` entry for entry. Report the final directory count.

**21.** `umask`. Report the value. Then `mkdir perms/plain` and `ls -ld perms/plain`. Show the
arithmetic that turns the umask and the default directory mode into the mode you see.

**22.** `touch perms/plain-file` and `ls -l perms/plain-file`. The mode is not the same as the
directory's. Explain the difference in terms of the default mode for files versus directories.

**23.** `mkdir -m 700 perms/private` and `ls -ld perms/private`. Then `mkdir -m 777 perms/open` and
`ls -ld perms/open`. One of those two proves something about `-m` and the umask. Which, and what?

**24.** Achieve the same end state as exercise 23's `perms/private` using a plain `mkdir` and one
other command. Then say what happened in between that did not happen with `-m` — think about what
another process could have done in that window.

**25.** `mkdir -p -m 700 perms/x/y/z`, then `ls -ld perms/x perms/x/y perms/x/y/z`. Which components
got mode 700? State the rule for `-m` under `-p`.

**26.** `rmdir perms/x`. Report the error. Then remove the whole `perms/x` chain with `rmdir -p`
starting at the deepest component, and report what `ls perms` shows afterwards. Anything surprising
about how far `rmdir -p` climbed?

**27.** Make thirty empty files in one command: `build/deck-03/bay-01/readings/2187-05-{01..30}.txt`.
Verify the count. Then check the mode of one of them against your answer to exercise 22.

---

## Experiment

**Write your prediction down before you run each of these.**

**28.** Predict what `touch times/anchor.txt` does to that file's three timestamps, then check with
`stat`. Then predict what `touch -c times/nothing-here.txt` does, and what it exits with. Run it and
check whether the file appeared.

**29.** Predict the mtime of `times/one.txt` after `touch -r times/anchor.txt times/one.txt`, then
run it and check. Then predict what `touch -r` does about the *access* time, and check that too.

**30.** Predict what `touch -a -d '2187-01-01 00:00' times/two.txt` does to mtime, and what
`touch -m -d '2187-02-02 00:00' times/two.txt` afterwards does to atime. Run both and `stat` after
each. One of the four numbers moves when you did not ask it to — or does not move when you expected
it to. Which?

**31.** Predict the output of `echo {1..10..3}` and of `echo {a..e}`. Then predict
`echo file-{a..c}-{1..2}.txt` — how many words, and in what order do the two expansions vary?

**32.** Predict what `mkdir -p 'build/a directory with spaces'` creates, then what
`mkdir -p build/a directory with spaces` (same words, no quotes) creates. Run both, `ls build`, and
clean up with `rm -rf` — you will need quoting there too.

---

## Stretch

**33.** Build the entire tree from `spec/deck-tree.txt` — both decks, all bays, both panels — from a
**clean** `build/`, in one command line. `rm -rf build/*` first. State how many `mkdir` invocations
you used. Anything above one is a wrong answer to this exercise.

**34.** Now do the same thing with a `for` loop and no brace expansion, for comparison. Count the
lines and characters of each version. Then say which one you would rather read six months later, and
defend it — this is not a rhetorical question and the brace version is not automatically the winner.

**35.** Every `readings/` directory in `build/` should contain a `.keep` file so it survives being
copied by tools that skip empty directories. Create all of them in one command, using `find` to
locate the directories rather than typing a brace expression that repeats the tree structure.

**36.** `mkdir -p` in a script is idempotent. Prove it: write a two-line script in `build/` that
creates a tree with `mkdir -p`, run it three times, and show with `find | md5sum` that the state is
identical after each run. Then break it by removing `-p` and show what happens on the second run.

**37.** Make a directory whose name starts with a dash: `build/-tmp`. Plain `mkdir -tmp` will not do
it. Find two different ways, and explain what each one is doing to stop the shell or `mkdir` from
reading the name as an option. Then remove it, which has the same problem again.

**38.** `touch` can create a file with a timestamp far in the future or the past. Create
`build/old.txt` dated 1971-01-01, `build/new.txt` dated 2187-12-31 and `build/pre.txt` dated
1969-01-01 — before the epoch — then `ls -lt build` and `stat` each one. All three succeed; say what
that tells you about the sign of the number a timestamp is stored in.

Now push both ends: try `1901-01-01` and `2500-01-01`, and `stat` the result each time. Both commands
exit 0 and neither file gets the date you asked for. Report the two values you actually got, and say
what they are. (Chapter 3 lesson 04 met one of these two boundaries already.)

---

## Dig

**39.** `mkdir -p a/b/c` creates three directories. If `a/b` already exists but you have no write
permission on it, where exactly does the command fail, and what has it already created by then? Set
this up under `mktemp -d` with `chmod 500` and report the exact error and the resulting state.

**40.** Brace expansion happens before pathname expansion (globbing). Prove the order with a single
command whose output differs depending on which happens first. `echo` and a directory with two files
in it is enough. State the general rule you have just demonstrated.

**41.** `mkdir -m` sets the mode without a window in which the directory exists at the default mode.
`mkdir` followed by `chmod` has such a window. Describe a concrete situation in which that window
matters — who has to be doing what, and what they get. Then say whether the same argument applies to
`touch` followed by `chmod`, and why the answer is different for files.

**42.** `man 1 mkdir` documents `-Z` and `--context`, which do nothing useful in this container. Read
what they are for, then run `ls -Z build/deck-03` and explain in two sentences why the output looks
the way it does here.
