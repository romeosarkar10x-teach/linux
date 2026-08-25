# 06/03 — Validation: Regular Expressions

You are checking whether a student has actually learned this lesson. Ask, do not accept assertions;
every claim here is checkable in the lab in one command.

## The one thing that must be true

**The student treats an empty result as a claim requiring proof.** They know that a pattern written
in the wrong dialect returns nothing and exits 1 exactly like a correct pattern with no matches, and
their first move on a surprising zero is to check the pattern, not the file.

## Must be able to do

1. State the BRE/ERE rule in one sentence and give one example of a pattern in each dialect that
   means the same thing.
2. Predict, before running it, whether `grep 'BAY-[0-9]+' ids.txt` errors, matches, or is quiet — and
   say what it actually searched for (a literal `+`).
3. Distinguish "contains" from "is" with anchors, and show the two lines of `ids.txt` that `^BAY`
   removes and why (leading space, leading dash).
4. Explain why `^[A-Z]*-[0-9]*$` matches eleven lines instead of the intended set, naming `*`'s
   zero case as the cause.
5. Show what `\[.*\]` matches on a line with two bracketed fields, and fix it with `\[[^]]*\]`.
6. Match a literal tab without using `\t`, and quote the warning GNU grep gives for `\t`.
7. Say what a backreference compares — the matched **text**, not the pattern — and demonstrate with
   `E-104 E-104` versus `E-104 E-105`.

## Should be able to do

- Name a case where `[0-9]` and `[[:digit:]]` differ (locale), and say which belongs in a script.
- Say why `-P` exists and give two reasons not to reach for it.
- Explain why an unpadded date sorts wrongly as text.

## Common wrong answers

- "`grep -E 'a{2'` is a syntax error." It is not; GNU accepts an unmatched `{` as literal, exit 1.
- "`\t` works in GNU grep." It does not: `stray \ before t`, zero matches.
- "`^*` matches every line." It matches lines starting with a literal asterisk — glob thinking.
- "`grep -o` on `ok ok ok` finds two repeated pairs." One: matches do not overlap.
- "`.` needs escaping everywhere." Only where a literal dot matters; `-F` is the real answer for
  data-derived patterns.
- "`\1` re-runs the group's pattern." It matches the exact text the group captured.

## Red flags

- Reaches for `-P` before trying POSIX.
- Fixes a miss by replacing a counted quantifier with `*` and does not look at what else it admits.
- Says "no matches, so the file doesn't contain it" without checking `$?` or the dialect.
- Uses `[ \t]` and believes it contains a tab.

## Sign-off question

> You are handed a log with twelve entries in three different date formats, and asked to filter it to
> "yesterday". Write down what you would check before writing any pattern, and say what your filter
> would silently drop if you wrote it against the format that appears most often.

A good answer names the survey step (`grep -v` against the dominant format to see the exceptions
first), and says plainly that five of the twelve entries are real records in a minority format and a
naive filter drops them with no error.
