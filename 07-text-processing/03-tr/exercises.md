# 07/03 — Exercises

`cd /labs/07-text-processing/03-tr` first.

Predict before you run. `tr` is small enough that you can reason out every answer, and the ones you
get wrong are the ones worth writing down.

## Getting input into tr (1–6)

1. `tr 'A-Z' 'a-z' data/mixed-case.txt`. Quote the error. What is `tr` complaining about?
2. Run the same translation three ways that work: with `<`, with a pipe from `cat`, and with a pipe
   from something that is not a file at all (`echo`, say).
3. Why does `tr` have no filename argument? Answer in terms of what `tr` is for, not what it lacks.
4. `tr` with no sets at all. Quote the error.
5. `tr -d 'b'` with only one set. Why is that legal when exercise 4 was not?
6. `sort -u < data/mixed-case.txt`, then fold the case first and `sort -u` again. Report both counts.

## Translating (7–16)

7. Fold `data/mixed-case.txt` to lowercase with an explicit range, then with `[:upper:]`/`[:lower:]`.
   Same output? Which would you write in a script, and why?
8. `tr '[:upper:]' '[:lower:]' < data/mixed-case.txt | sort | uniq -c`. Report the table.
9. Lesson 02 exercise 49 asked which accounts in the log are absent from the roster and gave a wrong
   answer. Redo it: fold `data/roster-display.txt`, compare against `sort -u data/log-accounts.txt`,
   and report the real answer.
10. `echo abcdef | tr 'abcdef' 'xy'`. Predict, then run. State the padding rule.
11. Add `-t` to exercise 10. What changed? Describe `-t` in one sentence.
12. `echo abcdef | tr 'ab' 'xyz'`. What happened to `z`? Is that an error?
13. Give a case where the padding rule in exercise 10 is exactly what you want. (Hint: masking.)
14. `tr '\n' ' ' < data/roster-display.txt`. What is missing from the end of the output, and why?
15. `tr 'cat' 'dog' <<< 'the cat sat on the mat'`. Explain the output character by character. What did
    the person who wrote this command think it did?
16. `printf 'a\tb\n' | tr '\011' ':'`. What is `\011`, and why might you write it that way?

## Deleting and complementing (17–28)

17. `cat -A data/crlf.txt`. What is at the end of each line that is not there in a normal file?
18. `cut -f2 data/crlf.txt | cat -A`. What has been attached to every value?
19. Fix the file with `tr` and confirm with `cat -A`. Write the command.
20. Explain why a `^M` on the end of a value is a nastier bug than a missing column.
21. `cat -A data/ctrl.txt`. Name the three control characters you can see and where each is.
22. `tr -d '[:cntrl:]' < data/ctrl.txt`. Predict first. What went wrong, and which character in the
    class caused it?
23. `tr -cd '[:print:]\n' < data/ctrl.txt`. Explain what `-c` did to the set, then read the command
    aloud in English.
24. Exercises 22 and 23 do nearly the same job. State the general principle about which one to reach
    for and why.
25. `tr -d '[:digit:]' < data/digits.txt` and `tr -cd '[:digit:]\n' < data/digits.txt`. Report both.
    Why does the second need `\n` in the set?
26. `tr -d '[:punct:]' < data/digits.txt`. Which characters count as punctuation here?
27. Normalise `data/digits.txt` so every identifier uses `-` as its separator, using one `tr`. Explain
    your set choice.
28. `tr -c '[:alnum:]\n' '-' < data/digits.txt` — compare with your answer to 27. Which is safer
    against a separator you did not anticipate?

## Squeezing (29–36)

29. `tr -s ' ' < data/aligned.txt`. What happened to the alignment?
30. Now finish the lesson 02 dead end: get the deck column out of `data/aligned.txt` using `tr` and
    `cut`. Write the whole pipeline.
31. Why can `cut` not do the squeezing itself? (One sentence; you answered this in lesson 02.)
32. `echo aaabbbccc | tr -s 'abc' 'xyz'`. Does it squeeze before or after translating? Prove it from
    the output.
33. `echo aaabbbccc | tr -s 'a'`. One set, no translation. What does `-s` alone mean?
34. `printf 'a  b   c\n' | tr -ds 'b' ' '`. Two flags, two sets. Which set goes with which flag?
35. `tr -s '\n' < data/prose.txt` on a file with blank lines — construct one in `scratch/` and show
    what this idiom is for.
36. Build the word-frequency table of `data/prose.txt`: one word per line, folded, counted, ranked.
    Report the top five.

## Complement plus squeeze (37–44)

37. Run exercise 36's first stage **without** `-s` and pipe it to `wc -l`. Compare with the `-s`
    version. Explain the difference in numbers exactly.
38. Where did the extra lines in exercise 37 come from? Point at a specific place in the prose.
39. Is `tr -cs '[:alpha:]' '\n'` the right definition of a word? Name two things it gets wrong.
40. Modify the set so that apostrophes and hyphens count as part of a word. Test it on a sentence you
    write yourself.
41. Decode `notes/rot13.txt`. Write the command.
42. Run your decode command on its own output. What comes back, and why exactly thirteen?
43. Write the rot13 command as two ranges and explain what each half of each range does.
44. According to the decoded note, what is rot13 actually for, and what does finding it protecting
    something important tell you?

## Bytes (45–50)

45. `tr 'a-z' 'A-Z' < data/utf8.txt`. Two characters did not fold. Which, and why?
46. `tr 'a-z' 'A-Z' < data/utf8.txt | od -c | head -2`. Confirm your explanation from the bytes.
47. Delete every `e` from `data/utf8.txt`. Did anything unexpected survive?
48. Construct a command that leaves a **broken** multi-byte character in the output, and prove it with
    `od -c`. (Deleting one byte of a two-byte character will do it.)
49. Given exercise 48, state the rule for when `tr` is safe.
50. `tr '\t' ',' < data/table.txt`. Look at the last line. What did you just create, and which lesson
    02 exercise does it repeat?

## Stretch (51–55)

51. `printf 'abcdef\n' | tr 'a-f' '[x*]'`. What is `[x*]`, and how does it relate to the padding rule?
52. Mask every digit in `data/log-accounts.txt`... except there are none. Do it to `data/digits.txt`
    instead, replacing each digit with `#`, and say why this is a one-command job for `tr` and an
    awkward one for anything else.
53. Count the distinct **characters** in `data/prose.txt`, ranked by frequency. (`tr` can put one
    character per line; you know the rest.) What is the most common character, and is that a surprise?
54. `tr` is the only tool in this chapter that cannot open a file. Name two consequences of that for
    how you write pipelines, one good and one annoying.
55. You are handed a 12 GB log with CRLF line endings and asked to make it usable. Compare
    `tr -d '\r' < in > out` against opening it in an editor. Consider memory, time, and what happens if
    the machine loses power halfway.
