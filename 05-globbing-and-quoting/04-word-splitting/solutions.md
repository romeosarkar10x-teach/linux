# 05/04 — Solutions (agent eyes only)

> **Student: do not open this file.**

All measured in the container (bash 5.2.21). `count.sh` prints `argc=N` then each argument bracketed.

## Warmup

**1.** `printf '%q\n' "$IFS"` → `$' \t\n'`. Space, tab, newline.

**2.** Unquoted: `argc=2`, `[a]` `[b]`. Quoted: `argc=1`, `[a  b]`. The second space did not "go"
anywhere — the run of two spaces was one separator, and separators are not part of any field.

**3.** `+ printf '[%s]\n' a b` — two separate words. bash requotes its trace output, so anything it
prints unquoted is a word with no special characters in it; a word with a space would appear as
`'a  b'`. That requoting is what makes `set -x` a reliable instrument.

**4.** The splitting *did* happen — `echo` received two arguments — and `echo` joins its arguments
with exactly one space when printing. The output tells you nothing about the input spacing, which is
why `printf '[%s]\n'` is the better instrument.

**5.** Word splitting is not performed on the right-hand side of an assignment. It is one of the
handful of contexts where the shell does not split (with `[[ ]]`, `case`, `$(( ))`). Quoting there
is harmless but unnecessary.

## IFS mechanics

**6.** `a:b:c` → 3. `a:::b` → **4**: `a`, ``, ``, `b`. Measured. In exercise 2 the two spaces
collapsed; here the three colons did not.

**7.** A run of `IFS` **whitespace** characters counts as a single separator, and leading and
trailing runs are discarded entirely; every other `IFS` character is a separator in its own right,
so two adjacent ones delimit an empty field.

