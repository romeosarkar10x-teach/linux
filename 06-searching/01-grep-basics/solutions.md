# 06/01 — Solutions: `grep` Basics

Every number here was measured in the container against the seeded lab (GNU grep 3.12).
Students must not read this file.

`L=logs/comms-2187-06-10.log` throughout.

## Warmup

**1.** `grep -c 'ERROR' $L` → **20**.

**2.** `ERROR` 20, `Error` 20, `error` 20; sum 60. `grep -ci 'error' $L` → **60**. They agree because
the three spellings are on disjoint lines (the generator cycles them).

**3.** Both answers are defensible; the reasoning is graded, not the verdict. `-i` gives 60 and hides
that the log uses three spellings for one severity — which is itself a finding about the writer of
the log, not about the station. A student who says "`-i` is right for finding all of them, wrong for
counting them, because 60 is one number over three conventions" has it.

**4.** No matches. `echo $?` → 1. A wrong filename gives 2 *and* a message; an unreadable file gives
2 and a different message. Status distinguishes them without reading the message.

**5.** Both → `rc=1`. Correct because "no match" is one condition, not two: an empty file has no
matching lines for exactly the same reason a full file with no matches has none. `grep` reports what
it found, not how much it read.

**6.** `grep: logs/nosuch.log: No such file or directory`, `rc=2`. A script testing only
`if grep -q …` treats 2 the same as 1 — "no errors in the log" — when the truth is "there was no
log". This is the single most common `grep` bug in shell scripts.

## Pattern, file, shell

**7.** `grep comms ERROR logs/comms-…` = pattern `comms`, files `ERROR` and the log. Output:
```
grep: ERROR: No such file or directory
logs/comms-2187-06-10.log:2187-06-10 00:00:00  comms  INFO   traffic nominal
…
```
The first non-flag word is always the pattern.

**8.** `grep -e comms -e ERROR $L`, or `grep 'comms.*ERROR' $L` / `grep 'ERROR' $L | grep 'comms'`.
Accept any that expresses one search rather than two files.

**9.** `.` is "any character", so `0.06` also matches `0x06`, `0-06`, and — here — `0:06` inside
timestamps: 13 lines. `-F` makes it literal: 0. The honest answer to "how many lines mention 0.06"
is **0**, and the lesson is that the 13 was never about 0.06.

**10.** `-F` switches off the whole regex engine, not just `.`. `[13]` is a bracket expression
matching one character; literally there is no `deck-0[13]` in the file. 30 vs 0.

**11.** Both → **19**. The pattern happens to be followed by a digit everywhere it appears, so `.`
matching a space or a `,` never fires. Agreement on one file is not a property of the pattern; it is
a property of the data. Change the data and the numbers separate.

**12.** `grep '-v' notes/handover.txt` — the quotes are gone before `grep` runs, so `grep` parses
`-v` as the *invert* flag. That leaves one non-flag word, which is the **pattern**: `grep` is now
searching for the string `notes/handover.txt`, with no file, so it reads **stdin** — your terminal.
It looks like a hang. Ctrl-D ends it (Ctrl-C also
works and is what most people reach for).

**13.** `grep -e '-v' notes/handover.txt` or `grep -- '-v' notes/handover.txt`. Both print:
```
-v is not a flag we use here. It is a note somebody left, and this line
```
In a script where the pattern comes from a variable, `-e "$pat"` is correct: it is unambiguous even
if the variable is empty, whereas `--` still leaves an empty pattern in argument position.

**14.** `logs/comms-2187-06-10.log:` — added by `grep`, because it was given more than one file.

**15.**
```
logs/comms-2187-06-10.log:20
logs/empty.log:0
logs/panel-2187-06-10.log:0
logs/strain-2187-06-10.log:0
```
More useful for "which file", less useful for "how many". The zeros are the point: they prove those
files were searched, which a single total cannot.

**16.** `-h`. **17.** `-H`; you want it when the output feeds something that will later need to know
where a line came from, or in a script that sometimes gets one file and sometimes many.

**18.** `grep: logs: Is a directory`, status **2**. Not a match failure.

**19.** `grep` is reading **stdin**; the shell opened the file. `grep` has no name to print, which is
where exercise 14's prefix came from: `grep` prints filenames it was *given*, not files it read.

**20.** Exactly: `grep: notes/binary.dat: binary file matches` — lowercase, on **stderr**, status 0.
It refuses because printing arbitrary bytes to a terminal can leave it in a broken state. `-a` (or
`--text`) overrides.

