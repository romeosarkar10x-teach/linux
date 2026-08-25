# 06/01 — Exercises: `grep` Basics

```
cd /labs/06-searching/01-grep-basics
ls -F
```

Single-quote every pattern from exercise 1 onwards, even when it looks unnecessary. `kestrel reset
06/01` restores the lab.

---

## Warmup

**1.** `grep 'ERROR' logs/comms-2187-06-10.log`. Roughly how much output? Now count it:
`grep -c 'ERROR' …`. Write the number down.

**2.** `grep -c 'Error' …` and `grep -c 'error' …` on the same file. Three numbers. What do they
sum to, and what does `grep -ci 'error' …` give?

**3.** Is `grep -i` the right tool for that log, or is it hiding something you would want to know?
Answer in one sentence with the numbers from exercise 2.

**4.** `grep 'WARN' logs/panel-2187-06-10.log`. No output. Is that because there are no matches,
because the file is unreadable, or because you typed the name wrong? How do you find out?

**5.** `grep 'ERROR' logs/empty.log; echo "rc=$?"`. And `grep 'zzz' logs/comms-2187-06-10.log;
echo "rc=$?"`. Same status. Why is that correct rather than sloppy?

**6.** `grep 'ERROR' logs/nosuch.log; echo "rc=$?"`. A different status. Which one, and what would
happen to a script that only tested `if grep -q …`?

## Pattern, file, and the shell in between

**7.** `grep comms ERROR logs/comms-2187-06-10.log`. Read the output carefully — it is two things at
once. What did `grep` think you asked for?

**8.** Rewrite exercise 7 so it does what it looks like it should. There are two ways: one uses a
flag, one uses a different pattern. Give both.

**9.** `grep -c '0.06' logs/comms-2187-06-10.log` → 13. `grep -cF '0.06' …` → 0. Explain the
difference in one sentence, and say which one is the answer to "how many lines mention 0.06".

**10.** `grep -c 'deck-0[13]' crew.txt` → 30. `grep -cF 'deck-0[13]' crew.txt` → 0. Same lesson,
different metacharacter. What is `-F` actually switching off?

**11.** `grep 'strain 0.4' logs/strain-2187-06-10.log | wc -l` and `grep -cF 'strain 0.4' …` give
the same number here. Why does that not mean `.` is harmless in this pattern?

**12.** Search `notes/handover.txt` for the line that begins with a dash. `grep '-v'
notes/handover.txt` does not do it. What does it do instead, and why does the terminal appear to
hang?

**13.** Two fixes for exercise 12: one names the pattern explicitly with a flag, one ends the
options. Give both, and say which one you would use in a script that takes the pattern from a
variable.

## Files, and more than one of them

**14.** `grep 'ERROR' logs/*.log | head -3`. What has been added to every line, and what added it?

**15.** `grep -c 'ERROR' logs/*.log`. Four lines of output, three of them zero. Is that more or less
useful than a single number, and for what question?

**16.** Get the matching lines from `logs/*.log` *without* the filename prefix. Which flag?

**17.** Force the filename prefix onto a single-file search. Which flag, and when would you want it?

**18.** `grep 'ERROR' logs` — the directory, not a file. What happens, and what status?

**19.** `grep -c 'ERROR' < logs/comms-2187-06-10.log`. Same count, different invocation. What is
`grep` reading, and what does that tell you about where the filename prefix in exercise 14 came
from?

**20.** `grep 'ERROR' notes/binary.dat`. `grep` refuses to print the line. Quote the message exactly.
Why does it do that, and which flag overrides it?

**21.** How many bytes into `notes/binary.dat` is the thing that made `grep` call it binary? (`cat
-A` and `wc -c` are enough.)

## Exit status, seriously

**22.** `grep -q 'ERROR' logs/comms-2187-06-10.log; echo $?` and the same with `zzz`. What does `-q`
buy you over `> /dev/null`?

**23.** Write a one-liner that prints `errors present` or `clean` for a log file, using the exit
status and nothing else.

**24.** Extend it to distinguish three cases: matched, did not match, and could not read the file.

**25.** `grep -s 'ERROR' logs/nosuch.log; echo "rc=$?"`. `-s` silenced the message. Did it change
the status? Say why that combination is a trap.

**26.** In `scratch/`, make a file you cannot read (`chmod 000`) and grep it. Which status, and is
the message on stdout or stderr? Prove it with a redirection.

## Patterns from a file, and several at once

**27.** `cat notes/patterns.txt`. Now `grep -c -f notes/patterns.txt logs/comms-2187-06-10.log`.
What number, and what does `-f` mean about how the three lines combine?

