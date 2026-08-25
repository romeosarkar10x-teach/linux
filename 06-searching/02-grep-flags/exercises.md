# 06/02 — Exercises: `grep` Flags

```
cd /labs/06-searching/02-grep-flags
ls -F
```

Quote every pattern. `kestrel reset 06/02` restores the lab. Before you start, read
`reports/notes.txt` — it tells you the shape of the report format, and two exercises depend on it.

---

## Warmup: what matches

**1.** `grep -c 'FAULT' reports/*.log`. Four numbers. Which file has none, and which has none
*because nothing went wrong* rather than because it is short?

**2.** `grep -c 'FAULT' archive/deck-03-2187-06-09.log` → 0, but the archived copy is a copy. Find
the fault lines in it anyway and say what changed.

**3.** Now `grep -ci 'fault' archive/deck-03-2187-06-09.log`. Same number as the live report?

**4.** `grep -c 'bay' words.txt` and `grep -cw 'bay' words.txt`. Print both sets of lines and list
exactly which lines `-w` removed and why each one was removed.

**5.** `grep -w 'bay' words.txt` keeps `bay-01`. State the rule `-w` actually uses. It is not "the
English word".

**6.** `grep -cx 'bay' words.txt`. One. Which line, and how is `-x` different from anchoring the
pattern at both ends (which you have not been taught yet — say what you would expect)?

**7.** `grep -c 'E-104' codes.txt` → 6, `grep -cw 'E-104' codes.txt` → 4, `grep -cx 'E-104'
codes.txt` → 2. Go line by line through the file and account for every one of those numbers.

**8.** One line of `codes.txt` begins with a space. Which of the three counts in exercise 7 does it
land in, and which does it not? What does that tell you about `-x` and whitespace?

**9.** `grep -cvx 'E-104' codes.txt`. Predict, then run. What did you just count?

## `-v`, and what it is not

**10.** How many entries in `reports/deck-04-2187-06-09.log` are not `ok`? Use `-v -c`, then look at
the lines and say why the number is not zero even though deck-04 had no faults.

**11.** Exercise 10 is a lesson in what `-v` inverts. It does not invert "entries" — it inverts
lines. Rewrite the search so the count answers the question that was actually asked.

**12.** `grep -lv 'FAULT' reports/*.log`. Every file is listed, including the ones full of faults.
Explain why in one sentence.

**13.** Get the files that contain no `FAULT` at all. Which flag, and how does it differ from
exercise 12?

**14.** `grep -L 'FAULT' reports/*.log` → two files. One is `quiet.log`. Is that a good result or a
misleading one, given exercise 1?

**15.** Write one command that answers "which report files mention no fault, in any spelling". Test
it against `archive/` too.

## What you see

**16.** `grep -n 'FAULT' reports/deck-03-2187-06-09.log`. Four line numbers. Write them down; the
next several exercises use them.

**17.** The report says entries are numbered from 001. Compare the *entry numbers* on the fault lines
with the *line numbers* `-n` gave you. Why do they diverge, and by how much at the last fault?

**18.** Which of those two numbers survives someone deleting a line from the middle of the file?
This is the whole reason the reports are numbered.

**19.** `grep -c '0\.4' readings.csv` and `grep -o '0\.[0-9][0-9]' readings.csv | wc -l` → 9 and 40.
Explain both numbers. What question is each one the answer to?

**20.** Make `-c` and `-o | wc -l` agree on `readings.csv` by changing only the pattern.

**21.** `grep -o` on a pattern that can match at overlapping positions: build one in `scratch/`
(`printf 'aaaa\n'` and the pattern `aa`) and say how many matches you get and why not three.

**22.** Extract just the bay names from `readings.csv`, one per line, with `-o`. Then count the
distinct ones — and say why `grep` alone cannot do the "distinct" part.

## Context

**23.** `grep -A2 'FAULT' reports/deck-03-2187-06-09.log`. Read `reports/notes.txt` first and
predict how many lines will come out. Then count them: 13.

**24.** You predicted 12 (4 matches × 3 lines). Where did the thirteenth line come from? Look at it
carefully — it is not from the file.

**25.** `grep -A2 'FAULT' reports/deck-03-2187-06-09.log | grep -c 'entry'`. Why is that not 12
either?

**26.** Three of the four faults are at consecutive entries. What does `-A2` do to their context
blocks, and how does the output tell you it happened?

**27.** `grep -B1 'FAULT' … | wc -l` → 11 and `grep -C1 'FAULT' … | wc -l` → 13. Account for both
without running them again.

