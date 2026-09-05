# 02/05 — Exercises

Lab: `/labs/02-navigating-the-filesystem/05-tree-and-stat`

Seed or reset from the VM with `kestrel seed 02/05` / `kestrel reset 02/05`. Written answers go in
`answers.md`, which the setup script does **not** create — make it yourself.

---

## Warmup

**1.** Draw the `bays` tree. Report the two counts on its last line.

**2.** Print everything the filesystem records about `manifest/notes.txt`. Report its size in bytes,
its inode number, and its type.

**3.** Ask what `manifest/hullscan` is. It has no extension; say what it is anyway.

**4.** Report the total size of `accounting`, in human-readable units, as one number.

---

## Core — `tree`

**5.** Re-run exercise 1 so that hidden entries are included. Both counts change. Say by how much,
and name every entry that appeared.

**6.** Print only the directories under `bays` — no files — and only to a depth of two levels.

**7.** Print the `bays` tree with the full path on every line instead of just the base name. Say one
situation where that form is more useful than the default.

**8.** Print the `bays` tree with each entry's permission bits. Which entry's permissions differ from
its siblings', and which lesson's exercise put them that way?

---

## Core — `stat` and timestamps

**9.** For each of the three files in `stamps`, report all three timestamps. Then answer: which file
has the oldest modification time, and which has the most recent access time? One file holds both
answers — say which, and explain how a file can be the least recently written and the most recently
read at the same time.

**10.** All three files in `stamps` have a modification time in the year 2187 and a change time of
today. Explain that in two lines. Which of the two dates would you trust as evidence, and why?

**11.** Using `ls` alone — no `stat` — list `stamps` three times so that the date column shows
modification time, then access time, then change time. Report the three orderings.

**12.** Print, for every file in `manifest`, one line containing just its name, its size in bytes and
its permissions in octal. One command, one line per file.

**13.** `manifest/readme.txt` and `manifest/notes.txt` have the same extension. Report each one's
size and type as the filesystem records it, then as `file` reports it. State what the filesystem
knows about the difference between them. (The answer is "nothing" — say why that is the right
design.)

---

## Core — `file`

**14.** Run `file` over everything in `manifest`. Two files have extensions that do not match their
contents. Name both and say what each actually is.

**15.** One entry in `manifest` is a symbolic link. Report what `file` says about it, then what
`file -L` says about it. The second is an error — quote it, and explain why following the link
produces a louder failure than not following it.

**16.** `file` reports one entry in `manifest` as `empty` and would report an unrecognised one as
`data`. Find the empty one. Then, without creating anything new, find a file elsewhere on the system
that `file` calls `empty` but that is not empty when you read it. (You met it last lesson.)

---

## The forty megabytes

**17.** `ls accounting` prints nothing. `du -sh accounting` says 40M. Establish which of the two is
withholding information, and produce the listing that reconciles them.

**18.** Report where inside `accounting` the forty megabytes actually is — the full path of the file
and its size.

**19.** Produce a per-directory breakdown of the whole lab, one line per top-level directory plus a
total, in human-readable units. Say which two directories are responsible for essentially all of it.

---

## The fifty megabytes that are not there

**20.** `ls -l ledger/reserved.img` and `du -h ledger/reserved.img` disagree by 50 MB. Report both
numbers, then report the two fields in `stat`'s output that explain the disagreement.

**21.** **Predict first, in writing.** Predict what each of these will report for
`ledger/reserved.img`, then run them:

```bash
du -h ledger/reserved.img
du -h --apparent-size ledger/reserved.img
du -sh ledger
du -sh --apparent-size ledger
wc -c < ledger/reserved.img
```

Explain in three lines what question each of the two `du` modes is answering, and which one you
would use to answer "will this fit on a USB stick?"

**22.** **Predict first, in writing.** `manifest/notes.txt` holds 23 bytes. Predict what `du -h` will
say about it, and why. Then check three more small files and say what number they have in common and
what that implies about storing a million tiny files.

---

## Stretch

**23.** `bays/deck-3/loop` is a symlink to an ancestor of itself. Predict what `tree` does with it by
default, then what `tree -l` does. Run both. Quote the exact marker `tree` prints, and say what a
tool that lacked that check would do.

**24.** Report the filesystem type and the free space for `/labs`, and then for `/`. They are not the
same filesystem. Say which one your lab files are on, and what that means for the lab surviving a
`docker rm` of the container.

**25.** `df` can report something other than blocks. Find the flag, run it on `/labs`, and describe a
failure it would explain that a normal `df` would make look impossible.

**26.** Using `stat` and nothing else, determine whether `manifest/subsystem` is a directory, and
report its link count. Then explain what its link count is counting — the number is not 1.

---

## Dig

**27.** `tree` can total the sizes of a directory's contents rather than reporting the directory's
own size. Find the option, run it on the whole lab in human-readable form — include hidden
entries and do not limit the depth, or the totals will be wrong — and report what it says for
`accounting` and for `ledger`. One of the two figures contradicts exercise 20 — say which and
why.