**28.** Get the same number without `-f`, using `-e` twice or more.

**29.** `grep -c -e 'ERROR' -e 'WARN' logs/comms-2187-06-10.log` → 60. Add `-e 'INFO'` and predict
the result before running it. Were you right?

**30.** A line that matches two of the patterns is counted how many times? Prove it:
`printf 'ERROR WARN\n' | grep -c -e ERROR -e WARN`.

**31.** What happens if `notes/patterns.txt` has a blank line in it? Copy it to `scratch/`, add one,
and find out. Explain the result in terms of "the empty pattern".

**32.** `grep -c '' logs/panel-2187-06-10.log` → 40. What did you just count, and what is the
cheapest thing this tells you about a file?

## Reading the crew file

**33.** Who is on deck 03? Then: how many people are on deck 03?

**34.** `grep 'cass' crew.txt` and `grep 'CASS' crew.txt`. One returns nothing. Fix it two ways: one
that changes the pattern, one that changes how `grep` compares.

**35.** Find the line for `rhea` without also matching anything containing `rhea` as a substring.
State whether that distinction matters in *this* file, and how you checked.

**36.** How many crew records are *not* on deck 03? Get it two ways: with subtraction, and with a
single `grep`. (The flag you want is in lesson 02, but you can guess it — try.)

**37.** The file has one record per line and three colon-separated fields. Count the distinct decks
mentioned, using only `grep -c` and running it more than once. Then say why this is the wrong tool
for that question and which chapter fixes it.

## Experiment

**38.** Build a file in `scratch/` where `grep -c 'ERROR'` and `grep 'ERROR' | wc -l` disagree.
First rule out the obvious guess: make a file with no final newline (`printf 'a\nb' > scratch/x`)
and show that both still agree. Then find the property that does it. (You already met the file type
in exercise 20.)

**39.** Make a file where `grep 'a'` prints a line that does not visibly contain an `a`. Two ways to
do this; one involves the terminal lying to you and one involves the pattern.

**40.** `grep` a file against itself: `grep -f logs/panel-2187-06-10.log logs/panel-2187-06-10.log |
wc -l`. Predict first. Then explain why it is slow.

**41.** Time it: `time grep -c 'ERROR' logs/comms-2187-06-10.log` versus `time grep -cF 'ERROR' …`.
Is `-F` measurably faster on a 240-line file? What would you need for the difference to show?

**42.** Search the whole lab for the word `panel`, case-insensitively, and get a list of *which
files* contain it, not the lines. You are allowed to guess the flag; it is in lesson 02.

## Stretch

**43.** `grep 'ERROR' logs/comms-2187-06-10.log | grep 'relay'` versus `grep 'ERROR.*relay'
logs/…`. Same output here. Name a case where they differ, and construct it in `scratch/`.

**44.** What does `grep` do with a pattern that is longer than any line in the file? Predict the
status, then check.

**45.** `grep -c 'ERROR' logs/*.log` prints zeros for files with no match. `grep -c 'ERROR' logs/*.log
| grep -v ':0$'` filters them. Explain what the second `grep` is matching, character by character —
you have not been taught `$` yet, so say what you think it does and check.

**46.** Read `notes/handover.txt`. It says the log is inconsistent about `Panel 03` versus `Panel 3`.
Write one `grep` that finds both. `'Panel 0*3'` works — say precisely why, in terms of what `*`
means in a regex, and then say what it would *also* match that you did not intend. Check your answer
by building the counter-example in `scratch/`.

**47.** The handover says "grep the run log for the word run". There is no run log in this lab.
Where would you look for one, and what would you search for? (Chapter 6's incident is that file.)

**48.** `LC_ALL=C grep -ci 'error' logs/comms-2187-06-10.log` versus the same without. Same answer
here. Construct the case where locale changes a case-insensitive match, and say why you cannot do it
with ASCII.

## Dig

**49.** `grep -r 'ERROR' .` from the lab root. It searches `notes/binary.dat` too. What does that do
to the output, and what would you add to make the result usable?

**50.** How many lines across `logs/` carry a severity word at all? Do not list the severities:
find the structural property the comms log's lines share and the panel log's lines do not, and
search for that. Report the count per file, and say what the panel log's format costs whoever has to
search it.

**51.** The comms log covers 2187-06-10. Prove, with `grep` alone, that it covers the whole day and
has no gap of more than six minutes. State clearly which part of that claim `grep` cannot check for
you.

**52.** One line in the lab claims a flag is "not a flag we use here". Find it, and say what it is
actually doing in that file — as data, not as an instruction.
