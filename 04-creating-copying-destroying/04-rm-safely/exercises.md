# 04/04 — Exercises: `rm`, Safely

Work in `/labs/04-creating-copying-destroying/04-rm-safely`.

```
cd /labs/04-creating-copying-destroying/04-rm-safely
ls -F
```

You are going to delete most of this lab on purpose. `kestrel reset 04/04` from the repo root brings
all of it back, and several exercises tell you to reset before continuing — that instruction is not
optional, because a later exercise reads state an earlier one destroyed.

One exercise runs `rm -rf /`. Read it before you decide it is a typo.

---

**Ahead of the syllabus.** This lesson uses `find -print` and `find -delete` (Chapter 6), `lsof`
(Chapter 9) before the chapters that teach them. Use them exactly as written here; you are not
expected to know them yet.

## Warmup

**1.** `rm junk/panel-01.log`, then `ls junk`. Any output from `rm`? Any confirmation? Report both.

**2.** `rm junk/nosuch.log` — exact error and exit status. Then `rm -f junk/nosuch.log` — exact
output and exit status. State the difference in one sentence.

**3.** `rm junk/old` — exact error. Then `rmdir junk/old` — exact error. Two commands, two different
refusals, both about the same directory. Why are the reasons different?

**4.** Delete `junk/old` and everything in it with one command. Then say which of the two exercise-3
refusals you overrode and which one you satisfied.

## Core

**5.** `rm -v junk/panel-0{2,3}.log`. What does `-v` print, and is it printed before or after the
file is gone?

**6.** Before deleting with a glob, look at it: `ls junk/panel-*.log`, then `rm junk/panel-*.log`.
Explain what the shell handed to `rm` in each case, and why running the `ls` first is a real check
rather than a superstition.

**7.** Reset the lab. `rm -i junk/panel-0*.log` and answer `y` to two and `n` to the rest. Then
`ls junk`. Now run `rm -i junk/panel-0*.log </dev/null; echo $?` and report both the output and the
status.

**8.** Reset. `rm -I junk/panel-0*.log` in your terminal. Report the exact prompt. How many prompts
did you get for six files, and how many would `-i` have given you?

**9.** From `man rm`, state the exact threshold at which `-I` starts asking, and give the one-sentence
argument for why `-I` gets used in real life and `-i` gets aliased away.

**10.** `ls awkward`. Five names, and three of them are going to be a problem. Say which three and
what is wrong with each — before you try to delete anything.

**11.** `cd awkward` and run `rm -f`. Report what happened and the exit status. Explain the result:
`rm` did not delete the file named `-f`, and it did not complain either.

**12.** Delete the file named `-f` using `--`. Show the command.

**13.** Delete the file named `--force` without using `--`. Show the command and explain why it works.

**14.** Which of your two fixes needs `rm` to cooperate, and which one is true regardless of what the
command does with its arguments? Which is the better habit, and why?

**15.** Delete `strain report.txt` — the one with a space. Then say what would have happened if you
had typed the name without quoting it, in terms of how many arguments `rm` would have received.

**16.** There is a file whose name contains a newline. `ls awkward` prints it as two lines. Prove
that it is one file, not two, with a command whose output cannot be misread.

**17.** Delete the newline file. Tab completion or a glob will both do it; typing the name will not.
Say why.

**18.** `awkward/keep-this.txt` must survive. Write a single `rm` that deletes everything else in
`awkward/` and leaves it — and check your glob with `ls` first.

**19.** In one sentence: given exercises 10 to 18, what makes a filename dangerous? It is not the
characters themselves.

**20.** `ls -l protected`. `keep.txt` is mode `0400` — you cannot write to it. Predict whether you
can delete it, then run `rm protected/keep.txt` in your terminal and report the exact prompt.

**21.** Answer `y`. Did it delete? Reset the lab, then run the same `rm` with `</dev/null` and report
what happened and the exit status. Where did the prompt go?

**22.** Reset. `rm -f protected/keep.txt`. Prompt or no prompt? What does `-f` mean about a
write-protected file?

**23.** State the rule, exactly, that exercises 20 to 22 have demonstrated: whose permission bits
decide whether a file can be deleted?

**24.** `ls -ld locked; ls -l locked/report.txt`. The file is `0644` and yours. The directory is
`0555`. Predict, then run `rm locked/report.txt`. Report the exact error.

**25.** Now `rm -f locked/report.txt`. Report the error and the exit status. Why did `-f` not help,
given that it "forces"?

**26.** Make the deletion succeed without changing the file at all. Show the command you ran on the
*directory* and then the successful `rm`.

**27.** Exercises 23 and 26 together: write the two-sentence rule about deletion and permissions that
you would tell somebody who has just been told "chmod 400 protects a file".

**28.** `stat -c '%n %i %h' linked/readings.txt linked/readings-alias.txt`. Same inode, link count 2.
Now `rm linked/readings.txt` and `stat` the survivor. Report the link count and `cat` the file. What
exactly did `rm` remove?

