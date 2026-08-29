# 08/06 — Validation

For the validator agent. Rubric only. Ask for the command and its output, not the conclusion.

## Must be able to do

1. State, before running anything, that a `.log` written by a wrapper holds fd 1 only, and quote the
   wrapper's redirection line as the evidence.
2. Produce the stderr stream on its own with `2>&1 >/dev/null` (or `2> file`), give the count `285`,
   and explain the ordering rule that makes `>/dev/null 2>&1` give `0` instead.
3. Give all three counts and show they close: 18 report lines, 285 warnings, 303 combined.
4. Rank the clamps by panel (181 p-03, 101 p-11, 2 p-07) and identify p-07 as the one
   `notes/clamping.txt` says should not clamp.
5. Give the two dates, 2187-05-13 and 2187-05-14, and show that p-07 clamps on no other day.
6. Extract the four note words in **first-appearance** order and say why `sort` is the wrong tool.
7. Submit the flag — four words, first-appearance order, underscores — and explain why `grep -r` could not have found it — a
   stream that is never written to a file cannot be searched afterwards.
8. Give the one-line fix to `bin/nightly` and the storage cost (~19 KB for the whole fourteen months).

## Strong answers look like

- Exercise 42 stated crisply: the two facts are counts of different things, one kept and one produced
  and discarded.
- Exercise 31 answered with the honest smaller number and an explicit statement of what it counts.
- Exercise 39 noticed `/dev/full` gives exit 0, and connected it to lesson 05.
- Exercise 45 recognised the check must be deliberate, because the kept evidence is identical in both
  cases.
- A student who reproduces the incident by hand with `>/dev/null 2>&1` and recognises what they just
  did has understood the chapter better than one who got the order right first time.

## Red flags

- Any narrative naming a person, or implying intent, around the two p-07 clamps. The lab supports a
  panel and two dates. A third sentence is a fabrication and should be marked as one, regardless of
  how plausible it sounds.
- Reporting the note words alphabetically or by count.
- Claiming the log is "wrong" or "falsified" with no engagement with what it is a true record of.
- Submitting a `STAGE{}` token as the flag.
- Concluding the tool is silent after `>/dev/null 2>&1 | wc -l` and stopping there.
- Claiming 284 nights, 284 incidents, or fourteen months of clamps on p-07.

## Partial credit

A student who found the flag but cannot state exercise 29 — why `grep` could never have found it —
has solved the puzzle and missed the chapter. Send them back to exercise 2.

A student who diagnosed the stream loss but never noticed p-07 has answered cass and missed the deck
log. Ask them to rank the clamps by panel and read `notes/clamping.txt` again.
