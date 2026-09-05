# 05/03 — Exercises

```
cd /labs/05-globbing-and-quoting/03-quoting
```

Anything destructive goes on a copy:

```
d=$(mktemp -d); cp -a names/. "$d/"
```

**Ahead of the syllabus.** This lesson uses `grep`, which Chapter 6 teaches properly. Use it exactly
as written here; you are not expected to know it yet.

## Warmup

1. Run all three and describe, in one clause each, what stopped and what did not:
   ```
   echo '$HOME * `echo hi`'
   echo "$HOME * `echo hi`"
   echo $HOME * `echo hi`
   ```

2. `echo a\ b` and `echo "a b"` and `echo 'a b'`. All three print the same thing. How many arguments
   did `echo` receive in each case, and how would you prove it?

3. Print the exact text `it's` using single quotes only — no double quotes anywhere in the command.
   Then explain the four pieces your command is made of.

4. `cd names; ls`. Ten files. Now `ls -b`. What changed, and which of the ten made it change?

## Core — the three mechanisms

5. Print, literally, the text `$PATH is not expanded here`. Give two commands that do it, using two
   different mechanisms.

6. `v="a b"`. Predict, then run:
   ```
   printf '[%s]\n' $v
   printf '[%s]\n' "$v"
   ```
   Explain the difference in terms of arguments, not appearance.

7. Inside double quotes, four characters keep their special meaning. Name them, and demonstrate two.

8. `echo "the cost is $5"`. What happened to the `5`, and why? Now make it print `the cost is $5`
   two different ways.

9. Write a command that prints a string containing both a single and a double quote:
   `he said "it's fine"`. Do it once with single quotes as the outer quote, and once with double.

10. `echo "a   b"` and `echo a   b`. Why is the second one's output different, and which expansion is
    responsible? (It is not globbing.)

11. `echo "*"` and `echo '*'` and `echo *` in `names/`. Two of the three are identical. Say what
    double quotes and single quotes have in common here, and where they differ.

## Core — names that fight back

Work in `names/`. Nothing here needs renaming; that would be missing the point.

12. `for f in *; do printf '[%s]\n' "$f"; done`. Ten lines. Now run it again with `$f` unquoted and
    count the lines. Which files split, and into how many pieces?

13. `ls | wc -l` says 11. `ls -b | wc -l` says 10. `printf '%s\n' * | wc -l` says 11. Explain all
    three numbers. Which one is the number of files?

14. `cat deck 03 readings.txt` fails three times over. Run it, read all three errors, then write the
    version that works.

15. Write a command that prints the contents of `captain's log.txt`. Then write a second one using a
    completely different quoting mechanism.

16. `ls cost$5.txt` and `ls 'cost$5.txt'`. One works. Explain the other's error message — where did
    the `$5` go?

17. `ls a;b.txt`. Read the two things that happened. Which one is the shell and which is your
    terminal telling you something ran? Now list the file properly.

18. ``ls "back`tick.txt"`` — type it exactly, including the backtick, and see what your shell does.
    Then list the file with single quotes. What did the double-quoted version try to do?

19. `ls star*.txt` matches one file. `ls 'star*.txt'` matches the same file. Are they doing the same
    thing? Construct a test that distinguishes them. (Hint: lesson 1, exercise 32.)

20. `ls -report.txt` fails. Quote the name — `ls "-report.txt"` — and it fails identically. Explain
    why quoting cannot help here, using the word *shell* and the word *command*.

21. Now list `-report.txt` two ways that do work.

22. The file with a tab in its name: list it with a glob, then list it by typing the name. How did you
    get a literal tab into the command line? (`Ctrl-V Tab`, or `$'tab\there.txt'`.)

23. The file with a newline in its name is the reason exercise 13 has three different numbers. Write a
    command that counts the files in `names/` correctly regardless of newlines in names.

24. On a copy, run `rm *.txt`. Read the error, check what survived, and say why this is the same
    behaviour you saw in lesson 1.

25. On a copy, delete every file in `names/` with one command that handles all ten names. Say which
    part of your command handles the leading dash and which part handles the spaces.

26. Write one command that copies all ten files into a directory `dest/`, preserving names. Test it on
    a copy. Which quoting decision was load-bearing?

## Core — quoting patterns, not filenames

Work in `logs/`.

27. `grep *.log comms.log`. It prints nothing and does not error. Work out what `grep` actually
    received, and what it therefore searched for. `set -x` will settle it.

28. Find the line in `sweep.log` that mentions the pattern `*.log`. Write the `grep` that does it, and
    say why the quotes are load-bearing in two separate ways.

29. `grep "$SPEC_DIR" errors.log` — `SPEC_DIR` is unset. What does `grep` search for, and how many
    lines does it print? Why is that the most dangerous possible outcome?

30. Now find the literal text `$SPEC_DIR` in `errors.log`. Which quote did you have to use?

31. Find the line in `comms.log` containing `"outside spec"` **with** its double quotes. Write it two
    ways: single-quoted, and double-quoted with escapes.

