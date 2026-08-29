# 08/02 — Exercises: redirection

```
cd /labs/08-streams-and-redirection/02-redirection
export PATH="$PWD/bin:$PATH"
cd scratch          # do your work here, not in the lab root
```

Everything below assumes you are in `scratch/` and refer to the lab's files as `../data/...`.
Wrecked it? `kestrel reset 08/02`.

---

## Warmup — the two counts

**1.** `deckreport`. Seventeen lines on screen. Which are the answer and which are notes? Guess
first, then check.

**2.** `deckreport 2>/dev/null | wc -l`. The fd 1 count.

**3.** `deckreport 2>&1 >/dev/null | wc -l`. The fd 2 count. Do the two numbers add to what you saw?

**4.** Take exercise 3 apart. Write the two assignments it performs, in order, with what each
descriptor points at afterwards. Do not move on until you can do this without the readme.

**5.** `deckreport >/dev/null 2>&1 | wc -l`. Zero. Write the same two assignments for this one and
say which line of your working explains the zero.

**6.** From the sentence you wrote in the last lesson's exercise 24, guessing what `2>&1` does: was
it right? Correct it in one sentence if not.

**7.** `cat notes/order.txt`. Which part of it did you already work out for yourself?

## `>`, `>>`, and truncation

**8.** `deckreport > a.txt 2>/dev/null; wc -l a.txt`. Now run the same line again. Same count. Why
is it not 24?

**9.** `deckreport >> a.txt 2>/dev/null; wc -l a.txt`. Now it grows. State the difference between
`>` and `>>` in terms of the descriptor table, not in terms of "overwrite".

**10.** `cp ../logs/deck05.log d.log; cat d.log`. Two existing lines. Now `deckreport >> d.log
2>/dev/null; wc -l d.log`. How many?

**11.** Same starting file, but with `>`. What happened to the two lines that were already there?

**12.** `cat notes/page.txt`. rhea's log is always exactly one run long. Which character is
responsible, and what is the one-character fix?

**13.** `echo hi > new.txt` where `new.txt` does not exist. Does `>` create it? What are its
permissions, and what decided them?

**14.** `> empty.txt` — a redirection with no command at all. Does it work? What is it useful for?

**15.** `deckreport > /dev/null; echo "rc=$?"`. Does redirecting change the exit status?

**16.** `failhard > /dev/null 2>&1; echo "rc=$?"`. Same question, with a program that fails.

## Order, in your hands

**17.** `deckreport > out.txt 2>&1; wc -l out.txt`. Seventeen. Explain in one line.

**18.** `deckreport 2>&1 > out2.txt; wc -l out2.txt`. Twelve, and five lines on your screen. Explain
in one line.

**19.** `deckreport &> out3.txt; wc -l out3.txt`. Which of the two above is `&>` equivalent to?

**20.** Prove it rather than believing it: `cmp out.txt out3.txt`. What does silence mean?

**21.** `deckreport > s.txt 2> s.txt; wc -l s.txt; cat s.txt`. Not seventeen. Read the last two lines
of the file carefully — one of them is a fragment. Explain what two independent descriptors did to
one file.

**22.** Rewrite exercise 21 so it actually collects both streams, two different ways.

**23.** `deckreport 2> e.txt 1>&2; wc -l e.txt`. Seventeen again, by the other route. Write the two
assignments.

**24.** Predict, then run: `chatty a b > o.txt 2>&1; cat o.txt`. Is the alternation preserved?

**25.** Predict, then run: `chatty a b 2>&1 > o2.txt; cat o2.txt`. What is in the file and what is on
your screen?

**26.** `deckreport 2>&1 >/dev/null | head -2`. Which two lines, and why those?

**27.** In a pipeline, `2>&1` copies the pipe rather than the terminal. What tells you the pipe was
set up before the redirections were applied?

## The trap

**28.** `cp ../data/readings.txt r.txt; wc -l r.txt`. Twenty lines. Now, on the copy:
`sort r.txt > r.txt`. `wc -c r.txt`. How many bytes?

**29.** Explain the zero in terms of *when* the truncation happened relative to `sort` opening its
input.

