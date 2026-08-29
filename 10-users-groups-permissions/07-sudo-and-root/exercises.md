# 10/07 — Exercises

Work in `/labs/10-users-groups-permissions/07-sudo-and-root`. `sudo` is allowed throughout this
lesson — that is the point of it. **Do not edit `/etc/sudoers` or `/etc/sudoers.d`.**

---

## What root is

1. `id` and then `sudo id`. Compare every field, not just the first.

2. `sudo id` reports no groups except `root`. Given lesson 02, how can root read a file whose access
   depends on group membership?

3. Read `notes/root.txt`. State the difference between "has every permission" and "is exempt from the
   permission check". They predict the same outcome; only one predicts *how*.

4. Prove it: `echo secret > scratch/z; chmod 000 scratch/z; cat scratch/z; sudo cat scratch/z`.

5. `whoami` and `sudo whoami`. Then `sudo -u rhea whoami`. What is `whoami` actually reporting?

6. Is `root` special because of its name or its number? Design a one-command check using `id -u`, and
   say what you would expect on a machine where the account had been renamed.

7. `getent passwd root` and `getent passwd 0`. Same line?

8. `su -` and let it fail. What is the error, and what does `notes/root.txt` say about why? Is that a
   misconfiguration?

9. Give two things only uid 0 may do that you have already met in this chapter.

---

## sudo as a program

10. `type sudo`, then `ls -l /usr/bin/sudo`. What is in the owner triad where you expected `x`?

11. Who owns `/usr/bin/sudo`? Put those two facts together and explain how a program you launch can
    be running as root.

12. `stat -c '%a %U %n' /usr/bin/sudo` — four digits. Which one is new, and which lesson covers it?

13. If `sudo` starts as root regardless of who runs it, what stops *anyone* running `sudo rm -rf /`?
    Name the mechanism, not the file.

14. `sudo -l`. Read it carefully. Which line grants you what?

15. `sudo -l` also prints a `Defaults` block. Name the two entries there that change what your command
    sees.

16. `sudo -l` tells you what the policy permits. Name two things it does *not* tell you about a
    command you are about to run.

17. `sudo -v`. On this station you have `NOPASSWD: ALL` and it still fails. Read the error. What is
    `-v` actually asking for, and why does `NOPASSWD` not help?

---

## The environment

18. `export FOO=bar; echo $FOO; sudo printenv FOO`. What happened, and what is that behaviour called?

19. `sudo env | sort | head -20`. Which variables survived? Look for the four beginning `SUDO_`.

20. `sudo printenv HOME` and `printenv HOME`. Different. Which command would that difference break?

21. Now the important one. Build a hijack:

    ```
    mkdir -p scratch/bin
    printf '#!/bin/sh\necho HIJACKED\n' > scratch/bin/id
    chmod 755 scratch/bin/id
    PATH=$PWD/scratch/bin:$PATH
    ```

    Predict what `id` and `sudo id` will each print. Then run both.

22. Explain the two results. Which policy setting produced the second one, and what attack is it
    for?

23. `sudo -l | grep secure_path`. What is on that list, and what is conspicuously not?

24. Put your `PATH` back (`hash -r` too, if `id` still misbehaves) and remove `scratch/bin/id`.

25. `sudo -E printenv FOO`. It works. Read what `-E` does, then say why a policy might forbid it.

---

## What sudo cannot do

26. `sudo echo hi > /etc/zz-test`. Predict, run, read the error. Which process was denied?

27. Rewrite it so it works, using `tee`. Then remove the file with `sudo rm`.

28. Rewrite it again using `sudo sh -c`. Both work; describe the difference in what you handed to
    root.

29. Which of the two would you rather see in somebody else's script, and why?

30. `sudo cd /root`. Read the error — it is unusually helpful. Why can `sudo` not do this?

31. `sudo -s` then `pwd` then `exit`. Then `sudo -i` then `pwd` then `exit`. Two different
    directories. Explain both.

32. Compare `sudo -i printenv HOME` with `sudo -s printenv HOME`. They agree — check, and then say
    what *does* differ between the two by comparing `sudo -i pwd` with `sudo -s pwd`. Which of the
    two is a login shell, and what does "login shell" mean for the environment?

33. You need to append a line to a root-owned file, as part of a script that runs unattended. Write
    the command. Justify your choice against the two you rejected.

---

## sudo -u: not everything needs root

34. `sudo -u rhea id`. Which groups does rhea have that you do not?

35. `sudo -u rhea whoami; sudo -u rhea pwd`. Where does she land, and why is it not her home
    directory?