32. Find the line in `errors.log` containing `"panel-*.log"`. The pattern contains a quote, a glob
    character and a dash. Which of those three does `grep` care about, and which does the shell?

33. Write a `grep` that finds lines mentioning either `*.txt` or `*.bak` in `sweep.log`, in one
    command. State where the quotes go and why.

34. Explain the difference between the shell's `*` and `grep`'s `*` using one line from `sweep.log` as
    the example.

## Core — command substitution

Work in `msg/`.

35. ```
    echo $(cat three.txt)
    echo "$(cat three.txt)"
    ```
    Predict, then run. Which one preserved the newlines, and what removed them in the other?

36. `echo "[$(cat spaces.txt)]"` and `echo [$(cat spaces.txt)]`. What happened to the leading and
    trailing spaces in the second?

37. Assign the contents of `note.txt` to a variable and print it with the word `says:` in front,
    preserving it exactly. Then break it deliberately by removing one pair of quotes and show what
    changed.

38. `$(…)` and backticks do the same job. Write the same command both ways, then nest one substitution
    inside another and explain why only one of the two forms is bearable.

39. Inside double quotes, command substitution still runs. Give one situation where that is exactly
    what you want, and one where it is a security problem.

## Core — fixing real scripts

Work in `scripts/`. Read before running.

40. Read `backup.sh`. Predict what it does to a directory full of ordinary names, then run it on one
    you create in `scratch/` with three tidy `.txt` files.

41. Now run it on a copy of `names/` — `d=$(mktemp -d); mkdir -p "$d/src" "$d/dst"; cp -a ../names/.
    "$d/src/"; ./backup.sh "$d/src" "$d/dst"`. Read every error. How many files ended up in `dst`?

42. `backup.sh` has quoting bugs **and** one bug that quoting will not fix. Find all of them. Name the
    non-quoting one precisely.

43. Fix `backup.sh` in `scratch/` — copy it there first — until it handles all ten names in `names/`.
    Verify: ten `.bak` files in the destination, with the original names intact.

44. Read `report.sh`. It runs without error and its output is wrong in three places. Run it as
    `./report.sh "deck 03"` and find all three.

45. One of `report.sh`'s bugs is invisible with `echo` and obvious with `printf '[%s]\n'`. Which one,
    and why does the choice of command hide it?

46. Fix `report.sh` in `scratch/`. Then state, for each of the three fixes, which of the three quoting
    mechanisms you used and why that one.

## Experiment

47. Quoting is per-character. Run:
    ```
    dir="names"
    ls "$dir"/*.txt
    ls "$dir/*.txt"
    ```
    Explain both results. Which characters were quoted in each case?

48. `set -x`, then run `cp "deck 03 readings.txt" scratch/` and `cp deck 03 readings.txt scratch/` in
    `names/`. Compare the two traces argument by argument.

49. `echo "$(echo '*')"` and `echo $(echo '*')` in `names/`. One prints an asterisk and one prints ten
    filenames. Trace where the glob got a second chance.

50. What is inside these, and what does each print?
    ```
    echo "''"
    echo '""'
    echo ""''""
    ```

51. `f='*.txt'; echo $f; echo "$f"`. The variable holds a glob. When does it get expanded, and what
    does that tell you about the order of parameter expansion and pathname expansion?

## Stretch

52. Write one command that lists every file in `names/` whose name contains a character that is
    special to the shell. Define your list of special characters first, then justify any file your
    command misses.

53. `grep -r 'sweep \*.log' .` from the lab root finds a line in `logs/comms.log`. Explain every
    character of that pattern: which are for `grep`, which are for the shell, and which are for both.

54. A script contains `find . -name *.txt`. It works in an empty directory and fails in a full one.
    Explain, then give the fix and say which quote you used.

55. Write a command that prints the exact string `'` (one single quote) and another that prints the
    exact string `\` (one backslash). Neither is as easy as it sounds.

56. You must pass the literal string `$1 "$2" '$3'` as a single argument to a script. Write the
    command line. Verify with a script that does `printf '[%s]\n' "$@"`.

## Dig

57. `logs/comms.log` records somebody being told that a threshold file had been revised and to use
    "the ones on the wall". `logs/sweep.log` records a sweep running with three patterns. Both are
    from 2187-05-30. What single question would you want answered about the wall, and what would you
    read to answer it?

58. `sweep.log` says `removed 41 files` and lists three patterns. Using only what you know from
    lessons 1 and 3, name three kinds of file that would have been in that directory and not in
    the 41. Do not guess at contents; argue from the patterns.

59. Every file in `names/` would survive a sweep for `*.log`. Only one would survive a sweep for
    `*.txt` — which, and by what mechanism? Is that mechanism a *name* property or a *command*
    property?

60. A name containing a shell metacharacter is more likely to be an accident than a plan; a name
    that is otherwise ordinary but sorts or matches unusually is more likely to be a plan. Argue
    both halves of that sentence using specific files from `names/`.
