# 12/01 — Your first script

> Everything you have typed twice this month is a script you have not written yet.

You have been writing shell for eleven chapters. A script is not a new language;
it is the same commands in a file, read top to bottom. What is new is everything
around the commands: how the file gets run, which program runs it, whether it is
allowed to run at all, and what it tells its caller when it finishes.

## The first two bytes

The first line of a script is not a comment. It looks like one and the *shell*
treats it like one — but the shell is not the first thing to read the file. When
you type `./deck-count.sh`, the kernel opens the file and reads its first two
bytes. If they are `#!`, the kernel takes the rest of that line as the program to
run, and hands it the script's path:

```
./deck-count.sh      becomes      /usr/bin/env bash ./deck-count.sh
```

Three consequences, all of which you will hit this week:

- **It is a path, not a command name.** `PATH` is not searched. `#!bash` is not a
  shebang, it is an error waiting to happen.
- **The file it names must exist and be executable.** A shebang pointing at
  `/usr/local/bin/bash` on a station where bash lives in `/usr/bin` gives you
  `cannot execute: required file not found` — which sounds like the *script* is
  missing. It is not. The interpreter is.
- **`#!/usr/bin/env bash` searches PATH**, because that is `env`'s job. `env`
  lives in `/usr/bin` almost everywhere; `bash` does not. That is the whole
  argument for the longer form.

None of this applies when you run `bash script.sh`. There you named the
interpreter yourself, so the kernel never gets asked and the first line is just a
comment. A script with a broken shebang still runs fine that way, which is
exactly how a broken shebang survives to production.

## Three ways to run it, and they differ

```
./script.sh      execute the file    needs +x   new shell   shebang honoured
bash script.sh   execute bash        no +x      new shell   shebang ignored
. ./script.sh    source the file     no +x      THIS shell  shebang ignored
```

The first two ask "run this program". The third asks "become this". Anything the
script changes — variables, the working directory, aliases — comes back only in
the third case, because there was never a second process to lose it in. This is
the same subshell boundary from Chapter 11 lesson 01, and it is why a script that
`cd`s somewhere leaves you exactly where you were.

## The exec bit is a permission, not a property

`Permission denied` with exit status **126** on a file you can read means the
file is fine and the mode is not. `chmod +x` — Chapter 10's tool, doing Chapter
10's job. Status **127** is different: something in the chain could not be
*found*, and on a script that usually means the shebang.

Learn the two apart now. `126` = found it, may not run it. `127` = did not find
it. You will read these two numbers for the rest of your career.

## What a script says when it finishes

A script's exit status is the status of the last command it ran, unless it says
otherwise with `exit N`. That is a default, not a decision — and Chapter 11
lesson 05 already showed you what it costs: a script whose last line is an `echo`
exits `0` regardless of what failed three lines earlier, and every caller
believes it.

There is one such script in this lab, in `ops/`. It is named for cleaning up and
it reports that it cleaned up. Read it. You are not asked to fix it yet.

## Comments

A comment costs nothing at runtime and answers the question you will have in
March. Say *why*, not *what*: the line already says what.

## What you will do

Run the same file three ways and account for every difference. Break a shebang
five ways and match each failure to its cause and its status code. Write
`deck-count.sh` from scratch, make it executable, and prove it exits nonzero when
it should.
