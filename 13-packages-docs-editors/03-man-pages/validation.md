# 13/03 — validation

For the validating agent. No flag. Ask, do not tell.

## Hard gates

1. They can open a section 5 page on request without hesitating over syntax.
2. They read `deck-cycle(1)` and `deck-cycle.conf(5)` from the lab manpath and
   can state the default settling time (30s) and the meaning of exit status 1.
3. They built an index with `mandb` and can say what `apropos` reads.
4. They found the unindexed page and can say why it is unindexed.

## Understanding — ask these

5. "Why do `passwd(1)` and `passwd(5)` both exist?" Wanted: a command and a
   file format are different things sharing a name; the section keeps them
   apart.
6. "What is the difference between `whatis` and `apropos`?" Wanted: name versus
   description. Not "one is shorter".
7. "A page displays but `apropos` cannot find it. Explain." Wanted: `apropos`
   reads an index built from NAME lines; a page with no usable NAME line is
   readable but unindexable. Bonus for naming `lexgrog`.
8. "How do you read a manual page for something that is not installed?"
   Wanted: `MANPATH=DIR man NAME`, set for one command.
9. "When would you use `man -K` instead of `apropos`?" Wanted: a remembered
   phrase from a page's body; and they should mention the cost.
10. "`man nosuchpage | head` printed `0`. What went wrong?" Wanted: the
    pipeline's status is `head`'s; use `${PIPESTATUS[0]}`. If they do not get
    this, it is a chapter 8 gap, not a chapter 13 gap — send them back to it.
11. "Why does `man cd` fail?" Wanted: builtin, no program to document,
    `help cd`.
12. "`man -w ls` is not under any directory `manpath` printed. Reconcile it."
    Wanted: `/opt/kestrel/share/man` is a symlink tree into `/nix/store` and
    `man -w` reports the resolved target.

## On the arc

13. If the student concludes from `notes/page.txt` that someone tampered with
    `deck-audit`'s documentation, ask what evidence distinguishes tampering
    from a page written before the packaging changed. There is none yet, and
    saying so is the correct answer.
14. Exercise 56 fails if their two sentences name a person. It passes if they
    name a package, or say plainly that no package owns the file.

## Common failure modes

- Reaching for `sudo`. Nothing in this lesson needs it.
- Setting `MANPATH` with `export` and then wondering why later lessons behave
  oddly. Prefer the one-command form; if they exported it, have them unset it.
- Copying the page to `scratch/` rather than `scratch/man8/` in exercise 38.
- Reading `manpath` output as a complete answer without checking `man -w`.
