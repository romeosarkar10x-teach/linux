# Exercises — Triage

Work in `/labs/15-capstone-kestrel-breach/02-triage`.

**Observation only.** Do not kill, stop, chmod, chown or delete anything
outside `case/` and your own scratch directory — except where an exercise
explicitly tells you to, and one of them does. Remediation is lesson 04.

## A. Warmup

1. `id` and `groups`. Which uid are you, and which groups are you in?
2. `getent passwd ops-bot`. Read the seven fields back in words.
3. `getent passwd eng-svc; echo $?`. What is the exit code, and what does it
   mean?
4. `ps -ef | wc -l`. Roughly how many processes is this container running, and
   why is that number so much smaller than on a normal machine?

## B. Core — the accounts

5. List every account in `/etc/passwd` with a uid of 1000 or above, showing
   name, uid and shell, using one `awk` command.
6. Which of those accounts cannot start an interactive shell? What is in its
   shell field?
7. `getent group crew` and `getent group ops`. Who is in each?
8. Which account is in `ops` but not in `crew`, and which is in both?
9. `id dorn` and `id rhea`. Which group does rhea have that nobody else does?
10. Look at `/etc/shadow`. What happens, and what does that tell you about the
    file's permissions? Check them.
11. Now read it with the privilege you have. Which accounts have a real
    password hash and which have `*` or `!`? What does the difference mean?
12. Write a one-sentence `says` line about the ops-bot account. It must not
    contain the word "bot" doing any work, and it must not speculate.

## C. Core — what is running

13. `ps -ef`. Which processes are not owned by you or by root?
14. Start the summariser the way the station starts it:
    `sudo -u ops-bot nohup ./bin/strain-summary >/dev/null 2>&1 &`.
    Wait ten seconds, then find it with `pgrep`.
15. `pgrep -u ops-bot -a`. Two pids come back. What is the second one, and why
    does it keep changing every time you run the command?
16. `ps -o pid,ppid,user,etimes,lstart,cmd -p <pid>`. Who is the parent?
17. `pstree -ps <pid>`. Read the whole chain from pid 1 aloud.
18. The parent is a `sudo` process owned by root, and the child is owned by
    `ops-bot`. Explain in one sentence how a process can change user.
19. `cat /proc/<pid>/status | head`. What are `State`, `PPid`, and the four
    numbers on the `Uid:` line?
20. `cat /proc/<pid>/cmdline`. It comes out as one run-together string. Fix it
    so each argument is on its own line.
21. Try to read `/proc/<pid>/environ` as yourself. What error?
22. Now try `sudo tr '\0' '\n' < /proc/<pid>/environ`. Does it work? Explain
    the error in terms of who opens the file.
23. Get the environment out correctly. Is `STRAIN_TOLERANCE` set in it?
24. `ls -l /proc/<pid>/cwd`. What directory is the process sitting in?
25. In another shell, run `./bin/deck-watch 20 &` as yourself. Compare its
    `ps` line with the summariser's. Which fields differ, and which one would
    you quote in a report about "how long has this been running"?
26. Let `deck-watch` finish. What happens to its pid? What would you have seen
    if you had run `ps` five seconds later?

## D. Core — open files

27. `sudo lsof -p <summariser pid>`. What are fds 3, 4 and 255?
28. What is fd 255, specifically? Why does bash hold that open?
29. `sudo ls -l /proc/<pid>/fd`. Same information, different tool. Which of the
    two would you use if `lsof` were not installed?
30. `cat var/summary.log`. What is it writing, and how often?
31. `cat var/summary.err`. What does the summariser complain about, and to
    which descriptor does that complaint go?
32. Which value is being reported when the raw value is above tolerance? Quote
    one `cycle=` line where `raw` and `reported` differ.
33. Count how many cycles have been clamped so far, and what fraction of the
    total that is.
34. Now the one destructive thing in this lesson: `rm var/summary.log`. Wait
    ten seconds.
35. Does the process notice? Check `sudo lsof -p <pid>` again. What is
    different about the fd 3 line now?
36. Is the summariser still writing? Where is the data going, and can you read
    it? (Chapter 14, lesson 03. Do not stop the process to find out.)
37. Recover the log's current contents without restarting anything. Write the
    command.
38. What would have happened to that data if you had stopped the process
    instead? Answer before you do anything, and do not do it.

## E. Experiment — predict first

39. Predict: does `pgrep strain-summary` find the process? Then run it. Then
    run `pgrep -f strain-summary`. Explain the difference using `man pgrep`'s
    wording for `-f`.
40. Predict what `lstart` shows for a process started thirty seconds ago versus
    what `etimes` shows, and which one changes when you re-run `ps`. Test both.
41. Predict: can you `kill` the summariser as yourself, without `sudo`? Write
    your prediction and the reason. **Do not run it** — write down the command
    you would have run and what you expect the error to be. You will find out
    in lesson 04.
42. Predict whether `ps -ef` shows the `sleep 5` child. Run `ps -ef` repeatedly
    and describe what you actually see and why it is inconsistent.

## F. Core — the two logs

43. `wc -l access/*.log`. How many entries in each?
44. Extract every distinct account name from `access/eng-access.log`, sorted.
    How many?
45. Check each of those names against `getent passwd`. Which one does not
    resolve?
46. How many times does that account appear, on what date, at what time, and
    what did it do?
47. Does it appear in `crew-shell.log`? What does its absence there mean, and
    what does it not mean?
48. What is the largest gap in `eng-access.log` between two consecutive entries
    by the same account? Show the pipeline.
49. `access/crew-shell.log` has one entry that is out of chronological order.
    Find it. Is that a finding, or a log that appends by session close?
50. Which account's session ends at 04:12 on 2187-05-24, and which lesson-01
    artefact carries the same timestamp?

## G. Stretch and Dig

51. Write one claim file per finding from this lesson, in `case/artefacts/`,
    numbered from `claim-04.md`. At minimum: the nologin account with a running
    process, the unresolvable account in the access log, and the summariser's
    own file mtime.
52. `stat -c '%y' bin/strain-summary`. What date is the summariser script
    itself, and how does that compare with every other date you have seen in
    this chapter so far?
53. Write a script `case/triage.sh` that prints, for every process not owned by
    root or by you: pid, user, start time, and command. It must produce no
    output at all when there is nothing to report. (Chapter 12.)
54. **Dig:** `ps` can print how long a process has been running in a
    human-readable form as well as in seconds. Find both format specifiers in
    `man ps` and show the summariser with each.
55. **Dig:** `lsof` has a flag that lists only files whose link count is below
    one. Find it and use it to show the deleted log without naming the pid.
56. **Dig:** `pgrep` has a flag that prints the oldest matching process only.
    Find it in `man pgrep` and explain when that is the right question to ask
    and when it is dangerously wrong.
