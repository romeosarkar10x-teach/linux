# 12/01 — exercises

Lab: `/labs/12-shell-scripting/01-first-script`. Work in `scratch/` unless told
otherwise. Nothing here needs root.

## A. Reading a script before running it (1–7)

1. `cd` into the lab and list it. Name the four directories and say, from the
   names alone, which one you would read first in an incident.
2. `cat bin/deck-count.sh`. What is its first line, and what will the kernel do
   with it?
3. `cat ops/tidy.sh`. What does it claim to do, and what does it actually do?
4. `cat notes/page.txt`. What did ops-bot conclude, and from what evidence?
5. `ls -l bin/` — which of those files are executable, and by whom?
6. `ls -l broken/` — one of the five has a different mode. Which, and what will
   that cost you?
7. `head -c 2 bin/greet | od -c`. Show the first two bytes. Why does the kernel
   care about exactly these two?

## B. Three ways to run one file (8–17)

8. Run `bin/deck-count.sh` with `./bin/deck-count.sh`. What does it print?
9. Run the same file with `bash bin/deck-count.sh`. Same output?
10. Run it with `sh bin/deck-count.sh`. Same output? Why is that not luck?
11. Make `scratch/setter.sh` containing one line: `DECK=alpha`. Run it with
    `bash scratch/setter.sh`, then `echo "[$DECK]"`. Explain the result.
12. Now run it with `. scratch/setter.sh` and echo `DECK` again. Explain the
    difference in terms of processes.
13. Does `. scratch/setter.sh` need the exec bit? Prove it.
14. Add `cd /tmp` to `scratch/setter.sh`. Run it with `bash`, then `pwd`. Then
    source it, then `pwd`. Account for both.
15. `unset DECK` and re-run the sourced version — what does that tell you about
    which shell the assignment happened in?
16. Write in one sentence the rule for when to source a file and when to execute
    it. Give one real example of each from Chapter 11.
17. `bash -c 'bash scratch/setter.sh; echo "[$DECK]"'` — predict before running.

## C. The exec bit (18–24)

18. Run `./broken/no-bit.sh`. Quote the error exactly and the exit status.
19. Run the same file with `bash broken/no-bit.sh`. Explain why one works.
20. `ls -l broken/no-bit.sh`. Which of the nine bits is missing?
21. Copy it to `scratch/`, `chmod +x` the copy, and run it. (Do not modify the
    original — later exercises use it broken.)
22. `chmod 700` the copy, then run it. Still works? Now `chmod 600` and run it.
    Which triad did the kernel check, and why that one?
23. What exit status does a permission failure give? Memorise it.
24. `./bin` — run a *directory* as a command. Quote the error and the status.
    Is it the same status as 23? Why does that make sense?

## D. Shebang failures, one at a time (25–36)

For each: predict the error, run it, quote the exact message and status, and
name the cause in one sentence.

25. `./broken/bad-interpreter.sh`
26. Now `bash broken/bad-interpreter.sh`. Why does it work? What does that tell
    you about who reads the shebang?
27. `head -1 broken/bad-interpreter.sh`, then `ls -l /usr/local/bin/bash`. Fix a
    copy in `scratch/` by editing only the first line.
28. `./broken/crlf.sh`. The error names something with a `\r` in it. What is the
    interpreter's name, as the kernel sees it?
29. Prove the line endings with `cat -A broken/crlf.sh`. Which character is the
    problem, and where is it?
30. Fix a copy in `scratch/` with `tr -d '\r'` and run it.
31. `./broken/wrong-shell.sh`. Quote the error. Which line number, and which
    character does it name?
32. `head -1 broken/wrong-shell.sh` and `ls -l /bin/sh`. What is `sh`, really,
    on this station?
33. Run `bash broken/wrong-shell.sh` — it works. Explain both results together
    in one sentence about who the shebang chose.
34. `./broken/no-shebang.sh` — it works. Explain why, given there is no first
    line to read.
35. Write `scratch/ns.sh` with **no shebang**, an exec bit, and two lines:
    `decks=(a b)` and `echo "[${decks[1]}][$BASH_VERSION]"`. Run it with
    `./scratch/ns.sh`. Now run it with
    `find scratch -name ns.sh -exec {} \;`. The results differ. Name the two
    different interpreters, and say which one is *not* your shell's choice.
36. Rank the five broken scripts from "fails loudest" to "fails most quietly".
    Defend the last place.

## E. Exit status (37–45)

37. `bin/exit-three`; then `echo $?`. Why did the last `echo` in the file not
    print?
38. `bin/last-command-wins`; then `echo $?`. Which command supplied that status?
39. Add `echo done` as a new last line of a copy of `last-command-wins` in
    `scratch/`. Re-run and check `$?`. What did adding a line change?
40. That is the whole bug from Chapter 11 lesson 05, in three lines. Write it
    out as a sentence a colleague would understand.
41. Run `ops/tidy.sh; echo $?`. What status does it give? Is that status a claim
    about anything?
42. Write `scratch/status.sh` that runs `ls /nope` and nothing else. What is its
    status? Where did the error text go?
43. Make it exit `0` on purpose, keeping the failing command. Two ways.
44. Make a script exit with the status of a command from the *middle* of the
    file, not the end. Show your work.
45. `if ./bin/exit-three; then echo yes; else echo no; fi` — predict, then run.
    Which status counts as true?

## F. Writing your own (46–56)

46. Write `scratch/decks.sh` from scratch: shebang, one comment saying why it
    exists, and `wc -l < ops/decks`. Make it executable and run it from the lab
    root.
47. Run it from `/tmp`. It breaks. Why?
48. Fix it so it works from anywhere, without hardcoding a path into the
    command. (Hint: the path can be a variable at the top.)
49. Add an `exit` line so that it exits `4` if `ops/decks` does not exist.
    Test both branches by renaming the file temporarily.
50. Write `scratch/hello` — no `.sh` extension, executable. Does it run? What
    does that say about extensions on this system?
51. `file scratch/hello` and `file ops/decks`. What is `file` looking at, given
    it does not run either?
52. Put `scratch/` on your `PATH` for this shell only, then run `hello` by bare
    name from `/tmp`. Then remove it from `PATH` again.
53. `.` is not on your `PATH`. Prove it, then say in one sentence why leaving it
    off is a security decision and not an inconvenience.
54. Write `scratch/two-shebang.sh` with `#!/bin/sh` on line 1 and
    `#!/bin/bash` on line 2. Which wins? Prove it with `echo "$BASH_VERSION"`.
55. Make a script whose shebang is `#!/bin/cat`. Run it. Explain the output
    exactly.
56. Write the shortest script you can that exits `1` and prints nothing. Then
    the shortest that exits `0` and prints nothing.

## G. Judgement (57–60)

57. `ops/tidy.sh` is dated 2186-01-11 and ops-bot reports it as fine. State
    precisely what evidence "exit status 0" is, and what it is not.
58. You are asked to add one line to `ops/tidy.sh` so its report can be
    believed. What line, and where? Do not edit the file — write the answer.
59. Someone hands you a script that "works on their machine" and fails here with
    status 127. List, in order, the three things you check.
60. Write two comments for `bin/deck-count.sh`: one useless, one useful. Say
    what makes the difference.
