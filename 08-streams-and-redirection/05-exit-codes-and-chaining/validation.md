# 08/05 — Validation

For the validator agent. Rubric only; there is no grading script. Ask for evidence — a command and
its output — not a claim.

## Must be able to do

1. Read `$?` correctly, and explain why `bin/rc 3; echo $?; echo $?` gives two different numbers.
2. Name 0, 1, 2, 126, 127 and 128+N, and say who produces 126 and 127 and how they differ.
3. Show that exit status is one byte: `exit 300` is 44, `exit 256` is 0, `exit -1` is 255 — and say
   why the second one is dangerous.
4. State the `&&` / `||` rule and predict `true && false || echo C` correctly **before** running it,
   with a left-to-right explanation.
5. Show a status being lost, at least two ways from: a following command clobbering `$?`, `!`,
   `local v=$(…)`, a non-final pipeline stage, a script ending in `echo`.
6. Diagnose the lab: `bin/checkbank B` prints a failure on both fds and exits 0; `bin/deckcheck`
   decides on status alone; therefore `logs/deckcheck.log` says `bank B ok`. All three links stated.
7. Fix it, and prove the fix by running the walk against `checkbank-fixed` and showing
   `bank B FAILED` in the log.
8. State at least three of the contexts in which `set -e` does not fire, including the one that makes
   `set -e` inside `checkbank` useless here.

## Strong answers look like

- Exercise 49/59 distinguishes "the log is wrong" from "the log is a true record of the wrong
  predicate". A student who reaches that sentence unprompted has the lesson.
- Exercise 53 explained as *the whole function body loses `set -e` because the call is a condition*,
  not as "bash ignored my error".
- Exercise 57's rewrite still checks every bank and exits non-zero at the end — a rewrite that stops
  at the first failure has changed the behaviour and should be asked about.
- Exercise 62 proposes verifying the tool, not just calling it.

## Red flags

- `$?` described as "the error variable" or as holding a history.
- `&&`/`||` described as if/else with no mention of precedence, after exercise 22.
- "`set -e` fixes it" with no engagement with exercise 53.
- Claiming `bin/checkbank B` is silent — it is loud on both fds; the *status* is the quiet part.
- Reporting a status from `try`-style wrappers without noticing a `tee` or `if` in between.
- Naming a person as responsible for anything in this lab. Nothing here supports that, and cass's
  page is a question, not an accusation.

## Partial credit

A student who diagnoses the walk correctly but cannot yet articulate exercise 60 has passed the
mechanical objective and not the reading one; send them back to `notes/page.txt` with exercise 41 in
hand.

A student who gets every number right and cannot explain why `logs/deckcheck.log` is not simply wrong
should not move on to `06-incident-08` — the incident is the same distinction at station scale.
