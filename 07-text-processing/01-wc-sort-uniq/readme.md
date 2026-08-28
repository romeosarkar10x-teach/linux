# 07/01 — `wc`, `sort`, `uniq`

> Three commands and one idiom that between them answer most of the questions anybody on this
> station will ever ask you about a log file.

## What this lesson is

The questions people actually ask about a file are countable ones. How many? How many of each?
Which is the most? Which appears only once? None of those are answered by reading, and all three of
this lesson's tools exist because somebody got tired of reading.

`wc` counts. `sort` orders. `uniq` collapses runs of identical **adjacent** lines. That third word is
the one to memorise, because `uniq` is not a duplicate finder and nothing in its name or its output
will warn you.

Chained together they produce the single most-used idiom in this entire course:

```
sort file | uniq -c | sort -rn
```

"Group identical lines, count each group, put the biggest group first." It is a frequency table, and
you will build one at least once a week for the rest of your working life.

## `wc`

`wc` prints counts for its input. With no flags it prints three: **lines, words, bytes**, in that
order, then the filename.

```
$ wc logs/access-2187-06-10.log
  600  3000 24189 logs/access-2187-06-10.log
```

The flags select which counts you get: `-l` lines, `-w` words, `-c` bytes, `-m` characters, `-L` the
length of the longest line. `-c` and `-m` differ only when the file is not plain ASCII — a two-byte
character counts once for `-m` and twice for `-c`.

Two behaviours worth knowing before they surprise you:

**It counts newlines, not lines.** `wc -l` reports how many `\n` bytes are in the file. A file whose
final line has no trailing newline is reported one short, and nothing about the output says so.
`logs/no-newline.log` in this lab has three lines of text and `wc -l` says `2`.

**Given a filename it prints the filename; given stdin it does not.** `wc -l file` prints
`600 file`. `wc -l < file` prints `600`. That difference matters the moment you put a count inside
another command, and it is why `wc -l < file` is the form to reach for in scripts. Given several
files it prints one line each and a `total`.

## `sort`

`sort` reads lines and writes them in order. The default order is **not** the order you expect, and
the default notion of "field" is **not** the one you expect either. Both defaults are defensible and
both bite.

**Default comparison is textual, not numeric.** Text compares character by character, so `10` comes
before `9` — `1` is less than `9` and the comparison never reaches the second character. `-n` says
compare as numbers. `-h` says compare human-readable sizes, so `512` sorts below `1K` below `2M`.
`-V` compares version strings, which is the only way `v1.9` sorts before `v1.10`. Pick the wrong one
and you still get output — sorted output, confidently wrong.

**Which characters compare how depends on the locale.** This station runs `C.UTF-8`, in which
comparison is by byte value, so every uppercase letter sorts before every lowercase one and
`DECK-02` lands above `deck-01`. `-f` folds case for the comparison. A pipeline whose correctness
depends on the ordering should set `LC_ALL=C` and say so, rather than inherit whatever the caller
had.

**Fields.** `-k` selects what to compare. The trap is that `-k2` does not mean "field 2" — it means
"**from** field 2 to the end of the line". To compare field 2 alone you write `-k2,2`. Those two give
different answers whenever a later field disagrees with the tie-break, and you will read past the
difference twice before you see it.

By default a field starts at the transition from blank to non-blank, so runs of spaces or tabs all
separate fields and leading blanks are part of the key. `-t` sets an explicit single-character
separator — `-t:` for passwd-style files, `-t$'\t'` for tab-separated ones. With `-t` the separator is
the *only* thing that ends a field, which is exactly what you want when a field contains a space.

Modifiers attach to a key: `-k3,3n` is "field 3, numerically", and it is better than a global `-n`
because it says which column you meant.

Other flags earning their place: `-r` reverse, `-u` output only the first of each equal run, `-c`
check whether the input is already sorted (exit 1 and name the first offending line if not), `-s`
stable, `-o FILE` write to a file which **may be the input file** — the one safe way to sort a file
in place, and the reason `sort f > f` truncating `f` is a story every generation relearns.

**Stability.** When two lines compare equal, GNU `sort` falls back to comparing the whole line, so
equal keys come out in an order that has nothing to do with the input. `-s` disables that last-resort
comparison and preserves input order for equal keys. That is what makes a two-pass sort work: sort by
the secondary key, then `-s` sort by the primary.

## `uniq`

`uniq` collapses **adjacent** identical lines into one. That is the whole tool.

The consequence is the most common beginner error in text processing: `uniq` on unsorted input
appears to work and reports nonsense. `data/accounts-week.txt` in this lab holds 271 lines drawn from
eight accounts. `uniq -c` on it produces **171** groups. Sorted first, it produces eight. Neither run
warns you; one of them is just wrong.

The useful flags: `-c` prefix each group with its count, `-d` print only lines that were duplicated,
`-u` print only lines that appeared exactly once, `-D` print every copy of every duplicated line,
`-i` ignore case, `-f N` skip the first N fields before comparing, `-s N` skip the first N characters,
`-w N` compare at most N characters.

`-i` has a trap of its own: `uniq -i` compares case-insensitively but `sort` did not, so equal-ignoring-
case lines are still not adjacent and still are not collapsed. If you want case-insensitive grouping
you need `sort -f | uniq -ci`, both halves.

`sort -u` and `sort | uniq` produce the same lines. They are not the same thing: `sort -u` cannot
count, cannot show you only the duplicates, and cannot show you only the singletons. Use `-u` when
you want a set; use `uniq` when you want to know something about the multiplicity.

## The idiom, and its tail

```
$ sort data/accounts-week.txt | uniq -c | sort -rn
    148 ops-bot
     61 rhea
     33 cass
     14 vint
      9 orla
      3 bex
      2 maintenance
      1 sensor-cal
```

Sorted, grouped, counted, ranked. `-rn` on the second sort because the count is now the first field
and it is a number.

Notice what the ranking does to your attention. The top of that list is a machine account doing
machine things, and it is where every eye goes. The bottom is one line, one count, one account, and
it is the only line in the output that says something happened exactly once. Ranked descending, the
interesting part of a frequency table is very often the part you have to scroll to.

## What this lesson deliberately does not give you

There is no way, with only `wc`, `sort` and `uniq`, to count accesses per account in
`logs/access-2187-06-10.log`. The account is the third column of a five-column line, `uniq` compares
whole lines, and `-f2` skips the first two fields but keeps everything after the account too. You can
get close and you cannot get there.

That is on purpose. Exercise 31 asks you to try. The tool you need is `cut`, and it is the next
lesson.

## Files in this lab

```
logs/access-2187-06-10.log   600 lines, five columns, seven accounts
logs/access-2187-06-11.log   563 lines, the next day
logs/no-newline.log          three lines of text, no trailing newline
logs/wide.log                three lines, one of them long
data/accounts-week.txt       271 lines, one account name per line, unsorted
data/decks.txt               eight lines, mixed case, duplicates
data/adjacent.txt            seven lines, duplicates that are not adjacent
data/sizes.txt               integers
data/sizes-h.txt             sizes with K/M/G suffixes
data/versions.txt            version strings
data/duty.txt                tab separated: account, deck, shift
data/tasks.txt               tab separated, and field 2 contains spaces
data/ties.txt                two fields, deliberate ties
data/nums-mixed.txt          negatives and leading blanks
notes/reporting.txt          what "the access numbers" has meant before
scratch/                     yours
```
