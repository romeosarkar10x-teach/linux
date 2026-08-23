# 04/01 — Validation (agent rubric)

No auto-grading. An agent reads the student's transcript and notes against this file.

This lesson is read-only. A student who modified anything under `logs/`, `notes/` or `fragments/`
has not failed — nothing here depends on the state — but note it, and check they know they did it.
Creating files under `feed/` and under `/tmp` is required by exercises 29–31 and 35.

## Reference values

| Thing | Value |
|---|---|
| `logs/comms-0517.log` | 120 lines; blanks at 17, 43, 60, 61, 62, 88 |
| `logs/panel-07.log` | 12 lines; last `2187-05-17 08:03  panel-07  idle` |
| `logs/deck3-strain.csv` | 41 lines; longest line 314 chars |
| `logs/roster.txt` | 5000 lines; L1 `crew 0001  deck 2  shift 2`; L50 `crew 0050  deck 3  shift 3`; L2500 `crew 2500  deck 5  shift 2`; L4242 `crew 4242  deck 1  shift 1`; L5000 `crew 5000  deck 3  shift 3` |
| `notes/no-newline.txt` | 58 bytes, `wc -l` = 0 |
| `notes/blank-run.txt` | 11 lines; `cat -s` yields 3 |
| `notes/crlf.txt` | 3 lines, each ending `^M$` |
| `notes/mixed.txt` | `^G` and `M-i` under `cat -v` |
| `cat -n` vs `nl` on comms log | 120 vs 114 |
| `crew 4242` matches | exactly 1 |
| `strace` | **not installed** |

---

## Per exercise

**1–3 (Warmup).** *Goal:* the tools do what they say. *Accept:* 12 and the `idle` line; `tac`
described as reversing line order only; ten lines each, sourced to the man page. *Reject:* "tac
reverses the text" without the line/character distinction. *Red flag:* guessing the default of ten
instead of reading it.

**4.** *Accept:* names `^I` and says plain `cat` renders a tab by cursor movement, so tabs and spaces
are indistinguishable on screen. *Reject:* "it added symbols to the file".

**5.** *Accept:* `wc -l` counts newline characters; 0 newlines, one line of text. *Reject:* "the file
is empty" or "wc is broken".

**6.** *Accept:* 58 bytes, and the observation that the prompt sits on the same line. *Distinction:*
notices this is the same fact as exercise 5 seen from the other side.

**7.** *Accept:* `$` present on `panel-07.log`'s last line, absent on `no-newline.txt`; absence means
the last byte is not a newline.

**8.** *Accept:* exact three-line output; identifies `^M` as carriage return and `$` as the newline
marker; says `-e` would not have shown `^M` because that requires `-v` (and `-A` = `-vET`).
*Reject:* calling `^M` "a control character" with no identification. *Red flag:* thinking `^M` is two
characters, caret and M.

**9.** *Accept:* CR before LF on every line; a byte-for-byte comparison differs on every line.
*Distinction:* connects it to real "whole file changed" diffs.

**10.** *Accept:* reports `^G` and `M-i`; identifies BEL and a high-bit byte. Audible beep optional —
terminal-dependent, and saying so is better than claiming one. *Reject:* claiming `M-i` is a letter
`i` with a modifier key.

**11.** *Accept:* 120 vs 114, and the six blank line numbers **17, 43, 60, 61, 62, 88** — found, not
guessed. *Reject:* "six blank lines somewhere". *Red flag:* the numbers are right but no command is
shown for finding them.

**12.** *Accept:* `nl -ba` (or `-b a`), with the man page reference. *Reject:* `cat -n` as the
answer — the exercise asked about `nl`.

**13.** *Accept:* 6 both ways, including the 120 − 114 arithmetic.

**14.** *Accept:* squeeze-blank; 3 lines out; eight consecutive blanks collapsed into one. *Reject:*
"it deleted the blank lines" — one survives, and the file is unchanged.

**15–17.** *Goal:* line addressing arithmetic. *Accept:* ex 17 must be `head -n 4010 | tail -n 11`
and must state 11 before counting. *Reject:* `tail -n 10`, or `head -n 4000 | tail -n 11`. *Red
flag:* using `sed -n '4000,4010p'` — correct output, but the exercise said `head` and `tail`; note it
and make them do it the constrained way.

**18.** *Accept:* 11 lines for `+4990`; last-4990 for the plain form; `+` = position from the start
versus quantity from the end. *Distinction:* predicted the output volume of the second before running
it, as instructed.

**19.** *Accept:* `head -c` stops mid-line, prompt lands after `de`; `head -n` ends on a line
boundary.

**20–21.** *Accept:* identifies `03-tail.txt` from the *content order* (label after its content, a
closing sentence first), not from `setup.sh`. Ex 21 accepts either the `;` sequence or the process
substitution, as long as the student says which they used and why. *Reject:* opening `setup.sh` to
answer 20. *Red flag:* `cat ... tac file` (the near-miss in `help.md`) reported as working — it
errors *and* prints, and the printed part is in the wrong order.

