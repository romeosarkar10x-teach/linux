# 07/04 — Exercises: `sed` substitution

Work in `/labs/07-text-processing/04-sed-substitution`. Predict before you run; the point of most of
these is the gap between the prediction and the output.

Nothing here needs `-i` except where it says so, and where it says so it uses a copy in `scratch/`.

## Substitution, the basic form

1. Run `sed 's/ops-bot/OPS-BOT/' data/counts.txt`. Then check `data/counts.txt` is unchanged. How
   does `sed` differ from an editor?
2. `sed 's/^ *//' data/counts.txt`. Explain each of the three characters `^`, ` `, `*`.
3. Same command with `cat -A` on both sides of the pipe. Confirm the padding is gone and nothing else
   changed.
4. Replace `deck-0` with `Deck ` in `data/quoted.txt`. Now do it with `-n` and the `p` flag. What is
   the difference in the output, and why?
5. Run `sed 's/deck-0/Deck /p' data/quoted.txt` — with `p` but **without** `-n`. Explain what you
   see.
6. `sed 's/nosuchtext/x/' data/counts.txt`. What is the exit status (`echo $?`)? Is "no match" an
   error?
7. What does `sed 's/rhea//' data/counts.txt` do? What is the replacement in that command?

## The first-match trap

8. `sed 's/1/ONE/' data/nums.txt`. Now `sed 's/1/ONE/g'`. State the default in one sentence.
9. `sed 's/1/ONE/2' data/nums.txt` — predict first. Which `1` changed on each line?
10. `sed 's/[0-9]/#/2g' data/nums.txt`. Describe what `2g` did.
11. Count the lines in `logs/access-2187-06-10.log` that contain more than one `0`. Now imagine you
    had run `sed 's/0/X/'` on that log to fix a typo. How many lines would be wrong?
12. Write the rule you will follow from now on about when to use `g`.

## Capture groups

13. `sed 's/^ *\([0-9]*\) \(.*\)/\2 \1/' data/counts.txt`. Identify what `\1` and `\2` captured.
14. Change the space between the two fields in that command to `\t` and pipe through `cat -A`.
15. Do the same thing with `-E` and no backslashes on the parentheses. Which do you find easier to
    read?
16. In the `-E` version, are `\1` and `\2` still backslashed? Why is the replacement different from
    the pattern in this respect?
17. `data/dates.txt` holds DD/MM/YYYY. Convert to YYYY-MM-DD. Do it once with `/` as the delimiter
    (escaping) and once with `|`. Keep the readable one.
18. Sort the converted dates. Sort the originals. Explain the difference to someone who thinks
    DD/MM/YYYY is fine.
19. Read the third rule in `notes/style.txt`. It gives a reason. Does exercise 18 agree with it?
20. Using one capture group, wrap every account name in `data/counts.txt` in square brackets while
    leaving the counts alone.

## `&`

21. `sed 's/[0-9][0-9]*/[&]/' data/amp.txt`. What is `&`?
22. Redo exercise 20 using `&` and no capture group at all. Which is shorter?
23. `sed 's/[0-9]/<&>/g' data/amp.txt`. Explain why the output has one pair of angle brackets per
    digit rather than per number.
24. Make `sed` print a literal `&` in the replacement. Show the command.

## Delimiters

25. `sed 's|.*/||' data/paths.txt`. What does each path become? Which standard command does this
    imitate?
26. `sed 's|/[^/]*$||' data/paths.txt`. And that one?
27. Write exercise 25 using `/` as the delimiter. Count the backslashes.
28. Try `sed 's,rhea,RHEA,' data/counts.txt` and `sed 'sXrheaXRHEAX' data/counts.txt`. Is the second
    one legal? Should you ever write it?

## Greed

29. `sed 's/".*"/X/' data/quoted.txt` — predict, then run. Explain the output.
30. Fix it with `[^"]*`. Explain in one sentence why that pattern cannot overrun.
31. Add `/g` to the fixed version. What does each line become?
32. Extract just the first quoted word from each line of `data/quoted.txt` using `-n`, a pattern with
    two capture groups, and `p`.
33. `sed 's/.*deck/X/'` against `data/paths.txt` — does anything match? Why not?
34. State the rule about `.*` you now want a colleague to know.

## Case

35. `sed 's/.*/\U&/' data/case.txt`. Then `\L`. Then `\u`. Then `\l`.
36. `sed 's/^./\u&/' data/case.txt` — what is the difference between this and exercise 35's `\u&` on
    `.*`?
37. Do the same job with `tr` from lesson 03. Which tool can capitalise **only the first letter** of
    each line, and why can the other one not?
38. `printf 'Rhea\nrhea\n' | sed 's/rhea/X/'` then add the `I` flag. What changed?
39. Lesson 02 exercise 49 failed because the roster says `Rhea` and the log says `rhea`. Write the
    `sed` that would have made the comparison work.

## Addresses

40. `sed -n '3p' data/blocks.txt`, `sed -n '2,5p'`, `sed -n '$p'`. Name each address type.
41. `sed -n '/BEGIN summary/,/END summary/p' data/blocks.txt`. Are the BEGIN and END lines included?
42. `sed '/BEGIN/,/END/d' data/blocks.txt`. Which lines survive?
43. `sed -n '/BEGIN/,/END/!p' data/blocks.txt`. Compare with 42. Are they the same command?
44. Indent only the appendix block by two spaces: `sed '/BEGIN appendix/,/END appendix/s/^/  /'`.
    Explain how an address and an `s` combine.
45. `sed -n '1~2p' data/blocks.txt`. What did it select? Is `1~2` POSIX?
46. `sed 3q data/blocks.txt` and `head -3 data/blocks.txt`. Same output. Which would you write, and
    which one is faster on a ten-gigabyte file?
47. `sed -n '/TODO/=' data/report.txt`. What is `=` for, and what is the `grep` equivalent?
48. Print only the account names from `logs/access-2187-06-10.log` for lines matching `deck-04`,
    without using `grep`.

## The report cleanup

49. `cat -A data/report.txt`. List every style violation you can see, and match each to a rule in
    `notes/style.txt`.
50. Strip trailing whitespace with `sed 's/[ \t]*$//'` and check with `cat -A`. Something survives.
    What, and why did that pattern not catch it?
51. Strip the carriage return. Now do both in one command, in the order that works. Show that the
    other order fails.
52. Squeeze runs of spaces to one. Which rule does this satisfy, and what does it do to
    `Access review, draft   `?
53. Delete the TODO lines. Then count them first with `sed -n '/TODO/p' | wc -l` — why count before
    deleting?
54. Copy the report into `scratch/`, then clean it with a single `sed -i.bak` and diff the result
    against the backup. Write the final command as one line.
55. Do the same job with `-i` and no suffix on a second copy. Now recover the original. Can you?
    Write down what you will do differently next time.

## Stretch

56. Turn `data/counts.txt` into a TSV of `account<TAB>count` and feed it to `sort -k2,2rn`. You now
    have the report the captain will ask for in lesson 08. Keep the command.
57. `sed -n 's/TODO/PENDING/w scratch/todo.txt' data/report.txt`. What went into the file, and what
    went to the terminal? Explain both.
58. Convert `data/roster.tsv` so the first two columns swap, header included. Then do it excluding
    the header. Which address did you use?
59. Using only the log and `sed`, produce the list of distinct dates it contains. Then say why this
    is a bad way to do it and what you would use instead.
60. `sed` has no non-greedy operator, no lookahead, and no way to count. Name one job from this
    lesson that you would move to `awk` the moment it got harder, and say what would make it harder.
