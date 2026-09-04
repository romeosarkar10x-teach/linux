# Exercises — 11/05 prompt and options

    cd /labs/11-environment-and-config/05-prompt-and-options

Several of these turn on options that make the shell *refuse* things. Do that
work in a shell you are willing to lose. Nothing here edits a startup file.

## Reading the pages (1–6)

1. Read `notes/page.txt`. What exit status did the audit report, and what
   number did it print?
2. What condition would have made the scheduler raise an alert? Did that
   condition occur?
3. Read `notes/page-2.txt`. State rhea's two complaints in one line each.
4. She says the two are probably unrelated. Before you know anything: is she
   right? Write down your guess and keep it.
5. `stat -c '%y' scripts/deck-audit.sh`. When was the audit script last
   changed? Does that fit "worked for forty cycles, then didn't"?
6. `ls /var/lib/kestrel` — what does the shell say, and what does that tell you
   the audit's `cat` did?

## The prompt as a string (7–16)

7. `echo "$PS1"` — print your current prompt without letting the shell draw it.
8. Which escapes in that string do you already recognise from `notes/prompt.txt`?
9. `PS1='hello$ '` — set it. What happened to your username and directory?
10. `PS1='[\W]\$ '` then `cd /etc`, then `cd /`. What changes and what does not?
11. Now `PS1='[\w]\$ '` and repeat. State the difference between `\w` and `\W`
    in one sentence.
12. Set `PS1='[\!]\$ '`. Run three commands. What is counting?
13. Set `PS1='\t \$ '`. Does the time update between prompts? What does that
    tell you about when `PS1` is expanded?
14. `PS1='[$(date +%S)]\$ '` — press Enter a few times without typing anything.
    Explain what is running and how often.
15. Exit the shell and start a new one (`bash`). Where did your prompt go, and
    which lesson explains that?
16. `echo "$PS2"`. Now type `echo "unterminated` and press Enter. What prompt
    appears? Press Ctrl-C to get out.

## Colour, and rhea's bug (17–24)

17. `source rc/prompts.sh`. Did your prompt change? Why not?
18. `PS1="$PROMPT_COLOUR"` — set the correct colour prompt.
19. `PS1="$PROMPT_BROKEN"` — set rhea's. Does it *look* different from the one
    in 18?
20. With the broken prompt set, type a command long enough to wrap your
    terminal (a long `echo` with a lot of words), then press Ctrl-A to jump to
    the start. Describe what the screen does.
21. Set `PS1="$PROMPT_COLOUR"` and repeat exercise 20 exactly.
22. `diff <(echo "$PROMPT_COLOUR") <(echo "$PROMPT_BROKEN")`. What is the only
    difference?
23. In one sentence: what do `\[` and `\]` tell readline, and why does the bug
    only appear on long lines?
24. Answer rhea: is it the terminal? Give her the one-sentence reason.

## PROMPT_COMMAND (25–28)

25. `echo "[$PROMPT_COMMAND]"` — is it set by default here?
26. `PROMPT_COMMAND='echo TICK'`. How many `TICK`s do you see before you have
    typed anything else, and why?
27. Run two commands. Where does `TICK` appear relative to each command's
    output?
28. `PROMPT_COMMAND='cd /tmp'` would be a bad idea. Say why in one sentence.
    (You do not have to run it. If you do, `unset PROMPT_COMMAND`.)

## Reading the switches before touching them (29–34)

29. `set -o` — how many options are listed? How many are `on`?
30. `shopt` — how many options are listed?
31. `shopt -p globstar dotglob nullglob failglob nocaseglob extglob`. What form
    does `-p` print, and why is that form more useful than `on`/`off`?
32. `shopt extglob` in your interactive shell, then
    `bash -c 'shopt extglob'`. Are they the same? Explain.
33. `echo "$-"` — the letters are the `set` options currently on. Which letter
    means "interactive"?
34. `set -o | grep -E 'errexit|nounset|pipefail|noclobber'` — before you change
    anything, what are the four defaults?

## errexit, and the four shapes of failure (35–41)

35. `cat scripts/checks.sh`. Predict which checkpoints will print. Write the
    prediction down.
36. Run it. `echo $?`. Which checkpoints printed?
37. Which of the four failing commands did `set -e` react to?
38. Why did the `false` inside `if false; then` not stop the script?
39. Why did `false || echo handled` not stop it?
40. `false | true` did not stop it either. Add `set -o pipefail` to the top of a
    copy in `scratch/` and run it. What changes?
41. State the rule for when `set -e` fires, in one sentence, in your own words.

## nounset (42–46)

42. `./scripts/greet.sh`. What does line 1 print for `$OPERATOR`?
43. `bash -u scripts/greet.sh` — what is the message and the exit status?
44. Line 2 uses `${SHIFT_NAME:-unassigned}` and `set -u` does not object. Why
    not?
45. `OPERATOR=rhea bash -u scripts/greet.sh` — does it pass now?
46. In your own shell run `set -u`, then `./scripts/greet.sh`. The script does
    *not* fail. Explain why, then find the two ways to make it fail anyway.

## The audit (47–52)

47. `./scripts/deck-audit.sh; echo $?`. Reproduce ops-bot's page exactly.
48. Which command in that script failed, and what was the pipeline's exit
    status? Explain the gap.
49. `./scripts/deck-audit-strict.sh; echo $?`. What is different, and which of
    the three switches is doing the work?
50. `wc -l < data/decks` — how many decks are there really?
51. Copy the strict script into `scratch/`, point it at the real path, and make
    it print `decks audited: 12`.
52. ops-bot's scheduler alerts on non-zero status only. Given exercise 49, is
    that configuration now sufficient? Answer in one line.

## Glob options (53–57)

53. `cd glob`. `ls -a`, then `echo *.txt`. Which of the six files matched?
54. Turn on `dotglob`, `nocaseglob` and `globstar` one at a time (fresh shells
    or turn each off after) and record what `echo *.txt` — and, for globstar,
    `echo **/*.txt` — adds each time.
55. `echo *.zzz` with no options on. What does the shell print, and why is that
    the most surprising default in this lesson?
56. Turn on `nullglob` and repeat. Then `failglob` and repeat. Give the exact
    message `failglob` produces.
57. A script does `rm *.zzz` in a directory with no `.zzz` files. Describe what
    happens under each of: default, `nullglob`, `failglob`. Which would you
    want, and why is `nullglob` more dangerous than it looks?

## History, and the debrief (58–64)

58. `echo "$HISTCONTROL" "$HISTSIZE" "$HISTFILE"`. What is `ignoreboth` made of?
59. Run `echo alpha`, then `echo alpha` again, then ` echo beta` (with a leading
    space), then `history 5`. Which of the three are recorded?
60. `grep -n HISTSIZE ~/.bashrc`. There are two. Which one is in force, and what
    is the rule that decides?
61. `shopt histappend` — on or off? Describe, in one sentence, what you lose
    when it is off and you have two terminals open.
62. Which of the changes you made in this lesson survive `exit` and a fresh
    `kestrel enter`? Which do not?
63. Rank these three by how much damage a wrong setting can do in a script,
    worst first: `nocaseglob`, `pipefail`, `PS1`. Defend the ordering.
64. rhea guessed her two complaints were unrelated. She was right. Write the
    two sentences you would send back — one per complaint — without telling her
    she was right about something she already knew.
