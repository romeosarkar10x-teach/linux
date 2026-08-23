# 04/03 — Exercises: `cp` & `mv`

Work in `/labs/04-creating-copying-destroying/03-cp-mv`.

```
cd /labs/04-creating-copying-destroying/03-cp-mv
ls -F
```

Several exercises overwrite or destroy files on purpose. Keep it inside `scratch/` or a `mktemp -d`
unless an exercise says otherwise. `kestrel reset 04/03` from the repo root puts everything back,
and a number of exercises depend on the seeded timestamps — if your answers stop matching, reset
before you debug.

---

## Warmup

**1.** `ls -lF source`. Five entries. Say what type each one is, and which two of them are the same
file.

**2.** `cp source scratch/copy`. Report the exact message and the exit status. What is `cp` refusing
to assume?

**3.** `cp source/handover.txt scratch/h.txt`, then `stat -c '%n %i %s' source/handover.txt
scratch/h.txt`. Same size, different what?

**4.** `mv rename/pnl_01.log rename/panel-01.log`, then `ls rename`. Nothing moved anywhere. Why is
this the same command as the one that moves files between directories?

## Core

**5.** `cp -r source scratch/tree`, then `find scratch/tree | sort`. `scratch/tree` did not exist.
What did `cp` do with the name?

**6.** Now the other case: `cp -r source dest`, then `find dest | sort`. `dest` **did** exist. State
in one sentence the rule that made these two identical command lines behave differently.

**7.** `dest/handover.txt` was already there before you started, and it is still there after
exercise 6. Explain why, given that `source/handover.txt` exists too.

**8.** Reset the lab (`kestrel reset 04/03`) so `dest` is clean again. Then `cp -rT source dest` and
`find dest | sort`. What did `-T` change, and what happened to the `dest/handover.txt` that was
there?

**9.** `cp -r source/ scratch/slash1` and `cp -r source scratch/slash2`, then compare the two with
`find scratch/slash1 scratch/slash2 | sed 's/slash[12]//' | sort -u | wc -l` or just by eye. Does a
trailing slash on the **source** change anything for `cp`?

**10.** `cp -r source/. scratch/dot` (with `mkdir -p scratch/dot` first). `ls scratch/dot`. What does
the `/.` do that a bare `source` does not?

**11.** Now the destination side. `mv source/handover.txt nosuch/` — report the exact error. Then
`mv source/handover.txt scratch/nosuch2` (no slash) and `ls scratch`. Two nearly identical commands,
two entirely different outcomes. Say precisely what the slash asserted.

**12.** Undo that: `kestrel reset 04/03`. When would you deliberately write the trailing slash on a
`mv` destination?

**13.** `ls -l source/latest.txt` — it is a symlink to a file. Now `cp source/latest.txt/ scratch/z`.
Report the exact error and say why a trailing slash on a *source* is not always a no-op.

**14.** `cp -r source scratch/t2` then `ls -l scratch/t2/latest.txt`. Did the symlink stay a symlink?
Now `cp -rL source scratch/t3` and `ls -l scratch/t3/latest.txt`. What did `-L` do, and what is the
size difference telling you?

**15.** `cat dest-file`, then `cp source/handover.txt dest-file`, then `cat dest-file`. Report all
three. Was there any warning?

**16.** Reset. Then `cp -i source/handover.txt dest-file` and answer `n`. Then run it again as
`cp -i source/handover.txt dest-file </dev/null` and report both the prompt and the exit status.
State the consequence for a `-i` inside a script.

**17.** `cp -n source/handover.txt dest-file; echo $?`, then `cat dest-file`. Compare with exercise
16: which of `-i` and `-n` is safe to put in a script, and what exit status does the refusal give
you?

**18.** `cp source/faults/open.txt source/latest.txt dest-file` — report the error. Then the same two
sources into `dest`. State the rule about what the last argument must be when there is more than one
source.

**19.** `cp -rv source scratch/verbose | head -4`. What exactly is `-v` printing — the plan, or what
already happened?

**20.** `mv -v rename/pnl_02.log rename/panel-02.log`. `mv -v` uses a different word than `cp -v`.
Which, and is it accurate?

**21.** `stat -c '%n %y' source/handover.txt stale/handover.txt`. Which is newer? Now
`cp -u -v source/handover.txt stale/handover.txt` and report the output.

**22.** `stat -c '%n %y' source/faults/open.txt stale/open.txt`. Now `cp -u -v` the source onto the
stale one, report the output and the exit status, and `cat stale/open.txt`. What did `-u` do, and how
would you have known without `-v`?

**23.** `-u` compares modification times. Name a case where the file you have is the one you want and
`-u` will overwrite it anyway.

**24.** `cp -u -v source/readings/*.txt stale/`. Which of the two files was copied, and why not both?

**25.** Reset. Using `-u`, copy `source/` into `stale/` so that only genuinely older files are
replaced, and confirm afterwards that `stale/open.txt` still says `NEWER than the source copy`.

