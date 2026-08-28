# 07/05 — Solutions: `awk` fields

All output measured in the lab against GNU Awk 5.4.1. `L=logs/access-2187-06-10.log`.

## Fields

**1.** `awk '{print $3}' $L`. Lesson 04's version was
`sed -n 's/^[^ ]* [^ ]* \([^ ]*\) .*/\1/p'` — it counts separators by hand, breaks if a field width
changes, and has to be re-read every time. `awk` names the field. This is the argument for the whole
lesson and it is best made by putting the two commands on adjacent lines.

**2.** `awk 'NR==1 {print $0; print $NF; print $(NF-1)}' $L` gives
`2187-06-10 00:00:00 ops-bot read deck-01`, then `deck-01`, then `read`. `$NF` is the last field
because `NF` is the field count and `$` takes an expression.

**3.** Every line reports `5`, and `sort -u` collapses that to a single line of output. One value
means **the file is regular**: every record has the same shape, so a positional command like
`cut -f3` is safe on it. On a file that answers `4` and `5` you have learned something before writing
anything else.

**4.** `600 5 2187-06-10 23:57:47 ops-bot exec deck-03`. `NR` is the total record count, `NF` and `$0`
are the **last record's**, because `END` runs after the last line and `awk` does not clear the
record buffer. That is a documented behaviour worth knowing: `END` can look at the final line.

**5.** Two empty lines (`$` under `cat -A`). A missing field is not an error; it is the empty string.
`awk` will happily print `$500`. This is a strength when you are parsing junk and a hazard when you
have miscounted, because nothing tells you.

**6.** `awk '$4=="exec" {print $3, $5}' $L` — first two lines `ops-bot deck-02`, `ops-bot deck-04`.

**7.** `ops-botdeck-01`. Two expressions with nothing between them is **concatenation** in `awk`. The
comma is what asks for a separator. This is the most common accidental output in the language.

## Ragged input

**8.** Garbage: `13 ops-bot`, `13` (an empty field), then a long tail of single timestamps. The
ragged file has runs of spaces, so `cut -d' ' -f3` lands on a different thing on every line, and
leading spaces push everything along by one or three.

**9.** `40 ops-bot`. One group, correct, no flags.

**10.** The default separator is **a run of whitespace** — any mixture of spaces and tabs, of any
length — and **leading and trailing whitespace is ignored** rather than producing empty fields. So
`$1` is the first non-blank thing on the line, whatever the indentation.

**11.** `2`, and `2 [a]`. Both confirm it.

**12.** It prints `2`, not `3`. `-F' '` is not "one space": a single space is the code that means
"use the default whitespace rule". This is a genuine wart and everybody meets it once.

**13.** `awk -F'[ ]' '{print NF}'` gives `3` (the middle field is empty). The smallest change is to
make the separator a one-character **regular expression** — a bracket expression is not a single
space and so does not trigger the special case.

## Separators

**14.** Row 7. Default whitespace splitting handles tabs fine for rows 1–6, but row 7's account is
`Maintenance, Deck`, which contains a space, so it splits into two fields and the row reports `5`
fields with `$1` as `Maintenance,`.

**15.** With `-F'\t'` row 7 reports `4` and `$1` is `Maintenance, Deck`. Nothing else changed — which
is the trap: a default-separator command works on this file for six rows out of seven and gives no
warning about the seventh.

**16.** `awk -F'\t' 'NF<4 {print NR": "$0}' data/roster.tsv` → row 5, `orla deck-02 day`. No role.

**17.** `awk -F'\t' 'NR==5 {print "["$4"]"; print "["$9"]"}'` prints `[]` twice. An unset field is the
empty string, and there is no difference between "field 4 is missing" and "field 9 was never going to
exist". `NF` is the only way to tell.

**18.** Row 7 reports `5` fields. The quoted comma inside `"Maintenance, Deck"` is a separator as far
as `awk` is concerned; `$1` becomes `"Maintenance` and `$2` becomes ` Deck"`. Exactly the lesson-02
result, from a different tool.

**19.** For the tutor: *a CSV field may contain the separator if it is quoted, and `-F,` has no idea
what a quote is. `awk` splits on the character; the format says the character is sometimes data.* Use
a real CSV reader, or control the file's format yourself and use tabs.

