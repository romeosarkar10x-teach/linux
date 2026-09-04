# 12/02 — validation

Rubric for the validating agent. No auto-grading.

## Must demonstrate

- [ ] Can state, without looking it up, what `"$@"`, `$@` and `"$*"` each do
      with the argument list `"cargo hold" beta`, including the counts.
- [ ] Explains `"$@"` with no arguments as an **empty list**, contrasted with
      `"$*"` as one empty word.
- [ ] Found **both** bugs in `bin/deck-report` — the unquoted redirect and the
      unchecked report — and identified which one `deck-report-2` fixed.
- [ ] Traced an argument through `relay` and can point at the quote marks that
      changed the count downstream.
- [ ] Used `shift` in a loop with an explicit `$#` condition, and knows what
      `shift` returns when there is nothing left.
- [ ] Wrote a script that checks `$#`, writes usage to stderr, and exits
      nonzero — and can say why `--help` is the opposite case.

## Strong answers look like

- Exercise 19: quoting is required at every hop; downstream cannot repair it.
- Exercise 26: names bug (b) as the one that outlives the fix.
- Exercise 27: "the bug was always there; the data made it visible."
- Exercise 28: a redirection target is opened by the shell, not parsed by the
  program, so a leading dash is harmless there and fatal as an argument.
- Exercise 30: a reply that credits rhea for escalating and names the mechanism.
- Exercise 52: gives the rename its strongest case before rejecting it.

## Red flags

- "Quoting is a style thing."
- Fixing `deck-report` by renaming `cargo hold`, without argument.
- A reply to rhea that implies user error.
- `while shift; do` left in a final answer without noticing the dropped first
  argument.
- Usage messages on stdout, or a usage failure exiting 0.
- Using `$*` in a new script with no comment explaining why.

## Not required

- `getopts` or long-option parsing — that is 12/08.
- `case` — 12/05.
- Arrays — 12/06. A student using `"$@"` correctly needs neither.

## Follow-up questions

1. "Your script works on every deck we have. Name the deck name that breaks it."
2. "Something failed in the middle and your script exited 0. Where did the
   status go?"
3. "Where in this chain would one missing pair of quotes be unrecoverable?"