**30.** Does `sort r.txt >> r.txt` behave better? Try it on a fresh copy and describe what you get.
(It is not "fine".)

**31.** Give two ways to sort a file in place that actually work. One uses a temporary name; the
other is a tool you met in Chapter 7.

**32.** `set -o noclobber`. Now `echo y > r.txt`. Read the message and the exit status. Then
`echo y >| r.txt`. Then `set +o noclobber`.

**33.** Does `noclobber` protect you from exercise 28? From `>>` into the wrong file? Say exactly
what it does and does not cover.

## `<`, and `/dev/null`

**34.** `wc -l < ../data/readings.txt` versus `wc -l ../data/readings.txt`. Same number, different
output. Why is the filename missing in the first?

**35.** `wc -l < nope.txt; echo "rc=$?"`. Who produced that message — `wc` or bash? How can you tell?

**36.** `failhard < /dev/null; echo "rc=$?"`. What does `< /dev/null` guarantee a program?

**37.** `wc -c < /dev/null`. Zero bytes. State the two halves of what `/dev/null` is.

**38.** `deckreport 2>/dev/stdout >/dev/null | wc -l`. Five. Compare with exercise 3 — same answer,
different mechanism. Which would you rather read in someone else's script?

## The shift board

**39.** `cat notes/wrong.txt`. Six entries. For each, predict what it does before running it. Write
your six predictions down first — this exercise is worthless if you run them first.

**40.** Now run each in `scratch/`. For A, report the line count of both files it writes.

**41.** One of the six is not a mistake at all. Which one, what is it for, and why is it on a list of
mistakes?

**42.** For E, `deckreport &> out.txt 2>/dev/null`: what ends up in `out.txt`, and where did the rest
go? Give the assignments in order.

**43.** For B, `deckreport 2> out.txt 1>&2`: is this wrong? Argue it either way in one sentence each.

**44.** Which entry is the one that loses data permanently, and what would you have to have done
beforehand to survive it?

## Reporting

**45.** Write the two-sentence answer to rhea's page. It must name the character and must not use
the word "just".

**46.** A colleague's script has `prog >> log 2>&1` and yours has `prog 2>&1 >> log`. Both "work" and
have for months. Describe the day they diverge.

**47.** Write the rule you would put on the shift board, in one sentence, that would have prevented
four of the six entries in `notes/wrong.txt`.

## Experiment

**48.** Build a file that contains only the complaints from three consecutive `deckreport` runs, with
nothing from fd 1. One command per run is fine; the file must end up 15 lines.

**49.** Now do it as one command line for one run, appending, and prove your file grows by five each
time.

**50.** Redirect fd 3 somewhere and have a script write to it: `exec 3> three.txt` then
`echo hi >&3`. What happened to your shell's own descriptor table, and how do you undo it?
(`exec 3>&-`.) Check with `ls -l /proc/$$/fd` before and after.

**51.** Make a program's stderr go to a file *and* the screen, without `tee`. You will probably fail;
say precisely what you would need that redirection alone does not give you.

**52.** `deckreport > out.txt 2>&1 > out2.txt` (entry A). Add a third: `2> out3.txt` on the end.
Predict the contents of all three files, then check.

**53.** Truncate a file using only a redirection, in three different ways.

## Stretch

**54.** `bash -c 'echo a; echo b >&2' > f 2>&1` versus `{ echo a; echo b >&2; } > f 2>&1`. Same
result. Now put the redirections on the inner commands instead and explain why the grouping matters.

**55.** Why can `2>&1` be written `2>& 1` but not `2> &1`? What is the shell actually parsing?

**56.** `prog 2>&1 | tee log` gives you both streams on screen and in a file. What is the exit status
of that pipeline, and whose? (Chapter 7 gave you `PIPESTATUS`; use it.)

**57.** A wrapper script runs a tool as `tool >> "$LOG" 2>&1` where `LOG=/var/tmp/tool.d/$(date
+%F).log`. Nothing is wrong with the redirection. Describe the failure mode anyway, in terms of who
reads that path and how long it lives.
