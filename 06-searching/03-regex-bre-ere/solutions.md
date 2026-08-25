# 06/03 — Solutions: Regular Expressions

All numbers measured in the container (GNU grep 3.12). Students must not read this file.

## Anchors

**1.** `grep -c 'BAY'` → **12**; `grep -c '^BAY'` → **10**. The anchor removes ` BAY-06` (leading
space) and `-BAY-05` (leading dash). Neither is malformed as an *identifier* — both are malformed as
*lines*, which is exactly the distinction anchors make.

**2.** Line 13, `BAY-`. `$` asserts that the position after the dash is the end of the line: nothing
follows, not even a space. It matches a position, not a character.

**3.** Exactly: `grep -x 'BAY-01' ids.txt` or `grep '^BAY-01$'` → 1 line. Contains:
`grep 'BAY-01'` → 2 lines, because `BAY-01-A` contains it. `ids.txt` distinguishes them on purpose.

**4.** Zero — there is no blank line. `cp ids.txt scratch/; printf '\n' >> scratch/ids.txt; grep -c
'^$' scratch/ids.txt` → 1. `^$` matches the empty string at a position where the start of the line
and the end of the line are the same place. Two assertions, no characters.

**5.** ` BAY-06`. Every pattern beginning `^BAY` fails on it, and the failure is invisible — the line
is *there*, it is well formed, and it will not be counted. `-x` has the same problem: it does not
trim, so leading whitespace defeats it too (lesson 02, exercise 8).

**6.** One: `-BAY-05`. `-` has no meaning in a regex at all except inside a bracket expression, so
`'^-'` needs no escape. The lesson-01 problem was the **shell and `grep`'s option parser**, not the
regex: a pattern that *starts* with a dash is read as a flag before the regex engine ever sees it.
`grep -e '^-'` or `grep -- '^-'`.

## Classes

**7.** `^BAY-[0-9][0-9]$` → **4**: `BAY-01`, `BAY-02`, `BAY-13`, `BAY-99` (lines 1, 2, 3, 18).
Excluded `BAY` lines: `BAY-7` (one digit), `BAY-007` (three), `BAY-01-A` (trailing), `BAY-`
(none), `BAY-05 spare` (trailing text), `BAY_07` (underscore, not dash), plus the two the anchor
removed in exercise 1.

**8.** `^BAY-[[:digit:]][[:digit:]]$` → 4. They differ when the locale defines digits outside ASCII —
`[0-9]` is a range over collation order and can behave unexpectedly in some locales, while
`[[:digit:]]` is defined by the locale as "the digit characters". Scripts should use the class form;
it cannot be surprised.

**9.** `^BAY-[0-9]\{1,3\}$` → **6**: the four above plus `BAY-7` and `BAY-007`.

**10.** **11**, because `[A-Z]*` and `[0-9]*` both allow zero occurrences, so `BAY-` matches (three
letters, dash, zero digits) — and so would a line consisting of a lone `-`. The pattern that means
what was intended is `^[A-Z]\{1,\}-[0-9]\{1,\}$`, or `\+` in place of `*`.

**11.** `grep -n '[^A-Z0-9-]' ids.txt` → lines 6 (`bay-04`), 15 (`BAY-05 spare`), 16 (` BAY-06`),
17 (`BAY_07`). Yes, `bay-04` is one: lower case is not in the class.

**12.** `[^]]` is a valid class — a `]` immediately after `^` is literal. `[^]` is not; grep says:
```
grep: Unmatched [, [^, [:, [., or [=
```
**13.** `0x41` and `0-41`. The unescaped `.` matched `x` and `-` (4 total: `0.41`, `0x41`, `0-41`,
`strain 0.41 nominal`); escaped gives 2.

**14.** `'0\.41'` and `'0[.]41'`. For a pattern assembled from a variable, the bracket form is
safer: it survives another round of expansion without the backslash being eaten, and it cannot be
turned into a different escape by accident. (The real answer for variable data is `-F`.)

**15.** `grep -c '^\.\+$' dots.txt` → **2**, matching `.` and `..`. In ERE: `grep -cE '^\.+$'`.

## Quantifiers

**16.** `'BAY-[0-9]\+'` → **10**; `'BAY-[0-9]+'` → **0**. Not an error. In BRE `+` is a literal plus
sign, so the pattern asks for `BAY-`, a digit, and a literal `+` — which no line contains. Exit
status 1: "no match", indistinguishable from a correct search that found nothing.

