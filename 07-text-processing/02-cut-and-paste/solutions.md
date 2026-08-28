# 07/02 — Solutions

Every output below was measured in the container.

## cut: fields

**1.** A **tab**. `data/roster.tsv` is tab separated and `cut`'s default `-d` is a tab, so the command
works with no delimiter given. You know because the file's fields contain spaces (`Maintenance, Deck`)
and the field came out whole.

**2.** The CSV is comma separated, so the whole line contains no tab, so `cut` printed **the entire
line** for each row — the no-delimiter rule. Fix: `cut -d, -f2 data/roster.csv`.

**3.** `cut -f3,5 data/roster.tsv` → `deck`/`role` columns, separated by a **tab**. The output
delimiter defaults to the input delimiter.

**4.** Identical output to exercise 3. **`cut` ignores the order of the list.** It scans each line
once, left to right, and emits the selected parts in the order they occur.

**5.** `cut` cannot **reorder** columns. Ever. It can only select.

**6.**
- `-f2-4` — fields 2 through 4 inclusive.
- `-f5-` — field 5 through the end of the line.
- `-f-2` — the start of the line through field 2.

**7.** `cut -d, --complement -f2` = `cut -d, -f1,3-5`. Both give `id,deck,shift,role`. `--complement`
is worth using when the file has an unknown or changing number of trailing columns, because `-f1,3-`
still needs you to know where the end is — and it does not, so use `-f1,3-` in fact. `--complement`
wins when you want "everything except these two, wherever they are".

**8.**
```
cut: you must specify a list of bytes, characters, or fields
```
There is no sensible default. "The whole line" is `cat`; any particular field would be a guess. `cut`
refuses rather than guessing, which is the correct behaviour and unusual among these tools.

**9.**
```
cut: only one list may be specified
```
`-b`, `-c` and `-f` are three different ways of describing a position in a line and they are mutually
exclusive. You cannot ask for "field 2's first character" in one `cut`; you pipe one into another.

**10.**
```
cut: fields are numbered from 1
```
There is no field 0. (`awk`'s `$0` is the whole line, which is a different tool with a different
convention — do not carry the habit across.)

**11.** The **separator between the selected fields** became ` | `. What did not change: which fields
were selected, their order, and the fact that lines with no delimiter are still printed whole
(unchanged, with no ` | ` in them at all).

**12.** `--output-delimiter` accepts a string. `-d` does not:
```
cut: the delimiter must be a single character
```
Input delimiting is a single byte; output delimiting is free text. That asymmetry is the whole reason
`cut` is fast and the whole reason it cannot parse CSV.

## cut: the log

**13.** The **account**. Fields are `date time account action deck`.

**14.**
```
$ cut -d' ' -f3 logs/access-2187-06-10.log | sort | uniq -c | sort -rn
    412 ops-bot
     96 rhea
     54 cass
     21 vint
     12 orla
      4 bex
      1 maintenance
```

**15.** A way to isolate one column out of the middle of the line. `uniq` compares whole lines or
line **suffixes** (`-f`) or line **prefixes** (`-w`); the account is neither.

**16.** `read 300, write 150, exec 150`. 300+150+150 = **600**, which matches `wc -l`. Always do this
check — a frequency table that does not add up to the line count means you cut the wrong column, or
some lines had no delimiter.

**17.** `deck-01, deck-02, deck-03, deck-04` at **150 each**. That is not a finding, it is a null
result: perfectly even distribution across four decks means the deck column tells you nothing about
who did what. Worth writing down, because "we checked and it was uniform" is a real answer and a
report that omits it invites the same question again next week.

**18.** A **space** — the input delimiter, echoed. Fields 3 and 5 come out as `ops-bot deck-01`, and
field 4 is simply absent, so the space in the output is not the space that was in the input at that
position.

