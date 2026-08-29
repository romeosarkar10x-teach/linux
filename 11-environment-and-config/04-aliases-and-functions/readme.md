# 11/04 — Aliases and functions

> "Interactive submissions, cycle 41: 2 lines. Scheduled submissions, cycle 41: 3 lines.
> Source file unchanged since 2185-11-02. Both accepted. Both recorded as authoritative.
> No fault detected."
> — ops-bot, 2187-06-24

Lesson 02 showed you how to change what a command name means by editing `PATH`. This lesson shows
you two ways to do it that `PATH` cannot see at all, and that `which` will never report.

## An alias is a text substitution

That is the entire definition. Bash looks at the **first word** of a command, and if it is an alias,
replaces it with the alias's text before deciding what to run.

```
alias ll='ls -l'
```

Every surprise follows from "text substitution, first word only, at read time":

- `echo ll` does not expand — `ll` is not the first word.
- An alias defined and used on the **same line** does not expand: bash parsed the line before the
  alias existed.
- An alias has **no arguments**. There is no `$1`. Whatever you type is left sitting after the
  replacement text, which is sometimes what you wanted and sometimes a disaster.
- A **trailing space** in the replacement makes bash check the next word for an alias too. That is
  the whole mechanism behind `alias sudo='sudo '`, and it is not a typo when you see it.
- Aliases are switched off in non-interactive shells. You measured this in lesson 03. It is about to
  matter.

## A function is a piece of your shell

```
mkcd() { mkdir -p -- "$1" && cd -- "$1"; }
```

A function runs **in your current shell**, not a child process. It takes arguments, returns a status,
can declare `local` variables, can change your directory — and it works in scripts, because it is not
an alias.

It also shadows more completely than `PATH` ever could. Recall the resolution order:

```
alias -> function -> builtin -> hash -> PATH
```

`PATH` is last. A function named `deck-report` means `PATH` is never consulted, so `which
deck-report` reports a file that has nothing to do with what runs. This is the same disagreement you
met in lesson 02, arriving from a completely different direction, and it is the reason `type` is the
tool to reach for.

To wrap a program with a function of the same name, use `command`, which skips aliases and functions:

```
deck-report() { command deck-report "$@"; }
```

Leave `command` out and the function calls itself. Do not assume you know what that looks like —
exercise 43 asks you to measure it, and the answer is not an error message.

## ops-bot's discrepancy

Two lines interactively, three from the scheduler, one unchanged program. Nothing in this chapter so
far explains it except in combination: an alias in a sourced file, plus the fact that aliases do not
exist in non-interactive shells. The same file, sourced by both, produces two different commands. Both
submissions were accepted. Both are recorded as authoritative. ops-bot reports no fault, and ops-bot
is right — there is no fault. There is a decision nobody wrote down.

You will reproduce it exactly in exercises 18–23.

## Objectives

- [ ] Define an alias and explain why only the first word expands
- [ ] Explain why an alias defined and used on one line does not work
- [ ] State why an alias cannot take arguments, and what happens to the words you type after it
- [ ] Use the trailing-space rule, and say what `alias sudo='sudo '` is for
- [ ] Bypass an alias with `\name`, quoting, and `command`, and say how the three differ
- [ ] Define a function, take arguments, and return a status with `return`
- [ ] Use `local`, and demonstrate what happens without it
- [ ] Show that a function shadows a program completely and that `which` cannot see it
- [ ] Wrap a program with `command`, and measure what happens without it
- [ ] Explain why aliases are useless in scripts and functions are not
- [ ] Inspect with `type`, `declare -F`, `declare -f`; remove with `unalias` and `unset -f`
- [ ] Reproduce ops-bot's two-versus-three-lines discrepancy from configuration alone
- [ ] Say when to reach for an alias and when for a function, with a reason

## Files

```
bin/deck-report     the real program. Understands --terse. Unchanged since 2185
rc/aliases.sh       ordinary aliases, and one landmine
rc/functions.sh     the same jobs done as functions
rc/broken.sh        three plausible mistakes, each wrong differently
notes/aliases.txt   what an alias is and the five rules that catch people
notes/functions.txt what a function is, and why `command` exists
notes/page.txt      ops-bot. No fault detected.
scratch/            yours
```

Put `bin/` on your `PATH` before you start:

```
lab 11/04
L=$PWD
export PATH="$L/bin:$PATH"
```

## Reset

```
kestrel reset 11/04
```

Nothing you define in your own shell survives it exiting — which is lesson 03's point arriving from
the other side, and the reason this lesson never asks you to edit a startup file.
