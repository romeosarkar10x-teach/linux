# 06/05 — Exercises: `find`, Advanced

```
cd /labs/06-searching/05-find-advanced
ls -F
cat notes/handover.txt
```

`-delete` and `rm` are allowed **inside `scratch/` only**. `kestrel reset 06/05` restores the lab,
and you will need it more than once in this lesson.

---

## Size, and the rounding

**1.** `find sizes -type f -printf '%s %p\n' | sort -n`. Nine files. Write the byte counts down;
every exercise in this section is checkable against that list.

**2.** `find sizes -type f -size 0`. One file. Which, and what does `-size 0` mean given that `-size`
rounds up?

**3.** `find sizes -type f -size -1k`. Predict before running. You probably said "everything under
1024 bytes". Which files did you actually get, and why?

**4.** `find sizes -type f -size 1k`. Five files, and only one of them is 1024 bytes. State the rule
that explains the set.

**5.** `find sizes -type f -size +1k`. Which three files, and why is `exactly-1k.log` not among them?

**6.** `find sizes -type f -size 1c` and `-size 512c` and `-size 1024c`. Now the numbers behave.
What is the `c` suffix doing that the bare number is not?

**7.** `find sizes -type f -size -512c` versus `-size +512c`. Three and five. That is eight of nine
files — which one is in neither set, and why does that make sense?

**8.** `find sizes -type f -size +0`. Nine files? Count them. Then explain the difference between
`-size +0` and `! -size 0`, or say there is none.

**9.** `find sizes -type f -size 1`. No suffix. Three files, and not the ones from exercise 4. What
unit did you just use?

**10.** Find every file in the whole lab over 32 kilobytes. One file. Write the predicate.

**11.** Write the predicate for "between 1 and 3 kilobytes inclusive" and test it against `sizes/`.
Say honestly whether the rounding makes "inclusive" mean what you want.

**12.** `du -h sizes/forty-k.log` versus `find sizes/forty-k.log -printf '%s\n'`. If they disagree,
which one answers "how many bytes is this file" and which answers "how much disk does it use"?

## Time, when the clock is real

`spool/` was stamped relative to the moment the lab was seeded, so ordinary time predicates work
there. Everything else in the lab is stamped in 2187 and will misbehave on purpose later.

**13.** `find spool -type f -printf '%TY-%Tm-%Td %TH:%TM %f\n' | sort`. Six files. Note the ages
implied by the names.

**14.** `find spool -type f -mmin -60`. One file. Now `-mmin +60`. Five. What is the boundary case,
and is any file in neither set?

**15.** `find spool -type f -mtime 0`. Two files. `run-25h.log` is not one of them. Say why, using
the word "truncated".

**16.** `find spool -type f -mtime 1`. One file. Reconcile that with exercise 15 in one sentence.

**17.** `find spool -type f -mtime -1` gives the same two files as `-mtime 0`. Is that a coincidence
of this lab or always true? Argue it from the definition.

**18.** `find spool -type f -mtime +7`. Two files. Now `-mtime 7` — what do you get, and what would
that difference do to a rotation script meant to delete logs older than a week?

**19.** `find spool -type f -daystart -mtime 1` versus without `-daystart`. Same answer here. Write
down the time of day at which they would stop agreeing.

**20.** `-mtime`, `-atime`, `-ctime`: which one changes when you `chmod` a file? Prove it in
`scratch/` — copy a file in, `stat` it, `chmod`, `stat` again.

**21.** `find spool -newer spool/run-3d.log`. Which files, and is `run-3d.log` itself in the output?
What does that tell you about `-newer`'s comparison?

**22.** Rewrite exercise 21 to include the reference file itself. (`-newer` alone cannot; combine.)

## Time, when the clock is fiction

**23.** `find deck -type f -printf '%TY-%Tm-%Td %TH:%TM %f\n' | sort`. Nine files, all stamped
2187-06. Now `find deck -mtime -7` and `find deck -mtime +1`. Ten and zero. Explain both.

**24.** `find deck -newerct '2187-06-09'`. Zero files, even though every mtime is later than that.
Which timestamp did you just ask about, and why is it not in 2187?

**25.** Exercise 24 is the most useful fact in this lesson for anyone reading a tampered tree. Say in
one sentence what it lets you detect.

**26.** `find deck -newermt '2187-06-09 04:30'`. How many, and which is the earliest in the result?

**27.** Add the other end: `find deck -newermt '2187-06-09 04:30' ! -newermt '2187-06-09 04:35'`.
Two files. Name them.

**28.** One of those two is stamped exactly `04:35`. It is inside the window. Which end of the window
is closed and which is open? Write the interval in mathematical notation.

**29.** Tighten it: `! -newermt '2187-06-09 04:34'`. Now one file. What is it, and what does its
content say?

**30.** Widen it: `-newermt '2187-06-09 04:29' ! -newermt '2187-06-09 04:36'`. Three files. Say what
the two markers are for and why somebody would seed a tree that way.

