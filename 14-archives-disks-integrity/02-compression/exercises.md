# Compression — Exercises

Lab: `/labs/14-archives-disks-integrity/02-compression`

**Do not decompress anything in `logs/`.** That is the constraint the lesson is
about; section A is impossible to fail and pointless to cheat.

## A. Reading without decompressing (1–14)

1. How many lines are in `logs/telemetry-2187-06.log.gz`, uncompressed? Do it
   without writing anything to disk.
2. How many lines across all three months?
3. Print the first two lines of the June log. Which command, and why not `head`
   on the `.gz`?
4. How many `CLAMPED` lines are in each of the three files? Show the one command
   that answers it for all three.
5. Which month has the most?
6. Which decks appear in the June log? In the April log?
7. `zgrep -l` — which of the three files mention `deck-01`?
8. Confirm that `logs/` is unchanged: no `.log` files appeared and the `.gz`
   sizes are the same. Show the command.
9. Run `zgrep CLAMPED` on an uncompressed file — copy `data/records.txt` into
   `scratch/` first and grep for `record 40`. Does `zgrep` work on plain files?
10. Why does that matter to somebody writing a script that processes a log
    directory containing both?
11. Use `zless` on the June log. How do you leave it?
12. `zdiff logs/telemetry-2187-04.log.gz logs/telemetry-2187-05.log.gz | head`.
    What kind of output is that?
13. The April and May `.gz` files are the same size. Are they the same file?
    Prove it.
14. Use `gzip -l logs/*.gz` to find the total uncompressed size of the three
    logs. Would decompressing them actually have been a problem *here*? Answer
    with the number, and then say what the number would have to be for the
    argument in the lesson's opening paragraph to hold.

## B. gzip on one file (15–28)

15. Copy `data/records.txt` to `scratch/`. Gzip it. Is the original still
    there?
16. Restore it with `gunzip`. Is the `.gz` still there?
17. Do it again with `-k`. Now what is in `scratch/`?
18. With both `records.txt` and `records.txt.gz` present, run `gunzip` on the
    `.gz`. Quote what gzip says.
19. Compress the same file at `-1` and at `-9` into two different names. What
    are the sizes?
20. Is the difference worth anything for this file? Answer with the numbers.
21. `gzip -l data/records.txt.gz`. What are the three numbers it reports?
22. Does `gzip -l` decompress the file? Say how you know from how fast it is
    and from what it can report.
23. `gzip -l` reports the uncompressed size from a 32-bit field in the trailer.
    What does it therefore report for a 5 GB file, and why is that worse than
    reporting nothing?
24. `gzip -t data/records.txt.gz`. What does it print, and what is the exit
    status?
25. `gzip -t data/truncated.gz`. Quote the error and give the exit status.
26. `file data/truncated.gz`. Does `file` agree with the extension?
27. `gzip -t data/half.log.gz`. Quote the error and the exit status.
28. `file data/half.log.gz`. Does `file` agree it is a gzip file? Explain in
    two sentences why `file` and `gzip -t` disagree, and which you would put in
    a verification script.

## C. Three compressors (29–38)

29. `ls -l data/records.txt*`. List the four sizes.
30. Rank gzip, bzip2 and xz by size on this file. Give the ratios against the
    original.
31. Decompress each into `scratch/` under a different name (keep the originals)
    and confirm all three give byte-identical output with `cmp`.
32. Which of the three commands took noticeably longer? Is that a fair test at
    46 KB?
33. `zcat data/records.txt.bz2`. What happens? Quote it.
34. What is the right command for a `.bz2`? For an `.xz`?
35. `ls -l data/sensor-raw.bin data/sensor-raw.bin.gz`. Which is larger, and by
    how many bytes?
36. Explain the direction of that result in one sentence.
37. Name two other kinds of file where compressing again would gain nothing.
38. A backup script gzips everything it copies. On a directory of JPEGs, what
    does it cost and what does it gain?

## D. zip, which you have to install (39–48)

39. Is `zip` installed? Show the command that answers it without guessing from
    `which` alone.
40. Is it available to install? Which repository and which version?
41. Install `zip` and `unzip`.
42. Where did the binaries land? Which package put them there?
43. `zip -r scratch/records.zip data` — how large is the result compared with
    `data/records.txt.gz`?
44. `unzip -l scratch/records.zip`. What does the listing show that
    `tar -tzf` does not?
45. Extract it into `scratch/unz` with `-d`. What is the top-level entry?
46. Does `unzip` overwrite silently the way `tar` does? Run it twice into the
    same directory and quote what it asks.
47. Name one thing `zip` does that `tar -czf` does not, and one thing `tar`
    does that `zip` does not.
48. Purge `zip` and `unzip` again. Confirm they are gone.

## E. Judgement (49–56)

49. A colleague says "the disk is full, I'll gunzip the logs to search them."
    What do you say, in one sentence?
50. Another says "I'll compress the logs again with xz to save space." The logs
    are already `.gz`. What actually happens?
51. You need to know whether a 4 GB `.gz` on a nearly full disk is intact. Which
    command, and what does it cost in disk space?
52. `gzip -l` says a file is 800 MB uncompressed. What could make that number
    wrong?
53. A script does `gzip *.log` in a directory that another process is writing
    to. Name the problem.
54. Why is `zgrep` on three compressed months better than one combined
    uncompressed file, even when disk space is not tight?
55. When is `tar -czf` the wrong tool and plain `gzip` the right one?
56. Write the one-line rule you would give a new cadet about `gzip`'s default
    behaviour.