**17.** Something like: "Before you conclude the codes are absent, check that your pattern means what
you think in the dialect you used — `+` and `{}` are literals in BRE, and a wrong pattern fails
silently with status 1."

**18.** `grep -cE 'BAY-[0-9]+' ids.txt` → 10. The `\+` became `+`.

**19.** BRE `^BAY-[0-9]\{2\}$`, ERE `^BAY-[0-9]{2}$` — both **4**. The two backslashes before `{`
and `}` are the only changes; `^`, `$`, `[0-9]` and the literals are identical in both dialects.

**20.** Counted: `^BAY-[0-9]\{1,2\}$` → **5** (`BAY-01`, `BAY-02`, `BAY-13`, `BAY-99`, `BAY-7`).
With `\?`: `^BAY-0\?[0-9]$` → matches `BAY-7` and `BAY-01`… but not `BAY-13`, so the honest answer is
that `\?` expresses "optional leading zero on a single digit" and the counted form expresses "one or
two digits"; they are different questions and the student should say which one they were asked.

**21.** `^BAY-0\?[0-9]*$` → **7**. `0\?` matches zero or one `0`, `[0-9]*` matches zero or more
digits — so `BAY-` satisfies it with both quantifiers taking nothing. Every `*`/`?` in a pattern is
a place where "nothing" is an acceptable answer.

**22.** `^BAY-0\?[0-9]\{1,\}$`, or `^BAY-[0-9]\+$`.

**23.** `.*` can consume `] plain [beta] plain [` and the trailing `\]` still finds the final `]`.
Greedy means "the longest match that lets the rest of the pattern succeed", and the rest of the
pattern succeeds at the last `]` on the line.

**24.** `grep -o '\[[^]]*\]' greedy.txt | wc -l` → **7**.

**25.** For line 5 it returns `[unclosed and then [closed]` — the class `[^]]` happily consumes the
second `[`. For "fields are bracket-delimited and cannot nest", that is wrong. For "a field starts at
a `[` and ends at the next `]`", it is exactly right. Regex has no opinion about which definition you
meant; you have to state it.

**26.** `{0,}` is `*`, `{1,}` is `+`, `{0,1}` is `?`. E.g. `grep -c '^BAY-[0-9]\{1,\}$' ids.txt`
equals `grep -c '^BAY-[0-9]\+$' ids.txt` → 6.

## Alternation and groups

**27.** ISO `^[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\} ` → **7**; slashed `^[0-9]\{2\}/` → **2**; time-only
`^[0-9]\{2\}:` → **2**. Sum 11 of 12 lines. The missing line is `2187-6-9 …`, which is ISO-*shaped*
but has one-digit month and day, so the strict pattern rejects it.

**28.** Literal `|`. BRE has no alternation operator without a backslash, so the pattern asked for
four digits, a dash, a literal pipe, then `^`… none of which is in the file. Zero, status 1, no
error.

**29.** `grep -c '^[0-9]\{4\}-\|^[0-9]\{2\}/' log.txt` → 10; `grep -cE '^[0-9]{4}-|^[0-9]{2}/'` → 10.

**30.** Lines 5 and 8, the two time-only records (`04:00:04 entry 004 ok`, `04:00:07 entry 007 ok`).
On purpose: they are the same log with the date dropped, which is a formatting inconsistency, not a
different kind of event.

**31.** `grep -cE '^([0-9]{4}-[0-9]{1,2}-[0-9]{1,2}|[0-9]{2}/[0-9]{2}/[0-9]{4}|[0-9]{1,2}:[0-9]{2})'`
→ 12. Three formats in one file means the generator was changed at least twice and nobody
back-filled, so every consumer of this log must handle all three — or silently drop the ones it does
not recognise, which is the failure that matters.

**32.** Line 10, `2187-6-9 …`: `[0-9]*` accepts one digit (and zero), where `[0-9]\{4\}` does not.
Loosening a quantifier to "fix" a miss also accepts things you never inspected.

**33.** `grep -cE '([0-9]{2}:){2}[0-9]{2}' log.txt` → 12; in BRE
`grep -c '\([0-9]\{2\}:\)\{2\}[0-9]\{2\}'`.

**34.** **6** lines: `strain strain…`, `bay-01 bay-01…`, `the the cat`, `report reported`,
`E-104 E-104`, `ok ok ok`. `report reported` matched because nothing requires the second occurrence
to end at a word boundary — `\1` matched the `report` inside `reported`.

**35.** `grep -c '\b\([A-Za-z0-9-]\+\) \1\b' pairs.txt` → **5**, and `grep -cw '\([A-Za-z0-9-]\+\)
\1' pairs.txt` → 5 as well. Either boundary works; `-w` is portable, `\b` is GNU.

