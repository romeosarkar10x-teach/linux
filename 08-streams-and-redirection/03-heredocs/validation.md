# 08/03 — Validation rubric: here-documents and herestrings

For the validating agent. There is no auto-grader. Judge the student's transcript and written
answers against these sections. Sections 1 and 2 are **must-pass**; a student who fails either has
not finished this lesson.

## 1. The mechanism (must pass)

The student can state that a here-document is a redirection of **fd 0**, and uses that to explain at
least one downstream consequence — that `sort`/`grep`/`bash` cannot tell it from a file, or that it
combines with `>` and `2>` on the same line, or that redirecting a `while` loop keeps it in the
current shell.

Fail if they describe it as "a multi-line string" and cannot correct themselves when asked how `sort`
reads it.

## 2. Quoting the delimiter (must pass)

The student can:

- state the rule: unquoted expands, **any** quoting (`'EOF'`, `"EOF"`, `\EOF`) disables expansion
  entirely
- name what is active in an unquoted body: parameter, command and arithmetic expansion, plus
  backslash escapes
- explain the `mkbanner` bug in terms of an unset variable expanding to nothing, and identify the
  one-character difference against `mkbanner-fixed`

Fail if they think there is a partial-expansion mode, or if they attribute the missing field names to
`cat`.

## 3. `<<-` (strong expectation)

The student states that `<<-` strips leading **tabs only**, from body lines *and* the delimiter line,
and has measured it — a transcript with `cat -A` in it, or the space-indented failure. An answer of
"it removes indentation" is not sufficient; probe with the tab-then-spaces case (exercise 38).

## 4. Failures that exit zero (strong expectation)

The student has run at least one of exercises 41–45, quoted the `here-document … delimited by
end-of-file` warning, and **recorded the exit status as 0**. They can say why a zero status on a
broken command is worse than a failure. Do not accept a guessed status.

## 5. Herestrings

The student uses `<<<` correctly and knows it adds a trailing newline (the 8-vs-7 measurement), and
can say when a pipe is the better choice.

## 6. Composition

At least one of:

- exercise 58 answered correctly (2 versus 0) with the word *subshell* in the explanation
- exercise 60 written as a single command with all three redirections
- exercise 56 run, with fd 1 and fd 2 separated

## 7. Reporting

The three-sentence answer to cass (exercise 61) states the mechanism, why the two scripts looked the
same, and a fix, without blaming a person and without the word "obviously". A student who names an
author of `mkbanner` has invented it — the lab does not say.

## Red flags

- Claims about `<<-` and spaces that were not measured.
- Exit statuses asserted rather than checked.
- Any hunt for a wrapper, a log path or a flag: exercise 75 is a one-sentence reasoning question and
  there is no flag in this lesson. A student who went looking should be redirected, not rewarded.
- A "fix" applied to anything under `bin/`. Work belongs in `scratch/`.

## Good signs

- They chose a distinctive delimiter unprompted after exercise 45.
- They noticed `templates/banner.txt` and used it as evidence about *which* fix is right.
- They ran the large-heredoc test (67) and saw the pipe become a deleted temp file.
