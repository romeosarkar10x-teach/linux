# 10/03 — Exercises

Work in `/labs/10-users-groups-permissions/03-managing-accounts`. Everything here needs `sudo`.

**Standing rule:** the only accounts you may modify are ones you create yourself, plus `probe`.
Never point `usermod`, `userdel`, `passwd -l` or `chage` at `cadet`, `rhea`, `cass`, `dorn`,
`ops-bot`, `ubuntu` or `root`. Every exercise names its target.

---

## Before you type anything

1. Read `roster/arrivals.txt`, `roster/offboarding.txt` and `roster/uid-policy.txt`. Two arrivals,
   one service account, two departures. Which of those five is the odd one out, and why?

2. `sudo useradd -D`. What shell would a bare `useradd` give a new person on this station?

3. Is that shell the one you are using right now? Check with `echo $SHELL` and `getent passwd cadet`.

4. `grep -E '^(UID_MIN|UID_MAX|HOME_MODE|UMASK|USERGROUPS_ENAB|ENCRYPT_METHOD)' /etc/login.defs`.
   Six settings. Say in one line what each one will do to an account you create.

5. What is the highest uid currently in use on this station? Get it from `/etc/passwd` with `awk` and
   `sort -n`, ignoring anything at or above 60000.

6. According to `roster/uid-policy.txt`, what should the next arrival's uid be? Compare with what
   `useradd` will actually choose.

---

## The bare command

7. `sudo useradd tulane`. No flags. It prints nothing.

8. `getent passwd tulane`. Read all seven fields aloud. Which of them did you choose?

9. `ls -ld /home/tulane`. What do you get, and is it a failure?

10. `getent group tulane`. Where did that come from? Which setting in exercise 4 caused it?

11. `sudo getent shadow tulane`. Nine fields, most of them empty. What is in field 2?

12. `sudo passwd -S tulane`. The second column is a letter. What does it mean, and is this account
    usable right now?

13. So: `useradd` with no flags created an account that cannot log in, has nowhere to live, and gets
    `/bin/sh`. Is that a bad default? Argue it either way in two sentences.

14. `sudo userdel tulane`. Then confirm with `getent passwd tulane` and `getent group tulane`. What
    happened to the group?

---

## The command you will actually type

15. Create the first arrival properly: a home directory, `/bin/bash`, the description
    `Tulane, M., hydroponics`, and membership of `crew`. One command.

16. `getent passwd tulane` again. Compare every field with exercise 8.

17. `ls -a /home/tulane`. Where did those files come from? Find the directory they were copied from.

18. `ls -ld /home/tulane`. What mode? Which setting from exercise 4 chose it? Could Kalvi read
    Tulane's home directory?

19. `id tulane`. Two groups. Which is primary, and which file records that fact? (Lesson 02.)

20. Now the second arrival, Okonkwo, A., same department, same requirements.

21. `getent passwd okonkwo tulane`. Their uids differ by one. Predict what uid the *third* account
    you create will get, then create and remove one to check.

22. The third entry in `arrivals.txt` is `survey-svc`, and it is not a person. Which of the flags you
    used in exercise 15 should it *not* get? Name two, with a reason for each.

23. Create `survey-svc`: no home directory, `/usr/sbin/nologin` as its shell, no supplementary
    groups. Then lock it.

24. `sudo passwd -S survey-svc`. Compare with exercise 12. Is a service account with `nologin` and no
    password actually protected by the lock, or was it already unreachable? What is the lock buying?

25. Run `sudo -u survey-svc /bin/sh -c 'echo hello'`. It works. Explain why the login shell being
    `nologin` did not stop that, and what that tells you about what a login shell is for.

---

## usermod

26. Okonkwo's description is wrong — she is deck-03, not hydroponics. Fix it without touching any
    other field.

27. Tulane wants `/bin/sh`. Change it, verify, change it back.

28. Add Tulane to `hydroponics`. Verify two different ways, one of which must not be `id tulane`.

29. `sudo usermod -l tulane-m tulane`. Now check three things: the login name, the home directory
    path, and the group name. How many of the three changed?

30. That is a foot-gun in the same family as lesson 02's. State it in one sentence, then undo the
    rename.

31. `sudo usermod -L okonkwo`, then `sudo getent shadow okonkwo | cut -d: -f2`. What is stored there
    now? Unlock and compare.

32. Okonkwo has never had a password set, so field 2 was `!` before you locked it and `!` after.
    Given that, how would you tell a *locked account with a password* apart from a *locked account
    that never had one*, by looking at field 2?

---

## /etc/shadow and chage

33. `sudo chage -l tulane`. Six lines. Match each one to a field number from `notes/shadow.txt`.

34. `sudo getent shadow tulane`. Field 3 is a number in the 20000s. What is it counting, and what
    date is it? Convert it with `date -d "1970-01-01 + N days"`.

