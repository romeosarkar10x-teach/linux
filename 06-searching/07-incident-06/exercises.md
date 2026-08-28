# 06/07 — Exercises: Incident, the gap is the message

```
cd /labs/06-searching/07-incident-06
ls -F
```

Chapters 1–6 tools. Wrecked the lab? `kestrel reset 06/07`. Do not edit anything under `logs/`.

---

## Warmup — read before you search

**1.** `cat notes/page.txt`. Write down, in your own words, the two claims cass is making. They are
not the same claim and only one of them is a symptom.

**2.** `ls -F` and then `ls -A spool`. Two different pictures of the same directory. Which flag
changed it, and what would you have missed?

**3.** `cat notes/monitor-summary.txt`. What does the monitor claim about its own run? List every
number in it and say where each one could be checked.

**4.** From the summary alone: run window 03:00:00 to 05:59:45, interval 15 seconds. Derive the
expected entry count by hand. Does your arithmetic agree with the monitor's claim?

**5.** `ls -l logs`. Four files. Group them into two pairs and say what distinguishes each pair.

**6.** `head -5 logs/strain-run-2187-06-13.log`. Describe the record format precisely: how many
fields, which are fixed-width, and which two of them are redundant with each other.

**7.** `grep -i error logs/*.log; echo "rc=$?"`. Nothing. Also try `warn`, `fail`, `alert`. Write
one sentence about what a clean `grep -i error` does and does not tell you.

## Counting — the whole case is here

**8.** `grep -c '^#' logs/strain-run-2187-06-13.log`. Write the number down. Now `head -3` the file
and explain why that number is not the number of entries.

**9.** Fix the pattern so it counts entries only. `grep -c '^#[0-9]' …`. What is the count now, and
what is the difference from exercise 8?

**10.** `wc -l` on the same file. Compare all three numbers you now have. Which one is the honest
answer to "how many entries are in this file", and why is `wc -l` not it?

**11.** Expected 720, present as measured in exercise 9. State the deficit as a number.

**12.** Prove the numbering is monotonic and never reused before you lean on it:
`grep -oE '^#[0-9]{4}' logs/strain-run-2187-06-13.log | sort | uniq -d`. What does empty output
prove, and what does it not?

**13.** `grep -oE '^#[0-9]{4}' … | tail -1` and `| head -1`. Lowest and highest sequence. Does
`highest − lowest + 1` equal the count from exercise 9?

**14.** Do the same three commands on `logs/strain-run-2187-06-12.log`. This is the control. What is
its count, and what does the control establish that the 13th alone could not?

## Locating the gap

**15.** Find where the numbering jumps. `grep -n '^#02' | head -40` will get you close by eye; then
do it properly. Give the last sequence before the gap and the first after it.

**16.** How many entries are missing, by sequence? Does it match exercise 11?

**17.** `grep -n '^#0245\|^#0265' logs/strain-run-2187-06-13.log`. Two lines, and note the *line*
numbers as well as the sequence numbers. Why are the line numbers consecutive when the sequence
numbers are not? What does that tell you about how the entries left the file?

**18.** Convert the missing sequence range to a clock window using the two surviving entries either
side. State it as `HH:MM:SS` to `HH:MM:SS`.

**19.** Check your window against the interval: 19 missing entries at 15 seconds each. Does the
arithmetic close, exactly, with no slack? If it does, what does that rule out — a monitor that
stopped and restarted, or entries removed from a file that kept running?

**20.** `sed -n '245,250p' logs/strain-run-2187-06-13.log`. Look at the `strain=` values either side
of the join. Is there any visible discontinuity? What does that mean for anyone hoping to spot this
by reading?

## The red herring

**21.** Run your exercise-9 count on `logs/panel-run-2187-06-13.log`. Compare with its highest
sequence number. What deficit do you get?

**22.** That deficit is much bigger than the one you are chasing. Before you do anything else, read
`notes/rotation.txt`. Then say what the deficit actually is.

**23.** `ls logs`. Which file did you not count? Count it.

**24.** `cat logs/panel-run-2187-06-13.log.1 logs/panel-run-2187-06-13.log | grep -c '^#[0-9]'`.
Total. Is anything missing from the panel run?

**25.** Write the one-sentence rule that would have stopped you reporting the panel log. It should
mention rotation and it should be checkable in one command.

**26.** Now apply the same suspicion to the strain log. Is there a `strain-run-2187-06-13.log.1`?
Prove there is not — with `find`, not with `ls`, and say why that distinction matters here.

**27.** `cat notes/rotation.txt` again, last paragraph. What does it say about bank A specifically,
and how much weight can that sentence carry on its own?

