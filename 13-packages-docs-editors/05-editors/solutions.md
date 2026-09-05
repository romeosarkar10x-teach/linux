# 13/05 — Solutions

**AGENT EYES ONLY.** Do not paste a solution to a student. These are for
checking work and for knowing which wrong answer they have.

Load-bearing exercises: **3, 10, 14, 21, 27, 30, 33, 35, 36, 37, 40, 41, 45,
47, 51, 54, 56, 57**. A student who has those has the lesson.

## A. nano, from nothing

1. `Ctrl-O` to write out (it prompts for the filename — Enter accepts), then
   `Ctrl-X` to exit. Two keys, in that order. A student who used `Ctrl-X` and
   answered `y` at the prompt got there too; both are correct.
2. `nano scratch/first.txt` again, or `cat` it from the shell.
3. `^` is Ctrl. `M-` is Meta — Alt on almost every keyboard, and Esc-then-key
   where Alt is swallowed by the terminal. The point of the exercise is that
   nano's own help uses a notation that has to be read, not guessed.
4. `Ctrl-W`, type `forty`, Enter. It lands on the `deck-11` line.
5. Any number; `90` is the sensible choice given `notes/`. Save `Ctrl-O`,
   exit `Ctrl-X`.
6. The file has both `deck-9 60` and `deck-09 120`. Renaming `deck-9` to
   `deck-09` creates a duplicate key — worth pointing out if they do it
   without noticing. The exercise says to make the change; noticing the
   collision is the bonus.
7. `cat conf/deck-cycle.conf`, or `grep -n 'deck-09\|forty'`. Verification
   from outside the editor is the habit being built.
