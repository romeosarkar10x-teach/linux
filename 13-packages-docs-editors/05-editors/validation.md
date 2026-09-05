# 13/05 — validation

For the validating agent. No flag. Ask, do not tell.

## Hard gates

1. They can open a file in vim, change one line, save, and quit — and quit
   without saving — without hesitating.
2. They reached line 402 of `cycles.log` by line number and found `SKIPPED` by
   search, not by scrolling.
3. They saw `E325: ATTENTION` for real and can say what a swap file is.
4. Their edit to `hatch-alarms.conf` carries a comment saying what changed and
   why. A correct value with no comment does not pass; that is the exercise.

## Understanding — ask these

5. "You are in vim and lost. What do you press?" Wanted: `Esc`, then `:q!`.
6. "Why did `:wq` end up inside your file?" Wanted: typed in insert mode.
7. "Two files look identical and one does not parse. What do you check?"
   Wanted: whitespace and line endings — `:set list` inside, `cat -A` outside.
   Bonus: `file` did not mention the CRLF, so it is a hint and not an audit.
8. "What is a swap file for, and what does finding one tell you?" Wanted:
   crash recovery; either someone has the file open now, or an editing session
   died. Explicitly not: a conclusion about who or why.
9. "What is the difference between `sudo vim` and `sudo -e`?" Wanted: the whole
   editor runs as root versus your editor running as you on a copy. Bonus:
   `:!` gives a root shell, and a `.vimrc` or a modeline becomes a privilege
   escalation path.
10. "Which of `EDITOR` and `VISUAL` wins?" Wanted: `VISUAL` first, usually —
    and that they checked a manual page rather than guessing.
11. "When would you use `sed` instead of an editor?" Wanted: anything
    repeatable, scripted, or across many files. An editor is for a judgement
    call on one file.

## On the arc

12. `notes/page.txt` observes that configuration files record what changed and
    never why. If the student reads that as evidence of tampering, ask what
    else it is consistent with — a typo, a rushed shift, a change nobody wrote
    up. All three are more likely than sabotage and the file cannot distinguish
    them.
13. A student whose fix comments say *why* has understood the lesson better
    than one who fixed more lines.

## Common failure modes

- Editing the originals in `conf/` instead of copies in `scratch/`. Recoverable
  by re-running `setup.sh`; make sure they know that.
- Answering `(E)dit anyway` to a swap file warning by reflex.
- `sudo vim` out of habit after exercise 56.
- Treating `:%s/a/b/g` as safe on a file that matters — the `c` flag exists.
- Exporting `EDITOR` in the current shell and expecting it to survive a login.
