# 05/04 — Exercises

```
cd /labs/05-globbing-and-quoting/04-word-splitting
```

`scripts/count.sh` prints the number of arguments it got, then each one in brackets. It is the
instrument for this whole lesson. Run it whenever you are not sure.

Stuck? `help.md`. Wrecked the lab? `kestrel reset 05/04`.

**Ahead of the syllabus.** This lesson uses `find` (Chapter 6), `cut` and `xargs` (Chapter 7) before
the chapters that teach them. Use them exactly as written here; you are not expected to know them
yet.

## Warmup — seeing the split

1. Print the value of `IFS` in a way that shows you the invisible characters. (`printf '%q\n'` is
   one way; `echo "$IFS" | cat -A` is another.) What are the three characters?

2. `v='a  b'` (two spaces). Run `bash scripts/count.sh $v` and then
   `bash scripts/count.sh "$v"`. How many arguments each time, and where did the second space go?

3. Same variable. Run `bash scripts/count.sh $v` under `set -x`. What does the trace line show, and
   how does bash indicate the argument boundaries?

4. `echo a   b` prints one space between the letters. Explain that in terms of splitting and of
   what `echo` does with the arguments it receives.

5. `w=$v` with `v='a  b'`. Print `"$w"`. Both spaces are there. Why was no quoting needed on the
   right of the `=`?

## Core — IFS mechanics

6. Set `IFS=:` in a subshell and run `set -- a:b:c; echo $#`. Now do the same with the string
   `a:::b`. How many fields? Explain the difference from the space case in exercise 2.

7. State the rule the last exercise demonstrated in one sentence: what is different about
   whitespace characters in `IFS`.

8. With `IFS=:`, split `a:b:` (trailing colon). How many fields? Is the trailing empty field kept?

9. Set `IFS=` (empty) and run `bash scripts/count.sh $v` with `v='a  b'`. What happens to splitting?

10. Set `IFS=,` and then split `'a b c'`. How many arguments? What did the space do?

11. `unset IFS`, then split `'a  b'`. How does the shell behave with `IFS` unset, and how is that
    different from `IFS=`?

## Core — whitespace that lies

12. `wc -w < data/spaced.txt` gives a number. Now `set -- $(cat data/spaced.txt); echo $#`. Do they
    agree? Should they?

13. `data/spaced.txt` line 1 is `  leading and trailing  `. Read it with `read -r l` and print
    `"$l"` in brackets. Where did the leading spaces go?

14. Read the same line with `IFS= read -r l`. Now what?

15. Explain what `read` does with leading and trailing `IFS` whitespace, and why `IFS=` in front of
    it is the fix rather than `-r`.

16. Line 1 of `data/bad-line.txt` ends in a backslash. Read it with `read -r l` and then with
    `read l`. Print both. What did the second one do to the *next* line?

17. From 16: state what `-r` does, in terms of what `read` would otherwise treat as special.

18. `data/spaced.txt` has a tab-separated line. Split it with the default `IFS` and count the
    fields. Now with `IFS=$'\t'`. Same answer? Try a line with two adjacent tabs in `scratch/` to
    make the difference show.

19. Write the three-part correct line-reading loop from the readme and use it to count the lines of
    `data/spaced.txt`. Name what each of the three parts is protecting against.

## Core — fields and records

20. `head -1 data/crew.csv` is `rhea:systems:deck-05:2187-04-02`. Split it into four variables with
    one `read`. Print each in brackets.

21. Do it with only three variables. What ends up in the third one, and what is the rule?

22. Do it with five variables. What is in the fifth?

23. Read the whole of `data/crew.csv` with a `while IFS=: read -r …` loop and print each crew
    member's name and deck, one per line.

24. Get the same deck list with `cut`. Which of the two would you rather have in a script that has
    to do something else with the name at the same time, and why?

25. Print the crew who are on `deck-05`. Do it in the loop, not with `grep`.

26. Add a line to a copy of `crew.csv` in `scratch/` with an empty second field
    (`nils::deck-03:2187-06-01`). Read it with your loop. Does the empty field stay in the right
    position? Why does that work when the space case in exercise 2 collapsed?

27. Add a line whose *last* field contains a colon. Does your loop still parse it correctly? Which
    field absorbs the extra colon, and is that the behaviour you want?

28. Read `data/crew.csv` into an array of lines with `mapfile -t`. How many elements? Print the
    third.

29. Split one line into an array with `IFS=: read -ra parts`. Print `"${parts[@]}"` through
    `count.sh`. How many arguments?

## Core — `$@`, `$*` and arrays

30. Write a script in `scratch/` that calls `count.sh` four times: with `"$@"`, `$@`, `"$*"` and
    `$*`. Run it with the two arguments `'a b'` and `c`. Record the four argument counts.

31. Which of the four preserved the original argument boundaries? Which is the only one you should
    ever write?

32. `"$*"` joined the arguments with a character. Which one? Prove it by setting `IFS=:` before the
    `echo "$*"` and running it again.

33. `arr=('bay 01' 'bay 02')`. Pass `"${arr[@]}"`, `${arr[@]}` and `"${arr[*]}"` to `count.sh`.
    Three different answers. Explain each.

34. State the relationship between `"$@"` and `"${arr[@]}"` in one sentence.