8. `Ctrl-\`, `deck-`, Enter, `bay-`, Enter, then `A` for all. nano reports
   **4** replacements in `hatch-alarms.conf`, **4** in `deck-cycle.conf`
   (`deck-04`, `deck-07`, `deck-9`, `deck-11` — plus `deck-09`, so 5 if they
   copied that file; have them say which file they used).
9. `Ctrl-K` three times then `Ctrl-U` pastes all three back together:
   consecutive `Ctrl-K`s accumulate into one buffer. A single `Ctrl-K`,
   moving, then another `Ctrl-K` replaces the buffer. This surprises people
   and is worth confirming they tried it.
10. "Save modified buffer?" with `Y`, `N`, `^C`. Three options: save and
    leave, discard and leave, or cancel and stay in the file. The third one
    is the one students forget exists, and it is the one you want when you hit
    `Ctrl-X` by accident.
11. `-l` shows line numbers in the left margin. Other good finds: `-w` (no
    hard wrapping — the one that matters for config files), `-v` (view only),
    `-B` (keep a backup), `-i` (auto-indent).

## B. vim, from nothing

12. `vim scratch/second.txt`, `i`, type, `Esc`, `:wq`, Enter. Every key: i,
    text, Esc, colon, w, q, Enter. Students who cannot name the Esc are the
    ones who get stuck later.
13. `:q` — it works because nothing was modified. If they changed something,
    `:q` refuses and they need `:q!`.
14. `dd`, then `:q!`. `cat` or `wc -l` from the shell shows the file
    unchanged. The lesson: nothing you do in vim reaches the disk until you
    write.
15. **601** lines. Vim prints `"text/cycles.log" 601L, ...` on open; `Ctrl-g`
    prints the same information again.
16. `:402` and Enter, or `402G`. Both. `402gg` also works.
17. `G` for the last line, `gg` for the first.
18. `/SKIPPED`, Enter. Line **402**:
    `2187-07-06 11:02 cycle 0401 SKIPPED pressure did not settle`. Note the
    off-by-one that is not one: the cycle is numbered 0401, the line is 402,
    because of the header. A student who reports "line 401" read the cycle
    number, not the line number — worth catching.
19. `$` to the end, `^` back to the first non-blank. `0` goes to column zero,
    which on this line is the same thing; ask them for a line where `0` and
    `^` differ.
20. `:set number`, `:set nonumber`. `:set number!` toggles.
21. Three changes, `uuu`, `Ctrl-r` twice. And yes — vim's undo crosses the
    write. Saving does not create a floor; you can undo to before the last
    `:w` and then write again, leaving the file in a state the disk never
    held between the two writes. This is the exercise's real content.
22. `:q!`.

## C. vim, doing real work

23. `cp conf/hatch-alarms.conf scratch/ && vim scratch/hatch-alarms.conf`.
24. `/fail` and read, or better: the file states the rule in its own comment
    (`FAIL must exceed WARN`), and `notes/page.txt` names the deck outright —
    **deck-04**, `warn = 2.0`, `fail = 1.5`. Accept either route; the point is
    that they searched rather than scrolled.
25. Change `fail = 1.5` to something above 2.0 (6.0 matches every other
    stanza), and add a comment line above it. The comment is the exercise:
    `notes/page.txt` is a complaint that nobody records *why*, and this is the
    student answering it. A student who fixed the number and skipped the
    comment has missed the lesson — send them back to `page.txt`.
26. `:wq` (or `:x`, or `ZZ`).
27. The diff should show the changed `fail` line and the added comment, and
    nothing else. Stray whitespace, a reflowed line, or a missing final
    newline all count as "something else" — that is why the exercise asks.
28. `:%s/deck-/bay-/g` reports **4 substitutions on 4 lines**. There are four
    `deck-` occurrences, all in stanza headers, one per line.
29. `u`. `:%s` counts as one undoable change no matter how many lines it
    touched — worth saying out loud.
30. `c` makes each substitution ask for confirmation: `y` accept, `n` skip,
    `a` all remaining, `q` quit, `l` last one. Accepting two and rejecting the
    rest gives 2 substitutions on 2 lines.
31. Put the cursor on `[deck-11]` and press `3dd` — header, `warn`, `fail`.
    Students who say `4dd` counted the blank line above; that is a different
    (also defensible) answer, so ask them which four lines went.
32. `:e!`. This is the "I have made it worse and I want the disk version"
    command, and it is the one nobody remembers under pressure.
33. `:set list` shows `^I` for tab and `$` for end of line. `deck-07` uses a
    space; the other three use tabs.
34. `cat -A conf/settling.tsv` — same information, `^I` and `$`, from the
    shell. `cat -A` is easier to act on because it composes: you can pipe it
    into `grep`. It matters that both exist because you cannot always get an
    editor onto a machine, and you cannot always pipe from inside one.
35. `^M` at the end of every line — carriage returns, the CR of CRLF. Vim
    shows them when the file has *mixed* endings; with uniform CRLF it may
    instead report `[dos]` and hide them. Ask which they saw.
36. `file conf/from-laptop.csv` prints `CSV ASCII text` — no mention of CRLF.
    `file` reports a type, cheaply, from a header and some heuristics; it is
    not an inspection. It answers "roughly what is this", never "is this
    correct".
37. `:%s/\r//` deletes the CR characters, leaving the file's format flag as it
    was — write it and vim may put them back if `ff=dos` is still set.
    `:set ff=unix` then `:w` changes the format vim writes in, which is the
    durable fix. Difference: one edits the bytes, the other edits how vim
    saves. The second survives further editing.
38. `cat -A conf/from-laptop.csv` — lines end `$`, not `^M$`.

## D. Getting out of trouble

39. The literal text `:wq` is inserted into the buffer, because insert mode
    takes every keystroke as text. `u` undoes it. Every student does this at
    least once and the exercise makes it deliberate instead of frightening.
40. `Esc` from insert mode returns to normal mode; `Esc` in normal mode does
    nothing (it beeps or flashes). So `Esc Esc` reaches normal mode from
    anywhere, and `:q!` from normal mode always exits without writing. It is
    the sequence you can use without first working out where you are.
41. Vim prints the swap-file warning: `E325: ATTENTION`, `Found a swap file by
    the name ".../.handover.txt.swp"`, the owner, the process ID of the other
    vim, and the note that the file may be being edited or that the session
    crashed. Have them read the *whole* message — it names the pid, which is
    how you tell "someone is editing this now" from "something died".
42. `[O]pen Read-Only`, `(E)dit anyway`, `(R)ecover`, `(D)elete it`,
    `(Q)uit`, `(A)bort`. The safe one while another vim is genuinely running
    is `O` (or `Q`). `E` invites two editors writing the same file, last write
    wins.
