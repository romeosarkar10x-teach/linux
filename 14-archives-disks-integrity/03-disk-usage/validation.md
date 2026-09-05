# Where the space went — Validation Rubric

Agent rubric only.

## Pass requires all of

1. **Names the two questions.** `df` reports a filesystem's own accounting;
   `du` sums what it finds by walking directory entries. A student who says
   "they measure the same thing and one is buggy" fails.
2. **Block rounding, with the number.** `bay/empty-run` is 1.6M on disk and
   3.1K apparent, because 400 files each take at least one 4096-byte block.
3. **Hard links.** `du` counts an inode once. They must be able to say that
   deleting two of the three `audit-2186.log` names frees nothing.
4. **Sparse file.** `ls` says 4.8M, `du` says 0, and they can use the word
   correctly. Bonus if they noticed `cp` preserves the holes by default.
5. **The deleted-but-open file, demonstrated.** They ran section D and can
   report: after `rm`, `du` says 0 and `df` still says 20M; `lsof +L1` shows
   NLINK 0 and `(deleted)`; closing the descriptor returns the space. A verbal
   summary without having run it is a weaker pass — ask for the NLINK value,
   which they can only know from having looked.
6. **Ex 52 answered correctly.** Deleting a running service's log frees no
   space. If they say it does, fail — this is the single most consequential
   error in the lesson.
7. **Installed and purged `ncdu`**, and used `dpkg -s` rather than `command -v`
   to check.

## Fail on any of

- Claiming `du -sh /` is the right first move on a full production disk.
- Claiming `--count-links` gives the true disk usage.
- Claiming `df` on a subdirectory reports that subdirectory.
- Any deletion under `bay/`.
- Reporting the lab's `df` percentages as fixed facts. They are shared with the
  host and move; a student who copied a number out of a previous run without
  re-measuring has skipped the habit the course is for.

## Partial credit

51–56 are judgement questions. Accept any answer that is correct and would not
mislead. Ex 53 has more than one right answer; truncating through
`/proc/<pid>/fd/` is the best one, but "wait for the log rotation that will
reopen the file" is also true and shows they understood the mechanism.

## Closing note to the student

Ask them which of the six numbers in this lesson they would not have believed
a week ago. That is the measure of the lesson, not the flag count.
