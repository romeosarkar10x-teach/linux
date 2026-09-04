# Lesson 05 — The prompt, and the switches that change what the shell means

Two pages arrived overnight and they look unrelated.

ops-bot: the scheduled deck audit finished with exit status 0 and reported zero
decks. It has reported twelve decks for forty cycles. The scheduler alerts on
non-zero status, so nothing was raised.

rhea: her prompt "eats itself" when she edits a long command. She has compared
her colour escapes against a working prompt character by character and they are
identical. She also says — and she is right — that the two complaints are
probably not related.

They are not related. They are the same lesson from two ends: **the shell has
switches, and a switch you did not set is still a decision.** Nobody chose
`errexit off`. It is off because that is the default, and the default is that a
failing command is somebody else's problem.

## PS1 is a string the shell re-expands every time

Before it asks you for a command, bash expands `PS1` and prints it. That is the
whole mechanism. `\u` becomes your username, `\w` your working directory, `\$`
becomes `#` for root and `$` for everyone else, `\!` the history number. Text
that is not an escape is literal. `$( )` inside `PS1` runs — every prompt.

`PS2` is what you see when you press Enter with a quote still open (`> `).
`PS4` is what `set -x` puts in front of each traced line (`+ `).
`PROMPT_COMMAND` is not a prompt: it is a command bash runs *before* drawing
one. Set it and you will see it fire immediately, before you have typed
anything else.

Colour is escape sequences — `\e[1;32m` on, `\e[0m` off. They print nothing.
Readline still has to count columns to know where your cursor is, and it counts
by looking at the string. So every run of non-printing characters must be
wrapped in `\[` and `\]`, which mean "this takes no space". Get it wrong and
short commands look perfect; long ones wrap in the wrong column and redraw over
themselves. That is rhea's bug, and it is not the terminal, and she was right
that it is not related to the audit.

## Two option lists, and they use minus for opposite things

    set -o      POSIX options       set -u   on     set +u   off
    shopt       bash's own options  shopt -s on     shopt -u off

For `set`, minus turns a thing **on**. For `shopt`, `-u` turns a thing **off**.
Read every option line twice for the rest of your life.

The ones that change what a script means:

| switch | what it does | what it costs |
|---|---|---|
| `set -e` | stop at the first failing command | it does not fire inside `if`, or `cmd \|\| other`, or mid-pipeline |
| `set -u` | an unset variable is an error | `${VAR:-default}` is still fine — that is not "unset" |
| `set -o pipefail` | a pipeline fails if **any** stage failed | without it only the last stage counts |
| `set -C` | `>` refuses to overwrite | `>\|` overrides it deliberately |
| `set -x` | print each command before running it | prefixed with `PS4` |

`set -euo pipefail` is one line at the top of a script that means *I would
rather this stop than continue while wrong*. The audit script has none of it:
`cat` failed, `wc -l` counted zero lines successfully, the pipeline's status was
`wc`'s, and the script exited 0 with a wrong answer. Nothing is broken. Every
component did what it was told.

## Options are per-shell, and a script is a different shell

`set -u` in your shell does not reach a script you run, because the script gets
its own shell. `bash -u script.sh` does. `export SHELLOPTS` does too, which is
a thing you can do and probably should not.

## Objectives

- [ ] Read `PS1` as a string, and name what `\u \h \w \W \$ \! \t` expand to
- [ ] Change your prompt for one shell, and know why it does not survive
- [ ] Explain what `\[ \]` are for and diagnose a prompt without them
- [ ] Distinguish `PS1`, `PS2`, `PS4`, and `PROMPT_COMMAND`
- [ ] Use `set -o` and `shopt` to *read* the current state before changing it
- [ ] Turn options on and off with the right sign for the right command
- [ ] Predict which of four failure shapes `set -e` reacts to
- [ ] Say why `set -u` is happy with `${VAR:-default}`
- [ ] Show a pipeline whose status changes when `pipefail` is on
- [ ] Fix the deck audit so that a missing file is an error
- [ ] Use `globstar`, `dotglob`, `nocaseglob`, `nullglob`, `failglob` and say
      which two are dangerous in a script
- [ ] Read `HISTCONTROL`, `HISTSIZE`, `histappend`, and explain a lost history
- [ ] Find the two `HISTSIZE` lines in your own `.bashrc` and say which wins

## Files

    rc/prompts.sh          five prompts; one is rhea's, and it is broken
    rc/options.sh          five options worth arguing about
    scripts/deck-audit.sh  the audit that exits 0 and is wrong
    scripts/deck-audit-strict.sh  the same audit with the three switches
    scripts/greet.sh       an unset variable, two ways
    scripts/checks.sh      four failure shapes, four checkpoints
    glob/                  fixtures the glob options act on
    data/decks             where the deck list actually lives now
    notes/                 prompt, options, history, and the two pages
    scratch/               yours

## Reset

    kestrel reset 11/05
