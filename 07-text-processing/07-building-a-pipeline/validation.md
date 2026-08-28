# 07/07 — Validation rubric

For the AI validator. Section 2 is must-pass. This lesson teaches a method, so the evidence you are
grading is the student's *process*, not only their final commands.

## 1. Reading the input (exercises 1–8, 48, 50)

Pass requires:
- Knows the file has 128 lines and 120 records, and can name the leftover line
  (`dump complete: rc=0`).
- Can argue why matching the record shape beats subtracting known junk.
- Uses 120 as a reference count later in the lesson without being reminded.

## 2. Growing and checking (exercises 9–20, 21–30, 57) — must pass

A student cannot pass without all of:

- **Evidence they looked after each stage.** Intermediate outputs, a `head` on a partial pipeline, or
  a narrative that names what each stage produced. A student who presents only the final command has
  not demonstrated the lesson even if the command is right.
- Diagnosing the field-4 failure themselves and explaining it in terms of **field count varying with
  severity** (`NF` is 6 and 7), not "awk was confused".
- Extracting by key name (`actor=`) rather than position, and stating the general rule.
- Using a count check at least twice, with the sums that match 120.
- Explaining why the exercise-12 count check passed on a wrong answer — that a check has a scope, and
  this one only proved nothing was dropped.

A student who cannot say what a check does *not* prove has not passed this section.

## 3. Debugging (exercises 31–40)

Pass requires:
- Correctly diagnosing at least four of the five: A `uniq -c` on all-unique lines; B no record filter
  plus ascending `sort -n`; C works but wastes two processes; D redirection consumes the pipe so
  `cat` gets nothing; E `grep -c` collapses the stream to one line.
- For C, distinguishing "wrong" from "wasteful" rather than calling it a bug.
- Naming which bug is hardest to catch in review, with a reason about how it *looks*, not how it
  works.

## 4. Exit status (exercises 41–47)

Pass requires:
- Knows a pipeline's status is the last stage's status.
- Uses `PIPESTATUS` correctly and knows it is only valid immediately after the pipeline.
- Knows `set -o pipefail` and can give a concrete pipeline it would break (`seq | head`, or any
  deliberate early exit).
- Knows `grep -c` exits 1 on a zero count.

## 5. The report (exercises 48–56, 62)

Pass requires:
- The four-row panel report with correct counts (p-c 4, p-a 3, p-b 3, p-d 3), summing to 13.
- Handled or explained the `-F,` applies-to-all-files problem rather than producing an empty column.
- A header added outside the sort.
- Saved and displayed in one pipeline with `tee`.
- On exercise 53, recognises the empty CSV field is `owner`, which this report never reads — missing
  data matters where it is read.
- Prefers the multi-line form for anything anyone else will read.

## 6. Judgement (exercises 59–61)

Pass requires a bisection strategy for a nine-stage pipeline that does not involve rewriting it, and a
non-absolute answer on pipeline-versus-`awk` that mentions both process count and readability.

## Red flags

- A final answer with no intermediate outputs anywhere in the transcript.
- `uniq` without `sort` surviving into a submitted pipeline.
- Claims the exercise-11 table is "close enough".
- Treats `NR` as a count of matched lines after exercise 58.
- Redirects into a file before the pipeline is right, then debugs by reading the file.
