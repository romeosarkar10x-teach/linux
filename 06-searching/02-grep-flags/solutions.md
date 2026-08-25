# 06/02 — Solutions: `grep` Flags

All numbers measured in the container (GNU grep 3.12). Students must not read this file.
`D9=reports/deck-03-2187-06-09.log`, `D8=reports/deck-03-2187-06-08.log`.

## What matches

**1.**
```
reports/deck-03-2187-06-08.log:2
reports/deck-03-2187-06-09.log:4
reports/deck-04-2187-06-09.log:0
reports/quiet.log:0
```
`deck-04` has none because thirty entries ran clean. `quiet.log` has none because it only has three
entries — a zero from a short file is a much weaker claim than a zero from a full one.

**2.** The archived copy spells it `fault`. `grep 'fault' archive/deck-03-2187-06-09.log` → 4 lines.
Somebody normalised the case when archiving, which silently breaks every case-sensitive search
written against the live format.

**3.** `grep -ci 'fault' archive/…` → **4**, matching the live report. `-i` is what makes the two
formats comparable.

**4.** `grep -c 'bay'` → **8** of 9 lines; `grep -cw 'bay'` → **5**. `-w` keeps `bay`, `bay-01`,
`bay.`, `the bay is clear`, `bay bay bay`. It removed `bays` (followed by a letter), `embayed`
(letters on both sides) and `subbay` (letters before). `BAY` was never in the 8 — that is case, not
`-w`.

**5.** The match must not be adjacent to a character in `[A-Za-z0-9_]` on either side. `-` and `.`
and space are not in that set, so `bay-01` and `bay.` qualify. It is the identifier rule, not the
English one.

**6.** Line 1, the bare `bay`. `-x` requires the pattern to consume the entire line. Anchoring at
both ends (`'^bay$'`, lesson 03) is equivalent here and generally — `-x` is the flag form of exactly
that, and is safer because it cannot be broken by a metacharacter in a pattern that came from
elsewhere.

**7.** `codes.txt`:
```
E-104          plain yes   -w yes   -x yes
E-1041         plain yes   -w no (digit follows)   -x no
xE-104         plain yes   -w no (letter precedes) -x no
E-104 confirmed plain yes  -w yes   -x no
E-104          plain yes   -w yes   -x yes
 E-104         plain yes   -w yes   -x no (leading space)
E-105          no
```
6 / 4 / 2.

**8.** The space-prefixed line is in the plain 6 and in the `-w` 4, and **not** in the `-x` 2. `-x`
means the whole line including whitespace; there is no trimming anywhere in `grep`.

**9.** `grep -cvx 'E-104' codes.txt` → **5**: the seven lines minus the two that are exactly the
code. You counted lines that are not exactly that code — including `E-104 confirmed`, which does
contain it.

## `-v`

**10.** `grep -vc 'ok' reports/deck-04-2187-06-09.log` → **3**. The three non-`ok` lines are the two
header lines and the `end of report` line, none of which are entries.

**11.** Search for the shape of an entry rather than the absence of `ok`:
`grep -c 'entry' reports/deck-04-…` → 30, and `grep 'entry' … | grep -vc 'ok'` → **0**. Restricting
to the record type first, then inverting, is the general fix.

**12.** Every one of those files has at least one line without `FAULT` in it, and `-l` asks "does
this file have a matching line" — with `-v` the matching lines are the non-fault ones.

**13.** `-L`. `-L` is a property of the file ("no line matched"); `-lv` is a property of one line
("some line failed to match"). They are almost never the same question.

**14.** `grep -L 'FAULT' reports/*.log` → `deck-04-2187-06-09.log` and `quiet.log`. Misleading in
exactly the way exercise 1 warned: the flag reports absence of the marker, not absence of faults, and
`quiet.log` is three entries long.

**15.** `grep -Li 'fault' reports/*.log` → the same two. Against `archive/`:
`grep -Li 'fault' archive/*.log` → `quiet.log` only, because `-i` now catches the lower-case archive
spelling. Without `-i` you would wrongly get `deck-03-2187-06-09.log` as well.

