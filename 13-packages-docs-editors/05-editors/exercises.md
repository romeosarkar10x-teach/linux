# 13/05 — Exercises

Work in `/labs/13-packages-docs-editors/05-editors`.

```
cd /labs/13-packages-docs-editors/05-editors
ls conf text notes
cat notes/editors.txt
```

These exercises are meant to be done in the editors, not around them. Copy a
file into `scratch/` before you destroy it; that is what `scratch/` is for.

## A. nano, from nothing

1. `nano scratch/first.txt`. Type a line. Save it. Leave. Which two keys?
2. Reopen it and confirm the line is there.
3. What does the `^` in `^O` mean, and what does `M-` mean in nano's help?
4. Open `conf/deck-cycle.conf` in nano. Search for `forty` without scrolling.
5. Fix that line to a number. Save and exit.
6. Fix the `deck-9` line to `deck-09` while you are in there.
7. Verify from outside the editor that both changes landed.
8. Use `^\` to change every occurrence of `deck-` to `bay-` in a copy in
   `scratch/`. How many replacements did nano report?
9. In that copy, cut three lines with `^K` and paste them back at the end with
   `^U`. What happens if you press `^K` twice in a row before pasting?
10. Exit nano with unsaved changes. What does it ask you, and what are your
    three options?
11. `nano -l text/handover.txt` — what does `-l` change? Find one other useful
    flag in `nano --help`.

## B. vim, from nothing

12. `vim scratch/second.txt`. Enter insert mode, type a line, return to normal
    mode, write and quit. Name every key you pressed.
13. Open it again and quit without saving anything. Which command?
14. Open it, delete the line with `dd`, then leave without saving. Confirm from
    outside that the file is unchanged.
15. `vim text/cycles.log`. How many lines? (Vim tells you when it opens the
    file, and `Ctrl-g` tells you again.)
16. Go to line 402 without scrolling. Two ways — name both.
17. Go to the last line, then the first, in one keystroke each.
18. Search for `SKIPPED`. Which line is it on, and what does it say?
19. From that line, jump to the end of the line, then back to the first
    non-blank character. Which keys?
20. `:set number`. Turn it off again.
21. `u` and `Ctrl-r`. Make three changes, undo all three, redo two. Does vim
    let you undo past the point where you last saved?
22. Quit that file without writing.

## C. vim, doing real work

23. Copy `conf/hatch-alarms.conf` to `scratch/`. Open the copy in vim.
24. `notes/page.txt` names a deck whose `fail` is below its `warn`. Find it
    with a search rather than by reading.
25. Fix it so `fail` exceeds `warn`, and add a comment line above it saying
    what you changed and why. (This is the point of `notes/page.txt`.)
26. Save and quit in one command.
27. `diff conf/hatch-alarms.conf scratch/hatch-alarms.conf`. Does the diff show
    exactly what you intended and nothing else?
28. In another copy, use `:%s/deck-/bay-/g` and read the message vim prints.
    How many substitutions, on how many lines?
29. Undo it with one keystroke. Confirm.
30. `:%s/warn/WARN/gc` — what does the trailing `c` do? Accept two and reject
    the rest.
31. Delete the whole `[deck-11]` stanza using `dd` with a count.
32. Reload the file from disk, discarding everything, without leaving vim.
33. `:set list`. Open `conf/settling.tsv` and say which lines use a tab and
    which use a space.
34. Do the same from outside vim with `cat -A`. Which is easier to act on, and
    why does it matter that both exist?
35. Open `conf/from-laptop.csv` in vim. What do you see at the end of each
    line, and what is it?
36. `file conf/from-laptop.csv` says only `CSV ASCII text` — it does not
    mention the line endings. What does that tell you about trusting `file`?
37. Strip those characters with a single vim command. (`:%s/\r//` is one way;
    `:set ff=unix` and `:w` is another. Try both on separate copies and say
    what is different about them.)
38. Confirm with `cat -A` from outside.

## D. Getting out of trouble

39. Open a file in vim and type `:` `w` `q` while still in insert mode. What
    ends up in the file? Undo it.
40. Press `Esc` twice, then `:q!`. Explain to yourself why that sequence always
    works.
41. Open `text/handover.txt` in vim, leaving it open. In a second shell, open
    the same file in vim again. Read the message it prints, in full.
42. What are the options it offers you, and which one is safe?
43. Where is the swap file? (The message names it.) `ls -a` on that directory.
44. Quit both editors, delete the swap file if one is left, and reopen cleanly.
45. Explain what a swap file is for, and why finding one on a live system tells
    you something.
46. `vim -R text/cycles.log` — what does `-R` do, and when would you want it?
47. Try to write in read-only mode. What does vim say, and what is the override?

## E. Which editor runs

48. `echo "$EDITOR" "$VISUAL"`. What is set?
49. `export EDITOR=nano`, then run a command that opens an editor for you and
    confirm which one you get. (`sudo -e` on a file in `/etc` will do.)
50. Set `EDITOR=vim` and repeat.
51. Which of the two variables wins if both are set, and where did you look up
    the answer?
52. Make `EDITOR` persist across logins. Which file, and why that one?
53. Undo exercise 52 if you would rather not keep it.

## F. Editing a root-owned file

54. `sudo -e /etc/deck-report.conf` (or another root-owned file in `/etc`).
    What editor opened, and as which user is it running? (`ps` from a second
    shell answers the second half.)
55. Make a harmless change, save, exit. Check the file's owner and mode
    afterwards — unchanged?
56. Explain, in two sentences, what `sudo vim /etc/passwd` does that `sudo -e`
    does not.
57. Give a concrete reason that difference could matter, given that vim can run
    shell commands with `:!`.
58. Undo your change from exercise 55.

## G. Stretch

59. Work through `vimtutor` up to lesson 3. It is installed.
60. Write a `~/.vimrc` with `set number`, `set expandtab`, and
    `set shiftwidth=4`. Open a file and confirm each one took effect.
61. Give one reason a shared machine's operators might agree not to keep
    personal editor configuration in `/root`.
62. Reformat `text/handover.txt`'s TODO list into a numbered list, in vim,
    without leaving normal mode more than you have to. Then say honestly
    whether `sed` would have been faster.
