# 01/05 — Editing the line you are typing

> You will type roughly forty thousand commands on this posting. The people who are fast at this are
> not fast typists — they are people who stopped retyping things.

The line you are typing is not owned by bash. It is handled by a library called **readline**, which
is why the same key bindings work in `python3`, `psql`, `gdb` and a dozen other tools. Learn them
once, use them everywhere.

This lesson is muscle memory. Reading it is nearly useless; the exercises are the entire point.

## Moving

| Keys | Does |
|---|---|
| `Ctrl-A` | jump to start of line |
| `Ctrl-E` | jump to end of line |
| `Alt-B` | back one word |
| `Alt-F` | forward one word |
| `Ctrl-B` / `Ctrl-F` | back / forward one character (same as arrow keys) |

`Ctrl-A` and `Ctrl-E` are the two that pay for themselves on day one. **A** for the start of the
alphabet, **E** for the end.

> **Alt keys.** If `Alt-B` does nothing, your terminal is probably sending the wrong thing. Press
> `Esc` then `b` instead — that always works, and is what `Alt` is doing under the hood.

## Deleting

| Keys | Does |
|---|---|
| `Ctrl-W` | delete the word before the cursor |
| `Ctrl-U` | delete from cursor to **start** of line |
| `Ctrl-K` | delete from cursor to **end** of line |
| `Ctrl-D` | delete the character under the cursor |
| `Alt-D` | delete the word after the cursor |

`Ctrl-U` is the panic key. Typed the wrong thing entirely? `Ctrl-U` and start again — faster and
more certain than holding backspace.

> **Careful with `Ctrl-D`.** On an **empty** line it does not delete anything: it signals
> end-of-input, and the shell exits. That is the same `Ctrl-D` that ends `cat` typing into a file.
> With text on the line it deletes a character; with no text it closes your session. Both behaviours
> are correct and they surprise everyone once.

## Putting it back

Everything you delete with `Ctrl-W`, `Ctrl-U` or `Ctrl-K` goes into a buffer readline calls the
**kill ring**.

| Keys | Does |
|---|---|
| `Ctrl-Y` | paste back the last thing you deleted |
| `Alt-Y` | after `Ctrl-Y`, cycle to the thing deleted before that |

This makes cut-and-paste possible without a mouse:

```
you have typed:   grep somepattern /var/log/very/long/path.log
                                    ^ cursor here
Ctrl-K            cuts the path off the end
                  ...type something else...
Ctrl-Y            pastes the path back
```

## Reusing the last line

| Keys | Does |
|---|---|
| `Alt-.` | insert the **last argument** of the previous command |
| `Ctrl-P` / `Ctrl-N` | previous / next history line (same as up/down arrows) |

`Alt-.` is the one people are most visibly impressed by, and it is genuinely the highest-value key
in this lesson:

```bash
$ ls /labs/01-shell-and-terminal/05-readline/very-long-name.txt
$ cat <Alt-.>
$ cat /labs/01-shell-and-terminal/05-readline/very-long-name.txt
```

Press it repeatedly to walk back through earlier commands' last arguments.

## Completion

`Tab` completes a partially typed word — a command name at the start of a line, a filename anywhere
else.

- One match → it completes it.
- Several → nothing visibly happens on the first press. Press `Tab` **again** to list them.
- None → nothing happens, which is itself information: what you typed is wrong.

That "nothing happens" on the first press is not a bug and is worth internalising, because it is
also the fastest way to check a filename exists before you commit to typing it.

Bash completion is extensible, and this image has `bash-completion` installed, so `git ch<Tab>` and
`systemctl st<Tab>` style completions work for tools that ship rules. It is not magic and it does
not know about every program.

## The rest of the line

| Keys | Does |
|---|---|
| `Ctrl-L` | clear the screen, keep the current line |
| `Ctrl-C` | abandon this line, start a fresh prompt |
| `Ctrl-T` | swap the two characters around the cursor |
| `Alt-T` | swap the two words around the cursor |

`Ctrl-L` is not `clear`. `clear` runs a program and starts a new prompt; `Ctrl-L` redraws with
whatever you had half-typed still there.

`Ctrl-C` deserves a note: on a line you are typing, it abandons the line. On a *running* program, it
sends an interrupt signal. Same key, two very different meanings depending on what is in front of
it. Chapter 9 does signals properly.

## Before you move on

You should be able to do these without looking anything up:

- Jump to the start and the end of a long line.
- Delete the last word, and delete the whole line.
- Paste back something you just deleted.
- Pull the last argument of the previous command into this one.
- Say what `Ctrl-D` does on an empty line, and why you should care.
