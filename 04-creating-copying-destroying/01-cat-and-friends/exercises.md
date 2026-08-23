# 04/01 — Exercises: cat and Friends

Work in `/labs/04-creating-copying-destroying/01-cat-and-friends`.

```
cd /labs/04-creating-copying-destroying/01-cat-and-friends
ls -F
```

Everything in `logs/`, `notes/` and `fragments/` is read-only material — you never need to change it.
`feed/` is yours.

`less` quits with `q`. `tail -f` stops with Ctrl-C. Neither of those is an error.

If you mangle the lab: `kestrel reset 04/01` from the repo root.

---

## Warmup

**1.** `cat logs/panel-07.log`. How many lines, and what is the last one? Confirm the count with `wc`.

**2.** `tac logs/panel-07.log`. Compare with exercise 1. State in one sentence what `tac` reverses —
and what it does *not* reverse.

**3.** `head logs/roster.txt` and `tail logs/roster.txt` with no options. How many lines did each
print? Where is that number documented?

**4.** `cat notes/tabs.txt`, then `cat -T notes/tabs.txt`. The file did not change. Say precisely
what the second command showed you that the first hid.

---

## Core

**5.** `wc -l logs/comms-0517.log` and `wc -l notes/no-newline.txt`. One of those files visibly has
text in it and reports `0`. Explain the number in terms of what `wc -l` actually counts.

**6.** Get the byte count of `notes/no-newline.txt` too. Now `cat notes/no-newline.txt` and look
carefully at where your shell prompt appears. What did `cat` not print?

**7.** `cat -e notes/no-newline.txt`, then `cat -e logs/panel-07.log | tail -2`. `-e` marks the end
of every line with `$`. Which of the two files has a `$` on its last line, and what does the absence
of one mean?

**8.** `cat -A notes/crlf.txt`. Report the exact output. Two of the characters shown are not letters.
Name both, and say which one `cat -e` alone would not have shown you.

**9.** `wc -l notes/crlf.txt` says 3 and the file looks like three ordinary lines. Given exercise 8,
what is the last *character* of each line, and why would a program comparing this file to a
LF-terminated one report every line as different?

**10.** `cat notes/mixed.txt`, then `cat -v notes/mixed.txt`. Something audible may have happened on
the first run. Report what `-v` printed in place of it, and what `-v` printed for the accented
letter.

**11.** `cat -n logs/comms-0517.log | tail -1` and `nl logs/comms-0517.log | tail -1`. Both commands
number the lines of the same file. They disagree by six. Find the six lines they disagree about.

**12.** Make `nl` agree with `cat -n`. `man nl`, look for the body numbering style. One option.

**13.** How many blank lines are in `logs/comms-0517.log`? Answer it with `grep -c`, then answer it a
second way using the difference you found in exercise 11.

**14.** `cat -s notes/blank-run.txt` and `wc -l notes/blank-run.txt`. What does `-s` stand for, how
many lines came out, and what happened to the other eight?

**15.** Print exactly the first 20 lines of `logs/roster.txt`, then exactly the last 20.

**16.** Print line 2500 of `logs/roster.txt` and nothing else, using only `head` and `tail`.

**17.** Print lines 4000 through 4010 of `logs/roster.txt` inclusive, again with only `head` and
`tail`. Say how many lines you expect before you count them.

**18.** `tail -n +4990 logs/roster.txt`. Compare with `tail -n 4990 logs/roster.txt` — do not run the
second one until you have predicted its output volume. Explain the `+`.

**19.** `head -c 40 logs/roster.txt`. Compare with `head -n 40`. Which one is guaranteed to stop
mid-line, and what appears on your prompt line as a result?

**20.** Reassemble the handover note: `cat fragments/*.txt`. Read the result. One of the three
fragments is stored backwards. Which one, and how can you tell without opening `setup.sh`?

**21.** Produce the note in correct reading order in **one** command line, given that one fragment
needs `tac`. You may use a pipe or several commands joined with `;` — say which you used and why.

**22.** `less logs/roster.txt`. Move with: `SPACE` and `b` for a screen, `j`/`k` or the arrow keys
for a line, `g` for the top, `G` for the bottom, `q` to quit. Go to the bottom and report the last
line. Then, from inside `less`, type `50g`. Where did you land?

**23.** In `less`, search forward with `/` and a pattern, then `n` for the next match and `N` for the
previous. Open `logs/roster.txt`, search for `crew 4242`, and report the line. Then press `n`. What
happened, and what does that tell you about how many matches there were?

**24.** `less logs/deck3-strain.csv`. The rows are 314 characters wide, so they wrap. Now type `-S`
and Enter (that is how `less` toggles an option mid-session), and use the right arrow. Describe the
difference between wrapping and truncating, and say which one you want for a wide CSV.

---

## Experiment

