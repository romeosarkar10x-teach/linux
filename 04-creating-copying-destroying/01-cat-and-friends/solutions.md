# 04/01 — Solutions (agent eyes only)

> **Student: do not open this file.** It contains every answer. There is no flag in this lesson, but
> there is nothing else here worth having either if you read it first.

## The shape of the lab

Read-only material in three directories, each aimed at one failure of naive reading:

- `logs/comms-0517.log` — 120 lines, six of them blank, at lines **17, 43, 60, 61, 62, 88**. The run
  of three (60–62) is for `cat -s`; the six total are the `cat -n` vs `nl` disagreement.
- `logs/deck3-strain.csv` — 41 lines (header + 40 rows), longest line **314** characters. For `less`
  wrap vs `-S`.
- `logs/roster.txt` — exactly 5000 lines, `crew NNNN  deck D  shift S`. Line 1 is
  `crew 0001  deck 2  shift 2`; line 5000 is `crew 5000  deck 3  shift 3`; line 2500 is
  `crew 2500  deck 5  shift 2`. `crew 4242` occurs **once**.
- `logs/panel-07.log` — 12 lines, LF-terminated, last line `2187-05-17 08:03  panel-07  idle`.
- `notes/no-newline.txt` — **58 bytes, 0 lines by `wc -l`**, no trailing newline.
- `notes/tabs.txt` — real tabs. `notes/crlf.txt` — CRLF. `notes/mixed.txt` — one `0x07` BEL and one
  `0xE9`. `notes/blank-run.txt` — `before`, nine blanks, `after` (11 lines).
- `fragments/03-tail.txt` is stored last-line-first. The other two are in order.
- `feed/` is empty at seed; exercises 29–31 and 35 create files in it.

Nothing here is a sabotage trace. The 2187-05-17 date is the day the Chapter 4 manifest was written,
and is set dressing until lesson 05.

## Captured reference output

```
$ wc -l logs/comms-0517.log logs/panel-07.log logs/deck3-strain.csv logs/roster.txt \
        notes/blank-run.txt notes/crlf.txt notes/mixed.txt notes/no-newline.txt notes/tabs.txt
   120 logs/comms-0517.log
    12 logs/panel-07.log
    41 logs/deck3-strain.csv
  5000 logs/roster.txt
    11 notes/blank-run.txt
     3 notes/crlf.txt
     2 notes/mixed.txt
     0 notes/no-newline.txt
     4 notes/tabs.txt

$ cat -n logs/comms-0517.log | tail -1      ->  120  2187-05-17 20:00  comms  channel 4 handshake ok
$ nl     logs/comms-0517.log | tail -1      ->  114  2187-05-17 20:00  comms  channel 4 handshake ok
$ grep -n '^$' logs/comms-0517.log | cut -d: -f1 | tr '\n' ' '   ->  17 43 60 61 62 88
```

## Per exercise

**1.** 12 lines; last is `2187-05-17 08:03  panel-07  idle`. `wc -l logs/panel-07.log` → 12.

**2.** `tac` reverses the *order of lines*. It does not reverse the characters within a line. (`rev`
does that; it is in the image and is not part of this lesson.)

**3.** Ten lines each. Documented in `man 1 head` / `man 1 tail` under `-n`: "print the first/last 10
lines" is the default.

**4.** `cat -T` renders each tab as `^I`, so the student can see there are three tabs per line and
not a variable number of spaces. Plain `cat` renders a tab by moving the cursor to the next tab stop,
which is indistinguishable from spaces on screen.

**5.** `wc -l` counts **newline characters**, not lines of text. `no-newline.txt` contains one line of
text and zero newlines, so the count is 0. `comms-0517.log` → 120.

**6.** `wc -c notes/no-newline.txt` → **58**. `cat` printed all 58 bytes and no newline, so the shell
prompt appears on the same line, immediately after `...end of it`.

**7.** `panel-07.log`'s last line ends with `$`; `no-newline.txt`'s does not:
```
$ cat -e notes/no-newline.txt
the last line of this file has no newline on the end of it
$ cat -e logs/panel-07.log | tail -2
2187-05-17 08:02  panel-07  shift handover$
2187-05-17 08:03  panel-07  idle$
```
Absence of the `$` means the file's final byte is not a newline — the file is unterminated.

