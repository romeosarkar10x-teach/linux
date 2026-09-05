# 02/06 — Exercises

Lab: `/labs/02-navigating-the-filesystem/06-paths-in-anger`

Seed or reset from the VM with `kestrel seed 02/06` / `kestrel reset 02/06`. Written answers go in
`answers.md`, which you create yourself.

**Do not rename anything.** Every awkward name in this lab is the exercise. If a name defeats you,
the answer is a better command, not a `mv`.

---

## Warmup

**1.** List `awkward`. Count the files. Then say why the number of lines you got is not the number of
files.

**2.** Re-run it so that every name is printed with escapes. Report the six names exactly as they
appear now.

**3.** Read the file at `awkward/deck 3 bay 2/strain log.txt`. Say which of the three methods from
the notes you used.

---

## Core — whitespace

**4.** There are three entries in `awkward` whose names render as `notes.txt`. Read all three and
report which one says what.

**5.** Change into `awkward/deck 3 bay 2`, confirm with `pwd` that you are there, and come back to
where you started with a single command that does not name the path.

**6.** One name in `awkward` contains a tab. Report its full name, and say which listing flag proved
the character is a tab rather than several spaces.

**7.** One name in `awkward` contains a newline. Report its size in bytes using `stat`, and state
what makes this name more dangerous than the one with the tab.

**8.** Using tab completion only — no typed-out names, no copy-paste — read `awkward/notes.txt `
(the one with the trailing space). Describe what the shell did when you pressed Tab after `note`,
and what you had to do next.

---

## Core — dashes

**9.** `cat dashes/-audit` works. `cd dashes` then `cat -audit` does not. Explain the difference in
one line.

**10.** From inside `dashes`, read `-audit` twice: once using the `./` fix and once using the `--`
fix. Report both commands.

**11.** From inside `dashes`, read the file named `--help`. Say which of the two fixes still works
here and which does not, and why.

**12.** From inside `dashes`, run `ls -audit`. It does not fail. Say what it actually did and which
flags it was interpreting.

**13.** `dashes` contains a directory whose name begins with a dash. Change into it and back out
again. Report the command you used.

---

## Core — lookalikes

**14.** List `lookalikes`. How many entries does `ls` report? How many distinct names do you *see*?
Write both numbers down before doing anything else.

**15.** Make the shell show you the bytes of those names. Report the escaped form of each of the five
entries.

**16.** Two entries render as `strain-log.txt`. Read both, and report which Unicode character each
one's name uses. The file contents will tell you if you have them the right way round.

**17.** Two entries render as `deck.txt`. Read both, and report the same.

**18.** One entry renders as `panel.txt` but is not what you would type. Report the escaped name and
say what the extra character is.

**19.** Without retyping any name by hand, read `lookalikes/dеck.txt` — the Cyrillic one. Say how you
got the name into the command line.

---

## Core — dots

**20.** List `dotted` three ways: plain, showing all entries, and showing all entries except `.` and
`..`. Report the three counts.

**21.** `dotted` contains one entry whose name is three dots and one whose name begins with two dots.
Read both. Say why neither of them is `..`.

**22.** `dotted/.cache` is an empty directory. Prove it is empty rather than assuming it — and say
what command you would need to be sure, given what you learned in `02/05`.

**23.** Confirm, using a tool that is not `ls`, that a leading dot does nothing to hide a file. Say
which tool you used and what it reported.

---

## Core — metacharacters

**24.** Read all five files in `metachars`. Report which ones needed quoting or escaping and which
did not.

**25.** `metachars/$HOME.txt` is the interesting one. Say what happens if you type its name inside
double quotes, and what happens inside single quotes. You do not need Chapter 5's rules to observe
the difference — just report it.

**26.** `metachars` contains a name with an apostrophe in it. Read it. Say why single-quoting the
whole name does not work and what you did instead.

---

## Experiment

**27.** **Predict first, in writing.** For each of these, predict whether it succeeds, fails, or
succeeds while doing something you did not intend. Then run them from inside the lab root:

```bash
ls report
ls -b report
cat report/-summary.txt
cd report && cat -summary.txt
ls report/old runs
ls -a report
```

Explain each result in one line. Two of the six are the interesting ones — say which and why.

**28.** **Predict first, in writing.** Predict what `ls awkward | wc -l` will print, and what the
true file count is. Run it. Explain the difference, and state the general rule about filenames and
line-oriented tools that this proves. (`wc -l` counts lines; `|` sends output into it — both are
Chapter 8, and you are only borrowing them.)

---

## Stretch

**29.** Produce a listing of the whole `report` directory, including hidden entries and subdirectory
contents, in which every name is unambiguous. State which flag combination you used and why each
flag was necessary.

**30.** Using `stat` with a format string, print the name and byte size of every file in `metachars`
in a form you could paste straight back into a command. There is a format placeholder that quotes for
you — find it.

**31.** For each of the two `strain-log.txt` files in `lookalikes`, report the inode number and size.
Then answer: could these two names ever refer to the same file? What would that require?

**32.** `awkward` contains a file whose name contains a newline. Change into `awkward` and produce a
listing in which that file occupies exactly one line of output. State the flag.

---

## Dig

