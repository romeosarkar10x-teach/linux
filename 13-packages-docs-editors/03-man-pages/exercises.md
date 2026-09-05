# 13/03 — Exercises

Work in `/labs/13-packages-docs-editors/03-man-pages`.

```
cd /labs/13-packages-docs-editors/03-man-pages
ls
cat notes/man.txt
```

Everything here is read-only reference and a manual page tree of your own. You
will not need `sudo` at any point in this lesson.

## A. Sections

1. Run `man passwd`. Which section did you get? The header line says.
2. Run `man 5 passwd`. What is this page about instead?
3. Explain in one sentence why both pages exist under the same name.
4. Without running it, predict what section `man chmod` gives you. Then check.
5. `man 2 chmod` — what is this page describing that section 1 is not?
6. `man -f printf` prints more than one line. Read them and say what the
   difference between the two `printf`s is.
7. `man -a printf` shows you the pages one after another. How do you get from
   the first to the second, and how do you quit out of the sequence?
8. Which section holds the format of `/etc/sudoers`? Find it without guessing
    twice. Then try the same for `/etc/fstab` and report what you get.
9. Read `man 7 signal`'s NAME line only, using a command that prints just that.
10. Give the section number for each: `ls`, `open`, `sudoers`, `chmod` (the
    command), `chmod` (the system call), `signal` (the overview, not the
    system call).

## B. Finding a page by what it does

11. You want to change a file's timestamps and cannot remember the command.
    Use `apropos` to find it.
12. `whatis touch` and `apropos touch` give different amounts of output.
    Explain the difference in one sentence.
13. `man -k` and `apropos` — run both with the same argument. What do you
    conclude?
14. Count how many manual pages this station has an index entry for:
    `man -k . | wc -l`. Write the number down.
15. Restrict that count to section 5 only. Which flag did you use?
16. `apropos -e passwd` versus `apropos passwd`. What does `-e` change?
17. `apropos -r '^deck'` — what does `-r` change?
18. Find every page whose description mentions "hostname".
19. Use `man -K` to find a page containing the word `getpwnam` in its body,
    not in its description. Time it and compare against `apropos`.
20. Say when you would reach for `-K` and when you would not.

## C. Your own manual pages

21. `ls man/man1 man/man5 man/man8`. How many pages are here, and how do you
    know which section each belongs to without opening it?
22. Try `man deck-cycle`. It fails. Why?
23. Read it with `MANPATH=$PWD/man man deck-cycle`.
24. What is the exit status of `deck-cycle` when a deck is skipped?
25. Read `deck-cycle.conf(5)` the same way. What is the default settling time
    for a deck the file does not mention?
26. The `deck-cycle(1)` page points at another page in its SEE ALSO. Follow it.
27. `MANPATH=$PWD/man man -w deck-cycle` — where is the file, and what format
    is it in? (`file` and `head` will both tell you something.)
28. There is a second copy of that page in `man/man1`. Find it, and say what is
    different about the file itself.
29. Read the archived copy with `man`. Did you have to decompress it first?
30. `MANPATH=$PWD/man apropos deck` — what happens, and why?
31. Read `notes/mandb.txt` and build the index.
32. Re-run exercise 30. How many pages does it find?
33. `ls man/`. What did `mandb` add?
34. `MANPATH=$PWD/man man -k . | wc -l`. You have four pages in that tree. What
    number did you get?
35. Which page is missing from the index? Open it with `man` — it displays
    perfectly. State the contradiction precisely.
36. Compare its source against `deck-cycle.1`. What does one have that the
    other does not?
37. Run `lexgrog man/man8/hatch-tally.8` and then `lexgrog man/man1/deck-cycle.1`.
    What is `lexgrog` doing, and what does it say about the first one?
38. Fix your own copy: `cp man/man8/hatch-tally.8 scratch/`, add the missing
    section, and prove it by indexing `scratch` and running `whatis` against it.
    (You may not have write permission on the original — that is intentional.)

## D. Where pages live

39. `manpath`. Write down the directories in order.
40. `man -w ls`. Is that path in the list from exercise 39? Which entry
    matched?
41. `man -w -a printf` prints three paths. Explain why there are three.
42. Which of the three would plain `man printf` open, and what rule decides it?
43. `ls /usr/share/man/`. Some entries are two-letter names. What are they?
44. How many pages are in `/usr/share/man/man5`?
45. `man -w nosuchpage` — what does it print and what is its exit status?
46. `man nosuchpage; echo $?` — the same status. Now run
    `man nosuchpage 2>&1 | head -2; echo $?` and explain the difference.

## E. When there is no page

47. `man cd` fails. `help cd` works. Explain, using `type cd`.
48. `type -a printf` prints four lines on this station. Read them, and say
    which of them `man printf` documents.
49. Find a command on this station whose `--help` output is more current than
    its manual page, or argue from what you have seen that you cannot tell.
50. `whereis ls` prints three kinds of thing. Name them.
51. `man man` itself prints a warning line on this station about a page it
    cannot resolve. Find it, and explain what that says about the image.

## F. Stretch

52. Write a shell function `mans() { ...; }` that takes a word and prints
    `apropos` results sorted by section number.
53. Write a script that, given a command name, prints its manual page's NAME
    line if it has one, its `--help` first line if not, and a clear message if
    neither exists. Exit status must distinguish the three cases.
54. Run your script under `shellcheck` and fix what it reports.
55. Use `man -w` in a loop to report, for every command in `/usr/local/bin` (or
    `/opt/kestrel/bin` if that is empty), whether it has a manual page at all.

## G. Bring it together

56. `notes/page.txt` says `deck-audit`'s page names a file its package does not
    ship. Using lesson 02's tools, establish whether that is true on this
    station, and write two sentences that state only what you verified.
57. You are handed a machine with no network. List, in order, the four things
    you would try to answer "what does this configuration file mean", and say
    what each one gives you that the previous one did not.