**26.** `ls -l perms/exec.sh perms/secret.txt`, then `cp perms/exec.sh scratch/e1` and
`cp perms/secret.txt scratch/s1`, then `ls -l scratch/e1 scratch/s1`. Did the mode survive a plain
`cp`? Both of them?

**27.** Same files, but compare `stat -c '%n %y %U:%G' perms/secret.txt scratch/s1`. Something did
**not** survive. Name it.

**28.** `cp -p perms/secret.txt scratch/s2` and `stat` it the same way. What does `-p` preserve, and
what is `-a` adding on top of `-p` that matters for a directory tree?

**29.** `stat -c '%n %h %i' source/faults/open.txt source/open-hardlink.txt` — two names, one inode.
Copy the tree twice, with `cp -r` and with `cp -a`, and `stat` the same two names inside each copy.
Report the link counts. Which flag kept the two names as one file, and which made two files out of
them?

**30.** `rename/` has six logs named `pnl_NN.log` and they should be `panel-NN.log`. Rename all six
with one loop. `mv` takes one source and one destination, so the loop is doing the work, not `mv`.

**31.** Could you have done exercise 30 with brace expansion and a single `mv`? Try it, and explain
the result in terms of what `mv` does with more than two arguments.

**32.** `mv rename/panel-0{1,2,3}.log scratch/` then `ls scratch`. Now the same shape works. What is
different about this case?

## Experiment

For each of these: **write your prediction down before you run it.** Then run it, and write down
which part of your prediction was wrong. The wrong part is the exercise.

**33.** Predict the exit status and the effect of `mv scratch/x scratch/x` after creating
`scratch/x`. Then predict the same for `cp scratch/x scratch/x`. Run both and report the two exact
messages.

**34.** Predict what `cp -r source source/nested` does. Run it. Then explain what `cp` had to notice
in order to produce that message, and why the naive implementation would not have terminated.

**35.** Predict whether `mv` changes a file's inode number. Then measure it in the two cases:
`mv scratch/a scratch/b` (same filesystem) and `mv scratch/b /tmp/b` (different filesystem — check
with `df --output=source,target /labs /tmp`). Report both inode numbers each time, and say which
case had to read and write every byte.

**36.** Two directories, `mkdir -p scratch/e/x scratch/f`. Predict what `mv scratch/e scratch/f`
does, then run it and `find scratch/f`. Now predict `mv -T` for the same shape, and finally predict
what happens if the target directory is **not** empty. Run all three.

## Stretch

**37.** Copy `source/` to `scratch/mirror` in a way that a second run of the exact same command
changes nothing at all. Prove it: run it twice, and compare `find scratch/mirror -printf '%p %s %m
%T@\n' | sort | md5sum` after each run. State which flag made the second run a no-op and which flag
made the timestamps match in the first place.

**38.** `cp --backup=numbered source/faults/open.txt dest/handover.txt`, then `ls dest`. Report the
name of the file that appeared. Then read `man cp` on `--backup` and `--suffix`, and say what
`VERSION_CONTROL` has to do with it.

**39.** `cp -t` and `mv -t` take the destination **first**. Copy three files from `source/` into
`scratch/` using `-t`, then explain the one situation where `-t` is not a stylistic choice but the
only thing that works. (Think about a command whose file list is being generated for it.)

**40.** Write a copy that refuses to clobber and tells you which files it skipped. `cp -n` is silent
about refusals; combine it with something that shows you. Two acceptable approaches: one uses another
`cp` flag, the other compares a listing before and after.

**41.** You are handed a tree and told to reproduce it exactly on another disk, including modes,
owners, times, symlinks and hard links. Write the single command. Then name the one thing about the
original that your copy still cannot reproduce, and say why.

**42.** Overwrite protection, three ways: `-i`, `-n`, and a shell setting that is not a `cp` flag at
all. Find the third (`help set`, and look for `noclobber`), demonstrate it protecting a redirection,
and then demonstrate that it does **not** protect `cp`. Explain the boundary — what is `noclobber` a
property of?

## Dig

**43.** `mv` prompts you in one situation even without `-i`. Find it: make a file you own, remove
your write permission from it (`chmod 400`), and `mv` something over it, typing at your terminal.
Report the prompt verbatim. Then do the same with `cp` and report what it says instead — it is not a
prompt. Explain the difference in terms of which of the two needs write permission on the *file* and
which needs it on the *directory*. Then run the `mv` again with `</dev/null` and report what the
prompt does when nobody is there to answer.

**44.** `cp` writes the destination in place by default — it opens and truncates the existing file
rather than replacing it. Design an experiment using a hard link that proves this, and run it. (Hint:
make a second name for the destination first, then copy over the first name and check the second.)

**45.** Given exercise 44: a program that has the destination open while you `cp` over it sees the
contents change under it. `mv` on the same filesystem does not do that. Explain the difference in
terms of directory entries and inodes, and say which of the two is the safer way to publish a new
version of a file that something else may be reading.

**46.** `cp -a` claims to preserve everything. Test the claim on the one piece of metadata that
cannot be preserved: create a file, note all four times from `stat`, `cp -a` it, and `stat` the copy.
Which of the four differs, and what would preserving it have meant?