**33.** `ls` has a general option that controls how names are quoted, of which `-b` and `-Q` are
shorthands. Find it, list its accepted values, and run `lookalikes` through the value that produces
shell-ready output. Report which value you used.

**34.** There is an environment variable that sets that same behaviour for every `ls` you run,
without a flag. Find it in `man ls`, set it for a single command, and demonstrate it working on
`awkward`. Then say what happens when you use it on `lookalikes` instead, and what you would have to
add to make the non-ASCII names visible.

**35.** `stat`'s `%N` placeholder prints a quoted name. Run it over `lookalikes` and compare its
output to `LC_ALL=C ls -b`. They escape the same bytes differently — report both forms for the
Cyrillic name and say which one you could paste into a command.

**36.** Find the option that makes `ls` print a `?` in place of any non-printable character, and the
option that makes it print such characters raw. Run both over `awkward`, and say which one you would
use over an untrusted network connection and why. (Hint: a filename may contain terminal escape
sequences.)

---

## Core — the eight quoting styles

**37.** `--quoting-style` accepts eight values. Run `ls --quoting-style=X lookalikes` for
`literal`, `locale`, `shell`, `shell-always`, `c` and `escape`. Four of the six produce **identical**
output here. Report which four, and explain why — the answer is about your terminal's locale, not
about the flag.

**38.** Re-run the same six with `LC_ALL=C` in front. Now they differ. Report the line for the
Cyrillic `deck.txt` under `escape`, under `c`, and under `shell-escape`. Say which of the three you
could paste into a `cat` command unchanged.

**39.** Run `ls --quoting-style=shell-escape awkward` and `ls --quoting-style=shell-escape-always
awkward`. Report both. Three of the six names are quoted by the first and all six by the second —
say when you would want the "always" form even though it is noisier.

**40.** `ls -N` prints names raw. Run `ls -N awkward`, then run it again piped through `cat -A`
(which marks tabs as `^I` and line ends as `$`). Report the second output. How many lines does the
six-entry directory occupy, and which entry is responsible?

**41.** `ls --zero` separates names with a NUL byte instead of a newline. Run it on `awkward` through
`cat -A` and report what you see. Say why NUL is the one byte that is safe as a separator — the
answer is a fact about what a filename may legally contain.

**42.** There is an environment variable that sets the quoting style for every `ls` without a flag.
Set it for one command only — `QUOTING_STYLE=shell-escape ls awkward` — and confirm the output
matches exercise 39's first run. Then say why setting it permanently in your shell startup is a
choice with a cost.

---

## Core — hiding, ignoring and inodes

**43.** List `dotted` three ways: `ls`, `ls -a`, `ls -A`. Report all three. Say precisely which two
entries `-A` drops that `-a` keeps, and why those two are special rather than merely hidden.

**44.** Run `ls --ignore='*.txt' awkward`. Two entries survive. Report them, and explain why
`notes.txt ` — which certainly ends in `.txt` to your eye — is one of the survivors.

**45.** Run `ls --hide='notes*' awkward`. Report the output. Then run `ls -a --hide='notes*' awkward`
and report that. `--hide` behaves differently under `-a` than `--ignore` does — state the difference
and say which of the two you would use in a script.

**46.** Report the inode number of each of the five entries in `lookalikes`, one per line. Confirm
that all five are distinct. Then answer exercise 31's question again in one line, now with the
numbers in front of you.

---

## Experiment — predict before you run

**47.** **Predict first, in writing.** Predict the output of each, then run all four from the lab
root:

```bash
ls -Rb report
ls report/old\ runs
ls "report/old runs"
ls report/old runs
```

The last one produces two errors, not one. Explain exactly what `ls` was asked to do, then describe
the arrangement of directory names under which that same command would succeed silently on the wrong
targets — and say why that outcome is more dangerous than the error you got.

**48.** **Predict first.** `printf '%q\n' metachars/*` prints each name in a form the shell will
accept back. Predict how `dorn's notes.txt` and `range[0-9].txt` will come out, then run it. Report
both lines and say which character got escaped in each.

**49.** **Predict first.** Predict what `stat -c '%N %s' metachars/*` prints for
`metachars/$HOME.txt` and for `metachars/dorn's notes.txt`. Then run it. `%N` switched quote
characters between those two lines — say why, and which rule it is applying.

---

## Stretch

**50.** From the lab root, change into `awkward/deck 3 bay 2`, confirm with `pwd`, and return with
`cd -`. Report both `pwd` outputs. Then say what `cd -` reads to do that, and why it survives a name
with spaces in it when a hand-retyped path might not.

---

## Dig

**51.** A filename may contain terminal escape sequences. Explain, in three sentences, what
`ls -N` on a directory containing such a name could do to your terminal, and what `ls -q` and
`ls -b` each do about it. State which of the three is the default when output goes to a terminal, and
which you would use when reading a directory someone else can write to.

**52.** Compare `stat -c '%N'` against `LC_ALL=C ls --quoting-style=shell-escape` over `lookalikes`.
Report the line each produces for the Cyrillic `deck.txt`. They escape the same bytes into different
syntax — say which of the two is guaranteed to round-trip through `bash`, and what `%N` is quoting
for instead.
