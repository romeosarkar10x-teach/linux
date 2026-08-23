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
