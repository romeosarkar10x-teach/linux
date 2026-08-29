# 11/04 — Exercises

Setup, once:

```
lab 11/04
L=$PWD
export PATH="$L/bin:$PATH"
```

Most of this lesson needs an **interactive** shell, because half of it is about a feature that only
exists in one. When an exercise says "in a script", it means `bash -c '...'` or a file you run.

---

## The program, before anything shadows it

1. Run `deck-report`. How many lines?
2. Run `deck-report 5`. What changed?
3. Run `deck-report --terse`. How many lines, and which one went away?
4. `stat -c '%y' bin/deck-report`. When was it last modified?
5. `type deck-report` and `which deck-report`. Do they agree right now?

## What an alias actually is

6. Read `notes/aliases.txt`. In one sentence, what is an alias?
7. In one command, run `alias g='echo pre'; g one two`. What happens?
8. Now run the two halves as two separate lines. What happens?
9. Explain the difference between 7 and 8 using the word "parsed".
10. With `g` defined, run `echo g`. Does it expand? Which rule is that?
11. Run `g one two` and read the output carefully. Where did `one two` end up?
12. From that: does an alias have a `$1`?
13. `. $L/rc/aliases.sh`. Run `alias` with no arguments. How many are defined?
14. `ll /etc/hostname` — what did it run?
15. Run `\ll /etc/hostname`. What happened, and why?
16. Run `'ll' /etc/hostname`. Same result? What does that tell you about when expansion happens?
17. Run `command ll`. Read the error. Which two stages did `command` skip?

## ops-bot's discrepancy

18. With `rc/aliases.sh` sourced, run `deck-report | wc -l`. How many lines?
19. Run `bash -c ". $L/rc/aliases.sh; deck-report | wc -l"`. How many lines?
20. Same file. Same program. Two answers. Which rule from `notes/aliases.txt` explains it?
21. Run `type deck-report` and `which deck-report` in your interactive shell. Which one told you the
    truth, and what did the other one tell you?
22. Read `notes/page.txt`. ops-bot says the source file is unchanged since 2185-11-02. Check that
    claim against exercise 4. Is ops-bot right?
23. Write the one-sentence explanation of the discrepancy you would send back, given that ops-bot
    does not take replies and somebody is going to read the log anyway.
24. `alias please='sudo '` has a trailing space. Define `alias hi='echo chained'` and run
    `please hi`. Now define `alias nope='echo X'` with no trailing space and run `nope hi`. Explain
    both results.
25. Why is `alias sudo='sudo '` a thing people write?
26. `unalias deck-report`. Confirm with `type`. Now run `unalias -a` and check `alias`.

## Functions

27. Read `notes/functions.txt`. Name three things a function has that an alias does not.
28. Define `greet() { echo "hello $1"; }` and call it with an argument. Now try to write the same
    thing as an alias. What stops you?
29. `. $L/rc/functions.sh`. Run `declare -F`. What does it list?
30. `declare -f mkcd`. What is the difference between `-F` and `-f`?
31. Run `mkcd scratch/newdir`. Where are you now? Why could this not be a program?
32. Run `mkcd` with no arguments. What happens, and what is the exit status?
33. Run `deck=IMPORTANT`, then `deck_summary 5`, then `echo $deck`. Is it still `IMPORTANT`?
34. Look at `deck_summary`'s first line. Remove the word `local` from a copy in `scratch/`, source
    that copy, and repeat exercise 33. What is `$deck` now?
35. In one sentence: what does `local` protect, and who from?
36. Define `f() { return 3; }`, run it, and check `$?`. Now change `return` to `exit` and run it.
    What happened to your shell? (Do this in `bash -i` you can afford to lose.)

## Functions shadow harder than PATH

37. With `rc/functions.sh` sourced, run `deck-report 5`. What is the extra line, and which stream is
    it on?
38. Run `which deck-report`. Does it mention the function at all?
39. Run `type deck-report` and `type -a deck-report`. What does `-a` add?
40. Read the function's body. What is `command` doing there?
41. Which stage of `alias -> function -> builtin -> hash -> PATH` does `command` start at?
42. If a hostile function replaced a command you rely on, which of `which`, `type`, `command -v`,
    `declare -F` would reveal it? Test all four.
43. In a **throwaway** shell, define `r() { r; }` and run `r`. Do not predict — measure. What is the
    exit status? Was there an error message?
44. Now run `FUNCNEST=20; r` in another throwaway shell. What is different, and which of the two
    behaviours would you rather ship?
45. `unset -f deck-report`. Confirm with `type`. Why is it `unset -f` and not `unset`?

## Three plausible mistakes

46. `cat $L/rc/broken.sh`. Read all three before running anything, and write down what you expect
    each to do.
47. Source it in an interactive shell and run `deck 5`. Did it work?
48. Look at the alias's text. `$1` was never substituted — so why did `5` reach the program anyway?
49. Now run `bash -c ". $L/rc/broken.sh; deck 5"`. What happens in a script?
50. Mistake 1 therefore works by accident interactively and fails outright in a script. Which failure
    would you rather have, and why?
51. Run `report` in a throwaway shell. Compare with exercise 43. Fix it with one word.
52. Run `i=IMPORTANT`, then `count`, then `echo $i`. What did `count` do to you?
53. Fix mistake 3 with one word. Which word, and where?
54. All three mistakes are in files people copy from each other. What single habit would have caught
    all three before they shipped?

## Choosing

55. Give one job that should be an alias and one that should be a function, with a reason for each.
56. Why should anything a script might use be a function rather than an alias?
57. You are asked to add a company-wide `rm` that always prompts. Give two reasons not to, using
    words from this lesson and from lesson 02.
58. In one sentence each: what does `type` tell you that `which` cannot, and what does `command` do
    that a backslash does not?