## What you see

**16.** `grep -n 'FAULT' $D9` → lines **9, 12, 15, 30**.

**17.** Entry numbers are 007, 008, 009, 022. Line numbers run ahead because the two header lines
push everything down by 2, and each fault adds two detail lines. At entry 022 the gap is 30 − 22 =
**8**: 2 header lines + 3 faults × 2 detail lines.

**18.** The **entry number**. Line numbers renumber themselves silently when a line is removed; a
record that carries its own number leaves a hole you can see. That is why the reports are numbered,
and it is the point the whole chapter is building towards.

**19.** `-c` → **9**: nine *lines* contain the string `0.4`. `-o …| wc -l` → **40**: forty
*matches* of a two-decimal reading, two per data row across twenty rows. `-c` answers "how many
records mention this"; `-o | wc -l` answers "how many times does this appear".

**20.** Any pattern that cannot match twice on one line, e.g. `grep -c '^deck'` / `grep -o '^0[0-9]'
readings.csv | wc -l` → 20 both, or anchor to the first field. Accept anything where the student
argues at-most-one-match-per-line.

**21.** `printf 'aaaa\n' > scratch/a; grep -o 'aa' scratch/a | wc -l` → **2**. `grep` resumes
scanning after the end of the previous match, so matches never overlap; positions 1–2 and 3–4 are
found, 2–3 is not.

**22.** `grep -o 'bay-[0-9][0-9]' readings.csv | wc -l` → **20** occurrences. `grep` cannot do
"distinct" because it has no memory between lines — it makes an independent decision per line and
never compares two of them. `sort -u` (Chapter 7) is the missing tool.

## Context

**23.** 13 lines. **24.** The extra line is `--`, GNU grep's separator between non-adjacent context
blocks. It is on stdout, it is not in the file, and it will end up in your pipeline if you do not
strip it.

**25.** 12: the separator does not contain `entry`. So the count "12" *is* recoverable — but only by
filtering out something `grep` itself inserted.

**26.** Entries 007, 008, 009 are contiguous once their two detail lines each are counted, so their
`-A2` blocks touch and are printed as **one** block with no separator. Only the jump to entry 022
produces a `--`. One separator for four matches is the tell.

**27.** `-B1`: 4 matches × 2 lines = 8, minus overlaps. The blocks for 008 and 009 each begin inside
the previous block, so 3 lines are shared, giving 8 − 3 + separators. Measured: **11** (10 file lines
plus 1 separator). `-C1`: **13**. The reliable method is to run it with `-n` and read the line
numbers, which is also the honest answer to give.

**28.** It cannot: `-C1` prints a subset of the union of what `-A1` and `-B1` print (they overlap on
the matched lines themselves, which both include). A student who says "it can, because of separator
lines" should be asked to build it — separators are added when blocks are *further* apart, and
splitting a run into more blocks is exactly what `-C` avoids.

**29.** **4**. `-c` counts matching lines and ignores context entirely; `grep` decides what matches
first and formats afterwards, and `-c` short-circuits the formatting stage. This is why `-c` with
`-o` also gives lines, not matches (exercise 45).

**30.** `grep -n -C2 'entry 022' $D9`, or `grep -A2 'FAULT' $D9 | grep -A2 '022'`. Narrowing the
pattern is better than filtering the output, and the student should say so.

## Where it looks