35. Field 5 is 99999. How many years is that? Is that a policy decision or an absence of one?

36. Set Tulane's password to expire every 90 days, with 14 days of warning. One `chage` command,
    two flags.

37. `sudo getent shadow tulane` again. Which fields changed? Do they match what you asked for?

38. Rotation 7 is a fixed six-month posting. Set Okonkwo's **account** to expire on 2187-12-31.

39. `sudo chage -l okonkwo`. Which line moved? Which line did *not* move, and why is that the whole
    point of exercise 38?

40. Two people arrive at your desk. One says "it says my password has expired". The other says "it
    says my account has expired". Which one can you fix by talking them through a prompt, and which
    one needs root?

41. `sudo chage -d 0 tulane`. Read `sudo chage -l tulane` and say what will happen at Tulane's next
    login. What is field 3 now?

42. Field 7 — "days after expiry before the account is disabled" — is the one nobody sets. Describe a
    situation where the difference between field 7 being `-1` and being `7` matters to somebody.

---

## The archived homes

43. `ls -l homes/`. Four entries. Three are directories. Read the owner column carefully — one of
    them is not like the others.

44. `sudo ls -l homes/haldane`. Who owns those files? Is `4102` a uid or a gid in that output? Both?

45. `getent passwd 4102`. What is the exit status? What does that tell you about the number?

46. `grep 4102 roster/retired-uids.txt`. It is not there. Now read the four numbers that *are* there
    and say what you think happened.

47. `sudo find homes -nouser -o -nogroup`. What does `-nouser` actually test? (It is not "the owner
    is 4102".)

48. Read `homes/haldane/README`. Which step of `roster/offboarding.txt` was skipped?

49. `homes/kalvi` is owned by `rhea`, which is odd for a directory named kalvi. Is that a bug in the
    lab, a bug on the archive host, or something a real archive copy does? Say what evidence would
    settle it.

---

## Reuse, demonstrated

50. Predict, in writing, before you run anything: if you create a new account right now, what uid
    will it get?

51. Create a throwaway account `relief` with a home directory. Check its uid.

52. That uid is not 4102, so the demonstration needs a smaller scale. Instead: create `relief2` with
    `sudo useradd -m -u 4102 relief2`. Now run `sudo ls -l homes/haldane` again.

53. Nothing was copied, nothing was chowned, and no file was written. Explain, in terms of what is
    actually stored in a file's inode, why the output changed.

54. Read `homes/haldane/private.txt` as `relief2`: `sudo -u relief2 cat homes/haldane/private.txt`.
    Does it work? Should it?

55. This is the uid-reuse hazard, and you have now caused it. Write the two-sentence version you
    would put in an incident note.

56. `roster/uid-policy.txt` says to retire numbers rather than reuse them. Name the cost of that
    policy — there is one, and "we run out of numbers" is not it at this scale.

57. Remove `relief2` **and its home directory**, then confirm that `sudo ls -l homes/haldane` is back
    to showing `4102`.

58. Remove `relief` the same way. Then `ls /home` and check that nothing was left behind.

---

## Doing the actual job

59. Do what rhea's page asked, for the departures only. `merrick` and `voss` do not exist as accounts
    on this station — so state, in commands you would run, exactly what you would do to each of them
    today, and say which step you would *not* do today and why.

60. Write rhea's reply. Say what you created, what you locked, what you found in `homes/`, and what
    decision you need from somebody before you can finish. Four sentences, no jargon she has to look
    up.

61. `homes/probe` exists and `probe` is locked with no home directory of its own. Is `homes/probe` an
    orphan? Explain the difference between that directory and `homes/haldane`.

62. Write the check you would run monthly to catch this class of problem across a whole filesystem,
    as one command. State what it would cost to run on a large disk and what you would do about that.

---

## Cleanup and stretch

63. Remove `tulane`, `okonkwo` and `survey-svc`, homes and all. Verify with `getent passwd` and
    `ls /home` that the station is as you found it.

64. `getent group` — are `tulane`, `okonkwo` and `survey-svc` gone from there too? Which removal
    removed them?

65. Write a shell function `newcrew NAME "Full, Name" DEPT` that creates a person account the way
    `arrivals.txt` implies it should be done, refuses to run if the account already exists, and
    prints what it did. Use `getent passwd` for the check, not `grep`, and say why.

66. `useradd` returned a non-zero status when you tried to create an account that already existed.
    Find the number, look up what it means in `man useradd`, and say why a script should test it
    rather than testing the message.

67. `adduser` exists on this station. Read the first thirty lines of it — it is a script, not a
    binary. What language is it in, and what does that tell you about relying on it?

68. Stretch: `/etc/shadow` is mode 640, owned `root:shadow`. `/etc/passwd` is 644. Explain why the
    split exists at all — why not put the hashes in `/etc/passwd` and make the whole thing 640?
