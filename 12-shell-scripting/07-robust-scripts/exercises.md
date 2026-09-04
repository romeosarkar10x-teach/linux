# 12/07 — exercises

Lab: `/labs/12-shell-scripting/07-robust-scripts`. Scratch in `scratch/`.
Quote errors exactly and record `$?` every time.

## A. `set -e` (1–12)

1. Write `scratch/a.sh`: `set -e`, then `false`, then `echo after`. Run it.
   Which line printed? What is the script's status?
2. Remove `set -e` and rerun. Status?
3. Run `bin/e-limits`. Which of its four numbered claims surprised you?
4. `set -e; false && echo yes; echo survived`. Why did the script survive?
5. `set -e; false || echo fallback; echo survived`. Same question.
6. `set -e; ! false; echo survived`. Same question.
7. Run `bin/e-in-if`. Record all three lines.
8. Read `check()`. Its first statement is `false`. Why did the second statement
   run?
9. Rewrite `bin/e-in-if` in `scratch/` so the failure inside `check` is actually
   detected. (There is more than one way; `check || handle` is one.)
10. `set -e; f() { false; }; f; echo after`. Does `after` print? Compare with 7
    and state the rule in one sentence.
11. Does `set -e` fire on the *last* command of a script? Test it.
12. Given all of the above, write two sentences on what `set -e` is for and what
    it is not.

## B. `-u` and `pipefail` (13–22)

13. Run `bin/u-demo`. Quote the error and the status.
14. `set -u; v=""; echo "[$v]"`. Does an empty variable trigger it?
15. `${missing:-default}` and `${missing:?not set}`. Run both under `set -u` and
    quote the second's message.
16. Write a script with `set -u` that uses `$1` and run it with no arguments.
    Now add a usage check before the first use of `$1`. Which error does the
    user see in each case, and which is more useful?
17. Run `bin/pipefail-demo`. Explain each of the three numbers.
18. `false | true` without pipefail gives 0. Which stage's status is a
    pipeline's status by default?
19. `yes | head -1` gives 141 under pipefail. Where does 141 come from? (`kill
    -l 13`.)
20. Is that a bug in your script, in `yes`, or in neither?
21. Write a pipeline in `scratch/` under `set -euo pipefail` that you expect to
    exit early, and guard it so the script survives without turning pipefail off.
22. `set -x` at the top of your script from 21. Read the trace; say one thing it
    shows you that you could not see before. Remove it.

## C. Quoting and `cd` (23–31)

23. Read `bin/unsafe`. List every unquoted expansion.
24. `bin/unsafe data`. What does it print, and what did it write?
25. `bin/unsafe` with **no argument**. Predict where `cd $dir` went, then check
    with a copy that echoes `$PWD`. What is the status?
26. Make a directory whose name contains a space and run `bin/unsafe` on it.
27. `bin/safe` on the same three inputs (a directory, nothing, a non-directory).
    Record all three statuses and messages.
28. Read `bin/safe` line by line and name the guard that handles each of 25, 26
    and a missing directory.
29. `cd /nonexistent; echo "now in $PWD"`. Now `cd /nonexistent || exit 1`. Why
    is the second form not paranoia?
30. `touch ./-rf; rm *` in `scratch/`. What happens? Clean up with `rm -- -rf`
    or `rm ./-rf`.
31. `find "$dir" -maxdepth 1 -mindepth 1 | wc -l` versus `ls | wc -l`. Give two
    inputs where they differ.

## D. `trap` (32–40)

32. Run `bin/trap-tour`. Record the order of the lines and the exit status.
33. Which trap ran last, and why is that the useful property?
34. The `ERR` trap fired and the script continued. What does `ERR` actually give
    you, then?
35. Add `set -e` to a copy of `bin/trap-tour`. Does the EXIT trap still run?
    Does the status still survive?
36. `trap 'echo "$msg"' EXIT` with `msg` set *after* the trap. Single quotes.
    Then try double quotes. Explain the difference in one sentence.
37. Write a script that creates a temp file, traps its removal on EXIT, and then
    fails halfway. Prove the file is gone.
38. Same script, but killed with Ctrl-C. Did the trap run? Add `INT` and retry.
39. `trap -p` in your shell. What is set? `trap - EXIT` removes one.
40. Set a trap inside a function and call the function. When does it fire? What
    does that tell you about the scope of traps?

## E. Temporary files (41–48)

41. Read `bin/tempfile-bad`. Name three separate problems with
    `tmp=/tmp/report.$$`.
42. Run it. It works. Explain why "it works" is not the same as "it is correct".
43. Make it fail after the temp file is created but before the `rm` (edit the
    copy in `scratch/`: add `exit 1` in the middle). Is the file left behind?
44. `bin/tempfile-good` with the same injury. Is the file left behind?
45. `mktemp` and `mktemp -d` by hand. Check the permissions of both with
    `ls -ld`. Why 600 and 700?
46. `TMPDIR=/labs mktemp`. Where did it go? Why does honouring `TMPDIR` matter on
    a machine where `/tmp` is small?
47. Two copies of `bin/tempfile-bad` running at the same time in the same shell:
    would they collide? Now think about two *users*. What is `$$` guaranteeing,
    and what is it not?
48. Rewrite `bin/tempfile-bad` yourself, from the top, with the header, `mktemp`
    and a trap. Compare with `bin/tempfile-good`.

## F. `shellcheck` (49–56)

49. `shellcheck bin/lint-me`. Count the findings.
50. `shellcheck -f gcc bin/lint-me`. Which format would you use in a commit hook?
51. Take them one at a time. Fix SC2006, then rerun. Then SC2086, then rerun.
52. SC2164 is about `cd`. Explain what it is protecting the *next* line from.
53. SC2115 is about `rm -rf $TMPDIR/*`. Say concretely what happens if `TMPDIR`
    is empty. Do not test this anywhere that matters.
54. Look up SC2126's suggestion and apply it. Is the result faster, clearer, or
    both?
55. `shellcheck bin/safe`. Is it clean? If it complains, decide whether to fix or
    to justify.
56. `shellcheck` your own scripts from 12/04, 12/05 and 12/06.

## G. Bring it together (57–62)

57. Rewrite `bin/unsafe` in `scratch/` completely: header, usage, validation,
    quoting, `mktemp` + trap, and a `shellcheck`-clean body.
58. Give it a non-zero exit for each distinct failure and document them in a
    comment block (12/02's exit-code conventions).
59. Test it with: no argument, two arguments, a file instead of a directory, a
    directory you cannot read, and a directory whose name has a space.
60. Take `bin/margin-check` from 12/06 and add the header. Does `set -euo
    pipefail` catch the octal bug? Say precisely why not.
61. Take `bin/tally` from 12/04 and add the header. Does it catch the subshell
    bug? Same question.
62. Write three sentences for `notes/`: what the header catches, what it does
    not, and what you will do instead for the second category. This is your
    answer to the 246-day-old request.