**8.** `a:b:` → **2**. The trailing separator does not create a trailing empty field. (Contrast with
exercise 6's *interior* empty fields, which are kept. This asymmetry is real and worth naming.)

**9.** `argc=1`, `[a  b]`. `IFS=` turns splitting off completely.

**10.** `argc=1`, `[a b c]`. The space is no longer in `IFS`, so it is not a separator — it is just
a character in the field.

**11.** `unset IFS` → splitting behaves as if `IFS` held the default space/tab/newline (`n=2` for
`a  b`). That is different from `IFS=`, which is an *empty* value and disables splitting. Unset and
empty are not the same thing here, which is unusual for a shell variable.

## Whitespace that lies

**12.** `wc -w` → 11; `set -- $(cat …); echo $#` → 11. They agree here, because `wc -w` and the
default `IFS` both count whitespace-delimited runs. They would stop agreeing the moment a glob
character appeared in the file, because the `set --` path also globs. Agreement is a coincidence of
this data, not a general fact — say so.

**13.** `[third line has leading spaces]` — for line 3, and for line 1 the leading and trailing
spaces are both gone. `read` stripped them.

**14.** `[   third line has leading spaces]` — preserved.

**15.** `read` strips leading and trailing `IFS` **whitespace** from the line before assigning. With
`IFS=` there is no whitespace in `IFS`, so nothing is stripped. `-r` is unrelated — it governs
backslash handling, not whitespace.

**16.** `read -r l` → `[first line ends in a backslash \]`. Plain `read l` →
`[first line ends in a backslash second line	has a real tab in it]` — the trailing backslash was a
line continuation and it silently swallowed line 2, tab and all. Measured.

**17.** `-r` makes `read` treat backslash as an ordinary character. Without it, backslash escapes the
next character and a backslash immediately before the newline continues the line. There is
essentially no situation in which you want the default.

**18.** Default `IFS` includes tab, so a tab-separated line splits into its fields either way for
single tabs. Build `a<TAB><TAB>b` in `scratch/`: default `IFS` gives 2 (tabs collapse, they are
whitespace); `IFS=$'\t'` gives **3**, because now the tab is the only separator and it is still
whitespace — so it *also* collapses. To get the empty field you need a non-whitespace separator.
This is a good place for a student to discover that `IFS=$'\t'` does **not** give you TSV semantics.

**19.**
```
while IFS= read -r line; do …; done < data/spaced.txt
```
5 lines. `IFS=` protects leading/trailing whitespace; `-r` protects backslashes; the redirect at
`done` avoids the subshell you get from `cat file | while …`, so variables set in the loop survive.

## Fields and records

**20.** `IFS=: read -r n r d j <<< "$(head -1 data/crew.csv)"` → `[rhea][systems][deck-05][2187-04-02]`.

**21.** Three variables → `[rhea][systems][deck-05:2187-04-02]`. Measured. The **last** variable
gets all remaining fields including the separators.

**22.** Five → the fifth is empty. Extra variables are set to the empty string, not left unset in
any observable way.

**23.**
```
while IFS=: read -r name role deck joined; do
    printf '%s %s\n' "$name" "$deck"
done < data/crew.csv
```

**24.** `cut -d: -f2 data/crew.csv` → `systems comms power galley hull`. `cut` is better when you
want one column and nothing else; the `read` loop is better when you need several fields together,
because `cut` would require a second pass and re-joining them.

**25.** `[ "$deck" = deck-05 ] && printf …` inside the loop → rhea and mikko.

**26.** The empty field stays in position 2 and `role` is the empty string. It works because `:` is
non-whitespace `IFS`, so adjacent separators delimit an empty field — exercise 6's rule doing
useful work for once.

**27.** The extra colon lands in the **last** variable, per exercise 21. For a trailing free-text
field that is usually exactly right. For a fixed-width record it means a corrupt line parses
silently, which is the argument for validating field counts with `read -ra` and `${#parts[@]}`.

**28.** `mapfile -t lines < data/crew.csv` → 5 elements. Third is the `mikko` line.

**29.** `IFS=: read -ra parts <<< "$line"` then `count.sh "${parts[@]}"` → `argc=4`.

## `$@`, `$*` and arrays

**30.** Measured with `'a b'` and `c`: `"$@"` → 2 (`[a b]` `[c]`); `$@` → 3; `"$*"` → 1 (`[a b c]`);
`$*` → 3.

**31.** `"$@"` preserved the boundaries and it is the only one to write.

**32.** The first character of `IFS`, normally a space. With `IFS=:`, `echo "$*"` → `a:b:c`.
Measured.

**33.** `"${arr[@]}"` → 2 (`[bay 01]` `[bay 02]`). `${arr[@]}` → 4 (split). `"${arr[*]}"` → 1
(`[bay 01 bay 02]`). Exactly the `$@`/`$*` table, because `$@` *is* the positional-parameter array.

**34.** `"$@"` is `"${arr[@]}"` where the array is the positional parameters; the quoting rules are
identical and for the same reason.

**35.** `count.sh "" x ""` → `argc=3` with two empty arguments. An unset variable unquoted →
`argc=1` (just `x`) — the empty expansion produced **no word at all**. Quoted, `"$u"` → `argc=1`
with one empty argument. This is the difference between "an empty argument" and "no argument", and
it is why `[ "$e" = x ]` works and `[ $e = x ]` does not (exercise 50).

## Loops over things with spaces

**36.** `for d in bays/*/` → **8**. `for d in $(ls bays)` → **11**. Measured. The three names with
spaces each split into two words.

**37.** The glob handled them; `$(ls …)` did not. Note carefully: the `for` list needed no quoting
because glob results are not word split, but `printf '[%s]\n' "$d"` inside the loop *did* need it,
because `$d` is an ordinary parameter expansion. Two different rules, one loop.

**38.**
```
for d in bays/*/; do printf '%s %s\n' "$d" "$(wc -l < "$d/readings.txt")"; done
```
Eight lines, every count 2.

**39.** **9** iterations for a 5-line file. Two causes: the two paths containing `deck 05` and
`bay 01`/`bay 02` split into three words each (+4), and — the second cause students miss — nothing
globbed here, but the mechanism is live: any path containing `*` or `?` would then be pathname
expanded. On this data the count is entirely from splitting: 5 − 2 + 6 = 9. A student who says
"splitting plus globbing" and then checks that no globbing actually occurred has done the exercise
properly.

**40.** 5, with `/labs/deck 05/bay 01` intact as one string.

**41.** `IFS=$'\n'; set -- $(cat …); echo $#` → 5. Measured, and `$3` is `/labs/deck 05/bay 01`.
Still vulnerable to **pathname expansion** — a line containing `*` would be globbed — and to
command substitution stripping trailing newlines. The `while read` loop has neither problem.

**42.** `xargs -n1 echo | wc -l` → **11**; `-print0` with `xargs -0` → **8**. Eight is right.
`-print0` terminates each path with a NUL byte, which cannot appear in a filename, so there is no
ambiguity for `xargs -0` to get wrong. Whitespace and newlines in names become harmless.

## Fixing real scripts

**43./44.** `tally.sh` passes `$*`, unquoted. `bash scripts/tally.sh 'bay 01' bay-02` →
`argc=3`, `[bay]` `[01]` `[bay-02]`. Measured. The fix is `"$@"` — change `$*` to `"$@"`. Then
`argc=2`.

**45./46.** Measured with `data/paths.txt`:
```
cp: cannot stat '/labs/deck': No such file or directory
cp: cannot stat '05/bay': No such file or directory
cp: cannot stat '01': No such file or directory
… same three for bay 02 …
```
and `scratch/dst` ends up with **3** entries — the three real paths copied fine, the two with
spaces produced six bogus arguments.

**47.** Four things:
- `while read line` → `while IFS= read -r line`: no `-r`, no `IFS=`.
- `cp -r $line $DEST/` → both unquoted.
- **Not about quoting:** the loop's stdin is the same stdin `read` is consuming, and any command
  inside the loop that reads stdin — `cp` does not, but the next thing somebody adds will — eats the
  rest of the list. The idiomatic guard is `< /dev/null` on such commands, or `read … <&3` with the
  list on fd 3. A student who instead names "no error handling / no check that `$DEST` is set" has
  found a real defect too; accept either, but the fd point is the one intended.
- No `--` before `$line` (see 49).

**48.**
```
DEST=$1
while IFS= read -r line; do
    cp -r -- "$line" "$DEST/" </dev/null
done
```
Verification: exactly two errors now, each naming the whole path
(`cp: cannot stat '/labs/deck 05/bay 01'`), and three successful copies.

**49.** A leading dash makes `cp` read the path as options — the same command-level failure as
`-report.txt` in lesson 3 and `-dash.txt` in lesson 1. `--` fixes it, or prefixing `./`. Quoting
does not, and cannot.

## Experiment

**50.** `v='a b'`: `[: too many arguments`, exit **2** — the shell built `[ a b = a b ]`. `v` unset:
`[: =: unary operator expected`, exit 2 — the shell built `[ = x ]`, three words where `[` expected
either two or four. Quoted: a real comparison, exit 0 or 1. Measured, including `[ "$e" = x ]` → 1.

**51.** All three behave. `[[ ]]` is shell **syntax**, not a command: the shell parses it before any
expansion and knows that the thing on the left of `=` is one operand no matter what is in it. `[ ]`
is a real program (`/usr/bin/[` exists) that receives already-split arguments and can only count
them.

**52.** Arithmetic expansion does not word split its contents; it parses them as an arithmetic
expression, in which whitespace is insignificant. `v` is even dereferenced without a `$`. Different
language, same shell.

**53.** The no-split contexts: `[[ ]]`, `case` word, `$(( ))`, right-hand side of an assignment,
and (for a different reason) the results of pathname expansion. Everything else splits.

**54.** Measured: `( IFS=:; … )` — inside `:`, outside `$' \t\n'`, no leak (subshell). A function
with `local IFS=:` — after the call, `$' \t\n'`, no leak. A bare `IFS=:` in a function with no
`local` **leaks** and poisons every subsequent unquoted expansion in the shell, which is a
spectacularly hard bug to find. Only the third leaks.

**55.** It prints **one** line, `[]`, with zero arguments. Measured. `printf` applies its format at
least once even with no arguments, supplying the empty string for `%s`. This is a `printf` fact, not
a splitting fact, and the distinction is the point of the exercise: `count.sh`'s `argc=0` is the
truthful part of its output and the bracket line is the lie.

## Stretch

**56.** The naive loop gives **1** for a two-line file with no final newline: `read` returns nonzero
on the last line because it hit EOF before a delimiter, even though it assigned the text. Fix:
```
while IFS= read -r l || [ -n "$l" ]; do …; done
```
→ 2. Measured.

**57.** `-d ''` sets the delimiter to the NUL byte (bash takes the first character of the argument;
an empty argument means NUL). Measured with `printf 'a\0b\0'` → `[a]` `[b]`. It is fully safe
because NUL is the one byte that cannot occur in a filename, so a NUL-delimited stream is
unambiguous where a newline-delimited one is not.

**58.**
```
find bays -mindepth 1 -maxdepth 1 -type d -print0 |
while IFS= read -r -d '' d; do
    [ "$(wc -l < "$d/readings.txt")" -gt 1 ] && printf '%s\n' "$d"
done
```
All eight qualify. Accept `find … -exec sh -c … {} +` variants.

**59.** `s='a b:c d:e'`; `set -- $s; echo $#` → 5 words with the default `IFS`;
`IFS=: ; set -- $s; echo $#` → 3 fields. Same string, two separators, two truthful answers. The
question is only ever "what did `IFS` say" — there is no intrinsic word count.

**60.** Expansion order: parameter expansion produces `* x`, word splitting produces `*` and `x`,
then pathname expansion runs on the resulting words and `*` becomes every file. Measured in a
directory with two files: `argc=3` (`a.txt`, `b.txt`, `x`). `"$v"` short-circuits both steps: one
word, and quoted words are never globbed. This is exercise 51 of lesson 3, stated as a sequence.

## Dig

**61.** A list assembled by concatenating output from two different sources, or by hand from a
document, without ever testing that the paths resolve. The entries with spaces are the tell:
whoever built the list was working from a human-readable label (`deck 05`, `bay 01`) rather than
from the filesystem, where those things are named `05-…` and `bay-01`. A list built by `find` cannot
contain a path that does not exist; a list built by typing can.

**62.** `deploy.sh` fails **loudly** — five `cp: cannot stat` lines on stderr. `tally.sh` fails
**quietly** — it produces a plausible-looking count that is simply wrong, with exit 0. The quiet one
is far worse to find at three in the morning, and it is the one that would still be wrong a year
later. This is the same lesson as `grep "$SPEC_DIR"` in 05/03 exercise 29.

**63.** Operated on: the three real paths, and only because they contain no spaces. Silently
skipped: nothing — that is the point, `deploy.sh` does not skip, it **invents** — the two space
paths became six nonexistent paths and produced errors, not silence. A student who writes "it would
have operated on `/labs/deck`, `05/bay` and `01` as three separate targets" has understood the
danger exactly: an unquoted path list does not lose entries, it manufactures them, and a
manufactured entry that happens to exist gets acted on. Do not accept a two-list answer that ignores
the manufacturing.

**64.** Three of the eight `bays/` directories have spaces in their names, so no, the rule is not
being followed. Finding out when it stopped: `ls -ld --time-style=full-iso 'bays/bay '*` and compare
mtimes against the hyphenated ones. Do not let a student conclude anything about *who*; the lab does
not record it and no agent may supply it.

## Notes for the authoring/tutor agent

- Exercise 6/7 (whitespace collapses, non-whitespace does not) is the load-bearing fact. Everything
  about `read`, CSV parsing and empty fields follows from it.
- Exercise 39's arithmetic — 5 − 2 + 6 = 9 — is worth walking through by hand with a student who
  gets a different number; it is the clearest possible demonstration that splitting is per-word, not
  per-line.
- Exercise 47's fd point is subtle and a student who finds a different fourth bug should be credited.
- Nothing in this lesson attributes the broken scripts or the bad path list to any named person, and
  no agent may. `crew.csv` names five crew; none of them is connected to `scripts/`.
