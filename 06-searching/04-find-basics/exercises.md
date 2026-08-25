# 06/04 — Exercises: `find` Basics

```
cd /labs/06-searching/04-find-basics
cat reports/index.txt reports/handover.txt
```

Quote every `-name` pattern. `kestrel reset 06/04` restores the lab.

---

## The walk

**1.** `find .` — how many lines? Now `find . | wc -l`. What is the first line, and why is it there?

**2.** `find . -print | wc -l` gives the same number. What does that tell you about the default?

**3.** `find . -type f | wc -l`, `-type d`, `-type l`. Do the three add up to the total from exercise
1? Say what that means about the entries `find` visits.

**4.** `find . -maxdepth 1`. List it. Now `find . -maxdepth 0`. What is the difference, in words.

**5.** `find . -mindepth 1 | wc -l`. Which single entry did that remove?

**6.** Run `find` with no path argument at all: `find -name '*.txt'`. It works. What did it use as the
starting path, and is that portable?

**7.** `find nosuch -name x; echo "rc=$?"`. Quote the message and give the status.

**8.** `find reports/index.txt; echo "rc=$?"`. A file, not a directory, as the starting path. What
happened? When is that useful?

## `-name`

**9.** `find . -name '*.log' | wc -l` → 13. `find . -name '*.log' -type f | wc -l` → 11. Which two
entries did `-type f` remove, and are they logs?

**10.** `find . -iname '*.log' | wc -l` → 14. Name the file that `-iname` added and `-name` missed.

**11.** `decks/deck-03/panel-03.log~` exists and `-name '*.log'` does not match it. Explain in terms
of what the pattern is compared against. Then write a pattern that matches both.

**12.** `reports/index.txt` says backups "are not logs and must not be counted as logs". Given
exercise 11, is `-name '*.log'` the right test for "is a log"? Answer with the count it gives and
the count you believe.

**13.** `find . -name '*/deck-03/*' | wc -l` → 0. Why is that not a bug?

**14.** Get every file under `decks/deck-03/` two ways: one with `-path`, one by changing the
starting path. Which one would you use in a script and why?

**15.** `find . -name readings`. Two results. `find . -name readings -type d`. One. Read
`reports/handover.txt` and say what would have gone wrong if you had piped the first into `cat`.

**16.** `find . -name '.*'`. Two results, one of them surprising. Which, and why is it there?

**17.** Does `find` need `dotglob` to see `.hidden-notes`? Answer with a command that proves it.

**18.** Find every entry whose name starts with a dash. There is exactly one. Did you have to do
anything special to the pattern? (Compare with lesson 01, exercise 12 — say why this case is
different.)

## The quoting trap

**19.** From the lab root, run `find . -name *.log` — unquoted. It works. Run `ls *.log` in the same
directory and say exactly why it worked.

**20.** `cd scratch`, then `find . -name *.log`. It still "works". Now say what `find` was actually
searching for. This is the dangerous form — explain why.

**21.** `cd decks/deck-03`, then `find . -name *.log`. Quote both lines of the error exactly.

**22.** You have now seen the same bug produce a correct answer, a wrong answer, and an error. Which
of the three is the worst outcome, and what is the one-character habit that prevents all three?

**23.** Does `-path` have the same problem? Construct the case in `scratch/` and show it.

## `-type`

**24.** `find links -type l` — three results, including one whose target does not exist. Which, and
why is a broken symlink still found?

**25.** `find -L links -type f`. The output is much longer. What did `-L` do, and where did the extra
entries come from?

**26.** Under `-L`, what happens to `links/broken.log`? Try `find -L links -type l` and explain.

**27.** `find links -xtype l`. One result. State the difference between `-type l` and `-xtype l` in
one sentence.

**28.** `find links/deck-03 -maxdepth 1` gives one line. `find links/deck-03/ -maxdepth 1` gives
seven. Explain the trailing slash.

**29.** `find . -type f,d | wc -l` → 41. What did the comma do, and which entries are missing from
the 44?

**30.** Count directories that contain nothing at all: `find . -type d -empty`. Two results. Now
`find . -type f -empty` → 0. What does that tell you about how this lab was seeded?

## Depth

**31.** `find . -maxdepth 2 -type d`. List it, and say which decks' bays are missing and why.

**32.** `find . -mindepth 2 -maxdepth 2 -name '*.log'`. Three results. Explain each one's depth by
counting slashes.

**33.** `find . -name '*.log' -maxdepth 2` — the option after the test. Compare the output with
exercise 32's `-maxdepth 2 -name '*.log'`. Same or different?

