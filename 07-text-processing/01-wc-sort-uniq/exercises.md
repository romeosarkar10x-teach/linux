# 07/01 — Exercises

`cd /labs/07-text-processing/01-wc-sort-uniq` first. Everything is relative to there.

Predict before you run. An exercise you ran without a prediction taught you the output and not the
tool.

## Counting (1–10)

1. `wc` with no flags on `logs/access-2187-06-10.log`. Name each of the three numbers.
2. How many bytes per line, on average? You have both numbers already.
3. `wc -l` on both access logs at once. What is the last line, and is it a file?
4. `wc -l logs/no-newline.log`. Now `cat` the file. How many lines do you see, and which is right?
5. Explain the discrepancy in exercise 4 using the word "newline". Then check with `wc -c` and
   `tail -c 1 logs/no-newline.log | od -c`.
6. `wc -l logs/access-2187-06-10.log` versus `wc -l < logs/access-2187-06-10.log`. What differs, and
   why does the second form exist?
7. `wc -L logs/wide.log`. What does it measure, and does it include the newline?
8. `wc -m` and `wc -c` on `logs/wide.log`. Same or different? What would make them differ?
9. `wc` on an empty file (`: > scratch/e`). Predict all three numbers first.
10. Count the words in `notes/reporting.txt`. Now count the lines. Which number would you quote to
    somebody asking "how long is that note"?

## sort: order (11–20)

11. `sort data/sizes.txt`. Predict the first three lines before you look.
12. Now `sort -n data/sizes.txt`. State in one sentence why the default disagreed.
13. `sort data/sizes-h.txt` and `sort -h data/sizes-h.txt`. What is `-h` comparing?
14. `sort -n data/sizes-h.txt`. This produces an order. Explain exactly what `-n` did with `1.5G`,
    and why the result is not an error.
15. `sort data/versions.txt`, then `sort -V`. Which pairs changed places?
16. `sort -n data/versions.txt`. Predict, then run. Why is everything a tie?
17. `sort data/decks.txt`. Why is `DECK-02` first? Which locale setting decides this?
18. `sort -f data/decks.txt`. What changed, and did anything get merged?
19. `sort -u data/decks.txt` versus `sort -fu data/decks.txt`. Two different counts. Explain both.
20. `sort data/nums-mixed.txt`, then `-n`, then `-b`. Three orders. Say what each one compared.

## sort: fields (21–30)

21. `sort -k2 data/duty.txt` and `sort -k2,2 data/duty.txt`. They differ. Find the lines that moved.
22. Explain the difference in exercise 21 in terms of what `-k2` means. Quote the man page phrase.
23. When two lines are equal on the key, what does GNU `sort` compare next? Prove it with
    `data/ties.txt`: `sort -k1,1` and read the `3 ...` lines.
24. Now `sort -s -k1,1 data/ties.txt`. Which order do the `3 ...` lines come out in, and where did
    that order come from?
25. Using `-s` and two passes, sort `data/ties.txt` by field 1 ascending with field 2 descending
    inside each group. Which pass runs first?
26. `sort -k2,2 data/tasks.txt` and `sort -t$'\t' -k2,2 data/tasks.txt` give different answers. Which
    two lines swap, and what is field 2 in each case?
27. `sort -t$'\t' -k3,3n -k1,1 data/tasks.txt`. Read the command aloud as a sentence in English.
28. Sort `data/duty.txt` by shift, then by account within shift. Write it with explicit key ends.
29. `sort -c data/sizes.txt`. What is the exit status, and what does the message name?
30. `sort -cn data/sizes.txt` names a different line than exercise 29. Explain why the line number
    moved.

## uniq (31–42)

31. Try to produce a count of accesses per account from `logs/access-2187-06-10.log` using only
    `wc`, `sort` and `uniq`. Get as close as you can, then write down precisely what stops you.
32. `uniq data/adjacent.txt`. Compare with the file. Which duplicates survived, and why those?
33. `sort data/adjacent.txt | uniq`. Now how many lines?
34. `uniq -c data/accounts-week.txt | wc -l`, then `sort data/accounts-week.txt | uniq -c | wc -l`.
    Two numbers. Which one is the number of accounts?
35. The wrong number in exercise 34 is not random. What is it counting?
36. `sort data/accounts-week.txt | uniq -c | sort -rn`. This is the idiom. Name what each of the
    three stages contributes.
37. In that pipeline, replace `-rn` with `-r`. The order is identical, which contradicts everything
    lesson said about text versus numeric comparison. Look at the exact bytes `uniq -c` emits
    (`| cat -A`) and explain why `-r` got away with it. Then pipe through `sed 's/^ *//'` first and
    run both again.
38. `sort data/adjacent.txt | uniq -d` and `| uniq -u`. Two disjoint sets. Which question does each
    answer?
39. `uniq -D` on the same input. How does it differ from `-d`, and when would you want it?
40. `sort data/decks.txt | uniq -ci`. Does `-i` group the mixed-case decks? Explain the result.
41. Fix exercise 40 so mixed-case entries are grouped and counted. You need to change the `sort`, not
    the `uniq`.
42. `sort -k2 data/ties.txt | uniq -f1 -c`. What is being compared, and what is being printed?

## Combining (43–50)

43. How many distinct accounts are in `data/accounts-week.txt`? Two different one-line answers.
44. Which accounts appear exactly once in `data/accounts-week.txt`? Which appear more than twice?
45. Produce the ranking from `data/accounts-week.txt` as a top-3 and a bottom-3, in two commands.
46. `sort data/accounts-week.txt | uniq -c | sort -n | head -1`. What question does this answer, and
    why is it a more interesting question than the `-rn | head -1` version?
47. Sort `data/accounts-week.txt` in place with `sort -o`. Verify it worked, then restore the file by
    re-running `setup.sh`. What would `sort data/accounts-week.txt > data/accounts-week.txt` have
    done instead, and why?
48. Count the lines of every file under `data/` with one `wc`. Which line is the one you want?
49. Are the two access logs the same length? Answer with one command whose exit status is the answer.
50. Try to build a frequency table of the *actions* (`read`/`write`/`exec`) in
    `logs/access-2187-06-10.log` using only this lesson's tools. `sort -k4,4` groups them correctly.
    Now count the groups `uniq -f3 -c` reports. Explain that number, and say what `-f3` actually
    compared.

## Stretch (51–56)

51. `sort -R` shuffles. Run `sort -R data/accounts-week.txt | head -20`. It does not look shuffled.
    Read `man sort` on `-R` and explain what it actually randomises.
52. Time `sort` on the big log with `time`, then `LC_ALL=C sort`. Is there a difference on this
    station, and what would make one appear?
53. `sort -m` merges already-sorted files. Merge the two sorted access logs and confirm the result is
    sorted with `sort -c`. What does `-m` buy you over plain `sort a b`?
54. Write a one-liner that reports, for `data/accounts-week.txt`, the number of accounts that appear
    exactly once — a single integer, no account names.
55. `uniq -w4 data/decks.txt`, sorted first. What does `-w4` compare, and why is the result useless
    here? Construct a file where `-w` is exactly the right tool.
56. Somebody hands you a frequency table and says the top entry is the problem. Give two reasons the
    bottom entry of a frequency table is more often the interesting one, using only what you have
    seen in this lab.
