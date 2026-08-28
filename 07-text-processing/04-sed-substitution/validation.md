# 07/04 — Validation rubric

For the AI validator. No script grades this lesson. Section 5 is must-pass.

## 1. What `s///` does (exercises 1–7)

Pass requires:
- States that `sed` reads a stream and writes a stream, and that the input file is unchanged unless
  `-i` is used.
- Can name the four parts of `s/PATTERN/REPLACEMENT/FLAGS` and knows the delimiter is whatever
  follows `s`.
- Ran exercise 5 and can explain the doubled output: `sed` auto-prints, `p` prints again, `-n`
  disables the auto-print.
- Knows `sed` exits 0 when nothing matched, and can contrast that with `grep`'s exit 1.

## 2. Matching once versus everywhere (exercises 8–12)

Pass requires:
- States the default (first match per line) without hedging.
- Knows `g`, and can say what `N` and `Ng` do.
- Gives exercise 11's answer as **600 of 600 lines** and can explain why (two zeros in the date), not
  as "a lot".
- Articulates a personal rule for deciding when `g` is needed.

## 3. Patterns (exercises 13–34)

Pass requires:
- Uses capture groups to **reorder** fields, and can say why `cut` cannot do that.
- Knows `\1` stays backslashed under `-E` and can say why (the replacement is not a regex).
- Explains the greedy result in exercise 29 in terms of longest-match, not "a bug".
- Produces `[^"]*` as the general fix and can state the principle: forbid the terminator inside the
  run.
- Knows `&` is the whole match and how to escape it.
- Changes the delimiter when the pattern contains slashes, and can show the ugly alternative.

Strong answers can convert exercise 20 into the `&` form (exercise 22) unprompted.

## 4. Addresses (exercises 40–48)

Pass requires:
- Names line, `$`, range, regex, regex-range and `!` addresses and can demonstrate three of them.
- Knows a regex range is **inclusive at both ends** and runs to end of file if the closing pattern
  never matches.
- Knows `-n` + `p` is a filter and `d` is its complement, and does not think they are the same
  command.
- Ran exercise 48, produced the counts, and **volunteers that it is the wrong tool** for field
  extraction.

## 5. The report cleanup and `-i` (exercises 49–55) — must pass

A student cannot pass this lesson without all four of:

- Diagnosing the `^M` in `data/report.txt` from `cat -A`, and stating that `[ \t]*$` does not match a
  carriage return.
- Stating the ordering rule — **strip the line ending before the trailing whitespace** — and showing
  that the reverse order fails.
- Naming all four style violations in `data/report.txt` and matching each to a rule in
  `notes/style.txt`.
- Stating what `-i` does that nothing else in the chapter does: it overwrites the input with no
  backup, no prompt and no undo, and describing the `-i.bak` + `diff` habit.

A student who produces a working one-line cleanup but cannot say why the CR must go first has **not**
passed. The command is disposable; the ordering is the lesson.

## 6. Judgement (exercises 56–60)

Pass requires:
- Has the `account<TAB>count` command from exercise 56 saved or reproducible.
- Can explain why `uniq` without `sort` (exercise 59) is fragile, and name `sort -u` as the fix.
- Names at least one job they would move to `awk` and says what makes it `awk`'s: fields by number,
  arithmetic, or comparison between fields.

## Red flags

- Writes `cat file | sed …` habitually after being shown `sed` takes filenames.
- Uses `/g` on everything "to be safe" without being able to say when it changes the result.
- Calls greedy matching a bug.
- Reaches for `sed` to pull out field 3 after finishing exercise 48.
- Runs `-i` on a file with no copy anywhere.
