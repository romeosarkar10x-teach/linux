# 13/01 — exercises

Lab: `/labs/13-packages-docs-editors/01-apt`.

You have `sudo` on this station. Use it only where the command needs it, and
notice when you were about to use it and did not have to.

## A. Warmup — read before you install

1. `ls repo/`. How many `.deb` files, and how many distinct package names?
2. Which package appears twice, and in which two versions?
3. `cat repo/Packages`. How many stanzas does it have, and what separates them?
4. Find the `Filename:` line for one package. Is the path absolute or relative,
   and relative to what?
5. `cat repo/station.list`. Quote the URL it names.
6. What does `[trusted=yes]` appear before, and what do you think it applies to?
   Write your guess down; lesson 02 will grade it.
7. Read `notes/apt.txt`. Which of the eight commands listed there change the
   system?
8. `apt list --installed | wc -l`. Roughly how many packages is this station
   running?
9. `apt list --installed | head -3`. What are the three fields on a line?
10. Without running it, predict the output of `apt search deck-report` right
    now. Then run it. Explain the result in one sentence.

## B. Core — the catalogue

11. Explain, in one sentence each, the difference between `apt update` and
    `apt upgrade`.
12. Copy `repo/station.list` into `/etc/apt/sources.list.d/`. Which of the
    two — the copy or the original — does `apt` read?
13. Run `sudo apt update`. What does it say about the `file:` source?
14. Run `apt search deck` again. What changed, and why did nothing about your
    installed software change with it?
15. `apt show deck-report`. Quote its `Depends:` line.
16. `apt show deck-report` also has an `APT-Sources:` line. What does it tell
    you, and why is that field worth knowing about?
17. `apt list -a deck-audit`. Why two lines?
18. What does the `/unknown` in `deck-audit/unknown 2.1.0 all` mean? Compare
    against a line from `apt list -a bash`.
19. `apt show deck-audit` with no version. Which of the two versions does it
    describe, and what rule did it use to pick?

## C. Core — installing

20. Install `deck-report`. Read the list of packages `apt` says it will install
    **before** confirming, and write it down.
21. How many packages did you ask for, and how many were installed?
22. Run `deck-report` and `deck-common`. Where did the second one come from?
23. `dpkg -l 'deck-*'`. What is in the first two characters of each line? (You
    will meet this properly in lesson 02; a guess is fine here.)
24. `apt-mark showmanual | grep deck`. Which of the two is listed, and why only
    that one?
25. Install a specific version: `sudo apt install deck-audit=2.0.1`. Confirm
    with `deck-audit`.
26. `apt list --upgradable`. What does it say, and why did installing an old
    version on purpose produce that?
27. `sudo apt upgrade`. What did it change, and what did it leave alone?
28. Run `deck-audit` again. Now explain what `upgrade` actually did in terms of
    files on disk.

## D. Core — removing

29. `cat /etc/deck-report.conf`. Which package put that file there?
30. Add a line to it with `sudo tee -a` — anything you like. This is your
    "local configuration".
31. `sudo apt remove deck-report`. Is `/etc/deck-report.conf` still there?
32. `dpkg -l deck-report`. It is still listed. Quote the first two characters
    and say what state that is.
33. `sudo apt purge deck-report`. Now check the file and `dpkg -l` again.
34. Your edit from exercise 30 is gone. Was that the right behaviour for a
    command named `purge`? Answer in one sentence, then say what you should
    have done first.
35. `sudo apt autoremove`. What did it remove, and which exercise made that
    package removable?
36. Predict what `sudo apt remove deck-common` would have printed if
    `deck-report` had still been installed. Then reinstall both and check.
37. What is the difference between the list `apt` prints under "The following
    packages will be REMOVED" and the list you asked for?

## E. Experiment — predict first

38. Predict the exit status of `apt show no-such-package-here`. Then run it and
    check with `echo $?`.
39. Predict what `apt install deck-repot` (typo) does. Run it. Would `sudo` have
    made it worse?
40. Run `apt list --installed | head -2` and read the first line of output
    carefully. What is `apt` warning you about, and what should you use instead?
41. Try the same reasoning with `apt-get`: run `apt-get search deck` and read
    the error. Then find which command in the `apt-*` family does that job in a
    script, and check whether it warns when piped.
42. `apt search deck | wc -l` versus `apt-cache search deck | wc -l`. Explain
    the difference in the two outputs' shape.
43. `apt show deck-report 2>/dev/null | grep Size`. What are the two size
    fields, and why can one of them be `unknown` here?
44. Remove the `.list` file from `/etc/apt/sources.list.d/` and run
    `apt search deck` again — but predict the result first. Then put it back and
    run `sudo apt update`.
45. Take a `md5sum` of every file under `/etc/apt/sources.list.d/` before and
    after one `apt update`. Does `update` write there?
46. Where **does** `apt update` write? Find the directory, and say what you
    would look at there to answer "when did this machine last refresh its
    catalogue".

## F. Stretch

47. Write a one-line command that lists every installed package whose name
    starts with `deck`, using `dpkg`, not `apt`.
48. Write a script (chapter 12 rules: shebang, `set -euo pipefail`, `--help`,
    exit codes) that takes a package name and prints `installed`, `removed` or
    `absent`. Use `apt-get`/`dpkg`, never `apt`, and say why in a comment.
49. Extend it to exit 0, 1, 2 for those three states, and document the codes in
    the header.
50. `shellcheck` it. Fix or justify every finding.

## G. Dig

51. Find the option that makes `apt install` show what it would do without doing
    it. Use it on `deck-report`.
52. Find the option that answers `y` for you, and say when using it is
    reasonable and when it is how you lose a machine.
53. `apt-cache policy deck-audit`. Read the version table and say what the `500`
    is.
54. Find where downloaded `.deb` files are kept after an install, and the
    command that empties it. Then say why that directory is empty on this
    station after you installed three packages.

## H. Bring it together

55. rhea asked for `deck-report` on the maintenance account tonight and did not
    ask where the repository came from. In two sentences, say what you would
    tell her — factually, with no accusation in it.
56. Write down the exact sequence of commands you would run on a machine you
    had never seen, to answer "is package X installed, from where, and at what
    version". Four commands or fewer.
57. `remove` versus `purge`: state the rule you will actually follow from now
    on, in one sentence, and the one case where you would deliberately break it.