**8.**
```
received 05-17^M$
logged 05-17^M$
filed 05-18^M$
```
The two non-letters are `^M` (carriage return, 0x0D) and `$` (`cat`'s marker for the newline). `-e`
is `-vE`; it shows the `$` but **not** the `^M`, because showing control characters is `-v`. `-A` is
`-vET` and therefore shows both.

**9.** The last character of each line is CR (0x0D), sitting immediately before the LF. A comparison
against an LF-only file differs by one byte on every line, so every line reports as changed. This is
the single most common "the file looks identical but diff says otherwise" cause.

**10.**
```
alarm test:^G and a latin-1 e-acute: M-i
done
```
`^G` is BEL (0x07) — that is the audible beep, if the terminal is configured for one. `M-i` is
`cat -v`'s notation for a byte with the high bit set: 0xE9, which is `é` in latin-1 and is **not**
valid UTF-8, which is why the plain `cat` shows a replacement character or nothing useful.

**11.** `cat -n` reaches 120; `nl` reaches 114. The six are lines **17, 43, 60, 61, 62, 88** — the
blank ones. `nl` gave them no number and did not advance its counter.

**12.** `nl -ba logs/comms-0517.log` — `-b a` numbers *all* body lines. (`-b t` is the default:
number non-empty lines only.)

**13.** `grep -c '^$' logs/comms-0517.log` → 6. Second route: 120 − 114 = 6, from exercise 11.

**14.** `-s` is `--squeeze-blank`: it collapses any run of consecutive blank lines to a single one.
Output is three lines — `before`, one blank, `after`. The other eight blanks were suppressed. Note
`-s` never removes a *lone* blank line and never touches the file.

**15.** `head -n 20 logs/roster.txt` and `tail -n 20 logs/roster.txt`.

**16.** `head -n 2500 logs/roster.txt | tail -n 1` → `crew 2500  deck 5  shift 2`.

**17.** `head -n 4010 logs/roster.txt | tail -n 11`. Eleven lines — 4010 − 4000 + 1. The common
wrong answers are `| tail -n 10` (ten lines, ending correctly) and `head -n 4000 | tail -n 11`
(eleven lines, ending in the wrong place).

**18.** `tail -n +4990` prints **11** lines — from line 4990 to the end. `tail -n 4990` prints the
last 4990 lines, i.e. lines 11–5000. The `+` changes the number from "how many, counted back from
the end" to "start here, counted forward from the beginning".

**19.** `head -c 40` stops after 40 bytes regardless of line structure:
```
crew 0001  deck 2  shift 2
crew 0002  de
```
…with the prompt glued to `de`, because the 40th byte is not a newline. `head -n 40` always ends on
a line boundary (unless the file itself is unterminated).

**20.** `fragments/03-tail.txt`. Tell without `setup.sh`: the assembled text reads
`part one: ... part two: ... and that is the whole of part three. / the summariser accepted ... /
part three:` — the label `part three:` arrives *after* the content it labels, and the sentence
beginning "and that is the whole of" is a closing sentence sitting first.

**21.** Either is accepted:
```
cat fragments/01-head.txt fragments/02-body.txt; tac fragments/03-tail.txt
cat fragments/01-head.txt fragments/02-body.txt <(tac fragments/03-tail.txt)
```
The first is two commands sequenced; the second is one `cat` with a process substitution, which is
the honest answer to "one command". Both produce:
```
deck 3 console handover, part one:
the panel was reseated at 04:02.
part two:
self-test passed on the first attempt.
part three:
the summariser accepted the input at 06:30,
and that is the whole of part three.
```

**22.** `G` lands on `crew 5000  deck 3  shift 3`. `50g` goes to line 50 — `crew 0050  deck 3
shift 3` — because in `less` a number typed before `g` is a line number.

**23.** `/crew 4242` lands on `crew 4242  deck 1  shift 1` (line 4242). `n` reports `Pattern not found` (it does
not wrap by default), which proves there was exactly one match. `grep -c 'crew 4242'` → 1 confirms it.

**24.** Wrapping continues a long line onto the next screen row, so one CSV row occupies four rows of
screen and columns do not line up. `-S` truncates at the screen edge instead and the right arrow
scrolls the view sideways, so every row stays on one screen line and the columns align. For a wide
CSV you want `-S`.

**25.** First: **24** — `cat` concatenated two 12-line files and each was newline-terminated. Second:
```
the last line of this file has no newline on the end of it2187-05-17 04:02  panel-07  power on
2187-05-17 04:03  panel-07  self-test start
```
The first output line is the *whole* of `no-newline.txt` plus the *whole* of the first line of
`panel-07.log`, glued. `cat` does not insert separators; it concatenates bytes. This is the point of
the whole exercise and of the tool's name.

**26.** With no arguments `cat` reads standard input and writes it to standard output, line by line
as the terminal delivers them. `cat -n` numbers them as it goes. Ctrl-D is not a character in the
stream: it makes the terminal driver deliver the input buffered so far, and when the buffer is empty
it makes `read()` return 0 — end of file. That is why Ctrl-D on a half-typed line does not end
anything the first time.

**27.** `tac notes/no-newline.txt` output ends **without** a newline:
```
0000060       e   n   d       o   f       i   t
```
`tac logs/panel-07.log` ends **with** one (`p o w e r   o n \n`). `tac` reverses the order of the
records it found; it does not add or remove terminators. If the input's last record was unterminated,
the output's last record is too — but note it is now the *first* thing printed, so the effect is
invisible unless you look at the bytes.

**28.** `head -n -3 logs/panel-07.log` prints **9** lines: everything except the last three. That is
the surprising one. `tail -n -3` prints the last three — identical to `tail -n 3`, because for `tail`
a leading `-` is just the default direction spelled out. So the same `-N` means "all but the last N"
to `head` and "the last N" to `tail`.

**29.** Terminal A prints `two` and then nothing further. `rm` removed the *name*; `tail -f` still
holds the inode open, and the new `feed/live.log` is a different inode that nothing is watching.
`tail -F` (= `--follow=name --retry`) prints `two`, then reports
`tail: 'feed/live.log' has been replaced;  following new file`, and then usually prints `three`.

**Timing-dependent, and measured:** if the recreation follows the `rm` closely, `tail -F` notices the
replacement only after the write and resumes at the *end* of the new file, so the message appears but
`three` does not. Leave a second or two between the `rm` and the recreation, or append a further line
afterwards, and `three` (and anything after it) appears. Accept either observation, provided the
student reports the replacement message; the point is the message, not the line. The version with
`tail -f` never prints anything after `two` under any timing.

This is exactly the Chapter 3 name-versus-inode distinction, now with a consequence: log rotation is
why `-F` exists.

**30.** Both followers get every line from the moment they start; the third one starts by printing
the last ten lines already in the file and then keeps up. Each `tail -f` has its own open file
description and its own offset, so they do not compete — reading a file does not consume it. Contrast
with the FIFO in Chapter 3 lesson 05, where two readers *did* split the stream.

**31.** `tail` prints a header of the form `==> feed/a.log <==`, preceded by a blank line, before a
block of lines, and prints a
new one only when the file it is about to print from is different from the last one it printed from.
Alternating appends therefore produce alternating headers; two appends to the same file in a row
produce one header.

**32.** `grep -n 'channel 3' logs/comms-0517.log` — `-n` prefixes each match with its line number in
the *original* file. Other accepted routes: `nl -ba logs/comms-0517.log | grep 'channel 3'`, or
`cat -n ... | grep ...`. The failure to catch is `grep ... | nl`, which numbers the matches.

**33.** `(head -n 1; tail -n 1) < logs/roster.txt` — one open file, `head` reads from the front,
`tail` seeks to the end. Also accepted: `head -n 1 f; tail -n 1 f` (opens the file twice — fine, as
long as the student says so), or `sed -n '1p;$p' logs/roster.txt` (one pass, reads every line).
The honesty clause is the graded part.

**34.** Any correct sequence, e.g. `/crew 1000` Enter, `ma`, `G`, `'a`. Marks are single letters and
`''` (two apostrophes) returns to the previous position, which is an acceptable alternative answer.

**35.** `less +F` can be interrupted with Ctrl-C, leaving you in a normal `less` session with the
whole accumulated file scrollable and searchable, and `F` resumes following. `tail -f` gives you no
way to look back at what has scrolled past.

**36.** The odd one is `less logs/panel-07.log | head -3`. `less` detects that its standard output is
not a terminal and degrades to acting like `cat` — so it prints the file with no paging and no
keystrokes at all, and `head -3` truncates it. The other three are ordinary: `cat | less` and
`less < file` both work (`less` reads its keystrokes from `/dev/tty`, not from standard input, which
is exactly why `cat | less` is usable at all), and `cat | head -3` is unremarkable. The lesson is
that `less` treats "am I writing to a terminal" and "am I reading a file or a pipe" as two separate
questions.

**37.** `tail` `lseek`s to the end of the file and reads a block backwards from there — typically the
last 8 KiB — counting newlines; if it has not found enough, it seeks back another block. So the cost
is proportional to the length of the last N lines, not to the size of the file. It can only do this
because the file is seekable; on a pipe `tail` has no choice but to read the entire stream and keep
the last N lines in memory. `strace` is **not installed in this image** — a student who reports that
and reasons from `man 2 lseek` has done the exercise correctly.

**38.** `nl -n rz -w 4 -s ' | ' -i 10 logs/panel-07.log`:
```
0001 | 2187-05-17 04:02  panel-07  power on
0011 | 2187-05-17 04:03  panel-07  self-test start
0021 | 2187-05-17 04:03  panel-07  self-test pass
```
`-n rz` is right-justified with leading zeros (`ln`/`rn`/`rz` are the three formats). Note the
increment applies to the number, not to which lines are printed.

**39.** `tac -s $'\n\n' logs/comms-0517.log` reverses the four paragraphs and leaves each one's lines
in order; the output starts at the old line 89 (`2187-05-17 14:23  comms  channel 9 handshake ok`)
and is still 120 lines.

The trap is quoting. `tac -s "$(printf '\n\n')"` looks right and is not: command substitution strips
trailing newlines, so `tac` receives the **empty string** as its separator and prints the file
unchanged — a silent no-op that looks like "`-s` does not work". A student who reports the file came
out unchanged and then finds out why has done better than one who got it right first time.

## Added exercises 40–52

**40.** With two or more files `head` prints a header per file and a blank line between blocks:

```
==> logs/panel-07.log <==
2187-05-17 04:02  panel-07  power on
2187-05-17 04:03  panel-07  self-test start

==> notes/tabs.txt <==
deck	bay	strain
3	4	0.41
```

The blank line comes *before* each header after the first, not after the block. `head -q` suppresses
the headers; `head -v` forces one even for a single file (`==> logs/panel-07.log <==`).

**41.** `-L` is the length of the longest line, in display columns.

```
  314 logs/deck3-strain.csv
   47 logs/comms-0517.log
  314 total
```

314 is the number quoted in exercise 24: on an 80-column terminal that row occupies four screen
lines when `less` wraps it, which is why `-S` is worth having. Note the `total` line reports the
largest of the maxima, not a sum — the only `wc` field for which that is true.

**42.** `cat -n` numbers all 11 lines and ends at 11; `cat -b` numbers only the two non-blank lines,
so its highest number is 2 while the output still has 11 lines:

```
     1	before
       (nine blank lines, unnumbered)
     2	after
```

`nl` defaults to `-b t` — number non-empty lines only — which is `cat -b`, and that is exactly the
six-line disagreement of exercise 11 and the `-b a` fix of exercise 12.

**43.** `wc -c` is 43, `wc -m` is 42. `-c` counts bytes, `-m` counts characters in the current
locale, which is UTF-8. The file's `\351` is a Latin-1 é: a legal byte, but not a legal UTF-8
sequence on its own. `wc -m` does not count it as a character, so the character count comes out one
short of the byte count. Every other byte in the file is ASCII, where the two counts agree.

**44.** `man cat`: `-A` is equivalent to `-vET`. `cat -vET notes/tabs.txt` gives byte-identical
output to `cat -A notes/tabs.txt`:

```
deck^Ibay^Istrain$
3^I4^I0.41$
```

`-T` does the tab (`^I`), `-E` the line ends (`$`), `-v` the non-printing rest. So `cat -e` from
exercise 7 is `-vE` and `cat -t` is `-vT`.

**45.** `tail -c 20 logs/panel-07.log` prints the last 20 bytes — `:03  panel-07  idle` and its
newline, a mid-line start. `tail -c +5470 logs/comms-0517.log` prints from byte 5470 *to the end*,
which is `shake ok`. Same rule as exercise 18: a bare number is a count from the end, `+N` is an
offset from the beginning.

**46.**

```
cat: logs: Is a directory        # status 1
cat: notes/nope.txt: No such file or directory   # status 1
```

Both are 1. The interesting half of the prediction is the first: `cat` does not refuse to open a
directory — the `open` succeeds — it refuses to `read` one, because on Linux reading a directory
through an ordinary file descriptor returns `EISDIR`. Contrast Chapter 3, where `cat` on a device
node or FIFO behaved differently again.

**47.** Both run straight through and end at 24. `cat -n` counts lines of the output stream, so
concatenation is invisible to it. `nl` is the surprise: it has a `-p` option precisely because it
would otherwise restart at each *page*, but multiple file arguments are treated as one continuous
document, so it also reaches 24.

**48.** `wc -c f` reports **0**. The shell sets up the redirection before it execs `cat`: `> f`
truncates the file to zero length, and only then does `cat` open the same now-empty file twice and
copy nothing. This is the standard reason `cmd file > file` is never a way to edit a file in place —
the data is gone before the program that was supposed to read it starts.

**49.** 118. The file has six blank lines (exercise 13); three of them are isolated (17, 43, 88) and
three are consecutive (60–62). `-s` squeezes each *run* to one line, so only the run is affected and
it loses two lines: 120 − 2 = 118.

**50.** The round trip succeeds — `cmp` prints nothing — and `od -c` on the plain `unexpand -t 8`
output shows the interior tabs restored (`d e c k \t b a y \t s t r a i n \n`). With
`--first-only`, only leading blanks would be converted, and since this file has none, the tabs stay
spaces:

```
0000000   d   e   c   k                   b   a   y                    
```

GNU `unexpand` converts only leading blanks by default, but `-t` implies `-a` (convert all runs of
blanks), which is what made the round trip work. `--first-only` cancels that. The leading-only
default is the safer one for source code: converting interior runs of spaces to tabs silently
changes aligned comments and string literals.

**51.**

```
less -N -X +/'crew 4242' logs/roster.txt
```

`-N` shows line numbers in the left margin, `+/pattern` runs a forward search at startup and lands on
the first match (line 4242), and `-X` disables the terminal's alternate-screen switch, so after `q`
the last screenful of the file stays on the terminal instead of being wiped. `-X` is the option that
makes `less` behave like `cat` for the purpose of leaving evidence in your scrollback.

**52.** `M-` is the high bit. `cat -v` clears bit 7 and prints `M-` followed by whatever the
remaining seven bits would print as: `0xE9 − 0x80 = 0x69 = i`, hence `M-i`. So `0xE0` becomes
`M-`+`0x60` = `M-\``, and `0x80` becomes `M-` plus `0x00`, which is itself a control character, so
`cat -v` applies the caret notation on top: `M-^@`.

```
$ printf '\340\200\n' | cat -v
M-`M-^@
```

A byte that is both high-bit and control therefore gets both notations, `M-^X` — the two encodings
compose rather than one overriding the other.

## Notes for the authoring/tutor agent

- Exercise 29 needs two terminals and is the most valuable exercise in the lesson. If a student
  skips it, send them back.
- `strace` is absent by design of the base image, not by omission here. Do not tell students to
  install it.
- The `0xE9` in `notes/mixed.txt` is deliberately invalid UTF-8. How it renders under plain `cat`
  depends on the terminal; accept any description as long as the `-v` output is reported as `M-i`.
- The BEL may or may not beep depending on the terminal emulator. "Nothing audible happened" is an
  acceptable answer to exercise 10 provided `^G` is reported.
- No flag in this lesson. The chapter's only flag is in `05-incident-04`.
