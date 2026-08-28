# 07/02 — Exercises

`cd /labs/07-text-processing/02-cut-and-paste` first. Everything is relative to there.

Predict before you run. When an exercise asks "what happens", the answer is a description of
behaviour, not a transcript.

## cut: fields (1–12)

1. `cut -f2 data/roster.tsv`. You passed no `-d`. What delimiter did `cut` use, and how do you know?
2. `cut -f2 data/roster.csv`. Explain the output. Then fix the command.
3. Select fields 3 and 5 of `data/roster.tsv`. What separates them in the output?
4. Now ask for them in the other order: `cut -f5,3`. What did you get? State the rule.
5. Given exercise 4, what does `cut` fundamentally not do to columns?
6. `cut -f2-4`, `cut -f5-`, and `cut -f-2` on the roster. Describe each range form in words.
7. `cut -d, --complement -f2 data/roster.csv`. Write the same result without `--complement`.
8. `cut data/roster.tsv` with no list at all. Quote the error. Why can `cut` not pick a default?
9. `cut -f2 -c1 data/roster.tsv`. Quote the error and explain the restriction.
10. `cut -f0 data/roster.tsv`. What does the error tell you about how fields are numbered?
11. `cut -f3,5 --output-delimiter=' | ' data/roster.tsv`. What changed, and what did **not**?
12. Can `--output-delimiter` take more than one character? Can `-d`? Try both and quote the failure.

## cut: the log (13–20)

13. `cut -d' ' -f3 logs/access-2187-06-10.log | head`. Which column is that?
14. Build the full frequency table by account: cut, then the lesson 01 idiom. Report the whole table.
15. This is the exact question lesson 01 could not answer. In one sentence, what was missing then?
16. Do the same for field 4 (the action). Do the counts add to 600?
17. Do it for field 5 (the deck). Comment on the result — is that a finding?
18. `cut -d' ' -f3,5` on the log. Predict the separator in the output before you run it.
19. `cut -c12-19` on the log. What did you extract, and why is `-c` safe here specifically?
20. Read the bottom line of your table from exercise 14. Say what it means. Do not say who it is.

## cut: where it breaks (21–32)

21. `cat -A data/aligned.txt | head -3`. What is actually between the columns?
22. `cut -d' ' -f2 data/aligned.txt`. Predict first. Explain the output you got.
23. Following on: what does `cut` do with two adjacent delimiters?
24. `cut -c11-20 data/aligned.txt`. Works. Why?
25. `cut -c11-20 data/ragged.txt`. Compare with exercise 24 line by line. Quote the worst line.
26. The line you quoted is not an error and not empty. Why is that worse than an error?
27. `tr -s ' ' < data/aligned.txt | cut -d' ' -f2` (you meet `tr` properly in lesson 03). Does it
    work? What did `tr -s` do that `cut` cannot?
28. `cut -f2 data/short.tsv`. Two rows behave oddly. Identify both and say why each does what it does.
29. `cut -f3 data/short.tsv`. Which line came out empty, and which came out whole?
30. Add `-s` to exercise 29. Which lines disappeared? State the rule `-s` applies.
31. `cut -d, -f2 data/roster.csv | tail -1` and `cut -d, -f3 data/roster.csv | tail -1`. Explain both.
32. Given exercise 31, write down the property a delimiter must have for `cut` to be safe. Then read
    `notes/columns.txt` and find the sentence that says the same thing.

## paste (33–44)

33. `paste data/ids.txt data/names.txt data/decks.txt`. What separates the columns by default?
34. `paste -d, data/ids.txt data/names.txt`. Now `paste -d:- ` with all three files. Explain the
    second result exactly — count the delimiters and the gaps.
35. `paste -d'\n' data/ids.txt data/names.txt`. Describe what this is useful for.
36. `paste data/ids.txt data/extra.txt`. The files have different lengths. What did `paste` do?
    Run it through `cat -A` to be sure.
37. Why is the behaviour in exercise 36 dangerous in a report, and what would you check before
    trusting a `paste` of two files?
38. `paste -s data/flat.txt`. What does `-s` change about how the input is read?
39. `paste -s -d+ data/flat.txt`. You now have an arithmetic expression. (Do not evaluate it yet —
    that is `bc`, and it is not in this chapter.)
40. Turn the sorted list of distinct accounts in the access log into one comma-separated line.
41. `paste - - < data/flat.txt`. Explain what `-` means and why it appears twice.
42. `paste - - - < data/flat.txt`. Predict the shape before running.
43. Print the roster's `role` column before its `name` column, using only `cut` and `paste`.
44. Exercise 43 reads the file twice. Name a situation where that is not acceptable.

## Combining (45–52)

45. Produce a two-column report of every account in the access log and how many times it appears,
    tab separated, account first.
46. Take the roster and produce `name<TAB>role`, sorted by role, with the header line still first.
    (Getting the header to stay on top with only these tools is the exercise; say what you tried.)
47. `cut -f1,3 data/roster.tsv | column -t`. What did `column -t` do, and why does the station's note
    say to let the *reader* run it rather than doing it yourself?
48. Count the distinct decks in the roster and in the log. Do they agree? Should they?
49. How many accounts appear in the access log but not in `data/roster.tsv`? Answer with a command,
    not by eye. (You have no `comm` or `join` yet — `sort`, `uniq -u` and a little thought will do.)
50. Explain, for exercise 49, why `sort | uniq -u` on the concatenation of two lists is not a general
    solution. What assumption about each list does it need?
51. Write a one-line pipeline that prints the *least* frequent account in the access log with its
    count, and nothing else.
52. You have been asked for "the access numbers, by account, readable". List three things about that
    request that are unspecified, and pick a defensible answer for each. Keep this — you will be asked
    for it again at the end of the chapter.

## Stretch (53–56)

53. `cut -b1-4` versus `cut -c1-4` on the log. Identical here. Construct a file where they differ,
    and say which one you would want for a timestamp and which for a name.
54. `cut -d, -f9 data/roster.csv` — a field that does not exist on any line. What comes out, and how
    many lines? Now add `-s`. Explain why `-s` did not help.
55. `cut` reads its input once and streams. `paste <(cut ...) <(cut ...)` does not. Given a 40 GB log
    on a station with no spare disk, which of the two idioms in exercise 43 survives, and why?
56. Write down, in one sentence each, the three failure modes of `cut` you met in this lesson that
    produce **plausible output rather than an error**. You will need this list for the rest of the
    chapter.
