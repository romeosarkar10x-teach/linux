# 07/03 — Solutions

Every output below was measured in the container.

## Getting input into tr

**1.**
```
tr: extra operand ‘data/mixed-case.txt’
```
`tr` takes sets, not filenames. It saw a third operand and had nowhere to put it.

**2.** `tr 'A-Z' 'a-z' < data/mixed-case.txt`; `cat data/mixed-case.txt | tr 'A-Z' 'a-z'`;
`echo RHEA | tr 'A-Z' 'a-z'`. The first is the one to write — the pipe from `cat` spawns a process to
do what the shell does for free.

**3.** `tr` is a **filter**: a thing that sits in the middle of a pipeline and transforms a byte
stream. Filters do not need to open files because the shell hands them one already open. Adding a
filename argument would have made `tr` a special case among the tools that do exactly this.

**4.**
```
tr: missing operand
```

**5.** Because `-d` is a different operation. Translation needs a source set and a destination set;
deletion needs only the set to delete. `tr -d 'b'` is complete.

**6.** **18** distinct lines raw, **7** after folding. The file contains seven accounts written in up
to three casings each.

## Translating

**7.** Same output. Write `[:upper:]`/`[:lower:]` in a script: the ranges `A-Z`/`a-z` are correct only
for ASCII and only in a locale where the alphabet is contiguous, and the classes say what you mean.

**8.**
```
2 bex / 3 cass / 2 maintenance / 3 ops-bot / 3 orla / 3 rhea / 2 vint
```

**9.**
```
$ { sort -u data/log-accounts.txt
    tr '[:upper:]' '[:lower:]' < data/roster-display.txt | sort -u; } | sort | uniq -u
```
**Empty output — no accounts differ in either direction.** Lesson 02's answer of fourteen was entirely
an artefact of case. One `tr` fixed it, and the reason lesson 02 could not was that it had no way to
change a character.

**10.** `xyyyyy`. **SET2 is padded to SET1's length by repeating its last character.**

**11.** `xycdef`. **`-t` truncates SET1 to SET2's length instead of padding SET2**, so `c` through `f`
are left alone.

**12.** `z` is **ignored**; `tr 'ab' 'xyz'` behaves as `tr 'ab' 'xy'`. Not an error, and no warning —
`tr` never warns about a set-length mismatch in either direction.

**13.** Masking. `tr '[:digit:]' '#'` replaces every digit with `#` precisely because the one-character
SET2 is padded out to ten. Same for `tr '[:punct:]' '_'` or `tr -c '[:alnum:]' '-'`.

**14.** The final newline. `tr '\n' ' '` translated **every** newline including the last, so the output
ends with a space and no line terminator, and your next prompt appears on the same line. Anything that
folds a file into a line has to put a terminator back (`; echo`).

**15.**
```
$ tr 'cat' 'dog' <<< 'the cat sat on the mat'
ghe dog sog on ghe mog
```
`c`→`d`, `a`→`o`, `t`→`g`, three independent character mappings. Every `t` in the sentence became `g`,
including the ones in "the". The person who wrote it thought `tr` replaced the **word** "cat" with the
word "dog". It does not, it cannot, and this is the most common `tr` mistake there is. The tool for
that is `sed` (lesson 04).

**16.** `\011` is the **octal** code for tab, so the command replaces tabs with colons. You write it
that way when the literal character would be invisible or would be eaten by the shell — a tab typed
into a command line may be intercepted by completion, and a tab inside a script is impossible to
review. `'\t'` works too and is clearer; octal is what you fall back on for characters with no escape.

## Deleting and complementing

**17.** `^M` before every `$` — a carriage return (0x0D) preceding each newline. Windows-style line
endings.

**18.**
```
sealed^M$
open^M$
```
Every value in the last column has an invisible `^M` glued to its end.

**19.** `tr -d '\r' < data/crlf.txt | cat -A` → clean `deck-01^Isealed$`.

**20.** Because a missing column produces an obvious hole, and a `^M` produces a value that **looks
correct everywhere you look at it**. `cat` shows `sealed`, your eyes show `sealed`, and
`[ "$x" = sealed ]` is false. It fails comparisons, sorts into the wrong place, and turns up in a
frequency table as two entries that print identically.

**21.** `^G` (BEL, 0x07) inside `panel-a...ok`; `^L` (form feed) inside `deck...-02 sealed`; `^K`
(vertical tab) after `pressure`.

**22.**
```
panel-aokdeck-02 sealedpressure normalplain line
```
The whole file on one line. **A newline is a control character**, so `[:cntrl:]` included it and `-d`
deleted every one.

**23.** `-c` complements the set: the command deletes every character that is **not** printable and
**not** a newline. Aloud: "delete everything except printable characters and line breaks."

**24.** **Specify what you want to keep, not what you want to remove.** The keep-set is finite and you
can enumerate it correctly; the remove-set is "everything else" and you will always forget a member of
it — here, the newline. This principle outlives `tr`.

