# Exercises — Remediation

Work in `/labs/15-capstone-kestrel-breach/04-remediation`. You will need `sudo`
in this lesson, for the first time in the chapter. Every change gets a record
in `case/` — six fields, no exceptions.

## A. Survey before you touch

1. `cd` into the lab and run `./bin/postcheck`. How many checks fail? What is
   its exit status?
2. Read `bin/postcheck`. For each check, name the single piece of system state
   it inspects.
3. Which of the six checks could pass while the underlying problem is still
   present? Name it and say how.
4. `stat -c '%a %U:%G %n'` every directory in the lab. Which two have modes you
   would question?
5. `find . -perm -4000` and `find . -perm -2000`. What did each find?
6. List every file not owned by you. Which account owns most of them?
7. Before changing anything, record the current state: write the output of
   `postcheck`, `find . -perm -4000`, and your `stat` survey into
   `case/notes/before.txt`.

## B. Close

8. `grep -rn 'trusted=yes' eng/repo.d/`. Which file, which line?
9. Read `eng/repo.d/README.txt`. In one sentence, what does `trusted=yes`
   switch off?
10. Two sources are configured. What is different about the other one, and does
    it have the same problem?
11. Remove the offending source. You have at least three options: delete the
    file, delete the line, or comment the line out. Pick one and justify it in
    your record.
12. Prove it: a command that returns nothing and exits non-zero.
13. Removing the source stops future installs from it. What does it *not* undo?
    Write that down as an open item rather than fixing it.
14. `stat -c '%a %U:%G %n' station/var`. What are the four digits, one at a
    time?
15. Which of the four is the actual problem here, and which one would you keep?
16. Fix the mode with a symbolic `chmod` that removes write access from others
    and leaves everything else alone. Do not use an octal mode.
17. Confirm the sticky bit survived your change. If it did not, you used octal.
18. Why does removing world-write from this directory not remove the files
    already in it, and who can still delete them?
19. `find . -perm -4000` again — you still have one. Whose is it, and what is
    its mode in full?
20. Read `bin/eng-scan`. It prints its real and effective uid. Run it and read
    that first line.
21. It is setuid root. The effective uid it prints is yours. Explain the
    contradiction before reading on.
22. The answer is that Linux ignores the setuid bit on scripts — anything
    starting `#!`. Look up why in one sentence of your own words, then say
    whether that makes this file harmless.
23. Clear the setuid bit. You will need `sudo`, and the file is not yours.
24. Prove it, and confirm `postcheck`'s setuid check now passes.

## C. Fix

25. `diff backup/strain-summary.orig station/summariser/strain-summary`. State
    the behavioural difference in one sentence.
26. Run the live summariser over `station/var/raw-sample.txt`, discarding
    stderr. Which cycles report a value different from their raw value?
27. Run it again, keeping only stderr. How many lines, and what do they tell
    you that stdout did not?
28. Run `backup/strain-summary.orig` over the same input. What is the true peak
    across the ten cycles?
29. Compute the true mean and the number of raw values above 6.0. Show the
    command.
30. Now read `station/var/deck3-report.txt`. Compare its three numbers against
    both runs. Which run produced that report?
31. That is the most important observation in the lesson. Write it as a
    change-record `why` field, in one sentence, naming no person.
32. Restore the correct summariser from the backup. Which direction does the
    `cp` go, and what happens if you get it backwards?
33. Verify with `diff`. What is the exit status of a `diff` that finds nothing?
34. Should you preserve the backup's mtime on the restored file with `cp -p`?
    Argue both sides in two sentences, then decide.
35. `grep -rn STRAIN_TOLERANCE .`. Which two files, and what is the
    relationship between them?
36. Now that the summariser no longer reads that variable, is the export in
    `home/ops-bot/.bashrc` still a problem? Answer before removing it.
37. Remove the export. `postcheck` should now pass that check.
38. `home/ops-bot/.bashrc` belongs to an account with a `nologin` shell. Say
    what would have to be true for that file to be read at all. Lesson 02 has
    the answer.

## D. Stop

39. Start the loop: `./station/summariser/loop &`. Confirm it is running with
    `pgrep -af summariser/loop`.
40. Watch `station/var/summary.log` grow. Which summariser is it running —
    the clamping one or the restored one? Justify from the output.
41. Now suppose you had *not* restored the file first, and had edited it while
    this loop was running. Would the output change? Explain in terms of when a
    program reads its own file.
42. Stop it with `pkill -f summariser/loop`. Which signal did that send by
    default?
43. Confirm it is gone, and that `postcheck`'s last check passes.
44. When would `pkill -9` have been the wrong choice here? Refer to lesson 02.

## E. Restore and prove

45. Regenerate `station/var/deck3-report.txt` from `raw-sample.txt` using the
    restored summariser. Keep the same three fields.
46. What are the three new numbers?
47. Write the change record for that regeneration. The `reversible` field is
    the interesting one — is it?
48. Run `./bin/postcheck`. All six should pass, exit 0.
49. Now break one thing back — re-add the export to `.bashrc` — and confirm
    `postcheck` catches it. Then remove it again. Why is testing your test
    worth the sixty seconds?
50. Count your change records. There should be one per change, and each
    `verified by` field must contain a command you actually ran.

## F. Stretch

51. `postcheck` cannot tell whether the regenerated report is correct. Write
    `bin/report-check` — takes the raw sample and the report, recomputes the
    three numbers, and exits non-zero if any disagree.
52. Write a one-line command that lists every setuid and setgid file under
    `/labs`, with owner and mode, sorted by owner.
53. `chmod g+rwX` versus `chmod g+rwx` on a tree containing both files and
    directories. Demonstrate the difference on a copy, and say which you want
    and why.
54. There is one fault in this lab you were told to record rather than fix
    (exercise 13). Write the two-sentence brief you would hand to whoever *can*
    fix it: what to do, and how they would verify it.

## G. Dig

55. Linux ignores setuid on `#!` scripts, but the setuid bit on a *binary* is
    honoured. Without creating one, explain what an attacker gains from a
    setuid-root copy of a program that can run arbitrary commands, and name one
    such program that is commonly found in real audits.
56. Your `postcheck` run exits 0. Write down, in three bullets, what a green
    run still does not establish about this system.
