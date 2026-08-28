# 07/01 — Solutions

Every number below was measured in the container.

## Counting

**1.** `600 3000 24189 logs/access-2187-06-10.log` — **lines, words, bytes**, then the name.

**2.** 24189 / 600 ≈ **40 bytes per line**. Every line has the same five fields and nearly the same
width, which is why the average is worth anything at all here and usually is not.

**3.**
```
  600 logs/access-2187-06-10.log
  563 logs/access-2187-06-11.log
 1163 total
```
The last line is a **total**, not a file. Anything that consumes `wc -l file...` output and assumes
one line per file breaks the moment a second file appears.

**4.** `wc -l` says **2**. `cat` shows **three** lines of text. `cat` is right about the text; `wc` is
right about the file.

**5.** `wc -l` counts newline **bytes**, and the third line does not end with one. `wc -c` says 49,
and `tail -c 1 … | od -c` shows the last byte is `e` — the final `d` of "newline" is not there
because the text ends `...no newline` with no terminator. A file whose last line is unterminated is
reported one line short by every tool that counts newlines, and none of them mention it.

**6.** `wc -l logs/access-2187-06-10.log` prints `600 logs/access-2187-06-10.log`;
`wc -l < logs/access-2187-06-10.log` prints `600`. Given a filename `wc` echoes it; given stdin it has
no name to echo. The second form is what you want inside `$(...)`, because the first gives you a
count with a filename glued to it.

**7.** `wc -L logs/wide.log` → **257**: the length of the longest line, **not** counting the newline.
`awk '{print length}'` on the same file gives 5, 257, 10.

**8.** Both **275**. They differ only for multi-byte characters — an accented letter or an emoji
counts 1 for `-m` and 2, 3 or 4 for `-c`. This file is pure ASCII, so they agree.

**9.** `0 0 0` and the filename. All three, including bytes.

**10.** `wc -w notes/reporting.txt` → **117** words, `wc -l` → 15 lines. For "how long is that note"
quote the **lines** — it is the number that matches what the reader will scroll past. Words are for
prose length, bytes are for storage.

## sort: order

**11.** `10 100 1000 11 2 21 3 9`. Text comparison: `1` beats `2` at the first character and the
comparison stops there.

**12.** `2 3 9 10 11 21 100 1000`. **The default compares text; `-n` compares numeric value.**

**13.** `sort` → `1.5G 1K 2M 3K 512 900`; `sort -h` → `512 900 1K 3K 2M 1.5G`. `-h` reads the K/M/G
suffix as a multiplier and compares the scaled value.

**14.** `1K 1.5G 2M 3K 512 900`. `-n` parses a **leading** number and ignores the rest of the field,
so `1K` is 1, `1.5G` is 1.5, `2M` is 2, `3K` is 3, then 512 and 900. Not an error: `sort -n` is
documented to parse a numeric prefix, and a value it cannot parse at all sorts as zero. This is the
single most common way a "sorted by size" report is quietly wrong.

**15.** `sort` → `v1.1 v1.10 v1.2 v1.21 v1.9 v2.0`; `sort -V` → `v1.1 v1.2 v1.9 v1.10 v1.21 v2.0`.
`v1.10` moved below `v1.2` and `v1.9`; `v1.21` moved below `v1.9`.

**16.** Unchanged order out, because every line starts with `v` and `-n` finds no leading digit in any
of them, so all keys are 0 and the last-resort whole-line comparison decides. A total tie is
indistinguishable from a sort that worked.

**17.** `DECK-02` first. Comparison is by byte value in this locale (`LANG=C.UTF-8`), and `D` (0x44)
is below `d` (0x64), so every capitalised entry sorts above every lowercase one. `LC_COLLATE` — in
practice `LC_ALL` or `LANG` — is what decides.

**18.** `-f` folds case for the **comparison**, so `DECK-02` sits next to `deck-02`. Nothing is
merged: `-f` changes ordering only. Both lines are still printed.

