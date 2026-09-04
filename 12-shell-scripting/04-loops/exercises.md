# 12/04 — exercises

Lab: `/labs/12-shell-scripting/04-loops`. Scratch work in `scratch/`.
Every "quote it" means: copy the output exactly, and record `$?`.

## A. `for` walks a list of words (1–9)

1. `for x in a b c; do echo "[$x]"; done`. How many iterations?
2. `for x in "a b" c; do echo "[$x]"; done`. How many now, and why?
3. `for x in $(echo "a b" c); do echo "[$x]"; done`. Explain the difference from 2
   in terms of when splitting happens.
4. `for x in {1..5}; do echo -n "$x "; done; echo`. Which expansion is this, and
   does it run before or after variable expansion?
5. `for ((i=0;i<3;i++)); do echo "$i"; done`. Does this work under `sh`? Try
   `sh -c 'for ((i=0;i<3;i++)); do echo $i; done'` and quote the error.
6. `for f in decks/*.log; do echo "$f"; done`. Count the lines. Which file has a
   space in it, and did it stay one word?
7. `for f in decks/nomatch*; do echo "[$f]"; done`. How many iterations, and what
   is `$f`?
8. Repeat 7 with `shopt -s nullglob` first. Then `shopt -u nullglob`.
9. `set -- one "two three"; for x in "$@"; do echo "[$x]"; done`. Two iterations
   or three? Tie this back to 12/02.

## B. Why not `$(ls)` (10–17)

10. `cd decks && ls *.log`. How many names, and how are they separated?
11. `cd decks && for f in $(ls *.log); do echo "[$f]"; done`. Count the
    iterations. Name the two words that came out of `cargo hold.log`.
12. Run `bin/count-decks-ls` from `decks/`. Quote every error line.
13. Run `bin/count-decks-glob` from `decks/`. Quote the line for the cargo hold.
14. `diff` the two scripts. Exactly one line differs. Which?
15. Is there an `ls` option that fixes 12? Try `ls -1`, `ls -Q`. Say precisely
    which stage of the pipeline the damage happens in.
16. `IFS=$'\n'; for f in $(ls *.log); do echo "[$f]"; done`. Does this fix it?
    What does it break instead (hint: a filename containing a newline, and every
    later command in that shell)?
17. State the rule in one sentence, without using the word `ls`.

## C. `while read` and its three parts (18–29)

18. `cat -A manifests/awkward.txt`. Describe each of the four lines: what is at
    the start, what is at the end, what is in the middle.
19. `while read line; do echo "[$line]"; done < manifests/awkward.txt`. Quote all
    output.
20. Same with `read -r`. Which line changed, and what came back?
21. Same with `IFS= read -r`. Which line changed now?
22. Name what each of `IFS=`, `-r` and `< file` is protecting against, one clause
    each.
23. Run `bin/read-manifest`. It does all three. Confirm your answers to 19–21.
24. Count the lines in `manifests/awkward.txt` with `wc -l`. Now count the
    iterations of the loop in 21. They disagree. By how many?
25. `tail -c 1 manifests/awkward.txt | xxd`. What is the last byte? Now explain
    24.
26. `while IFS= read -r line || [ -n "$line" ]; do echo "[$line]"; done <
    manifests/awkward.txt`. How many iterations now?
27. Why `|| [ -n "$line" ]` and not `|| true`? Predict first, then run it —
    and have Ctrl-C ready, because the prediction you should arrive at is not
    "it prints one extra line". Say exactly what condition never becomes false.
28. Does `read` set `$line` before it returns false on that last line, or after?
    Design a one-line test that proves your answer.
29. `printf 'a\nb' | wc -l`. Explain the number in terms of 25.

## D. The subshell (30–39)

30. `n=0; printf '%s\n' a b c | while read -r x; do n=$((n+1)); done; echo "n=$n"`.
    Predict, run, quote.
31. Add `echo "inside: $n"` as the last line of the loop body. What does it print
    on the third iteration?
32. So the counting worked. Say in one sentence where the answer went.
33. Run `bin/tally` from `decks/`. Quote its output and `$?`.
34. `grep -l FAULT *.log` on its own. How many names? Which deck?
35. Is `bin/tally`'s `grep` wrong, its loop wrong, or neither? Be specific.
36. Rewrite `tally` in `scratch/` using `< <(grep -l FAULT *.log)`. Verify.
37. Rewrite it again using `$(grep -c ...)` or `| wc -l` with no loop at all.
    Which of your two versions would you ship, and why?
38. `shopt lastpipe`. Read `help shopt` on it. Turn it on in a non-interactive
    script and re-run 30. Does it help? Does it help in an interactive shell?
39. Connect this to 12/01 (execute vs source) and 11/01 (`export`) in one
    sentence about parents and children.

## E. `until`, `break`, `continue` (40–47)

40. `i=0; until [ $i -ge 3 ]; do echo $i; i=$((i+1)); done`. Rewrite as `while`.
41. Which reads better for "retry until the port answers"? For "loop while there
    is input"? Say why.
42. Run `bin/first-fault` from `decks/`. Quote the output.
43. Remove the `break` from a copy in `scratch/`. What changes in the output, and
    what changes in the runtime?
44. `for i in 1 2 3 4 5; do [ $((i%2)) -eq 0 ] && continue; echo $i; done`.
    Predict, then run.
45. Nested loops: write a double loop over `1 2 3` and `a b`, and use `break 2`
    to leave both from the inside. Prove it left both.
46. `for i in 1 2 3; do echo $i; done; echo $?`. Now put a `false` as the last
    body command. What is the loop's status?
47. Loop with a `break` after a successful command — what status does the loop
    end with? How would you make a loop return a status you choose?

## F. Build (48–56)

48. Write `scratch/deck-lines` that prints `<deck>: <lines>` for every `*.log`,
    handling the cargo hold, sorted by name.
49. Add a total line. Keep the counter outside any pipeline.
50. Write `scratch/deck-faults` that prints every deck containing `FAULT` and
    exits 1 if there was at least one, 0 otherwise. Test both cases.
51. Write `scratch/read-lines` that takes a filename as `$1` and prints each line
    numbered, byte-exact — leading whitespace, backslashes, and an unterminated
    last line all preserved. Test on `manifests/awkward.txt` and compare with
    `cat -n`.
52. Make 51 refuse a missing file with a usage message on stderr and exit 64
    (12/02, 12/03).
53. Write `scratch/manifest-check`: read `manifests/decks.txt` and report which
    listed decks exist in `decks/` and which do not. Watch the cargo hold.
54. Write a loop that renames nothing but *prints* the `mv` command it would run
    for each `*.log`, correctly quoted so the printed line could be pasted.
55. Take your 53 and run it with `bash -x`. Read the trace. Which expansion do
    you now see happening that you had been guessing about?
56. In `notes/`, write three sentences: the `for` rule, the `while read` line in
    full with each part named, and the subshell rule. This is the page you will
    reread in two years.
