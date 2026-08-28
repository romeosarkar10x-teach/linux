# 07/04 — Solutions: `sed` substitution

Every number here was measured in the lab. Flag none of it to the student; guide with `help.md`.

## Substitution, the basic form

**1.** Prints `412 OPS-BOT` on line 1 and leaves the file alone. `sed` is a **stream** editor: it
reads input, writes output, and never modifies its input. An editor changes the file; `sed` changes a
copy on its way past. Only `-i` breaks that, and `-i` is really "write the output back over the
input afterwards".

**2.** `^` anchors at the start of the line, the space is a literal space, `*` means "zero or more of
the thing before it". So: zero or more leading spaces, replaced with nothing. Note `*` applies to the
single preceding character, not to the whole pattern.

**3.** `cat -A data/counts.txt` shows `    412 ops-bot$`; after `sed` it is `412 ops-bot$`. Only the
leading run changed.

**4.** `sed 's/deck-0/Deck /' data/quoted.txt` prints all four lines changed. With `-n … /p` it also
prints four lines, because every line matched. The difference only shows on a file where some lines
do not match: without `-n`, `sed` prints every line whether it changed or not; `-n` plus `p` prints
only the ones that changed.

**5.** Each changed line appears **twice**. `sed` auto-prints the line at the end of the cycle, and
`p` printed it as well. This is the reason `-n` exists, and the reason `sed -n '…p'` is one idiom
rather than two flags that happen to combine.

**6.** Exit status `0`. "No match" is not an error for `sed`, which is a real difference from `grep`
— `grep` returns 1 when it finds nothing, and pipelines and `if` statements are often built on that.
`sed` succeeded: it processed every line and changed none of them.

**7.** It deletes the text: line 2 becomes `     96 ` (with the trailing space where the name was).
The replacement is the **empty string** between the second and third delimiters. Deletion is just
substitution by nothing.

## The first-match trap

**8.** Without `g`: `panel ONE of 1 in bay 1`. With `g`: all three `1`s on that line change. **The
default is: first match on each line only.**

**9.** `panel 1 of ONE in bay 1` — the second `1` on the line. `N` means "the Nth match", counting
per line.

**10.** `panel 1 of # in bay #` on every line: from the second match onward, all of them. `Ng` is
"the Nth and everything after it".

**11.** All 600 lines contain more than one `0` — the date `2187-06-10` alone contains two. A
`sed 's/0/X/'` typo fix would have corrupted every line in the file while looking like it worked, and
`wc -l` before and after would be identical. This exercise exists to make that number 600 rather than
"some".

**12.** The rule worth writing down: **decide per line, not per file.** If the thing you are matching
can occur twice on a line, you need `g` or an anchor. If you cannot say which, add an anchor (`^`,
`$`) so the question does not arise.

## Capture groups

**13.** `\1` is the run of digits, `\2` is the rest of the line after the space. Output is
`ops-bot 412`, `rhea 96`, and so on. The leading `^ *` is matched but not captured, which is how the
padding disappears.

**14.** `sed 's/^ *\([0-9]*\) \(.*\)/\2\t\1/' data/counts.txt | cat -A` gives `ops-bot^I412$`. This is
the thing lesson 02 exercise 45 could get half of and no further: `cut` can select columns but never
reorder them, and `paste` can only join files. Reordering needs a tool that can match and rewrite.

**15.** `sed -E 's/^ *([0-9]+) (.*)/\2\t\1/'`. Same output. The ERE version is easier to read for the
same reason it was in chapter 6: the backslashes in BRE land on the characters you use most.

**16.** Yes, `\1` and `\2` stay backslashed. The replacement is not a regular expression — it is a
template. `-E` changes how the **pattern** is parsed and nothing else.

**17.** `sed -E 's|([0-9]+)/([0-9]+)/([0-9]+)|\3-\2-\1|' data/dates.txt` gives

```
2187-06-10 hull sweep
2187-06-11 filter change
2186-12-03 panel swap
2187-01-18 access review
2187-07-07 galley inventory
```

The escaped-slash form `sed -E 's/([0-9]+)\/([0-9]+)\/([0-9]+)/\3-\2-\1/'` is identical and worse.

