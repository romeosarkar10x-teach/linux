# 06/07 — Solutions

**Flag: `KESTREL{the_gap_is_the_message}`**

Every number below was measured in the container.

## Warmup

**1.** Claim one: "the logs look fine" — a conclusion, and it is true of every line she read. Claim
two: "the summary stops early" — the symptom, and it is about a *count*, which is the one thing
reading line by line cannot check. Separating the conclusion from the observation is the whole skill.

**2.** `ls -A spool` also shows `.hold-2187-06-13`. `-A` (or `-a`) includes dotfiles. Without it you
miss the only file in the lab that matters.

**3.** Run window 03:00:00–05:59:45, interval 15s, entries expected 720, samplers 1 2 3 4, status
nominal throughout. The window and interval are checkable against the log's first and last entries;
720 is checkable by arithmetic *and* by counting; "samplers 1 2 3 4" is checkable per-entry and is
the one that quietly fails.

**4.** 05:59:45 − 03:00:00 = 10785 s; 10785 / 15 = 719 intervals; +1 for the entry at 03:00:00 = **720**.
Agrees.

**5.** Two strain logs (the 12th and the 13th — one is a control) and two panel files for the 13th,
one of which carries a `.1` suffix. The pairing that matters is *log vs control* and *log vs its own
rotated half*.

**6.** Six fields: `#NNNN`, date, time, `sampler=N`, `strain=0.NNN`, `status=nominal`. The sequence
and the timestamp are redundant with each other — either one alone orders the file, and having both
is exactly what makes the deletion provable.

**7.** rc 1, no output, for `error`, `warn`, `fail`, `alert`. It tells you no entry *says* anything
went wrong. It tells you nothing about entries that are not there to say it. A clean `grep -i error`
is evidence about the surviving text and nothing else.

## Counting

**8.** **703.** The first two lines are `#` comments describing the format. `^#` counts them.

**9.** `grep -c '^#[0-9]' logs/strain-run-2187-06-13.log` → **701**. Difference from exercise 8: **2**,
the two header lines.

**10.** `wc -l` → **703**, the same as exercise 8 and for the same reason: it counts every line
including commentary. The honest answer to "how many entries" is **701** — you had to state what an
entry *looks like* before a count meant anything.

**11.** 720 − 701 = **19**.

**12.** `grep -oE '^#[0-9]{4}' … | sort | uniq -d` → empty. That proves **no sequence number appears
twice** in what remains. It does not prove the numbering never restarted, never skipped for a
legitimate reason, or that nothing was renumbered — it only rules out duplicates.

**13.** Lowest `#0001`, highest `#0720`. 720 − 1 + 1 = 720 ≠ 701. **The file claims a range it does
not fill.** That single inequality is the finding; everything after it is locating and explaining.

**14.** The control, `strain-run-2187-06-12.log`: count **720**, highest **#0720**, range equals
count. It establishes that the monitor's normal output is complete and that 720 is what a good night
looks like — so the 13th's shortfall is not a property of the tool, the format, or your pattern.

## Locating the gap

**15.** Last before: **`#0245`, 04:01:00**. First after: **`#0265`, 04:06:00**.

**16.** #0246 to #0264 inclusive = **19**. Matches exercise 11 exactly, which is the second
independent route to the same number.

**17.**
```
247:#0245 2187-06-13 04:01:00 sampler=1 strain=0.285 status=nominal
248:#0265 2187-06-13 04:06:00 sampler=1 strain=0.335 status=nominal
```
Line numbers **247 and 248 — consecutive**. The sequence jumps by 20 across two adjacent lines. That
is the shape of **lines removed from a file that was already written**, not of a writer that paused:
a writer that paused would have left the same jump with nothing else disturbed, but it would also
have left the run summary and the surrounding cadence disturbed, and neither is. Nothing was
re-numbered, nothing was rewritten — someone deleted whole lines and left the rest untouched.

**18.** Missing entries would have run **04:01:15 to 04:05:45** inclusive.

**19.** 19 × 15 s = 285 s. From 04:01:00 to 04:06:00 is 300 s, which is 20 intervals: one for the
surviving entry at 04:01:00 and 19 for the missing ones. It closes **exactly, with no slack**. A
monitor that stopped and restarted would almost never resume on the same 15-second phase; a clean
phase-aligned hole is what you get when the writer never stopped and the lines were taken out
afterwards.