**19.** The **time**, `HH:MM:SS`. `-c` is safe here because the first two fields are genuinely fixed
width: `YYYY-MM-DD` is always ten characters and the separator is always one space, so the time is
always at characters 12–19. It is a machine-generated format, not a human-aligned one.

**20.** `1 maintenance` — one account appears exactly once in six hundred lines. It says that
whatever that account is for, it was used once that day. It does not say anything about a person, and
this is practice data.

## cut: where it breaks

**21.** Runs of spaces — `cat -A` shows `account   deck      shift     role$`. The columns are padded
to width 10.

**22.** Six empty lines. Field 1 is `account`, and field 2 is what lies between the first and second
space — which is nothing, because the spaces are adjacent.

**23.** Two adjacent delimiters delimit an **empty field**. `cut` does not collapse runs. This is
correct for `-d,` (an empty CSV cell is a real cell) and catastrophic for `-d' '` on aligned text.

**24.** Because the file really is fixed width: every column starts at character 1, 11, 21 and 31, so
characters 11–20 are exactly the deck column on every row.

**25.** Two rows differ. `cass` was written with single spaces and `orla` with a 12/8 split. The worst
line:
```
01 day med
```
That is the tail of `deck-01`, the whole word `day`, and the head of `medical`, from a row where the
alignment shifted left.

**26.** Because an error stops you and a plausible string does not. `01 day med` will be sorted,
counted, pasted into a column headed "deck", and read by someone who was not there. Every failure
mode in this lesson that matters is of this kind.

**27.** Yes: `deck`, `deck-02`, `deck-01`, … . `tr -s ' '` **squeezes runs of spaces into one**, which
turns the human alignment into a single-space delimiter that `cut` can use. `cut` has no flag that
does this and never will; squeezing is a transformation of the text, not a way of reading it.

**28.**
- `vint` is a line with **no tab at all**, so `cut -f2` printed it **whole**.
- `-- end of extract --` likewise: it contains no tab, so the banner appears in your column of decks.

**29.** `cut -f3 data/short.tsv` — the `cass` row (`cass<TAB>deck-01`, only two fields) came out
**empty**; `vint` and `-- end of extract --` came out **whole**.

**30.** `-s` drops the two lines with no delimiter (`vint`, the banner) and keeps the empty `cass`
result. Rule: **`-s` suppresses lines that contain no delimiter**; it says nothing about lines that
merely have too few fields.

**31.**
```
$ cut -d, -f2 data/roster.csv | tail -1   ->  "Maintenance
$ cut -d, -f3 data/roster.csv | tail -1   ->   Deck"
```
The name contains the delimiter. The CSV quotes it, and `cut` has no idea what a quote is; it counts
commas. The record is silently split across two columns and everything to its right is off by one.

**32.** **A delimiter must be a character that cannot occur inside any value.** `notes/columns.txt`:
"If a value can contain the separator, the separator is wrong. Pick another one." The note also
explains why the station standardised on tab: values on this station do not contain tabs.

## paste

**33.** A **tab**.

**34.** `paste -d, ids names` → `1,rhea`. `paste -d:- ids names decks` → `1:rhea-deck-02`. Three files
means **two gaps**, and `paste` cycles through the delimiter list: gap 1 gets `:`, gap 2 gets `-`. If
there were a fourth file, gap 3 would get `:` again.

**35.** It **interleaves** the files — id, name, id, name — instead of columnising them. Useful for
generating alternating-line formats: key/value pairs, or a list where each entry is a header line
followed by a body line.

**36.** Five lines. `paste` padded the missing values with **empty fields**:
```
4^I$
5^I$
```
The tab is there; the value is not.

**37.** Because `paste` cannot check row alignment — it assumes line *n* of every file describes the
same thing. If one file has a line missing in the *middle* rather than at the end, `paste` produces
five full rows with the wrong name against every id from that point down, and nothing is empty and
nothing is an error. Before trusting it: **compare `wc -l` of every input**, and if they differ, stop.
Equal counts are necessary, not sufficient — that is why `join` (chapter 8) exists, which matches on
a key instead of on position.