**19.** `sort -u` → 6 lines (`DECK-02 Deck-03 deck-01 deck-02 deck-03 deck-04`) because `DECK-02` and
`deck-02` are not equal. `sort -fu` → 4 lines (`deck-01 deck-02 deck-03 deck-04`) because with case
folded they are equal, and `-u` keeps the first of each equal run.

**20.**
```
sort     -20, 12, 5, -3, -3, 0, 7    (with their leading blanks)
sort -n  -20, -3, -3, 0, 5, 7, 12
sort -b  -20, -3, -3, 0, 12, 5, 7
```
Plain `sort` compares the whole line including leading blanks, so the indented lines sort first as a
block. `-n` compares numeric value and skips blanks as part of parsing. `-b` ignores leading blanks
but still compares **text**, so `12` still precedes `5`.

## sort: fields

**21.** `-k2` and `-k2,2` differ on the three `deck-03` lines: `-k2` gives `rhea(day) bex maintenance`,
`-k2,2` gives `bex maintenance rhea`.

**22.** `-k2` means the key runs from field 2 **to the end of the line** — the man page calls it
`-k KEYDEF` with `POS1[,POS2]` and says "the key extends to the end of the line" when POS2 is
omitted. So `-k2` is really "deck, then shift, then anything after", and `day` beat `night` for
`rhea`. `-k2,2` compares the deck alone, and the tie falls to the last-resort comparison.

**23.** It compares **the entire line** as a last resort. In `data/ties.txt` the `3 ...` lines are
written `charlie, alpha, bravo` and come out `3 alpha, 3 bravo, 3 charlie` — an order that exists
nowhere in the input and comes entirely from the tie-break.

**24.** `3 charlie, 3 alpha, 3 bravo` — **input order**. `-s` disables the last-resort whole-line
comparison, so equal keys keep the order they arrived in.

**25.**
```
sort -k2,2r data/ties.txt | sort -s -k1,1
1 echo | 1 delta | 2 foxtrot | 2 bravo | 3 charlie | 3 bravo | 3 alpha
```
The **secondary** pass runs first. Sort by the key you want *inside* the groups, then stably sort by
the key that forms the groups. The stable pass preserves what the first pass did.

**26.** `rhea` and `bex` swap. Without `-t`, fields are split on runs of blanks, so field 2 is
`strain` for both lines and the tie-break decides: `bex` first. With `-t$'\t'` field 2 is
`strain audit` and `strain review`, so `rhea` first. The file is tab separated and the space inside
the field is what makes the difference visible.

**27.** "Fields are separated by tabs; order by field 3 numerically, and break ties by field 1 as
text." Result: `bex, rhea` (1), `cass, orla` (2), `vint` (3).

**28.** `sort -t$'\t' -k3,3 -k1,1 data/duty.txt` → the three `day` accounts alphabetically
(`cass orla rhea`), then the four `night` ones (`bex maintenance ops-bot vint`). Explicit `,3` and
`,1` matter: without them the first key would swallow the rest of the line and the second key would
never be consulted.

**29.** `sort: data/sizes.txt:2: disorder: 10`, exit status **1**. It names the first line that is out
of order — line 2, `10`, because `10` sorts before `9` as text and the file starts `9, 10`.

**30.** `sort -cn` reports line **4**, `2`. The file is `9 10 100 2 21 3 1000 11`: numerically the
first three are ascending, and the first violation is `2` after `100`. Different comparison, different
first violation. `-c` is only as meaningful as the ordering you ask it about.

## uniq

**31.** You cannot get there. `sort -k3,3` groups the log by account correctly, but `uniq` compares
whole lines and every line differs in its timestamp. `uniq -f2` skips date and time — and then
compares account **plus action plus deck**, which splits each account into many groups. There is no
flag that says "compare only field 3". `-f` skips a prefix; `-w` truncates a suffix; neither can cut
a column out of the middle. What you need is a tool that extracts the column, and that is `cut`.

**32.** `alpha bravo alpha charlie bravo alpha delta` — nothing was collapsed, because no two
identical lines are adjacent in that file. Output is the input, and `uniq` did exactly what it
promises.