**22–24 (`less`).** *Goal:* the pager is a tool, not an obstacle. *Accept:* ex 22 `crew 5000 ...` and
line 50 = `crew 0050  deck 3  shift 3`; ex 23 the `crew 4242` line, `Pattern not found` on `n`, and
the conclusion that there was exactly one match; ex 24 a clear wrap-versus-truncate description and
`-S` chosen for the CSV. *Reject:* ex 23 concluding the search "broke". *Red flag:* quitting `less`
with Ctrl-C or by closing the terminal — teach `q`.

**25 (Experiment).** *Accept:* 24; and the glued first line reported **exactly** — the whole of
`no-newline.txt` immediately followed by `2187-05-17 04:02  panel-07  power on`, no separator.
*Reject:* a prediction written after the fact. The written-first prediction is the exercise.

**26.** *Accept:* `cat` with no arguments reads standard input; Ctrl-D described as an
end-of-file signal to the terminal driver rather than a character in the text. *Distinction:* notices
Ctrl-D on a partially typed line flushes it instead of ending input.

**27.** *Accept:* `tac notes/no-newline.txt` output ends without a newline (shown with `od`);
`panel-07.log`'s does; `tac` preserves terminators and reverses order. *Distinction:* notes the
unterminated record has moved to the *front* of the output.

**28.** *Accept:* `head -n -3` → 9 lines; `tail -n -3` → the last 3, same as `tail -n 3`; states that
`-N` means opposite things to the two commands. *Reject:* claiming `tail -n -3` errored.

**29.** *Goal:* the whole lesson's punchline. *Accept:* `tail -f` prints `two` and stops; `tail -F`
prints `two` and reports `has been replaced;  following new file`. Whether `three` appears is
**timing-dependent and either observation is correct** — with a fast recreate, `-F` resumes at the
end of the new file and `three` is missed. *Accept as distinction:* explains it as name versus inode,
and connects it to log rotation. *Reject:* "`tail -f` is broken". *Red flag:* only one of `-f` and
`-F` was run.

**30–31 (Stretch).** *Accept:* ex 30 — both followers get everything; each has its own open file
description and offset; reading does not consume. *Distinction:* contrasts it explicitly with the
Chapter 3 FIFO, where two readers split the stream. Ex 31 — header form `==> path <==` with a leading
blank line, printed only on a change of source file.

**32.** *Accept:* `grep -n`, or `nl -ba | grep`, or `cat -n | grep`. *Reject:* `grep | nl`, which
renumbers from 1 — that is the failure the exercise is built around.

**33.** *Accept:* any working answer plus an honest statement of how many times the file is read.
`(head -n 1; tail -n 1) < file` is once; two separate commands is twice; `sed -n '1p;$p'` is once but
reads every line. *Reject:* a claim of "once" for a two-command solution.

**34.** *Accept:* any working keystroke sequence, reported exactly, including `''` as an alternative
to a named mark.

**35.** *Accept:* `less +F` can be interrupted and scrolled/searched back through the accumulated
text, then resumed with `F`; `tail -f` cannot look back.

**36 (Dig).** *Accept:* identifies `less file | head -3` as the odd one, and explains that `less`
checks whether *stdout* is a terminal and degrades to `cat` when it is not — separately from where
its input comes from — and that `cat | less` works because `less` reads keystrokes from `/dev/tty`.
*Reject:* naming `cat | less` as the odd one. *Distinction:* connects it to Chapter 3 lesson 05.

**37.** *Accept:* `tail` seeks to the end and reads backwards a block at a time counting newlines;
cost scales with the last N lines, not the file; requires a seekable file, so on a pipe it must read
everything and buffer. *Accept:* reports `strace` is not installed and reasons from `man 2 lseek`.
*Reject:* asserting `tail` reads the whole file. *Red flag:* trying to install `strace`.

**38.** *Accept:* `nl -n rz -w 4 -s ' | ' -i 10`, output starting `0001 | ` then `0011 | `. Any
equivalent spelling of the options is fine.

**39.** *Accept:* `tac -s $'\n\n'` with the paragraph-reversed output, first line
`2187-05-17 14:23  comms  channel 9 handshake ok`, 120 lines. **Equally accepted:** the student
tried `"$(printf '\n\n')"`, got the file back unchanged, and worked out that command substitution
stripped the newlines so `tac` was handed an empty separator. *Reject:* reporting "`-s` does nothing"
with no investigation.

---

## Roll-up

**Pass** — Warmup and Core done with correct values; exercises 5, 7, 11, 18 and 25 correct, since
those are the five that carry the ideas (what `wc -l` counts, the missing terminator, blank-line
numbering, `+N` versus `N`, and concatenation without separators). At least three Experiment
exercises attempted with predictions written *before* running. `less` used and quit with `q`.

**Redo** — any of: predictions written after the fact; exercise 17 off by one and not caught;
exercise 29 done with only one of `-f`/`-F`; `setup.sh` opened to answer exercise 20; `wc -l` = 0
explained as "the file is empty".

**Distinction** — exercise 29 explained as name-versus-inode with log rotation named; exercise 30
contrasted with the Chapter 3 FIFO; exercise 36 explained in terms of `/dev/tty`; exercise 37 reasoned
correctly without `strace`; exercise 39's quoting trap found and diagnosed rather than worked around.
