# 04/05 — Solutions (agent eyes only)

> **Student: do not open this file.** It contains the flag and every answer.

## The shape of the incident

`records/tree-manifest.txt` is the authoritative manifest: issued 2187-05-17 18:20, **16 rows
describing 15 files** across `readings/` (7), `faults/` (3) and `handover/` (5). Two rows share the
path `readings/2187-05-17-1804.txt`, recorded four minutes apart:

```
readings/2187-05-17-1804.txt         512   18:04       end of shift copy, unverified
readings/2187-05-17-1804.txt        1180   18:08       extract retaken, first copy came out short
```

`records/tree-manifest.txt.bak` is the **red herring**: issued 09:12 the same day, marked "working
copy, not for readback", 12 rows, `faults/` listed first, and missing `readings/2187-05-17-1200.txt`,
`readings/2187-05-17-1804.txt` and `handover/2187-05-15.txt`. Building from it produces a tree that
is short by three files and in which nothing looks wrong.

`salvage/` holds two of the fifteen files at their true sizes: `readings/2187-05-17-1804.txt` at
**1180** bytes and `handover/2187-05-15.txt` at **704**. The first settles the duplicate empirically;
the second is present in the authoritative manifest and absent from the `.bak`, which settles which
manifest is authoritative without any argument about age.

`records/copy-notes.txt` is **trace 4** of the sabotage arc. It is dorn's. Nothing in the lab says
so and no agent may say so.

## Per exercise

**1.** `records/` (3 files), `salvage/` (2 files in 2 subdirectories), `rebuild/` (empty). **Two**
files survived.

**2.** Columns: `path`, `size`, `recorded`, `note`. The header says engineering confirms a manifest
by reading the notes column down, first letter only, one word per directory, in row order — and that
a readback which is not three words means the manifest is incomplete.

**3.** 29 lines total; 16 of them are manifest rows. The footer's "16 rows" is correct, and it is a
count of *rows*, which is the trap set for exercise 8.

**4.** `tree-manifest.txt` mtime `2187-05-17 18:20`, `.bak` `09:12` — the `.bak` is **9 hours 8
minutes older**, and its second line reads "working copy, not for readback".

**5.** Differences: (a) `faults/` rows come first in the `.bak`; (b) three rows are missing —
`readings/2187-05-17-1200.txt`, both `readings/2187-05-17-1804.txt` rows, and
`handover/2187-05-15.txt`; (c) the `recorded` times differ for shared paths (the `.bak`'s are
morning times); (d) footer says 12 rows and adds "Midday and evening readings not yet taken."
Sizes for shared paths **agree** — which is why a student who only spot-checks sizes concludes the
two manifests are consistent.

**6.** Older is less authoritative because the tree kept changing after it was written — the `.bak`'s
own footer admits the midday and evening readings had not been taken yet. The counter-argument is
real: an older record is less likely to have been tampered with after the fact. The files settle it —
`salvage/handover/2187-05-15.txt` exists on disk and appears only in the later manifest, so the later
manifest is the more complete description of what was actually there.

**7.** `records/tree-manifest.txt`. Reason must be evidence-based (the salvaged files), not
"the newer one is better".

**8.** **15 files**, from 16 rows: two rows describe the same path.

**9.** The two rows quoted above; **four minutes** apart, 18:04 and 18:08.

**10.** (a) The file was overwritten between 18:04 and 18:08 and both states were recorded. (b) The
first extract failed and was re-run, so the 512-byte row describes something that was never a valid
file. The notes point at (b): "unverified", then "extract retaken, first copy came out short".

**11.** `stat -c '%s %y' salvage/readings/2187-05-17-1804.txt` → `1180 2187-05-17 18:08:00`. It
matches the **second** row exactly, in both size and time.

**12.** The 18:08 / 1180-byte row describes the file that existed. The 18:04 / 512-byte row describes
a short extract that was replaced. `copy-notes.txt` agrees explicitly: "The 18:04 extract came out
short… Ran it again at 18:08 and got a sensible file, and left both lines in the manifest rather than
tidying one away."

**13.** Rule: when two rows share a path, the later recording supersedes the earlier — unless
something on the ground matches the earlier one, in which case the ground wins. Accept any wording
that puts measured evidence above the timestamp ordering.

**14.**
```
mkdir -p rebuild/{readings,faults,handover}
```

