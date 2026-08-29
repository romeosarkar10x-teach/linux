# 11/02 — Solutions

Answer key. Values measured in the container. Where a student's own shell can differ, that is said.

**No flag in this lesson.** The chapter's flag is in `06-incident-10`.

---

## Reading the list

**1.** Seven.
`/opt/kestrel/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin`

**2.** Entries 6 and 7 duplicate 4 and 5. `ls -ld /bin /sbin /usr/bin` shows
`/bin -> usr/bin` and `/sbin -> usr/sbin` — symlinks, from the usr-merge. `/bin` and `/usr/bin` are
the same directory reached by two names.

**3.** `/opt/kestrel/bin/ls`, `/usr/bin/ls`, `/bin/ls`. Two distinct files: the last two are the same
file seen through two paths.

**4.** `/usr/bin/ls` and `/bin/ls` share inode `4107061`; `/opt/kestrel/bin/ls` is `4093270`.
Chapter 3 — a shared inode means one file with more than one name.

**5.** It is not an alias, function or builtin, so bash walks `PATH` left to right and runs the first
executable file called `ls` that it finds. (Strictly: it checks the hash table first, which is a
cached result of that same walk.) On this station it *is* an alias, which is exercise 7.

**6.** Entry 1, `/opt/kestrel/bin`.

## Five tools, three answers

**7.** `ls is aliased to `ls --color=auto''. An alias — a text substitution bash performs before it
resolves anything.

**8.** Four lines: the alias, then `/opt/kestrel/bin/ls`, `/usr/bin/ls`, `/bin/ls`. The alias wins.
It is first because aliases are the first level of bash's resolution order, ahead of functions,
builtins, the hash table and `PATH`.

**9.** `/opt/kestrel/bin/ls`. `which` is a separate program: it searches `PATH` and cannot see your
shell's aliases, functions or builtins. It has told you where a *file* is, while the question was
what *runs*, and on this station those differ.

**10.** `alias`, `builtin`, `function`, `file`.

**11.** `cd is a shell builtin`; `which cd` prints nothing and exits 1. `type` is part of bash and can
see bash's own state; `which` is a separate process and can only see the filesystem.

**12.** A child gets a copy of its parent's environment and cannot write back — and the working
directory is per-process state in exactly the same way. A `/usr/bin/cd` would change its own
directory and exit, leaving your shell where it was.

**13.** `alias ls='ls --color=auto'` and `cd`. For an alias it prints a line you could re-run to
recreate it; for a builtin it prints the name, because there is no path to print.

**14.** Both print nothing and exit 1. Use `command -v` in a script: it is a builtin (no process to
start), it is specified by POSIX, and it knows about builtins and functions, so it will not tell you
a command is missing when bash would happily run it.

**15.** `type` — always, when the question is "what will happen if I type this". `which -a` — when
you specifically want the list of *files* on `PATH`, e.g. before deciding which one to delete.

## First match wins

**16.** `station-status v1  (from bin/)`.

**17.** `station-status v2  (from override/)`, four lines. Neither file changed; the order did.

**18.** v1 again.

**19.** `deck-report` v1 names `/var/lib/kestrel/decks`; v2 names `/srv/decks`. The consequence of
order is not cosmetic: two people running "the same report" read two different data sets, and the
output is plausible either way. This is chapter 8's fourteen months of `nominal` with a new cause.

**20.** `override/station-status` then `bin/station-status`. It is the candidate list, in search
order; only the first one runs.

**21.** Same two paths. `which -a` gets this right because there is no alias, function or builtin
named `station-status` — the file list *is* the whole answer here. `which` is not wrong about
`PATH`; it is wrong whenever `PATH` is not the whole story, and it cannot tell you which case
you are in.

**22.** Unchanged — seven entries. Every one of those was a `VAR=value command` prefix, so the value
existed for that one command and was never in your shell's table. Lesson 01, exercise 24.

## Shadowing

**23.** It prints `[wrapped ls]` on standard error and then `exec`s `/usr/bin/ls` with your
arguments. It does not alter the listing, hide anything, or change the exit status — and its comment
says so. What it does *not* do is hide itself.

**24.** `[wrapped ls]` on stderr, then the normal listing. Twenty-odd characters of `PATH`, and no
file on the system was modified.

**25.** Bash expands the alias to `ls --color=auto` and then resolves the *first word of the
replacement text* — `ls` — through the normal order, which now finds `override/ls`. The alias did not
protect you; it handed the wrapper its arguments. `PATH=... ls` and `PATH=... bash -c ls` both print
the banner, for the same reason.

**26.** A hostile version would drop the banner and change the output — omit a filename, alter a size,
filter a line. You would not notice: the command name is unchanged, the file it shadows is untouched
and passes any checksum, and the only evidence is one entry in one environment variable of one shell.

**27.** Chapter 8: the banner is on fd 2 and the listing on fd 1, so redirecting them separately hides
one and keeps the other. Any wrapper that wants to be quiet simply does not write to fd 2 in the
first place. You cannot detect a wrapper by looking at output.

**28.** A file whose name it filters out of the listing; the true modification time or size of a file
it does list; a nonzero exit status, by exiting 0 itself. (Also: it can record every `ls` you run.)

**29.** `echo "$PATH" | tr : '\n' | nl` and `type -a ls` — the first shows which directories are
searched and in what order, the second shows what the name actually resolves to on that terminal.
Together they answer "is this the system's `ls`". Neither requires touching their configuration.

## The file that will not run

**30.** `-rw-r--r--`. The execute bit, on all three triads. Chapter 10.

