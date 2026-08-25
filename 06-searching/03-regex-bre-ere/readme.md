# 06/03 — Regular Expressions: BRE and ERE

> Two dialects of the same language, separated by which characters need a backslash. Learn the
> language once; learn the escaping twice.

## What this lesson is

Everything so far treated the pattern as a string with two surprises in it (`.` and `*`). This lesson
makes the pattern a language with a grammar. Four constructs and one operator:

- **anchors** — `^` start of line, `$` end of line
- **classes** — `[0-9]`, `[^0-9]`, `[[:digit:]]`, and `.` for any character
- **quantifiers** — `*` zero or more, `?` zero or one, `+` one or more, `{n}` / `{n,m}` counted
- **groups** — a parenthesised sub-pattern, with backreferences to what it matched
- **alternation** — `a|b`, either side

That is the whole of POSIX regular expressions. What varies is punctuation.

## BRE, ERE, and the backslash

`grep` with no flags speaks **Basic** regular expressions. In BRE, `?`, `+`, `{`, `}`, `(`, `)` and
`|` are **literal characters**, and you get the operator by backslashing them: `\?`, `\+`, `\{2\}`,
`\(…\)`, `\|`. `^`, `$`, `.`, `*` and `[…]` are operators already.

`grep -E` speaks **Extended** regular expressions, where those characters are operators and you
backslash them to get the literal. Same language, inverted convention.

This has one consequence you will meet in about five minutes: `grep 'BAY-[0-9]{2}'` finds nothing,
because BRE reads `{2}` as four literal characters and no line contains them. There is no error. The
pattern is valid, it simply asks for something that is not there. **A regex that returns nothing is
not evidence that the thing is absent until you have checked that your dialect read it the way you
meant.**

Rule of thumb: if the pattern has more than one backslash in it, write it with `-E` instead.

## Anchors change the question

`BAY-01` asks "does this line contain it". `^BAY-01$` asks "is this line exactly it". Between those
two questions live most of the wrong answers in this chapter, and the reason `-x` and `-w` exist as
flags is that people kept getting the anchored forms wrong.

`^` and `$` match positions, not characters. `^$` is a valid pattern and matches an empty line;
`grep -c '^$'` counts blank lines and is a genuinely useful thing to know.

## Greed

`*`, `+` and `{n,}` are **greedy**: they take the longest match that still allows the rest of the
pattern to succeed. `\[.*\]` against `[one] [two]` matches the whole line, not `[one]`, because
`.*` swallows `] [two` and the final `\]` still finds a `]` at the end.

POSIX `grep` has no lazy quantifier. The fix is not `.*?` — that is `grep -P`, a different engine —
it is to say what you actually mean: `\[[^]]*\]`, "a bracket, then anything that is not a closing
bracket, then a closing bracket". A negated class is almost always the right answer to a greed
problem, and it is faster too.

## Classes, and what is in them

`[0-9]` and `[a-z]` are ranges over the collation order, which is why serious scripts write
`[[:digit:]]` and `[[:alpha:]]` instead — those are defined by the locale and cannot be surprised by
it. Inside a bracket expression almost nothing is special: `[.]` is a literal dot, `[^]]` is
"not a closing bracket" (a `]` first in the class is literal), and a `-` is literal if it is first or
last.

A backslash is **not** an escape inside a bracket expression. `[ \t]` is the set {space, backslash,
`t`} — three characters, no tab. And outside brackets it is no better: GNU `grep` does **not** accept
`\t` in a POSIX pattern at all — it warns `stray \ before t` and matches nothing. GNU does add
`\b`, `\w`, `\s` and `\<`, but those are GNU-only, and `[[:space:]]` is the portable answer that
also happens to be the correct one. To match a literal tab in a POSIX pattern, put a real tab in it
(`$'\t'` from bash) or use `[[:space:]]`.

## Backreferences

`\(…\)` in BRE, `(…)` in ERE, and `\1` refers back to what the first group matched — not to the
pattern, to the **text**. `\([a-z]\+\) \1` finds a repeated word. This is not a regular operation in
the formal sense, which is why it can be slow, and why `grep -F` has no equivalent.

## `-P` exists

`grep -P` uses PCRE: lazy quantifiers, lookahead, `\d`, named groups. It is available here and it is
the wrong reflex. Two reasons: `-P` is not always compiled in on machines you do not control, and a
PCRE that took thirty seconds to write can take exponential time to run on adversarial input. Use it
when you need lookaround, and know that you have left POSIX behind.

## The shape of the lab

`ids.txt` — eighteen station identifiers, most well formed, several not, and the malformations are
the interesting part. `log.txt` — one log written in three timestamp formats. `pairs.txt` — lines
with repeated words, including one that repeats *almost*. `spacing.txt` — the same record with tabs,
one space and several. `greedy.txt` — bracketed fields, including an unclosed one. `dots.txt` —
literal dots and near misses. `scratch/` is yours.

## What "solved" looks like

You can write a pattern in BRE, convert it to ERE, and say which characters changed and why. You can
tell the difference between "found nothing" and "asked the wrong question". You can fix a greedy
match with a negated class rather than by reaching for `-P`. And you can explain what `[ \t]`
actually matches.

## Before you move on

Lesson 04 leaves `grep` for `find`, which has its own pattern language — glob-style, not regex — and
the first mistake everyone makes is bringing this lesson's syntax with them.
