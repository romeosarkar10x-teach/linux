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
