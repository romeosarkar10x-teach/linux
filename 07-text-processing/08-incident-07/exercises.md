# 07/08 — Exercises: the tail of the report

Work in `/labs/07-text-processing/08-incident-07`. Do not modify anything in `logs/`.

This is the chapter finale. Everything from lessons 01–07 is in play, and the assignment the captain
gave you is exercises 9–20. The rest is what a good analyst does with a table they just built.

## Warmup — read before you count

1. Read `notes/page.txt`. In one sentence, what has actually been asked for?
2. Read `notes/forms.txt`. Which form is the report, and which is the finding?
3. Form AC-3 lists four things a finished report must have. Name all four.
4. Read `notes/handover.txt`. Write down the advice it gives, in its own words.
5. `ls logs/`. How many files? What period do they cover, and how do you know without opening them?
6. `wc -l logs/*.log`. Note the total. Is `wc`'s total line a record count?
7. `head -3 logs/access-2187-01.log`. Name the five fields.
8. Is every line in every log a record? Prove it rather than assuming it.

## The report she asked for (9–20)

9. Stage one: get the account column out of all three logs at once. `head -3` and look.
10. Add the counting stages. Look at the result. How many rows?
11. How many distinct accounts are there? Does it match the row count?
12. Sum the count column. Does it equal your total from exercise 6?
13. Rank it, highest first.
14. Add a share-of-total column, one decimal place. `awk` is the right tool for the arithmetic.
15. Add a header row without sorting it into the table.
16. State the period the report covers, computed from the logs rather than typed from memory.
17. Assemble the whole thing: header, period, ranked rows, three columns.
18. Save it to `reports/access-q1.txt` and show it on the terminal in one pipeline.
19. Read your own report out loud, top to bottom, every row.
20. If you skipped a row in exercise 19, go back and do it properly. This exercise is the lesson.

## Reading the whole report (21–30)

21. What share of the total is `ops-bot`? What share are the top three together?
22. Is `ops-bot` interesting? Justify your answer with a number rather than with the handover note.
23. What is the last row of your report? What is its count?
24. Ask of that row the question you would ask of the first: who is this account, and is that number
    normal for it?
25. Count `maintenance`. Look at every one of its lines. Is a count of six explainable?
26. Now look at every line for the account in the last row. How many lines is that?
27. What date, what time, what action, what deck?
28. Search all three logs for that account with `grep -c`. Explain the three numbers it prints.
29. How would you have found this account if you had never built the ranked report? Give a command.
30. Which is more likely in practice — that you run the command from exercise 29, or that you read
    the bottom of a report you built? Answer honestly; it is the point of the lesson.

## Corroboration (31–40)

31. `records/` has two account snapshots. What is the date of each?
32. How many accounts does each snapshot list?
33. Is the account from exercise 23 in the January snapshot?
34. Is it in the June snapshot, five months later?
35. Build the list of accounts that appear in the logs, sorted and unique, into `scratch/`.
36. Build the list of accounts from the January snapshot into `scratch/`. Watch the comment lines.
37. Compare the two lists. Which accounts appear in the logs and in no snapshot?
38. State what you now know as a sentence with no speculation in it.
39. State one thing you do **not** know, and cannot learn from these files.
40. Does anything in this lab say who created that account? Check before you answer.

## The red herring (41–45)

41. Rank the logins only. Who tops that table, and by how much?
42. Does restricting to `login` make the finding easier or harder to see? Why?
43. `grep login logs/*.log | wc -l` versus `grep -c login logs/*.log`. Explain the difference in the
    output, not just the numbers.
44. Rank by deck. Rank by action. Does either ranking surface the finding?
45. Name the reason the handover advice failed today, in one sentence that does not blame anyone.

## The finding (46–50)

46. Form AC-9 has three fields. Name what goes in each.
47. Field 1: the account, dashes written as underscores. Write it.
48. Field 2: the event. Look up the action from exercise 27 in the vocabulary table.
49. Field 3: the frequency word. Look up your count from exercise 26 in the frequency table.
50. Join the three with underscores, wrap in `KESTREL{}`, and submit:
    `kestrel flags submit 07/08 'KESTREL{...}'`

## Reporting (51–55)

51. The captain rejected your first report as unreadable. Before you change anything, list three
    things about it that a person reading on a small console would object to.
52. Rewrite it to fix those three. Column widths, alignment and the number of decimal places are all
    fair game.
53. Should the finding go in the AC-3 report, in a separate AC-9, or both? Justify it.
54. Write the one-sentence summary you would put at the top of the report for someone who will read
    exactly one sentence.
55. Your report says `eng-svc  1  0.0%`. Is `0.0%` the right thing to print for a count of one out of
    2435? What would you print instead, and what does that change about how the row reads?

## Experiment (56–60)

56. Rebuild the report with `sort -k2,2n` instead of `-rn`. Which account is first now? Argue for
    ascending order as a default for incident work.
57. Add a column showing each account's first and last appearance in the quarter. What does it say
    about the account from exercise 23 that it does not say about the others?
58. Count events per account per month, three columns. Which accounts appear in all three months?
59. What would this report have looked like if the account had logged in twice, in different months?
    Would you have noticed sooner or later?
60. Change one thing about the AC-3 form that would have made today's finding unmissable. Defend it
    against the objection that it makes every report longer.

## Stretch (61–64)

61. Write the whole report as a single `awk` program with no pipes except the final `sort`. Compare
    with your pipeline version for readability.
62. Produce the same table sorted by account name instead of count, and say which version you would
    file and which you would send.
63. Your pipeline reads all three logs. Show that it reads them once, not three times, and say how
    you know.
64. A colleague says "just `grep -v ops-bot` first, it is all noise". Give the strongest argument for
    doing that and the strongest argument against.

## Dig

Four stages in `records/`. Tokens are `STAGE{...}` and do **not** register with `kestrel flags`.

**65.** Stage 1. `records/tally.txt` is a console session tally. Rank it the lesson-01 way. The
**last** row names a file in `records/`. Token, and the instruction for stage 2.

**66.** Stage 2. That file is a table of terminal sessions. Exactly one of its accounts appears in no
account snapshot. Find that row with `awk`, and take field 2 of it — that names the next file.

**67.** Stage 3. That file tells you which column to `cut` from `records/left.txt` and which from
`records/right.txt`, and to `paste` them. The line you want is numbered by the count you computed in
exercise 26.

**68.** Stage 4. `records/cipher.txt` says how the line was written. Decode it with `tr`, reshape it
with `sed`, and wrap it in `STAGE{}`.

**69.** The four stages used four different skills from this chapter. Name them. Name the one chapter
skill the chain never used, and say why it would have been wrong for every stage.

**70.** The final stage token is two words. Say why those two words are the right ones for this
incident.
