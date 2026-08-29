# 10/04 — Exercises

Work in `/labs/10-users-groups-permissions/04-rwx-and-octal`. Nothing here needs `sudo`, and nothing
here changes a mode. If you reach for `chmod`, you are a lesson early.

---

## Reading the ten characters

1. `ls -l notes/modes.txt`. Read the first ten characters aloud, one at a time, naming what each
   governs. Ten, not nine.

2. Which character is not part of any triad? What are its three most common values?

3. `ls -ld maze notes scratch`. Same first character for all three. What is it?

4. `ls -l notes/` and `ls -ld notes/`. Different output. Explain the difference in one sentence
   without using the word "contents".

5. `stat -c '%a %A %n' notes/modes.txt`. Two forms of the same thing. Which is which?

6. `stat -c '%U %G %u %g %n' notes/modes.txt`. Four fields, two of which are the same information.
   Which pair, and which of the pair is what the kernel actually stores? (Lesson 03.)

7. Without running anything: what octal is `rw-r-----`? `rwxr-xr-x`? `r--------`? `rwxrwxrwx`?

8. Without running anything: what symbolic form is `640`? `755`? `600`? `751`?

9. `stat -c '%a %n' notes/* audit/* scratch/*`. Any surprises? Which single digit repeats most?

10. `ls -l /etc/shadow /etc/passwd /etc/group`. Three modes, two owners. Explain each mode in one
    line, in terms of who needs what. (You answered the underlying question at the end of lesson 03.)

---

## First match wins

11. `notes/modes.txt` is yours. If its mode were `044` — no owner bits, `r--` for group and other —
    could you read it? Answer before you check anything, then justify it from the rule.

12. Make the file and check: `cp notes/modes.txt scratch/t; chmod 044 scratch/t; cat scratch/t`. What
    happened, and which triad did the kernel use?

13. That is the single most counter-intuitive thing in this lesson. Write the rule in your own words
    in one sentence, without the words "owner", "group" or "other".

14. Now `chmod 644 scratch/t` so you can carry on, and note which access you needed to do that — was
    it read, write, or something that is not in the nine bits at all?

15. In `audit/listing.txt`, `strain/.private` is `-rw-------  rhea rhea`. Can cass read it? Can rhea?
    Can root? Which of those three answers does not come from the triads at all?

16. Construct a mode where a member of the file's group has *more* access than the owner. Write it in
    octal and say who it would confuse.

---

## The maze

Read `maze/HOW`. Answer each prediction **in writing before you run the command**.

17. `ls -ld maze/open maze/listed maze/reachable maze/shut`. Four modes. Convert each to octal in
    your head and check with `stat`.

18. You are `cadet` and all four are owned by `root:root`. Which triad applies to you for all four,
    and why does that make the comparison clean?

19. Predict, then run: `ls maze/open`, `ls -l maze/open`, `cat maze/open/rota.txt`.

20. Predict, then run: `ls maze/listed`, `ls -l maze/listed`, `cat maze/listed/rota.txt`.

21. `ls maze/listed` worked and `ls -l maze/listed` did not — it printed a line of `?`. What extra
    thing does `-l` need that plain `ls` does not?

22. `ls` got the names from the directory itself. Where does the rest of the `-l` line come from, and
    why does getting it require the `x` bit?

23. Predict, then run: `ls maze/reachable`, `cat maze/reachable/rota.txt`.

24. You just read a file inside a directory you cannot list. Say why that is not a contradiction, in
    terms of what each bit permits.

25. `cat maze/reachable/note.txt` also works. `cat maze/reachable/nothere.txt` gives a different
    error from the one `ls` gave. Read both errors carefully — what does the difference tell you
    about what the kernel is willing to reveal?

26. `maze/reachable/deeper/buried.txt` exists. Read it. Then say how many directory `x` bits that one
    `cat` required, counting from `/`.

27. Predict, then run: everything you can think of against `maze/shut`. What is the mode, and what
    would you have to be to get in?

28. Summarise the four directories as a four-row table: mode in octal, `ls`, `ls -l`, `cat a known
    name`. This table is the lesson; keep it.

---

## cass's page

29. Read `notes/page.txt`. Which of the four maze directories is cass describing?

30. rhea says it is not possible. She is wrong here, and she is wrong for a reason that is worth
    stating precisely. What is the assumption behind "if you can list it you can read it"?

31. Cass says the directory is "one directory down from the shift rota". Is that consistent with what
    you found? What would you need from her to be sure which directory she means?

32. Write the reply. Three sentences: why it happens, how you know, and what she should ask for
    (which is not "read access to the file").