**38.** `-s` reads each file **serially** — all of one file's lines onto one output line — instead of
reading the files in parallel. With one file it turns a column into a row.

**39.** `12+7+31+4+19+2`.

**40.**
```
$ cut -d' ' -f3 logs/access-2187-06-10.log | sort -u | paste -sd,
bex,cass,maintenance,ops-bot,orla,rhea,vint
```

**41.** `-` means **standard input**. Listing it twice makes `paste` treat stdin as two inputs: it
takes one line for the first column, the next line for the second, and repeats. So a six-line file
becomes three rows of two.

**42.** Two rows of three: `12 7 31` / `4 19 2`.

**43.**
```
$ paste <(cut -f5 data/roster.tsv) <(cut -f2 data/roster.tsv)
role	name
systems	Rhea
medical	Cass
...
```

**44.** When the input is **not a file you can read twice**: the output of another pipeline, a stream
from the network, a named pipe, standard input, or a file too large to pass over twice. Process
substitution runs `cut` on the file twice; a pipeline has one shot at its input.

## Combining

**45.** `uniq -c` output is fixed width — the count is right-aligned in seven characters, then a
space, then the value — so `-c` is legitimate here:
```
$ cut -d' ' -f3 logs/access-2187-06-10.log | sort | uniq -c | sort -rn > scratch/counts.txt
$ paste <(cut -c9- scratch/counts.txt) <(cut -c1-7 scratch/counts.txt)
ops-bot	    412
rhea	     96
cass	     54
vint	     21
orla	     12
bex	      4
maintenance	      1
```
The count keeps its leading padding, and there is nothing in this lesson that can strip it. `tr -s`
is the next lesson; `sed 's/^ *//'` is two after that. Note that this relies on `uniq -c`'s field
being seven wide, which holds up to 9999999 — a formatting detail of another program, which is
exactly the sort of thing exercise 37 in lesson 01 warned you about relying on.

**46.**
```
$ { head -1 data/roster.tsv | cut -f2,5
    tail -n +2 data/roster.tsv | cut -f2,5 | sort -t$'\t' -k2,2; }
name	role
Ops-Bot	automation
Vint	cargo
Orla	comms
Maintenance, Deck	facilities
Bex	galley
Cass	medical
Rhea	systems
```
The header has to be removed before the sort and put back afterwards, because `sort` has no idea a
header exists — it would sort `name` in among the values. Splitting with `head -1` and `tail -n +2`
reads the file twice; `awk 'NR==1{print;next}{...}'` does it in one pass, in lesson 05.

**47.** `column -t` aligned the columns with padded spaces for display. The station's note says to
leave it to the reader because alignment **destroys the delimiter structure**: once you have padded
with spaces, `cut -f` no longer works on your output and `cut -d' '` never did. Ship the tab-separated
file; let the person reading it pipe it through `column -t` if they want it pretty.

**48.** Both give `deck-01 deck-02 deck-03 deck-04` — four, and they agree.
```
cut -f3 data/roster.tsv | tail -n +2 | sort -u
cut -d' ' -f5 logs/access-2187-06-10.log | sort -u
```
They **should** agree if the roster is complete and the log only records real decks, and the fact
that they do is weak evidence for both. Had the log shown a fifth deck, that would be the interesting
result.

**49.** The honest answer is that you cannot tell with these tools, and finding that out is the
exercise. Naively:
```
$ { cut -d' ' -f3 logs/... | sort -u; cut -f2 data/roster.tsv | tail -n +2 | sort -u; } | sort | uniq -u
```
returns all **fourteen** names, because the log writes `rhea` and the roster writes `Rhea`. Fold the
case (`tr 'A-Z' 'a-z'`, lesson 03) and it collapses to two:
```
maintenance
maintenance, deck
```
which are the same entity written two ways. So the real answer is **zero accounts in the log are
absent from the roster** — but no command in this lesson tells you that, and a report built from the
naive version would have claimed fourteen. Two lists naming the same things differently is the normal
case, not the exception.

