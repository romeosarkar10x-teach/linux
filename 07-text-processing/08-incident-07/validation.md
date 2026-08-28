# 07/08 — Validation rubric

For the AI validator. Chapter 7 finale. Sections 2 and 3 are must-pass. Submitting the correct flag
is necessary and **not sufficient** — the flag is three lookups deep and can be reached by a student
who never built the report.

## 1. The brief (exercises 1–8, 51–55)

Pass requires:
- States the deliverable as an object: ranked table, by account, counts, for the quarter.
- Knows AC-3 is the report and AC-9 is the finding.
- Names all four AC-3 requirements, including **the period stated on the report**.
- Proved the logs contain no non-record lines rather than assuming it.

## 2. The report (exercises 9–20, 61–63) — must pass

Requires all of:
- A ranked eight-row table with counts and shares, a header, and the period **computed from the
  logs**, not typed from the filenames.
- Evidence of stage-by-stage construction (lesson 07's method) — intermediate outputs, not just a
  final one-liner.
- The count column sums to 2435, checked.
- The header is added outside the sort.
- Saved and displayed in one pipeline.

A student who produces the correct final table with no evidence of having checked a count at any
stage has not passed this section.

## 3. Reading it (exercises 21–30, 41–45) — must pass

Requires all of:
- Names `eng-svc` as the finding and can say **how they found it**. "I read the last row of my own
  report" passes. "I grepped for something unusual" passes only with an explanation of what prompted
  it. Being told passes nothing.
- Quantifies `ops-bot` (1800, 73.9%) rather than dismissing it on the handover note's authority.
- Explains `maintenance`'s six as a schedule, from its lines.
- Explains the three prefixed counts from `grep -c` over three files.
- Explains why ranking by deck or action does not surface the finding.

## 4. Corroboration and restraint (exercises 31–40)

Pass requires:
- Confirmed `eng-svc` is absent from **both** snapshots, and knows their dates.
- Compared the log accounts against the snapshot accounts as sets, handling the comment lines.
- A statement of the finding with **no speculation in it** — every clause traceable to a file.
- Names at least one thing that cannot be learned from these files.
- **Names no person.** A student who attributes the account to anyone has failed this section
  regardless of the rest, because nothing in the lab supports it.

## 5. The flag (exercises 46–50)

`KESTREL{eng_svc_logged_in_once}`, submitted via `kestrel flags submit 07/08`.

Pass requires the student can say where each field came from: the account column with the dash
rewritten, the vocabulary table entry for `login`, and the frequency word for a count they computed.
A student who cannot name the source of field 3 has pattern-matched.

## 6. Judgement (exercises 56–60, 64)

Pass requires:
- A real position on ascending versus descending order, with the trade-off stated both ways.
- Recognises `eng-svc`'s zero-length first-to-last span as the shape that no other account has.
- On exercise 64, gives the argument for the `ops-bot` filter *and* the argument that it hides the
  day `ops-bot` is the story.

## 7. The Dig (exercises 65–70)

Four `STAGE{...}` tokens, in order:
`STAGE{tally_read_to_the_end}`, `STAGE{account_named_by_a_field}`, then the paste, then
`STAGE{once_counts}`. Pass requires four distinct skills named, and the observation that stage 1 has
the same shape as the incident.

## Red flags

- The flag submitted with no report in `reports/`.
- Any named person in connection with `eng-svc`.
- "The handover note said to read the top three" offered as a reason for anything.
- Treats `0.0%` as a finished answer for the `eng-svc` row.
- Cannot say what `wc`'s `total` line is.
