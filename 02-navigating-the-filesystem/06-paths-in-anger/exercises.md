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