43. The message names the path: the same directory as the file,
    `.handover.txt.swp`. `ls -a text/` shows it — it is hidden, which is why
    a plain `ls` had not shown it.
44. Quit both, `rm text/.handover.txt.swp` if it survived, reopen — no
    warning.
45. The swap file holds unwritten changes so a crashed or disconnected session
    can be recovered. On a live system, finding one tells you either that
    someone is editing that file right now, or that an editing session died —
    and the pid in the warning distinguishes the two. Either way it is a
    person's fingerprint on a config file.
46. `-R` opens read-only: you can move and search, `:w` refuses. Use it on
    logs, on anything under investigation, and on any file you only mean to
    read. It is habit-forming in the right direction.
47. `E45: 'readonly' option is set (add ! to override)`. The override is
    `:w!`, and it works — `-R` protects against accident, not against
    intent.

## E. Which editor runs

48. Both are **empty** in this image. That is the answer, and it is the reason
    the rest of the section exists: something still opens when a program wants
    an editor, and it is not your choice that decided which.
49. `export EDITOR=nano`, then `sudo -e /etc/deck-report.conf` opens nano.
50. `export EDITOR=vim`, same command, vim opens.
51. `VISUAL` wins where both are set, for programs that check it — it is the
    variable meaning "a full-screen editor is fine here". The second half of
    the question is the real one: they must say **where they looked** —
    `man sudo` (the `SUDO_EDITOR`/`VISUAL`/`EDITOR` order is written out),
    `man git-var`, or the program's own docs. "I remembered" is not an
    answer; different programs genuinely differ, and sudo's own order puts
    `SUDO_EDITOR` first.
52. `~/.bashrc` for an interactive-shell default, or `~/.profile` for a login
    shell. Chapter 11's reasoning applies unchanged: `.bashrc` because these
    are interactive sessions and it is the file that runs for each one.
53. Remove the line and open a new shell.

## F. Editing a root-owned file

54. Whichever `EDITOR` names. From a second shell, `ps -ef | grep vim` shows
    it running as **cadet**, not root, editing a file in `/var/tmp` with a
    name like `deck-report.conf.XXXXXXXX`. That is the whole point of
    `sudo -e`: your editor, your privileges, on a copy.
55. Save, exit; `ls -l /etc/deck-report.conf` shows the original owner and
    mode preserved. sudoedit copies the content back, it does not move your
    temporary file over the original.
56. `sudo vim /etc/passwd` runs the **entire editor** as root — its
    configuration, its plugins, its shell escapes, and any command in a
    modeline. `sudo -e` runs your editor as you and only performs the
    privileged copy-back as root. Two sentences; both halves required.
57. Concretely: vim's `:!command` runs a shell. Under `sudo vim`, that is a
    root shell — one keystroke away from an editing session someone approved
    for a single file. Anyone who can get you to open a file under `sudo vim`
    (or who can write your `~/.vimrc`) gets root. Under `sudo -e`, `:!` gets
    them a shell as you.
58. Re-run `sudo -e` and revert the line.

## G. Stretch

59. `vimtutor` is installed at `/opt/kestrel/bin/vimtutor`. Lessons 1–3 cover
    movement, deletion, put, and search. Nothing to check beyond them being
    able to say what `dw` does without looking it up.
60. `~/.vimrc` with the three `set` lines. Confirm: numbers appear; Tab
    inserts spaces (`cat -A` proves it); a `>>` indents by four.
61. Good answers: `/root`'s configuration runs whenever anyone uses `sudo vim`
    or a root shell, so one operator's plugins and shell escapes become
    everyone's attack surface and everyone's surprise; and a shared root
    account with personal config makes it impossible to tell whose habits
    produced a change. Either is a pass; both is better.
62. Reasonable vim: `gg` to the top, `/TODO`, then `Ctrl-a` on numbers if they
    number them by hand, or three `I` edits. The honest answer to the second
    half is usually **yes, `sed` would have been faster** — for three lines of
    a mechanical transform, `sed -i 's/^TODO: /1. /'` and friends win. The
    exercise exists so they say so out loud. A student who insists vim was
    faster should be asked to time both.