**15.**
```
head -c 320 /dev/zero > rebuild/faults/open.txt
head -c 448 /dev/zero > rebuild/faults/closed.txt
head -c 256 /dev/zero > rebuild/faults/deferred.txt
```
Accept `/dev/zero`, `/dev/urandom`, or `yes | head -c`. Accept `truncate -s` if the student found it
(it creates a sparse file — worth a note, since `du` will then disagree with `ls -l`, which is
exercise 21's territory arriving early).

**16.** A single brace expression generates *words*; it cannot pair each generated word with a
different size. So the names come from
`rebuild/handover/2187-05-1{3,4,5,6,7}.txt` but the sizes do not. Reasonable answers: five
`head -c` lines, or a `for` loop over pairs. Both are defensible; forty commands is not.

**17.** Seven files: 1024, 1536, 2048, **1180** (not 512), 768, 640, 896 for
`2187-05-17-0600`, `-0900`, `-1200`, `-1804`, `2187-05-16-2200`, `2187-05-15-0600`,
`2187-05-14-0600`.

**18.** `cp salvage/readings/2187-05-17-1804.txt rebuild/readings/` and
`cp salvage/handover/2187-05-15.txt rebuild/handover/` — `cp`, not `mv`, because `salvage/` is the
only physical evidence in the lab and `mv` would consume it. (This overwrites the placeholder the
student made in exercise 17, which is correct and worth pointing out: a real file beats a
right-sized one.)

**19.** All fifteen sizes must match the manifest. `du -sb rebuild` sums apparent bytes of files
**and** directories, so it will not equal the manifest's column total; `du -sb` is meaningful as a
consistency check between two of the student's own trees, not against the manifest.

**20.** 15.

**21.** Manifest size column totals **13,308** bytes for the fifteen files (readings
1024+1536+2048+1180+768+640+896 = 8092; faults 320+448+256 = 1024; handover
1120+960+704+832+576 = 4192). Summing all sixteen rows blindly gives 13,820 — the extra 512 is the
superseded row, and a student whose total is 13,820 has not applied exercise 13. `du -sb rebuild` reports
more, because it counts the four directory inodes at 4096 each. `du -sb --exclude` games aside, the
correct answer is "the difference is directories, not missing or extra data". A student who used
`truncate` gets a different `du` (without `-b`) again, for a different reason — sparseness.

**22.** Building from the `.bak` gives **12 files**: `readings/2187-05-17-1200.txt`,
`readings/2187-05-17-1804.txt` and `handover/2187-05-15.txt` are absent. Three files differ. You
would **not** notice from the second tree alone — it is internally consistent, every size matches its
own manifest, and nothing errors. That is the whole point of the red herring.

**23.** `.bak` readback: `not` (faults first) + `deted` (five readings) + `moed` (four handover) —
```
notdetedmoed
```
Three "words", none of them words. Two of the three are one letter short, which is exactly what the
header's rule is for: a readback that does not come out as words means rows are missing.

**24.** Same size (1180). `cmp` differs at byte 1 — the reconstruction is NUL bytes, the real file is
text. Different inodes, obviously. The reconstruction reproduces **the shape of the tree**: names,
paths, and byte counts. It reproduces no contents, no timestamps, no ownership and no identity. A
manifest can only ever restore the shape.

**25.** Within one filesystem, `mv` is `rename(2)`: the inode number and link count are unchanged,
the ctime moves, and the data never travels — so a moved tree still exists, findable by inode. Across
filesystems, `mv` copies and unlinks: new inodes, new ctimes, and the original blocks are freed. A
delete leaves no destination at all; the inode's link count reaches zero and the blocks return to the
free pool. Distinguishing evidence: does a tree with those inode numbers exist anywhere; do the
sizes and mtimes match; is there a directory whose mtime moved at the right moment.

**26.** **None of it is available here.** The source filesystem is gone — the lab holds a manifest, a
notes file and two salvaged files, and nothing that carries an inode number, a link count or a ctime
from the original tree. What would have been needed: an inode listing (`ls -li`, `stat`) taken at the
same time as the manifest, or the mtime of the parent directory recorded before and after. The
manifest records *sizes*, which survive a copy and therefore prove nothing about identity.

**27.** Model answer:
> The deck-03 tree described by the 18:20 manifest of 2187-05-17 has been reconstructed at its
> recorded shape: fifteen files, three directories, sizes as recorded, with two files restored from
> salvage at their real contents. Whether the original was deleted or moved cannot be determined from
> what survives — the manifest records sizes, not inodes, and nothing here carries identity from the
> original filesystem.

Reject anything that asserts deletion as established fact. (The flag says `deleted_not_moved`; the
*evidence* in this lab does not, and that tension is deliberate — the flag is the readback of what
somebody concluded, not a proof the student has performed. A student who notices that has understood
the lesson better than one who does not.)

**28.** A manifest taken off a copy proves the copy exists and is self-consistent; it cannot
establish that the copy matches the original, because any error introduced by the copy is recorded as
if it were the original's content. `copy-notes.txt` says this in one line: "a manifest taken off a
copy only proves the copy exists".

**29.** Reading the authoritative manifest's notes column, first letters, in row order:
```
deleetednotmoved
```
Sixteen letters: `d e l e e t e d` / `n o t` / `m o v e d`.

**30.** Drop one of the two `e`s — specifically the one belonging to the 18:04 row ("end of shift
copy, unverified"), because that row describes a file that never existed. The remaining `e` is
"extract retaken", the row that describes the real 1180-byte file measured in `salvage/`. Fifteen
letters, three words:
```
deleted / not / moved
```
The reason must be the measurement from exercise 11, not "the words look right".

**31.** **Flag:** `KESTREL{deleted_not_moved}`

Registered as `04/05` in `container/flags.tsv`:
```
printf '%s%s' 'kestrel-station-7' 'KESTREL{deleted_not_moved}' | sha256sum
0a055dd76ec5dd9348eeaed07e1d6685707fd6696bbd022d328f2e3b8c9baf14
```
The string appears in no file in the lab: the manifest holds the letters as the first characters of
sixteen unrelated notes, and `grep -r deleted /labs` finds nothing resembling it.

**32.** Model debrief:
> The manifest was a record of a tree, kept somewhere the tree was not, so that if the tree went the
> description would still exist. It did go, and the description did survive.
> The two rows four minutes apart are one file recorded twice: an extract that came out short at
> 18:04 and the retake at 18:08. Both were left in deliberately, because a record that has been
> tidied is no longer a record.
> "Deleted, not moved" matters because a moved tree is still on the station and can be found; a
> deleted one has to be rebuilt from the manifest, and everything it contained that the manifest did
> not record — contents, times, who wrote what — is gone. It also makes the week between the copy on
> 05-17 and the wipe something somebody will be asked about.

**33.** To answer "who", you would need process accounting, shell history, file ownership and
timestamps on the original filesystem, and a way to search text across many files. Text search is
Chapter 6 (`grep`) and Chapter 7 (`find`, `sed`, `awk`); ownership and process attribution are later
still. The correct answer here is to stop.

## Added exercises 34–52

**34.** 29 lines in the manifest, 20 in the `.bak`. The manifest's 13 non-row lines are: title,
issue line, "recorded off the deck-03 tree", a blank, the four-line readback convention, a blank, the
column header, the top rule, the bottom rule and the footer. The `.bak` has 8: title, issue line,
"working copy, not for readback", a blank, the column header, two rules and the footer. The
authoritative one has more non-row lines because it carries the readback convention — the part that
makes the notes column mean something — which is exactly the part the working copy dropped.

**35.** The rows are lines 12–27, so:

```
head -27 records/tree-manifest.txt | tail -16
```

`nl -ba records/tree-manifest.txt` gives both numbers: the first row is line 12 and the last is line
27. Adding a row moves the `27` and the `16` together; both are positions counted from the top, which
is why this is a fragile way to read a table and why Chapter 6 exists.

**36.** The sixteen rows total **13820** bytes. The fifteen files that existed total **13308** — the
512-byte `readings/2187-05-17-1804.txt` row is excluded, because exercise 11 showed the surviving
file is 1180 bytes and exercise 12 established that the 18:04 row records an extract that came out
short and was retaken, not a file that was ever in the tree. 13820 − 512 = 13308.

**37.**

```
records/tree-manifest.txt records/tree-manifest.txt.bak differ: byte 44, line 2
```

Status 1. `cmp` has told you the two files are not identical and where the *first* byte of difference
is — line 2, the issue timestamp, which differs in its first digit. That is a correct answer and a
useless one: the differences you care about are four missing rows, a reordered table and a changed
`recorded` value, and `cmp` stops at the first byte and says nothing about any of them. `cmp` answers
"are these the same file"; nothing more. What you want is a line-level comparison, and that is
Chapter 7.

**38.**

```
16 rows.
----------------------------------------------------------------------------
handover/2187-05-13.txt              576   18:19       day shift only, no night entry
handover/2187-05-14.txt              832   18:18       everything signed off
handover/2187-05-15.txt              704   18:17       verified against the panel log
```

Reading bottom-up puts the footer's claim next to the rows it is a claim about, so "16 rows" and the
last row arrive together and you can start counting upward immediately. When a document asserts
something about its own body, the assertion and the end of the body are adjacent, and `tac` is the
cheapest way to see both at once.

**39.** Four rows:

```
readings/2187-05-17-1200.txt        2048   12:07
readings/2187-05-17-1804.txt         512   18:04
readings/2187-05-17-1804.txt        1180   18:08
handover/2187-05-15.txt              704   18:17
```

All four were recorded *after* 09:12, which is when the `.bak` was issued — and its footer says so:
"Midday and evening readings not yet taken." The `.bak` is not wrong about anything it contains; it
is simply earlier. That is what makes it a red herring rather than a forgery, and it is also why
"older" alone was never the argument in exercise 6.

**40.** The `.bak` claims 12 rows and has 12. The footer is correct. It changes nothing: a correct
count tells you the file has not been truncated, and says nothing about whether the tree had more
files in it than the manifest ever knew about — which is precisely the `.bak`'s problem. A count is a
check on the record, not on the world.

**41.** 15 files and 4 directories (`rebuild`, `rebuild/readings`, `rebuild/faults`,
`rebuild/handover`) — `find` counts the top of the tree, which is the number people get wrong.
15 files, not 16: the same exclusion as exercise 36.

**42.**

```
touch -d '2187-05-17 18:13' rebuild/faults/open.txt rebuild/faults/closed.txt
touch -d '2187-05-17 18:14' rebuild/faults/deferred.txt
```

(Two commands, because `open.txt` and `closed.txt` share 18:13 and `deferred.txt` does not.) You now
have a tree whose mtimes agree with the manifest, which makes the reconstruction readable — you can
sort it by time and see the shape of that evening.

What it does not establish is anything at all about the original files. You set those times yourself,
from the manifest, an hour ago. A timestamp you wrote is a transcription of a record, not evidence;
if the manifest were wrong, your tree would be confidently wrong in exactly the same way and nothing
in it would say so.

**43.**

```
$ stat -c '%s %y %n' rebuild/readings/2187-05-17-1804.txt
1180 2187-05-17 18:08:00.000000000 +0000 …
```

Plain `cp` gives the copy *today's* mtime; `cp -p` (or `cp -a`) keeps 18:08 and 18:17. If you used
plain `cp` in exercise 18, redo it with `-p`.

The distinction matters more here than anywhere else in the lesson. Those two files' mtimes were
written by whatever produced them on 2187-05-17 — they are measurements. Every other mtime in
`rebuild/` is a value you typed from a manifest. Both look identical in `ls -l`, and only one of them
would survive being questioned. That is the reason `cp -p` exists.

**44.** `du -sb rebuild` reports 13308 — the sum of the fifteen file sizes, exactly the figure from
exercise 36 — and `du -sh rebuild` reports 32K.

On `salvage`, `du -sb` is **1884** = 1180 + 704, the two files' bytes and nothing else; the
directories contribute nothing to the byte total. `du -sh` is **20K**: three directories at 4K each
(`salvage`, `salvage/readings`, `salvage/handover`) plus one 4K block for the 1180-byte file and one
for the 704-byte file. 12K + 4K + 4K = 20K. Neither number is wrong; they answer different questions
— "how much data is here" and "how much of the disk is this costing".

**45.**

```
0000000  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0
*
0002220  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0  \0
0002234
```

The `*` is `od` collapsing identical lines (lesson 03/01 met this); `0002234` octal is 1180 decimal.
`wc -c` is 1180 and `wc -l` is **0** — there is not a single newline in it.

So the reconstruction is 1180 NUL bytes. It has the manifest's size and none of its content, and
that is all a size column can ever give you back.

**46.**

```
$ cmp /tmp/z salvage/readings/2187-05-17-1804.txt
/tmp/z salvage/readings/2187-05-17-1804.txt differ: byte 1, line 1
```

Status 1. Byte **1** — the very first byte, `\0` against `s`. Same length, no shared content; `cmp`
finds the difference immediately and never reaches the end. Equal size told you nothing.

**47.** `wc -l /tmp/z` is 0 and `wc -l` on the salvaged file is 26. `wc -l` counts newline
*characters*, so a 1180-byte file with no newlines has zero lines — the same arithmetic as lesson 01
exercise 5, where a file with visible text reported 0 because its single line was unterminated. Here
there is no text at all, and the count is honest about it.

**48.** `du /tmp/z` reports **4** — four 1K units, i.e. one 4096-byte block. The file is 1180 bytes,
so 2916 bytes of that block are allocated and unused. The filesystem hands out whole blocks; a file
of one byte and a file of 4096 bytes cost the same. This is why a tree of many small files costs far
more than `du -sb` suggests, and why the manifest's size column would never have predicted the disk
cost of the tree it describes.

**49.** mtime becomes the value you asked for; **ctime becomes now**:

```
2187-05-17 18:13:00.000000000 +0000|2026-09-05 21:46:55.278326031 +0000
```

So yes — anyone reading `rebuild/` tomorrow can tell. A file whose mtime is in 2187 and whose ctime
is this afternoon has had its timestamps set by hand, because ctime cannot be set by `touch` at all
(lesson 02 exercise 51). The reconstruction announces itself as a reconstruction, which is the right
outcome: it is a working tree, not a claim to be the original.

**50.** Raw sequence, notes column first letters in row order:

```
n o t d e t e d m o e d
```

Grouped one word per directory, in the order the rows appear — `faults`, then `readings`, then
`handover`:

```
not   deted   moed
```

`not` is a word by accident; `deted` and `moed` are not words. The readback fails, and the manifest's
own convention says what to do about that: "If the readback is not three words, the manifest is
incomplete and must not be acted on." The `.bak` is missing four rows, so four letters are missing,
and the check catches it. Its header said `working copy, not for readback` before you ran a single
command — the readback is the mechanical confirmation of something the file volunteered.

**51.** Columns that would have answered "deleted or moved":

- **inode number** — with the device, the identity of the file itself. If the tree were moved within
  one filesystem, the inodes at the new location would be *the same numbers*; a `cp` or a
  cross-filesystem `mv` gives new ones. This is the single most useful column and the manifest has
  no equivalent.
- **device number** (`stat -c '%d'`) — tells you which filesystem the tree was on, so "the inodes
  differ" can be read as "it crossed a filesystem" rather than "it is not the same data".
- **link count** — a file with two names does not disappear when one is removed; a manifest that
  recorded `%h` would tell you whether a missing path could still exist elsewhere under another name.
- **a content hash** — establishes that a file found later *is* the file, not merely one of the same
  size. Exercise 46 is the whole argument for this column.
- **ctime** — when the inode last changed, which is the one timestamp nobody can set.

All five are readable with `stat` in the instant before a wipe, so all five could have been recorded
by the same person, at the same time, with the same effort. What no manifest can record is what
happened *after* it was written — which is the archivist's actual question.

**52.** A manifest establishes what the tree contained at the instant it was taken: these paths,
these sizes, these times, and — with the columns of exercise 51 — these identities. It cannot
establish anything about the tree afterwards: not that the files still existed a minute later, not
that they were removed rather than relocated, not who touched them. It is a photograph, and no
photograph tells you what happened after the shutter closed.

The second sentence is the one the archivist needs, and it is the one the manifest cannot supply. The
answer to "deleted or moved" has to come from a record of *events* rather than of state: an audit
log, a filesystem journal, shell history, process accounting — something that was watching while it
happened. `records/` contains no such thing, and neither does this lab. Chapter 15 is where you get
the tools to read that kind of record; until then the honest answer is exercise 27's.

## Notes for the authoring/tutor agent

- The `.bak` is the required red herring and it is **not** a decoy flag — it produces a readback that
  is obviously not three words, so nobody submits and fails. The failure it causes is a wrong *tree*,
  which the student can detect themselves via the readback rule.
- Exercise 27 versus the flag text is the sharpest thing in this lesson. Do not resolve it for the
  student. If they raise it, agree with them: the flag is somebody's conclusion, and their job was to
  say what the evidence supports.
- `records/copy-notes.txt` is trace 4 (`_handoff/SCENARIOS.md`, 2187-05-17). It is read again in
  Chapter 15. The author is never named, here or by any agent.
- If a student uses `grep` or `awk` to do the readback, the answer is right and the exercise is
  wasted; ask them to also do it by eye and say what they would have missed. (`awk '{print
  substr($4,1,1)}'` produces the sixteen-letter sequence and gives no hint that one letter is
  spurious.)
