# 05 — Validation

Rubric for the validator agent. No auto-grading. Judge the student's work
and conversation, not file contents alone.

## Must have

1. **The gap, computed.** They can state that records 0432–0437 are missing
   and show the command that produced that, not the eyeball. A student who
   read the numbers off the screen has not done exercise 13.
2. **The archive connection.** They state that the same six sequence numbers
   are the only records with a non-zero `clamped=` value, and treat that as
   the link between the two artefacts.
3. **The hash followed.** They found `report/calibration-note.txt` by
   hashing the tree, not by opening files until one looked right.
4. **The permission diagnosed correctly.** The denial in exercise 41 is
   about the directory's `750`, not the file's `400`.
5. **The flag.** `KESTREL{calibration_matter}`, assembled from two halves in
   two places, with the format supplied by the student.
6. **A working `gaps`.** Correct output, exit 0/1/66 as specified, listed in
   `--help`, and the other three subcommands byte-identical — verified with
   `diff`, `cmp` or a checksum, and they can say which they used.
7. **All five report sections filled**, and every sentence in them
   supportable by a command they can name.

## Must not have

- A person's name anywhere in the report, in any grammatical dress.
- The word "falsified", "covered up", or any equivalent, applied to the
  October change. The measured finding is that the report's figures match
  the clamped output; the mechanism is established, the intent is not.
- Timestamps without sources in the **When** section.
- A `gaps` that exits 66 when it finds gaps.
- Any lab file that now contains the flag, or a `report/report.md` with the
  flag pasted into it.

## Probe questions

- "Your report says X. What command prints X?" — for any sentence you
  suspect.
- "Someone reads only your **When** section. Which of those timestamps could
  have been set by hand, and how would they know?"
- "`stationctl check` exits 1. Is that a failure of the tool?"
- "You changed `stationctl`. What is the worst thing your change could have
  broken, and how did you rule it out?"
- "What did you not find out?"

## Signals of a strong pass

They noticed that the archive covers 0400–0443 while the log starts at 0412,
and said so without being asked. They wrote a "what I did not establish"
list. They can explain why exercise 33's sum of 81 means nothing. They are
uncomfortable with the report stopping where it stops, and they left it
stopped anyway.