**25.**
```
tr -d '[:digit:]'      ->  id-  id-  id-  ID-  id_  id.
tr -cd '[:digit:]\n'   ->  0041 0193 2187 0007 0412 0096
```
The second needs `\n` in the set because the newline is not a digit, so without it `-c` would delete
the line endings as well and you would get `004101932187000704120096` on one line. Same trap as
exercise 22, arrived at from the other direction.

**26.** `id0041 …` — the `-`, `_` and `.` are all gone. `[:punct:]` is every printable non-alphanumeric
non-space character.

**27.** `tr '_.' '--' < data/digits.txt` → every identifier reads `id-NNNN` (and `ID-0007`, which
`tr` did not touch because case was not what you asked about). Set choice: name the two separators you
actually saw and map both to `-`. Note SET2 could have been just `-`; the padding rule would repeat it.

**28.**
```
$ tr -c '[:alnum:]\n' '-' < data/digits.txt
```
Same result here, and **safer**, because it says "anything that is not a letter, digit or newline is a
separator" rather than listing the separators you happened to notice. A file with a `+` or a space in
one row would defeat exercise 27 and not this. Exercise 24's principle again.

## Squeezing

**29.** Every run of spaces collapsed to one, so the columns no longer line up and the file became
single-space delimited.

**30.**
```
$ tr -s ' ' < data/aligned.txt | cut -d' ' -f2
deck
deck-02
deck-01
deck-03
```

**31.** `cut` treats every delimiter character as a delimiter, so two adjacent spaces delimit an empty
field; it has no flag to collapse runs and never has had.

**32.** `xyz`. It **translates first, then squeezes the result** — `aaa`→`xxx`→`x`. You can prove it
with `echo aaabbbccc | tr -s 'abc' 'xxx'`, which gives a single `x`: if it squeezed first you would get
`xxx`.

**33.** `abbbccc`. With one set, `-s` **only** squeezes: runs of characters in the set collapse to one,
nothing is translated.

**34.** `-d` takes the **first** set and `-s` the second. So `tr -ds 'b' ' '` deletes `b`s and squeezes
spaces: `a  b   c` → `a c`.

**35.**
```
$ printf 'a\n\n\nb\n\n\nc\n' > scratch/blank.txt
$ tr -s '\n' < scratch/blank.txt
a
b
c
```
It collapses runs of blank lines, which is what you do to a file that has been through a generator
that emits an extra newline per record. (`data/prose.txt` has no blank lines, so it is unchanged there
— worth checking rather than assuming.)

**36.**
```
$ tr -cs '[:alpha:]' '\n' < data/prose.txt | tr '[:upper:]' '[:lower:]' | sort | uniq -c | sort -rn | head -5
      7 is
      6 the
      3 and
      3 a
      2 why
```

## Complement plus squeeze

**37.** With `-s`: **54** lines. Without: **59**. Five extra.

**38.** Every place where two or more non-letters are adjacent produces an empty field, and there are
exactly five: `, ` after "record" and `. ` twice at sentence ends, the `,` and `.` that fall at the end
of a line (punctuation immediately followed by the newline), and the file's own trailing newline. Each
run of non-letters becomes that many newlines instead of one.

**39.** It is a rough definition. At least two failures: it splits **contractions and hyphenated
words** — "it's" becomes `it` and `s`, "well-known" becomes two words — and it discards **numbers
entirely**, so `deck-02` contributes `deck` and nothing else. (A third: it has no idea about case, so
you need the second `tr` to avoid counting `The` and `the` separately.)

**40.**
```
$ printf "it's a well-known log\n" | tr -cs "[:alpha:]'-" '\n'
it's
a
well-known
log
```
Note the double quotes so the apostrophe survives the shell, and `-` placed **last** in the set so it
is not read as a range.

**41.** `tr 'A-Za-z' 'N-ZA-Mn-za-m' < notes/rot13.txt`.

**42.** The rot13'd text — that is, the file as stored. Thirteen is half of twenty-six, so applying
the rotation twice moves each letter a full alphabet and back to itself. rot13 is its own inverse,
which is why nobody ever writes a decoder.

**43.** `A-Za-z` is uppercase followed by lowercase, twenty-six plus twenty-six. `N-ZA-M` is the
uppercase alphabet started thirteen letters in and wrapped — `N`…`Z` is the second half,
`A`…`M` the first — so `A`→`N`, `N`→`A`. `n-za-m` does the identical thing for lowercase. The two
alphabets are kept separate so case is preserved.

**44.** Decoded, the note says rot13 is for **hiding text from a reader who has not decided to read
it** — a spoiler, a puzzle answer, a punchline — where the barrier is meant to be a decision rather
than a secret. And: "If you find rot13 protecting something that matters, what you have found is not a
cipher. You have found somebody who believed it was one."

## Bytes

**45.** `é` and `ï` did not fold: `CAFé`, `NAïVE`. Each is **two bytes** in UTF-8 and neither byte is
in the range `a-z`, so `tr` passed both through while folding everything around them.