**20.** They agree: `awk` reports `3` fields with `$2` empty, and `cut -d, -f2` emits an empty line.
Neither collapses empty fields — that is a whitespace-only behaviour, which is why it surprises people
who learned it from `awk`'s default and expected it everywhere.

**21.** `3 b`. A `-F` argument is a **regular expression** (any `-F` longer than one character, and
some of length one). `[0-9]+` splits `a1b22c` into `a`, `b`, `c`.

**22.** `awk -F'\t' 'NR>1 {print $1}' data/roster.tsv`. `NR>1` is the header-skipping pattern and you
will write it constantly. `FNR>1` is the version that works with several files.

## Conditions

**23.** `awk '$3=="rhea"' $L | wc -l` → 96. Better: `awk '$3=="rhea" {n++} END {print n}'` → 96, no
pipe.

**24.** `awk '$3=="rhea" && $4=="exec"' $L | wc -l` → 24.

**25.** Both 150. `awk '$5 ~ /04/'` is safer: `/deck-04/` matches the pattern **anywhere on the
line**, so it would also fire on an account named `deck-04-relay` or a note field mentioning it.
Anchoring a match to a named field is the point of having fields.

**26.** `awk '$4==0 {print $1, $2}' data/readings.txt` → `deck-01 panel-c`. Zero amps: the panel is
drawing nothing at all, which is either switched out or dead.

**27.** `awk '$3 < 20' data/readings.txt` → `deck-03 panel-b 12.4 9.8`. Half the voltage and three
times the current of its neighbours — the classic shape of a short, and the highest watts in the
file. Nothing else in the column is close.

**28.** `awk 'NR<=3 {print $3, ($4=="read" ? "R" : "-")}' $L` → `ops-bot R`, `ops-bot R`, `ops-bot -`.

**29.** `awk 'NF'` gives 8 lines; the file has 11. `NF` is a **pattern** — a number, true when
non-zero — and the default action prints the record. Blank lines have `NF` of 0, so they are false and
never print. It is the shortest blank-line filter there is.

## Arithmetic and END

**30.** `awk '{s += $3*$4} END {printf "%.2f\n", s}' data/readings.txt` → `618.36`.

**31.** `awk '{s+=$3; n++} END {print s/n, n}' data/readings.txt` → `22.82 10`. Note `n++` rather than
using `NR`; both work here, and `NR` would be wrong the moment you added a condition.

**32.** `awk '$4 > m {m=$4; line=$0} END {print m, line}' data/readings.txt` →
`9.8 deck-03 panel-b 12.4 9.8`. `m` starts empty, which is 0 in a numeric comparison, so the first row
always wins the first round. That works here because no value is negative; with negative data you
initialise in `BEGIN` or on `NR==1`.

**33.** `awk '{w[$1] += $3*$4} END {for (k in w) printf "%s %.1f\n", k, w[k]}' data/readings.txt |
sort` → `deck-01 148.5`, `deck-02 187.6`, `deck-03 222.5`, `deck-04 59.7`.

**34.** In the main block you get a **running** total printed once per line — the last two lines of
`awk '{s+=$3*$4; print s}'` are `584.76` and `618.36`. Only the final line is the answer, and the rest
is noise. `END` is the only place that has seen everything.

**35.** `0.333333` then `0.3333`. `print` formats numbers with `OFMT`, which is `%.6g` by default;
`printf` uses exactly the format you gave. If a report's decimals matter, use `printf`.

**36.** `3.5 3 1`. `awk` division is **floating point**; `int()` truncates and `%` is the remainder.
Anyone arriving from C or from shell arithmetic expects `7/2` to be 3 and is wrong.

**37.** `awk '{s+=$2} END {print s}' data/mixed.txt` → `65` (12+24+24+5). Not a bug in `awk`: it reads
a leading number out of a string and ignores the trailing `V`. Whether it is a bug in *your report*
depends on whether you meant it.

**38.** `awk '{s+=$3} END {print s}' data/roster.tsv` → `0`. Column 3 is `shift`, all words, all worth
zero. Nothing warned. In a real report you notice because you sanity-check totals against something
you already know — a count, a previous week, an order of magnitude — and because a total of exactly
`0` from 600 lines of input is never right.

## The counting idiom