**31.** `find deck -newermt 'yesterdayy'`. Quote the error exactly. Note that `find` is doing date
parsing, not glob matching, and that a typo fails loudly here — unlike a typo in a `-name` pattern.

**32.** `-newermt 'yesterday'`, `-newermt '2 hours ago'`, `-newermt '2187-06-09'` — all valid. Which
of these three would you ever put in a script, and why not the others?

**33.** Using only what `notes/handover.txt` tells you, write the single `find` command that finds
the one file written during the gap. Then read that file.

**34.** Generalise exercise 33 into a shell function `window START END DIR`. Test it against the
`04:29`/`04:36` pair.

## Permission

**35.** `find perms -type f -printf '%m %p\n' | sort`. Eight files. Keep the list.

**36.** `find perms -perm 644`. Two files, and one of them is not directly in `perms/`. Which
flavour of `-perm` is this?

**37.** `find perms -perm -644`. More files. State the rule in one sentence, and say why `run.sh`
(755) is in this set but not in exercise 36's.

**38.** `find perms -perm /022`. Two files. What question does this answer that neither of the
previous two can?

**39.** `find perms -perm -022` versus `-perm /022`. One file versus two. Explain the difference by
saying what `-022` demands.

**40.** `find perms -perm /111`. Three entries, and two of them are directories. Why are directories
executable at all?

**41.** `find perms ! -perm -u=w`. One file. What is it, and would `rm` be able to delete it? (You
answered that in Chapter 4 — say the reason.)

**42.** Find every file in the whole lab that is world-writable. One file. Then write the same
predicate in symbolic form.

**43.** `find . -perm 600 -type f`. Two files in two different directories. Was that the answer you
expected from the directory names?

**44.** `perms/closed/` is mode 700 and contains a file. You can still read it — because you own it.
Write the command that would find "files inside directories nobody but the owner can enter". Say why
`find` cannot answer that question with a single predicate.

## Ownership, and a predicate that cannot help

**45.** `find . ! -user cadet | wc -l` → 0. `find . -user cadet | wc -l` → 56. Read the comment at
the top of `owners/mode-differs.txt`. Why is `-user` useless in *this* tree?

**46.** Given exercise 45, is "every file is owned by cadet" evidence about who wrote them? Answer in
one sentence. This is the general lesson: a predicate that cannot discriminate is not a finding.

**47.** `-nouser` and `-nogroup` find entries whose numeric owner has no passwd entry. Nothing here
matches. Describe a real situation where they would, and why it matters.

**48.** `find . -uid 1000 | wc -l`. Same as `-user cadet`? Check `id cadet` and say which form you
would use in a script that runs on a machine where the account might not exist.

## Empty

**49.** `find . -type d -empty`. Two directories. `find . -type f -empty`. Two files, and one of
them is in a directory you would not have thought to look in. Which, and why is it empty?

**50.** `notes/dot-only/` contains only `.keep`. Is it `-empty`? Run it, note the exit status, and
say what "empty" means to `find`.

**51.** Combine: find directories that contain nothing at all and delete them — but print first.
Write both commands, in the right order.

## `-exec`, both forms

**52.** `find sizes -type f -exec echo one +`. Quote the error exactly. Fix it by adding one thing,
and say what the rule about `{}` and `+` is.

**52b.** Now the real measurement: `find sizes -type f -exec echo {} \;` prints nine lines,
`-exec echo {} +` prints one. Explain what you measured, in processes.

**53.** `find deck -name 'panel-*.log' -exec wc -l {} \;` versus `+`. One of them prints a `total`
line. Which, and why is that a consequence of process count rather than a flag?

**54.** `find deck -type f -exec grep strain {} \;` versus `+`. One prints filename prefixes. Same
cause as exercise 53 — restate it in terms of what you learned in lesson 01 about `grep` and
multiple file arguments.

**55.** Get filename prefixes with `\;` anyway. (Lesson 02 has the flag.)

**56.** `find deck -type f -exec sh -c 'echo "$1 $1"' _ {} \;`. Why does `{}` appear once but print
twice, and what is the `_` for?

**57.** `find deck -type f -exec false {} \; ; echo "rc=$?"`. `find`'s status is 0 even though every
command failed. What does that mean for `find … -exec` in a script that checks `$?`, and how would
you actually detect a failure?

**58.** `-exec` as a test: `find deck -type f -exec grep -q adjusted {} \; -print`. One file. Explain
why `-print` is needed and what would happen if you dropped it.

**59.** Rewrite exercise 58 without `-exec`, using `grep -rl`. Then say which one you would use if
the filter also involved `-newermt`, and why.

**60.** `find scratch -name 'ok.log' -ok rm {} \; < /dev/null`. Quote the prompt. Did the file
survive? What does that tell you about `-ok` in a non-interactive context, and how does it differ
from `-i` on `rm`?

## `-delete`, and the order trap

Everything here is inside `scratch/`. Reset when you are done.