**18.** Converted, `sort` gives 2186-12-03 first and 2187-07-07 last — true chronological order.
Original, `sort` gives `03/12/2186` first because it compares the **day** field first, then the
month, then the year. The 2186 entry only lands first by accident.

**19.** Yes. "Not because it is prettier but because it sorts" is exactly exercise 18. YYYY-MM-DD is
the only common format whose lexical order is its chronological order, which is why every log on this
station uses it.

**20.** `sed 's/^ *\([0-9]*\) \(.*\)/\1 [\2]/'` gives `412 [ops-bot]`.

## `&`

**21.** `&` is the entire text the pattern matched. Output: `[41]`, `[193]`, `[2187]`, `[7]`, `[412]`,
`[96]`.

**22.** `sed 's/[a-z][a-z-]*$/[&]/' data/counts.txt` — no groups needed, and the leading padding stays
because it is no longer part of the match. Shorter, and it says what it means: bracket the name.

**23.** `<4><1>` for `41`. `[0-9]` matches exactly one digit, so with `/g` it matches once per digit
and `&` is one digit each time. `&` is the match, not the line.

**24.** Backslash it: `echo ops-bot | sed 's/ops/A\&B/'` gives `A&B-bot`. Unescaped `&` there would
give `AopsB-bot`.

## Delimiters

**25.** Basenames: `access.log`, `panel.log`, `kestrel`, `forms.txt`. It imitates `basename`, and
unlike `basename` it does a whole file at once. `.*/` is greedy on purpose here: it eats up to the
**last** slash, which is precisely what you want.

**26.** Dirnames: `/var/log/station` twice, `/opt/kestrel/bin`, `/home/cadet/notes`. That is
`dirname`. `/[^/]*$` is "a slash, then a run of non-slashes, then end of line".

**27.** `sed 's/.*\///'` — one backslash, but the pattern now contains `\//` and every reader has to
stop and parse it. On a longer pattern you get four or six and it becomes unreadable. Change the
delimiter instead.

**28.** Both work; `sed 'sXrheaXRHEAX'` is legal because the character after `s` is the delimiter,
whatever it is. Do not write it. A delimiter that could appear in ordinary text makes the command
unreadable and breaks the moment the pattern grows an `X`. Stick to `/`, `|`, `#`, `,`, `:`.

## Greed

**29.** `deck-01 X`. The pattern `".*"` matched from the first quote to the **last** quote on the
line, swallowing the date in the middle. Regular expressions take the longest match available at the
leftmost starting point.

**30.** `sed 's/"[^"]*"/X/'` gives `deck-01 X 2187-06-10 "routine"`. `[^"]*` cannot match a quote, so
the run has to stop at the closing quote. You have replaced "anything" with "anything except the
terminator", which is the whole trick.

**31.** With `/g`, both quoted fields become `X`: `deck-01 X 2187-06-10 X`.

**32.** `sed -n 's/^\([^"]*\)"\([^"]*\)".*/\2/p' data/quoted.txt` gives `sealed`, `open`, `sealed`,
`open`. The first group is what precedes the quote, the second is the field itself, `.*` eats the
rest, and `-n … p` prints only the rewritten line.

**33.** Nothing matches; all four paths print unchanged. There is no `deck` in `data/paths.txt`. A
`sed` that matches nothing prints its input unchanged and exits 0 — which is why a `sed` typo is
quieter and more dangerous than a `grep` typo.

**34.** `.*` matches as much as it can, and it does not stop at the thing you were picturing. Prefer a
negated class (`[^X]*`) whenever you mean "up to the next X".

## Case

**35.** `\U&` gives `RHEA`, `CASS`, …; `\L&` gives the input back (already lowercase); `\u&` gives
`Rhea`, `Cass`, …; `\l&` gives the input back. `\U`/`\L` run until the end of the replacement or a
`\E`; `\u`/`\l` affect one character.

**36.** No difference in output here, because `\u` only ever affects the next character either way.
The difference is in what got replaced: `s/.*/\u&/` rewrites the whole line, `s/^./\u&/` rewrites one
character. On a line you also wanted to keep intact, the second is the safe one.

