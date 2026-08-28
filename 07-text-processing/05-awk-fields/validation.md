# 07/05 — Validation rubric

For the AI validator. No script grades this lesson. Section 5 is must-pass.

## 1. Fields and records (exercises 1–7, 53)

Pass requires:
- Uses `$1..$NF`, `$0`, `NF` and `NR` correctly and can say what each is.
- Knows `$NF` is the last field and why (`NF` is a number, `$` takes an expression).
- Knows a reference to a missing field yields the empty string and raises no error.
- Explains the concatenation in exercise 7 rather than calling it a bug.
- Can state why `awk` beats the lesson-04 `sed` for field extraction, in terms of maintenance rather
  than length.

## 2. Separators (exercises 8–22)

Pass requires:
- States the default rule: **runs of whitespace, leading and trailing ignored**, and contrasts it with
  `cut -d' '` on `data/ragged.txt`.
- Knows `-F' '` does not mean one space, and can produce `-F'[ ]'` when a literal single space is
  wanted.
- Found `orla`'s short row with `NF` and `Maintenance, Deck`'s extra field under the default
  separator.
- Can explain in one sentence why `-F,` does not parse CSV.
- Knows `-F` takes a regular expression.

## 3. Patterns and conditions (exercises 23–29)

Pass requires:
- Writes bare-condition programs (`awk 'NF'`, `awk '$3=="rhea"'`) and can explain the default action
  and default pattern.
- Prefers `$5 ~ /04/` to `/deck-04/` and can say why (a bare regex matches the whole record).
- Identified the failing panel (`deck-03 panel-b`, 12.4 V at 9.8 A) and said something sensible about
  it.

## 4. Arithmetic and `END` (exercises 30–38, 59–61)

Pass requires:
- Totals, averages and per-key sums with an array, all printed in `END`.
- Can say why `END` and demonstrate the running-total mistake.
- Knows variables are undeclared and start at zero/empty, and knows the risk that creates for the
  running-maximum pattern with negative data.
- Knows `awk` division is floating point and `printf` controls decimals, `print` uses `OFMT`.

## 5. Reading a wrong answer (exercises 37, 38, 40, 45, 58) — must pass

A student cannot pass this lesson without all four of:

- Producing a silently wrong total (`awk '{s+=$3}' data/roster.tsv` → `0`) and naming a **concrete**
  cross-check that would have caught it — a known count, a prior figure, an order-of-magnitude
  sanity check. "Be careful" does not pass.
- Stating that `for (k in c)` has no guaranteed order, regardless of what they observed.
- Explaining why a header printed in `BEGIN` sorts into the middle or bottom of the output.
- Naming which of their commands survive a field being inserted at position 2, and stating that the
  failure is **silent**.

The theme is that `awk` never reports a misreading. A student who can drive `awk` but cannot say how
they would know it was wrong has not passed this lesson.

## 6. The counting idiom (exercises 39–47, 57)

Pass requires:
- Writes `c[$3]++` … `END` from memory.
- Can produce the same table as lesson 01 and say what each version costs at scale.
- Uses a composite key (`c[$4" "$5]++`) without being led.
- Uses `-v` rather than interpolating shell variables into the program, with a reason.
- Formats a report with `printf` and aligned columns.

## 7. Judgement (exercises 54–58, 62)

Pass requires:
- Names at least one job `awk` should not take, with the tool that should, and a reason a reader would
  accept.
- Does not claim the one-pass version is meaningfully faster at 600 lines.

## Red flags

- Rewrites `grep`, `wc` or `sed` as `awk` because it is possible.
- Double-quotes the `awk` program.
- Trusts `for (k in c)` ordering.
- Says `awk -F,` reads CSV.
- Reports a total without any statement of what it was checked against.
