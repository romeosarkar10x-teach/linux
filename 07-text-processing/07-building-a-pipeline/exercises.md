# 07 — Exercises: building a pipeline

Work in `/labs/07-text-processing/07-building-a-pipeline`.

No new commands in this lesson. Everything here uses `grep`, `sed`, `awk`, `sort`, `uniq`, `cut`,
`tr`, `head`, `tail`, `wc`, `tee` and `xargs`. The skill being drilled is the order you do things in
and the checks you run between them.

**Rule for the whole lesson: after every stage you add, run it and look at the output before you add
the next one.** Several exercises will catch you if you did not.

## Looking at the input (1–8)

1. `head -5 logs/maint-raw.txt`. Describe the shape of one record in one sentence.
2. `wc -l logs/maint-raw.txt`. Write the number down.
3. Count the blank lines. Count the comment lines. Count the lines that start with `2187`.
4. Do those four numbers add up? If not, what is left over? Find that line.
5. Why is `grep '^2187'` a better stage one here than `grep -v '^#' | grep -v '^$'`?
6. `tail -3 logs/maint-raw.txt`. Which of those lines would survive the `grep -v` version?
7. Look at `logs/access-2187-06-10.log` too. How many lines? Which of the two files is the clean one?
8. State the number of *records* in `logs/maint-raw.txt`. This number is your check for the rest of
   the lesson.

## Growing a pipeline (9–20)

9. Stage one: print only the records. Pipe to `head -3` and look.
10. Add a stage that prints field 4 of each record. Pipe to `head -3` and look. Is it what you
    expected?
11. Add `sort | uniq -c | sort -rn`. Look at the whole output. What is wrong with it?
12. Sum the counts from exercise 11. Compare with your number from exercise 8.
13. Run `awk '/^2187/{print NF}' logs/maint-raw.txt | sort -u`. Explain the result in one sentence.
14. Which severity produces which field count, and why? Look at a line of each.
15. How many records have the field count that gives the *actor* in field 4? Compare with the ERROR
    count.
16. Rewrite the actor extraction so it does not depend on field position. Use `sed` and `actor=`.
17. Sum the counts of your fixed version. Does it equal exercise 8's number now?
18. Do the same extraction with `awk -F'actor='`. Show that both give the same table.
19. Which of the two do you find easier to read six months later? Defend it in one sentence.
20. State the general rule you just used, in one sentence, without mentioning this file.

## Counts as tests (21–30)

21. Write a one-liner that prints the sum of the count column of any `uniq -c` output.
22. Use it on the actor table. Use it on a panel-letter table. Both should equal 120.
23. Extract the panel letter (`p-a` … `p-d`) from each record. Count them. Do they sum to 120?
24. `sort -u` the actor list. How many lines? What does that number mean?
25. Extract severities. Count each. Sum them. Should be 120 — is it?
26. Build a two-column table of severity and actor, counted, sorted by count descending.
27. How many distinct severity/actor pairs are there? Is that fewer than 6 × 3? Why?
28. Which actor appears in all three severities?
29. Which actors appear only as `INFO`?
30. You added a `grep` in the middle of a working pipeline and the final count did not change. Give
    two different explanations, one benign and one a bug.

## The broken five (31–40)

`notes/broken.txt` holds five pipelines. Each has exactly one bug.

31. Read pipeline A. Predict what it prints before running it. Then run it.
32. Fix A with a one-word change. What was the actual bug?
33. Read pipeline B. Run it. Why is `are` in the output?
34. Fix B so it ranks actors, most first, top five.
35. Read pipeline C. It gives the right answer. Name two things wrong with it anyway.
36. Rewrite C as a single command with no pipe at all.
37. Read pipeline D. Run it. What is in `reports/decks.txt` and what did `cat` print? Explain both.
38. Fix D so the count reaches the file *and* the terminal.
39. Read pipeline E. Run it. Why is the output `1 150`?
40. Which of the five bugs would you be least likely to catch in review? Say why.

## Exit status and pipes (41–47)

41. Run `grep nosuch logs/maint-raw.txt | wc -l` and then `echo $?`. Explain the status.
42. Run it again followed by `echo "${PIPESTATUS[@]}"`. Read the array.
43. Run any other command, then `echo "${PIPESTATUS[@]}"` again. Why did it change?
44. Turn on `set -o pipefail`, repeat exercise 41, and turn it off again.
45. Why is `pipefail` off by default? Give one pipeline that would break if it were always on.
    (Hint: lesson 06, `head`.)
46. `grep '^2187' logs/maint-raw.txt | grep -c ERROR` — what is the exit status when the count is
    zero? Contrive an input where it is.
47. Write a rule of thumb for when a zero from a pipeline should be believed.

## The report (48–56)

The maintenance chief wants: **which panels are throwing errors, how critical each panel is, and how
many errors each threw.** `data/panels.csv` has the criticality.

48. Get just the ERROR records. How many?
49. Extract the panel letter from each ERROR record. Count them, ranked.
50. Look at `data/panels.csv`. Which column is criticality? Which row is incomplete?
51. Load the CSV into an `awk` array keyed by panel letter, and print the array. Nothing else yet.
52. Now join: for each panel letter in the ERROR counts, print letter, criticality, count.
53. What does your pipeline print for the panel whose owner is blank? Is that the behaviour you want?
54. Sort the report by count descending. Then sort it by criticality instead. Which is more useful to
    the chief, and why is that a question about the reader and not about the data?
55. Add a header line without sorting it into the middle of the table.
56. Save the report to `reports/panel-errors.txt` *and* show it on the terminal, in one pipeline.

## Judgement (57–62)

57. Compute the average `dur=` per severity. Show your stage-by-stage build, not just the answer.
58. A colleague's version of exercise 57 uses `awk '/^2187/{ ... } END {print s, NR}'` and reports
    `NR` as the record count. Run it. Why is `NR` 128?
59. You have a pipeline with nine stages that gives the wrong answer. Describe, in three sentences,
    how you find the guilty stage without rewriting anything.
60. When is it right to replace a five-stage pipeline with a single `awk` program, and when is it
    right to leave the pipeline alone?
61. `notes/method.txt` has six steps. Which one do you personally skip most, and what would it have
    caught in this lesson?
62. Write the pipeline from exercise 56 out on one line, then reformat it across multiple lines with
    trailing pipes. Which one would you paste into a report you have to defend?