**50.** `sort | uniq -u` on a concatenation finds items that appear exactly once *across both lists*.
It needs each list to be **already deduplicated** (hence `sort -u` on each), and it cannot tell you
**which** list a unique item came from — the two directions of difference are mixed together in one
output. It also needs both lists to use identical spelling, which is what exercise 49 broke. `comm`,
in chapter 8, answers all three of those properly.

**51.**
```
$ cut -d' ' -f3 logs/access-2187-06-10.log | sort | uniq -c | sort -n | head -1
      1 maintenance
```
`sort -n` (ascending) plus `head -1`, rather than `sort -rn | tail -1`, because `tail` on a stream has
to reach the end and `head` can stop. On this file it makes no difference; on a large one it does.

**52.** Unspecified, at least:
- **What counts as an access.** Every log line? Only successful ones? Only writes?
- **What period.** One day, one shift, the week?
- **What "readable" means.** Sorted how, how many rows, with what column headings, in what file, and
  does the person want the whole tail or just the top ten?
- (A fourth, if you like: what to do about accounts with zero accesses — do they appear as 0 or not
  at all?)

Defensible answers: all lines, the day the log covers, ranked descending by count, tab separated with
a header, complete rather than truncated. Write down which you chose. **Keep this answer.**

## Stretch

**53.** `-b` counts bytes, `-c` counts characters; they diverge on multi-byte input:
```
$ printf 'café,x\n' | cut -b1-4   ->  caf?   (a broken half of é)
$ printf 'café,x\n' | cut -c1-4   ->  café
```
For a fixed-width **timestamp** either works and `-b` is marginally faster and cannot be surprised by
encoding. For a **name**, use `-c`, or better, use `-f` and stop cutting names by position at all.

**54.** Eight blank lines — one per input line, because every line has the delimiter and simply has no
ninth field. `-s` does not help: `-s` suppresses lines with **no delimiter**, and these all have four.
There is no `cut` flag for "warn me that the field I asked for does not exist". Asking for a field
past the end of the line is indistinguishable, in the output, from a field that is genuinely empty.

**55.** `paste <(cut -f5 f) <(cut -f2 f)` needs two full passes over the 40 GB file and, if the input
were a pipe rather than a file, would need to buffer one side entirely — which is where the missing
disk goes. `awk '{print $5, $2}'` is one pass, constant memory, no temporary file. The `paste` idiom
is fine for roster-sized files and wrong for log-sized ones.

**56.**
1. **A line with no delimiter is printed whole**, so a banner or a header lands in a column of data.
2. **`-c` on human-aligned text** slices the wrong characters and returns a fragment that reads like a
   value.
3. **A delimiter that occurs inside a value** splits one record into two columns and shifts everything
   to its right by one, on that row only.

(And a fourth from `paste`: two files of different lengths, or the same length but out of step, join
row by position and produce a full table of wrong pairings.)

---

## Authoring notes

- The access log here is **byte-identical** to lesson 01's (`c6c7f1b94c1fdbf2c9bb63b50a8b14bf`), on
  purpose: lesson 01 ends by failing to count its third column and lesson 02 opens by doing it. Do not
  regenerate it independently.
- Exercise 45 was drafted using `awk` to swap the columns, which this lesson does not have. Rebuilt
  around `cut -c` on `uniq -c`'s fixed-width output, which is measured (seven-wide, verified up to
  four digits) and makes a deliberate callback to lesson 01's exercise 37.
- Exercise 49's naive answer is **fourteen**, not zero, because the roster uses display names. That
  was found during measurement and the exercise was kept as-is, with the wrong-looking answer as the
  point. It also forward-references `tr` and `comm` honestly.
- The count-of-one account in this lab is `maintenance`, an account that plainly exists in the roster.
  Nothing here should read as the chapter's incident.