**28.** `stat` has a mode that describes the **filesystem** an argument sits on rather than the file
itself. Find it, run it on `/labs`, and report the block size and the filesystem type it names.
Compare that type against what `df -T` said in exercise 24. They do not agree — say which you would
trust and how you would check.

**29.** Find the `du` option that makes it report a total for the arguments as a whole, in addition
to the per-argument lines. Run it over `accounting`, `ledger` and `manifest` together and report the
total.

**30.** `file` has an option that prints the MIME type instead of the human description. Find it, and
report the MIME types of `manifest/telemetry.txt`, `manifest/drift.txt` and `manifest/hullscan`.
Say why a program would prefer this output to the default.

---

## Core — `tree` as an instrument

**31.** Print the `bays` tree showing only entries named `survey.txt`. Report the count line. Three
files match, but the directory count is 8 — explain what the extra directories are doing in a listing
that was supposed to show only matches.

**32.** Add the option that removes those from the output. Report the new count line and say, in one
sentence, why the two options are separate rather than one.

**33.** Print `bays` with the `panels` directories excluded. Report the count line, and name the one
entry that appears here but not in exercise 31's output.

**34.** Print the first level of `bays` with the trailing count line suppressed. Then print it again,
with hidden entries and two levels, with directories sorted ahead of files. Report both.

**35.** `tree` can emit machine-readable output. Find the option, run it on `ledger`, and quote the
result. Point at the one element that is not a file or a directory, and say what a program consuming
this would do with it.

**36.** Print `ledger` with each entry's inode number and the device it lives on. Report both numbers
for `reserved.img`. Then say which of the two you would use to tell "the same file under two names"
apart from "two files with the same contents".

---

## Core — `stat` as a report generator

**37.** Produce one line per entry in `manifest` containing the name, the permission string, the
octal mode, `owner:group`, and the type as `stat` words it. One command. Report the two entries whose
type is not `regular file`, and the one whose type is `regular empty file` — a phrase `ls` has no way
to print.

**38.** Print `manifest/dangling.link` and `manifest/hullscan` with the format that quotes the name
and, for a link, appends its target. Quote both lines. Say what that one format code saves you
compared to running `ls -l` and reading the arrow.

**39.** Ask `stat` for the **birth** time of `manifest/notes.txt`. Report it. Then compare it against
the mtime of `stamps/read-me.txt` and explain why the file "created" recently can honestly carry a
modification time from 2187.

**40.** Run `stat -L` on `manifest/dangling.link`. Quote the error exactly. Then explain, using
exercise 15's answer, why `-L` and `file -L` fail for the same reason with different wording.

**41.** `stat -c` ends each line with a newline; `stat --printf` does not. Demonstrate both on the
three files in `stamps`, and say which one you would use inside a loop that builds a single line of
output.

---

## Experiment — predict before you run

**42.** **Predict first, in writing.** You copy `ledger/reserved.img` into your home directory with
plain `cp`. Predict what `ls -l` and `du -h` will say about the copy. Then do it, and report both.
Then say what `cp` had to do to produce that result.

**43.** **Predict first.** Now produce the copy a second way — `cat ledger/reserved.img > c.img` —
and a third with `cp --sparse=never`. Predict `du -h` for both before running. Report all three
numbers together, and state the rule: which tool preserves the hole and which fills it.

**44.** **Predict first.** `touch -r` copies timestamps from a reference file. Predict which of the
three timestamps it will copy from `stamps/read-me.txt`, then check with `stat`. One of the three is
not copied — name it and say why it cannot be.

**45.** **Predict first.** Predict `du -sh .` for the whole lab with `--exclude='*.bin'`. Then run it.
Report the number, and say what it proves about which single file the lab's size is.

**46.** `du` can count something other than bytes. Find the option, run it on the whole lab, and
report the number. Say which of two failures that number would diagnose that `du -sh` could not.

---

## Stretch

**47.** Produce a one-line-per-top-level-directory breakdown with an explicit depth limit rather than
running `du -sh` five times. Report the command and confirm the five numbers match exercise 19's.

**48.** `du` can print a timestamp beside each total. Find the option, run it on `manifest`, and
report the line for `manifest` itself. Say which of the directory's timestamps that column is, and
what it therefore does **not** tell you about when the largest file inside changed.

**49.** Print the lab's totals in SI units rather than binary ones. Report what `accounting` comes to
in each, and say which of the two numbers a disk vendor prints on the box.

---

## Dig

**50.** Run `tree -h --du -a manifest` and `du -sh manifest`. The two totals differ by more than 20K.
Report both, and account for the gap precisely — it is not rounding.

**51.** For `ledger/reserved.img`, report `%s`, `%b` and `%B` from `stat`. Multiply the last two and
compare against the first. Then do the same for `manifest/notes.txt`, whose size is 23 bytes. State
the arithmetic that turns those three numbers into each of the two answers `du` can give.

**52.** `du -ah manifest` lists every file, not just the directory total. Run it and compare the
per-file numbers against `ls -l`. Name the two entries where the two tools disagree most, in opposite
directions, and say which tool is right about what.
