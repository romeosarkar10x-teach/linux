# 12/06 — exercises

Lab: `/labs/12-shell-scripting/06-input-and-arithmetic`. Scratch in `scratch/`.
Quote errors exactly, record `$?`, and say which stream each line came out of.

## A. `read` as input (1–10)

1. Run `bin/ask`. Answer both prompts. Where did the prompt text go — try
   `bin/ask > /dev/null` and see what you can still read.
2. `printf 'alpha\n7\n' | bin/ask`. Does it work? What does that tell you about
   `-p`?
3. `read -r -p "n: " v` then type nothing and press Enter. What is `$v`, and what
   is `$?`?
4. `read -t 1 v < /dev/null; echo $?`. Explain the status.
5. `read -n 3 v <<< "abcdef"; echo "[$v]"`. Did you have to press Enter?
6. `read -s -p "secret: " s; echo; echo "[$s]"`. When would you use this, and
   what is it not (hint: it is not encryption, and `$s` is in your environment).
7. `read -r p q <<< "a b c"; echo "p=[$p] q=[$q]"`. Predict first.
8. `read -r p q r s <<< "a b"`. What are `$r` and `$s`? Any error?
9. `echo "a:b:c" | { IFS=: read -r x y z; echo "$x|$y|$z"; }`. Why the braces?
   What happens without them (12/04)?
10. Why is `IFS=:` written on the same line as `read` rather than above it?

## B. `bin/fields` (11–15)

11. Run it. Read the script. Which line does the splitting?
12. What does `[ "$id" = id ] && continue` do, and what would a `tail -n +2`
    achieve instead?
13. Add a fifth crew member whose name contains a space. Does `bin/fields` cope?
14. Add a sixth whose *deck* field contains a colon. Does it cope? Say precisely
    which variable absorbs the extra field and why.
15. This is a CSV reader that will break on real CSV. Name two things real CSV
    has that this cannot handle.

## C. Validation (16–20)

16. `bin/ask-safe` with `12`. Then with `1x`, `-3`, `` (empty), ` 4` (leading
    space). Record the status of each.
17. Read the `case` pattern `''|*[!0-9]*`. Explain each half.
18. Should `-3` be rejected? Change the script so it accepts negative integers,
    and test.
19. What happens if you delete the `case` entirely and pass `1x`? Predict, then
    run. Quote the error and say what `$(( ))` decided `1x` was.
20. Now pass `x[$(id -u)]` with no validation. Explain, in one sentence, why
    arithmetic on unvalidated input is not merely a correctness problem.

## D. Arithmetic (21–33)

21. Run `bin/arith-tour`. Predict every line before you run it; mark the ones
    you got wrong.
22. `$(( 7 / 2 ))` and `$(( -7 / 2 ))`. Is this rounding down, or toward zero?
    Which does Python do? (Say what you would expect; do not go looking.)
23. `$(( -7 % 3 ))`. State the rule about the sign.
24. `$(( 1.5 ))`. Quote the error exactly.
25. `x=5; y=x; echo $(( y + 1 ))`. Explain the 6.
26. `n=abc; echo $(( n + 1 ))`. Predict, run, and say what worries you about it.
27. `unset z; echo $(( z + 1 ))`. Same question under `set -u`.
28. `echo $(( 5 / 0 ))`. Quote the error and give `$?`.
29. `(( 0 )); echo $?` and `(( 1 )); echo $?`. Now write an `if (( n > 3 ))`.
30. `let "x = 1 + 2"; echo $x`. Now try it without the quotes: `let x = 1 + 2`.
    Quote the failure. This is why the lesson recommends `(( ))`.
31. `i=0; echo $(( i++ )) $(( i++ )) $i`. Explain all three numbers.
32. `echo $(( 9223372036854775807 + 1 ))`. What happened, and what did *not*
    happen?
33. Write, in `scratch/`, a check that would have caught 32 before it printed.

## E. Bases and the leading zero (34–41)

34. `v=010; echo $(( v ))`. Predict, run.
35. `echo $(( 08 ))`. Quote the error.
36. `echo $(( 10#08 ))`, `$(( 16#ff ))`, `$(( 2#101 ))`.
37. `cat data/margins.txt`. Which two values are octal-invalid, and which one is
    octal-*valid* and therefore worse?
38. Run `bin/margin-check`. Record stdout and stderr separately (`>out 2>err`).
39. Which decks did it actually test? Which are genuinely below 10?
40. `cat notes/page.txt`. The log matches the script's stdout exactly. Explain
    how a script can be broken for a year while its log looks correct.
41. Fix `bin/margin-check` in `scratch/` without touching `data/margins.txt`.
    Verify all four decks are now tested and that alpha and beta are reported.

## F. Decimals without a calculator (42–47)

42. `bin/average` and `bin/average-2` on the same data. Quote both averages.
43. Read `average-2`'s `frac` line. Why `* 100` before `/ n` and not after?
44. Compute the average by hand. Is `12.60` correct, or truncated? Where would
    the error show up first — at two decimal places, or at six?
45. Write a version that rounds instead of truncating. (Hint: add half the
    divisor before dividing.) Test on data where it matters.
46. Do the same with `awk 'BEGIN{printf "%.3f\n", 63/5}'`. Is `awk` available
    here? Is `bc`? Check both and say what you would do on a machine with
    neither.
47. Argue in two sentences when you should stop using shell arithmetic and use
    `awk` (or leave the shell entirely).

## G. Arrays (48–58)

48. `bin/decks-array`. Predict the two loops' output before running.
49. Which loop split `cargo hold`, and which quoting caused it?
50. `decks=(a b c); echo "${#decks[@]}"; echo "${#decks[1]}"`. Two different
    lengths — say what each is.
51. `decks[9]=nine; echo "${#decks[@]}"; echo "${!decks[@]}"`. Explain both.
52. `unset 'decks[1]'; echo "${#decks[@]}" "${!decks[@]}"`. Why the quotes around
    `decks[1]`?
53. Write a loop over `"${!decks[@]}"` printing `index: value`. Now write the
    same loop as `for ((i=0;i<${#decks[@]};i++))` and run it on the sparse array.
    What went wrong?
54. `decks+=(delta)`. What index did it get?
55. `declare -A crew; crew[vasquez]=alpha; crew["cargo hold"]=3`. Print the keys
    and one value. What happens if you forget `declare -A`?
56. Read `data/readings.txt` into an array, one line per element, with
    `mapfile -t r < data/readings.txt`. Print the count and the third element.
57. Do the same with `r=( $(cat data/readings.txt) )` and explain the difference
    in the count.
58. Write `scratch/top-deck`: read `data/readings.txt`, find the highest reading,
    print `<deck> <value>`. Integer arithmetic only, no `sort`. Then check your
    answer with `sort -k2 -n`.

## H. Build (59–62)

59. Write `scratch/hours` that reads `data/crew.csv`, skips the header, and
    prints total hours, the mean to one decimal place, and anyone over 40.
60. Make it take the threshold as `$1`, defaulting to 40, validated (12/02,
    12/05).
61. Have it read every number with `10#` and prove the fix by zero-padding one
    row in a copy of the CSV.
62. `shellcheck scratch/hours` until it is quiet, then explain one thing it told
    you that you did not already know.
