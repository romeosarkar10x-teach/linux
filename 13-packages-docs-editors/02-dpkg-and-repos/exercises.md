# 13/02 — exercises

Lab: `/labs/13-packages-docs-editors/02-dpkg-and-repos`.

Lesson 01's packages and its `station.list` are still installed. Leave them.

## A. Warmup — read a `.deb` without installing it

1. `ls debs/`. Two files. Decode a filename: what are its three parts?
2. `dpkg -c debs/hatch-log_1.0.0_all.deb`. How many files would it install, and
   where?
3. What are the owner and mode of the file it would put in `/usr/bin`?
4. `dpkg -I debs/hatch-log_1.0.0_all.deb`. Quote the `Description` line.
5. Same command on `hatch-report`. Quote its `Depends:` line, including the
   version constraint.
6. Which of `-c` and `-I` reads the control archive, and which reads the data
   archive? Say how the output told you.
7. Neither command needed `sudo`. Say why in one sentence.
8. `dpkg -I` reports a `conffiles` member. What is in it, and what does listing
   a file there change about `remove` versus `purge` (lesson 01)?

## B. Core — the installed-package database

9. `dpkg -l | head -6`. What are the first two characters of a normal line?
10. `dpkg -l 'deck-*'`. Which states do you see, and why is one of them not
    `ii`?
11. `dpkg -L deck-common`. How many files, and which directories?
12. `dpkg -L deck-report` after lesson 01 purged and reinstalled it — if any
    package on your machine is in `rc` state, run `dpkg -L` on that one. What do
    you get, and why is the list so short?
13. `dpkg -S /usr/bin/ls`. Which package owns it?
14. `dpkg -S` on a file in this lab. What happens, and what is the exit status?
15. Explain in one sentence why exercise 14 came out that way. It is not about
    permissions.
16. `dpkg -s deck-common | head`. Quote the `Status:` line and name its three
    words.
17. Find the file dpkg keeps that status in. It is under `/var/lib/dpkg/`.
18. `grep -c '^Package:' /var/lib/dpkg/status`. Compare against
    `dpkg -l | wc -l`. Explain any difference.

## C. Core — installing by hand

19. `sudo dpkg -i debs/hatch-log_1.0.0_all.deb`. Read every line it prints.
20. Run `hatch-log`. Where on disk is it, and which command told you?
21. `dpkg -l hatch-log`. Which state?
22. `sudo dpkg -i debs/hatch-report_1.4.2_all.deb`. Quote the two-line
    explanation of what went wrong.
23. What is the exit status of that `dpkg -i`? Predict first.
24. `dpkg -l hatch-report`. Which state, and what do the two letters mean
    separately?
25. Now run `hatch-report`. Predict before you press enter. Explain the result
    in terms of what "unpacked" and "configured" each mean.
26. Exercise 25 is the important one in this lesson. Write two sentences on why
    a package that runs is not evidence that a package is installed correctly.
27. `sudo apt-get -f install`. Read what it decided to do. Did it fix
    `hatch-report`?
28. Say why it made that decision rather than the other one. The answer is about
    what apt could and could not find.
29. `dpkg -l hatch-report` now. Which state, and where did the configuration
    file go?
30. Find `hatch-common` somewhere in this lab, install it with `dpkg -i`, and
    then check `dpkg -l hatch-report` again. Explain the state you get.
31. Get `hatch-report` to `ii` from here. Say which command you used and why
    that one.
32. `sudo dpkg -P hatch-report hatch-log hatch-common`, then `dpkg -l 'hatch*'`.
    What is left?

## D. Core — sources

33. `ls /etc/apt/sources.list.d/`. Which files are there, and which one did you
    put there in lesson 01?
34. `cat /etc/apt/sources.list`. What does it contain, and what does that tell
    you about where Ubuntu now expects sources to live?
35. Read `sources/one-line.list`. Name the four positional parts of a `deb`
    line.
36. Read `sources/deb822.sources`. Which field corresponds to `noble` in the
    one-line format, and which to `main restricted`?
37. Which format can name a key file without bracket syntax? Quote the field.
38. Read `sources/unsigned.list` and `sources/ppa-style.list`. State the
    difference in one sentence.
39. What is `deb-src` for, and why does this station not need it?
40. Take the `station.list` in `/etc/apt/sources.list.d/`, copy it aside, remove
    `[trusted=yes]` from the copy, install the copy, remove the original, and
    run `sudo apt update`. Quote the error exactly.
41. Explain that error. Is apt complaining about a bad signature or about
    something else?
42. Put `station.list` back as it was and run `sudo apt update` to confirm you
    are clean. Verify with `apt-cache policy deck-audit`.
43. `apt-cache policy` with no arguments. What does it list, and what is the
    number next to each source?

## E. Experiment — predict first

44. Modify an installed package's file:
    `sudo sh -c 'echo x >> /usr/bin/deck-report'`. Then run
    `dpkg -V deck-report`. What does it print?
45. Predict the exit status of that `dpkg -V`. Check it. Write one sentence on
    what that means for using `dpkg -V` in a script.
46. Decode the `??5??????` output: which position changed, and what does `5`
    stand for? The manual has the table.
47. Repair it with `sudo apt install --reinstall deck-report` and confirm with
    `dpkg -V`.
48. `dpkg -V` with no package name checks everything. Run it. How long does it
    take, and what does it find?
49. Predict what `dpkg -i` does if you give it a `.deb` for a package that is
    already installed at the same version.
50. Predict what `dpkg -i` does with a `.deb` for an *older* version than the
    one installed. Try it with the two `deck-audit` files from lesson 01.

## F. Stretch

51. Write a command that lists every file on this station **not** owned by any
    package, under `/usr/local`. Say why that directory is the interesting one.
52. Write a script (chapter 12 rules) `whoowns PATH` that prints the owning
    package or `unowned`, exiting 0 and 1 respectively. Handle a relative path
    by resolving it first, and say which command you used.
53. Write a command that answers, for one package, "which of its files have been
    modified since installation" — using `dpkg -V`, and cleanly enough to put in
    a report.
54. `shellcheck` anything you wrote.

## G. Dig

55. Find the dpkg option that lists a package's files *from the `.deb`* with
    full paths, and say how it differs from `-L`.
56. Find where dpkg records what it did, with timestamps. Then find the last
    package installed on this station before you started work.
57. Find the difference between `dpkg -r` and `dpkg -P`, in the manual, and
    check it against lesson 01's `remove`/`purge`.
58. Find out what `dpkg --audit` reports, and run it.

## H. Bring it together

59. `notes/page.txt` says `sources.list.d` has a file in it that is not from any
    station build. Using only commands from this lesson, write down what you
    can establish about such a file without accusing anyone: what it points at,
    whether it is signed, and what it has installed.
60. Which command answers "what did this repository put on my machine"? Say
    exactly how you would use it, given that a repository is not recorded on the
    packages it installed. (There is a partial answer only. Say what the gap is.)
61. In two sentences: why does `iU` matter more to an auditor than `rc`?