**21.** 25 bytes: `strain readings, packed\n` is 24, so the NUL is byte 25, at the start of line 2.
The file is 55 bytes.

## Exit status

**22.** 0 and 1. `-q` exits at the first match without reading the rest of the file and without
formatting output — on a large file that is a real speed difference, not just tidiness.

**23.** `grep -q 'ERROR' "$f" && echo 'errors present' || echo 'clean'` — with the caveat that the
`||` branch also fires on status 2.

**24.**
```bash
if grep -q 'ERROR' "$f"; then echo matched
elif [ $? -eq 1 ]; then echo 'no match'
else echo unreadable; fi
```
The robust form captures the status first: `grep -q 'ERROR' "$f"; rc=$?; case $rc in 0) …;; 1) …;;
*) …;; esac`. Accept either; prefer a student who noticed that `$?` changes after `elif` runs.

**25.** `rc=2`, unchanged. The trap: `-s` removes the evidence and keeps the failure, so a script
that suppresses messages and tests truthiness now silently reports "clean" for a missing file.

**26.** `chmod 000 scratch/x; grep 'a' scratch/x; echo $?` → `grep: scratch/x: Permission denied`,
status **2**. `grep 'a' scratch/x 2>/dev/null` prints nothing → stderr.

## `-f` and `-e`

**27.** **80**. The lines of the pattern file combine as **alternatives** (OR), and a line matching
two of them is still one line.

**28.** `grep -c -e 'ERROR' -e 'WARN' -e 'downlink' $L` → 80.

**29.** 60 → adding `-e 'INFO'` gives **200**, not 240. The trap is that `-e 'ERROR'` is
case-sensitive: it covers the 20 upper-case lines only, so the 20 `Error` and 20 `error` lines are
still missing. A student who predicted 240 assumed the five severities partition the file — they do,
but three of the patterns for them are spelled one way and the data three ways. Verified: 200.

**30.** `1`. Counting is per line, not per match.

**31.** **240**. The empty pattern matches every line, so one blank line in a pattern file silently
turns the whole search into `cat -n`-with-a-count. This is a real production failure mode: a pattern
file built by a script that emitted a trailing newline.

**32.** You counted **lines** — `grep -c ''` is `wc -l` with a different bug profile (it counts a
final unterminated line, which `wc -l` does not). Cheapest thing it tells you: whether the file has
any content at all, without reading it into a pager.

## Crew file

**33.** `grep 'deck-03' crew.txt` → 16 lines; `grep -c` → **16**. Named crew on deck-03: `rhea` and
`bex`.

**34.** `grep 'cass'` → the line; `grep 'CASS'` → nothing, status 1. Fix by pattern: `grep '[Cc]ass'`
(lesson 03 territory, accept it). Fix by comparison: `grep -i 'CASS'`.

**35.** `grep 'rhea' crew.txt` → **1** line. There is no `rhea2` or `xrhea` here, so the distinction
does not matter *in this file* — and the way to know that is to count (`grep -c 'rhea'` = 1), not to
assume. `grep -w 'rhea'` and `grep '^rhea:'` are both right and both belong to later lessons.

**36.** 60 − 16 = **44**; `grep -vc 'deck-03' crew.txt` → **44**. Agreement is the check.

**37.** `grep -c "deck-0$n" crew.txt` for n=1..4 → 14, 15, 16, 15; sum 60, so four decks. Wrong tool
because you had to already know the deck names to count them — `grep` cannot enumerate what it has
not been told to look for. Chapter 7 (`cut`/`sort -u`/`uniq -c`) fixes it.

## Experiment

**38.** No-final-newline is a red herring: `printf 'a\nb' > scratch/x; grep -c a scratch/x` → 1 and
`grep a scratch/x | wc -l` → 1. They agree. The property is **binary**: on `notes/binary.dat`,
`grep -c 'ERROR'` prints 1 while `grep 'ERROR' notes/binary.dat | wc -l` prints **0**, because the
"binary file matches" notice goes to stderr and no line reaches the pipe.

**39.** (a) A line containing a literal `a` preceded by `\r`, or padded so the terminal overwrites
it — the terminal lies. (b) `grep -i 'a'` on a line containing only `A`; or `grep 'a'` where the
pattern was meant literally but the file contains a character the locale folds. Accept any
construction the student can demonstrate.

**40.** **40**. Every line matches itself, so the output is the file. Slow because `grep` builds an
automaton from 40 patterns and tests every line against all of them — 1,600 comparisons for a job
that looks like one. This is how a `grep -f big-file big-file` takes minutes at real scale.

