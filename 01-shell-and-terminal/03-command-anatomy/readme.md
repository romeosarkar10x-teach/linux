# 01/03 — What a command actually is

> Half of what you type is not the program you think it is. On a machine with eleven years of
> accumulated helpfulness bolted to it, that is worth checking before it matters.

You type a line. Something happens. Between those two events the shell does a specific, knowable
sequence of things, and when a command misbehaves the answer is almost always "it wasn't the
program you thought".

## The shape of a line

```
    ls    -l  --color=auto   /labs   notes.txt
    ▲     ▲        ▲           ▲        ▲
    │     │        │           └────────┴── operands (arguments)
    │     └────────┴────────────────────── options (flags)
    └──────────────────────────────────── the command word
```

The shell splits your line on whitespace into **words**. The first word is what to run; the rest
are handed to it as arguments, in order, as a list of strings.

That is the whole contract. The shell does not know what `-l` means. It does not know that
`/labs` is a directory. It hands `ls` a list — `["-l", "--color=auto", "/labs", "notes.txt"]` — and
`ls` decides what any of it means.

This is why flag conventions vary between programs: there is nobody enforcing them.

## Flag conventions

| Form | Read as | Example |
|---|---|---|
| `-l` | one short flag | `ls -l` |
| `-la` | two short flags bundled | same as `ls -l -a` |
| `--long` | one long flag | `ls --all` |
| `--key=value` | long flag with a value | `ls --color=never` |
| `--key value` | same, separated | `ps -o pid` |
| `--` | "no more flags after this" | `ls -- -weird-file` |

Bundling only works for short flags that take no value. `tar -czf x.tgz dir` bundles three, and the
one that takes a value has to come last — which is why `-f` is always last in a tar bundle, a fact
Chapter 14 will make you tired of.

`--` is worth remembering now. A file named `-l` is a legal filename, and every tool you own will
mistake it for a flag. `--` is how you say "stop parsing options":

```bash
$ rm -l          # error: rm thinks -l is a flag
$ rm -- -l       # deletes the file named -l
```

Chapter 5 has an entire incident built on this.

## Five kinds of command word

When the shell has a command word, it resolves it in a **fixed order**:

1. **Alias** — a text substitution defined in your shell. Checked first.
2. **Keyword** — part of the shell's grammar: `if`, `for`, `while`, `[[`, `function`.
3. **Function** — a shell function you or a startup file defined. (Chapter 12.)
4. **Builtin** — a command compiled into the shell itself: `cd`, `echo`, `type`, `export`.
5. **File on PATH** — an executable found by searching the `PATH` directories in order.

The order is not trivia. It is why an alias can shadow a real program, why `cd` cannot be a
program, and why the same word can mean different things in two shells.

> **Why `cd` must be a builtin.** A program runs as a *child* process. A child cannot change its
> parent's working directory — nothing can reach up like that. So `cd` has to be executed by the
> shell itself. There is a `/usr/bin/cd` on some systems, and it is useless by design.

## `type` — the question to ask first

```bash
$ type cd
cd is a shell builtin
$ type ls
ls is /opt/kestrel/bin/ls
$ type if
if is a shell keyword
```

`type` answers "what would happen if I ran this word", which is the question you actually have.

Two flags earn their keep:

```bash
$ type -t echo        # just the category, one word
builtin
$ type -a echo        # EVERY match, in resolution order
echo is a shell builtin
echo is /opt/kestrel/bin/echo
echo is /usr/bin/echo
echo is /bin/echo
```

`type -a echo` on this station finds four `echo`s. One is built into bash, three are separate
programs in three directories. When you type `echo`, you get the builtin — it is earlier in the
order — and you will never touch the other three unless you name them by path.

They are not identical. The builtin and the external `echo` differ on flag handling, and that
difference has broken real scripts.

## `which` and why `type` is better

```bash
$ which echo
/opt/kestrel/bin/echo
```

`which` searches PATH for files. That is all it does. It does not know about builtins, keywords,
aliases, or functions — so for `echo` it gives you an answer that is *true* and *not what will
run*.

```bash
$ which cd
$            # nothing. But cd obviously works.
$ which -a echo
/opt/kestrel/bin/echo
/usr/bin/echo
/bin/echo
```

> **Rule.** `which` answers "is there a program by this name, and where". `type` answers "what will
> actually run". You almost always want the second question. Reach for `type` by default.

There is also `command -v`, which is the POSIX-standard way to ask and which works in dash where
`type -a` may not. Chapter 12 uses it in scripts.

## Aliases, briefly

An alias is a word-for-text substitution the shell does before anything else:

```bash
$ alias ll='ls -l'
$ ll                 # runs: ls -l
$ type ll
ll is aliased to `ls -l'
$ unalias ll
```

Two things to know now, and the rest in Chapter 11:

- An alias **shadows** a real command of the same name. `alias ls='ls --color=never'` is
  fine — the alias body is not re-expanded into itself — but it does mean `ls` no longer means what
  the manual says.
- **Backslash escapes it.** `\ls` runs the real `ls`, ignoring any alias. So does `command ls`.
  When something behaves oddly, `\` is a fast way to find out whether an alias is responsible.

Aliases defined at the prompt vanish when the shell exits. Making them stick is Chapter 11.

## Putting it together: diagnosing "that's not what I expected"

```bash
$ type -a <word>     # what will run, and what else has that name
$ \<word>            # run it with aliases bypassed
$ command -v <word>  # the portable question
```

Three commands, and most "why is this behaving strangely" questions collapse.

## Before you move on

- What the shell does with the words on a line, and what it does *not* interpret.
- What `--` is for, and why a file named `-l` needs it.
- The five kinds of command word, in resolution order.
- Why `cd` cannot be an external program.
- Why `type` is a better default than `which`.
