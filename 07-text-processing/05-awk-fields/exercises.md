# 07/05 — Exercises: `awk` fields

Work in `/labs/07-text-processing/05-awk-fields`. `L=logs/access-2187-06-10.log` will save you
typing. Predict before you run.

Single-quote every `awk` program. If you ever see the shell complain about `$3`, that is why.

## Fields

1. Print the account from each log line with `awk '{print $3}'`. Compare the command with lesson 04
   exercise 48's `sed`. Which would you rather read in six months?
2. Print `$0`, `$1`, `$NF` and `$(NF-1)` for the first line only (`NR==1`).
3. `awk '{print NF}' $L | sort -u`. What does one value in the output tell you about this file?
4. `awk 'END {print NR, NF, $0}' $L`. Explain each of the three values. Why does `$0` still work in
   `END`?
5. `awk '{print $10}' $L | head -2 | cat -A`. Is a missing field an error?
6. Print the account and deck, separated by a space, for lines where the action is `exec`.
7. `awk 'NR==1 {print $3 $5}' $L` — no comma. Explain the output.

## Ragged input

8. `cut -d' ' -f3 data/ragged.txt | sort | uniq -c | sort -rn | head -5`. Read the output. What went
   wrong?
9. Now `awk '{print $3}' data/ragged.txt | sort | uniq -c`. One clean answer.
10. State the rule about `awk`'s default field separator, including what it does with leading
    whitespace.
11. `printf 'a  b\n' | awk '{print NF}'` and `printf '   a b\n' | awk '{print NF, "["$1"]"}'`.
    Confirm the rule.
12. `printf 'a  b\n' | awk -F' ' '{print NF}'`. Predict 3, run it, and explain the answer you get.
13. Get the answer you expected in 12 by changing the `-F` argument. What is the smallest change?

## Separators

14. `awk '{print NR, NF, $1}' data/roster.tsv` with the default separator. Which row is wrong, and
    why?
15. Same with `-F'\t'`. What changed, and what did not?
16. Which row of `data/roster.tsv` has fewer than four fields? Find it with one `awk`.
17. Print `$4` and `$9` of that short row with brackets around them. What is an unset field?
18. `awk -F, 'NF!=4 {print NR": "NF}' data/roster.csv`. Which row, and what is the quoted comma
    doing?
19. Write one sentence for the tutor explaining why `awk -F,` is not a CSV parser.
20. `printf 'a,,c\n' | awk -F, '{print NF, "["$2"]"}'` and the same through `cut -d, -f2`. Do `cut`
    and `awk` agree about empty fields?
21. `printf 'a1b22c\n' | awk -F'[0-9]+' '{print NF, $2}'`. What kind of thing is a `-F` argument?
22. Skip the header of `data/roster.tsv` and print the accounts. Which pattern did you use?

## Conditions

23. Count `rhea`'s lines in the log with a bare condition, no `print`, no `grep`.
24. Count the lines where `rhea` ran `exec`.
25. `awk '/deck-04/' $L | wc -l` and `awk '$5 ~ /04/ {n++} END{print n}' $L`. Same number. Which is
    safer on a bigger log, and why?
26. Print the readings where amps are exactly zero. What does that panel look like?
27. Print any reading where volts are below 20. One row comes back. Say what you think happened to
    it.
28. Use a ternary (`cond ? a : b`) to print the account and `R` or `-` depending on whether the action
    is `read`, for the first three lines.
29. `awk 'NF' data/blank.txt | wc -l` and `wc -l < data/blank.txt`. Explain the difference in terms
    of the default action and the default pattern.

## Arithmetic and END

30. Total watts across `data/readings.txt` (`volts * amps`), to two decimals.
31. Average volts, and the number of readings, from one `awk`.
32. Find the row with the highest amps by keeping a running maximum. Print the whole row.
33. Per-deck watt totals with an array. Pipe to `sort`.
34. Why must the totals be printed in `END` and not in the main block? Show what happens if you get it
    wrong.
35. `awk 'BEGIN {print 1/3; printf "%.4f\n", 1/3}'`. Explain the two different outputs.
36. `awk 'BEGIN {print 7/2, int(7/2), 7%2}'`. Is `awk` division integer division?
37. Sum field 2 of `data/mixed.txt` — a column of things like `12V`. What total do you get, and is it
    a bug?
38. Make `awk` print a total that is definitely wrong by summing a column that is not numeric. Then
    say how you would have noticed in a real report.

## The counting idiom

39. Build the account frequency table with `c[$3]++` and `END`. Compare the output with lesson 01's
    `sort | uniq -c | sort -rn`.
40. Run the `awk` version twice. Is the order of the output guaranteed? Where does the guarantee come
    from in the `sort | uniq -c` version?
41. Sort the `awk` output so it matches lesson 01's exactly.
42. Count by action **and** deck at once, using `c[$4" "$5]++`. What are the four biggest groups?
43. Count by hour of the day. Do it once with `substr($2,1,2)` and once with `split($2,t,":")`.
44. Add percentages to the account table with `printf`, one decimal place, using a second variable
    for the total.
45. Add a `BEGIN` block that prints a header. Then pipe the whole thing to `sort -k2,2rn` and look at
    where the header went. What is the lesson about headers and pipelines?
46. Use `-v who=rhea` to parameterise exercise 23. Why is `-v` better than pasting the name into the
    program?
47. Produce the account table sorted by count **ascending** and read the bottom three lines. Note what
    is there; chapter 8's incident will care.

## Output

48. `awk -F'\t' '{print $2, $1}' data/roster.tsv | cat -A`. What separator came out, and where did it
    come from?
49. Set `OFS` in `BEGIN` to a tab and rerun. Now try `awk -F'\t' 'BEGIN{OFS="\t"} {print}'` — no
    commas. Why did nothing change?
50. Add `$1 = $1` before that `print`. Explain what assigning a field to itself accomplished.
51. Format the account table as `%-12s %4d` and check the columns line up under `ops-bot` and
    `maintenance`.
52. Write `rhea`'s lines to `scratch/rhea.txt` from inside `awk` with `print > "scratch/rhea.txt"`.
    Count them. When would you use this instead of a shell redirect?
53. `awk '{print substr($2,1,5), length($3), toupper($3)}' $L | head -2`. Name what each of the three
    functions did.

## Judgement

54. Rewrite lesson 01's full pipeline (`cut | sort | uniq -c | sort -rn`) as one `awk` plus one
    `sort`. Time both on the log with `time`. Is the difference worth anything at 600 lines? At six
    million?
55. Name a job in this chapter that `awk` should **not** do, and say which tool should.
56. `awk 'BEGIN {print 2+2}' </dev/null` — no input file at all. What is `awk` here?
57. Take the report from lesson 04 exercise 56 (account, tab, count) and produce the same thing from
    the raw log in one `awk`. Which version would you put in a script?
58. You are handed a log with an extra field inserted at position 2. Which of your commands from this
    lesson break, and which survive? Which of your `cut` commands from lesson 02 survive?

## Stretch

59. Print each account's first and last timestamp from the log using two arrays and `END`.
60. `awk 'FNR==1 {print FILENAME, FNR}' data/short.txt data/mixed.txt`. What is the difference between
    `NR` and `FNR`, and when does it matter?
61. Find the deck with the highest total watts without piping to `sort` — do the comparison in `END`.
62. `awk '{if (length($0) > m) m = length($0)} END {print m}' $L`. Which standard command from lesson
    01 does this replace, and which of the two would you rather trust?
