# 05/02 — Exercises

```
cd /labs/05-globbing-and-quoting/02-brace-expansion
```

Rule for this lesson, and it is not optional: **`echo` first.** A brace expression that is wrong
does not fail, it succeeds at something else, and `mkdir` will happily build the something else.

## Warmup

1. `echo a{b,c}d`. Now predict `echo a{b,c}{d,e}` before running it, then run it. How many words?

2. `echo {1..5}` and `echo {01..05}`. What is different about the second, and which endpoint caused
   it? Test your answer with `echo {1..05}`.

3. `echo file{,.bak}`. Explain the output in terms of "a list with two elements".

4. `cd backup; ls`. Which two files have a `.bak` beside them, and which two do not?

## Core — the three forms

5. `echo {a..e}`, `echo {e..a}`, `echo {a..z..5}`. State the rule for the third one in your own words.

6. `echo {0..20..5}` and `echo {20..0..5}`. Does the step have to be negative to count down?

7. `echo {10..1..3}`. Which numbers come out, and which endpoint is not in the list? Why not?

8. Predict the output of `echo {-2..2}`, then run it. Now predict `echo {2..-2}`.

9. `echo {1..5..0}`. What did a step of zero do? Was that what you expected?

10. `echo {a,b}{1,2}` and `echo {a,b}-{1,2}`. Then `echo {a..d}{1..3} | wc -w`. Give the arithmetic
    that predicts 12.

11. `echo a{b,c{d,e}}f`. Write out, in words, the list the inner braces produced and what the outer
    ones did with it.

12. `echo {b,a,c}`. Compare with `echo *` from lesson 1. Which of the two sorts its output?

13. Five expressions that do nothing:
    ```
    echo {abc}
    echo {a}
    echo {a, b}
    echo {a,b
    echo {a..3}
    ```
    For each, say in one clause why the shell refused to treat it as a brace expression.

## Core — building the deck

Read `spec/deck-spec.txt` and `spec/gaps.txt` before starting.

14. Write the *naive* expression — the one the spec alone suggests — and run it under `echo`, not
    `mkdir`. How many directories would it create?

15. Run it for real into a throwaway directory:
    ```
    mkdir -p scratch/naive && cd scratch/naive
    mkdir -p deck-05/bay-0{1..8}/{readings,faults,handover}
    find deck-05 -type d | wc -l
    ```
    Confirm the count matches your prediction from exercise 14.

16. Which directory did that create that `spec/gaps.txt` says must not exist? Which two things from
    the spec did it fail to create at all?

17. `bay-0{1..8}` works, but only by luck. What happens to the padding if the deck had twelve bays
    and you wrote `bay-0{1..12}`? Test it with `echo`. Now write a form that pads correctly for
    twelve bays.

18. Build the correct deck-05 tree in `build/`, with **one** `mkdir -p` command, honouring all three
    gaps. Verify with `find build/deck-05 -type d | wc -l`. The answer is 39.

19. Explain the count: write it as a sum, with a term per part of the tree.

20. Somebody proposes fixing gap 1 by building all eight bays and then running `rmdir` on bay-06.
    Give one argument for and one against, in the specific context of a command somebody else will
    read later.

21. The three panels are `03`, `05`, `09`. Write both the list form and the sequence form that would
    produce them if they were regular, and say why only one of them can be used here.

22. `mkdir -p` was used, not `mkdir`. Run your one-command build a second time into the same
    `build/`. What happened, and which flag is responsible?

23. Change one bay's name in your expression to `bay-99` and run the whole thing again with `echo`.
    Did anything warn you? Compare with what a glob would have done with a name that matches nothing.

24. Write the expression that creates only bay-08's four subdirectories, without touching the other
    bays. One command.

## Core — braces meet the filesystem

25. `ls existing/deck-05`. Which bays exist, and which of their subdirectories?

26. From the lab root, run:
    ```
    echo existing/deck-05/bay-0{1,2,3}/readings
    ```
    Three of those paths do not exist. Did the shell tell you? Which command would have?

27. Now run `ls -d existing/deck-05/bay-0*/readings`. How many did the glob return, and what is the
    difference between the two answers?

28. State the rule this lesson turns on, in one sentence, using the words *filesystem* and *string*.

## Core — the `{,.bak}` idiom

29. In `scratch/`, make a file and copy it: `echo test > scratch/x.cfg; cp scratch/x.cfg{,.bak}`.
    Write out the command the shell actually ran.

