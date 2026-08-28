# 07/05 — `awk`: fields

> `awk` is a programming language pretending to be a command. You need about six percent of it, and
> this is that six percent.

## What this lesson is

`cut` takes columns and cannot reorder them. `sed` rewrites patterns and cannot count. `awk` reads
**records** made of **fields**, and it can do arithmetic, keep totals, compare one field against
another, and print a report at the end.

It is also a full programming language with functions, arrays, regular expressions and its own
`printf`, and you can spend a year on it. Don't. The six lines in `notes/awk.txt` cover almost every
`awk` that gets written in anger on a station like this one. This lesson is those six lines and the
places they surprise you.

## The shape of a program

```
awk 'PATTERN { ACTION }' file
```

For each line, if PATTERN is true, run ACTION. Either half can be left out:

```
awk '{ print $3 }' file      # no pattern: every line
awk 'NF > 3' file            # no action: print the whole line
awk '$3 == "rhea"' file      # the same, with a condition on a field
```

The default action is `print $0` and the default pattern is "true". That is why `awk 'NF > 3'` is a
filter and `awk '{print $3}'` is a column extractor, from the same two-word grammar.

Quote the program in **single** quotes, always. `$3` means something to the shell and something
different to `awk`, and single quotes are what stop the shell getting there first.

## Fields

`$1`, `$2`, … are the fields. `$0` is the whole record. `NF` is how many fields this record has, so
`$NF` is the last one and `$(NF-1)` the one before it. `NR` is the record number — the line count so
far.

```
$ awk '{ print $3 }' logs/access-2187-06-10.log | sort | uniq -c | sort -rn
    412 ops-bot
     96 rhea
...
```

That is the lesson-01 pipeline with `cut` replaced. It looks like no gain until you try it on
`data/ragged.txt`, which is the same records with the column discipline destroyed:

```
$ cut -d' ' -f3 data/ragged.txt     # nonsense
$ awk '{print $3}' data/ragged.txt  # correct
```

**`awk`'s default field separator is a run of whitespace**, and leading whitespace does not create an
empty first field. `cut -d' '` splits on exactly one space and produces an empty field for every
extra one. This is the single biggest practical difference between the two tools, and it is why `awk`
survives contact with human-typed files.

## `-F` sets the separator

```
awk -F'\t' '{ print $2 }' data/roster.tsv
awk -F,    '{ print $2 }' data/roster.csv
awk -F'[0-9]+' '{ print $2 }'          # the separator is a regular expression
```

One trap: `-F' '` does **not** mean "one space". A single space is the code for the default
whitespace rule. If you genuinely need to split on each single space, write `-F'[ ]'`.

## `BEGIN` and `END`

`BEGIN` runs before the first record, `END` after the last. `END` is where reports come from, because
it is the only place that knows the totals.

```
$ awk '{ s += $3 * $4 } END { printf "%.2f\n", s }' data/readings.txt
618.36
```

Variables need no declaration and start empty — zero in arithmetic, the empty string in text. That is
why `s += …` works with no `s = 0` anywhere.

## Arrays, and the one idiom worth memorising

```
awk '{ c[$3]++ } END { for (k in c) print c[k], k }' logs/access-2187-06-10.log
```

That is `sort | uniq -c` in one pass, with no sort. `c` is an array indexed by strings; `c[$3]++`
creates the entry if it does not exist and adds one.

`for (k in c)` visits the keys in **no defined order**. If you want them ordered, pipe the output to
`sort` like everything else in this chapter. Do not trust the order you happen to see.

## Numbers and strings

`awk` decides whether a field is a number by looking at it. A field that looks numeric compares
numerically; a field that does not compares as text.

```
$ awk 'BEGIN { print ("10" < "9"), (10 < 9) }'
1 0
```

Both are correct. The first compares two strings and `"1"` sorts before `"9"`; the second compares two
numbers. When you want to force the issue, `$1 + 0` makes a number and `$1 ""` makes a string.

`awk` also reads a number out of the front of a field and ignores the rest, so `12V` is `12` in
arithmetic and `V` never causes an error. Convenient, and occasionally the reason a total is wrong
and nothing complained.

## `printf`

`print` is fine for pipelines. Reports want `printf`, which takes the same format strings as the
shell's:

```
$ awk '{ c[$3]++; t++ } END { for (k in c) printf "%-12s %4d %5.1f%%\n", k, c[k], 100*c[k]/t }' \
      logs/access-2187-06-10.log | sort -k2,2rn
ops-bot       412  68.7%
rhea           96  16.0%
```

`printf` prints no newline unless you write `\n`. `%-12s` is left-aligned in twelve columns, `%4d` is
an integer in four, `%5.1f` is one decimal place in five, and `%%` is a literal percent sign.

## `OFS`, and the `$1=$1` trick

Commas in a `print` produce the output field separator, which is a space by default:

```
awk -F'\t' '{ print $2, $1 }' data/roster.tsv        # tab in, space out
awk -F'\t' 'BEGIN{OFS="\t"} { print $2, $1 }' ...    # tab in, tab out
```

Assigning to any field makes `awk` rebuild `$0` using `OFS`. That is the whole reason the strange-
looking `{ $1 = $1; print }` exists: it re-joins the record with the new separator without changing
anything.

## What you have

The chapter's access log, a ragged copy of it, `data/roster.tsv` (one row missing a field, one field
containing a space), `data/roster.csv` (one field containing a quoted comma), `data/readings.txt`
(deck, panel, volts, amps — one panel is not well), `data/short.txt`, `data/blank.txt`,
`data/mixed.txt`, `notes/awk.txt`, and `scratch/`.

Lesson 04 ended with an ugly `sed` that extracted field 3. Exercise 1 is that same job. Notice how
long it takes.