**46.**
```
0000000   C   A   F 303 251  \n   N   A 303 257   V   E  \n ...
```
`303 251` is `é`, unchanged; the letters either side are uppercase.

**47.** `tr -d 'e' < data/utf8.txt` gives `café`, `naïv`, `plain`. The `é` **survived** — it is not the
byte `e`. So the visible "e" at the end of "café" remains while the one in "naïve" is gone, which is
the sort of result that makes someone doubt their own command.

**48.**
```
$ tr -d '\251' < data/utf8.txt | od -c | head -1
0000000   c   a   f 303  \n   n   a 303 257   v   e  \n ...
```
`café` is now `caf` followed by a lone `303` — half of a character, an invalid UTF-8 sequence that
most terminals draw as a replacement glyph and most parsers reject.

**49.** **`tr` is safe on single-byte data.** For ASCII input — log files, identifiers, generated
records — it is exact. For anything containing multi-byte characters, use a tool that understands
characters: `sed`, `awk`, or a real program.

**50.**
```
bex,deck-04,galley, night
```
You created a broken CSV: the last value contained a comma, and now nothing distinguishes it from a
column separator. This is lesson 02 exercise 31 from the manufacturing side — there the delimiter was
already inside a value and `cut` mis-split it; here you introduced the ambiguity yourself. Converting
tab-separated data to comma-separated is safe only when you have checked that no value contains a
comma, and `tr` cannot check.

## Stretch

**51.** `xxxxxx`. `[x*]` means "`x`, repeated as many times as needed to match SET1's length". It makes
the padding rule **explicit** instead of relying on it: `tr 'a-f' '[x*]'` and `tr 'a-f' 'x'` do the same
thing, but the first says so. `[x*N]` gives an exact count — though it does not cap anything:
`tr 'a-f' '[x*5]'` still outputs six `x`s, because a SET2 of five is then padded to six by the ordinary
rule. `[x*]` is the form worth knowing; the explicit count matters only when SET2 has other characters
after it.

**52.**
```
$ tr '[:digit:]' '#' < data/digits.txt
id-####  id-####  id-####  ID-####  id_####  id.####
```
One command because it is a pure character map with no context: every digit, everywhere,
unconditionally. A pattern tool has to be told how many digits and where, and `sed 's/[0-9]/#/g'` is
longer, slower and easier to get wrong. When the job really is "these characters become those
characters", `tr` is not a compromise, it is the right answer.

**53.**
```
$ tr -d '\n' < data/prose.txt | fold -w1 | sort | uniq -c | sort -rn | head -5
     50
     24 e
     22 t
     20 a
     18 h
```
The most common character is the **space**, by double. Not a surprise once you see it — English words
average under five letters, so roughly one character in six is a space — but almost nobody predicts it,
because we do not read spaces. The letter order after it (e, t, a, …) is the standard English
frequency order, which is a decent sanity check that your pipeline is measuring what you think.

**54.** Good: `tr` composes with **anything**. It never cares whether its input is a file, a pipe, a
process substitution, a device or a network stream, so it drops into any position of any pipeline
without a special case. Annoying: you cannot write `tr ... file1 file2`, so processing several files
means a loop or a `cat`, and you cannot edit a file in place — `tr ... < f > f` truncates `f` before
`tr` reads it, exactly like `sort` in lesson 01, and `tr` has no `-o` to save you.

**55.** `tr -d '\r' < in > out` streams: constant memory regardless of the 12 GB, one pass, and it
starts producing output immediately. An editor loads the whole file, which needs 12 GB of memory it
probably does not have, and takes minutes before it can do anything. On power loss the `tr` version
leaves a truncated but valid `out` and an **untouched** `in`, so you rerun it; an in-place editor save
can leave you with neither. The one cost is disk: you need room for both files at once.

---

## Authoring notes

- `notes/rot13.txt` is **stored rot13'd** by `setup.sh` (`tr 'A-Za-z' 'N-ZA-Mn-za-m' > notes/rot13.txt
  <<'NOTE'`). The plaintext must not appear anywhere in the lab, or exercise 41 is decoration.
- Exercise 9 is the payoff for lesson 02 exercise 49, whose measured answer was a wrong-looking
  fourteen. Here it measures **empty**. The two lessons must keep this pairing.
- `tr -d '[:cntrl:]'` collapsing the file to one line (exercise 22) is measured, not asserted, and it
  is the strongest argument in the lesson for the keep-set principle. Do not soften it.
- `data/prose.txt` was checked to have **no blank lines**, which is why exercise 35 constructs its own
  input rather than pretending the prose file needs squeezing.
- Exercise 37's difference is exactly five, and the five places are identifiable: four punctuation
  runs plus the trailing newline. Verified with `tr -c '[:alpha:]' '\n' | grep -n '^$'` → lines
  11, 21, 26, 36, 59.
- The account counts in `data/log-accounts.txt` match the access log of lessons 01 and 02
  (412/96/54/21/12/4/1), shuffled deterministically so it is not sorted.