**34.** Older `find` printed a warning for exercise 33. This one (findutils 4.11) prints nothing.
Given that the result is identical either way, why does the readme still tell you to write depth
options first?

**35.** How many `.log` files live at depth 3 or deeper? Get it with `-mindepth`, then check it by
subtracting two other counts.

**36.** `find . -maxdepth 1 -type f | wc -l` → 0. What does that say about the lab root, and how
would you phrase the same question for `decks/deck-03`?

## Combining tests

**37.** `find . -type f ! -name '*.log' | wc -l` → 10. List them and say which one you would argue
*is* a log despite its name.

**38.** `find . -name '*.log' -o -name '*.txt' | wc -l` → 19.

**39.** `find . -name '*.log' -o -name '*.txt' -type f | wc -l` → also 19. Predict what `find .
\( -name '*.log' -o -name '*.txt' \) -type f | wc -l` gives before you run it.

**40.** It gives 17. Name the two entries the ungrouped version let through, and write out what the
ungrouped expression actually means as an English sentence with brackets in it.

**41.** Every regular file under any `bay-01` directory whose name ends in `.log`, case-insensitive.
One command.

**42.** Everything under `decks/` that is **not** under `deck-03`. Two ways: one with `!` and
`-path`, one by listing starting paths.

**43.** `find decks/deck-03 decks/deck-04 -name '*.log' | wc -l` → 6. What happens to the printed
paths when you give two starting paths, and what does that mean for `sort`?

## Beyond globs

**44.** `find . -regex '.*/strain-0[12]\.log'` — four results, and it misses two files a human would
say are strain logs. Which two, and why?

**45.** `find . -regextype posix-extended -regex '.*/(panel|strain)-[0-9]+\.log' | wc -l` → 10. Which
dialect is the default, and what did `-regextype` change? (Lesson 03 is the reference.)

**46.** `-regex` matches the whole path, not part of it. Prove it: write a `-regex` that fails only
because it lacks a leading `.*`.

**47.** When would you use `-regex` over `-name` plus a pipe into `grep`? Give one case for each and
name the cost of the pipe. (Hint: think about what happens to a filename containing a newline.)

## Experiment

**48.** Make a directory in `scratch/` whose name ends in `.log`. Now `find scratch -name '*.log'`.
Did your "find all logs" command just get a directory? Fix it.

**49.** Create a file in `scratch/` with a newline inside its name (`touch $'scratch/two\nlines'`).
Run `find scratch | wc -l`. Is that count honest? What would `find scratch -name '*' | wc -l` say?

**50.** Time `find / -name 'panel-03.log' 2>/dev/null` and then `find /labs -name 'panel-03.log'`.
Report both. What is `find` spending its time on?

**51.** `find . -name '' ; echo rc=$?`. Nothing, status 0. Is an empty `-name` pattern the same as no
`-name` at all? Contrast with `grep ''` from lesson 01, exercise 32.

**52.** Build a case in `scratch/` where `find . -name 'x*'` and `ls x*` give different answers and
neither is wrong.

## Stretch

**53.** `find . -name scratch -prune -o -name '*.log' -print | wc -l` → 12, one fewer than 13.
Explain what `-prune` did, and why the `-print` at the end is not optional here.

**54.** `find decks/deck-04` versus `find decks/deck-04 -depth`. Same seven entries, different order.
State the rule, and name an operation that requires the second order.

**55.** `find . -name '*.log' -o -print | wc -l` → 31. Work out what that command means. (It is not
"everything that is not a log", and the difference is the point.)

**56.** Write one command that answers `reports/handover.txt`'s question three ways: how many names
end in `.log`, how many regular files contain a line matching `strain 0\.`, and how many files are
under `decks/`. Report the three numbers and say which one you would give to whoever asked.

## Dig

**57.** `archive/2187-05/panel-03.log` and `archive/2187-06/panel-03.log` have identical base names
and identical depth. Using only this lesson's tools, give the one property that distinguishes them
in `find`'s output, and say what you would need to distinguish them by *content* instead.

**58.** The index says logs are `panel-NN.log` and `strain-NN.log`. Find every `.log` file whose name
does **not** fit either convention, and list them. Then say, for each, whether it is a naming mistake
or a different kind of file.

**59.** Somebody will eventually run "find every log and delete the old ones" on this tree. From what
you have measured, list three entries that command would get wrong, and say for each whether the
error is a false positive or a false negative. Do not run anything destructive.
