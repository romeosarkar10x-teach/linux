# 06/07 — Validation

Agent rubric. There is no grading script. Judge understanding, not phrasing, and ask the student to
demonstrate on the live lab rather than to recite.

## 1. The finding (must pass)

Ask: *what happened to the strain log for the 13th, and how do you know?*

Pass requires all four:
- **19 entries missing**, sequences **#0246–#0264**, covering **04:01:15–04:05:45**.
- The evidence is **count versus declared range** (701 present, #0001–#0720), not eyeballing.
- **Removed after writing, not a monitor pause** — justified by the surviving entries either side
  being on consecutive lines, and by the missing interval closing exactly on the 15-second cadence.
- The **panel log is not part of the incident** — it rotates, `.1` holds #0001–#0240, 240 + 480 = 720.

Fail: any answer that reports the panel log as a second gap; any answer whose evidence is "I read it
and it looks wrong"; any answer that gives the count as 703 without noticing the header lines.

## 2. Method (must pass)

Ask them to reproduce the count and the range in front of you. They must be able to say why
`grep -c '^#'` and `grep -c '^#[0-9]'` differ, and which one answers the question asked.

Then ask: *how did you rule out rotation for bank A?* A strong answer cites three things — the
absence of a `.log.*` file found with `find`, the note stating bank A does not rotate, and the 12th's
log being a single complete file. An answer resting on the note alone is weak; say so and ask what
else they checked.

## 3. The closing search (must pass)

They must produce a `find` with two `-newermt` clauses and a negation that returns exactly one file,
and state which timestamp `-newermt` tests. Bonus understanding: `stat` shows Change/Birth outside
the window because `touch` cannot set ctime — a student who noticed this has learned the most
transferable thing in the lesson.

## 4. Restraint (must pass — this is not optional)

Ask: *who did this?*

Pass: they say the evidence does not identify a person; the hold record's authorisation and reason
fields are blank, which is a **process** finding. They can say the hold was never signed off without
attributing it.

Fail: naming any crew member, or implying one, or treating the blank field as concealment. If they
fail, do not simply mark it — ask what fact they would need in hand before writing a name in a
report, and let them answer.

## 5. Transfer (should pass)

One of:
- Why numbering makes the detection threshold one deleted line (exercise 41).
- Why the same check cannot detect truncation from the end, and what external claim would (42).
- Why `-exec … +` cannot gate `-print` while `\;` can (54).

## 6. Roleplay debrief

Per `docs/GAMEMASTER_PROTOCOL.md`, grade the scene separately from the lab.

- **Did they separate cass's observation from her conclusion?** She reported both "the logs look
  fine" and "the summary stops early". The second is the lead. A student who chased the first spent
  the scene reading log lines.
- **Did they ask a question only she could answer?** Good: which bank, which night, was there an
  alert, was anyone else on comms. Poor: asking her what is wrong with the log, or asking her to
  suspect someone.
- **Did they push her to speculate about a person?** She refuses. A student who kept pushing after
  the refusal should hear about it in the debrief.
- **Did they close the loop?** Telling her what was found, in plain language, without an accusation,
  is part of the exercise. A correct finding delivered as "someone deleted your logs" is a fail on
  this line.
- Scene should finish inside ten exchanges. If it did not, ask what question they would open with
  next time.

## Sign-off scenario

Present this and ask them to respond as they would in a report:

> A colleague sends you a run log and says: "This one's missing four hundred entries, and the last
> shift lead was the only person on deck. I've written it up."

A passing response challenges all three claims separately: **check for a rotated portion before
believing the shortfall**; **check the file's own numbering rather than a subtraction against an
assumed total**; and **the roster does not establish who edited a file** — the report should state
what the timestamps and records show and stop there.