**39.** `awk '{c[$3]++} END {for (k in c) print c[k], k}' $L` gives the same seven pairs: 412 ops-bot,
96 rhea, 54 cass, 21 vint, 12 orla, 4 bex, 1 maintenance. One pass, no sorting of 600 lines.

**40.** Not guaranteed. `for (k in c)` visits keys in an unspecified order — GNU Awk's happens to be
stable within a run but the language promises nothing and other awks differ. In the
`sort | uniq -c | sort -rn` version the order comes from `sort`, explicitly, which is why that
pipeline is reproducible by construction.

**41.** `… | sort -rn`.

**42.** `awk '{c[$4" "$5]++} END {for (k in c) print c[k], k}' $L | sort -rn | head -4` →
`100 read deck-03`, `100 read deck-01`, `50 write deck-04`, `50 write deck-02`. A composite key is
just string concatenation; there is nothing else to learn.

**43.** `awk '{h[substr($2,1,2)]++} END {for (k in h) print k, h[k]}' $L | sort` and
`awk '{split($2,t,":"); h[t[1]]++} …` give identical results (`00 26`, `01 26`, `02 25`, …).
`substr` is shorter; `split` survives a change to the timestamp's width.

**44.** `awk '{c[$3]++; t++} END {for (k in c) printf "%-12s %4d %5.1f%%\n", k, c[k], 100*c[k]/t}' $L
| sort -k2,2rn`:

```
ops-bot       412  68.7%
rhea           96  16.0%
cass           54   9.0%
vint           21   3.5%
orla           12   2.0%
bex             4   0.7%
maintenance     1   0.2%
```

**45.** The header sorts into the output, and with `sort -k2,2rn` it lands at the **bottom**. The
lesson: a header is data as far as the next command is concerned. Either print the header after
sorting (`awk … | sort … | sed '1i account count'`, or a `printf` before the pipeline) or do not
print one until the last step.

**46.** `awk -v who=rhea '$3==who {n++} END {print n}' $L` → 96. `-v` keeps the shell's quoting out of
the `awk` program: with interpolation you would be writing `'$3=="'"$WHO"'"'`, which breaks on a name
containing a quote and is unreadable long before that.

**47.** `… | sort -n | head -3` → `1 maintenance`, `4 bex`, `12 orla`. The bottom of a frequency table
is where a single, deliberate, one-off action shows up. Everyone reads the top. Remember this.

## Output

**48.** A **space**, from `OFS`, whose default is a single space. The comma in `print $2, $1` asks for
`OFS`; the input separator has nothing to do with the output.

**49.** `BEGIN{OFS="\t"}` with commas gives tabs. With `print` and no commas nothing changes, because
`print` with no arguments prints `$0` — the original record, exactly as read. `OFS` is only consulted
when `awk` builds output from fields.

**50.** `awk -F'\t' 'BEGIN{OFS="\t"} {$1=$1; print}'` rebuilds `$0` from the fields using `OFS`.
Assigning to **any** field forces the rebuild; `$1=$1` is the cheapest assignment that changes
nothing. It is the standard idiom for "re-join this record with a different separator", and on the
roster it also normalises the runs of whitespace if there were any.

**51.** `printf "%-12s %4d\n"` → `ops-bot       412` and `maintenance     1`; the counts line up
because `%4d` right-aligns in a fixed width, and the names line up because `%-12s` is wider than
`maintenance`. If a name were thirteen characters, `printf` would not truncate — it would push the
column, which is why report widths get chosen from the data.

**52.** `awk '$3=="rhea" {print > "scratch/rhea.txt"}' $L`; `wc -l` → 96. Use it when one pass has to
produce **several** files — `print > ("scratch/" $3 ".txt")` splits the log by account in one read,
and a shell redirect cannot do that without re-reading the file once per account.

**53.** `00:00 7 OPS-BOT`. `substr($2,1,5)` takes five characters from position 1 (`awk` strings are
1-indexed, unlike almost everything else you will use); `length($3)` is the field's character count;
`toupper` is the case fold from lesson 03 without leaving `awk`.

## Judgement

