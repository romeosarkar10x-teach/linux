# 07/03 — `tr`

> The bluntest tool in the chapter and the right one about once a week.

## What this lesson is

`tr` translates characters. Not words, not patterns, not fields — **characters**. It has no regular
expressions, no notion of a line beyond the newline being one more character, and it cannot even open
a file.

That last one catches everyone:

```
$ tr 'A-Z' 'a-z' data/mixed-case.txt
tr: extra operand ‘data/mixed-case.txt’
```

`tr` reads **standard input only**. There is no filename argument, ever. You redirect (`< file`) or
you pipe. This is not an oversight; `tr` is a filter and nothing else.

Because it is so limited it is also fast, predictable, and impossible to get subtly wrong in the way
`sed` can be. Once a week you will want exactly what it does, and the rest of the time you will want
lesson 04.

## The basic form

```
tr SET1 SET2
```

Every character of the input that appears in SET1 is replaced by the character at the **same
position** in SET2. Everything else passes through unchanged.

```
$ tr 'A-Z' 'a-z' < data/mixed-case.txt
```

`A-Z` is a **range**, written the way you would expect. `tr` also understands the POSIX character
classes:

```
[:alpha:]  [:digit:]  [:alnum:]  [:upper:]  [:lower:]
[:space:]  [:blank:]  [:punct:]  [:print:]  [:cntrl:]
```

`tr '[:upper:]' '[:lower:]'` is the portable, locale-aware way to fold case, and it is what you should
write.

And it understands backslash escapes: `\n`, `\t`, `\r`, `\\`, and octal like `\011`.

## The two length rules

**SET1 longer than SET2**: SET2 is padded by repeating its **last character**.

```
$ echo abcdef | tr 'abcdef' 'xy'
xyyyyy
```

This is a real behaviour with a real use — `tr '[:digit:]' '#'` masks every digit with one character —
and a real trap, because `tr 'abcdef' 'xy'` almost certainly was not what somebody meant.

`-t` (`--truncate-set1`) turns it off: SET1 is shortened to SET2's length instead, and the surplus
characters are left alone.

```
$ echo abcdef | tr -t 'abcdef' 'xy'
xycdef
```

**SET2 longer than SET1**: the surplus is silently ignored. `tr 'ab' 'xyz'` is the same as
`tr 'ab' 'xy'`.

Neither case is an error. `tr` never warns about a mismatch.

## `-d` — delete

`-d SET` deletes every character in SET. There is no SET2.

```
$ tr -d '\r' < data/crlf.txt
```

That one command is the fix for a file written on a system that ends lines with carriage
return + newline. Before you know that is the problem, such a file looks fine in `cat`, compares
unequal to a file that looks identical, and `cut -f2` on it yields values with an invisible `^M`
glued to the end. `cat -A` shows it; `tr -d '\r'` removes it.

Be careful with `-d` and classes:

```
$ tr -d '[:cntrl:]' < data/ctrl.txt
```

**A newline is a control character.** That command deletes every line ending too, and returns the
whole file as one long line. Which brings us to:

## `-c` — complement

`-c` inverts SET1: operate on every character **not** in the set.

```
$ tr -cd '[:print:]\n' < data/ctrl.txt
```

"Delete everything that is not printable, except newlines." That is the correct way to strip control
characters out of a file, and it is a general pattern: **say what you want to keep, not what you want
to remove.** The set of things you want is finite and you can write it down; the set of things you do
not want is everything else and you will forget some of it.

## `-s` — squeeze

`-s SET` collapses each **run** of repeated characters from SET into one.

```
$ tr -s ' ' < data/aligned.txt
account deck shift role
rhea deck-02 day systems
```

This is the fix for lesson 02's dead end: `cut -d' '` could not read human-aligned columns because
`cut` does not collapse delimiters, and `tr -s ' '` collapses them before `cut` ever sees the line.

`-s` given two sets translates first and squeezes the **result**:

```
$ echo aaabbbccc | tr -s 'abc' 'xyz'
xyz
```

`-s` with one set squeezes only, no translation.

Flags combine: `tr -ds 'b' ' '` deletes `b` and squeezes spaces, with `-d` taking the first set and
`-s` the second.

## The word-frequency idiom

Put `-c` and `-s` together and you get one of the most useful one-liners there is:

```
$ tr -cs '[:alpha:]' '\n' < data/prose.txt | tr '[:upper:]' '[:lower:]' | sort | uniq -c | sort -rn
```

"Replace every run of non-letters with a single newline" turns prose into one word per line. Without
`-s` you get an empty line everywhere two non-letters were adjacent — a full stop followed by a space
is two — and the count of blank lines will be substantial. `-s` is not decoration here.

## `tr` works on bytes

This matters and it is not in the name. `tr 'a-z' 'A-Z' < data/utf8.txt` gives:

```
CAFé
NAïVE
```

The accented letters are two bytes each, neither of which is in `a-z`, so they pass through untouched
while everything around them is folded. `tr` will also happily cut a multi-byte character in half if
you delete one of its bytes. For ASCII text — which is what station logs are — `tr` is exact. For
anything with accents, emoji or non-Latin script, `tr` is the wrong tool and `sed` is the next lesson.

## Things `tr` cannot do

- **It cannot replace a string.** `tr 'cat' 'dog'` maps `c`→`d`, `a`→`o`, `t`→`g`; it does not touch
  the word "cat". This is the single most common misuse.
- **It cannot match a pattern.** No wildcards, no anchors, no groups.
- **It cannot read a file by name.**
- **It cannot insert.** SET1 and SET2 map one character to one character; nothing gets longer.

Every one of those is lesson 04.

## rot13

The classic `tr` demonstration, and it is genuinely how people write it:

```
$ tr 'A-Za-z' 'N-ZA-Mn-za-m' < notes/rot13.txt
```

Two ranges on each side, rotated thirteen places. Running it twice returns the original, because
thirteen is half of twenty-six. Read `notes/rot13.txt` — decoded — for what it is actually for.

## Files in this lab

```
data/mixed-case.txt      account names in inconsistent case
data/roster-display.txt  the roster's display names
data/log-accounts.txt    600 lines, the account column of the access log
data/aligned.txt         columns padded with runs of spaces
data/crlf.txt            CRLF line endings
data/ctrl.txt            embedded control characters
data/prose.txt           four sentences of prose
data/digits.txt          identifiers with assorted punctuation
data/table.txt           tab separated, one value contains a comma
data/short-sets.txt      input for the SET length rules
data/utf8.txt            multi-byte characters
notes/rot13.txt          rot13'd
scratch/                 yours
```
