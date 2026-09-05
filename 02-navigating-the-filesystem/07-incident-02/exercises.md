# 02/07 — Exercises

**Lab:** `/labs/02-navigating-the-filesystem/07-incident-02`
Seed it with `kestrel seed 02/07`. Reset with `kestrel reset 02/07`.

In-chapter tools only: `ls`, `cd`, `pwd`, `stat`, `file`, `tree`, `du`, `df`, `cat`, `head`, `tail`,
`wc`, `echo`, `printf`, `/proc`. No `find`, no `grep`. Do not modify anything in the lab.

Keep a log. Commands that failed count as findings — write them down with their exact error.

---

## Warmup

**1.** Confirm cass's report yourself. From the lab root, run `ls maintenance` and record both what
it printed and what it exited with. Then run `du -sh maintenance`. Write the two numbers side by
side.

**2.** `du -sh` on a directory reports a total. Get the breakdown one level down instead, so the
40M is attributed to something more specific than `maintenance`. Record what you get.

**3.** How many entries does `maintenance` actually contain? Answer with a command whose output you
can count, and state the number including `.` and `..`, and the number excluding them.

## Core

**4.** You now have two directory names inside `maintenance`. One is 40M and one is not. State
which is which, with the command that told you.

**5.** `.cache` is a real directory. Prove it is genuinely empty — not "empty the way `maintenance`
was empty". Your proof must rule out the exact trick you have already been caught by once.

**6.** `overnight/` sits next to `maintenance` in plain sight. Establish what it is and whether it
has anything to do with the 40M. One sentence and the evidence.

**7.** Get inside the 40M directory. You will find that typing its name does not work. Record the
first failure verbatim — the command you typed and the exact error — before you find a way in.

**8.** Once inside: `pwd`, and list everything including hidden entries. Record the three files.

**9.** The 40M is one file. Name it, give its exact size in bytes, and say what `file` reports it
is. Then explain in one sentence why `du -sh` on the parent said 40M and `ls maintenance` said
nothing — the two facts are unrelated and both true.

**10.** You entered a directory whose name you could not type. Now find out *why* you could not.
Print the directory's name as bytes, with non-ASCII escaped. State exactly how many characters in
the name are not the ones a reader would guess, and what they are. (Chapter 2 lesson 6 taught this;
plain `ls -b` is not enough.)

**11.** Ask `stat` to print the name in a form you could paste into a command. Compare that output
to your answer from exercise 10. `stat`'s version is safe to paste but still does not let you
*type* the name. Explain why — that gap is the entire incident.

## Experiment

**12.** **Write your prediction down before running anything.** You are going to try to enter the
directory four ways:

  a. typing the name out with ordinary spaces, quoted
  b. tab completion
  c. a glob (`maintenance/.a*`)
  d. pasting the quoted name from `stat -c %N`

Predict, for each, whether it succeeds, and say why. Then run all four and record what actually
happened. Where you were wrong, say what you had assumed about how the shell hands names to `cd`.

**13.** **Predict first.** `ls maintenance` printed nothing and `ls -a maintenance` printed four
lines. Predict what `ls -A maintenance` prints, and what `tree maintenance` prints versus
`tree -a maintenance`. Run them. Explain the rule that makes `tree`'s file count come out the way
it does.

## Stretch

**14.** Using Chapter 2 lesson 5's tools, get `du` to report `maintenance` in bytes rather than
rounded to `M`, both as bytes-on-disk and as apparent size. The two numbers differ by about fifteen
kilobytes. Account for the difference — every byte of it — and say which of the two cass's disk
accounting would have reported.

**15.** Read `audit-notes.txt`. Report only what it says — who is speaking is not stated and you
should not guess. Then answer the question that matters for the incident: does the existence of
this file explain the 40M, or is the 40M explained by something else entirely? Defend the answer.

**16.** The notes file has a modification time. Report it. Compare it to the mtime of the 40M file
next to it. State what the difference does and does not let you conclude.

## Dig

