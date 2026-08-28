# 07 — Building a pipeline

> "Nobody writes a nine-stage pipeline. They write one stage, look at it, and add another. The people
> who look fast at this are just people who never guessed."

Every command in this chapter you already have. This lesson adds no new ones. What it adds is the
only thing that turns those commands into work you can trust: **a method for building a pipeline that
does not require you to be right the first time.**

You have probably already had the experience where a pipeline runs, prints a number, and you have no
idea whether the number is true. That is not a knowledge gap. It is a process gap. You built the whole
thing before you looked at any of it.

## The method

It is on the wall in the maintenance locker, and it is in `notes/method.txt`:

1. **Look at the input.** `head -5`. Not what you remember the input looking like. The input.
2. **Write stage one. Run it. Look at it.**
3. **Add one stage. Run it. Look at it.**
4. **When the output surprises you, stop.** The surprise is the bug, and it is in the stage you just
   added, because everything before it already surprised you or did not.
5. **Check the count at every stage.** A number that did not change when it should have is the
   loudest free bug you will ever get.
6. **Only when it is right, redirect to a file.**

That is the whole lesson. The rest is practice at not skipping step 3.

## Look at the input first

```
$ head -5 logs/maint-raw.txt
```

The dump is not a clean table. It has two comment lines at the top, blank lines scattered through it,
a comment at the bottom, and a status line that is not a record at all. `wc -l` says 128. There are
**120** records. If you build a pipeline that ends in a count and never notice the difference, your
report is wrong by eight and nobody will ever tell you.

So stage one is almost always: **get down to the lines that are actually records.**

```
$ grep -c '^2187' logs/maint-raw.txt
120
```

Anchoring on the shape of a record beats `grep -v '^#'` plus `grep -v '^$'`, because the junk you have
not seen yet is not a comment and is not blank.

## Grow it one stage at a time

Building the "who caused the most maintenance events" report, with a look after every stage:

```
$ grep '^2187' logs/maint-raw.txt | head -3
$ grep '^2187' logs/maint-raw.txt | awk '{print $4}' | head -3
$ grep '^2187' logs/maint-raw.txt | awk '{print $4}' | sort | uniq -c | sort -rn
```

Run those three in order and the third one lies to you. It reports panels, not actors, and only
thirteen of the lines give an actor at all. Field 4 is not the actor. Field 4 is *sometimes* the
actor, which is much worse.

The reason is one space:

```
[INFO ]    ->  splits into  [INFO   and   ]      two fields
[ERROR]    ->  splits into  [ERROR]              one field
```

`awk` counts fields, not columns. Two field counts in one file means positional extraction is wrong
on some fraction of the lines and right on the rest, silently. `awk '/^2187/{print NF}' | sort -u`
prints `6` and `7`, which is the entire diagnosis in one command.

The fix is to stop counting and start naming:

```
$ sed -n 's/.*actor=\([^ ]*\).*/\1/p' logs/maint-raw.txt | sort | uniq -c | sort -rn
     83 ops-bot
     19 rhea
     11 cass
      4 vint
      2 orla
      1 bex
```

83 + 19 + 11 + 4 + 2 + 1 = 120. The count matches stage one. That is what "check the count at every
stage" buys you: not a feeling that it is right, an arithmetic check that it is.

**When a field's position is not reliable, key off the field's name.** `key=value` logs exist so that
you can, and most machine-written logs are `key=value` for exactly this reason.

## Counts are your test suite

You have no test framework here. You have counts. Some that catch real bugs:

- Does the record count survive a stage that was not supposed to drop anything?
- Does the sum of a `uniq -c` column equal the record count?
- Does `sort -u` reduce the line count by the number you expected?
- Does the last stage's output have as many lines as there are distinct keys?

`awk '{print $1}' … | sort | uniq -c | awk '{s+=$1} END{print s}'` is the cheapest test in this
course.

## `uniq` without `sort` is the most common bug in this chapter

`uniq` collapses **adjacent** duplicates only. On the actor stream unsorted:

```
     43 ops-bot
      1 rhea
      1 ops-bot
      1 rhea
      ...
```

It is not broken. It answered a different question — "runs of identical lines" — and that question
looks enough like the one you asked to survive review. Say it out loud once: **`sort` before `uniq`,
always, unless you specifically want runs.**

## Where the exit status went

A pipeline's exit status is the status of the **last** command, not of the pipeline:

```
$ grep nosuch logs/maint-raw.txt | wc -l
0
$ echo $?
0
```

`grep` failed. `wc` succeeded. The pipeline reports success and prints a zero that means "no matches"
but looks exactly like a legitimate zero. Two ways to see the truth:

```
$ grep nosuch logs/maint-raw.txt | wc -l ; echo "${PIPESTATUS[@]}"
0
1 0
$ set -o pipefail ; grep nosuch logs/maint-raw.txt | wc -l ; echo $? ; set +o pipefail
0
1
```

`PIPESTATUS` is an array of every stage's status, and it is only valid immediately after the
pipeline. `set -o pipefail` makes the pipeline fail if any stage fails. Scripts should generally set
it. At the prompt, `PIPESTATUS` is the one you will actually reach for.

## Redirect last, and never into your own input

Two rules, both learned the same way:

- Build the pipeline to the terminal. Add `> reports/whatever.txt` only when the terminal output is
  the output you want. A wrong pipeline that printed to the screen cost you nothing; a wrong pipeline
  that wrote a file cost you the file and possibly your belief in the file.
- `sort file > file` truncates `file` before `sort` opens it. Write somewhere else, then move.

## Order of stages changes the answer and the cost

`grep` before `awk` and `awk` before `sort` is not style. Filtering early means every later stage
handles fewer lines, and `sort` is the expensive one. But it is also about correctness: filtering
after `uniq -c` filters counted lines, not records, and those are different things.

Ask of every stage: *what does the stream contain now?* If you cannot answer in one noun — records,
actor names, counted actor names, a single number — you have lost track, and that is exactly when you
should run it and look.

## What you should be able to do

Take a report request in a sentence, look at the input, and grow a pipeline stage by stage, checking
a count at each step, until the output is defensibly right. And when it is wrong, find out which
stage did it in under a minute — because you looked at every stage as you added it.
