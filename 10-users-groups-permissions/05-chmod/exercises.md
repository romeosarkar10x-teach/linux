# 10/05 — Exercises

Work in `/labs/10-users-groups-permissions/05-chmod`. No `sudo`. Never `chmod` a path outside this
lab.

---

## Numeric

1. `stat -c '%a %n' notes/*`. What are they, and would you have guessed?

2. `cp notes/chmod.txt scratch/a`. What mode is the copy? Is that the same as the original's, and
   what does that tell you about what `cp` copies?

3. `chmod 600 scratch/a`, then `stat -c '%a %A %n' scratch/a`. Read both forms.

4. `chmod 400 scratch/a` and then try `echo x >> scratch/a`. Denied. Now fix it and say which bit you
   restored.

5. `chmod 4 scratch/a` — one digit. What did it do to the other two triads? What is the rule for a
   numeric argument with fewer than three digits?

6. Set `scratch/a` back to 644 and check.

7. Without running it: `chmod 755` on a file that is currently `640`. Which bits change, in both
   directions? Name at least one bit that is *removed*.

8. That is the property of numeric mode people forget. State it in one sentence.

---

## Symbolic

Predict each result in writing before running it. Reset with `chmod 000 scratch/a` between clauses
where the exercise says so.

9. `chmod 000 scratch/a`. Then `chmod u+r scratch/a`. What is it now?

10. `chmod g+w scratch/a`. Now?

11. `chmod o=x scratch/a`. What did `=` do that `+` would not have?

12. `chmod a+x scratch/a`. Which triads changed?

13. `chmod ug=rw scratch/a`. What happened to the `other` triad, and why is that the point of this
    exercise?

14. `chmod u+rwx,go-rwx scratch/a`. Two clauses in one command. What is it now, and what would the
    numeric equivalent have been?

15. Which of the six commands above could you have written numerically without knowing the file's
    current mode? Which could you not?

16. `chmod +w scratch/a` with no `who`. Read `notes/chmod.txt` — what is the default `who`? Check
    what actually happened, and be careful: the answer here is not quite what the note implies.
    (`umask` is lesson 06, and it is the reason.)

17. Give the symbolic command for: "take write away from everybody except the owner", without knowing
    what the current mode is.

18. Give the symbolic command for: "make this runnable by its group, changing nothing else".

19. Give the numeric command for the same thing as 18. What did you have to know that the symbolic
    form did not need?

20. `chmod a=r scratch/a` then `chmod u+w scratch/a`. Two commands. Why is that pair a common idiom,
    and what is it equivalent to numerically?

---

## What chmod needs

21. `stat -c '%U %a %n' drop/theirs.txt`. Whose is it?

22. Try `chmod 666 drop/theirs.txt`. What is the error, and which of the nine bits would have let you
    do it?

23. None of them would. State what `chmod` actually requires, and where that requirement is recorded.

24. You own `scratch/a`. Set it to `000` and then chmod it back. You had no read and no write on it at
    the time. Why did that work?

25. Is there any mode you could set on a file you own that would stop you changing its mode later?
    Answer, then argue why the answer has to be what it is.

---

## The four repairs

Read `notes/page.txt` and `repair/NOTES`. For each of the four, work out the intended use *first*,
then make the smallest change that supports it. Record the command and one sentence of justification.

26. `repair/collect.sh` — "on shift, anyone runs it". Current mode? What is wrong?

27. Fix it. Compare `chmod 755`, `chmod +x` and `chmod a+x`. Are all three the same here? Would they
    be on a file that was `640`?

28. Prove it is fixed by running it.

29. `repair/id_station` — "nobody but its owner, ever". Current mode? What exactly is exposed?

30. Fix it. Numeric or symbolic — say which you chose and why this is the case where the other one is
    wrong.

31. `repair/handover/` — "crew write in it every day". Current mode? Which of the three permissions is
    missing, and for whom?

32. Fix it. Careful: the change is on the directory, and the reason is in `notes/deletion.txt`.

33. Prove it: create a file in `repair/handover` as yourself. Then say what a *member of crew who is
    not you* would now be able to do to `week-24.txt` — including whether they could delete it.

34. That last answer should worry you slightly. Note it down; lesson 08 has the bit that fixes it.

35. `repair/exporter.conf` — this is the one rhea cares about. Current mode? What is in the file?

36. Somebody set it to 777 to get a run out. Name three separate things that mode allows which nobody
    intended, and rank them by how bad they are.

