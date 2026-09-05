# Exercises — Forensics

Work in `/labs/15-capstone-kestrel-breach/03-forensics`. Nothing here needs
`sudo`. Nothing here should be modified — if you change an mtime you have
destroyed the artefact, so copy before you experiment.

## A. Warmup

1. `cd` into the lab. List the three evidence trees and the two scaffolding
   directories. Which is which, and how can you tell without opening anything?
2. Count the regular files under the lab. Count the symlinks. Count the
   directories.
3. Run `ls -l engineering/audit/`. Write down the timestamp it shows for
   `checksums-2186.txt`.
4. Now run `stat engineering/audit/checksums-2186.txt`. What did `ls -l` not
   tell you?
5. Which of the three timestamps in that output is the same for almost every
   file in the lab, and what does that tell you about how this tree got here?

## B. The three timestamps

6. Print name, mtime and ctime for every file in `engineering/`, one per line,
   using a single `stat -c` call.
7. Every file in this lab has an mtime *later* than its ctime. Explain how that
   is possible at all, and give two different innocent explanations for it.
8. Does `stat` report a birth time on this filesystem? Quote the exact line, and
   say why it is useless to you here.
9. `cat home/dorn/notes-recert.txt`, then `stat` it again. Did the mtime
   change? Did the atime? Did the ctime?
10. Copy `home/cass/rota.txt` to `/tmp/rota-plain.txt` with plain `cp`, and to
    `/tmp/rota-a.txt` with `cp -a`. `stat` all three. Which timestamps survived
    which copy?
11. You have been handed a file and told it was written on a particular date.
    Which single timestamp would you ask to see, and what could still have
    produced that value without the claim being true?

## C. Building the timeline

12. Read `bin/timeline`. What does the last block do, and what does that mean
    for anything it reports?
13. Run `./bin/timeline .`. Note that one line comes out on stderr. Rerun so
    that stdout goes to a file and stderr stays on your screen.
14. Reproduce the timeline yourself with one `find -printf` piped to `sort -n`,
    without using `bin/timeline`.
15. How many distinct calendar dates appear in the timeline?
16. What is the oldest artefact, and what is the newest artefact that is *not*
    part of the scaffolding?
17. Three files carry the mtime `2187-06-14 07:30`. What do those three have in
    common, and why should none of them appear in your case file as evidence?
18. Restrict the timeline to files modified between 2187-05-15 and 2187-05-20
    inclusive, using `-newermt`. How many?
19. Do the same using `-newer` with a reference file instead of a date string.
    Which reference file did you pick, and why is that answer not unique?
20. Add the owner to your timeline output. Which accounts appear?
21. `find . -user rhea -type f`. How many, and in which trees?
22. Same for `dorn`, `cass`, `ops-bot`. Write the four counts down.

## D. The two clusters

23. Look at your timeline between 05-15 and 05-17. List those artefacts with
    their owners.
24. Now look at 05-19 23:58 through 05-20 01:31. List those with their owners.
25. State the gap between the two clusters in hours. Show the arithmetic.
26. In one sentence each, and with no motive in either: what kind of activity
    does the first cluster consist of, and what kind does the second?
27. Which single artefact in the second cluster is *inside* the first cluster's
    tree? What is the significance of it being owned by a different account
    from everything around it?
28. Is `home/cass/rota.txt` in either cluster? Give the date, and say what it
    is doing in this lab.
29. `home/ops-bot/.bashrc` has an mtime of 05-19 23:58, which puts it at the
    start of the second cluster, but it is owned by neither of the two accounts
    doing the checking. Write this down as an anomaly. Do not explain it.
30. Write a claim file for the earliest artefact in each cluster. Six fields.
    The `means` line must say "cluster" and must not say "someone".

## E. Comparing

31. `diff` the two checksum files in `engineering/audit/`. How many lines
    differ, ignoring the comment header?
32. For each differing line, say whether the hash changed a lot or a little.
    What is the difference between those two cases?
33. One of the two changed hashes differs from the original by a single
    character. Find which character, in which position.
34. What are the two obvious explanations for a one-character hash difference,
    and how would you tell them apart if you had the original files?
35. You do not have the original files. Confirm that: try to hash
    `2186-q3.dat`. What happens?
36. `diff station/summariser/strain-summary.orig station/summariser/strain-summary`.
    Describe the change in behaviour in one sentence, in terms of what the
    program does to a value above 6.
37. What are the mtimes of those two files, and how far apart are they?
38. Is `.orig` older or newer than the live script? What would you expect if
    someone had made a backup *before* editing, and does this match?
39. `grep` for `STRAIN_TOLERANCE` across the whole lab. Which two files mention
    it, and what is the relationship between them?
40. `station/var/deck3-report.txt` reports `exceedances 0` and
    `peak reported 6.0`. Given exercise 36, write a `says` line and a `means`
    line for that report. The `means` line is the most careful sentence you
    will write today.

## F. Manifests and mounts

41. `engineering/manifests/MANIFEST-2186.txt` lists six files. How many of them
    exist anywhere under this lab?
42. The manifest's header names a source path. Does that path exist? What is
    the one command that answers this, and what is its exit status?
43. Multiply out the manifest's byte counts. What is the total, and is that a
    plausible size for a year of raw strain data at one sample a second? Say
    what you assumed.
44. The checksum file lists four `.dat` files; the manifest lists six entries.
    What are the two extra ones, and what is the difference between a `.dat`
    and a `.sum`?
45. `station/mounts/raw-strain` — what kind of thing is it, where does it
    point, and what happens when you `cat` it?
46. Why is it absent from `bin/timeline`'s output? Point at the line of the
    script responsible.
47. Modify your own `find` pipeline from exercise 14 so the symlink *does*
    appear, with its own mtime rather than its target's.
48. What is the symlink's mtime, and where does it fall relative to your two
    clusters?
49. Write the symlink's claim file. The `says` line must describe what is on
    disk. It must not assert that the target ever existed.

## G. Stretch

50. Produce a single command that prints the timeline as
    `YYYY-MM-DD HH:MM  owner  path`, sorted, with the scaffolding files
    excluded.
51. Write `bin/mine` — a script taking a directory, printing every file in it
    not owned by the invoking user, newest first. Handle a directory with no
    such files by printing nothing.
52. `find` has `-newerXY` where X and Y each select a timestamp. Read
    `man find`, then explain what `-newerct` selects and give one investigation
    where it beats `-newermt`.
53. Sort the timeline by ctime instead of mtime. What order do you get, and why
    is it useless here?
54. Suppose you wanted to make an edit today look like it happened in October.
    Which timestamps could you fake, which could you not, and what would that
    combination look like to someone doing this exercise?

## H. Dig

55. `stat -c '%y %z'` prints nanoseconds. Do any two artefacts in this lab
    share a timestamp to the nanosecond? What would it mean if a set of files
    did?
56. `find -printf` has a `%T+` directive as well as `%T@`. Compare them, and
    say which one sorts correctly as a plain string and why that is convenient.