**41.** No measurable difference; both are dominated by process startup on 240 lines. To see it you
would need a large input (tens of MB) and a pattern with real backtracking cost, plus a warm page
cache and more than one run.

**42.** `grep -ril 'panel' .` → `./logs/panel-2187-06-10.log` and `./notes/handover.txt` (plus a
`Permission denied` on any file the student chmod'd in exercise 26). `-l` stops at the first match
per file.

## Stretch

**43.** Both → **20** here. They differ when the two words appear in the other order, or on the same
line but with `relay` before `ERROR`: `printf 'relay ERROR\n' > scratch/y` — the pipeline matches it,
`'ERROR.*relay'` does not. `.*` imposes order; a pipeline does not.

**44.** No match, status **1**. `grep` does not care about length; a pattern longer than the line
simply cannot match it.

**45.** `:` literal colon, `0` literal zero, `$` end of line — so the filter drops lines whose count
is exactly zero. Without `$`, `':0'` would also drop `…:10` and `…:0…`. Students are expected to
guess `$` and verify by constructing a `:10` case.

**46.** `grep 'Panel 0*3' notes/handover.txt` → **1** line (both spellings are on the same line).
`0*` is "zero or more `0`s", which is why it covers `Panel 3` and `Panel 03`. It also matches
`Panel 0003` and `Panel 000000003` — counter-example: `printf 'Panel 0003\n' > scratch/p; grep
'Panel 0*3' scratch/p` matches. The precise pattern is `'Panel 0\?3'` (BRE) — also 1 here.

**47.** There is no run log in this lab. You would look wherever the 0400 job writes — an overnight
report directory on the deck the job runs on — and search for entries that number themselves, so
that a missing entry shows as a gap rather than as nothing. That file is the Chapter 6 incident. Do
not say more.

**48.** Same answer (60) because the data is ASCII. Locale changes case folding only for characters
whose upper/lower mapping is locale-dependent — Turkish dotless `ı`/`I`, or `İ`; with ASCII input
every `C` and every UTF-8 locale fold identically, so the case cannot be built without non-ASCII
bytes.

## Dig

**49.** `grep -r 'ERROR' .` → **22** matching lines on stdout plus
`grep: ./notes/binary.dat: binary file matches` on stderr. `-I` skips binary files entirely; here
the stdout count stays 22 (the binary file contributed no printed line either way) and the stderr
noise goes away. That is the honest answer: `-I` cleans the *messages*, not the counts. `2>/dev/null`
also silences it, and is worse, because it would hide a `Permission denied` too.

**50.** The structural property is the fixed `  comms  ` field between the timestamp and the
severity — every comms line has it, no other file does. `grep -c '  comms  ' logs/*.log` → comms
**240**, panel 0, strain 0, empty 0. So every line of the comms log carries a severity; the panel log
carries none at all. What that costs: the panel log has no severity vocabulary, so there is no
pattern that finds "problems" in it. You can only search it for values and then judge them yourself
— which means a panel fault cannot be found by `grep` unless you already know what number is wrong.

**51.** `grep -c '2187-06-10' $L` → 240, and `grep -c " $h:" $L` for each hour 00–23 → **10** each,
so every hour of the day has exactly ten entries and 24×10 = 240 accounts for the file. That proves
coverage and uniform density. It does **not** prove the six-minute claim: `grep` matches lines
independently and has no notion of the distance between two matches, so ten entries in an hour is
equally consistent with ten entries in the first minute. Ordering and gaps are Chapter 7's job.

**52.** `notes/handover.txt` line 5: `-v is not a flag we use here.` In that file it is **data** — a
line of prose that happens to begin with a dash — and the only reason it matters is that passing it
to `grep` as a pattern makes `grep` read it as an option. The instruction/data confusion is the
whole point of `-e` and `--`.

## Authoring notes

- The comms generator cycles severity on `10#$i % 12`, so 20/20/20 for the three `error` spellings
  is exact, not approximate. If the line count ever changes, exercises 1, 2, 27, 29 and 31 all move.
- Exercise 9's 13 lines come from timestamps (`0:06`), not from readings. Verified.
- Exercise 11's 19 is data-dependent and stated as such in the answer.
- `notes/binary.dat` is 55 bytes with the NUL at offset 25 (start of line 2). Exercise 21 depends on
  the header string length; do not reword the header.
- Exercise 38 is the only place in the chapter where stderr-vs-stdout is load-bearing. Keep it.
