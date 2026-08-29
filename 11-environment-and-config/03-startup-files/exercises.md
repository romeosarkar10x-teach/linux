# 11/03 — Exercises

Work in `scratch/`. Do not edit your own `~/.bashrc` in this lesson — nothing here needs it, and
the validator checks.

Set a shorthand first, because you will type the lab path a lot:

```
lab 11/03
L=$PWD
```

Every `HOME=...` below is a one-shot prefix in the sense of lesson 01: it exists for that command
and your own `HOME` is untouched.

---

## Reading the notes

1. Read `notes/startup.txt`. Write down the two questions bash asks about a shell it is starting.
2. Which of those two questions is answered by the `-l` flag, and which by `-i`?
3. From the notes alone: how many of `~/.bash_profile`, `~/.bash_login`, `~/.profile` does a login
   shell read when all three exist?
4. From the notes alone: does a login shell read `~/.bashrc`?
5. Read `notes/order.txt`. What is the technique it describes for finding out which files ran?
6. Why does that note tell you to use a different `HOME` rather than editing your own dotfiles?

## The four cases, measured

7. `ls -a homes/full`. How many files, and what are they?
8. `cat homes/full/.bash_profile`. What does each of those files do?
9. Run `HOME=$L/homes/full bash -l -c true`. Which markers appear?
10. Was that answer the same as your prediction in exercise 3?
11. Run `HOME=$L/homes/full bash -i -c true`. Which markers appear now?
12. Run `HOME=$L/homes/full bash -c true`. Which markers appear? Explain the result in one sentence.
13. Run `echo exit | HOME=$L/homes/full bash -li`. You should see two markers. Which, and why two?
14. Run `HOME=$L/homes/full bash -li -c true`. `.bash_logout` does **not** appear. Compare with
    exercise 13 and say what is different about the shell in each.
15. Make a table of the four cases and the files each reads. Keep it; you will check it in
    exercise 55.

## First match wins, again

16. `mv homes/full/.bash_profile scratch/` — no, do not. Copy the whole directory instead:
    `cp -a homes/full scratch/full` and work there. Why does this lesson keep insisting on copies?
17. In `scratch/full`, remove `.bash_profile` and run the login shell again. Which marker now?
18. Remove `.bash_login` too and run it again. Which marker now?
19. Remove `.profile` as well and run it again. What happens, and is it an error?
20. Put all three back (`cp -a` from `homes/full` again). In one sentence: what does "first match
    wins" mean for login files, and where have you seen those three words before in this chapter?
21. Someone creates a `~/.bash_profile` containing one line, to set one variable. What happens to
    everything that was in their `~/.profile`?
22. That is the single most common way people lose their configuration. Why is it so hard to notice?

## The station's arrangement

23. `cat homes/station/.profile`. Which of the three login files is this, and why does it get read?
24. Find the lines in it that source `~/.bashrc`. Quote them. Are they machinery, or a decision?
25. Run `HOME=$L/homes/station bash -l -c 'type -t station-status'`. What does it print, and which
    file defined it?
26. Run `HOME=$L/homes/station bash -l -c 'echo $STATION_ROLE'`. Which file set that?
27. Run `HOME=$L/homes/station bash --noprofile -l -c 'echo [$STATION_ROLE]'`. Explain the output.
28. Now run `HOME=$L/homes/station bash -l --noprofile -c true`. Read the error. Which part of your
    command is it actually complaining about?
29. `stat -c '%y' homes/station/.bashrc`. When was it last modified? Keep this; exercise 51 needs it.
30. `HOME=$L/homes/station bash -l -c 'alias'` lists `decks`. But
    `HOME=$L/homes/station bash -l -c 'type decks'` says not found. Both are true. Run
    `HOME=$L/homes/station bash -l -c 'shopt expand_aliases'` and explain the contradiction.
31. Run the same `type decks` with `shopt -s expand_aliases;` in front of it. Now what?
32. `station-status` is a function and `decks` is an alias, defined in the same file, in the same
    shell. One works and one does not. Which property of that shell decides it?
33. What does that tell you about putting aliases in a file that scripts will source?

## The complaint

34. `cat homes/split/.bash_profile` and `cat homes/split/.profile`. Predict which one a login shell
    reads before running anything.
35. Run `HOME=$L/homes/split bash -l -c true`. Were you right?
36. Does the login shell in `split/` have the `decks` alias defined at all? Check with `alias`.
37. Run `HOME=$L/homes/split bash -i -c alias` and compare. Where does the alias exist and where does
    it not?
38. Explain, in two sentences, why this account's aliases work in some terminals and not others.
39. Nothing in `split/` is broken, misspelled, or corrupt. Which single file's *existence* causes the
    whole effect?
40. Go back to `../02-path/notes/page.txt` — cass got three lines, rhea got four, thirty seconds
    apart. Give a configuration in `split/`'s shape that would produce exactly that.
41. Read `notes/page.txt`. rhea says her function stopped working and that she changed nothing. Take
    her claim seriously: what could change about *the terminal she opened* without any file changing?
42. Name two ways a terminal could start a non-login shell where it used to start a login one.
43. She says she does not want the fix, she wants the difference. Why is that the more useful thing
    to ask for?

## Breaking it on purpose

44. In `scratch/`, make a home directory whose `.profile` runs `exit 1`. Log into it. What happens?
45. Make one whose `.profile` contains `read -p "who are you? " name`. Try
    `HOME=... bash -l -c true`. What does a startup file that waits for input do to an automated
    login?
46. Make one whose `.profile` contains a typo — `ecoh hello`. Does the login fail, or continue?
47. Given 44 and 46: which kind of mistake in a startup file is more dangerous, the loud one or the
    quiet one?
48. Recover from 44 without deleting the file: start a shell with `--noprofile` and fix it from
    there. Write down the command you used.
49. Why is `--noprofile` the thing to reach for, rather than deleting the home directory?

## BASH_ENV, source, and reload

50. `echo 'echo "read: BASH_ENV file"' > scratch/envfile`. Run
    `BASH_ENV=$L/scratch/envfile bash -c true`. What happens? Compare with exercise 12.
51. Run `BASH_ENV=$L/scratch/envfile HOME=$L/homes/full bash -i -c true`. Does the `BASH_ENV` file
    run? Which case is it for?
52. A cron-style job runs `bash script.sh` and the script mysteriously has extra settings. `BASH_ENV`
    is one explanation. How would you check?
53. In your own shell, run `alias zz='echo hi'`, then `source ~/.bashrc`, then `alias zz`. Is `zz`
    still there? What does that tell you about "reloading" a configuration?
54. Contrast `source ~/.bashrc` with logging out and back in. Name one thing the first cannot undo.

## Debrief

55. Recite your table from exercise 15 from memory, then check it. Which row did you get wrong, if
    any, and why that one?
56. In one sentence each: what is `~/.bashrc` for, and what is `~/.profile` for?
57. Somebody asks you to "add this line to my bashrc so it's set everywhere." Give the one-sentence
    reason that is not quite true, and say where the line should go instead.
58. Write the answer to rhea's page: not a fix, a statement of what is different about the two
    terminals and how she could tell which kind she is in.
