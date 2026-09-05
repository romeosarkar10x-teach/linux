# Exercises — The briefing

Work in `/labs/15-capstone-kestrel-breach/01-the-briefing`.

**Standing rule for this chapter:** nothing in `brief/` or `station/` is
modified. Ever. Copy into `case/` or into a scratch directory you make
yourself. If you change a byte under `station/`, run
`kestrel reset 15-capstone-kestrel-breach/01-the-briefing` and start again.

## A. Warmup

1. `cat brief/rules-of-engagement.txt`. Which rule number is the one about
   sourcing a conclusion?
2. Which rule tells you when to take the hash, and what is its reason?
3. `stat -c '%n %s %y' brief/handover/notes.txt`. What is the size in bytes,
   and what is the mtime?
4. `cat brief/handover/notes.txt`. What does the previous sysadmin's handover
   file contain, in full?
5. `sha256sum brief/handover/notes.txt`. Write the first eight characters down.
6. `cat brief/deck-3-recert-notice.txt`. What month is the deadline, and how
   many crew berth on deck 3?

## B. Core — sourcing an artefact

7. `stat -c '%a %U %G %s' station/summariser/run.log`. Read the four values
   back in words.
8. Get the mtime of the same file as a Unix timestamp instead. Which `stat`
   format letter did you use?
9. `sha256sum station/summariser/run.log`. Full hash, written down.
10. Do the same three steps for `station/audit/MANIFEST.txt` and for
    `station/mounts/raw-strain`. One of them behaves differently — which, and
    what happened?
11. `sha256sum` on the symlink failed or hashed something unexpected. Explain
    what `sha256sum` actually tried to do, using the word "dereference".
12. `cat case/TEMPLATE.md`. What are the six fields, and which two are the
    says/means split from the notes?
13. `cp case/TEMPLATE.md case/artefacts/claim-01.md`. Fill it in for
    `station/summariser/run.log`. Leave `says` and `means` as placeholders for
    now.
14. `bin/roe-check case/artefacts/claim-01.md`. What exit code, and what is it
    complaining about? Check `$?` explicitly.
15. Fill in `says` with one sentence describing what is literally in the run
    log. Re-run `roe-check`. Exit code now?
16. Fill in `means`. Re-run. Exit 0?
17. Deliberately break the `sha256` field by deleting one character. What exit
    code, and what does the message say? Restore it.
18. Deliberately point `artefact:` at a path that does not exist. Exit code?
    Restore it.
19. Delete the whole `mtime:` line. Exit code, and how is it different from
    exercise 17's? Restore it.

## C. Core — the three sample artefacts

20. `wc -l station/summariser/run.log`. How many lines?
21. `head -2` and `tail -2`. What date range does the log cover?
22. Is any *date* missing from that range? Show the command you used to decide,
    not just the answer.
23. Now look at the `seq=` numbers. Extract just the sequence numbers into a
    sorted list. Which chapter-7 tool did you use, and why that one?
24. Are the sequence numbers contiguous? Find the gap without reading all 26
    lines by eye.
25. How many numbered records are missing, and between which two timestamps?
26. Write the `says` sentence for this artefact. It must contain the line
    count, the date range, and the two sequence numbers either side of the gap,
    and it must not contain the word "deleted".
27. Write the `means` sentence. One sentence. It may say what you think; it may
    not name a person.
28. `ls -l station/mounts/`. What type is `raw-strain`, and what does it point
    at?
29. `cat station/mounts/raw-strain`. What is the exact error?
30. `test -e station/mounts/raw-strain; echo $?` and then `test -L` the same
    path. Explain both exit codes in one sentence each.
31. `stat station/mounts/raw-strain` versus `stat -L station/mounts/raw-strain`.
    What is the difference, and which one errors?
32. `cat station/audit/MANIFEST.txt`. How many files does it list, what is the
    total number of bytes it accounts for, and what date does its header claim?
