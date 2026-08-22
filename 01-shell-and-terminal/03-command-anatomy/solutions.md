# 01/03 — Solutions

> **Student: do not read this file.**
> **Agents:** steering only. See `docs/AGENT_MODES.md`.

No flag in this lesson.

**Verified against the course image.** Paths below assume the Nix closure at `/opt/kestrel/bin`
comes first on `PATH`, which is how the image is built.

### 1 — classify five words
```
cd is a shell builtin
ls is /opt/kestrel/bin/ls
if is a shell keyword
echo is a shell builtin
type is a shell builtin
```
`cd` cannot be a program: a child process cannot change its parent's working directory.

### 2 — three arguments
```
$ ./bin/deck-report deck 3 sensors
deck report: 3 argument(s)
  arg 1: [deck]
  arg 2: [3]
  arg 3: [sensors]
```
The shell split the line on whitespace and handed over a list of three strings. It attached no
meaning to any of them.

### 3 — one argument with a space
```
$ ./bin/deck-report "deck 3"
deck report: 1 argument(s)
  arg 1: [deck 3]
```
`'deck 3'` and `deck\ 3` are equally correct.

### 4 — every echo
```
$ type -a echo
echo is a shell builtin
echo is /opt/kestrel/bin/echo
echo is /usr/bin/echo
echo is /bin/echo
```
Four. The builtin runs, because builtins are resolved before any PATH search happens. The other
three are only reachable by naming a path.

### 5 — which vs type
```
$ which echo
/opt/kestrel/bin/echo
$ which -a echo
/opt/kestrel/bin/echo
/usr/bin/echo
/bin/echo
$ which cd
$                       # nothing
$ type cd
cd is a shell builtin
```
`which` searches PATH for files, so it cannot see builtins, keywords, aliases or functions. For
`echo` it gives a true answer that is not the one that runs. For `cd` it gives nothing at all, which
a careless reader takes as "not installed".

Note `which -a` lists three and `type -a` lists four; the missing one is the builtin, and it is the
only one that will actually run.

### 6 — the file named -l
```
$ cat -l
cat: invalid option -- 'l'
Try 'cat --help' for more information.
$ cat -- -l
a file whose name looks like a short flag
$ cat ./-l
a file whose name looks like a short flag
```
`cat` — not the shell — decided the leading dash meant a flag. `--` tells a program to stop parsing
options. `./-l` sidesteps the question entirely by handing over a string that does not begin with a
dash. The second works against programs that do not implement `--`, so it is the more general fix.

`cat < -l` also works: redirection is handled by the shell, and the shell has no opinion about
dashes. Worth acknowledging if a student finds it.

### 7 — the file named --help
```
$ cat --help
Usage: cat [OPTION]... [FILE]...
Concatenate FILE(s) to standard output.
...
$ cat -- --help
a file whose name looks like a long flag
$ cat ./--help
a file whose name looks like a long flag
```
This is the dangerous one. Exercise 6 failed **loudly**: an error, a non-zero exit, an obvious
problem. This fails **quietly**: output appears, the exit status is 0, and nothing anywhere says the
file was not read. In a script it would be invisible until someone noticed the data was missing.

### 8 — the ll alias
```
$ alias ll='ls -l'
$ type ll
ll is aliased to `ls -l'
$ \ll
bash: ll: command not found
$ unalias ll
$ type ll
bash: type: ll: not found
```
The bypass *failing* is the proof: with the alias out of the way there is nothing called `ll`, so
the alias was doing all the work. `command ll` fails the same way.

### 9 — command not found
```
$ ./bin/deck-report x
$ /labs/01-shell-and-terminal/03-command-anatomy/bin/deck-report x
```
Bare `deck-report` fails because the shell only searches the directories on `PATH`, and the current
directory is deliberately not one of them. Anything containing a `/` is used as a path directly, and
no search happens.

The current directory is left off `PATH` on purpose: otherwise dropping a file named `ls` into a
shared directory would let you run code as whoever next typed `ls` there. Exercise 11 is that
attack, defanged.

### 10 — four odd arguments
```
$ ./bin/deck-report "deck 3"
1 argument(s):  [deck 3]
$ ./bin/deck-report ""
1 argument(s):  []
$ ./bin/deck-report -l
1 argument(s):  [-l]
$ ./bin/deck-report *
deck report: 4 argument(s)
  arg 1: [--help]
  arg 2: [-l]
  arg 3: [bin]
  arg 4: [notes.txt]