**54.** `awk '{print $3}' $L | sort | uniq -c | sort -rn` versus
`awk '{c[$3]++} END {for (k in c) print c[k], k}' $L | sort -rn`. At 600 lines both are ~3 ms and
`time` mostly measures process startup — the difference is not measurable and not worth caring about.
At six million lines it matters a great deal: the first sorts six million records, the second sorts
seven. Do not optimise the 600-line case; do know which one scales.

**55.** Several defensible answers. The best: **plain text substitution across a file** — `awk` can do
it with `gsub`, but `sed 's/…/…/g'` is shorter, more readable and what a colleague expects. Also
acceptable: counting characters or bytes (`wc`), deleting characters (`tr`), and finding files
(`find`). "Use the smallest tool that says what you mean."

**56.** `4`. With only a `BEGIN` block and no main block, `awk` never reads input, so it is a
calculator — a genuinely useful one, because it does floating point that the shell's `$(( ))` cannot.
Without `</dev/null` and with only `BEGIN`, GNU Awk still exits immediately; add a main block and it
will sit waiting on the terminal, which is worth knowing before it happens to you.

**57.** `awk '{c[$3]++} END {for (k in c) printf "%s\t%d\n", k, c[k]}' $L | sort -k2,2rn` gives
`ops-bot<TAB>412` down to `maintenance<TAB>1` — the same bytes as lesson 04 exercise 56, from the raw
log instead of a pre-counted file. In a script, this one: it has one dependency (the log) instead of
two (the log and whatever produced `counts.txt`).

**58.** Everything addressed by field number breaks — `$3` is now the wrong column in every command
above, and so is every `cut -f3`. What survives: commands that use `$NF` or `$(NF-1)`, and anything
keyed to a pattern rather than a position (`$0 ~ /rhea/`). What survives *silently* is the danger: a
`cut -f3` on a shifted file returns plausible wrong answers rather than an error, and exercise 3's
`NF` check is how you catch it before that happens.

## Stretch

**59.** `awk '{ if (!($3 in f)) f[$3]=$2; l[$3]=$2 } END { for (k in f) print k, f[k], l[k] }' $L |
sort`:

```
bex 22:26:35 22:40:38
cass 15:39:08 19:47:21
maintenance 22:45:19 22:45:19
ops-bot 00:00:00 23:57:47
orla 21:30:23 22:21:54
rhea 08:09:32 15:34:27
vint 19:52:02 21:25:42
```

`in` tests for a key without creating it — writing `if (f[$3] == "")` would create every key as a side
effect, which matters when you later count them. Note `maintenance`: first and last are the same
timestamp, because it appears once. An account whose whole history is one instant is a shape you will
see again.

**60.** `data/short.txt 1`, `data/mixed.txt 1`. `NR` counts records across **all** input files;
`FNR` restarts at 1 for each file. It matters for header skipping (`FNR>1`) and for anything that
reports a line number the user could look up.

**61.** `awk '{w[$1] += $3*$4} END {for (k in w) if (w[k] > m) {m = w[k]; d = k} print d, m}'
data/readings.txt` → `deck-03 222.52`. The loop-and-compare is the `END`-block version of exercise 32.

**62.** It replaces `wc -L`, and it reports `44`. Trust `wc -L` for the answer and this for the
flexibility: `awk` can tell you *which* line, or the length of a field rather than a record, and
`wc -L` cannot. Note both count characters, not display columns, and neither is right about a
double-width glyph.

## Authoring notes

- `data/ragged.txt` is generated **from** the access log by an `awk` in `setup.sh`, so the records are
  the same records and the only variable is the whitespace. Exercise 8 versus 9 is therefore a clean
  comparison and not two different files.
- `data/roster.tsv` carries two defects on purpose: `orla` is short a field (so `NF` has something to
  find) and `Maintenance, Deck` contains a space (so the default separator is wrong on exactly one of
  seven rows). Exercise 15's real content is "it worked on six rows and said nothing".
- `-F' '` reporting 2 rather than 3 (exercise 12) was verified; it is the special case in POSIX awk,
  not a GNU quirk.
- Exercise 59 is a deliberate rehearsal for chapter 7's incident: an account with one record has a
  first timestamp equal to its last, and it lives at the bottom of every table sorted by count. The
  incident asks the student to look there. Do not spoil it in the tutor session.
- `for (k in c)` order was stable across runs here. The solution still says it is unguaranteed,
  because it is, and a student who learns to trust it will be wrong on another machine.