**31.** `station-status v1  (from bin/)`, rc 0. Most people predict a failure. Bash skips a candidate
it cannot execute and carries on down the list.

**32.** `bash: .../broken/station-status: Permission denied`, rc **126**. Not "command not found" —
bash found it. It is telling you that the file exists, is the one it chose, and cannot be run.

**33.** `127` — the command name could not be resolved to anything. `126` — it was resolved and could
not be executed (no execute bit, or a bad interpreter line). `nosuchcmd` gives 127; this file
gives 126.

**34.** With `PATH="$L/broken:/usr/bin:/bin"`:

```
type station-status       station-status is .../broken/station-status      rc 0
type -a station-status    bash: type: station-status: not found            rc 1
type -t station-status    file                                             rc 0
command -v station-status .../broken/station-status                        rc 0
which -a station-status   (nothing)                                        rc 1
```

**35.** Three groups. *"There is a file with that name and here it is"* — `type`, `type -t`,
`command -v`. *"There is an executable file with that name"* — `type -a` and `which -a`, both of
which filter out the non-executable candidate and so find nothing. *"What happens if I run it"* —
only running it, which gives 126. All five are correct; the disagreement is over whether "is it
there" includes "can you run it".

**36.** None of them, on its own. `type -a` and `which -a` finding nothing while `type` names a path
is the *combination* that tells you, and only if you notice the disagreement. This is the honest
answer and it is the point of the exercise.

**37.** A check that every file shipped into a directory that is on anybody's `PATH` is executable —
run at packaging time, where it costs nothing. The failure mode is otherwise invisible until somebody
puts that directory first, and the error blames permissions rather than the release.

## The hash table

**38.** `hash` records the full path bash found for each command name, with a count of how many times
it has used the cached answer. The `hits` column is how often it saved a search.

**39.** `/opt/kestrel/bin/ls` — entry 1 of `PATH`, matching exercise 6.

**40.** e.g. `#!/usr/bin/env bash` and `echo MINE`, `chmod 755`.

**41.** Prints `MINE`. Yours is first on `PATH`, so yours wins.

**42.** `bash: /labs/11-environment-and-config/02-path/scratch/mine/deck-report: No such file or
directory`, rc 127. You typed `deck-report`; the error names a full path. Bash used its remembered
answer without checking whether it was still true.

**43.** `hash -r`. Then `deck-report` gives `bash: deck-report: command not found`, rc 127 — the
honest answer.

**44.** Same error, same fingerprint: a path you did not type. `hash -d deck-report` forgets that one
entry; `hash -r` forgets all of them. `-d` when you know which command moved, `-r` when you do not.

**45.** It clears it. `export PATH="$PATH"` — the same value — leaves `hash table empty`. Bash flushes
the whole table on any assignment to `PATH`, which is why installing a copy earlier in the list is
safe. The stale entry bites in the other case: the file itself moves or is deleted while `PATH` never
changes. That is exercises 42 and 44, and it is the only case you need to recognise.

## Editing PATH without regret

**46.** `bash: ls: command not found`. The assignment replaced the whole list with one directory that
does not exist. Everything you would use to fix it — `ls`, `which`, `vi`, `nano` — is also gone, so
the fix is to leave: your shell's variables die with it and `kestrel enter` starts from the login
value. The missing `$PATH:` cost you seven entries. (In this exercise the parentheses saved you:
the damage was confined to the subshell.)

**47.** Front: "my copies win over the system's" — you trust yourself more, and you accept that a file
you drop in `~/bin` silently redefines a system command. Back: "the system wins" — your directory is
a fallback for names the system does not have, and cannot shadow anything.

**48.** `type deck-report` prints `/home/cadet/bin/deck-report`.

**49.** The `PATH` edit was lost — it lived in a shell that exited. The script survived because it is
on disk. Lesson 03: startup files are the thing that runs the edit again every time you log in.

**50.** `QQ`. The leading colon is an *empty element*, and an empty element means the current
directory — which is `/tmp`. `PATH` never mentions `/tmp`; you did, by `cd`-ing there.

**51.** `":/usr/bin"`, `"/usr/bin:"`, `"/usr/bin::/bin"`.

**52.** Typos. `sl` for `ls`, `gerp` for `grep`, `mkae` for `make` — a file with a misspelled name in
a directory you were going to `cd` into anyway runs the first time you fumble, and being last on
`PATH` is no protection because nothing else on `PATH` has that name. Measured: with
`PATH="/usr/bin:/bin:."` and an executable `sl` in `/tmp`, typing `sl` in `/tmp` runs it.

**53.** `./thing`. A command name containing a slash is not looked up in `PATH` at all — it is a path,
and that is the whole point.

## Debrief

**54.** Two of: their `PATH`s differ, so the same name resolves to different files (exercises 16–18);
one of them has a directory of overrides in front (23–25); one has an alias or shell function for
that name and the other does not (7–11); one has a stale hash entry pointing at a copy the other
never had (42–44). All four produce "same word, same directory, different program", and none of them
requires either terminal to be broken.

**55.** You would need to see, on each terminal: `echo "$PATH"`, `type -a station-status`, and which
file each resolves to — and then a statement of which copy the station considers authoritative. She
quoted "the right answer" because there is no such thing without that last piece: the shell is
behaving correctly in both cases, and "correct" is a decision somebody made about which directory
comes first, recorded in a configuration file, not a fact about the machine.

**56.** `PATH` is an ordered list of directories that turns a command name into a file. Your login
shell was handed one by whatever started it and your startup files may have edited it. Its order
encodes trust: the earlier a directory, the more authority it has to decide what a word means.