37. Fix it. What is the right mode for a config file with a credential in it, read by a service that
    runs as its owner?

38. `exporter.conf` is 777 and is not executable in any useful sense — it is a config file. What does
    the `x` bit even mean on a file that is not a program? Is setting it harmful, or merely wrong?

39. Write rhea's reply: four lines, one per repair, each naming the command and what it was for. Then
    one closing line about the one she cares about, without blaming anybody.

40. Which of the four mistakes would `ls -l` have made obvious to a passer-by, and which would not?
    What does that suggest about how you would find the rest of them on a real machine?

---

## Deleting

41. Read `notes/deletion.txt`. Then `ls -l drop/` and `stat -c '%a %n' drop`.

42. `echo x >> drop/theirs.txt`. Denied — you knew that. Which triad?

43. Now `rm drop/theirs.txt`. Predict first, in writing. What happened?

44. If `rm` asked you to confirm, who was asking — the kernel or `rm`? How would you check?

45. Explain the result using only the sentence "a directory is a list of names".

46. Recreate the situation in `scratch/`: a directory you own, containing a file, where you can delete
    the file without being able to write it. Do it with `chmod` alone.

47. Now the other direction. Make a directory in `scratch/` containing a file you own and can write,
    which you *cannot* delete. One `chmod` on the directory.

48. Verify: `echo more >> thatfile` works, `rm thatfile` does not. Read both results out loud. Which
    mode was consulted for each?

49. So: to stop somebody deleting a file, which mode do you change? To stop them editing it?

50. `repair/handover` is now group-writable. Say precisely what that means for deletion, and who it
    applies to.

51. `/tmp` is `1777` — world-writable, and yet you cannot delete other people's files there. Given
    everything above, what must that extra `1` be doing? Guess in writing; do not look it up.

---

## Recursion

52. `stat -c '%a %n' tree` — and then try to look inside. Why can you not?

53. Read `tree/README`. Two of the files are scripts. What would `chmod -R 755 tree` do that you do
    not want?

54. What would `chmod -R a+rx tree` do that you do not want? Is it the same problem as 53?

55. `chmod -R a+rX tree`. Then `find tree -printf '%m %p\n' | sort`. Which files got `x` and which did
    not?

56. State what `X` means, precisely, in one sentence — both halves of it.

57. The directory `tree` itself was `600`, so you could not enter it. How did a recursive `chmod`
    manage to descend into it? What does that tell you about the order it works in?

58. `chmod --reference=tree/data/cycle-41.csv scratch/a`. What is `scratch/a` now? When is
    `--reference` better than typing the digits?

59. `chmod -c a+w tree/README` and then run it again. (Then put it back to 644.) What does `-c` print the second time, and why is
    that more useful than `-v` in a script?

60. Write the command that would make every *directory* under `tree` 755 and every *file* 644, in one
    line, without `X`. (`find -type` is chapter 6.) Then say which version you would rather read in
    six months.

---

## Symlinks and edges

61. `ln -s ../notes/chmod.txt scratch/link`. `ls -l scratch/link` — what mode does the link show?

62. `chmod 600 scratch/link`. Predict, then check both the link and `notes/chmod.txt`. What did you
    just change?

63. Set `notes/chmod.txt` back to 644. Now state the rule about `chmod` and symlinks in one sentence,
    and say what a symlink's own mode is good for.

64. `chmod 0644` and `chmod 644` — is there a difference? What is the leading digit for? Check with
    `stat -c '%04a %n' /tmp`.

65. `chmod 1777 scratch/somedir` would set that leading digit. Do not do it yet. Say what you expect
    it to do based on exercise 51, and note the lesson it belongs to.

---

## Judgement

66. Somebody's fix for a permission problem is `chmod -R 777 .`. List the four separate things that is
    wrong with, beyond "too permissive".

67. You inherit a machine. Write the one-line command you would run to find every world-writable
    regular file under `/labs`, and say why the `-type` matters (lesson 04, exercise 54).

68. Write a function `harden FILE` that sets a file to owner-read-write only, refuses if you do not own
    it, and prints the before and after modes. Test it on `scratch/a` and on `drop/theirs.txt`.

69. Stretch: `chmod` on a directory changes what people may do with the names in it, and `chmod` on a
    file changes what they may do with its contents. Given that, explain in three sentences why a
    "read-only" directory is a much weaker idea than it sounds — and what you would use instead if you
    genuinely needed a file nobody could remove.
