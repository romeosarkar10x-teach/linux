# 12/05 — exercises

Lab: `/labs/12-shell-scripting/05-case-and-functions`. Scratch work in
`scratch/`. Quote errors exactly and record `$?`.

## A. `case` basics (1–9)

1. Run `bin/mode` with `status`, `count`, `faults`, `help`, `-h`, `--help`.
2. `bin/mode nope`. Quote the message, say which stream it went to, and give the
   status.
3. `bin/mode` with no argument at all. What happens, and why does `"$1"` not
   error the way `$1` under `set -u` would (12/02)?
4. Rewrite `bin/mode` in `scratch/` as an `if/elif` chain. Count the lines and
   the repetitions of `$1`.
5. Which of your two versions would you rather add a fifth mode to? Say why in
   one sentence.
6. `case "$1" in help|-h|--help)` — what is `|` doing here? Is it a pipe?
7. `v="a b"; case $v in "a b") echo yes;; *) echo no;; esac`. Unquoted `$v`.
   Predict, run. Now do the same test with `[ $v = "a b" ]` (12/03). Explain the
   difference.
8. `case ABC in [a-z]*) echo lower;; *) echo other;; esac`. Predict, run.
9. `shopt -s nocasematch`, rerun 8, then `shopt -u nocasematch`. Where else in
   this course have you seen a `shopt` change matching behaviour (11/05)?

## B. Patterns and order (10–19)

10. Run `bin/dispatch deck-01`. Read the script. Which branch did you expect?
11. Run `bin/dispatch status` and `bin/dispatch zzz`. Quote both.
12. How many of `bin/dispatch`'s four branches can ever run? Name the dead ones.
13. State the rule that explains it, in one sentence.
14. `shellcheck bin/dispatch`. Quote the two check numbers and what each one
    says.
15. Fix `bin/dispatch` in `scratch/` by reordering only. Verify all four inputs.
16. `bin/classify-deck a.log b.log.gz c.txt d`. Predict all four lines first.
17. `*.log` comes before `*.log.gz`, yet `b.log.gz` is still classified
    correctly. Why does the earlier pattern not win here? Say exactly what
    `*.log` requires.
18. Now change `*.log` to `*log*` in a copy in `scratch/` and rerun. Which
    branch just died? State the general rule about ordering patterns from most
    specific to least.
19. Write a `case` in `scratch/` that matches a deck name of exactly the form
    `deck-` plus two digits and nothing else. Test it against `deck-01`,
    `deck-1`, `deck-011`, `deck-ab`.

## C. `;;`, `;&`, `;;&` (20–25)

20. `bin/fallthrough ax`. Record the output of all three blocks.
21. `bin/fallthrough abc`. Which blocks print one line and which print two?
    Explain each.
22. In your own words: what does `;&` test before it runs the next body?
23. And `;;&`?
24. Rewrite the `;;&` block using two separate `case` statements. Is it clearer?
25. Name one situation where `;&` is genuinely the right tool, and one where it
    is a trap for the next reader.

## D. Functions (26–36)

26. `f() { echo "args: $#"; }` then `f a b c`. What is `$0` inside it? Print it.
27. Print `${FUNCNAME[0]}` inside `f`.
28. Define `f`, call it, `unset -f f`, call it again. Quote the error.
29. `type -t f`, `type -t echo`, `type -t if`, `type -t bin/mode`. Four answers;
    say what each word means.
30. `declare -f f`. Where did the formatting come from?
31. `ls() { echo "not ls"; }`. Run `ls`. Now get the real one two ways
    (`command`, and a path). Then `unset -f ls`. Cross-reference 11/04.
32. `s() { true; false; }`. `s; echo $?`. State the rule.
33. `e() { :; }`. Status? Why is `:` there at all — what happens with an empty
    body?
34. `bash -c 'f(){ exit 7; }; f; echo never'`. Does `never` print? Status?
35. `return 5` typed at your interactive prompt. Quote the error.
36. Write a function in a file, `source` the file, and call it. Then run the file
    instead of sourcing it and call the function. Explain the difference using
    12/01.

## E. `local` (37–44)

37. `bin/leaky`. Quote both lines. Which function is the dangerous one?
38. Write the smallest possible bug demonstrating why: a caller with a loop
    counter and a function that also uses `i`.
39. `bin/status-trap decks/alpha.log`. Quote both statuses.
40. Read the two function definitions. The commands are identical. Explain the
    difference in one sentence.
41. Which of the two is the safe habit even when you do not care about the
    status? Argue it.
42. Is `local` scoping lexical or dynamic? Test: a function with `local v` that
    calls a second function which reads `$v`.
43. `d() { local v=$1; [ $1 -le 0 ] && return; d $(( $1 - 1 )); echo "v=$v"; }`.
    Run `d 2`. Explain the output in terms of one `v` per call.
44. Can you `local` inside a `case` branch at top level of a script? Try it and
    quote the error.

## F. Status or output (45–52)

45. Read `bin/echo-vs-return`. Which function answers by status, which by
    output? How does each caller consume it?
46. Run it on `decks/alpha.log decks/epsilon.log`.
47. Rewrite `deck_has_fault` so it `echo`s `yes`/`no` instead. Rewrite the
    caller. Which version is shorter, and which is harder to misuse?
48. `bin/big-return`. Quote both lines and the error.
49. `300 mod 256`. Do the arithmetic. Now imagine the function was counting
    files. Describe the bug report you would receive.
50. `m() { echo out; return 3; }; r=$(m); echo "[$r] $?"`. Does the status
    survive command substitution?
51. Write `scratch/deck-tool` with modes `list`, `count`, `faults`, `help`,
    built from a `case` over `$1` and one function per mode, every local
    variable `local`, usage to stderr and exit 64 on anything else. Reuse
    `lib/deck.sh` by sourcing it.
52. `shellcheck scratch/deck-tool` until it is silent.

## G. The ops tree (53–58)

53. Read `ops/housekeeping.sh` top to bottom. How many functions are defined?
54. How many modes does its `case` accept?
55. How many does its `usage` list?
56. Which mode runs when it is called with no argument? Quote the parameter
    expansion that decides that, and say what it means (11/01).
57. Run it three ways: no argument, `verify`, and something invalid. Record the
    output and status of each.
58. `cat notes/page.txt`. Which of the modes in 54 produced the line ops-bot
    recorded? Which modes has ops-bot never seen output from?
