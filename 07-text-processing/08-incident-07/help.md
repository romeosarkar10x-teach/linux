# 07/08 — Tutor guide: the tail of the report

The student will find the answer. That is not in doubt — there are eight rows and one of them is
weird. The lesson is **whether they find it by reading the report they built, or by being told to
look at the bottom.** Everything below protects the first outcome.

**Do not say "look at the last row." Ever.** If you say it, the lesson is over and they learned
nothing they will still have in six months.

## Sequencing

Make them build the report before anything else. Exercises 9–18 first, in order, one stage at a time
the way lesson 07 taught. A student who jumps to `grep eng-svc` has skipped the entire point, and the
point is the habit, not the account.

## Where students stall, and what to ask

**Exercise 1.** They will say "she wants the log analysed". Push until they can state the deliverable
as an object: a ranked table, by account, with counts, for the quarter.

**Exercise 4.** Some students will treat the handover note as an instruction. Others will dismiss it
because it is obviously a trap in a lesson. Both are wrong for the same reason. Ask: "is that advice
correct?" It is — about the top three. Ask what it does not say.

**Exercises 19–20.** This is the exercise. If they say "yes I read it", ask them to name the last
three rows from memory. If they cannot, they skimmed. Do not tell them what is there; send them back.

**Exercise 24.** If they have noticed `eng-svc` but shrug at it, ask what the number 1 means over
ninety days. If they still shrug, ask them to do exercise 25 first — `maintenance`'s six *is*
explainable, and explaining it is what makes the next row's silence loud.

**Exercise 28.** Expect surprise at three prefixed counts instead of one total. Good moment; ask what
question each form answers.

**Exercises 35–37.** The comment-line trap in the snapshot file catches people. If their `comm`
output has junk in it, ask what is in `scratch/snap-accounts.txt`, do not diagnose it for them.

**Exercise 40.** Watch for a student about to write a name. Stop them and ask which file says it.
None does. This matters beyond the exercise: the same student will do it in a real incident.

**Exercises 46–50.** Purely mechanical if they counted right. If the submission fails, the count is
wrong or the dash is still a dash — ask which of the three fields they are least sure of.

**Exercise 55.** Students defend `0.0%` because it is arithmetically correct. Ask what a reader
concludes from it in two seconds. Correct and misleading are compatible.

**Exercise 59.** Most say "sooner". Sit with them on it. Two events look like a pattern, and a
pattern looks explained.

## The scene

`scene.md` is the captain. Run it after the student has a first version of the report, not before —
the scene depends on having something to reject. If the student has not built anything, tell them to
come back with a draft.

## The Dig

Only after the flag is submitted. Stage 1 mirrors the incident (rank it, the answer is at the
bottom), which is deliberate — say nothing about it and see whether they notice at exercise 70.
Stage 3's line number is the incident's own count, so a student who miscounted fails there instead of
at submission. If they get a nonsense stage-4 decode, send them back to their `eng-svc` count.

## Do not

- Do not confirm or deny theories about who created the account. Nothing in the lab says. If the
  student invents a name, ask which file it came from.
- Do not let them submit before exercise 26 is actually run. A guessed count guesses the frequency
  word.
- Do not let `grep -r KESTREL` be treated as a bug. It returns nothing on purpose and they were told.
- Do not accept "ops-bot is noise" as an unsupported claim; there is a number for it and they should
  produce it.