**33.** **4** — `alpha bravo charlie delta`.

**34.** `uniq -c data/accounts-week.txt | wc -l` → **171**. Sorted first → **8**. Eight is the number
of accounts.

**35.** 171 is the number of **runs** of identical adjacent lines in the shuffled file. It is a real
measurement of something real; it is just not the thing anybody asked for. A wrong answer from `uniq`
is usually a correct answer to the question "how many runs".

**36.** `sort` makes equal lines adjacent (without it `uniq` has nothing to work with); `uniq -c`
collapses each run and prefixes its length; `sort -rn` reorders those counted lines by count,
descending.

**37.** The order is identical, because `uniq -c` **right-aligns the count in a fixed-width field**
(`cat -A` shows `    148 ops-bot`, `     61 rhea` — padded to the same width). Equal-width numeric
strings compare the same textually as numerically, so `-r` got the right answer by accident. Strip
the padding with `sed 's/^ *//'` and the accident ends:
```
$ ... | sed 's/^ *//' | sort -r
9 orla / 61 rhea / 33 cass / 3 bex / 2 maintenance / 148 ops-bot / 14 vint / 1 sensor-cal
```
`-rn` on the stripped input is still correct. Write `-n` when you mean numeric; do not rely on
another tool's formatting to make text comparison behave.

**38.** `uniq -d` → `alpha bravo` ("which lines occurred more than once"). `uniq -u` → `charlie delta`
("which lines occurred exactly once"). Disjoint, and together they are the whole set.

**39.** `-D` prints **every copy** of every duplicated line: `alpha alpha alpha bravo bravo`. `-d`
prints one representative each. Use `-D` when you need to see the duplicates in context — for example
to check whether they really are identical or differ in something `uniq` was told to ignore.

**40.** No.
```
1 DECK-02 | 1 Deck-03 | 2 deck-01 | 1 deck-02 | 2 deck-03 | 1 deck-04
```
`uniq -i` compares case-insensitively, but the input was sorted **case-sensitively**, so `DECK-02` and
`deck-02` are not adjacent and `uniq` never gets to compare them. Every flag on `uniq` is subject to
the adjacency rule; none of them repair the sort.

**41.** `sort -f data/decks.txt | uniq -ci` →
```
2 deck-01 | 2 DECK-02 | 3 Deck-03 | 1 deck-04
```
Both halves have to agree about what "equal" means. Note the representative printed is the first of
each run, so the report's casing is an accident of sort order.

**42.** `sort -k2 data/ties.txt | uniq -f1 -c` compares from field 2 onward — the word — and prints
the first line of each run with its count: `1 3 alpha | 2 2 bravo | 1 3 charlie | 1 1 delta |
1 1 echo | 1 2 foxtrot`. The `2 2 bravo` group is the two lines `2 bravo` and `3 bravo`, which are
equal on the word and differ in the number `uniq` was told to skip. The printed representative keeps
a field the comparison ignored, which is a good way to mislead a reader.

## Combining

**43.** `sort -u data/accounts-week.txt | wc -l` or `sort data/accounts-week.txt | uniq | wc -l` —
both **8**.

**44.** Exactly once: `sensor-cal`. More than twice: `bex cass ops-bot orla rhea vint` (everything
except `sensor-cal` at 1 and `maintenance` at 2).

**45.**
```
sort data/accounts-week.txt | uniq -c | sort -rn | head -3
sort data/accounts-week.txt | uniq -c | sort -rn | tail -3
```
`148 ops-bot / 61 rhea / 33 cass` and `3 bex / 2 maintenance / 1 sensor-cal`.

**46.** It answers "what is the **rarest** thing in this file" — `1 sensor-cal`. More interesting
because the top of a frequency table is nearly always the thing that is supposed to be busy, and the
bottom is where the thing that happened once lives. Frequency tables are read top-down and the news
is at the other end.