**17.** `ls` has an option that lists directory *entries* one per line with no decoration, and
another that prints each entry's inode number. Find both in `man ls`, use them together on
`maintenance`, and say what the inode numbers tell you about the two subdirectories that the names
did not.

**18.** Find the `du` option that prints the size of every file in the tree rather than only
directory totals, and use it to show the 40M attributed to exactly one file, in bytes rather than
in `M`. Two options, one command.

## Flag

**19.** The flag is not stored in any file. It is the name you could not type.

Take the directory's name. Drop the leading dot. Lowercase it. Replace each run of whitespace —
visible or not — with a single underscore, and drop any trailing one. Wrap the result:

```
KESTREL{...}
```

Submit from the VM (not inside the container):

```
kestrel flags submit 'KESTREL{...}'
```

If it is rejected, you have almost certainly mishandled the part of the name that exercise 10 was
about. Re-read your byte dump.

---

## Core — the name, byte by byte

**20.** `ls -ab maintenance` escapes the spaces but shows `cannot type` with what looks like an
ordinary space between the two words. Re-run it with `LC_ALL=C` in front. Report both lines exactly.
Say what changed and why the locale — not the flag — was what hid the character.

**21.** Run `ls -aN maintenance | cat -A`. Report the line for the stowaway directory. `cat -A` marks
each non-printing byte; quote the marker it prints for the hidden character, and say what those two
bytes are in hex.

**22.** Count the name twice: how many **bytes** it occupies and how many **characters** a reader
would say it has. The two numbers differ by one. State both and account for the difference.

**23.** `LC_ALL=C ls -a --quoting-style=shell-escape maintenance` prints a form you can paste. Report
it. Then paste it into `cd` and confirm with `pwd` that you arrived. Say which two of the name's
oddities that form handled for you that ordinary quoting would not.

**24.** Prove the name ends in a space rather than merely being followed by one in the listing. Use
two independent pieces of evidence — one from `ls`, one from `stat`.

**25.** From `maintenance`, type `cd .a` and press Tab. Record exactly what the shell put on the
line, including whether it quoted anything and where the cursor ended up. Then say whether pressing
Enter at that point would have worked, and why.

**26.** Enter the directory with a glob: `cd maintenance/.a*`. It works. Explain in two lines which
program expanded the pattern, what it handed to `cd`, and why that path never had to survive being
typed.

**27.** From inside, run `ls -l /proc/self/cwd`. Report the line. Say why this is the most reliable
way to prove where you are, given that `pwd` prints a name you have just spent five exercises being
unable to trust.

---

## Core — the forty megabytes, precisely

**28.** Report `ballast.bin`'s exact size in bytes three ways: from `ls -l`, from `stat -c %s`, and
from `wc -c`. All three agree. Then run `wc -l` on it and report that number. Explain it.

**29.** `file` calls `ballast.bin` `ASCII text, with very long lines (65536), with no line
terminators`. Read its first 32 bytes with `head -c 32 … | cat -A` and report what you see. Say what
the file actually contains and why `file` was not wrong.

**30.** Report the MIME type of `ballast.bin`. Say in one sentence why a program deciding whether to
open this file would be badly served by that answer.

**31.** Use `du` with the options that give **every file**, in **bytes**, and report the four lines
for the stowaway directory. Confirm the three file sizes add up to the reported total for the
directory exactly, and say what that tells you about whether `du -b` charges anything for the
directory entry itself.

**32.** Report `du -s --block-size=1 maintenance` and `du -sb maintenance`. State both numbers and
their difference to the byte. Then say which of the two answers "how much would I free by deleting
this" and which answers "how much would I have to copy over the network".

**33.** Run `tree -a --du -h maintenance`. Report the last line. Compare its total against
`du -sh maintenance` and say whether they agree here — and, from lesson 5, why they might not have.

**34.** Report `df -h /labs`. Say what fraction of the filesystem the 40M represents, and use that to
say something honest about whether cass's alarm was proportionate. The answer is not "no".

