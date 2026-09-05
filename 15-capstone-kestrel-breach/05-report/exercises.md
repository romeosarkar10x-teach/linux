# 05 — Exercises

Lab: `/labs/15-capstone-kestrel-breach/05-report`. Start there.

```
cd /labs/15-capstone-kestrel-breach/05-report
```

Everything you write goes in `report/`. Copy `report/TEMPLATE.md` to
`report/report.md` and fill it in as you go — several exercises below tell
you to write a specific sentence into a specific section.

## A. Survey (1–6)

1. List the lab tree, directories first, one level deep. How many top-level
   directories are there?
2. `cat case/notes/00-carried.md`. Which of the five carried items is the
   only one that was *not* fixed in lesson 04?
3. Count the regular files under `archive/`. What are they, by extension?
4. How large is `evidence/handover.tar.gz`? Use a human-readable size.
5. Which file under this lab has the oldest mtime? Which has the newest?
6. Copy `report/TEMPLATE.md` to `report/report.md` without preserving
   anything. Confirm the copy's mtime is now, not 2187.

## B. The run log's shape (7–18)

7. How many lines are in `station/summariser/run.log`?
8. Print the first and last line of the log in one command.
9. Every line begins `seq=NNNN`. Extract just the sequence field from every
   line, and count the distinct values.
10. Two lines share each sequence number. What distinguishes them?
11. What is the lowest sequence number in the log? The highest?
12. If the log had no gaps, how many distinct sequence numbers would lie
    between the lowest and the highest inclusive? Compare that to your
    answer to exercise 9.
13. Produce the list of sequence numbers that are missing, without reading
    the file by eye. (`seq`, `sort`, `comm` — one pipeline.)
14. State the missing range as a sentence with two numbers in it.
15. Each record carries a date. What is the date on the record immediately
    before the gap? Immediately after?
16. How many nights does the gap span, by date arithmetic?
17. Does the gap's date range overlap either of the two edit clusters you
    found in lesson 03? Which one?
18. Write one sentence into the **When** section of your report stating the
    gap, its range, and the file you got it from.

## C. Stage 1 — the handover (19–24)

19. `evidence/handover.tar.gz` is a compressed archive. List its contents
    *without* extracting it.
20. Extract it into a directory you create yourself, not into the lab tree.
    Why not into the lab tree?
21. Read the extracted `README`. What token does it give you?
22. `handover/notes.txt` contains one word. Is it evidence?
23. The README claims the archive job and the log job are different jobs.
    Which finding in this lab is consistent with that claim?
24. What does the README tell you to do next, in your own words?

## D. Stage 2 — the missing records (25–34)

25. The archive files are gzipped. Read one without writing an uncompressed
    copy to disk.
26. How many archive records are there, and what sequence range do they
    cover?
27. Every record has a `clamped=` field. How many records have a non-zero
    value there?
28. Which sequence numbers have `clamped=` non-zero? Compare that set to
    your answer from exercise 13.
29. Read all six of the records the log is missing, in order, with one
    command.
30. Five of the six carry a `continues=` field. What does the sixth carry
    instead?
31. What token does the sixth record give you?
32. That record also carries a `match=` field. What kind of value is it?
    How can you tell from the value alone?
33. Sum the `clamped=` values across the six records. Does that number
    appear anywhere else in the case?
34. Write one sentence into the **What happened** section of your report
    stating that six records exist in the archive and not in the log.

## E. Stage 3 — following the hash (35–42)

35. Compute the sha256 of `report/TEMPLATE.md`. How long is the hash, in
    characters?
36. Find the single file under this lab whose sha256 equals the `match=`
    value. Do it with one pipeline; do not check files by hand.
37. Why does your pipeline need to exclude the `.gz` files, or why does it
    not?
38. Read the file you found. What token does it carry?
39. The note distinguishes two things that were treated as one. Name both.
40. Which of those two words is the first half of what you are looking for?
41. The note says the second half is in `station/.calibration/second`.
    Try to read it as yourself. What exactly does the error say?
42. `ls -ld station/.calibration`. Who owns it, and what are its
    permissions? Explain the failure in exercise 41 in terms of that mode.

## F. Stage 4 — extending the tool (43–52)

43. Read `station/.calibration/second` as the account that owns it. You saw
    the technique in lesson 02.
44. You now have two words. The station's flag format is documented in the
    course; assemble the flag. Do not write it into any file in the lab.
45. Run `bin/stationctl --help`. List its subcommands.
46. Run `bin/stationctl faults deck-3` and `bin/stationctl faults deck-9`.
    What are the two exit codes, and what does each mean?
47. Run `bin/stationctl check`. What is its exit code, and why is that not
    an error?
48. Add a `gaps` subcommand to `bin/stationctl`. It takes a path to a run
    log, prints the missing sequence numbers one per line, and exits 0 if
    there are none and 1 if there are. Missing file is exit 66.
49. Add `gaps` to `usage()`. Verify `--help` shows it.
50. Verify that `stationctl decks`, `faults` and `check` produce exactly the
    same bytes and the same exit codes as before your change. How did you
    verify "exactly the same bytes"?
51. Run your `gaps` command against `station/summariser/run.log`. Does its
    output match exercise 13?
52. Run it against a log with no gaps — make one — and confirm exit 0.

## G. The report (53–58)

53. Fill in **What happened**: one paragraph, mechanism only, no names.
54. Fill in **When**: every timestamp you are relying on, oldest first, each
    with the file or command it came from.
55. Fill in **Who did what**: accounts and actions. Where the evidence
    stops, say what would be needed to go further.
56. Fill in **What I changed**: the five faults closed in lesson 04, plus
    anything you left alone and why.
57. Fill in **What would have caught this in October**: name one control,
    and say what it would have printed on 2186-10-06.
58. Re-read your report and delete every sentence you cannot support with a
    command. How many did you delete?

## H. Stretch (59–62)

59. Your `gaps` command assumes one field format. Make it fail with exit 66,
    not a traceback of `seq` errors, when handed a file with no `seq=` lines
    at all.
60. `stationctl` sets `STATIONCTL_DATA` with `:=`. Run it with that variable
    set to a directory that does not exist, and confirm exit 66.
61. Write a one-line command that prints, for every archive record, its
    sequence number and clamped value as two columns, sorted by clamped
    value descending.
62. The report has no section for what you did not find out. Write that
    section anyway, as a list, and decide whether it belongs in the
    document.

## I. Dig deeper (63–64)

63. The `match=` hash appears in a record inside a gzipped file. If you had
    only `grep` and not `zgrep` or `zcat`, could you have found it? Try it
    and explain the result.
64. `run.log`'s mtime is 2187-05-24 02:00:30 — the same minute as its last
    record. What would it mean if the mtime were *later* than the last
    record's timestamp? Earlier?