**61.** `mkdir -p scratch/a && touch scratch/a/{one,two}.log scratch/a/keep.txt`. Now
`find scratch/a -name '*.log' -print` and read it. Then swap `-print` for `-delete`. Confirm what
remains.

**62.** `find scratch/a -delete` on a directory that still has `keep.txt`. Does it work? What does
that tell you about `-delete` and non-empty directories — and about the order it descends?

**63.** The trap. `mkdir -p scratch/w && touch scratch/w/{a.log,b.txt}`, then run
`find scratch/w -delete -name '*.log'`. Look at what is left of `scratch/w`. Explain exactly why, in
terms of evaluation order and the truth value of `-delete`.

**64.** Fix exercise 63 by moving one word. Then state the habit that would have prevented it.

**65.** `find scratch/x -delete -print` on a seeded file — does it print before or after deleting,
and what is the exit status? Say why `-print` after `-delete` is not a safety net.

**66.** `-delete` implies `-depth`. Build a two-level tree in `scratch/` and show that
`find scratch/tree -delete` removes it entirely, then explain why the implied `-depth` is required
rather than merely convenient.

## Names that fight you

**67.** `ls awkward/`. Four files. Say what is wrong with each name.

**68.** `find awkward -type f | xargs -n1 echo`. Quote the error exactly. How many of the four files
were processed?

**69.** `find awkward -type f -print0 | xargs -0 -n1 echo`. Four lines? Count carefully — one file
produces two. Which, and why is that not `xargs`'s fault?

**70.** `find awkward -type f -printf '[%f]\n'`. Now the newline in the filename is visible. What
does that tell you about using `find … | while read` on untrusted names?

**71.** Do the same job with no pipe at all: `find awkward -type f -exec echo {} +`. Say why this is
usually the better answer than `-print0 | xargs -0`.

**72.** `awkward/-summary.log` starts with a dash. Copy it to `scratch/` and delete the copy with
`rm`. Two ways (Chapter 4). Then delete it with `find … -delete` and note that `find` never had the
problem.

## `-printf`, and sorting by what `find` knows

**73.** `find deck -type f -printf '%T@ %p\n' | sort -n | head -1`. What is that first number, and
what does it mean that it is greater than the current epoch seconds (`date +%s`)?

**74.** Print every file in `sizes/` as `bytes<TAB>name`, sorted largest first, using `-printf` and
`sort` only.

**75.** `%p` versus `%f` versus `%h`. Print all three for one file and describe each.

**76.** Write a one-liner listing every file in the lab modified in the 2187-06-09 04:00–05:00 hour,
with its mtime, sorted. Use `-newermt`, `-printf` and `sort`.

## Experiment

**77.** Construct a file in `scratch/` for which `-size 1k` and `-size 1024c` disagree. Then one for
which they agree. What is the only size where they agree?

**78.** Prove that `-mtime` uses seconds internally, not calendar days: make two files 100 seconds
apart in `scratch/` with `touch -d`, and find a `-mmin` boundary that separates them.

**79.** Show that `-newer` compares mtimes and not ctimes, by `chmod`-ing a file and demonstrating
that `-newer` does not change while `-cnewer` does.

**80.** `find . -type f -newermt '2187-06-09 04:30' ! -newermt '2187-06-09 04:35' -exec grep -l .
{} +`. Chain a window into a content search. Now do the reverse order (grep first, then filter by
time) and say which is cheaper and why.

## Stretch

**81.** `find . -type f -size +1k -exec grep -c . {} + | sort -t: -k2 -rn | head -3`. Read the
pipeline aloud in one sentence, then check whether the sort key is right.

**82.** Write the safe rotation command: delete `*.log` under `spool/` older than seven days, batched,
with a dry run first. Then say the two things that make the naive version dangerous.

**83.** `find` has `-quit` (stop after the first match). Use it to answer "does any file in this lab
contain the word `adjusted`" without walking the whole tree, and say how you know it stopped early.

**84.** Explain why `find . -name '*.log' -delete` in a directory you did not `cd` into is a
different risk from `rm *.log`, in both directions — name one way `find` is safer and one way it is
worse.

## Dig

**85.** `notes/handover.txt` says: "When it holds exactly one thing, that is worth a sentence in the
report." You found that one thing in exercise 33. Write the sentence for the report — what the file
is, when it was written, and what it does *not* tell you.

**86.** The two `marker-*` files bracket the window. Suppose they were not there. Reconstruct the
window from `deck/` alone: what evidence in the tree tells you where to put the boundaries, and how
confident can you be?

**87.** Prove, using `-newerct`, that every mtime in `deck/` was set after the fact rather than
written naturally. Then say what a careful person would do to make the tampering harder to see, and
whether `find` could still catch it.

**88.** The chapter's incident involves a gap in a numbered log. Nothing in this lesson searches
content for numbers — that is lesson 01–03. Write, in one line each, which predicate from *this*
lesson you expect to need, and what you would still need `grep` for.