33. What single command would you have asked cass to run first, to get the useful information in one
    round trip instead of three?

---

## The audit listing

Answer 34–44 from `audit/listing.txt` alone. Do not run commands against the station; nothing in that
listing exists here. Groups: rhea is in `rhea, crew, engineering`; cass is in `cass, crew`; kalvi is
in `kalvi, crew, hydroponics`.

34. Who can read `strain/export.csv`? Name each of the three and give the triad that decided it.

35. Kalvi cannot. What is the smallest change that would let her — and is it a change to the file, to
    a group, or to her?

36. Who can write `galley/rota.txt`? Note that its mode is `-rw-rw-r--` and the directory's is
    `drwxrwxr-x`.

37. Can cass **delete** `galley/inventory.csv`, which is `-rw-r--r--` and which she owns? Which mode
    did you have to look at to answer that? (This is lesson 05's opening question; get it wrong now,
    cheaply.)

38. Can cass list `tools/`? Run `tools/report`? Run `tools/adjust`?

39. `tools/adjust` is `-rwx------ root root`, modified at 02:55 on a date in March. From the listing
    alone, what can you say about it, and what can you *not* say? Be strict about the boundary.

40. `queue/` is `drwx--x--x dorn ops`. What can cass do inside it? What can she do with
    `queue/README`, which is `-rw-r--r--`?

41. `queue/` is the `--x` case in the wild. Why would somebody set a directory that way on purpose?
    Give a use for it that is not sinister.

42. `quarantine/` is `d---------`. Who can enter it? What does that mode communicate to the next
    person who reads the listing, beyond its literal effect?

43. `heartbeat` is `-rw-rw-rw-`. Say what is wrong with that in one sentence, and say what it should
    probably be given its owner and group.

44. Answer question 6 in `audit/questions.txt`: which single file would you raise first? Defend the
    choice against the other candidates.

---

## Paths

45. `ls -ld / /labs /labs/10-users-groups-permissions`. Every one of them has `x` for other. What
    would happen to every user on this station if one of them did not?

46. `namei -l maze/reachable/deeper/buried.txt`. Read the output. What is this tool for?

47. Use `namei -l` on `maze/shut/rota.txt`. Which line is the one that stops you? Would `ls -l` on
    the file alone have told you that?

48. A colleague says "the file is 644, so it must be readable". Give them the two-sentence correction,
    with the path rule in it.

49. Design the smallest experiment that proves a missing `x` on a *parent* directory, not the file's
    own mode, is what denied you. Use `scratch/` and `chmod` on your own directories only.

50. `cd maze/listed` — does it work? Which bit does `cd` need, and is it the one you would have
    guessed from `ls` working?

---

## Reading real modes

51. `ls -ld /tmp`. Its mode ends in a letter you have not met. Do not look it up yet — write down what
    you think it might be for, given that `/tmp` is world-writable.

52. `ls -l /usr/bin/passwd`. There is another unfamiliar letter, in the owner triad. Same instruction:
    guess, in writing, given that `passwd` has to write to a file only root can write.

53. Both of those are lesson 08. What you should take from them now is that the ten characters are
    not always the ten you have learned. What would you do if you met one in a listing tomorrow?

54. `find /etc -maxdepth 1 -perm -o=w 2>/dev/null`. What is this asking for? Is the answer reassuring?

55. `stat -c '%a %n' /etc/passwd /etc/shadow /etc/sudoers`. All three succeed, and one of them is
    `440` — not readable by you. Now try `cat /etc/sudoers`. Why did `stat` work when `cat` did not?
    Which directory's bit was `stat` relying on?

56. `ls -l /opt/kestrel/bin | head`. Almost every entry is `lrwxrwxrwx`. Is `/opt/kestrel/bin/awk`
    really writable by everybody? Test it with `echo hi >> /opt/kestrel/bin/awk` — predict first.
    Then say what a symlink's own mode is good for.

---

## Writing it down

57. Write a function `perms FILE` that prints the octal mode, the symbolic mode, the owner and the
    group on one line, and works on a directory as well as a file.

58. Extend it: if the file is world-writable, append the word `WORLD-WRITABLE` to the line. Test it
    against `heartbeat`… which is in a listing, not on disk. Make one in `scratch/` instead.

59. Write down, from memory, the octal for: a private key, a shared script everyone runs, a config
    file only root should read, a directory a team collaborates in. Then say which of those four you
    are least sure about and why.

60. Stretch: `chmod 000 scratch/t` and then, as `cadet`, try to read it, delete it, and rename it.
    Two of those three work. Explain the result using only what is in `notes/modes.txt`, and note
    which lesson is going to have to explain the rest.