**36.** The **text**. `E-104 E-104` matches; `E-104 E-105` does not (`grep -c '\([A-Za-z0-9-]\+\)
\1' <<< 'E-104 E-105'` → 0). If `\1` re-ran the pattern, `E-105` would match it, since it fits
`[A-Za-z0-9-]\+` perfectly.

**37.** `grep -cE '([A-Za-z0-9-]+) \1' pairs.txt` → 6. The parentheses lost their backslashes; `\1`
is `\1` in both dialects — the backreference is never spelled `1`.

## Whitespace

**38.** The single-space line, `deck 03 bay 01 ok` — one of six.

**39.** `[ \t]` contains **space**, **backslash**, and the letter **t**. Three characters, no tab.
It matches the three lines separated by one or more spaces and misses the two with tabs.

**40.** `grep -c 'deck[[:space:]]\+03' spacing.txt` → **5**. Excluded: `deck03bay01ok`, which has no
separator at all — correctly, since the pattern requires at least one.

**41.** `grep -c 'deck\t' spacing.txt` →
```
grep: warning: stray \ before t
```
and the count is **0**. GNU `grep` does not accept `\t` in a POSIX pattern. To match a real tab:
put one in the pattern via the shell (`grep $'deck\t' spacing.txt`) or use `[[:space:]]` /
`[[:blank:]]`.

**42.** `grep -cE 'deck[[:space:]]*0?3[[:space:]]*bay' spacing.txt` and similar will do it, and it is
a **bad** pattern: making every separator optional means it also matches `deck3bay`, `deck 3 bay` and
anything with the fields run together in an order you did not intend. A pattern that accepts every
input shape stops being evidence about the input's shape.

## Dialects

**43.** `^BAY-[0-9]\{2\}$` → `-E '^BAY-[0-9]{2}$'`. `^(BAY|DECK)-[0-9]+$` → BRE
`'^\(BAY\|DECK\)-[0-9]\+$'` → 6 lines (`BAY-01 02 13 99`, `DECK-03`, `DECK-3`).

**44.** Needing a backslash to be an **operator**: BRE `? + { } ( ) |`. Needing a backslash to be a
**literal**: ERE `? + { } ( ) | . * ^ $` (and BRE `. * ^ $` in the positions where they are special).
`^` and `$` are special at the ends in both; `*` is special after something to repeat in both.

**45.** Neither `grep -E 'a{2' ids.txt` nor `grep 'a{2' ids.txt` errors — both search for the literal
text `a{2` and exit **1**. GNU accepts an unmatched `{` as a literal. The genuine error is an invalid
interval:
```
grep: Invalid content of \{\}
```
from both `grep -E 'a{2,1}'` and `grep 'a\{2,1\}'`, exit status **2**.

**46.** `grep -cP 'BAY-(?=0)' ids.txt` → **7**. The lookahead asserts that a `0` follows *without
consuming it*, so the match is `BAY-` alone. POSIX has no zero-width assertion other than `^`, `$`
and the GNU word boundaries. The two reasons: `-P` may not be compiled in on a machine you do not
control, and PCRE backtracking can go exponential on adversarial input.

**47.** `grep -o 'BAY-0' ids.txt` → 7 matches, but each one *includes* the `0`. The difference is
what the match consumes: with `-P` the reported match is `BAY-`, with POSIX it is `BAY-0`. If you are
piping matches onward, that is the whole difference.

## Experiment

**48.** e.g. `printf '<a> <b> <c>\n' > scratch/g; grep -o '<.*>' scratch/g` → one match, the whole
line. Fix: `grep -o '<[^>]*>' scratch/g` → three.

**49.** Start of **line**. `printf 'a\nab\n' > scratch/l; grep -c '^b' scratch/l` → 0, and
`grep -c '^a' scratch/l` → 2. `grep` decides one line at a time; there is no pattern in POSIX `grep`
that can span a newline.

**50.** `grep -c '^*' ids.txt` → **0**. A `*` with nothing to repeat is a literal asterisk (`^` is an
anchor, not a repeatable atom), so the pattern means "a line starting with an asterisk", and no line
does. Students who predicted "every line" were reading it as a glob.

**51.** Under `LC_ALL=C` they are the same for ASCII. Under a UTF-8 locale, `[[:lower:]]` matches
`é` and `[a-z]` does not: `printf 'é\n' > scratch/u; LC_ALL=C.UTF-8 grep -c '[[:lower:]]'
scratch/u` → 1 versus `[a-z]` → 0. Accept any demonstration with a non-ASCII letter.

