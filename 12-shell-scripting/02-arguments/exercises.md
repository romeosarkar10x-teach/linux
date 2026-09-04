# 12/02 — exercises

Lab: `/labs/12-shell-scripting/02-arguments`. Write your own scripts in
`scratch/`. `bin/show-args` is the honest witness — use it whenever you are not
sure what actually arrived.

## A. What arrived (1–9)

1. `bin/show-args a b c`. What are `$0` and `$#`?
2. Run the same script by absolute path. Which of the two outputs changed, and
   which did not?
3. `. bin/show-args a`. What is `$0` now? Explain in one sentence.
4. `bin/show-args "a b" c` — how many arguments?
5. `bin/show-args a\ b c` — same count? What did the backslash do that the
   quotes did in 4?
6. `bin/show-args` with no arguments at all. What is `$#`, and how many lines
   does the loop print?
7. `bin/show-args *` from inside `decks/`. Who expanded the `*` — the script or
   your shell? Prove it.
8. `bin/show-args '*'` from the same place. Now who expanded it?
9. `bin/show-args 1 2 3 4 5 6 7 8 9 ten`, then add a line to a copy in
   `scratch/` printing `$10` and `${10}`. Explain both outputs.

## B. `"$@"`, `$@`, `"$*"` (10–20)

10. `bin/count-at "cargo hold" beta`. Write down the iteration count for each
    of the three loops.
11. Which of the three preserved what the caller typed?
12. `bin/count-at` with no arguments. `"$@"` prints nothing; `"$*"` prints one
    line. Explain the difference in terms of words, not characters.
13. Run `IFS=- bin/count-at a b`. Did `"$*"` join with a dash? Explain what
    happened to `IFS` between your shell and the script.
14. Now put `IFS=-` on a line *inside* a copy of `count-at` in `scratch/`, above
    the loops. Re-run. Different? Why?
15. From `decks/`, run `bin/count-at *`. Which loop shows you the deck with a
    space in its name as one thing?
16. Make a file called `scratch/star file.txt`. From `scratch/`, run
    `bin/count-at "$(echo *)"` and `bin/count-at *`. Account for the difference.
17. `bin/relay "cargo hold" beta`. How many arguments did `show-args` receive?
18. `bin/relay-quoted "cargo hold" beta`. Now how many? Diff the two scripts and
    point at the character that matters.
19. Write the rule from 17–18 as a sentence about what an unquoted `$@` does at
    every hop, not just the last one.
20. Under what circumstance is `"$*"` the right answer? Give one, with a comment
    you would write beside it.

## C. rhea's page (21–30)

21. Read `notes/page.txt`. What did she run, and what did she get?
22. Run `bin/deck-report "cargo hold"` yourself. Quote stdout and stderr
    separately (Chapter 8's tools).
23. What is the exit status? Why is that the status, given that something
    clearly failed?
24. `cat -A` is not needed here — but `cat bin/deck-report` is. Name the two
    separate bugs. One is about quoting; the other is about what the script
    reports.
25. Run `bin/deck-report-2 "cargo hold"`. Which of the two bugs is fixed?
26. Which bug does rhea's page complain about, and which one is the reason ops
    logged the run as successful?
27. `bin/deck-report alpha` works. Explain why the bug is invisible for three of
    the four decks.
28. There is a deck file named `-n`. From `decks/`, run `bin/deck-report -n`.
    It works. Explain why the leading dash caused no trouble *here* — look at
    how the filename reaches `wc`.
29. Now write `scratch/wc-arg.sh` that does `wc -l "$1"` — the same job, passing
    the name as an **argument** instead of through a redirection. Run it on
    `-n` and quote the error. Fix it with the two characters Chapter 6 taught
    you, and say why the redirect version never needed them.
30. Write the one-line message you would send rhea. She was right about the file
    and right to escalate; say so, and say what the script did.

## D. `shift` and `set --` (31–41)

31. Write `scratch/each.sh` that prints `handling <arg>` for every argument
    using a `while` loop and `shift`.
32. Run it with `"cargo hold" beta`. Two lines or three?
33. Add `echo "left: $#"` after the loop. What is left?
34. Call `shift` when `$#` is 0. What is the return status, and what changed?
35. Use that status as the loop condition instead of `[ "$#" -gt 0 ]`. Does it
    work? Which form reads better, and why might a reviewer prefer one?
36. `shift 2` with only one argument left — what happens to `$#` and to `$?`
    (run it and check both).
37. Write `scratch/defaults.sh`: if `$#` is 0, `set -- alpha beta gamma`; then
    print `"$@"` one per line. Test with and without arguments.
38. Modify it to use `${1:-alpha}` instead. Name one thing `set --` can do that
    the default expansion cannot.
39. Add `set -u` to the top of a script that uses `$1` and run it with no
    arguments. Quote the error.
40. Fix that with a `$#` check and a usage message. Which fix would you rather
    read six months from now?
41. Write a loop that consumes arguments in *pairs* (`$1` and `$2`, then shift
    2). What does it do with an odd number of arguments, and what should it do?

## E. Being a good caller (42–50)

42. `bin/needs-two alpha`. Quote the message, the stream it came out on, and the
    status.
43. Prove the message is on stderr, not stdout, with one redirection.
44. Why does the usage line use `$(basename "$0")` instead of `$0`? Show both.
45. `if bin/needs-two a b; then echo ok; fi` and the same with one argument.
    What does the caller learn from the status?
46. Write `scratch/deck-count.sh`: takes one deck name, prints its entry count,
    exits 64 with usage on the wrong argument count, and exits 66 if the deck
    file does not exist. Quote everything.
47. Test it with: no arguments; `alpha`; `"cargo hold"`; `-n`; `nosuch`. Five
    runs, five statuses.
48. Make it accept *many* decks and print one line each, still handling every
    case from 47.
49. Run it as `scratch/deck-count.sh decks/*` from the lab root. Does the deck
    with a space survive? Whose quoting made that work?
50. Add `--help` handling that prints usage on **stdout** and exits 0. Why is
    that the opposite of the wrong-usage case?

## F. Judgement (51–56)

51. `bin/deck-report` is dated 2186-02-19 and has run every day since. Say
    precisely what its `exit 0` has been evidence of.
52. Someone proposes fixing `deck-report` by renaming the cargo hold. Give the
    strongest argument for that, then the argument against it.
53. You are handed a script that uses `$*` everywhere. Under what condition does
    it work perfectly? How likely is that condition to hold forever?
54. A colleague says quoting is a style preference. Answer them in one sentence
    using something from this lab.
55. Write the two-line comment you would put at the top of `bin/relay` so that
    the next person does not "simplify" `"$@"` back to `$@`.
56. Name the one thing in this lesson you would put on a card above your desk.