**31.** `grep -rl 'FAULT' .` → `./archive/.cache/index.tmp`, `./archive/.cache/scan.tmp`,
`./archive/deck-03-2187-06-08.log`, `./reports/deck-03-2187-06-08.log`,
`./reports/deck-03-2187-06-09.log`, `./reports/notes.txt`. The two non-reports are the `.cache` junk
(which contains the bare word) and `notes.txt` (which *describes* the format: "A FAULT line is always
followed by…").

**32.** Not a false positive. `grep` returned exactly what was asked for. It is a *specification*
error: "find fault lines" and "find the string FAULT" are different requests, and only the second one
was made.

**33.** `--include='*.log'` → `./archive/deck-03-2187-06-08.log`, `./reports/deck-03-2187-06-08.log`,
`./reports/deck-03-2187-06-09.log`. It correctly dropped `notes.txt` and the two `.tmp` files; it
kept the archive copy, which is probably not wanted.

**34.** `--exclude-dir=.cache` → the three above plus `./reports/notes.txt`. `--include` filters by
filename and knows nothing about location; `--exclude-dir` filters by location and knows nothing
about filenames. "Which kinds of file" and "which parts of the tree" are separate questions, and most
real searches need both.

**35.** `grep -rl --include='*.log' 'FAULT' reports/` — the cheapest answer is to point `-r` at the
right directory rather than to exclude the wrong ones. Also correct:
`grep -rl --include='*.log' --exclude-dir=archive 'FAULT' .`.

**36.** With no path, `-r` searches `.`. From a home directory that is every dotfile, every cache,
every checked-out repository and every mail spool — minutes of I/O and thousands of lines, most of
them binary notices.

**37.** Fifteen lines, one per file in the tree, with zeros for `archive/index.txt`,
`archive/quiet.log`, `codes.txt`, `readings.csv`, `reports/deck-04-…`, `reports/quiet.log`,
`words.txt`. The zeros are the evidence that those files were read and found clean — `-l` cannot
distinguish "searched, no match" from "never searched".

**38.** Build a deep tree (`mkdir -p scratch/t/{1..50}/{1..50}`) with a file in each leaf, then time
`--exclude='*'` against `--exclude-dir` on the top directory. You cannot show it here because this
lab is 15 files and the whole walk is inside one disk read; the difference is a property of tree
size, not of the flags.

## Combining

**39.** `grep -rc --include='*.log' 'FAULT' reports/ | grep -v ':0$'` →
```
reports/deck-03-2187-06-09.log:4
reports/deck-03-2187-06-08.log:2
```
**40.** Same pipeline plus a filter on the number — `awk -F: '$2 > 2'`, or `grep -v ':[012]$'` if
they are staying inside the chapter. The "more than two" is arithmetic, and `grep` does not do
arithmetic; it compares text.

**41.** `grep -n -A1 'FAULT' $D8`. `-n` numbers context lines too, with a `-` separator instead of a
`:` — that difference is worth pointing out. Order of flags does not matter.

**42.** `grep -w 'bay' words.txt | grep -vx 'bay'` → four lines. One `grep` cannot do it: `-x` and
`-w` are both requirements on the same match, and there is no per-flag negation — `-v` inverts the
whole decision, not one flag of it.

**43.** **7**, not 5. Five *lines* match `-w bay`, but `bay bay bay` contributes three matches and
`the bay is clear` one, so `-o` counts occurrences: 1+1+1+1+3 = 7. Same lesson as exercise 19.

**44.** `grep -l 'FAULT' reports/*.log` and `grep -l 'cleared' reports/*.log`, then intersect by eye
— both give the two deck-03 reports. The cost is that you read every file twice and the intersection
is done by a human; `comm` on two sorted lists (Chapter 7) is the real answer.

## Experiment

**45.** `grep -oc '0\.[0-9][0-9]' readings.csv` → **20**, not 40. `-c` wins: it counts lines and `-o`
is ignored. If you want matches you must count them yourself with `wc -l`.

**46.** `man grep`, `-l`: "Stop reading a file after the first matching line." That settles it,
and it is also why `-l` on a huge log is nearly free while `-c` on the same file is not.

**47.** `-A0` is accepted and behaves like no context: `grep -A0 -c 'FAULT' $D9` → 4, and the output
is the matching lines alone. A negative number is an error:
```
grep: -1: invalid context length argument
```
status 2.

**48.** The pattern is the empty string; `-x` makes it "the line is empty"; `-v` inverts that to "the
line is not empty". `grep -vx '' reports/quiet.log | wc -l` → **6**, the whole file, since it has no
blank lines. `grep -cx '' reports/quiet.log` → 0. This is the useful idiom for stripping blank lines
without `sed`.

**49.** `grep -ciw 'BAY' words.txt` → **6**: the five `-w` lines from exercise 4 plus the bare `BAY`
line that case-sensitivity had excluded.

**50.** No error. **The last one wins.** `grep -l -L 'FAULT' reports/*.log` prints the two files with
no fault (`-L` last), and `grep -L -l 'FAULT' reports/*.log` prints the two with faults (`-l` last).
Both exit 0. A flag pair that silently picks a winner is worse than an error, and this is a real
source of bugs in generated command lines.

## Stretch

**51.** `grep -c 'FAULT' reports/*.log` → 4 lines; `grep -rc 'FAULT' reports/` → **5**. The extra is
`reports/notes.txt`: the glob only expanded `*.log`, while `-r` reads everything in the directory
regardless of name.

**52.** `grep -riw 'fault' .` — `-w` prevents `default` from matching because `t` is a word character
adjacent to the match. Test: `printf 'default settings\n' > scratch/d; grep -riw 'fault' scratch/d`
→ nothing.

**53.** Live reports: 2 + 4 = **6** fault lines over the two days. It may be wrong because
`archive/` holds copies of the same two reports, so a tree-wide count double-counts, and because a
fault line is not a fault — entry 007 appears on both days and may be one continuing problem
reported twice. The command is right; the noun is ambiguous.

**54.** Use `reports/deck-03-2187-06-09.log`. `grep -L 'FAULT'` does not list it, because it has
fault lines. `grep -lv 'FAULT'` does list it, because it has non-fault lines — thirty-odd of them.
`-L` asks about the file; `-lv` asks about a line.

## Dig

**55.** Easy half: `grep -A2 -n 'FAULT' $D9` shows two `detail` lines after each fault in deck-03 —
verifiable by reading. Hard half: deck-04 has *no* fault lines at all, so "a fault is followed by
nothing" is vacuously true there and `grep` can produce no evidence either way. To be certain you
would need a deck-04 report that actually contains a fault. A student who says "the second half is
unverifiable with this data" has the answer; a student who says "confirmed" does not.

**56.** `grep -C2 'entry 007' reports/deck-03-2187-06-0[89].log` shows both, with the same bay
(bay-08) and the same peak (`peak 0.77 held 21s`). That is consistent with one unresolved problem
recurring, and consistent with two separate events, and consistent with the 06-09 report being
generated from stale data. Identical detail lines are evidence of a common source, not of a common
cause. The student must not name a person.

**57.** `grep -rx 'FAULT' .` → `./archive/.cache/index.tmp:FAULT`. One line, in a temp file that a
cache rebuild wrote. Those files are machine output — they hold the bare marker as a token, not as a
record — which is why they matched every search in this lesson and belonged in none of the answers.

## Authoring notes

- `mk_report` puts two `detail` lines after each deck-03 fault; deck-04 gets none by design, which is
  what makes exercise 55 unanswerable in the right way. Do not "fix" it.
- Fault entries: 06-08 at 7 and 19; 06-09 at 7, 8, 9 and 22. The contiguous run 7/8/9 is what makes
  the context blocks merge in exercises 23–27. Changing it changes 23, 26, 27, 29.
- `archive/deck-03-2187-06-09.log` is the 06-09 report with `FAULT` lower-cased by `sed`. That single
  transformation carries exercises 2, 3, 15, 52 and 53.
- `readings.csv` has two columns named `strain` with different values, so `-o` yields exactly 2
  matches per data line: 40 over 20 rows.
- Measured: `-ow bay` = 7, `-oc` = 20, `-l -L` last-flag-wins, `-A-1` = "invalid context length
  argument" (status 2).
