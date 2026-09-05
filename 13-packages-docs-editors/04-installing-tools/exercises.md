# 13/04 — Exercises

Work in `/labs/13-packages-docs-editors/04-installing-tools`.

```
cd /labs/13-packages-docs-editors/04-installing-tools
ls
cat notes/tools.txt
```

This lesson installs software. Some exercises need `sudo`; the ones that do say
so. Section F puts everything back.

## A. What is already here

1. `cat notes/candidates.txt`. Which of the seven do you expect to be present?
2. Check each with `command -v`. Which are actually there?
3. One of them is not called what you would guess from the list. Which, and
   what is it called?
4. `htop` runs. What does `apt-cache policy htop` say about whether it is
   installed?
5. Explain that contradiction in two sentences. `man -w htop` is a hint.
6. `dpkg -S "$(command -v jq)"` — what do you get, and why?
7. State the rule you should follow from now on: when you want to know whether
   a command exists on a machine, what do you run?
8. `type -a ls` prints more than one path. Which one runs, and what decides it?

## B. From the archive

9. You want an interactive disk usage browser. Find it with `apt search`
   without knowing its name.
10. `apt show ncdu` — what section is it in, and how big is it installed?
11. Install it (`sudo`). Read the last four lines of the output and say what
    the `Processing triggers for man-db` line was doing.
12. Run `ncdu /labs`. Quit with `q`. What does it show you that `du -sh` does
    not?
13. `dpkg -l ncdu` — what state?
14. `dpkg -L ncdu | wc -l`, and find its manual page in that list.
15. Now install `ripgrep`. What is the command it provides? (It is not
    `ripgrep`.)
16. Where does `dpkg -L ripgrep` say the binary went, and is that a directory
    you were told never to write to by hand?
17. Compare `rg -l deck /labs | wc -l` against `grep -rl deck /labs | wc -l`.
    The numbers differ. Find a file that one reports and the other does not.
18. From that difference, state one thing `rg` does by default that `grep -r`
    does not. (Create a directory containing a dotfile and test your theory.)
19. `apt-cache policy ripgrep` now. Compare its `Installed:` line against
    exercise 4's.

## C. From a tarball

20. `ls dist/`. What is in there, and what does the name tell you before you
    open it?
21. `tar -tzf dist/deck-tools-1.3.tar.gz`. How many files, and is there exactly
    one top-level directory?
22. Explain why exercise 21 comes before extracting, and what would have gone
    wrong if the archive had been built badly.
23. Extract it into `scratch/`.
24. `cat scratch/deck-tools-1.3/README`. What does it say about installing?
25. Run `deck-lint` from where you extracted it, against
    `scratch/deck-cycle.conf`. What does it report?
26. What is its exit status? Check the manual page in the tarball for what that
    status means — without installing anything.
27. Two of the lines in that config are rejected. For each, say exactly what is
    wrong with it.
28. Fix `scratch/deck-cycle.conf` so `deck-lint` passes. What is its exit
    status now?
29. `deck-lint --quiet` on the broken file and on the fixed one. What is the
    difference, and why would a script want that?
30. Install it, following the README (`sudo`). Which two directories did you
    copy?
31. `command -v deck-lint`. Which prefix is it in?
32. Why did you not have to change `PATH`?
33. `man deck-lint` — does it work? What about `whatis deck-lint`?
34. If `whatis` fails, fix it with what you learned in lesson 03, and say why
    `sudo` was needed this time when it was not needed then.
35. `dpkg -S "$(command -v deck-lint)"`. What do you get?
36. `dpkg -l | grep -i deck-tools`. What do you get?
37. Write down, in one sentence each, the three things you have just lost by
    installing this way.

## D. Prefixes

38. `echo "$PATH" | tr ':' '\n'`. Where does `/usr/local/bin` sit relative to
    `/usr/bin`?
39. Suppose a package later installs `/usr/bin/deck-lint`. Which one would run?
40. Is that the behaviour you want? Argue either way, but argue.
41. `manpath` — is `/usr/local/share/man` on it? `ls -ld /usr/local/man`, and
    explain what you find.
42. Install `deck-lint` a second time into `~/.local/bin` instead. Does it run?
43. If it does not, what is missing, and what would you add to which file to
    fix it for future logins?
44. Give one reason to prefer `~/.local/bin` over `/usr/local/bin`, and one
    reason to prefer the opposite.
45. What is `/opt` for, and which directory on this station is a live example?

## E. Judgement

46. You need a tool. It is in the archive at version 1.2, and upstream is at
    2.0 as a tarball. Which do you take, and what would change your mind?
47. A blog post tells you to `curl ... | sudo bash`. Write two sentences on what
    that does that route one does not.
48. Your script needs `jq`. What should it do at start-up, and what should it
    do if `jq` is missing?
49. Write that check. It must not install anything and must exit non-zero with
    a message naming the missing tool.
50. `shellcheck` your check and fix what it says.
51. You are asked to make `deck-lint` available to every user on the station,
    surviving upgrades and removable in one command. What would you do
    instead of route three? You do not have to build it — describe it.

## F. Put it back

52. Purge `ncdu` and `ripgrep`. Which command, and what is the difference from
    `remove` here?
53. Remove the hand-installed `deck-lint` and its manual page. How did you know
    which files to delete?
54. Rebuild the manual index and confirm `whatis deck-lint` no longer finds it.
55. `command -v rg ncdu deck-lint` — should print nothing and exit non-zero.
56. `dpkg --audit`. Should be silent.

## G. Bring it together

57. Write a script `tool-report` that prints, for each command name given to it:
    the path that would run, the package that owns it if any, and `unpackaged`
    if none. Test it on `ls`, `jq`, and a file under `/labs`.
58. Run it against every file in `/usr/local/bin`. What is the result on a
    clean station, and what would a non-empty result mean?
59. `notes/page.txt` makes a claim about what `/usr/local` does not record.
    Verify it: install `deck-lint` again, and find any station-wide record of
    when it appeared or who installed it. Report what you found, including
    nothing. Then remove it again.
