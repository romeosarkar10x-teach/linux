# 01/02 — The shells on the box

> The station's accounts do not agree on what a shell is. Some of that is history. Some of it is
> somebody in a hurry, eleven years ago, and it is still here.

"The shell" is not a thing. It is a category, the way "browser" is a category, and the differences
between the members are small enough to ignore right up until the moment they bite.

## The ones you will meet

| Shell | What it is | Where you meet it |
|---|---|---|
| `bash` | the GNU Bourne-Again Shell. Big, featureful, everywhere. | your interactive shell, almost always |
| `dash` | Debian Almquist Shell. Small, fast, strictly POSIX. | `/bin/sh` on Debian and Ubuntu |
| `sh` | not a shell — a *promise*. A pointer to whatever shell provides POSIX behaviour. | script shebangs |
| `zsh` | bash's more configurable cousin. Default on macOS. | other people's machines |
| `fish` | friendly, and deliberately *not* POSIX-compatible. | other people's machines |

Two of those matter to you right now: `bash`, because you are typing into it, and `sh`, because it
is not what you think it is.

## `/bin/sh` is a lie of convenience

On Ubuntu:

```bash
$ ls -l /bin/sh
lrwxrwxrwx 1 root root 4 ... /bin/sh -> dash
```

It is a symlink. `sh` is the *interface* — the POSIX shell language — and `dash` is the
implementation Ubuntu chose because it starts faster, which matters when the boot process runs
thousands of small scripts.

This is the single most common source of "it works when I run it, it fails from the script":

```bash
$ echo "hello" > /tmp/t.sh          # a script starting with #!/bin/sh
# bash-only syntax inside it
$ bash /tmp/t.sh    # works
$ sh /tmp/t.sh      # syntax error
```

Things bash has that dash does not include `[[ ]]`, arrays, `$'...'`, `local` in some forms, and
`source` as a synonym for `.`. You meet all of those properly in Chapter 12. What you need now is
the reflex: **`sh` and `bash` are different programs, and a shebang chooses one.**

## What shells are installed

Two different questions, and they have different answers.

**Which shells are registered as valid login shells:**

```bash
$ cat /etc/shells
# /etc/shells: valid login shells
/bin/sh
/usr/bin/sh
/bin/bash
/usr/bin/bash
/bin/rbash
/usr/bin/rbash
/usr/bin/dash
```

Note that several of those are the same program reached by two paths, and that `rbash` is bash in
a restricted mode. The file is a list of *paths*, not of distinct programs.

`/etc/shells` is a plain text file, one path per line. It does **not** install anything and it does
not enforce anything for `su` or for scripts. It is a list that certain programs consult — `chsh`
refuses to set a login shell that is not in it, and FTP daemons historically refused logins for
users whose shell was absent from it.

**Which shells actually exist on disk** is a different question, and `/etc/shells` can be wrong in
both directions: it can list a shell that has been uninstalled, and it can omit one that is
installed. Check the filesystem, not the list.

> **Gotcha.** A path being in `/etc/shells` is not evidence the program is there. On a machine
> where things have been removed over the years, that file is an archaeological record. It is also
> not a complete list of usable shells — nothing stops you running a shell that is not in it.

## Which shell is running this

Three ways, in increasing order of trustworthiness:

```bash
$ echo $SHELL       # your login shell preference. Not necessarily what is running.
/bin/bash
$ echo $0           # the name this shell was invoked as. Usually right.
bash
$ ps -p $$          # what the kernel says is running. Always right.
```

`$0` is the **name the current process was invoked as** — argument zero. In a script, `$0` is the
script's path, which is how scripts print their own usage messages. In an interactive login shell
it is often `-bash`, with a leading dash. That dash is the convention a *login program* uses to tell
a shell "you are a login shell, read the login startup files". Note who does it: the thing that
starts the shell chooses the name, so `bash -l` does **not** produce a leading dash — it asks for
login behaviour without renaming anything. Chapter 11 makes that matter.

```bash
$ bash
$ echo $0
bash
$ exit
```

`$0` can be lied to — a program can invoke a shell under any name it likes — which is why `ps -p $$`
stays the final word.

## Trying another shell

Just run it. You get a child shell (01/01), and `exit` brings you back:

```bash
$ dash
$ echo $0
dash
$ [[ 1 == 1 ]]
dash: 2: [[: not found
$ exit
```

That error is the lesson. `[[` is a bash keyword; dash has no such thing, and reports it as a
missing command because that is genuinely what it looks like from dash's side.

> **Warning — do not run `chsh`.** Changing your *login* shell is a different act from trying one,
> and it takes effect the next time you log in, which is the worst moment to find out you have
> broken it. Try shells by running them. Chapter 11 covers login shells properly.

## The one-line summary of a shell

```bash
$ bash --version
GNU bash, version 5.2.21(1)-release (x86_64-pc-linux-gnu)
```

Most shells accept `--version`. `dash` does not — it has no such option, and says so. Not every
program supports the flags you expect, and that is itself worth knowing.

## Before you move on

- What `/bin/sh` actually is on Ubuntu, and why.
- What `/etc/shells` is for, and the two ways it can be wrong.
- The difference between `$SHELL`, `$0`, and `ps -p $$`, in trustworthiness order.
- What the leading dash in `-bash` means.
- Why a script that works with `bash` can fail with `sh`.