**29.** Given exercise 28: why is `unlink` a better name for the operation than `delete`?

**30.** Reset the lab first. `ls -l linked/latest.txt` — a symlink to a file. `rm linked/latest.txt`, then check that
`linked/readings.txt` still exists. Which of the two did
`rm` remove?

**31.** `ls -l linked/archive-link` — a symlink to a **directory**. Run `rm linked/archive-link/`
with the trailing slash. Report the exact error. Then run `rm -r linked/archive-link/` and report
that error too — it is a *different* error from the same command family.

**32.** Explain the pair of errors in exercise 31. Then say what would have happened to
`linked/archive/` if the trailing slash had been ignored.

**33.** Delete the symlink `archive-link` and leave `archive/` intact. Show the command, and state the
rule about trailing slashes on symlinks that you would put on a sticky note.

## Experiment

For each of these: **write your prediction down before you run it.** Then run it, and write down
which part of your prediction was wrong.

**34.** Predict, in full, what `rm -rf /` does on this system. Then run it. Report both lines of
output and the exit status. Then read `man rm` on `--preserve-root` and say what version of this
command *would* still be dangerous.

**35.** Predict what `rm -rf --preserve-root=all /labs` does — note the path is a real one and is a
separate filesystem here (`df --output=source,target /labs /`). Run it. Report the message and the
exit status, then say what protected you: the failsafe, or the filesystem boundary?

**36.** Predict what these three do, then run each in `scratch/`:
```
D=""; rm -rf "$D"/subdir
rm -rf scratch/tmpdir /
rm -rf scratch/tmpdir/ *
```
(Create `scratch/tmpdir` with something in it first, and make sure your current directory is
`scratch/` for the third one, which is the one you should think hardest about.) One of them is
stopped by a failsafe. The other two are the actual danger. Say which is which.

**37.** Predict the exit status of `rm -rf /a/path/that/does/not/exist`. Run it. Then say why that
exit status is exactly what makes `-f` correct in a cleanup script and dangerous at a prompt.

## Stretch

**38.** Build the trash pattern. Write a shell function `trash` that moves its arguments into
`trash/` instead of deleting them, timestamping the name so a second `trash` of the same filename
does not clobber the first. Demonstrate it on two files with the same basename from different
directories. Then say the two ways your function is *worse* than `rm`.

**39.** `mktemp` and `mktemp -d`. Run each, look at what they produced, and read `man mktemp` on
`--tmpdir` and on the `XXXXXX` template. Then answer: why is `mktemp` a safety tool in a lesson about
deletion — what does `FILE=/tmp/mywork; rm -rf "$FILE"` risk that `FILE=$(mktemp -d)` does not?

**40.** Write a cleanup that removes a temporary directory even if the script fails halfway.
(`help trap`, and the `EXIT` signal.) Demonstrate it: a script that makes a `mktemp -d`, writes into
it, exits nonzero on purpose, and leaves nothing behind.

**41.** Reset the lab. `find` can delete. Build the safe version first: `find junk -name '*.log' -print`, read it,
then re-run with `-delete`. Then explain why `find … -delete` is safer than `find … -exec rm {} \;`
in one specific respect, and check whether `-delete` will remove a non-empty directory.

**42.** `shred` is in this image. Use it on a file in `scratch/`, with `-u`. Then state, in two
sentences, why `shred` cannot promise what its man page says it promises on a modern filesystem.
(`man shred`, the CAUTION section.)

## Dig

**43.** Delete a file while something is reading it. In one terminal:
`tail -f busy/big.log > /dev/null &`. Then `rm busy/big.log` and `ls busy`. Is the file gone? Now
`ls -l /proc/<pid>/fd` and report the line for that file, including the word at the end of it.

**44.** Same setup, with the space measured. Make a large file in `scratch/` (`head -c 50000000
/dev/zero > scratch/big`), record `df --output=used /tmp` (or the lab's filesystem), open it with
`tail -f`, `rm` it, and record `df` again. Then kill the reader and record `df` a third time. Report
all three numbers and say when the space actually came back.

**45.** `lsof` is installed. Find the command that lists every open file whose link count has fallen
to zero — files that have been deleted but are still holding disk space — and run it while exercise
44's reader is alive. Report the line, including the `NLINK` column.

**46.** From exercises 43 to 45: a colleague says the disk is full, deletes the largest log file, and
reports that `df` has not changed. Write the diagnosis and the fix in three sentences. The fix is not
"delete more files", and it is not "reboot".

**47.** `rm` on a directory tree has to remove the contents before the directory. Given the
permission rule from exercise 23, work out what `rm -r` needs on every directory in the tree, and
construct a tree that `rm -r` **cannot** fully delete even though you own every file in it. Show
your construction and the exact error.

**48.** Two names for the same danger. Explain, in terms of what the *shell* does before `rm` ever
runs, why `rm -rf "$DIR"/` with `DIR` unset is not the same risk as `rm -rf /` — and why the failsafe
that catches the second one cannot catch the first.
