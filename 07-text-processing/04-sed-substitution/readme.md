# 07/04 — `sed`: substitution

> You will be handed files that are almost the right shape. This is how you fix ten thousand lines
> without opening any of them.

## What this lesson is

Lesson 03 gave you a tool that maps characters. This one gives you a tool that matches **patterns**
and rewrites them. `sed` — stream editor — reads a file line by line, applies your instructions to
each line, and prints the result. It never touches the original unless you tell it to.

This lesson covers `s///` and addresses. That is roughly ninety percent of the `sed` anyone runs.
`sed` can also hold multiple lines in memory and branch like a programming language; that part is out
of scope, and when you need it you almost certainly want `awk` (lesson 05) instead.

## The substitute command

```
sed 's/PATTERN/REPLACEMENT/' file
```

Read it as four fields separated by slashes: the command `s`, the pattern, the replacement, and the
flags (empty here). The pattern is a **basic** regular expression — the same BRE you met in chapter 6
with `grep`.

```
$ sed 's/^ *//' data/counts.txt
412 ops-bot
96 rhea
54 cass
21 vint
12 orla
4 bex
1 maintenance
```

That is `uniq -c` output with the leading padding removed. Lesson 01 exercise 37 asked you to do this
and you did it; now look at what else the same command can do:

```
$ sed 's/^ *\([0-9]*\) \(.*\)/\2\t\1/' data/counts.txt
ops-bot	412
rhea	96
...
```

`\(` and `\)` mark a **capture group**; `\1` and `\2` in the replacement are what those groups
matched. Lesson 02 could split columns but never reorder them. This is the tool that reorders them.

## Without a filename it reads standard input

Unlike `tr`, `sed` takes filenames. It also reads stdin when given none, so both of these work:

```
$ sed 's/x/y/' file
$ cat file | sed 's/x/y/'
```

The first is better. There is no prize for extra processes.

## Flags

Flags go after the closing delimiter.

| Flag | Effect |
|---|---|
| (none) | replace the **first** match on each line |
| `g` | replace **every** match on the line |
| `N` | replace only the Nth match on the line |
| `Ng` | replace the Nth match and everything after it |
| `p` | print the line if a substitution happened (pair with `-n`) |
| `w FILE` | write the changed line to FILE |
| `I` | match case-insensitively |

```
$ sed 's/1/ONE/2' data/nums.txt
panel 1 of ONE in bay 1
```

The default is first-match-only, and this is the single most common `sed` bug on the station: someone
writes `s/old/new/`, tests it on a line with one match, and ships it against a file where half the
lines have two.

## Any delimiter you like

The slash is not special. Whatever character follows `s` becomes the delimiter:

```
$ sed 's|.*/||' data/paths.txt
access.log
panel.log
kestrel
forms.txt
```

That strips a leading directory. Written with slashes it would be
`sed 's/.*\///'` — correct, unreadable, and known in the trade as leaning-toothpick syndrome. When
your pattern contains slashes, change the delimiter. `|`, `#`, `,` and `:` are all common.

## Regular expressions: BRE and `-E`

By default `sed` speaks BRE, so `+`, `?`, `|`, `(` and `)` are literal characters and you backslash
them to get the special meaning. `-E` switches to ERE, where it is the other way round.

```
$ sed  's|\([0-9]*\)/\([0-9]*\)/\([0-9]*\)|\3-\2-\1|' data/dates.txt
$ sed -E 's|([0-9]+)/([0-9]+)/([0-9]+)|\3-\2-\1|'      data/dates.txt
```

Identical output. The second is easier to read and you should prefer it, exactly as in chapter 6.
Note that `\1` and `\2` stay backslashed in the **replacement** under both — the replacement is not a
regular expression.

## `&` is the whole match

```
$ sed 's/[0-9][0-9]*/[&]/' data/amp.txt
[41]
[193]
```

`&` in the replacement means "everything the pattern matched". To get a literal ampersand, write `\&`.

## Regular expressions are greedy

This is the other bug you will write:

```
$ sed 's/".*"/X/' data/quoted.txt
deck-01 X
```

You wanted to replace the first quoted field. `.*` matched from the first quote all the way to the
**last** one on the line, because a regular expression takes the longest match it can. The fix is to
say what the field cannot contain:

```
$ sed 's/"[^"]*"/X/' data/quoted.txt
deck-01 X 2187-06-10 "routine"
```

`[^"]*` is "any run of characters that are not quotes", which cannot run past the closing quote.
Remember this shape — it is the standard answer to greediness, and `sed` has no non-greedy operator.

## GNU case conversion

`\U`, `\L`, `\u` and `\l` in the replacement change case: the first two until further notice, the
second two for one character.

```
$ sed 's/^./\u&/' data/case.txt
Rhea
Cass
```

These are GNU extensions. They will not work on a Mac. Neither will several other things in this
lesson, and the station runs GNU, so use them here and check before you rely on them elsewhere.

## Addresses

Put an address before a command and the command applies only to matching lines.

| Address | Meaning |
|---|---|
| `3` | line 3 |
| `$` | last line |
| `2,5` | lines 2 through 5 |
| `/BEGIN/` | every line matching the pattern |
| `/BEGIN/,/END/` | from a matching line to the next line matching END |
| `1~2` | every second line starting at 1 (GNU) |
| `/x/!` | every line **not** matching |

```
$ sed -n '/BEGIN summary/,/END summary/p' data/blocks.txt
$ sed '/TODO/d' data/report.txt
$ sed '/BEGIN appendix/,/END appendix/s/^/  /' data/blocks.txt
```

`d` deletes, `p` prints, `q` quits. `-n` suppresses the automatic printing of every line, which is
what makes `-n` + `p` a filter rather than a duplicator. Run `sed '/TODO/p'` without `-n` once so you
have seen the duplication for yourself.

## Several commands at once

Two forms, identical in effect:

```
$ sed -e 's/  */ /g' -e 's/[ \t]*$//' -e 's/\r$//' data/report.txt
$ sed 's/  */ /g; s/[ \t]*$//; s/\r$//'           data/report.txt
```

Order matters, and it matters in a way that will bite you: `s/[ \t]*$//` does **not** remove a
trailing carriage return, because `\r` is neither a space nor a tab. A file that came from a Windows
machine will look clean and compare unequal. Strip the CR first, then the whitespace.

## In place

```
sed -i 's/old/new/' file        # edits the file, no backup, no undo
sed -i.bak 's/old/new/' file    # edits the file, keeps file.bak
```

`-i` is the only part of `sed` that can destroy work. The habit worth building is: run it without
`-i` first and look at the output, then add `-i.bak` and check the diff. There is a directory called
`scratch/` in this lab for exactly this, and every exercise that uses `-i` uses a copy.

## What you have

```
$ cat notes/style.txt
```

The station's report style rules, four of them, and a draft that breaks all four. The last exercises
are that cleanup, and the pipeline you build there is one you will reuse for the rest of the course.

Files: `logs/access-2187-06-10.log`, `data/counts.txt`, `data/dates.txt`, `data/paths.txt`,
`data/quoted.txt`, `data/report.txt`, `data/blocks.txt`, `data/roster.tsv`, `data/case.txt`,
`data/amp.txt`, `data/nums.txt`, `notes/style.txt`, and an empty `scratch/`.

Now `exercises.md`.
