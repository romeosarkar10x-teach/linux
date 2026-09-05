# tar — Exercises

Lab: `/labs/14-archives-disks-integrity/01-tar`

Extract into `scratch/` and nowhere else. Every exercise assumes you are in the
lab directory.

## A. Listing (1–12)

1. List the contents of `archives/deck-logs-2187.tar`. How many lines?
2. List `archives/deck-logs-2187.tar.gz`. Same output? Which flag did you need,
   and did you actually need it?
3. Add `-v` to the previous command. Name three things `-v` shows you that the
   plain listing did not.
4. Does either listing command create, change or extract a file? Say how you
   would prove it.
5. List `archives/hatch-tally.tar.bz2` without giving any compression flag.
   Does it work?
6. Now list it with `-j`. Same result?
7. List `archives/calibration-export.tar.gz`. How many members, and how many of
   them are directories?
8. Does `calibration-export.tar.gz` have a single top-level directory? What
   would happen if you extracted it in your home directory?
9. List `archives/strain-export.tar.gz`. How many path components are there
   before the first real file?
10. List `archives/etc-backup.tar`. What does tar print before the member list,
    and is it an error?
11. Do the member names in `etc-backup.tar` start with a `/` or not? Say what
    the printed warning actually means.
12. Use `--wildcards` to list only the `deck-04` files inside
    `deck-logs-2187.tar.gz`. How many are there?

## B. Extracting safely (13–26)

13. Make `scratch/logs` and extract `deck-logs-2187.tar.gz` into it with `-C`.
    What is the top-level entry inside `scratch/logs`?
14. Without deleting anything, extract it again into the same place. What did
    tar print? What did it do to the files that were already there?
15. Extract only `deck-logs-2187/README` from the archive into `scratch`. Show
    the command. What is in `scratch` afterwards?
16. Make `scratch/bomb` and extract `calibration-export.tar.gz` into it. How
    many entries are in `scratch/bomb` now?
17. Explain in one sentence why exercise 16 needed `-C` more than exercise 13
    did.
18. Extract `strain-export.tar.gz` into `scratch/strain` with no
    `--strip-components`. What is the path to `strain.tsv` from `scratch`?
19. Delete that and re-extract with `--strip-components=4`. What is the path
    now?
20. Try `--strip-components=6`. What happens to the members, and does tar
    report an error?
21. Extract `etc-backup.tar` into `scratch/etc-test`. Where did `clamp.conf`
    land — under `scratch/etc-test`, or under the real `/etc`?
22. Was the real `/etc/kestrel` touched? Show the command that answers that
    without guessing.
23. `--absolute-names` on extract would have changed exercise 21. Say what it
    would have tried to do and why you would not run it here.
24. Extract `hatch-tally.tar.bz2` into `scratch/tally`. How many `.tsv` files?
25. `cat` one of them. Are the tabs real tabs? How did you check?
26. Remove everything under `scratch/` in one command, leaving `scratch` itself.

## C. Creating (27–38)

27. Make a directory `scratch/mine` containing three small text files.
28. Create `scratch/mine.tar` from it, uncompressed. Show the command with `-f`
    in the right place.
29. List your archive. Are the member names `mine/a.txt` or `scratch/mine/a.txt`
    — and what decided that?
30. Create a gzipped version, `scratch/mine.tar.gz`. Compare the two sizes with
    `ls -l`.
31. Create a bzip2 version. Which of the three is smallest at this size, and is
    that a useful conclusion from three text files?
32. Run `tar -cfz scratch/oops.tar.gz scratch/mine`. Quote tar's error exactly.
33. After exercise 32, is there a file named `z` in your current directory?
    What is in it?
34. Delete `z`. Write the command exercise 32 should have been.
35. Create an archive of `mine` using `-a` and the filename `scratch/mine.tgz`.
    Did tar compress it? How did it decide?
36. Use `-C` on **create** to archive `mine` without the `scratch/` prefix in
    the member names. Show the command.
37. Add `-v` to a create command. Which stream does the member list go to —
    stdout or stderr? Show how you checked (Chapter 8).
38. Create an archive of a directory that does not exist. What is tar's exit
    status?

## D. Reading the archives you were given (39–48)

39. Without extracting anything, how many `.log` files are inside
    `deck-logs-2187.tar.gz`?
40. Which decks appear in it?
41. Run `file` on all seven files in `archives/`. Which one's output disagrees
    with its name?
42. Quote `file`'s output for `spare-logs.tar.bz2` exactly.
43. Run `tar -tjf archives/spare-logs.tar.bz2`. Quote the first line of the
    error, and give the exit status.
44. Run `tar -tf archives/spare-logs.tar.bz2`. Does it work? Why does the wrong
    flag fail where no flag succeeds?
45. `spare-logs.tar.bz2` and `deck-logs-2187.tar.gz` are the same size. Compare
    them byte for byte with `cmp`. What are they?
46. Run `tar -tzf archives/nosuch.tar.gz`. What is the exit status, and is it
    different from exercise 43's?
47. `du -b archives/deck-logs-2187.tar` and the `.gz`. What is the ratio, and
    why is it so extreme for this particular content?
48. Why is the uncompressed `.tar` exactly 20480 bytes and not some arbitrary
    number?

## E. Judgement (49–56)

49. You are handed an archive by someone else. Write the two commands you run
    before you run anything else, in order.
50. Your colleague extracted an archive in their home directory and now has
    nine loose config files mixed into it. What one flag would have prevented
    it, and what one command would have warned them?
51. tar overwrites without asking. Name one situation in this lab where that is
    exactly what you wanted, and one where it would have cost you.
52. A backup script does `cd /etc && tar -czf /backup/etc.tar.gz .`. Why the
    `cd`, and what would the member names look like without it?
53. Someone suggests `--absolute-names` on create so the archive "remembers
    where things go". Give the argument against in two sentences.
54. `-t` on a 4 GB archive over a slow disk takes real time. Is there any way
    to know an archive's contents without reading it? Say why not.
55. You need one file out of a 4 GB archive. Do you extract the whole thing?
    Show the alternative.
56. Write the one-line rule you would put in a handover note about extracting
    archives.
