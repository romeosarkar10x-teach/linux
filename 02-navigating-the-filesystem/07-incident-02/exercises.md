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

**20.** Debrief, written, four sentences — one each:

- why `ls` showed nothing,
- why `du` showed forty megabytes,
- what the forty megabytes actually is,
- what a filename is, now that you have met one you cannot type.

Then one more sentence: what you would tell cass, given that she asked whether the disk was lying
or she was. Neither is the answer.
