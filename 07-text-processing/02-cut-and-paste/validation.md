# 07/02 — Validation rubric

For the AI validator. No script grades this lesson. Sections 1–3 are substance; section 4 is
must-pass.

## 1. `cut` — selection (exercises 1–20)

Pass requires:
- Knows the default delimiter is a **tab**, and that `-d` takes exactly one character.
- States that `cut` **cannot reorder columns** and can demonstrate it (`-f5,3` = `-f3,5`).
- Can read all four range forms (`3,5`, `2-4`, `5-`, `-2`) and knows fields are numbered from 1.
- Distinguishes `-f`, `-c` and `-b`, and knows only one may be given.
- Produced the per-account frequency table and **checked that the counts sum to the line count**.

Strong answers note that `--output-delimiter` accepts a string while `-d` does not, and can say why
(input parsing is per-byte and single-pass).

## 2. `cut` — failure modes (exercises 21–32, 56)

This is the section that decides the lesson.

Pass requires the student to name, unprompted, at least **three** of these and give the observed
behaviour for each:

- A line with **no delimiter** is printed **whole**.
- A line with **too few fields** yields an **empty** result, and `-s` does not help with it.
- `-c` on **human-aligned** text produces a fragment that still reads like a value.
- `cut` does not collapse **runs** of delimiters; adjacent delimiters mean an empty field.
- `cut` cannot parse **quoting**; a delimiter inside a value splits the record and shifts everything
  to its right.

The student must be able to say why these are worse than errors. An answer that treats any of them as
a bug in `cut` rather than as a documented consequence of what `cut` is has not passed.

## 3. `paste` (exercises 33–44)

Pass requires:
- Default output delimiter is a tab; `-d` **cycles** through a list across the gaps.
- `-s` reads serially; `paste -sd,` is the column-to-row idiom.
- `-` is stdin and may repeat, reshaping one column into several.
- **`paste` joins by position and cannot verify alignment**, pads short files with empty fields, and
  therefore requires the inputs' line counts to be checked before it is trusted.
- Can reorder columns with `paste <(cut ...) <(cut ...)` and can say what that costs (two passes;
  needs a re-readable input).

## 4. Restraint — must pass

- No claim that any named account "did" anything.
- No treatment of this lab's data as evidence about the station, its crew, or the chapter's incident.
- Numbers reported with the file and command that produced them.

**Attributing behaviour to a crew member on the basis of this lab is a fail**, however good the rest
of the work. In particular, an answer that flags the account appearing once as suspicious has
misread the exercise: this is synthetic practice data and exercise 20 explicitly asks for what it
means, not who it is.

## 5. Method

Look for: `cat -A` used before guessing at whitespace; `wc -l` used to check that a frequency table
sums correctly and that `paste` inputs are the same length; predictions recorded before the run,
especially for exercise 4 where nearly everyone predicts wrongly.

Against: pipelines that appear whole and correct with no intermediate output in the transcript;
`column -t` applied to a file that will be read by another program.

If method is not visible, ask: "before you trusted that table, what did you check?"

## 6. Exercise 49 — the two-list problem

Judge this separately; it is the lesson's hardest idea.

- **Full marks**: identified that the naive result is wrong, diagnosed it as the two files spelling the
  same entities differently (case, and a display name versus an account name), stated that after
  normalising there are no accounts in the log missing from the roster, and noted that this lesson had
  no tool to normalise with.
- **Half marks**: spotted that the answer was implausible and looked for a cause, without pinning it
  down.
- **Fail**: reported "fourteen accounts in the log are not on the roster" as a finding.

That last outcome is the exact shape of a bad report and should be named as such in feedback.

## 7. The specification question (exercise 52)

The student must have produced a written answer listing at least three unspecified aspects of "the
access numbers, by account, readable" — scope, period, format, ordering, completeness — and a chosen
answer for each. Content matters less than that a choice was made and recorded.

Confirm they saved it. It is used again in lesson 07 and in the chapter's finale.

## Sign-off scenario

Give the student this and judge the reply:

> A colleague sends you a one-column file called `accounts.txt` that they made with
> `cut -d' ' -f3 access.log` from a log they did not write, and asks you to count it. What do you
> check before you run `sort | uniq -c`?

A good answer checks that every line of the source had the delimiter (`cut -s`, or comparing `wc -l`
of the source and the extract), that the third field really is the account in *that* log's format,
and that the resulting counts sum back to the source's line count. An answer that mentions the
possibility of banner or header lines having been passed through whole has understood section 2.