35. Pass an empty string as an argument: `bash scripts/count.sh "" x ""`. Now try to pass an unset
    variable the same way, unquoted. What is the argument count each time?

## Core — loops over things with spaces

36. `for d in bays/*/; do printf '[%s]\n' "$d"; done | wc -l`. How many? Now
    `for d in $(ls bays); do …; done | wc -l`. How many? Explain the difference.

37. Three of the `bays/` directories have spaces in their names. Which iteration approach handled
    them and which did not — and note that the glob needed no quoting *in the `for` list* but the
    `"$d"` inside did.

38. Count the lines of `readings.txt` in every bay, printing the bay name and count. Get it right
    for all eight.

39. `for p in $(cat data/paths.txt); do …; done` — how many iterations for a five-line file? Where
    did the extra ones come from? (There are two separate causes; find both.)

40. Redo it with `while IFS= read -r p`. Five. Confirm the two paths with spaces came through whole.

41. `IFS=$'\n'` then `set -- $(cat data/paths.txt); echo $#`. Five as well. What is this approach
    still vulnerable to that the `while read` loop is not?

42. Pipe `find bays -mindepth 1 -maxdepth 1 -type d` into `xargs -n1 echo | wc -l`, then do it with
    `-print0` and `xargs -0`. Two different numbers. Which is right, and what is `-print0` doing?

## Core — fixing real scripts

43. Read `scripts/tally.sh`. Predict what `bash scripts/tally.sh 'bay 01' bay-02` prints before you
    run it. Then run it.

44. Fix `tally.sh` with a one-character-class change. Verify.

45. Read `scripts/deploy.sh`. It copies each path named on stdin into `$1`. Predict what happens
    when you feed it `data/paths.txt`.

46. Run it: `mkdir -p scratch/dst && bash scripts/deploy.sh scratch/dst < data/paths.txt`. Record
    the errors and how many things landed in `scratch/dst`.

47. Name every bug in `deploy.sh`. There are four things worth changing and one of them is not about
    quoting.

48. Fix it. Verify by feeding it `data/paths.txt` again into a clean destination and checking that
    the two space-containing paths are attempted as single paths. (They still will not exist — that
    is fine, the error message is the proof.)

49. `deploy.sh` uses `cp -r $line $DEST/`. Even fully quoted, what would still go wrong if a path in
    the list began with a dash? What is the fix, and which lesson was it from?

## Experiment

50. `[ $v = 'a b' ]` with `v='a b'`. What is the error and the exit status? Now with `v` unset. A
    *different* error — what and why? Now with `"$v"` in both cases.

51. Do the same three comparisons with `[[ ]]` instead of `[ ]`. All three behave. What is
    `[[ ]]` doing that `[ ]` cannot, and why can it?

52. `v='1 + 2'; echo $(( v ))`. It prints 3. No quoting, a string full of spaces, and it worked.
    Explain.

53. `case $v in 'a b') …` works unquoted too. Add `case` and `[[ ]]` and `$(( ))` to a list of
    contexts where splitting does not happen, and check the assignment case from exercise 5 is on
    it.

54. Set `IFS=:` inside `( … )` and print `IFS` inside and after. Now do it inside a function with
    `local IFS=:`. Now do it with a bare `IFS=:` at the top of a function and no `local`. Which of
    the three leak?

55. `printf '[%s]\n' "$@"` with no arguments set. How many lines does it print, and why is that
    number surprising? (This is a `printf` fact, not a splitting fact — say which.)

## Stretch

56. `printf 'one\ntwo' > scratch/nonl.txt` — no final newline. Count its lines with a
    `while IFS= read -r` loop. You will be one short. Fix the loop so it gets both lines, and
    explain what `read` returns on the last, newline-less line.

57. Read NUL-separated input: `printf 'a\0b\0' | while IFS= read -r -d '' x; do …; done`. What does
    `-d ''` mean, and why is this the only fully safe way to read a list of filenames?

58. Build a pipeline that lists every `bays/` subdirectory containing a `readings.txt` with more
    than one line, correct for names with spaces, using `find -print0`.

59. Write one line that reports the number of *words* and the number of *fields under `IFS=:`* in
    the string `a b:c d:e`. They differ; say why in terms of which separator was in force.

60. Explain, using the expansion order, why `v='* x'; bash scripts/count.sh $v` gives more arguments
    in a directory containing files than in an empty one — and why `"$v"` gives one everywhere.

## Dig

61. `data/paths.txt` names two directories under `/labs/deck 05/` that do not exist on this station.
    Everything else in the file is real. What kind of mistake produces a path list with entries
    that were never valid, and what does it tell you about how the list was assembled?

62. `deploy.sh` and `tally.sh` were both written by somebody in a hurry. One of them fails loudly
    and one of them fails quietly. Which is which, and which would you rather have found in a
    production script at three in the morning?

63. Take `data/paths.txt` and `05/01`'s `spec/sweep-notes.txt` together. If a sweep were driven by
    a path list built the way `deploy.sh` reads one, which entries would it have operated on and
    which would it have silently skipped? Write the answer as two lists.

64. A file named `deck 05` — with a space — is the reason two entries in `paths.txt` explode into
    six words. Nothing on this station is *supposed* to have a space in its name. Look at
    `bays/` and say whether that rule is being followed here, and what it would take to find out
    when it stopped being followed.