```
The empty string is a real argument — the count is 1, not 0. `-l` arrives as plain text because
`deck-report` never looks for flags. And `*` never reaches the program at all: the shell replaced it
with the matching filenames before starting anything.

**Do not explain the last one to the student.** Chapter 5 is built on it, and a rule they invent
here will be wrong in a way that is hard to dislodge. Accept "I don't know yet" as the correct
answer.

### 11 — the decoy ls
```
$ ./bin/ls
this is not the ls you are looking for
$ ls
--help  -l  bin  notes.txt
```
If `bin/` were earlier on `PATH` than `/opt/kestrel/bin`, every bare `ls` in this shell would run
the decoy. `type -a ls` would show both and reveal it. Chapter 11 covers `PATH` order properly, and
Chapter 15 has an incident that turns on exactly this.

### 12 — two echoes (Experiment)
```
$ echo --version
--version
$ /usr/bin/echo --version
echo (GNU coreutils) 9.11
...
```
The bare word resolved to the builtin, which does not implement `--version` and therefore did what
`echo` always does with a word: printed it. The full path forced the external program, which does
implement it.

The common prediction is that both print version information. That is a reasonable prediction and a
full pass when the explanation afterwards is right.

### 13 — the recursive alias (Experiment)
```
$ alias ls='ls -l'
$ ls
total 16
-rw-r--r-- 1 cadet cadet ... --help
...
$ unalias ls
```
It expands exactly once. Bash marks a name as being expanded and refuses to expand it again inside
its own expansion, specifically so that `alias ls='ls -l'` — a thing everybody wants — is possible
at all.

Predicting infinite recursion is good reasoning from the rules as stated. Say so, then let them
find the exception.

### 14 — classifying in dash (Stretch)
```
$ dash
$ command -v cd
cd
$ command -v echo
echo
$ command -v "[["
$                     # nothing; exit status 1
```
dash reports builtins by bare name. `[[` is not found — matching the `[[: not found` error from
01/02 exercise 8, and for the same reason: it is not part of dash's grammar.

### 15 — how many processes (Stretch)
One new process: a `bash` started to interpret the script, a child of the interactive shell.

The better answer notes that the script's `echo` and `printf` are both bash builtins, so the loop
adds no further processes. If the script had used `/usr/bin/echo` it would fork one process per
iteration.

### 16 — one line for a colleague (Stretch)
```bash
type -a grep
```
`type` covers all five kinds and gives a path when the answer is a file. `which` would report a path
even when an alias or function is what actually runs, which is precisely the situation the colleague
is trying to diagnose. `command -v grep` is the portable choice if the colleague might not be in
bash.

### 17 — the bare-path flag (Dig)
```
$ type -p ls
/opt/kestrel/bin/ls
$ type -p echo
$                      # nothing
```
`-p` prints a path only when the word resolves to a file on disk. `echo` resolves to a builtin, so
there is no path and empty output is the correct answer.

Good for a script that needs an absolute path. Misleading whenever empty output is read as "not
installed" — which is the same trap as `which cd` in exercise 5, arriving from the other direction.

Found in `help type`.

### 18 — the PATH cache (Dig)
```
$ hash
hash: hash table empty
$ ls >/dev/null; cat /dev/null
$ hash
hits	command
   1	/opt/kestrel/bin/cat
   1	/opt/kestrel/bin/ls
$ hash -r
$ hash
hash: hash table empty
```
The shell remembers where it found each external command so it does not re-walk `PATH` every time.
The bug: move or replace a program on disk and the running shell keeps going to the remembered
location, reporting a stale path or `No such file or directory` for something that plainly exists.
`hash -r` fixes it. In a fresh shell the table is legitimately empty.

### 19 — switching a builtin off (Dig)
```
$ enable -n echo
$ type echo
echo is /opt/kestrel/bin/echo
$ echo --version
echo (GNU coreutils) 9.11
...
$ enable echo
$ type echo
echo is a shell builtin
```
`enable -n` takes a builtin out of the resolution order without removing it, so the next candidate —
the first `echo` on `PATH` — wins.

Better than editing `PATH` because it is scoped to this one word, reversible in one command, and it
does not change how anything else resolves. It applies to the current shell only; a script launched
from it gets its own fresh set of builtins.