**47.** `sort data/accounts-week.txt -o data/accounts-week.txt` works: `sort` reads the whole input
before it opens the output. `sort file > file` does not — the shell truncates `file` to zero bytes
when it sets up the redirection, **before `sort` ever runs**, so `sort` reads an empty file and you
lose the data. `-o` exists precisely because that redirection is a trap.

**48.** `wc -l data/*` — the line you want is `total`, unless you wanted them individually, in which
case it is every line except `total`. Being clear about which is the whole skill of reading `wc`
output in a script.

**49.** `[ "$(wc -l < logs/access-2187-06-10.log)" = "$(wc -l < logs/access-2187-06-11.log)" ]` — exit
status 1, they are not (600 versus 563). Note `wc -l <` and not `wc -l file`, or you would be
comparing counts with filenames attached.

**50.** `sort -k4,4 logs/access-2187-06-10.log | uniq -f3 -c | wc -l` → **598**, for a file with three
distinct actions. `-f3` skips date, time and account, then compares **everything remaining** — action
*and* deck — and the sort's last-resort whole-line comparison interleaves lines that share an action
but differ in deck, so almost nothing is adjacent. Same wall as exercise 31, met from the other side.
For the record the real answer is `read 300, write 150, exec 150`, and getting it needs `cut`.

## Stretch

**51.** `sort -R` does not shuffle lines; it sorts by a **random hash of the key**. Equal lines hash
equally, so all 148 `ops-bot` lines come out consecutively — `head -12` shows twelve identical lines.
It is a random *grouping* order, not a permutation. `shuf` is the tool that actually permutes.

**52.** No measurable difference on this station: the locale is already `C.UTF-8`, whose collation is
byte order. A difference appears under a locale with real collation rules (`en_US.UTF-8`), where every
comparison consults a collation table; on large inputs `LC_ALL=C sort` can be several times faster,
and it also changes the answer, which is the more important half.

**53.**
```
sort -m <(sort logs/access-2187-06-10.log) <(sort logs/access-2187-06-11.log) | sort -c   # rc 0
```
`-m` assumes its inputs are already sorted and merges them, which is linear in the total size and
needs no temporary files. Plain `sort a b` re-sorts everything from scratch. `-m` on unsorted input
produces unsorted output and does not warn.

**54.** `sort data/accounts-week.txt | uniq -u | wc -l` → **1**.

**55.** `sort data/decks.txt | uniq -w4` → `DECK-02 Deck-03 deck-01`: `-w4` compares only the first
four characters, so every `deck-NN` collapses into one group per capitalisation and the deck number is
discarded. Useless here because the distinguishing part of the line is past character 4. `-w` is right
when the leading fixed-width part **is** the identity — a log of `2187-06-10 03:14:22 ...` lines
collapsed with `-w10` gives you one line per day.

**56.** Two reasons, both visible in this lab: the top entry is usually a machine account or a routine
job whose high count is exactly what you would predict, so it carries no information; and a count of
one cannot be explained by "it runs all the time" — something that happened exactly once had a reason
that happened exactly once. The tail is also where a ranking's readers stop looking, which is a
property of the reader, not of the data.

---

## Authoring notes

- **Exercise 37 was drafted wrong** and the measurement pass caught it. The draft asserted `sort -r`
  would misorder counts above 99. It does not, because `uniq -c` right-aligns its counts, so text and
  numeric order coincide. The exercise now walks the student through `cat -A`, the accident, and the
  `sed 's/^ *//'` case that breaks it. Do not "restore" the simpler claim.
- **Exercise 50 was drafted wrong** too: the draft claimed `uniq -f3 -c` would produce an action
  table. It produces 598 groups. Rebuilt around the measured number.
- The generator was changed after a first seeding: `deck` had been derived from the same counter as
  `action`, making deck a function of action, and timestamps repeated so the log contained identical
  records. Both were artefacts a student could notice and neither is true of a real access log.
- `sensor-cal` is the count-of-one here, **not** `eng-svc`. The chapter's incident owns that name and
  this lesson must not spend it.
