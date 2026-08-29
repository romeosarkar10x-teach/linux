# 10/06 — Exercises

Work in `/labs/10-users-groups-permissions/06-chown-chgrp-umask`. Use `sudo` only where an exercise
says to. Never `chown` anything outside this lab.

---

## Reading the two columns

1. `ls -l intake`. Name the owner and group of each of the three files.

2. `stat -c '%U %G %u %g %n' intake/*.raw`. What do you get that `ls -l` did not?

3. One of the three prints something unusual in the first two fields. Which, and what does it print?

4. `ls -l` printed a *number* where it printed names for the others. Why? Is that a property of the
   file or of something else?

5. `getent passwd 4102` and `getent group 4102`. What comes back? Reconcile that with the file
   existing.

6. `stat -c '%U' intake/unclaimed.raw` says `UNKNOWN` while `ls -l` says `4102`. Both are honest.
   Which one would you rather see in a script, and why?

7. Write down everything you can establish about `intake/unclaimed.raw` from the file alone. Then
   write down three things you *cannot*. rhea asked for the first list; the second list is why she
   asked.

---

## chown is root's

8. `chown cadet intake/cycle-41.raw`. What is the error, exactly?

9. You own `handoff/week-24.txt`. Try to give it away: `chown rhea handoff/week-24.txt`. Predict
   first.

10. Both failed. State the rule in one sentence.

11. You cannot `chmod` your way out of this. Explain why not, in terms of where the owner is stored
    and what the nine bits describe.

12. Give one concrete reason a system might refuse to let users give files away. (Disk quotas are one.
    There is a second, and it involves a program that runs as its owner — you met the idea in lesson
    04 exercise 39 and will meet the mechanism in lesson 08.)

13. `sudo chown cadet:crew intake/unclaimed.raw`. Check it. Then put it back with
    `sudo chown 4102:4102 intake/unclaimed.raw` and verify with `stat`.

14. That worked with a number for which no account exists. What does that tell you about what the
    file actually stores?

15. `sudo chown nosuchuser scratch/README`. What is the error, and how is it different in kind from
    the one in exercise 14?

---

## chgrp is usually yours

16. `stat -c '%U %G %n' handoff/*.txt` and `stat -c '%U %G %a %n' handoff`. Note the mismatch between
    the directory's group and the files'.

17. `id`. Which groups are you in?

18. `chgrp crew handoff/week-24.txt`. Predict, then run, then check.

19. `chgrp shadow handoff/week-25.txt`. Predict, then run. What is the error?

20. You own `week-25.txt` and the command still failed. State the rule for `chgrp` precisely — it has
    two halves.

21. So `chgrp` cannot give you access you did not have. Explain in one sentence why that is the right
    design.

22. `chgrp crew intake/cycle-42.raw` — a file in a group you *are* in, that you do not own. Predict,
    run, explain.

23. Fix the rest of `handoff/` so every file in it is group `crew`. One command.

24. `handoff/*.txt` is `640`. Now that the group is `crew`, say precisely what changed for another
    crew member — and what did not.

25. Read rhea's second paragraph in `notes/page.txt`. She says the files come out with the wrong
    group and asks you to work out *why* before fixing them one at a time. Answer her: create
    `handoff/probe.txt` with `touch` and check its group. Where did that group come from — the
    directory, or you?

26. Confirm it: `sg crew -c 'touch handoff/probe2.txt'` and check the group. What did `sg` change?

27. So the default group of a new file comes from the creating **process**, not the containing
    directory. Is there any way to make the directory decide? Guess, note the lesson number you
    expect, and move on. (`notes/ownership.txt` does not tell you; lesson 08 does.)

28. Clean up: `rm handoff/probe.txt handoff/probe2.txt`.

---

## The colon forms

Use `scratch/` for these. `cp notes/umask.txt scratch/colon` first.

29. `chgrp crew scratch/colon` and `chown :crew scratch/colon`. Are they the same command? Check the
    manual claim in `notes/ownership.txt` against what you observe.

30. `chown cadet: scratch/colon`. What group is it now, and where did that group come from?

31. Write down what each of these four would do, before running any of them:
    `chown cadet scratch/colon`, `chown cadet:crew scratch/colon`, `chown :crew scratch/colon`,
    `chown cadet: scratch/colon`. Which of the four leaves the group alone?

32. Run them and correct your table where you were wrong.

33. `chown --reference=handoff/rota.txt scratch/colon`. What did it copy — one column or two? Check
    both.

34. When is `--reference` the right tool for ownership? Give a case where typing the names would be
    worse.

35. `chown -c cadet:crew scratch/colon` twice in a row. What does the second run print?

---

## Recursion and symlinks

36. `find mixed -printf '%u %g %M %p\n' | sort`. How many distinct groups are in the tree, and which
    entry is not a regular file or directory?

37. `ls -l mixed/data/raw-link` — where does it point, and is the target inside `mixed/`?

