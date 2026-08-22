# Chapter 1 — Shell & Terminal, Properly

## Incident briefing

Nobody hands you a ticket on your first week. What you get is an account, a workstation, and a
station that has been running for eleven years without anyone tidying up after themselves.

So you start where everyone starts: finding out what you are actually typing into. Which program is
reading your keystrokes, what it does with them, and what it remembers afterwards. It is not
glamorous and it is the foundation of every other chapter — Chapter 6 hands you tools that will
mangle their own input if you cannot quote, and Chapter 12 has you write scripts that will fail
silently if you cannot tell an unset variable from an empty one.

At the end of the chapter there is a file nobody has read in three weeks: the shell history of the
sysadmin you replaced. His last command stops in the middle of a word.

## Learning objectives

- [ ] Separate terminal emulator, tty, and shell — and diagnose which one has broken
- [ ] Prove which shell is running, without trusting `$SHELL`
- [ ] Explain what `/bin/sh` is on Ubuntu, and why a script can work under `bash` and fail under `sh`
- [ ] Describe how the shell splits a line, and what it does *not* interpret
- [ ] Resolve a command word through all five kinds — alias, keyword, function, builtin, file
- [ ] Read and write shell variables, and tell **unset** from **empty**
- [ ] Edit a command line without arrow keys: jump, cut, yank, and reuse the last argument
- [ ] Search, recall and reason about shell history — and know when it is written to disk
- [ ] Reconstruct a truncated command from evidence rather than guesswork

## Prerequisites

Chapter 0, complete — you need a working container, and `kestrel seed` / `kestrel reset` / `kestrel
flags submit` all working. Nothing else.

## Lessons

- [`01-terminal-vs-shell-vs-tty`](01-terminal-vs-shell-vs-tty/readme.md) — three things one word is
  doing; `tty`, `$$`, `ps -p $$`
- [`02-shells-on-the-box`](02-shells-on-the-box/readme.md) — `/bin/sh` is a symlink; `/etc/shells`
  versus what is installed; `$SHELL` vs `$0` vs `ps`
- [`03-command-anatomy`](03-command-anatomy/readme.md) — words, flags, `--`; the five kinds of
  command word; `type` over `which`; aliases
- [`04-variables`](04-variables/readme.md) — assignment shape, `${VAR}`, unset vs empty, the
  default-value family, `$?`
- [`05-readline`](05-readline/readme.md) — moving, deleting, the kill ring, `Alt-.`, Tab completion,
  `Ctrl-D`'s two meanings
- [`06-history`](06-history/readme.md) — the list versus the file, `!!` `!$` `!n`, `Ctrl-R`,
  `HISTCONTROL`, `history -a/-c/-r`
- [`07-incident-01`](07-incident-01/readme.md) — **incident:** reconstruct a command from a history
  file that stops mid-word

## Flags in this chapter

**One**, in `07-incident-01`. It is not gettable by grepping for it, and it is not gettable without
having understood 01/06. Everything else in the chapter is practice for it.

## Recording

Lesson 01/05 is the one lesson in this course that **cannot** be validated after the fact —
keystrokes leave no trace, and `Ctrl-A` looks identical to thirty left-arrows in every log. Start a
recording before you begin it. `docs/RECORDING.md`.

## Before you move on

You should be able to do all of these without looking anything up:

```bash
ps -p $$          # which shell, actually
type -a echo      # what would run, and what else has that name
echo "${x:-fallback}"
```

- Get to the start of a long line in one keystroke.
- Pull the previous command's last argument into this one without touching the arrow keys.
- Find a command you ran an hour ago by searching for a fragment of it.
- Read a file whose name begins with a dash.
- Explain why the last line of a history file is often unfinished.

Chapter 2 moves you around the filesystem, and it assumes all of the above.
