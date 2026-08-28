# 07/02 — `cut` and `paste`

> The station's logs are columns. Everything downstream gets easier the moment you can take one.

## What this lesson is

Lesson 01 ended at a wall. You could count identical whole lines, but you could not count the third
word of six hundred lines that were identical in nothing else. Every log on this station is columns,
and `uniq` cannot see a column.

`cut` takes columns out. `paste` puts them back, or joins columns from separate files side by side.
Between them they are the cheapest tools in the chapter — no regex, no expressions, nothing to learn
beyond counting from one. That cheapness is also their limit, and half this lesson is about where the
limit is, because `cut` fails **silently** and produces output that looks like data.

## `cut`

`cut` prints selected parts of every line. You must tell it what to select, in exactly one of three
ways:

- `-f LIST` — **fields**, separated by a delimiter
- `-c LIST` — **characters**, by position
- `-b LIST` — **bytes**, by position

```
$ cut data/roster.tsv
cut: you must specify a list of bytes, characters, or fields
```

You may use exactly one of them at a time; `cut -f2 -c1` is an error. Fields are numbered from 1, and
`cut -f0` is an error too.

### The list

A LIST is comma separated and understands ranges:

```
-f3          field 3
-f3,5        fields 3 and 5
-f2-4        fields 2 through 4
-f5-         field 5 to the end of the line
-f-2         the start of the line through field 2
--complement -f2   everything except field 2
```

Two things about the list that surprise people:

**The order is ignored.** `cut -f5,3` prints field 3 then field 5, the same as `cut -f3,5`. `cut`
walks the line once, left to right, and emits whatever it passes that you asked for. **`cut` cannot
reorder columns.** If you need field 5 before field 3, you need `paste` (below) or `awk` (lesson 05).

**Fields you did not ask for do not exist in the output**, but the delimiter between the ones you did
is preserved:

```
$ cut -f3,5 data/roster.tsv | head -2
deck	role
deck-02	systems
```

### The delimiter

`cut`'s default delimiter is a **tab**. Not a space. This is why the station's report style says
"columns are separated by a single tab" — it is the format every tool already agrees about.

For anything else, `-d`:

```
$ cut -d, -f2 data/roster.csv
$ cut -d' ' -f3 logs/access-2187-06-10.log
```

`-d` takes exactly **one character**. Not a string, not a regex, not "one or more spaces".

```
$ cut -d'' -f1 data/roster.csv
cut: the delimiter must be a single character
```

`--output-delimiter=STRING` changes what goes *between* the selected fields on the way out, and it
may be more than one character:

```
$ cut -f3,5 --output-delimiter=' | ' data/roster.tsv | head -2
deck | role
deck-02 | systems
```

### Lines that do not fit

Two cases, and `cut`'s behaviour is different for each.

**A line with fewer fields than you asked for** gives you an empty result for the missing field. No
warning, no error, an empty line in your output.

**A line with no delimiter at all** is printed **whole**, unchanged. This one bites. A file with a
header banner, a separator line, or a trailing `-- end of extract --` will emit that entire line into
a column of accounts, and nothing tells you.

`-s` (`--only-delimited`) suppresses lines that contain no delimiter:

```
$ cut -f2 data/short.tsv        # the line "vint" comes out whole
$ cut -s -f2 data/short.tsv     # it is dropped
```

Use `-s` whenever you are cutting a file you did not generate.

### `-c`: characters, and when it is a trap

`-c` selects by position, which is right when the format really is fixed width — a timestamp is
always the same length, so `cut -c12-19` pulls the time out of every line of the access log
regardless of what follows.

It is wrong the moment a human aligned the file by eye. `data/aligned.txt` looks like four neat
columns. `cut -c11-20` reads it perfectly. `data/ragged.txt` holds the same data with two rows
aligned slightly differently, and the same command returns:

```
01 day med
```

which is not an error, is not empty, and will go straight into a report.

### Why `-d' '` usually fails on human-aligned text

`cut` does not collapse runs of delimiters. Two spaces mean an empty field between them. On
`data/aligned.txt`, `cut -d' ' -f2` prints six empty lines, because field 2 is the second space.

The fix is not a `cut` flag — there is not one. You squeeze the runs first, with `tr -s ' '`
(lesson 03), or you use a tool that treats whitespace runs as one separator by default (`awk`,
lesson 05). This lesson's job is to make you feel the gap.

### What `cut` cannot do at all

It cannot parse quoting. `data/roster.csv` and `data/roster.tsv` hold the same roster; one record's
name contains a comma, and in the CSV it is properly quoted:

```
7,"Maintenance, Deck",deck-03,day,facilities
```

`cut -d, -f2` gives you `"Maintenance` and moves on. `cut` has no concept of a quoted field and never
will. For real CSV you need a real CSV parser; `cut` is for formats where the delimiter cannot occur
inside a value, which is exactly what the note in `notes/columns.txt` is telling you to choose.

## `paste`

`paste` is the other direction: it reads files in parallel and writes one line per row, joined by
tabs.

```
$ paste data/ids.txt data/names.txt data/decks.txt
1	rhea	deck-02
2	cass	deck-01
```

`-d` sets the joining character. Given several, `paste` **cycles** through them:

```
$ paste -d:- data/ids.txt data/names.txt data/decks.txt
1:rhea-deck-02
```

`-d'\n'` is a legitimate and occasionally useful choice: it interleaves the files instead of
columnising them.

**Unequal lengths are padded, not refused.** `paste data/ids.txt data/extra.txt` gives five lines,
the last two with an empty second column. `paste` assumes the files are row-aligned and cannot check
it. If two files got out of step, `paste` will silently attach the wrong name to the wrong id — the
same failure as `cut -c` on ragged input, from the other side.

### `paste -s`

`-s` ("serial") pastes each file's lines into a **single row** instead of reading files in parallel:

```
$ paste -s -d, data/names.txt
rhea,cass,vint,orla,bex
```

This is the standard way to turn a column into a comma-separated list, and you will use it in every
chapter from here on.

### `paste - -`

`-` means standard input, and it may appear more than once. Each `-` consumes one line per row, so
`paste - - < file` reshapes a single column into two columns:

```
$ paste - - < data/flat.txt
12	7
31	4
19	2
```

`paste - - -` gives three. It is the fastest way to fold a long thin file into something readable.

### Reordering with `paste`

Because `cut` will not reorder, this is the idiom that does:

```
$ paste <(cut -f5 data/roster.tsv) <(cut -f2 data/roster.tsv)
role	name
systems	Rhea
```

Two passes over the file, joined by position. It works, it is honest, and by lesson 05 you will write
it as `awk '{print $5, $2}'` in one pass. Learn both — the `paste` version composes with things that
are not files-you-can-read-twice.

## The thing lesson 01 could not do

```
$ cut -d' ' -f3 logs/access-2187-06-10.log | sort | uniq -c | sort -rn
```

That is a per-account frequency table of six hundred log lines. `cut` supplies the column, and the
idiom you already know does the rest. Read it all the way to the bottom.

## Files in this lab

```
logs/access-2187-06-10.log   600 lines, five space-separated fields
data/roster.tsv              the roster, tab separated
data/roster.csv              the same roster, comma separated, one quoted field
data/aligned.txt             columns aligned with runs of spaces
data/ragged.txt              the same, alignment broken on two rows
data/short.tsv               rows with missing fields, and one line with no delimiter
data/ids.txt names.txt decks.txt    parallel columns, equal length
data/extra.txt               a shorter column
data/flat.txt                one number per line
notes/columns.txt            the station's report style
scratch/                     yours
```
