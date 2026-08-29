# 11/02 — PATH

> When you type a command, something decides which file that means. It is a list, it is in order,
> and anybody who can edit it can decide what `ls` means to you.

You have typed `ls` several hundred times in this course without once saying which `ls` you meant.
Something resolved that for you, every time, and it was not magic and it was not the kernel. It was
one environment variable holding a list of directories, searched **left to right**, stopping at the
first executable file with a matching name.

That is the entire algorithm. No scoring, no preference for the newest, no notion of a "correct"
version. Order, and a stop. Which means the question "where does `ls` live" has a right answer only
relative to a particular `PATH`, and two people in the same directory can type the same word and run
different programs. That is lesson 01's `env` problem with a sharper edge: an environment variable
that decides what your *verbs* mean.

Not everything you type is looked up in `PATH`, and the levels above it matter more than people
expect. Bash resolves a command name in this order: **alias, function, builtin, hash table, PATH.**
`cd` is a builtin and cannot be anything else — a program cannot change its parent's working
directory, for exactly the reason lesson 01 gave you. On this station `ls` is an alias before it is
ever a file, which you can see with `type -a` and which `which` will never tell you.

The hash table is the level people forget. Bash remembers where it found a command so it does not
walk the list again, and it does not notice when the answer changes. Move a program, or install a
copy earlier in `PATH`, and bash keeps running the old one — and if the old file is gone you get an
error naming a path you never typed, which is the clearest fingerprint in this chapter.

There are five tools for asking "what would run", they disagree, and the disagreement is not a bug.
`type` knows about aliases, functions and builtins because it is part of bash. `which` is a separate
program that searches `PATH` and nothing else, so it can answer confidently and wrongly. This lab
contains one file on which `type`, `type -a`, `command -v` and `which -a` give three different
answers between them, and running it gives a fifth result. Exercise 30 is that file. All five are
correct; they are answering different questions.

Two hazards close the lesson. An **empty element** in `PATH` — leading, trailing, or a doubled colon —
means the current directory, so a file dropped in a directory you `cd` into can become a command you
run. And **position is trust**: `PATH="$HOME/bin:$PATH"` means your copies beat the system's, while
`PATH="$PATH:$HOME/bin"` means the reverse. Both are defensible. Choosing without noticing you chose
is not.

rhea's note is the chapter arc arriving early. Two people, one command, one directory, two different
outputs, and neither terminal broken. She is not asking you to fix anybody's configuration. She is
asking whether you could **detect** it.

## What you will be able to do

- [ ] Print `PATH` one entry per line, numbered, and talk about entries by position
- [ ] State the lookup rule — left to right, first executable match, stop
- [ ] Give bash's full resolution order and place `PATH` last in it
- [ ] Explain why `cd` cannot be a program on disk
- [ ] Use `type`, `type -a`, `type -t`, `command -v` and `which -a`, and say what each one can miss
- [ ] Predict which of two same-named commands runs, from the `PATH` alone
- [ ] Add a directory to `PATH` at the front or the back, and defend the choice
- [ ] Say why `export PATH=$HOME/bin` breaks your shell and what the fix is
- [ ] Recognise a stale hash entry from its error message, and clear it
- [ ] Say why `hash -r` is needed after installing a program earlier in `PATH`
- [ ] Identify an empty `PATH` element in three spellings and say what it means
- [ ] Explain what shadowing is, how cheap it is, and how you would detect it
- [ ] Build a personal `~/bin`, put something in it, and have it found

## Files

```
bin/station-status    v1. Prints three lines
bin/deck-report       v1. Names the directory it reads from
override/station-status  v2, same name, one extra line of output
override/deck-report  v2, same name, a different source directory
override/ls           a wrapper that announces itself and runs the real ls
broken/station-status v3, and it will never print. One bit is missing
broken/README         what to run, and the five tools that disagree about it
notes/path.txt        the list, the resolution order, and the five tools
notes/lookup.txt      editing PATH, the empty entry, and the hash table
notes/page.txt        rhea, cass, and one command with two answers
scratch/              yours
```

Nothing here is installed. Every directory in this lab reaches your `PATH` only because you put it
there, for as long as your shell lasts. Lesson 03 is about the file that would make it permanent.

## Reset

`kestrel reset 11/02`. If your shell has become strange — commands not found, or the wrong copies
running — `exit` and `kestrel enter` is faster than repairing it, and exercise 46 is about why.