For each of these, **write your prediction down before you run it.** Then run it and write down which
part of your prediction was wrong. The wrong part is the exercise.

**25.** Predict the output of `cat logs/panel-07.log logs/panel-07.log | wc -l`, and then of
`cat notes/no-newline.txt logs/panel-07.log | head -2`. The second one is the interesting one:
predict exactly where the first line break falls.

**26.** Predict what `cat` does with no filename arguments at all. Then run `cat`, type two lines,
and press Ctrl-D. Then run `cat -n` the same way. Explain what Ctrl-D sent — it is not a character
in your text.

**27.** Predict, for `tac notes/no-newline.txt`, whether the output ends with a newline. Then check
with `tac notes/no-newline.txt | od -c | tail -2`. Then predict and check the same thing for
`tac logs/panel-07.log`.

**28.** Predict what `head -n -3 logs/panel-07.log` prints — note the minus. Predict the line count
first, then run it. Then predict `tail -n -3 logs/panel-07.log` and run that. One of the two
negatives does something you did not expect.

**29.** Predict what `tail -f` does when the file it is following is *deleted and recreated* rather
than appended to. Set it up in `feed/`, with two terminals:

```
# terminal A
printf 'one\n' > feed/live.log
tail -f feed/live.log
```

```
# terminal B
printf 'two\n' >> feed/live.log
rm feed/live.log
printf 'three\n' > feed/live.log
```

Predict which of `two` and `three` terminal A prints. Then run it. Then run the whole thing again
with `tail -F` (capital F) in terminal A, predicting again before you look.

---

## Stretch

**30.** Open a second terminal (`kestrel enter` again). In A, run `tail -f feed/live.log`. In B, run
a loop that appends a line every second for twenty seconds:

```
for i in $(seq 1 20); do printf 'tick %d\n' "$i" >> feed/live.log; sleep 1; done
```

Watch A. Then, without stopping A, run `tail -f feed/live.log` in a *third* terminal. Do both
followers get every line? What does that say about what `tail -f` is reading?

**31.** `tail -f` can follow more than one file:
`printf 'a\n' > feed/a.log; printf 'b\n' > feed/b.log`, then `tail -f feed/a.log feed/b.log` in one
terminal while you append to both from another. Describe the header lines `tail` inserts and when it
decides to print one.

**32.** Number only the lines of `logs/comms-0517.log` that mention `channel 3`, keeping their
*original* line numbers. `nl` and `cat -n` both renumber from 1 after a filter, so neither works
alone. Find a way. (`grep -n` is one route; there are others.)

**33.** Get the first line and the last line of `logs/roster.txt` in a single command line, in that
order, without printing anything in between. State whether your solution reads the file once or
twice, honestly.

**34.** `less` can jump to a percentage: type `50p`. It can also mark a position with `m` plus a
letter and return with `'` plus that letter. Open `logs/roster.txt`, mark the line for `crew 1000` as
`a`, go to the end, and come back. Report the exact keystrokes you used.

**35.** `less +F feed/live.log` starts `less` in a follow mode that behaves like `tail -f`. Start it,
append to that file from another terminal, then press Ctrl-C inside `less` and scroll back through
what arrived. Explain, in one sentence, the thing `less +F` can do that `tail -f` cannot.

---

## Dig

**36.** `cat` writes bytes to standard output. `less` writes to your terminal *and* reads your
keystrokes. Run `cat logs/panel-07.log | less`, then `less < logs/panel-07.log`, then
`cat logs/panel-07.log | head -3`, then `less logs/panel-07.log | head -3`. One of those four behaves
differently from what its shape suggests. Explain it in terms of what `less` needs that a pipe does
not provide. (Chapter 3's `/dev/tty` is the relevant idea.)

**37.** `head -n 5 logs/roster.txt` returns instantly on a 5000-line file. So does `tail -n 5`. One
of those two is obviously easy and the other is not — a file is a stream of bytes with no line index
anywhere in it. Work out what `tail` must do to find the last five lines without reading the first
4995, and confirm your reasoning with
`strace -e trace=lseek,read tail -n 5 logs/roster.txt 2>&1 | tail -20` if `strace` is in the image,
or by reasoning about `lseek` from `man 2 lseek` if it is not.

**38.** `nl` has options for the numbering format (`-n`), the width (`-w`), the separator (`-s`) and
the increment (`-i`). Produce a numbering of `logs/panel-07.log` that is zero-padded to four digits,
separated from the text by ` | `, counting in tens. One command.

**39.** `tac` has a `-s` option that changes what it treats as a separator. Try to use it to reverse
`logs/comms-0517.log` by *paragraph* — runs of text between blank lines reversed as units, with each
unit's internal line order left intact. Report the command, and say whether the result is exactly
what you wanted; if it is not, say precisely what `-s` did instead.