38. Predict: `chgrp -R crew mixed`. What happens to `mixed/data/raw-link`, and what happens to
    `intake/cycle-41.raw`?

39. Run it and check both. Was your prediction right?

40. Compare with lesson 05: `chmod 600 scratch/link` changed the *target*. `chgrp -R` changed the
    *link*. State the three behaviours — `chmod`, `chgrp` without `-R`, `chgrp -R` — as three lines.

41. Test the middle one directly. `ln -s ../intake/cycle-41.raw scratch/L`, then `chgrp crew
    scratch/L`. Predict first. What is the error, and *whose* permissions produced it?

42. `stat -c '%U %G %n' scratch/L` says the link is yours, and the command still failed. Explain.

43. `echo x > scratch/t; ln -s t scratch/Lt; chgrp -h crew scratch/Lt`. Check the group of both
    `scratch/Lt` and `scratch/t`. What did `-h` do?

44. A symlink has its own owner and group and they are almost never consulted. Name the one situation
    in this exercise set where they were.

45. Reseed is not available to you mid-lesson, so put `mixed` back by hand: every entry group
    `cadet`, except `mixed/logs/beta.log` (`ops`) and `mixed/data/counts.csv` (`crew`). Write the
    commands.

---

## umask

46. `umask`. Then `umask -S`. The two numbers look unrelated. Explain the relationship — and note
    which one lists what is *allowed* and which lists what is *removed*.

47. `touch scratch/plain; stat -c '%a' scratch/plain`. `mkdir scratch/pdir; stat -c '%a' scratch/pdir`.
    Two different results from the same mask. Why?

48. Read `notes/umask.txt`. Write the arithmetic out for both, in binary or octal, showing the
    requested mode and the mask.

49. Why does `touch` never create an executable file? Answer without using the word "strips".

50. `(umask 077; touch scratch/u1; mkdir scratch/d1)` — the parentheses matter. Predict both modes,
    then check.

51. `(umask 002; touch scratch/u2; mkdir scratch/d2)`. Predict, check.

52. `(umask 000; touch scratch/u3; mkdir scratch/d3)`. Predict, check. Is this "no permissions" or
    "all permissions"? This is the reversal that catches everybody.

53. After all three subshells, run `umask` in your shell. What is it, and why?

54. Now `umask 077` *without* parentheses, create a file, then `umask 022` again. What is the smallest
    accurate description of what you just changed?

55. Does `umask 077` change any file that already exists? Prove it with one command on a file you
    made in exercise 47.

56. `(umask 077; mkdir -m 755 scratch/d4)`. Predict, check. What does `-m` do to the arithmetic?

57. `(umask 077; touch scratch/u5; chmod 644 scratch/u5)`. What is the mode? What does that tell you
    about the order of operations?

58. `umask u=rwx,g=rx,o=` — the symbolic form. Run `umask` afterwards to see the number. Which number
    is it, and did you predict it?

59. Write the umask you would set for: (a) a shared project directory where the whole group edits
    everything; (b) a directory holding credentials. Give the number and the resulting file mode for
    each.

60. `cp notes/umask.txt scratch/c1; stat -c '%a %U %G' scratch/c1` and then
    `cp -p intake/cycle-42.raw scratch/c2; stat -c '%a %U %G' scratch/c2`. Two different results.
    What does `-p` preserve, and — look carefully at the *owner* of `c2` — what did it fail to
    preserve, and why was that inevitable?

---

## Finding things by owner

61. `find . -user root`. What comes back?

62. `find . -nouser`. What is `-nouser` actually testing? (It is not "owned by nobody".)

63. `find . -group crew -type f`. Then the same with `-gid 1001`. Same answer? When would they differ?

64. Write one command that lists every file under `/labs` not owned by you. (Chapter 6 gave you
    `find`; `-not` and `!` both work.)

65. Write one command that reports, for every file in `intake/`, the owner name, the numeric uid and
    the mtime, one line each, sorted by uid.

---

## Judgement

66. rhea's page asks two things. Write her reply: one paragraph on `unclaimed.raw` that establishes
    only what the file supports, and one on the `handoff/` group, naming the mechanism rather than the
    workaround.

67. Somebody proposes fixing the `handoff/` group problem by running `chgrp -R crew handoff` in a
    loop from a scheduled job. Give two reasons that is the wrong fix, one of them about what happens
    to files created between runs.

68. Write a function `owned-by USER PATH` that prints every file under `PATH` owned by `USER`, with
    its mode, and exits 1 with a clear message if no such account exists. Test it with `cadet`,
    `root`, and `nosuchuser`.

69. Stretch: a file arrives owned by uid `4102`. Six months later somebody creates an account and it
    is assigned uid `4102`. What happens to the file, what does `ls -l` say now, and what — precisely
    — did the new account gain? You saw this happen in lesson 03; explain the mechanism rather than
    recalling the result.