36. You need to read a file that is group `engineering`, mode `640`. Two routes: `sudo cat`, or
    `sudo -u rhea cat`. Both work. Argue for one.

37. Which of the two leaves a clearer record of what was done and why? Which is easier to grant
    narrowly in a policy?

38. `sudo -u rhea touch scratch/hers`. Predict who would own the result — then run it. It fails.
    Diagnose the failure with `stat -c '%U %G %a' scratch` and `sudo -u rhea id`, and say which
    single bit is missing.

39. Fix it with one `chmod`, run the `touch` again, and check the owner and group of the result.
    Then delete the file as yourself. Did you need `sudo` to delete it? Explain using lesson 05, and
    put `scratch` back to `755`.

40. Name a case where `sudo -u` is exactly wrong and root is the right answer.

---

## Reading a policy

Use `policy/sudoers.example`. Nothing in `policy/` is live.

41. The comment line gives the grammar: `user host = (runas_user:runas_group) commands`. Parse the
    `root` line and the `%sudo` line field by field.

42. What does the `%` mean in `%sudo` and `%ops`?

43. Parse the `cass` line. Who may run what, as whom, on which host, and with or without a password?

44. Parse the `dorn` line. He is granted something that is not root. What, and why might that be the
    right shape for a grant?

45. Why does a policy name a host at all, when this file is on this station?

46. `Defaults use_pty`. Guess what it is for. (It is about what a command can do to your terminal
    after it exits.)

47. Read the last comment block. Explain, to somebody who has never used `find`, why granting
    `/usr/bin/find` grants a shell.

48. Name three other commands that are shells in disguise for this purpose. Editors and pagers are the
    hunting ground.

---

## Four grants

`policy/grants.txt`. Two of the four are fine and two are much wider than they read.

49. Grant A: `tail -f /var/log/exporter.log`. The path is fixed. What is not?

50. Show the problem concretely: what could the grantee run, given that argument list is not pinned?
    (You do not need to run it.)

51. Grant B: `vi`. State the problem in one sentence.

52. Grant C. Why is this the one the reviewer calls the only one anybody has ever needed twice, and
    what makes it a good grant? Name three properties.

53. Grant D: `/opt/kestrel/bin/*`. What does the star cover, and what would you need to check before
    deciding whether it is safe? (`ls /opt/kestrel/bin | wc -l` is a start.)

54. Rank all four from safest to worst and defend the ordering in one line each.

55. Rewrite grant A so that it is actually narrow. You may invent a wrapper script; say what the
    wrapper must not accept.

56. The reviewer's notes are unattributed. Say what you can and cannot conclude about who wrote grant
    D.

---

## One line needs root

57. `cat jobs/collect-counts.sh`. Which single line requires privilege? How do you know before running
    it?

58. Run it as yourself: `./jobs/collect-counts.sh /tmp/c1.txt`. What is the error and what is the
    exit status?

59. Run it under `sudo`. It works. What is now true of the *other* four lines that was not true
    before?

60. That is the objection to `sudo whole-script.sh`. State it in one sentence.

61. Rewrite the script so only the line that needs root runs as root. Test both halves.

62. Your rewrite calls `sudo` inside a script. Name one thing that makes worse and one thing that
    makes better, compared with `sudo ./script.sh`.

63. `cat jobs/tidy.sh`. The dangerous line is commented out. Say exactly what would happen if
    `TARGET` were empty and the line were live, and which one character in it is doing the damage.

64. Rewrite the guard so the script refuses to run with an empty or unset `TARGET`, before it prints
    anything. (`set -u` alone is not enough here; say why.)

---

## Writing the request

65. Read `requests/draft-1.txt`, `requests/reply-1.txt` and `requests/template.txt`. List the six
    things rhea's reply asks for.

66. What did draft 1 actually ask for? Answer in terms of what a person would have to grant to satisfy
    it literally.

67. Write draft 2. The situation, which is hypothetical — do not go looking for these paths: you
    need to read the engineering archive for one shift, to check whether cycle 41's raw counts match
    what was exported, and reading it as yourself was refused because the directory is group
    `engineering` and you are not. Use the template's six headings, and name a concrete path even
    though you are inventing it; "the archive" is the thing rhea rejected.

68. Your draft asks for something. Say whether you asked for root, for a group, or for `sudo -u`, and
    defend it — one of the three is clearly right here and the other two are defensible with an
    argument.

69. Stretch: rhea's reason for refusing is not "you might break something". Reread her reply and state
    her actual reason in your own words, then say what that implies about grants that are given
    verbally and never written down.