**20.**
```
#0245 2187-06-13 04:01:00 sampler=1 strain=0.285 status=nominal
#0265 2187-06-13 04:06:00 sampler=1 strain=0.335 status=nominal
```
No discontinuity at all — 0.285 to 0.335 is an unremarkable step and both say `nominal`. Reading is
useless here. cass read it twice and she was not being careless; she was using the only method
available to her, and the method cannot see this.

## The red herring

**21.** `panel-run-2187-06-13.log`: count **480**, highest **#0720**, lowest **#0241**. Naive deficit
against 720: **240**.

**22.** `notes/rotation.txt`: the monitor rotates at 04:00, the earlier portion becomes `.1`, and
**numbering does not restart across a rotation**. The deficit is not a deficit; it is the part of the
run that is in the other file.

**23.** `logs/panel-run-2187-06-13.log.1` — count **240**, `#0001`–`#0240`.

**24.** 240 + 480 = **720**. Nothing is missing from the panel run.

**25.** "Before reporting a shortfall, check for rotated portions of the same run and count them
together" — checkable as `cat logs/panel-run-2187-06-13.log* | grep -c '^#[0-9]'`.

**26.** `find logs -name 'strain-run-2187-06-13.log.*'` → nothing. `find` matters rather than `ls`
because you are asserting a **negative**, and you want a search that covers subdirectories and
hidden names rather than one directory listing you happened to eyeball. (You are still only proving
it is not *here*; see 27.)

**27.** "The strain monitor on bank A does not rotate. Its run log is one file." That is a
**statement in a document**, not an observation of the system. It is corroboration, and combined
with exercise 26's search and the 12th's single complete file it is enough — but a document alone
would not be, and saying so in the report is the difference between a finding and an assumption.

## The search that closes it

**28.**
```
find . -newermt '2187-06-13 04:01' ! -newermt '2187-06-13 04:06' -type f
./spool/.hold-2187-06-13
```
One file. The window is half-open — `-newermt A` is strictly after A, `! -newermt B` is at or before
B — so state which end you meant. The tight window (`04:01:15` to `04:05:45`) returns the same file.

**29.** The usual first failure is getting the two `-newermt` clauses the wrong way round, which
returns everything *outside* the window, or forgetting the `!`, which returns everything since the
start of the window. Widening finds it; narrowing back tells you the file is at 04:03:20 and the
first attempt was not too narrow, it was inverted.

**30.** The name begins with a dot. `ls -A` (Chapter 2) shows it. `find` never had the problem —
it has no concept of a hidden file, which is why an investigation reaches for `find` and not `ls`.

**31.** `find logs -newermt … ! -newermt …` → nothing. The strain log's own mtime is later (06:00,
its last write). So **the deletion happened after the log stopped being written**, not during the
window — the hold record is contemporaneous with the gap, the edit is not.

**32.**
```
Access: 2187-06-13 04:03:20
Modify: 2187-06-13 04:03:20
Change: 2026-08-28 19:42:13
 Birth: 2026-08-28 19:42:13
```
You searched on **Modify** — that is what `-newermt` uses by default. Access and Modify are inside
the window. **Change (ctime) is not, and cannot be set by `touch`**: it records when the inode
metadata was last altered, which is when this lab was built. That asymmetry is the single most useful
forensic fact in the chapter: mtime is a claim, ctime is much harder to make lie.

**33.** Form **SH-12**, a sampler hold record. `notes/forms.txt`: fields `f1`–`f5` are a five-word
summary read in numeric order; `f6` is who authorised the hold; `f7` is why.

**34.**
```
$ grep -oE 'f[1-5]=[a-z]+' spool/.hold-2187-06-13 | cut -d= -f2 | paste -sd_
the_gap_is_the_message
```
`grep -o` prints only the match, the ERE bounds the key range, and the file's own order is numeric
order so nothing needs sorting.

**35.** **f6 (authorised by) and f7 (reason)** are blank. `notes/forms.txt`: "A hold record with f6
or f7 blank is an incomplete record and should have been rejected at end of shift." It was not
rejected. That is a fact about the **process**, and it is as far as the evidence goes.

