# 06/03 — Exercises: Regular Expressions

```
cd /labs/06-searching/03-regex-bre-ere
cat ids.txt
```

Single-quote every pattern — several of these contain characters the shell would otherwise take.
`kestrel reset 06/03` restores the lab.

---

## Anchors

**1.** `grep -c 'BAY' ids.txt` and `grep -c '^BAY' ids.txt`. Two numbers. Which lines does the anchor
remove, and are they malformed or just differently formed?

**2.** `grep -n 'BAY-$' ids.txt`. One line. What is on it, and what is `$` asserting about the
position after the dash?

**3.** Write a pattern that matches a line that is *exactly* `BAY-01`. Then match a line that
*contains* `BAY-01`. Show that `ids.txt` distinguishes them.

**4.** `grep -c '^$' ids.txt`. Zero. Add a blank line to a copy in `scratch/` and get 1. What is a
pattern with two operators and no characters actually matching?

**5.** `grep '^ ' ids.txt`. One line. Why does that line break every pattern you have written so far,
and which flag from lesson 02 has the same problem?

**6.** `grep -c '^-' ids.txt`. One. Explain why `-` needs no escaping here but caused a problem in
lesson 01.

## Classes

**7.** `grep -c '^BAY-[0-9][0-9]$' ids.txt` → 4. List the four, and list the `BAY` lines that were
excluded with the reason for each.

**8.** Rewrite exercise 7's pattern with `[[:digit:]]`. Same answer. Say when the two forms would
differ and why a script should prefer one.

**9.** Match identifiers whose numeric part is one to three digits: `^BAY-[0-9]\{1,3\}$`. How many,
and which new lines came in?

**10.** `grep -c '^[A-Z]*-[0-9]*$' ids.txt` → 11. That is more than you expected. Find the line that
matches because `*` allows **zero**, and say what the pattern should have been.

**11.** Negated class: find lines containing a character that is not an upper-case letter, a digit or
a dash. Which lines, and is `bay-04` one of them?

**12.** `[^]]` versus `[^]` — try both against `greedy.txt`. One is a class, one is an error. Quote
the error.

**13.** In `dots.txt`, `grep -c '0.41'` → 4 and `grep -c '0\.41'` → 2. Name the two extra lines the
unescaped pattern caught.

**14.** Match a literal dot two ways: with a backslash, and with a bracket expression. Which would
you use in a pattern that came from a variable, and why?

**15.** `grep -c '^\.$' dots.txt` → 1, but `dots.txt` has both `.` and `..`. Extend the pattern to
match a line of one or more dots and nothing else.

## Quantifiers

**16.** `grep -c 'BAY-[0-9]\+' ids.txt` → 10 and `grep -c 'BAY-[0-9]+' ids.txt` → 0. Explain the
zero. Is it an error?

**17.** That zero is the most dangerous behaviour in this lesson. Write one sentence you could say to
a colleague who reports "there are no bay codes in this file".

**18.** Rewrite exercise 16's working pattern with `-E`. Which characters changed?

**19.** `grep -c '^BAY-[0-9]\{2\}$'` and `grep -cE '^BAY-[0-9]{2}$'` on `ids.txt`. Same number.
Write both out and mark every character that had to change.

**20.** Match `BAY-7` and `BAY-07` but not `BAY-007` — with a counted quantifier, then with `\?`.

**21.** `^BAY-0\?[0-9]*$` → 7. Take that pattern apart and explain why it matches `BAY-` itself.

**22.** Fix exercise 21 so the numeric part is required.

**23.** `*` is greedy. In `greedy.txt`, `grep -o '\[.*\]'` on line 2 returns `[one] [two]`, not
`[one]`. Explain in terms of what `.*` is allowed to consume.

**24.** Get the individual bracketed fields with `-o` and a negated class. How many fields in the
whole file?

**25.** Line 5 of `greedy.txt` is `[unclosed and then [closed]`. What does your exercise-24 pattern
return for it, and is that the right answer? Argue both sides.

**26.** `{0,}`, `{1,}` and `{0,1}` are the long forms of three operators. Name them, and write one of
the three both ways against `ids.txt`.

## Alternation and groups

**27.** `log.txt` has three timestamp formats. Count each: ISO (`2187-06-09`), slashed
(`09/06/2187`), and time-only. The three counts should not sum to 12 — say why before you check.

**28.** `grep -c '^[0-9]\{4\}-|^[0-9]\{2\}/' log.txt` → 0. What did BRE think `|` was?

**29.** Fix it two ways: escape the pipe, and switch to `-E`. Both give 10.