**37.** `tr 'a-z' 'A-Z' < data/case.txt` gives `RHEA`, `CASS`, … — `tr` can uppercase everything and
cannot uppercase only the first letter, because `tr` has no notion of position. It maps characters
wherever they appear. `sed` can anchor with `^`. That is the difference between a character mapper
and a pattern matcher, and it is the reason lesson 03 comes before this one.

**38.** Without `I`, only the lowercase `rhea` becomes `X` and `Rhea` survives. With `I`, both lines
print `X`. `I` is a GNU extension on the `s` flags; the address form is `/rhea/I`.

**39.** `sed 's/.*/\L&/' file` on both sides, or `tr '[:upper:]' '[:lower:]'`. Either makes the
roster's `Rhea` and the log's `rhea` compare equal. The display-name problem in lesson 02 exercise 49
was two problems — case, and `Maintenance, Deck` versus `maintenance` — and this fixes the first one.

## Addresses

**40.** `3p` prints `ops-bot dominates every count` (line number). `2,5p` prints the summary block
(line range). `$p` prints `trailing line` (last line).

**41.** Yes, both included. A regex range runs **from** the line matching the first pattern **through**
the line matching the second, inclusive. If END never matches, the range runs to end of file — a
common and quiet bug.

**42.** `preamble line`, `middle line`, `trailing line`. Both blocks and their markers are gone.

**43.** Same three lines. They are different commands with the same output here: `d` deletes the
matched range and auto-prints the rest, `-n … !p` prints everything outside the range. `d` is the one
to write; `!` earns its keep when the command is not a delete.

**44.** Output has the appendix's three lines indented and everything else flush. The address selects
the lines; the `s` runs only on those. `s/^/  /` substitutes the zero-width start of the line with two
spaces, which is the standard way to indent.

**45.** Lines 1, 3, 5, 7, 9 — `first~step`. It is a **GNU extension**, not POSIX. Fine on the station,
not portable.

**46.** Identical output (same md5). Write `head -3`; it is clearer. On a huge file both are fast for
the same reason: `q` makes `sed` stop reading, exactly as `head` does. The one to avoid is
`sed -n '1,3p'` without `q`, which reads the entire file to print three lines.

**47.** `=` prints the **line number** of each matching line: `3` and `5`. The `grep` equivalent is
`grep -n TODO | cut -d: -f1`. `=` prints the number on its own line, which is why it pairs with `-n`.

**48.** `sed -n '/deck-04/s/^[^ ]* [^ ]* \([^ ]*\) .*/\1/p' logs/access-2187-06-10.log | sort |
uniq -c | sort -rn` gives 102 ops-bot, 24 rhea, 13 cass, 5 vint, 3 orla, 2 bex, 1 maintenance. The
address filters, the `s` extracts the field, `p` prints the result. It works and it is horrible; the
lesson-02 version is `grep deck-04 | cut -d' ' -f3`, and lesson 05 will do the whole thing in one
`awk`. Knowing you *can* do this in `sed` matters mostly so you can recognise when you should not.

## The report cleanup

**49.** `cat -A` shows:

```
Access review, draft   $
prepared by the  duty officer^M$
TODO check the tail   $
Deck 01 sealed  at 04:00$
TODO confirm with ops$
End of draft $
```

Violations: trailing spaces on lines 1, 3, 6 (rule 1); a carriage return on line 2 (rule 1 in spirit —
it is invisible whitespace at end of line); double spaces on lines 2 and 4 (rule 2); two TODOs (rule
4). Rule 3 has nothing to bite on here — the report carries no dates — but
`data/dates.txt` violates it on every line.

**50.** `sed 's/[ \t]*$//' | cat -A` clears the trailing spaces and **leaves `^M$` on line 2**. `\r`
is neither a space nor a tab, so `[ \t]` does not match it — and because the CR sits at the very end,
`$` anchors after it and the spaces before it (if any) are no longer at end of line either.

**51.** `sed 's/\r$//'` removes the CR and leaves trailing spaces. The order that works is CR first:

```
sed 's/\r$//; s/[ \t]*$//' data/report.txt
```

The other order leaves `^M` behind, as exercise 50 showed. **Strip line endings before you strip
whitespace.**