**36.** `kestrel flags submit 'KESTREL{the_gap_is_the_message}'`.

## Reporting

**37.** Something like:

> Nineteen entries are missing from the strain bank-A run log for 2187-06-13, sequence #0246–#0264,
> covering 04:01:15 to 04:05:45. The monitor numbers its entries, so the file contains 701 entries
> across a declared range of 720 and the surviving lines either side of the gap are adjacent — the
> lines were removed after they were written. It is not rotation: bank A does not rotate, there is no
> `.1` file, and the 12th's log for the same monitor is complete at 720.

**38.** "It is nothing — the panel log is a rotated pair and reads short on its own; counted
together the run is complete at 720. Thank you for sending it; the summary was worth checking."

**39.** Something like: "The hold record for sampler 3 covering that window has its authorisation and
reason fields blank, so the hold was never signed off. That is a gap in the end-of-shift process; the
record does not identify who raised or released it, and nothing else in the log set does either."
No name, and no implication that a blank field means concealment.

**40.** Cheap: have the monitor write its entry count and a checksum into the run summary at close,
so the file carries its own claim — costs nothing, and only catches sloppy editing. Expensive:
append-only storage or off-host shipping of the log as it is written — catches everything, and costs
storage, plumbing, and someone's ongoing attention.

## Experiment

**41.** `sed -i '400,418d' scratch/copy.log` and the count/range check catches it immediately. The
floor is **one**: a single deleted entry still breaks `highest − lowest + 1 == count`. Numbering is
what makes the detection threshold one line instead of "enough to notice by eye", which in practice
is never.

**42.** Truncation from the end is **not** detectable by the same check: the range shrinks with the
count and stays consistent. You need an external claim about how long the run should have been —
which is exactly what `notes/monitor-summary.txt` provides, and why a summary written by the same
process is weak evidence and a summary written by a different one is strong.

**43.** With no sequence numbers you are down to timestamps: look for an interval larger than 15
seconds. That catches this gap, but it cannot distinguish deletion from a pause, it fails entirely
if the deleted block is at the end, and it fails if entries are irregular by design. Much weaker,
and every real log format that expects to be audited numbers its records for this reason.

**44.** `uniq -d` on the extracted sequence numbers catches the duplicate. The count-versus-range
check does **not** — adding a duplicate raises the count without changing the range, and can even
mask a deletion by making the arithmetic close again. Two checks, two different failure modes; run
both.

**45.** `find . -newermt '2187-06-13' ! -newermt '2187-06-14' -type f` → **11 files**, which is most
of the lab. The five-minute window returns **one**. Reach for the narrow window first when you have
one; the day window is for when you do not yet know what you are looking for, and its job is to
produce a list short enough to read, not an answer.

## Stretch

**46.** One shape:
```
grep -oE '^#[0-9]{4}' logs/strain-run-2187-06-13.log | tr -d '#' > /tmp/have
seq -w 0001 0720 > /tmp/want
comm -23 /tmp/want /tmp/have
```
prints `0246`…`0264`. `seq -w` for the zero padding, and both inputs must be sorted the same way for
`comm` to be meaningful.

**47.** A `gapcheck` worth having takes the expected range from the file itself (lowest and highest
present), reports `expected/present/deficit`, prints the missing ranges via the exercise-46 method,
and returns 1 on any deficit. Run over the four logs it should flag only the 13th's strain log, and
should *not* flag `panel-run-…log` if you taught it to glob `FILE*` and concatenate — which is the
exercise-25 rule expressed as code.