**52.** Build something like `yes 'aaaaaaaaaaaaaaaa bbbb' | head -200000 > scratch/big`, then time
`grep -c 'aaaa' scratch/big` against `grep -c '\(a\+\) \1'`. The backreference is measurably slower
because it cannot be compiled into a single-pass automaton — the engine has to try alternatives and
compare captured text, which is why backreferences are not a regular operation.

## Stretch

**53.** A defensible definition: "an upper-case prefix, a single dash, and one or more digits, with
nothing else on the line". Pattern: `grep -cE '^[A-Z]+-[0-9]+$' ids.txt` → 8 (`BAY-01 02 13 7 007
99`, `PANEL-03 11`, `DECK-03 3` — the student should list them). It rejects `bay-04` (case),
`BAY-01-A` (suffix), `PANEL-3B` (letter in the numeric part), `BAY_07` (underscore), `BAY-`,
`BAY-05 spare`, ` BAY-06`, `-BAY-05`. Grade the defence, not the pattern: a student who says "`bay-04`
is a valid identifier typed in lower case and my pattern is wrong to reject it" is right, and should
then show the `-i` version.

**54.** `grep -vnE '^[0-9]{4}-[0-9]{2}-[0-9]{2} ' log.txt` → the slashed lines (3, 7), the time-only
lines (5, 8), and `2187-6-9` (10). Of those, `2187-6-9` and the time-only lines are formatting
variants of the same record type; the slashed lines are too. **None** of them is a different record
type — every line of this file is one report entry, which is the point: format variation is not
semantic variation, and a filter written against the dominant format would drop five real entries.

**55.** `[0-9]*` matches zero or more digits, so it matches the empty string at the start of every
line: `grep -c '[0-9]*' ids.txt` → **18**, the whole file. They wanted `grep -c '[0-9]'` → 17, or
`'[0-9]\+'`.

## Dig

**56.** `grep -nE '^[0-9]{4}-[0-9]{1,2}-[0-9]{1,2} ' log.txt` isolates the shape; the two lines that
are ISO-shaped but not ISO are line 10 (`2187-6-9`, unpadded month and day) and line 11
(`2187-06-09 4:00:10`, unpadded hour). A tool sorting these as text puts `2187-6-9` **after**
`2187-06-09` — `6` sorts after `0` — so an unpadded date silently lands at the end of a
chronologically sorted report, and `4:00:10` sorts before `04:00:00`. Zero padding is what makes
lexical order equal chronological order.

**57.** Within this lesson you can only check the *shape* of the numbers: `grep -o 'entry [0-9]\{3\}'
log.txt` extracts them, `grep -c` counts them, and a count that disagrees with the report's stated
entry count tells you something is missing. What it cannot do: tell you *which* number is missing, or
notice a gap, because `grep` never compares one line with another. Detecting the gap itself needs
Chapter 7. Say this plainly — it comes back.

**58.** `ok ok ok` contains two overlapping repeated pairs (positions 1–2 and 2–3), but
`grep -o '\([a-z]\+\) \1' <<< 'ok ok ok'` reports **one** match, `ok ok`: scanning resumes after the
end of the first match, so the second `ok` is consumed and cannot start another. The gap between "how
many repeats are in this line" and "how many matches `grep -o` prints" is the non-overlap rule from
lesson 02, exercise 21.

## Authoring notes

- `ids.txt` is eighteen lines and every malformation is load-bearing: leading space (ex 5), leading
  dash (ex 6), underscore (ex 11), lower case (ex 11, 53), trailing text (ex 3, 53), empty numeric
  part (ex 10, 21). Do not tidy it.
- Measured: `^BAY` 10, `^BAY-[0-9][0-9]$` 4, `{1,3}` 6, `{1,2}` 5, `^[A-Z]*-[0-9]*$` 11,
  `BAY-[0-9]\+` 10, `BAY-[0-9]+` 0, `[0-9]*` 18.
- `log.txt` is deliberately 7 strict-ISO + 2 slashed + 2 time-only + 1 unpadded-ISO = 12.
- `pairs.txt` gives 6 for the naive backreference and 5 with a boundary; `report reported` is the
  whole reason that file exists.
- `grep 'deck\t'` warns `stray \ before t` and matches nothing. This was measured, not assumed —
  an earlier draft of the readme claimed GNU supported it.
- `grep -E 'a{2'` is NOT an error in GNU grep; `a{2,1}` is (`Invalid content of \{\}`, status 2).