**28.** Construct the case where `-C1` output has *more* lines than `-A1` plus `-B1` output
combined, or argue that it cannot happen.

**29.** `grep -A2 -c 'FAULT' …` → 4. Does `-c` count context lines? What does that say about the
order in which `grep` applies the flags?

**30.** Use context to show the fault at entry 022 with everything around it, without printing the
other three faults. (Any approach; say which flags did the work.)

## Where it looks

**31.** `grep -rl 'FAULT' .` from the lab root. Six files. Two of them are not reports at all. Name
them and say why each matched.

**32.** `reports/notes.txt` matches. Is that a false positive? Answer in terms of what you asked for
versus what you meant.

**33.** Restrict the search to log files: `grep -rl --include='*.log' 'FAULT' .` → three files.
Which one dropped out that you wanted, and which two that you did not?

**34.** `grep -rl --exclude-dir=.cache 'FAULT' .` → four files. Compare with exercise 33. State the
difference between excluding a directory and including a filename pattern, as two different
questions.

**35.** Write the search that finds fault markers only in live reports — not archived, not cached,
not notes. More than one flag combination works.

**36.** `grep -r 'FAULT'` with no path at all. What does it search, and what would that have done if
you had run it in your home directory?

**37.** `grep -ric 'fault' . | sort`. Fifteen lines. Which files have a zero, and why is a zero
useful here when `-l` would have hidden it?

**38.** `--exclude-dir` prunes the walk; `--exclude` still walks. Design a test in `scratch/` that
would show the difference in *time* rather than in output, and say why you cannot demonstrate it at
this lab's size.

## Combining

**39.** Count fault lines per file across the whole tree, live reports only, with the filename
attached and the zeros dropped. One pipeline.

**40.** List the live report files that have **more than two** fault lines. `grep` cannot do
"more than two" — say which part of your pipeline does.

**41.** For each fault in `reports/deck-03-2187-06-08.log`, print the fault and its first detail line
with line numbers. Which flags, in which order?

**42.** Find lines that contain `bay` as a word but are not entirely the word `bay`. Two flags, and
one of them must be negated — think about whether you can do it in one `grep`.

**43.** `grep -ow 'bay' words.txt | wc -l` → predict, then run. Explain any surprise using exercise
19's lesson.

**44.** Which live report files contain a fault *and* the word `cleared`? `grep -l` twice is the
obvious way; do it and say what it costs.

## Experiment

**45.** Does `-c` with `-o` count matches or lines? Predict, then check on `readings.csv`.

**46.** Does `-l` stop reading the file? You cannot time it here — find the argument from the
documentation instead (`man grep`, the `-l` entry) and quote the phrase that settles it.

**47.** What happens when you give `-A` a value of 0? And a negative number? Report the error text
exactly.

**48.** `grep -v -x '' reports/quiet.log` — predict before running. What is the pattern, what does
`-x` do to it, and what does `-v` do to that?

**49.** `-i` and `-w` together on `words.txt` with the pattern `BAY`: predict the count, then run.

**50.** Put two flags in conflict: `grep -l -L 'FAULT' reports/*.log`. What does GNU grep do — error,
or pick one? Report exactly.

## Stretch

**51.** `grep -c 'FAULT' reports/*.log` gives four lines including zeros; `grep -rc 'FAULT'
reports/` gives five. Which file appears in one and not the other, and why?

**52.** The archive copy uses lower-case `fault`. Write one search that finds the marker in both
spellings but does **not** match the word `default` if it appeared. Test it by adding such a line to
`scratch/`.

**53.** Someone asks: "how many faults were there on deck 03 over both days?" Give the number, and
then give the reason your number might be wrong even though the command is correct. (Look at what
`archive/` holds.)

**54.** Explain to someone who has not done this lesson why `grep -L` and `grep -v -l` are different
tools, using one file from this lab as the example.

## Dig

**55.** `reports/notes.txt` claims a FAULT line is followed by two detail lines in deck-03 and none
in deck-04. Verify both halves with `grep` and its flags alone. One half is easy; say what makes the
other half hard, and what you would need to be certain.

**56.** Both deck-03 reports have a fault at entry 007. Are they the same fault? Use context flags to
show the evidence, and state plainly what the evidence does and does not prove.

**57.** Using only what this lesson taught, find every line in the tree that is a fault marker on a
line of its own, with nothing else on it. Which files, and what are those files for?
