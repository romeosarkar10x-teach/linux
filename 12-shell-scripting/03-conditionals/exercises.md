# 12/03 — exercises

Lab: `/labs/12-shell-scripting/03-conditionals`. Scratch work in `scratch/`.
Every "quote the error" means: copy it exactly, and record `$?`.

## A. `if` is about status (1–8)

1. `if true; then echo y; else echo n; fi`. Which status is "true"?
2. Same with `false`. Then with `exit`-status 3: `if bash -c 'exit 3'; ...`.
3. `if grep -q nominal tree/regular.txt; then echo found; fi` — where is the
   test? Name the command that supplied the status.
4. `if [ -f tree/regular.txt ]; then ...` — name the command here too.
5. `type test`, `type [`, `type [[`. Which is a keyword, and what does that
   word buy the shell?
6. `ls -l /usr/bin/[`. There is a real program called `[`. Why does it exist if
   bash has a builtin?
7. `if [ $(wc -l < tree/regular.txt) ]; then echo y; fi` — predict, run, and say
   what was actually tested.
8. Write the corrected version of 7 that tests whether the file has more than
   zero lines.

## B. `[ ]` splits its arguments (9–18)

9. `v=""; [ $v = x ]; echo $?`. Quote the error and the status.
10. Write out what the shell handed to `[` in 9, word by word.
11. `v="a b"; [ $v = x ]; echo $?`. Quote the error. How many arguments did `[`
    receive?
12. Quote the variable in both. Do both errors go away? What are the statuses?
13. `[[ $v = x ]]` with `v="a b"`, unquoted. No error. What did the shell skip?
14. `[ "$a"="$b" ]` with both unset. Predict, run, explain. (Count the
    arguments.)
15. `bin/gate ""` and `bin/gate "a b"`. Quote both errors and both **exit
    statuses of the script**.
16. Explain why the script's status is what it is, given that `[` returned 2.
17. `bin/gate deck` and `bin/gate hold` both behave correctly. Say precisely
    what has protected this script since 2186.
18. Fix `bin/gate` in a `scratch/` copy with two characters. Then fix it a
    second, different way. Which would you ship, and why?

## C. Numbers and strings (19–29)

19. `[ 10 -gt 9 ]; echo $?` and `[[ 10 > 9 ]]; echo $?`. Explain the
    disagreement.
20. `[ "10" \> "9" ]; echo $?` — why the backslash, and why this answer?
21. `bin/version-gate 8`, `9`, `10`, `11`. Which answers are right, and which
    is the first release the gate got wrong?
22. Read `notes/page.txt`. What is ops-bot holding, and on whose authority?
23. `bin/count-gate 10`. Same argument, different answer. Point at the one line
    that differs.
24. `bin/version-gate 9.2` and `bin/count-gate 9.2`. Now which one errors?
    Quote it. What does that tell you about `-gt` and decimals?
25. `[ 5 -eq 05 ]` and `[ "5" = "05" ]`. Both are defensible. Say what each is
    asking.
26. `[ abc -eq 1 ]` — quote the error and the status.
27. `[[ abc -eq 1 ]]` — no error. What did it return, and what did it evaluate
    `abc` as? Which behaviour do you want in a script that gates deployments?
28. Write `scratch/cmp.sh` taking two arguments, printing whether the first is
    numerically greater, and refusing non-numeric input with a message on
    stderr and status 65.
29. What would `version-gate` do on release `100`? Predict from the rule, then
    check.

## D. File tests (30–41)

Run each against the paths in `tree/`.

30. `-e` on `link-ok` and on `link-broken`. Explain the difference in one
    sentence about what `-e` follows.
31. `-L` on both. Which test is about the link itself?
32. `-f` on `link-ok`. Follows or not?
33. `-d` on `subdir`, `-d` on `regular.txt`.
34. `-s` on `regular.txt` and on `empty.txt`.
35. `-r`, `-w`, `-x` on `readonly.txt` and `runnable.sh`. Which of the nine bits
      is each one reading, and for whom (Chapter 10)?
36. `-w /etc/passwd` as cadet. What does the result tell you, and would it be
    the same as root?
37. `regular.txt -nt empty.txt`. Check the two mtimes with `stat` and confirm.
38. `bin/classify` on all six things in `tree/` plus a nonexistent path. Any
    surprises?
39. `classify` reports `link-ok` as a symlink, not as a regular file. Is that
    right? Argue both sides in two sentences.
40. Reorder a `scratch/` copy so `-f` comes first. What changes, and for which
    inputs?
41. Add a branch that distinguishes a *broken* symlink from a working one. Which
    two tests together say "broken"?

## E. Combining, and the `&&`/`||` trap (42–52)

42. `bin/readiness regular.txt`, `empty.txt`, `readonly.txt`, `nosuch`. Which
    say ready?
43. `readonly.txt` is mode 444 and reports ready. Is `readiness` wrong? What is
    it actually claiming?
44. Rewrite `readiness`'s condition as a single `[[ ]]`. Same behaviour?
45. Rewrite it with `-a` inside one `[ ]`. It works. Read
    `notes/operators.txt` and give the reason not to.
46. `[ -d /etc ] && echo dir || echo notdir`. Run it. Now run it against a
    nonexistent path.
47. `true && false || echo "else branch"`. Predict, run, explain.
48. Construct a case where `cmd && echo ok || echo failed` prints **both**
    `ok`-side failure and `failed`. (Hint: make the middle command fail —
    `echo` to a closed descriptor, or use `false` in its place.)
49. State the rule you would give a colleague about when `&&`/`||` may stand in
    for if/else.
50. Write a condition that is true when a path exists **and** is either a
    directory or a non-empty regular file. Use `[[ ]]` and parentheses.
51. `[[ $name == deck-* ]]` with `name=deck-01`, then with the right-hand side
    quoted. Explain both.
52. `[[ deck-01 =~ ^deck-[0-9]+$ ]]; echo $?`, then print
    `"${BASH_REMATCH[0]}"`. Add one capture group and print `${BASH_REMATCH[1]}`.

## F. Building something (53–58)

53. Write `scratch/check-deck.sh <path>`: exits 0 and prints `ok` if the path is
    a readable, non-empty regular file; otherwise prints a *specific* reason on
    stderr (missing / not a regular file / unreadable / empty) and exits 66.
54. Test it against all six entries in `tree/` and a nonexistent path. Seven
    runs, seven outcomes.
55. Make it work when the path contains a space. Prove it.
56. Make it work under `set -u` with no arguments at all.
57. Convert every `[ ]` in it to `[[ ]]`. Which quotes could you now drop, and
    which would you keep anyway?
58. Run `shellcheck scratch/check-deck.sh`. Read the warnings; do not fix them
    yet. Which of them are about this lesson?

## G. Judgement (59–62)

59. `bin/version-gate` has been correct for four years and is wrong today.
    Write the sentence you would put in the incident log, naming the mechanism
    without blaming anyone.
60. Someone proposes fixing the deployment hold by renaming release 10 to
    "9.9". Give the argument for, then the argument against.
61. `bin/gate` prints a shell error to stderr and exits 0. Name the two separate
    defects and say which one a monitoring system would notice.
62. When would you deliberately choose `[ ]` over `[[ ]]` in new code?
