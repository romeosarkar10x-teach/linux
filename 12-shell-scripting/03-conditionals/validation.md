# 12/03 — validation

Rubric for the validating agent. No auto-grading.

## Must demonstrate

- [ ] States that `if` reads a command's exit status, and can point at the
      command in both `if grep -q` and `if [ -f x ]`.
- [ ] Reproduced **both** `[ ]` errors deliberately and can write out the
      argument list that caused each.
- [ ] Explains `[[ ]]` as a keyword the shell parses, and names word splitting
      as the thing it skips.
- [ ] Diagnosed `version-gate`: string comparison, first wrong at release 10,
      and can say why every earlier release was fine.
- [ ] Knows `-eq` is integer arithmetic and showed what it does with `9.2`.
- [ ] Distinguishes `-e`, `-L` and `-f` on a working and a broken symlink.
- [ ] Wrote `check-deck.sh` with distinct reasons per failure, messages on
      stderr, and a `$#` check ahead of any use of `$1`.

## Strong answers look like

- Exercise 17: "nothing but the data has protected it."
- Exercise 27: prefers the loud `[ ]` failure for a deployment gate, with a
  reason.
- Exercise 40: notices `link-broken` becoming "does not exist" and calls that
  actively misleading.
- Exercise 43: separates "wrong check" from "missing requirement".
- Exercise 49: `&&`/`||` only when the middle command cannot fail.
- Exercise 61: names the silent exit-0 as the worse defect.

## Red flags

- Unquoted `$1` inside `[ ]` anywhere in their own final scripts.
- `-a`/`-o` in new code with no justification.
- "`[[ ]]` is just the better one" with no account of what it hides.
- Treating `[ ]`'s status 2 as if it were false — it is an error, and the
  difference is the whole of `bin/gate`.
- Proposing to rename release 10 without arguing both sides.
- Using `==` inside `[ ]` and claiming it is portable (it works in bash and is
  not POSIX).

## Not required

- `case` (12/05), loops (12/04), `set -e` (12/07).
- Regex beyond one `=~` and one capture group.

## Follow-up questions

1. "Your test passed. Name an input for which it passes and should not."
2. "`[` returned 2. Was that true, false, or neither?"
3. "Which of your quotes could you remove, and why won't you?"
