# 01/01 — Terminal, shell, tty

> Four decks, sixty-odd people, and a rack of machines that have been up for eleven years. You will
> be talking to them through a window that is not the thing it talks to. Worth knowing which is
> which before you start giving orders.

You have been typing into a black rectangle and calling it "the terminal". That word is doing at
least three jobs at once, and when something breaks, knowing which of the three broke is most of
the diagnosis.

## Three things, not one

```
  ┌─────────────────┐        ┌────────────┐        ┌───────────┐
  │ terminal        │◄──────►│    tty     │◄──────►│   shell   │
  │ emulator        │        │ (the wire) │        │  (bash)   │
  │ draws pixels    │        │ kernel     │        │ a program │
  └─────────────────┘        └────────────┘        └───────────┘
```

**The terminal emulator** is a program on *your* machine that draws characters in a window and
sends your keystrokes somewhere. GNOME Terminal, Alacritty, the Docker console, PuTTY. It knows
about fonts and colours and scrollback. It knows nothing about Linux commands.

**The tty** is the kernel's end of the connection — a character device file that the terminal talks
to on one side and the shell talks to on the other. It is a real file. You can look at it. Its job
is to carry bytes, do the most basic line handling, and deliver signals (Ctrl-C) to whatever is
attached.

**The shell** is just a program: `bash`, `dash`, `zsh`, `fish`. It reads a line, works out what you
meant, runs it, prints the result, and loops. Nothing about a shell requires a terminal — a shell
can read commands from a file with no human anywhere near it.

This is worth clearing up because the three fail separately. Colours wrong? Emulator. Ctrl-C not
killing anything? tty. `command not found`? Shell.

## Which tty am I on

```bash
$ tty
/dev/pts/0
```

`pts` is a **p**seudo-**t**erminal **s**lave — the software kind, created when a terminal emulator
or an SSH session opens. `/dev/tty1` and friends are the real hardware consoles you get with
Ctrl-Alt-F1 on a physical machine.

If a shell has no terminal attached at all — because its output went into a pipe, or it is running
from a script — `tty` says so:

```bash
$ echo hi | tty
not a tty
```

That is not an error. It is a fact about the environment, and programs check it. `ls` prints one
name per line when its output is a pipe and multiple columns when it is a terminal, for exactly
this reason. Try it.

## Which shell am I in

Every running process has a **process ID**. The shell's own PID is in the special variable `$$`:

```bash
$ echo $$
2417
```

Then ask the process table what that PID actually is:

```bash
$ ps -p $$
    PID TTY          TIME CMD
   2417 pts/0    00:00:00 bash
```

`ps -p <pid>` shows one specific process. Note the `TTY` column — it agrees with what `tty` told
you. That is the same connection, seen from the other end.

> **Gotcha.** `echo $SHELL` looks like it answers this question. It does not. `$SHELL` is your
> *login shell as recorded in the account database* — what you get by default. If you then type
> `dash` and are now sitting in dash, `$SHELL` still says bash. It is a preference, not an
> observation. `ps -p $$` is an observation. Prefer observations.

## Nesting

Shells nest. Type `bash` inside bash and you have two shells, one running inside the other:

```bash
$ echo $$
2417
$ bash            # a child shell
$ echo $$
2588
$ exit            # back out
$ echo $$
2417
```

`exit` leaves the current shell. When you exit the last one the terminal has nothing left to talk
to, and the window closes. That is *why* typing `exit` closes a terminal — you are not closing a
window, you are ending a program, and the window follows.

`ps` with no arguments shows the processes on your tty, which makes the nesting visible:

```bash
$ ps
    PID TTY          TIME CMD
   2417 pts/0    00:00:00 bash
   2588 pts/0    00:00:00 bash
   2601 pts/0    00:00:00 ps
```

Three processes, one tty. `ps` is in the list because it is itself a process, running at the
moment it looks.

## Who am I to the machine

```bash
$ whoami
cadet
$ id
uid=1000(cadet) gid=1000(cadet) groups=1000(cadet),27(sudo),1001(crew)
```

`whoami` is the short answer, `id` the complete one. Chapter 10 takes this apart properly. For now,
one thing to notice: the numbers are what the kernel actually uses, and the names are a convenience
laid over them for humans.

## Before you move on

You should be able to say, in one sentence each:

- What a terminal emulator does that a shell does not.
- What `tty` prints, and what it means when it prints `not a tty`.
- Why `ps -p $$` is a better answer than `echo $SHELL` to "which shell am I in".
- What happens to the terminal window when the last shell in it exits.
- Why `ps` always lists `ps` itself.
