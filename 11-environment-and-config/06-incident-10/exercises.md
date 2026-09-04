# Exercises — 11/06 Incident 10

    cd /labs/11-environment-and-config/06-incident-10

This is an incident, so the exercises are the investigation. Do them in order
the first time.

## Establish what is actually true (1–8)

1. `ls archive/` in your own shell. How many sections?
2. `ls -la archive/` — anything unusual about ownership or permissions?
3. `find archive -type d | sort`. Does `find` agree with `ls`?
4. `stat -c '%y %n' archive/*/`. When was the archive last written to?
5. Read `notes/page.txt`. Which of cass's checks would you have run, and which
   one did she run that you would not have thought of?
6. Read `notes/incident.txt` and `notes/rules.txt` before touching anything.
7. Write down, in one line, the claim you are testing. "A directory is missing"
   is not it — you have already disproved that in exercise 3.
8. `HOME=$PWD/homes/dorn bash -l` — start the account's login shell. Run `ls`
   in `$ARCHIVE`. How many sections now? Type `exit`.

## Checkpoint 1 (9–12)

9. Get both lists into files and `diff` them, rather than counting by eye.
10. Which section is missing from the account's view?
11. `bin/compare-view <name>` with the name you found.
12. If it rejected you, what did the rejection tell you to do that you had not
    done?

## Find the mechanism (13–24)

13. In the account's shell, `ls -d $ARCHIVE/02-navigation`. Does that work?
14. `echo $ARCHIVE/02-navigation/*` — does that work?
15. `cd $ARCHIVE; echo *` — does *that* work? State the difference between 13
    and 15 in terms of who expands what.
16. `cat $ARCHIVE/02-navigation/deck-map.txt` in the account's shell. Is the
    file readable?
17. So: is anything wrong with the directory, or with the account? Answer in
    one sentence before continuing.
18. `grep -rn GLOBIGNORE homes/dorn/` — where is it set?
19. `grep -n GLOBIGNORE homes/dorn/.bashrc` alone finds nothing. Why not, and
    what should you have grepped instead?
20. Read `homes/dorn/.profile`, then `.bashrc`, then whatever `.bashrc`
    sources. Draw the chain: three files, two arrows.
21. There are **two** lines doing the hiding, not one. What is the second, and
    which command does it affect that `GLOBIGNORE` does not?
22. In the account's shell: `type ls`, then `\ls`, then `command ls`. Which of
    those show you the truth, and why?
23. `bin/name-mechanism <VARIABLE> <path-relative-to-home>`.
24. Read `notes/toolchain.txt`. Who is supposed to own that file, who audits
    it, and what does the answer to the second question mean for anyone who can
    write to a home directory?

## Repair it (25–33)

25. Re-read `notes/rules.txt`. List what you may not do.
26. Deleting the two lines would work. Say in one sentence why it is the wrong
    repair anyway, using the file's own first comment as evidence.
27. Where in `.bashrc` is the generated file sourced — before or after the last
    line of `.bashrc`?
28. Given lesson 05's rule about two assignments to the same variable in one
    file, what is the smallest thing you can add to `.bashrc` to undo
    `GLOBIGNORE` without touching the file that sets it?
29. Do it. Run `bin/verify-repair`.
30. It will complain that a bare `ls` still hides the directory. Why did your
    fix not cover that, and what is the second line you need?
31. Add it. Run `bin/verify-repair` again and record the token.
32. `md5sum homes/dorn/.config/kestrel/env.sh` — confirm you did not touch the
    generated file.
33. Start a fresh `HOME=$PWD/homes/dorn bash -l` yourself and check the archive
    by hand. Do not take the checker's word for it.

## Close it (34–40)

34. The last checkpoint wants the date the hiding was written. `notes/*` does
    not have it and neither does any comment. Where is it?
35. `stat -c '%y' homes/dorn/.config/kestrel/env.sh`.
36. The file's own first line says `Generated 2186-03-02`. The timestamp says
    something else. Which one is evidence, and which one is a claim?
37. `bin/incident-close <stage-3-token> <YYYY-MM-DD>`.
38. Submit the flag: `kestrel flags submit 'KESTREL{...}'`.
39. Try submitting one of the `STAGE{...}` tokens. What happens, and why is that
    the correct behaviour?
40. `kestrel flags` — how many do you have now?

## Write it up (41–50)

41. In three sentences, tell cass what happened. She asked for it in writing.
    She is not asking to be taught the shell; she is asking whether the machine
    is broken.
42. Answer her actual question directly: can a computer show two people
    different contents of the same directory, with both correct?
43. Name the one thing she could have run that would have shown it immediately,
    and say why it was not an unreasonable thing not to know.
44. Your repair lives in `.bashrc`. The next toolchain upgrade regenerates
    `env.sh` with the same two lines in it. Does your repair still hold? Why?
45. Is your repair *silent*? Would the next engineer reading `.bashrc`
    understand why those lines are there? If not, fix that too — comments are
    part of a repair.
46. Whoever wrote those two lines chose `.config/kestrel/env.sh` rather than
    `.bashrc`. Give two reasons that is a better hiding place, in terms of what
    people actually read and grep.
47. `ls -l` the file's ownership. Who could have written it, and is that the
    same question as who did?
48. What would have caught this? Name one check the toolchain does not do,
    from `notes/toolchain.txt`, and say what it would have cost to do it.
49. `find` never lied to you. `grep -r` never lied to you. `ls` did. Explain
    that sentence precisely — it is not because `ls` is untrustworthy.
50. One line, for your own notes: what is the difference between a file being
    hidden and a file being invisible to one person?
