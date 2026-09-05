# Incident 13 — Validation Rubric

Agent rubric only. This is the chapter finale and the rubric is strict.

## Pass requires all of

1. **The archive is provably unmodified.** They hashed it before starting and
   after finishing and can quote both, and `sha256sum -c SHA256SUMS` still
   passes. A correct finding with no baseline is a **fail** — the constraint
   was stated twice and it is the professional point of the lesson.
2. **The shortfall, quantified.** Five days — 02, 07, 11, 16, 19 — at 97 lines
   against a specified 144, i.e. 47 samples each, 235 in total, all stopping at
   16:00.
3. **The correlation, stated as a correlation.** Those five days are exactly
   the days `readings/deck-04-daily-max.csv` records at or above the 6.0 clamp
   threshold, and no other day is short. Full credit also notes that on every
   complete day the archive's maximum matches that file exactly, and on the
   short days it does not.
4. **The manifest handled line by line.** They did not discard it over the
   day-13 hash, and they can say that the transposition is a copying error in a
   file that is otherwise intact.
5. **Correct scope on what was not established.** The report must say that the
   evidence does not distinguish "removed" from "never exported", and does not
   identify who produced the export.
6. **No person named.** Any name, any speculation about a person's motive, or
   any phrasing that invites one, is an automatic fail regardless of how good
   the technical work was.
7. **The flag**, `KESTREL{manifest_says_otherwise}`, obtained through
   `manifest-audit attest`.

## Fail on any of

- Any modification to `export/`, including recompressing "to save space".
- Reporting the passing `SHA256SUMS` as evidence the export is correct.
- Reporting `console-note.txt.gz` as a finding rather than a filename mistake.
- Concluding "bad export, re-run it" and stopping. This is the intended trap
  and the captain offers it out loud. It is a true statement and it is not the
  finding.
- Claiming the samples were deliberately deleted, or that anyone deleted them.
- Submitting a `STAGE{...}` token as the flag and reporting it as one.

## Roleplay assessment (`scene.md`)

The captain accepts the finding only when the cadet states the correlation.
A cadet who ended the scene at "bad export" did not pass the roleplay even if
they later found the flag by other means — note it, and say why: the captain
gave them a plausible explanation and they took it.

## Weighting

This closes chapter 14. Correctness of the finding and integrity of the
evidence are equally weighted; a student who finds everything and cannot show
the archive is untouched has not done the job. Say that plainly.

## Closing note to the student

The chapter's sentence: *a checksum tells you nothing changed since somebody
hashed it, and the manifest is the only thing here that says what should have
been true.* Ask them to say it back in their own words before you close.