**48.** Do not look for a file; look for the **run**. Ask what the writer says its own range is
(summary, or the first entry's sequence), and account for every sequence number in that range across
whatever files exist, decompressing as needed — `find . -newermt`/`-name` to gather candidates, then
count the union. The check that depends on `.1` existing is a check on a convention; the check that
depends on sequence numbers is a check on the data.

**49.**
```
find archive -name '*.log' -exec grep -c '^#[0-9]' {} +
```
`+` batches many files into few `grep` invocations, which for a thousand files is the difference
between a thousand process spawns and a handful. The cost is that `grep` then prefixes each count
with the filename — which here you *want*. Use `\;` only when the command genuinely cannot take
multiple arguments.

**50.** Both are true: sampler 3 was legitimately held 04:01:15–04:05:45, and the entries for that
window are gone. A legitimate hold explains why sampler 3 stops reporting; it does **not** explain
why the other samplers' entries for the same window are missing too — a hold on one sampler should
leave the other three writing normally. What would distinguish the two: whether the surviving entries
in the window mention samplers 1, 2 and 4 (they do not — there are no entries at all), and whether
the hold record was completed (it was not).

## Dig

**51.** `find records -newermt '2187-06-13' ! -newermt '2187-06-14' -type f` → `records/hold-log.txt`.
Token: **`STAGE{first_stage_holds}`**. It also lists three holds this quarter, one of them sampler 3
on the 13th — corroboration for exercise 50 arriving from a different direction.

**52.** 720 − 701 = **19**, so line 19 of `records/index-b.txt`:
**`STAGE{nineteen_that_were_never_written}`**. Counting `^#` instead of `^#[0-9]` gives 703 and a
deficit of 17, and line 17 says `STAGE{wrong_line_count_again}` — a loud, unambiguous failure that
names the mistake without naming the fix.

**53.**
```
sed -n '/^#0265/,$p' logs/strain-run-2187-06-13.log | grep -oE 'sampler=[0-9]' | sort -u
sampler=1
sampler=2
sampler=4
```
**Sampler 3** never reappears. `records/sampler-3.txt` → **`STAGE{third_stage_the_one_that_stopped}`**.
(Over the whole file sampler 3 appears 61 times, all before the gap.) The decoy files
`sampler-1/2/4.txt` say `STAGE{wrong_sampler_recount_it}`.

**54.**
```
$ find . -type f -exec grep -q 'SH-12' {} \; -print
./records/sampler-3.txt
./notes/forms.txt
./spool/.hold-2187-06-13
```
Token in the hold record: **`STAGE{four_of_four_and_nobody_signed}`**.

`-exec grep -q … \; -print` works because `-exec` with `\;` is a **test** — its exit status gates
`-print`. With `+` you cannot do that: `find` batches the arguments and the exit status no longer
corresponds to any one file, so `-print` after a `+` exec prints everything. The equivalent with `+`
is `-exec grep -l 'SH-12' {} +`, which makes `grep` do the printing. Both are correct here; the `\;`
form is the one that generalises to commands that are not `grep`.

**55.** The four skills: **find by timestamp** (lesson 05), **`grep -c` with a precise pattern**
(lesson 02), **ERE with `grep -o`** (lessons 02–03), **`find -exec`** (lesson 05). The chapter skill
the chain never used is **`locate`** (lesson 06) — and it would have been wrong at every stage,
because every stage asks about the state of files *now*: what was written in a five-minute window
last night, what a file currently contains, which files currently mention a string. An index built
before any of that happened cannot answer one of them.

---

## Authoring notes

- **The count trap is load-bearing.** `grep -c '^#'` gives 703 because of two header lines. The
  wrong deficit (17) lands on a real line of `index-b.txt` that fails loudly. Do not "fix" the
  headers.
- **The red herring is arithmetic, not fiction.** The panel log genuinely reads as −240 on its own
  and is genuinely complete. A student who reports it has made the exact mistake the lab is testing.
- **`ctime` cannot be forged with `touch`** — exercise 32 shows Change/Birth outside the station
  clock. That is a property of the harness, and it is also true and useful, so it is taught rather
  than hidden.
- **Nobody is named.** There is no name in `setup.sh`, in any seeded file, or in this document. f6
  and f7 are blank on purpose and the blank is a process finding. A tutor or gamemaster that supplies
  a name has broken the lesson.
- **cass is not a suspect and has no hidden knowledge.** She read the logs correctly and reported the
  one thing reading cannot resolve. Play her as competent.
- **Crack attempt with Chapters 1–5 only:** the flag *is* reachable with `ls -A spool` + `cat`
  (Chapter 2) plus `notes/forms.txt` for the field order — no Chapter 6 tool strictly required. That
  is left as-is deliberately: the lab's difficulty is knowing that `spool/` is where to look, and the
  only thing that points there is the timestamp window. A student who dot-hunts every directory by
  hand will get the flag and will not be able to answer section 1 of `validation.md`, which is the
  part that is graded. `grep -rl KESTREL .` returns nothing (rc 1) — the flag is not greppable.