## The search that closes it

**28.** You have a window. Exactly one file in this tree was written inside it. Write the `find` that
returns it, using `-newermt` twice. Remember the window is half-open.

**29.** Your `find` should return one path. If it returns none, widen the window by a minute at each
end and try again — then narrow back and say what was wrong with your first attempt.

**30.** Why did `ls spool` not show you this file? Which flag from Chapter 2 would have?

**31.** Run the same `find` scoped to `logs/` only. Nothing. What does that establish about when the
deletion happened relative to the last write of the log?

**32.** `stat spool/.hold-2187-06-13`. Read all three timestamps. Which of them is inside your window
and which are not, and which one is the one you searched on?

**33.** `cat` it. It is a form. `cat notes/forms.txt` and identify which form, then read the
convention for the summary fields.

**34.** Extract the summary fields with a single ERE and `grep -o`, in numeric order. You want the
values, not the keys.

**35.** Two of the seven fields are empty. Which two, and what does `notes/forms.txt` say should have
happened to a record in that state?

**36.** Assemble the flag and submit it:
`kestrel flags submit 'KESTREL{...}'`.

## Reporting

**37.** Write the three-sentence finding for cass. It must state what is missing, how you know, and
what you checked to rule out the boring explanation. It must not contain the word "someone".

**38.** cass asked "if it is nothing, tell me it is nothing". Write the sentence you would have sent
if the strain log had turned out to be like the panel log.

**39.** Your finding will be read by somebody who will want a name. Write the sentence you put in the
report about the two blank fields, which says what the evidence supports and stops there.

**40.** What would you change about the monitor so this is impossible to do quietly next time? Give
two answers, one cheap and one expensive, and say what each costs.

## Experiment

**41.** In `scratch/`, copy the strain log and delete a block of entries from the middle with `sed`.
Now detect your own deletion using only the techniques from this lesson. How few entries can you
remove and still be caught?

**42.** Same copy: remove a block from the *end* instead of the middle. Is it detectable? Why is
truncation a different problem from excision?

**43.** Build an unnumbered version of the log (`cut -d' ' -f2-` into `scratch/`). Delete nineteen
lines from the middle. Try to detect it. Write down what you have to fall back on and how much
weaker it is.

**44.** Add a fake entry to your scratch copy with a sequence number that already exists. Which of
your checks catches a duplicate, and which of them do not?

**45.** `find . -newermt '2187-06-13' ! -newermt '2187-06-14' -type f`. Everything written on the
day. How many, and how does the volume of that answer compare with the one-file answer from
exercise 28? Which window would you reach for first next time?

## Stretch

**46.** Write a one-liner that takes any of these run logs and prints every missing sequence number,
not just the first and last. `grep -o`, `sort`, and something from Chapter 7 that you have not been
taught yet — `seq` and `comm` are both fair game if you can work them out.

**47.** Generalise: a function `gapcheck FILE` that prints expected, present, deficit and the missing
ranges, and exits non-zero if there are any. Test it on all four logs and on your scratch copies.

**48.** The panel log's rotation was detectable by the presence of a `.1` file. What if the rotation
had used a date suffix, or compression, or a different directory? Describe the check that does not
depend on the naming convention.

**49.** `grep -c` on a directory of a thousand logs is slow. Given `find`, `-exec` and what you know
about `+` versus `\;`, write the version that would run over a whole log archive, and say which form
you chose and why.

**50.** The record you found is a *hold* record — the sampler was held out of the run legitimately,
and released. Explain how a legitimate mechanism and nineteen missing entries can both be true at
once, and what evidence would distinguish "held" from "held, and then the trace tidied".

## Dig

Four stages in `records/`. Tokens are `STAGE{...}` and do not register.

**51.** Stage 1. Exactly one file in `records/` was written on 2187-06-13. Find it by time, not by
name. Token, and the instruction for stage 2.

**52.** Stage 2 is the count. The difference between what the strain log claims and what it contains
is a line number in `records/index-b.txt`. If you land on a line that tells you to count again, you
counted the header lines — that is the trap from exercise 8 and it is deliberate.

**53.** Stage 3. One sampler id stops appearing after the gap and never comes back. Find it with
`grep -o` and an ERE, restricted to the entries after the gap. It names a file in `records/`.

**54.** Stage 4. Three files mention `SH-12`. Find all three with a single `find … -exec grep …`,
and note that the one you want is the one `ls` never showed you. Compare `-exec … \;` with
`-exec … +` here and say which one you can use and why.

**55.** The four stages used four different skills. Name them, and name the one skill from this
chapter that the chain did not use — then say why it would have been the wrong tool for every stage.