---

## Experiment — predict before you run

**35.** **Predict first, in writing.** Predict the count line for `tree maintenance` and for
`tree -a maintenance`. Then run both and report them. The first says `0 directories, 0 files` for a
directory containing 40M — state the one rule that produces that.

**36.** **Predict first.** `.cache` is empty. Predict what each of `du -sh .cache`, `du -sb .cache`
and `du -s --block-size=1 .cache` will report before running them. Then run all three. Report the
three numbers, and explain how an empty directory can be simultaneously 0 and 4096.

**37.** **Predict first.** Predict `du --inodes -s` inside the stowaway directory. Then run it.
Report the number and name every inode it counted, including the one that is not a file you listed.

**38.** **Predict first.** Predict whether `cat maintenance/.a*/audit-notes.txt` will work without
any quoting at all. Then run it. Explain the result using exercise 26's mechanism.

**39.** **Predict first.** You are inside the stowaway directory. Predict what `cd ..` then `ls`
shows, and what `cd -` does afterwards. Run both. Say what `cd -` had stored that you could not have
typed.

**40.** **Predict first.** Predict what `stat -c %N` prints for the stowaway directory, then run it.
It quotes the name in single quotes and stops there. Say what a reader of that output still cannot
determine, and which command from exercise 20 or 21 they would have to run to find out.

---

## Stretch

**41.** Report the mtime of `audit-notes.txt` and of `ballast.bin` to the second. They are 160 years
apart. State what that proves about the order in which they were created, and then state, plainly,
that it proves nothing of the sort — and why.

**42.** Report the **ctime** of both files. Compare them to the mtimes. Using lesson 5's material,
say which of the two timestamps you would put in an incident report and which you would put in a
footnote.

**43.** Report the inode numbers of `.cache` and of the stowaway directory. They differ by one. Say
what that suggests about the order they were created in, and then say how much weight that suggestion
can actually bear.

**44.** `overnight/` contains four run logs and a `NOTES` file. Report its total size and read
`NOTES`. State, in one sentence, why it is in the lab, and what you would have wasted if you had
started there.

**45.** Read `audit-notes.txt` again. It describes a discrepancy between two records and a decision
to keep a copy. Report what the file says about **the summariser** specifically, quoting the sentence.
Do not speculate about who wrote it.

**46.** The notes say "the copy stops existing". Point at the thing in this lab that is a copy of
something, and say honestly whether the lab gives you enough to tell what it is a copy of. The honest
answer is no — say what you would need.

---

## Dig

**47.** Compare four renderings of the stowaway name side by side: `ls -ab`, `LC_ALL=C ls -ab`,
`LC_ALL=C ls -a --quoting-style=shell-escape`, and `stat -c %N`. Report all four. Rank them by how
much a reader can reconstruct the exact bytes from the output alone, and justify the ranking.

**48.** Only one of those four is safe to paste into a command **and** unambiguous about the bytes.
Name it. Then say what property makes the other three fail one test or the other.

**49.** `ls -aN maintenance` prints the name raw. Explain what would have happened had the name
contained a terminal escape sequence instead of a no-break space, and say why the default `ls`
behaviour on a terminal makes that attack harder — and why it made this investigation harder too.

**50.** Using only `ls`, `stat` and `cat -A`, write down the procedure you would give a colleague for
"tell me the exact bytes of a filename you cannot type". Four steps at most, each a command.

**51.** The flag is the name. Explain why a flag derived from a filename could not have been hidden
in a file instead — what property of this incident would have been lost.

**52.** State, in two sentences, the general rule this incident teaches about the relationship
between what a directory listing shows you, what the filesystem stores, and what you can type.

---

## The debrief — required

Written, four sentences — one each:

- why `ls` showed nothing,
- why `du` showed forty megabytes,
- what the forty megabytes actually is,
- what a filename is, now that you have met one you cannot type.

Then one more sentence: what you would tell cass, given that she asked whether the disk was lying
or she was. Neither is the answer.