**52.** `sed 's/  */ /g'` — a space, then a space-star, so "two or more spaces" become one. Rule 2.
`Access review, draft   $` becomes `Access review, draft $`: it squeezed the run to one space but did
not remove it, because that job is rule 1's and belongs to the trailing-whitespace command. Two rules,
two commands, and the order still matters.

**53.** `sed '/TODO/d'` leaves four lines. Counting first (`2`) is the point: a delete tells you
nothing about what it deleted, and rule 4 says the TODOs have to be *resolved*, not hidden. If you
delete two TODOs without reading them you have filed a report with two unanswered questions in it.

**54.**

```
cp data/report.txt scratch/report.txt
sed -i.bak 's/\r$//; s/[ \t]*$//; s/  */ /g; /TODO/d' scratch/report.txt
diff scratch/report.txt.bak scratch/report.txt
```

`diff` shows the CR and whitespace changes and the two removed lines.

**55.** `sed -i` with no suffix leaves no backup. The original is recoverable only because it is still
in `data/`; if you had run it on the original there would be nothing to recover — no undo, no trash,
no prompt. What to do differently: run without `-i` and read the output, then use `-i.bak`, and never
point `-i` at the only copy of anything.

## Stretch

**56.**

```
sed 's/^ *\([0-9]*\) \(.*\)/\2\t\1/' data/counts.txt | sort -k2,2rn
```

gives `ops-bot 412`, `rhea 96`, `cass 54`, `vint 21`, `orla 12`, `bex 4`, `maintenance 1`, tab
separated. Keep it. That is the shape of the report in lesson 08, and the captain will reject the
first version of it.

**57.** `scratch/todo.txt` gets the two changed lines (`PENDING check the tail   `, `PENDING confirm
with ops`); the terminal gets **nothing**, because `-n` suppressed auto-printing and there is no `p`
flag. `w` writes the line as it stands after substitution. Add `p` and you get both.

**58.** With no address, `sed -E 's/^([^\t]+)\t([^\t]+)/\2\t\1/' data/roster.tsv` swaps the header too
(`deck<TAB>account`). Excluding it: `sed -E '1!s/…/…/'` — the address `1!` means "every line except
line 1". `2,$` would do the same and says the same thing less directly.

**59.** `sed 's/ .*//' logs/access-2187-06-10.log | uniq` gives one line: `2187-06-10`. It is a bad
way to do it because `uniq` only collapses *adjacent* duplicates and this log happens to be sorted by
time within one day — the moment you concatenate two days out of order it silently reports the same
date twice. Use `cut -d' ' -f1 | sort -u`, which does not depend on the input's order.

**60.** Exercise 48 is the obvious one: extracting field 3 with `s/^[^ ]* [^ ]* \([^ ]*\) .*/\1/`
already reads badly, and it breaks completely the moment a field can be empty, contain a space, or
move. `awk` addresses fields by number instead of by counting separators, so `awk '{print $3}'`
neither cares how wide the fields are nor how many come after. Anything that needs arithmetic, a
running total, or a comparison between two fields is also `awk`'s, because `sed` cannot count.

## Authoring notes

- `data/counts.txt` is `cut -d' ' -f3 logs/… | sort | uniq -c | sort -rn` from the shared access log,
  so the whole chapter keeps the same seven accounts and the same counts. Students who did lesson 01
  recognise them, and lesson 08's report is built from the same numbers.
- Exercise 11's answer is **600 out of 600** — every line of the log contains two zeros in the date.
  It was written expecting "some" and measured as "all", which is a better exercise.
- Exercise 5 (`p` without `-n`) must be run, not described. The duplication is the only way the `-n`
  idiom stops being magic.
- Exercises 50–51 are the load-bearing pair of the lesson. The `^M` surviving a trailing-whitespace
  strip is the single most useful thing here and it recurs in every chapter that reads a file someone
  else produced.
- `notes/style.txt` rule 3 exists so exercise 18 has a station-authored reason to point at, rather
  than the tutor asserting that ISO dates are better.
- Exercise 48 deliberately produces a working, ugly command. The chapter's argument is that `sed`
  substitutes and `awk` reads fields; a student who has felt `sed`'s field extraction is ready for
  lesson 05 in a way that one who has only been told is not.