**30.** Which two lines of `log.txt` does exercise 29's pattern miss, and are they in the file by
mistake or on purpose?

**31.** Write one ERE that matches all three timestamp formats. Then say what a report generator that
emits three formats tells you about how it was maintained.

**32.** `grep -c '^[0-9]*-[0-9]*-[0-9]* ' log.txt` → 8, one more than the strict ISO count. Which
line snuck in, and which quantifier let it?

**33.** Group and quantify: match a line with two colon-separated time fields (`04:00`) using a group
and `\{2\}` rather than repeating yourself.

**34.** `pairs.txt`: `grep '\([A-Za-z0-9-]\+\) \1' pairs.txt` finds repeated tokens. Six lines. One
of them does not contain a repeated word at all. Which, and why did it match?

**35.** Fix exercise 34 so `report reported` does not match. (You need a boundary — either `-w`,
`\b`, or an anchor.)

**36.** What does `\1` refer to: the pattern in the group, or the text it matched? Prove it with
`E-104 E-104` and `E-104 E-105`.

**37.** Write the same backreference pattern in ERE. Which parentheses changed, and did `\1` change?

## Whitespace

**38.** `spacing.txt` holds one record written six ways. `grep -c 'deck 03' spacing.txt` → 1. Which
one did you find?

**39.** `grep -c 'deck[ \t]\+03' spacing.txt` → 3, not 5. `[ \t]` did not do what you think. State
exactly which three characters that bracket expression contains.

**40.** Get all five spaced variants with `[[:space:]]`. Which line is still excluded, and correctly
so?

**41.** Try `grep -c 'deck\t' spacing.txt`. Quote the warning exactly and give the count. So how do
you match a real tab in a POSIX pattern? (Two ways: one uses the shell, one uses a character class.)

**42.** Write a pattern that matches the record regardless of how the fields are separated, including
the run-together version. Is that a good pattern? Say what it would match that you do not want.

## Dialects

**43.** Take `^BAY-[0-9]\{2\}$` and convert it to ERE. Take `^(BAY|DECK)-[0-9]+$` and convert it to
BRE. Run both pairs.

**44.** Which of these characters need a backslash in BRE and which in ERE: `? + { } ( ) | . * ^ $`?
Build the table by testing, not by recalling.

**45.** `grep -E 'a{2' ids.txt` and `grep 'a{2' ids.txt` — predict which one errors. Both are quiet;
say what each one searched for. Now `grep -E 'a{2,1}' ids.txt` and `grep 'a\{2,1\}' ids.txt`. Quote
the message and give the exit status of each.

**46.** `grep -P 'BAY-(?=0)' ids.txt` → 7 lines. What did the lookahead do that no POSIX pattern can?
And name the two reasons the readme gives for not reaching for `-P`.

**47.** Write the exercise-46 search in POSIX with `-o`, and say what is different about the output.

## Experiment

**48.** Build a file in `scratch/` where a greedy `.*` makes `grep -o` return one match where you
wanted three. Then fix it without `-P`.

**49.** Does `^` mean "start of line" or "start of input"? Prove it with a two-line file.

**50.** What does `grep '^*'` match? Predict first — `*` with nothing to repeat is a special case.

**51.** Is `[a-z]` the same as `[[:lower:]]` under `LC_ALL=C`? Under a UTF-8 locale with a non-ASCII
letter in the file? Construct the case.

**52.** Time a backreference against a plain pattern on a file you build large enough to notice. What
does the difference suggest about how `\1` is implemented?

## Stretch

**53.** Write one pattern that matches every **well formed** identifier in `ids.txt` and nothing else.
Define "well formed" yourself first, in one sentence, then defend your pattern against every line it
rejects.

**54.** `log.txt` claims to be one report. Write the pattern that finds every line whose timestamp is
*not* in the dominant format, and say which of those lines is a formatting variant and which is a
different record type.

**55.** A colleague writes `grep -c '[0-9]*' file` and reports that every line has a number. Explain
their bug in one sentence and give the count they wanted.

## Dig

**56.** Two lines in `log.txt` are ISO-shaped but not ISO. Find them with one pattern, and say what
would break in a tool that sorted these lines as text.

**57.** Using only this lesson, write a check that would tell you whether a numbered report is
missing an entry. State clearly what your check can and cannot prove — this matters later.

**58.** `pairs.txt` line `ok ok ok` matches a repeated-word pattern. How many *different* repeated
pairs are in it, and what does `grep -o` report? Explain the gap between those two numbers.
