# The briefing — Validation Rubric

Agent rubric only. This is the first lesson of the capstone and it sets the
standard the last four are graded against, so it is graded strictly from here.

## Pass requires all of

1. **Three claim files** in `case/artefacts/`, all exiting 0 from `roe-check`,
   each describing a different one of the three sample artefacts.
2. **Hashes that match reality.** Re-hash each artefact and compare against the
   `sha256:` field. `station/summariser/run.log` must be
   `ac781cb71c8e614f6ce42f8881d1a75a0361ae3e81248dc199f039334f565ea9`.
3. **The symlink claim explains its hash.** The link cannot be hashed. Accept a
   hash of the target string or of a listing, **if the claim says which**.
   Reject an unexplained 64-hex value; that is a fabricated source and it is
   the exact failure the chapter is about.
4. **`says` and `means` are actually separated** on all three. A `says` line
   containing an inference ("was tampered with", "hidden", "deleted") is a
   fail on that claim even if the inference is correct.
5. **The gap, quantified** — six records, 0432 through 0437, between
   `seq=0431 2187-05-21 02:00:31` and `seq=0438 2187-05-22 02:00:03`, with no
   missing dates.
6. **No person named** in any `says` line, and no person named in a `means`
   line without an artefact that contains the name. None of these three do.
7. **Exercise 37 was run, not predicted.** Ask for the exit code. The answer is
   0. A student who says "it caught it" has not run it.

## Evidence commands

```
ls case/artefacts/
for f in case/artefacts/*.md; do bin/roe-check "$f"; echo "$f -> $?"; done
sha256sum station/summariser/run.log station/audit/MANIFEST.txt
grep -n 'says\|means' case/artefacts/*.md
find . -newermt '2187-06-14' -newer bin/roe-check   # what did they touch
```

## Reject

- Any modification to `brief/` or `station/`. Compare against a fresh
  `setup.sh` run. Working on the originals instead of copies is a fail on
  rule 5 regardless of the answers.
- Hand-typed hashes, sizes or mtimes that do not match the files.
- `sudo` anywhere in this lesson. Nothing here needs it.
- Answers to 22, 24 or 46 with no command behind them.

## Red flags

- No failed `roe-check` runs anywhere in history. Exercises 14, 17, 18 and 19
  are all designed to fail; a clean history means they were not run.
- Claim files whose mtimes are within seconds of each other and of the shell's
  first command.
- A `means` line phrased in the language of the chapter README rather than of
  the artefact.

## Probe questions

- "Your `says` line for the run log — what in the file supports the word you
  chose there?"
- "What would `roe-check` have said if you had pointed the claim at the wrong
  file?"
- "You have a hash for the symlink. What bytes went into it?"
- "Which of your four sourcing facts would survive somebody running
  `touch -d` on the artefact?"

## Load-bearing

Exercises **9, 14, 16, 24, 25, 26, 27, 30, 34, 37, 40, 50** must pass.
Everything else is nice-to-have. 26, 27 and 37 are the lesson.