30. `cd backup`. Write one command that makes a `.bak` of `panel-09.cfg` and `panel-11.cfg` and no
    others. (Careful — a `.bak` already exists for two of the four.)

31. What does `mv panel-03.cfg{,.bak}` do given that `panel-03.cfg.bak` already exists? Predict
    first, then test it on a copy in `scratch/`, and check the mtimes with `ls -l` before and after.

32. `cp backup/panel-{03,05,09,11}.cfg scratch/`. Then `rm scratch/panel-{03,07}.cfg`. What is the
    exit status, what was deleted, and what was not?

33. Exercise 32's `rm` complained about one file and deleted another. Is that behaviour you want in a
    script? Write the version of that command you would actually commit.

## Experiment

34. `set -x`, then run `echo panel-{01,02,99}.log` in `01-globs/panels`. Read the trace. Then run
    `echo panel-*.log` in the same directory with `set -x` still on. Describe the difference between
    the two traces in terms of *when the filesystem was consulted*.

35. Still with `set -x`: `echo panel-{0,1}*.log` in that directory. How many arguments did `echo`
    receive, and how many patterns were matched against the disk to produce them? Which expansion
    ran first?

36. ```
    n=5
    echo {1..$n}
    ```
    Run it. Now run `eval echo {1..$n}`. Explain both results in terms of the order of expansions.

37. Three ways to get `1 2 3 4 5` from a variable `n=5`: `seq`, a C-style `for` loop, and `eval`.
    Write all three. Rank them for use in a script somebody else maintains, and justify the ranking.

38. `echo {1..3,7}` — predict, then run. What did the shell decide that expression was?

39. `echo a{b\,c,d}e`. Where did the backslash take effect, and what would happen without it?

40. `echo {a,}{b,}`. Four combinations, three words. Find the missing one — `set -- {a,}{b,}; echo $#`
    and `printf '[%s]\n' {a,}{b,}` will both help. Say what happened to it, and at which stage.

41. `mkdir -p seq/run-{001..010}` then `ls seq | head -3`. Now `mkdir -p seq/run-{1..10}` and
    `ls seq | wc -l`. How many directories are there, and why is that number the way it is?

42. Sort the result of `ls seq`. Where do the unpadded names sort relative to the padded ones, and
    what does that tell you about why padding is worth the two extra characters?

## Stretch

43. Write a single command that creates, in `scratch/`, a file per hour for one day, named
    `2187-05-30-HH00.txt` with HH from 00 to 23. Verify you got 24, and that the first is `0000`.

44. Write one command that would create the deck-05 tree for **decks 05, 06 and 07** at once, keeping
    all three gaps. How many directories? Predict before running.

45. Brace expansion has no length limit worth relying on. Estimate the word count of
    `{a..z}{a..z}{a..z}` before running `echo {a..z}{a..z}{a..z} | wc -w`. Then give one reason a
    command like that is dangerous even when it is correct.

46. You need to remove `bay-01` through `bay-05` from a tree, but `bay-03` is currently mounted by
    somebody else's process and must be skipped. Write the brace expression, and then say why this is
    a case where a glob plus a manual check might be the better tool.

47. A colleague's script contains `rm -rf $BASE/{logs,tmp}`. `BASE` is unset. Work out exactly what
    runs, using the ordering rule from exercise 36. Then say which single character, added where,
    would have made this survivable.

48. Braces are not POSIX. Write the portable equivalent of `mkdir -p deck-05/bay-0{1,2,3}/readings`
    that works in `dash`. Check it: `dash -c 'echo a{b,c}d'`.

## Dig

49. Read `spec/gaps.txt` again. Each of the three gaps defeats a different property of brace
    expansion. Name the property each one defeats.

50. Somebody built this station's directory trees with brace expressions — the naming is far too
    regular to be hand-typed. Given that, what does the existence of `bay-06` as a *reserved but
    unbuilt* number tell you about the order in which the spec and the tree were written?

51. Read `spec/deck-spec.txt` once more, as a document rather than a spec. It describes eight bays.
    `spec/gaps.txt` is a second file, written to correct it. Why is that a worse arrangement than one
    correct file, and what would you have to check before merging them?

52. A file called `panel-99.log` does not exist anywhere on this station. Write the command that
    would have created it as a side effect of a brace expression, using no wildcard and no explicit
    filename. Then say what you would look for on a real system to tell that file apart from one that
    had been there all along.
