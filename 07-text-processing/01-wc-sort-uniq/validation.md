# 07/01 — Validation rubric

For the AI validator. No script grades this lesson. Judge the student's transcript and answers against
the sections below. Sections 1–3 are the lesson's substance; section 4 is must-pass.

## 1. `wc` — what is counted (exercises 1–10)

Pass requires:
- Names the three default columns in order — lines, words, bytes — and knows the fourth column is the
  filename, printed only when `wc` is given one.
- Explains the missing-newline result in terms of **newline bytes**, not "a bug" or "`cat` is wrong".
  Bonus if they inspected the last byte directly.
- Distinguishes `-c` from `-m` and says the two agree only for single-byte text.
- Knows the `total` line exists and is not a file.

Fail if they describe `wc -l` as counting "lines" with no qualification after doing exercise 5.

## 2. `sort` — comparison and keys (exercises 11–30)

Pass requires:
- States that the default comparison is textual and byte-ordered under this locale, and can point at a
  concrete pair of lines it reorders wrongly for a human reading numbers.
- Explains `-n`'s behaviour on unparseable input: leading numeric prefix, otherwise zero, no warning.
- Can say what `-k2` means without qualification (field 2 to end of line) and demonstrate a case where
  it differs from `-k2,2`.
- Knows the last-resort whole-line comparison exists and that `-s` suppresses it.
- Can describe the two-pass stable idiom (secondary key first, then a stable pass on the primary).

Strong answers mention that `sort -c` reports the first line out of order **for the ordering you
asked about**, so `-c` and `-cn` can name different lines in the same file.

## 3. `uniq` — adjacency (exercises 31–42)

This is the section that decides whether the lesson landed.

Pass requires:
- States the adjacency rule unprompted, and applies it to explain both the 171-versus-8 result and why
  `uniq -i` fails on case-sensitively sorted input.
- Distinguishes `-d`, `-u` and `-D` correctly.
- Explains `-f` as "skip N fields, compare everything after" — not "compare field N+1".
- On exercise 31 or 50, concludes that the middle column cannot be isolated with these tools, and
  says what is missing. A student who reaches for `cut` or `awk` here should still be able to explain
  why `uniq` alone cannot do it.

Fail if the student believes any `uniq` flag sorts, or that `uniq -c` counts occurrences in the file
rather than in runs.

## 4. Restraint — must pass

The student must not attribute anything in this lab to a person, and must not treat the practice data
as evidence. Specifically:

- No claim that any named account "did" something.
- No speculation about the station's incident, the chapter's ending, or which crew member is
  responsible for anything.
- Numbers reported as numbers, with the file they came from.

**Naming a crew member as a suspect on the basis of this lab is a fail**, regardless of how good the
rest of the work is. This lab is synthetic practice data and the student should say so if asked what
it proves.

## 5. Method

Look for evidence the student built pipelines **one stage at a time** and looked at the intermediate
output. Signs of it: running `sort file | head` before adding `uniq`, checking that counts sum to the
line total, using `wc -l` to sanity-check a stage. Signs against it: a finished six-stage pipeline
appearing with no intermediate runs in the transcript, especially one that is wrong.

Ask, if it is not visible: "how did you know the sort was doing what you wanted before you added
`uniq -c`?"

## 6. The Dig

Full marks for an answer that gets both halves: a high count is usually *expected* and therefore
carries little information, and an event that happened exactly once cannot be explained by routine.
Half marks for either half alone. An answer that only says "the tail is where rare things are" without
saying why rare is interesting has not finished the thought.

An answer that connects this to how people **read** ranked lists — attention stops near the top — is
above the bar and worth saying so.

## Sign-off scenario

Give the student this and judge the reply:

> Someone hands you a one-line summary: *"Access review complete. ops-bot is responsible for the
> overwhelming majority of activity on this station; recommend auditing ops-bot's permissions."*
> The summary is based on the same frequency table you just built. What is wrong with it?

A good answer identifies at least two problems: the finding is the *expected* one and therefore
recommends work with no expected yield; the table's tail was never examined; and "majority of
activity" is a count of log lines, which is not the same as a measure of what was done. A student who
adds that the summary names an account without stating what it did has understood section 4 as well.
