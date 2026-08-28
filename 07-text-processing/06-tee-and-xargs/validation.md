# 07/06 — Validation rubric

For the AI validator. No script grades this lesson. Section 3 is must-pass.

## 1. `tee` (exercises 1–12, 41, 58)

Pass requires:
- Uses `tee` to save and display in one pass, and can say the log was read once.
- Knows `tee` truncates and `tee -a` appends.
- Knows `tee` continues after a write failure, returns non-zero, and can say why that is the right
  behaviour for a pipeline component.
- Can explain the `cat f | tee f` hazard in terms of **the shell setting up redirections before either
  command runs**, not merely "it is dangerous".
- Knows `tee` before an early-exiting `head` saves only what flowed.

## 2. `xargs` mechanics (exercises 13–30, 46–47)

Pass requires:
- Can state what `xargs` is for in one sentence: turning a stream into arguments.
- Uses `-n`, `-I{}`, `-t`, `-a` and `-r` and knows `-I` implies one line per run.
- Read the `--replace and --max-args are mutually exclusive` warning and knows which flag was
  discarded.
- Knows `xargs` runs the command once on empty input unless `-r` is given.
- Has a working test for whether a command needs `xargs`, and can classify six commands with it.
- Knows exit status 123 means "some command failed" and that `xargs` does not stop at the first
  failure.

## 3. Filenames and separators (exercises 31–40, 44) — must pass

A student cannot pass this lesson without all four of:

- Reproducing the `ls | xargs` failure and naming which file caused it.
- Explaining why `find | wc -l` reported five for four files.
- Stating that **NUL is the only byte that cannot appear in a filename**, and therefore why
  `-print0`/`-0` is the only safe pairing.
- Writing a safe deletion command with all of `-print0`, `-0`, `-r` and `--`, and saying what each
  defends against.

A student who can drive `xargs` but writes `ls | xargs rm` when asked for the safe form has not
passed. This section is the reason the lesson exists.

Strong answers also identify the `sh -c` plus `{}` interpolation in exercise 44 as an injection
hazard and can give the `_ {}` positional form.

## 4. Combining, and the report (exercises 41–45, 48–54)

Pass requires:
- One pipeline that saves and displays and does not read the input twice.
- The two-day per-account table, with `maintenance` showing as **0** for 2187-06-09 rather than as a
  missing row, and an explanation of why a zero is better than a gap.
- A header added **after** sorting, with the connection to lesson 05 exercise 45 stated.
- Can say what the report is still missing (the date range) when asked to read it as its recipient.

## 5. Judgement (exercises 55–58)

Pass requires:
- Prefers one `awk` to a `xargs` loop when the body is text processing, with the process-count reason.
- Does not defend the exercise-55 one-liner.
- Gives a defensible answer on concurrent appends and does **not** propose `sed -i` for it.

## Red flags

- `ls | xargs` on filenames after section 3.
- Believes `--` is something `xargs` provides.
- Hides the SIGPIPE message without being able to say what caused it.
- Uses `tee` to edit a file in place.
- Reports a `total` line from a batched `xargs wc -l` without noticing there may be several.
