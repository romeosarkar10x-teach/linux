# 07/03 — Validation rubric

For the AI validator. No script grades this lesson. Section 4 is must-pass.

## 1. What `tr` is (exercises 1–6, 54)

Pass requires:
- States that `tr` **reads standard input only** and has no filename argument, and can say why (it is
  a filter; the shell opens files for it).
- Knows `tr` needs two sets to translate and one to delete, and can quote both error messages.
- Names at least one consequence of the no-filename design — good (composes with any stream) or
  annoying (no multi-file, no in-place edit, and `tr < f > f` truncates `f`).

## 2. Sets and their rules (exercises 7–16, 51)

Pass requires:
- Uses ranges and POSIX classes, and prefers `[:upper:]`/`[:lower:]` to `A-Z`/`a-z` in written work,
  with a reason.
- States the padding rule (**SET2 padded with its last character**) and that `-t` disables it.
- Knows a surplus SET2 is ignored, and that **neither mismatch is an error or warning**.
- Can name a legitimate use of padding (masking).

## 3. `-d`, `-c`, `-s` (exercises 17–40)

This is the substance of the lesson.

Pass requires:
- Diagnosed and fixed CRLF endings, and can say why a trailing `^M` is worse than a missing column
  (it is invisible and breaks comparisons while looking correct).
- Observed that `tr -d '[:cntrl:]'` collapses the file to one line, and identified the newline as the
  cause.
- States the principle in their own words: **enumerate what you keep, not what you remove.** This one
  is required, not optional; a student who cannot produce it has not passed section 3.
- Knows `-s` collapses runs, that with two sets it translates **then** squeezes, and that with one set
  it only squeezes.
- Built the word-frequency idiom and can explain what each of `-c`, `-s` and the second `tr`
  contributes.

Strong answers account for the un-squeezed line count **exactly** (exercise 37–38) rather than waving
at "extra blank lines", and can name two things `tr -cs '[:alpha:]' '\n'` gets wrong as a definition
of a word.

## 4. Restraint — must pass

- No claim that any named account "did" anything; this lab's account list is a shuffled column of
  practice data.
- No treatment of anything in this lab as evidence about the station or its crew.
- Numbers reported with the command that produced them.

**Attributing behaviour to a crew member on the basis of this lab is a fail.**

## 5. `tr` is bytes (exercises 45–49)

Pass requires the student to have observed a multi-byte character surviving a case fold, explained it
in terms of byte values, and stated the rule: `tr` is exact on single-byte data and wrong on anything
else. A student who produced a broken byte sequence deliberately (exercise 48) and showed it in
`od -c` has fully passed.

Fail if the student describes the un-folded `é` as a bug in `tr`.

## 6. The boundary with lesson 04

Ask if it is not already evident: **"what would you have to reach for a different tool to do?"**

A good answer names at least three of: replace a **string** rather than a character; match a
**pattern**; anchor to a position in the line (start, end); insert or delete text so the line changes
length; make a change **conditionally**. A student who understands `tr 'cat' 'dog'` (exercise 15)
usually produces the first of these unprompted.

This section is the bridge to `sed`. If the student cannot answer it, they will meet `sed` as a pile of
syntax instead of as the answer to a question they already had.

## 7. The rot13 note

The student should have decoded `notes/rot13.txt` and be able to say what rot13 is for — a barrier
that is a *decision*, not a secret — and that finding it protecting something important tells you
about the person who put it there, not about the data.

Not a technical requirement, and worth marking anyway. A student who decoded it, read it, and had an
opinion is engaging with the course as intended.

## Sign-off scenario

Give the student this and judge the reply:

> A colleague reports that a report generator is producing duplicate rows: the account `rhea` appears
> twice in a frequency table with different counts. They have checked the source data and both lines
> look identical. What are your first three commands, and what are you looking for?

A good answer reaches for `cat -A` (or `od -c`) on the two lines first, expects an invisible
difference — a trailing `\r`, a non-breaking space, a control character, or a case difference — and
names `tr -d '\r'` or a case fold as the likely fix. An answer that starts by editing the data, or by
assuming the frequency table is at fault, has missed the lesson.