33. Do any of those files exist anywhere under this lab? Show how you checked.
34. Write one claim file for the symlink and one for the manifest. Both must
    pass `roe-check`.

## D. Experiment — predict first, then run

For each of these, **write your prediction down before you run anything**, then
run it, then write one sentence on the difference.

35. Predict: does `sha256sum` on a symlink hash the link's own bytes (the target
    path string) or the target's contents? Then test it on a symlink you make
    yourself in a scratch directory, pointing at a file that *does* exist.
36. Predict: if you `cp` a file out of `station/` into `case/`, does the copy
    keep the original's mtime? Test it. Then test `cp -p`. Which rule of
    engagement does this bear on?
37. Predict the exit code of `roe-check` on a claim file that is perfectly
    formatted but describes the wrong artefact entirely — right hash, wrong
    path, path exists. Test it. What does this tell you about what a format
    checker can prove?
38. Predict: does `stat` change a file's mtime? Does `cat`? Check both with
    `stat -c '%y %x'` before and after. Explain which timestamp moved and which
    did not, in the vocabulary of chapter 3.
39. Predict what `wc -l` reports for a file whose last line has no trailing
    newline. Then make one in a scratch directory and check. Does
    `station/summariser/run.log` have a trailing newline? How can you tell?
40. Predict: two files with identical contents but different names and
    different mtimes — same `sha256sum` or different? Test it, then say which
    of the four sourcing facts is the one that identifies *content*.

## E. Stretch — combining earlier chapters

41. Using `find` with `-newermt`, list everything under `station/` modified in
    2187-05, oldest first, with its timestamp. (Chapter 6.)
42. Do the same restricted to a single day: 2187-05-17 only. What does the
    upper bound have to be, and why is `-newermt '2187-05-17'` alone not enough?
43. Build a one-line-per-artefact index of all three sample artefacts —
    path, bytes, mtime, hash — into `case/notes/01-index.tsv`, tab separated,
    generated by a command, not typed. (Chapters 6, 7, 12.)
44. Sort that index by mtime, oldest first. Which artefact is oldest?
45. `awk` over the run log: print only the lines whose sequence number is
    greater than 0431. How many, and what is the first?
46. Count the run log's lines by type — `start` versus `ok` — with one pipeline.
    Are they balanced? What would an imbalance have meant?
47. Write a two-line shell loop that runs `roe-check` over every file in
    `case/artefacts/` and prints the filename and its exit code. (Chapter 12.)
48. Extend it so it prints nothing for passing claims and only reports failures,
    and exits non-zero if any claim failed. (Chapter 8, chapter 12.)
49. `grep -c .` versus `wc -l` on the run log. Same number? Construct a file in
    scratch where they disagree.
50. The rules of engagement say to work on copies. Copy all of `station/` into
    a scratch directory in one command, preserving mtimes and the dangling
    symlink as a symlink. Prove the symlink survived as a link and that the
    mtimes came across.

## F. Dig — not in the notes

51. `stat` can print the *inode* and the *link count*. Find both format letters
    from `man stat` and report them for `station/summariser/run.log`.
52. `stat --printf` exists alongside `-c`. From the man page, what is the
    difference, and demonstrate it with one command whose output has no
    trailing newline.
53. `sha256sum` can print its output in a different, self-labelling format
    that names the algorithm on every line. Find the flag in `man sha256sum`,
    produce that form for all three sample artefacts, and then answer: does
    `sha256sum -c` accept a file written in that format? Test it, do not guess.
54. `find` has a test that matches files whose mtime is newer than another
    *file's* mtime, rather than a date. Find it and list everything under
    `station/` newer than `station/audit/MANIFEST.txt`.
55. `ls` can sort by mtime and print the timestamp in a full, unambiguous format
    rather than the abbreviated one. Find the two flags and produce a listing of
    `station/` sorted oldest-first with full timestamps.
56. `stat -c '%y'` prints nanoseconds. Find the format letter that prints the
    mtime as seconds since the epoch, and explain in one sentence why a report
    might prefer that number over the human-readable string.
