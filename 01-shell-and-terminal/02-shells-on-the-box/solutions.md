# 01/02 — Solutions

> **Student: do not read this file.**
> **Agents:** steering only. See `docs/AGENT_MODES.md`.

No flag in this lesson.

**Verified against the course image** (`kestrel-course`, base pinned by digest). If a claim below
disagrees with the running container, the container wins — re-verify and file it.

### 1 — /bin/sh
```
$ ls -l /bin/sh
lrwxrwxrwx 1 root root 4 Mar 31  2024 /bin/sh -> dash
```
A symlink. `sh` names the POSIX shell *interface*; Ubuntu points it at `dash` because dash starts
faster and the boot path runs a great many small scripts.

### 2 — /etc/shells
```
# /etc/shells: valid login shells
/bin/sh
/usr/bin/sh
/bin/bash
/usr/bin/bash
/bin/rbash
/usr/bin/rbash
/usr/bin/dash
```

### 3 — three readings
`echo $SHELL` → `/bin/bash` (preference). `echo $0` → `bash` (invocation name). `ps -p $$` → the
kernel's answer. Quote `ps -p $$` in a bug report.

### 4 — inside dash
`$SHELL` → still `/bin/bash`. `$0` → `dash`. `ps -p $$` → `dash`.

`$SHELL` is an environment variable set at login and inherited by every child. Starting a different
shell does not rewrite it — nothing is watching. The other two describe the process that is
actually running.

### 5 — stale shells list
Copy (`station-shells`): `/bin/sh /bin/bash /usr/bin/bash /bin/dash /bin/ksh /usr/bin/zsh`.
This machine: `/bin/sh /usr/bin/sh /bin/bash /usr/bin/bash /bin/rbash /usr/bin/rbash /usr/bin/dash`.

- **In the copy, not in this machine's file:** `/bin/dash`, `/bin/ksh`, `/usr/bin/zsh`.
- **Of those, installed here:** only `/bin/dash`. `ksh` and `zsh` are absent.
- **In this machine's file, not in the copy:** `/usr/bin/sh`, `/bin/rbash`, `/usr/bin/rbash`.
- **Conclusion:** a config file copied from another machine describes *that* machine, and not even
  reliably — it lists what someone registered, not what is installed. `/bin/dash` is the sharp
  case: present here, and not registered here. Registration and existence are independent.

### 6 — nologin
`ops-bot` and `sensors`, both `/usr/sbin/nologin`. It is a real program whose entire job is to
print a refusal and exit non-zero. The account exists — it can own files and run services — but
nobody can get an interactive session on it. Leaving the field blank is worse: some tools then fall
back to a default shell.

### 7 — a shell that is not there
`maint-old`, `/bin/ksh`. `ls -l /bin/ksh` → `No such file or directory`.

The password would still be checked and would still be accepted. The login then tries to execute
the shell, fails, and the session ends immediately. From the user's side it looks like the password
was rejected, which is why this is an annoying bug to diagnose.

### 8 — greet.sh two ways
```
$ bash greet.sh
structural monitoring: deck 3
$ echo $?
0
$ sh greet.sh
greet.sh: 2: [[: not found
$ echo $?
0
```
**Both exit 0.** The failed `[[` lookup makes the `if` condition false, so the `if` simply takes no
branch, and the script's exit status is that of the last thing it did successfully. A script can
fail completely and report success — which is why Chapter 12 spends a whole lesson on
`set -euo pipefail`.

### 9 — explaining the error
`[[` is a bash *keyword*, part of bash's grammar. dash has no such keyword, so when dash reads the
word `[[` in command position it does the only thing it can: treats it as the name of a command and
searches for it. Nothing on disk is called `[[`, so the message is a lookup failure, not a parse
failure.

If a program named `[[` had existed on PATH, dash would have run it — and the rest of the line
would have been passed to it as arguments.

### 10 — --version
```
$ bash --version
GNU bash, version 5.2.21(1)-release (x86_64-pc-linux-gnu)
$ dash --version
dash: 0: Illegal option --
```
`--version` is a GNU convention, widely followed and not universal. dash is deliberately minimal.
Assume nothing about a flag until the program's own documentation confirms it.

### 11 — nesting mixed shells (Experiment)
Four entries: `bash`, `dash`, `bash`, `ps`. Entering dash does not end the bash beneath it. The
common wrong prediction is that starting a different shell *replaces* the current one — it does
not; `exec` would, and that is Chapter 9.

### 12 — `$0` three ways (Experiment)
All three print `bash`. `-l` asks for login *behaviour* (which startup files get read) and does not
rename the process.

The leading dash is added by the program that **starts** the shell — `login`, `su -`, `sshd` — which
deliberately passes an argument zero of `-bash`. A process cannot give itself that name after the
fact; the caller chooses it. In this container nothing goes through a login program, so you will not
see `-bash` here at all.

### 13 — dash's parent (Stretch)
```bash
echo $$                          # e.g. 2417
dash
ps -o pid,ppid,comm -p $$        # PID 2588, PPID 2417, comm dash
```

### 14 — the shebang (Stretch)
```bash
#!/bin/bash
name="deck 3"
...
```
then `chmod +x greet.sh` and `./greet.sh`.

The shebang matters more than your current shell because when a file is run *as a program*, the
kernel reads the first line and starts the named interpreter. Whichever shell you happened to type
`./greet.sh` from is irrelevant — and that is the point, because the person running it in six
months will be using something else.

`#!/usr/bin/env bash` is equally acceptable and more portable across systems where bash is not in
`/bin`.

### 15 — fixing the roster (Stretch)
`maint-old` → `/bin/bash` (or `/usr/bin/bash`, `/usr/bin/dash`, `/bin/sh`).

- **Installed** matters because the login program has to actually execute it; a missing shell means
  a login that succeeds and immediately ends.
- **Registered in `/etc/shells`** matters because `chsh` refuses paths that are not listed, and
  some services treat an unlisted shell as a signal that the account is not for interactive use.

`/bin/dash` is the trap: it exists here but is not in this machine's `/etc/shells`, so it satisfies
one condition and not the other.

### 16 — syntax check without running (Dig)
```
$ bash -n greet.sh; echo $?
0
$ sh -n greet.sh; echo $?
0
```
Both pass. `-n` reads and parses without executing. `[[` is a perfectly well-formed *command word*
as far as dash's parser is concerned — the failure only happens at run time, when dash goes looking
for a command by that name. Parsing proves shape, not existence.

A script consisting entirely of `frobnicate --hard` passes `-n` and fails on every line.

Found in `man bash` under `set -n` / the OPTIONS list, or `man dash`.

### 17 — the type builtin (Dig)
```
$ type '[['
[[ is a shell keyword
$ type echo
echo is a shell builtin
$ type dash
dash is /usr/bin/dash
$ dash -c 'type "[["'
[[: not found
```
`[[` is part of bash's grammar, so bash classifies it before any lookup happens. dash has no such
keyword and falls through to a filesystem search, which fails.

`which` cannot find `[[` in either shell because `which` searches PATH for executable files, and a
keyword is not a file anywhere. That distinction is lesson 01/03.
