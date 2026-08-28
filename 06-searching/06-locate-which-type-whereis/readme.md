# 06/06 — `locate`, `which`, `type`, `whereis`

> Two questions that look like one. "Where is that file?" and "what will run if I type this name?"
> The tools people reach for answer neither reliably, and one of them lies to you every day.

## An index is not a search

`find` walks. Every answer it gives is about the filesystem as it is at the moment you asked, and
the cost is proportional to the size of the tree.

`locate` does not walk anything. It reads a **database** that something built earlier, and it
answers in milliseconds regardless of how big the filesystem is. On this station that database was
built when the container image was made, which is why:

```
locate strain
/sys/module/acpi_x86/parameters/check_lps0_constraints
```

One hit, and not one you wanted. There are dozens of files with `strain` in the name under `/labs`,
and the index has never heard of any of them, because `/labs` was an empty mount point when the
index was built. `sudo updatedb` rebuilds it, and the same command then returns 51 paths.

That is the entire lesson about `locate`, and it cuts both ways:

- A file created since the last `updatedb` is **invisible**. `locate` says nothing and exits 0,
  which is indistinguishable from "it does not exist".
- A file deleted since the last `updatedb` is **still listed**. `locate` prints a path that is not
  there any more, and only `-e` (check existence before printing) filters those out.

So `locate` answers a question about the past, quickly. Use it to find something you know is old —
a config file, a man page, a package's data directory — and never to establish that something is
absent.

Two more things about the matching. `locate` matches a **substring of the whole path**, not a
filename and not a glob: that `check_lps0_constraints` hit contains the letters `strain` inside
`constraints`. And the pattern is anchored nowhere, so `locate log` matches half the disk. `-b`
restricts the match to the base name, `-r` takes a regex, `-i` ignores case, `-c` counts, `-l N`
limits, and `-0` gives NUL-separated output for the same reason `find -print0` does.

The database lives at `/var/cache/locatedb` here, is owned `root:plocate`, and holds 74838 paths.
`updatedb` as an ordinary user fails with `/var/cache/: Permission denied` and exit status 1 —
building the index is a root job, because the index contains paths from directories you cannot read.

## "What will run if I type this?"

That is a different question, and it has more than one kind of answer, because a name in bash can
resolve to five things. In the order bash checks them:

1. an **alias**
2. a **keyword** (`if`, `for`, `while` — part of the grammar, not a command at all)
3. a **function**
4. a **builtin** (`cd`, `echo`, `type` — code inside bash, no file involved)
5. a **file** found by walking `PATH` left to right

Only the fifth is a file. That is why the tool everyone reaches for gets it wrong.

## `which` is a program, and that is the problem

`/usr/bin/which` is a separate executable. It runs in its own process, it can see your `PATH`
because that is exported, and it can see **nothing else about your shell**, because aliases,
functions and builtins do not exist outside the shell that holds them.

So in this lab, with `tools/` first on `PATH`:

```
which echo
/labs/…/tools/echo          # a file, sitting on PATH
echo hello
hello                        # the builtin ran; tools/echo never executed
```

`which` gave you a real path to a real executable and it is not what runs. It also returns nothing
for `cd` (a builtin, so `which` reports failure, status 1), nothing useful for an alias, and the
*file* path for a name you have shadowed with a shell function — confidently, status 0.

`which -a` lists every match on `PATH` rather than the first, which is genuinely useful for finding
the older copy shadowing the newer one. That is about the only thing it does that the shell's own
tools do not.

## `type` and `command -v` are builtins, and they know

`type NAME` asks the shell the question the shell is actually going to answer:

```
type echo            → echo is a shell builtin
type if              → if is a shell keyword
type -t deck-scan    → function
type -a echo         → the builtin, then every file on PATH, in order
type -P echo         → only the file, skipping the builtin
```

`command -v NAME` gives one machine-readable line — a path for a file, the bare name for a builtin
or keyword, the full `alias …='…'` text for an alias — and exits 1 for a name that does not resolve.
That exit status is what you want in a script: `command -v jq >/dev/null || die "jq required"`.
`command -V` is the wordy version, and is the same thing `type` prints.

Rule of thumb: `command -v` in scripts, `type -a` when you are debugging, `which` when you are on a
machine whose shell you do not control and cannot do better. Do not build habits on `which`.

## `whereis` answers a third question

`whereis` does not care about your `PATH` or your shell. It looks in a **compiled-in list of standard
directories** — `/usr/bin`, `/usr/lib`, `/usr/share/man`, and so on (`whereis -l` prints the list) —
for a binary, its manual, and its source, and prints all three:

```
whereis grep
grep: /usr/bin/grep /nix/store/…/bin/grep /usr/share/man/man1/grep.1.gz /usr/share/info/grep.info.gz
```

That is the right tool for "where does this package keep its stuff", and the wrong tool for "what
will run". Note also that `whereis nosuchcmd` prints `nosuchcmd:` and exits **0** — no match is not
an error, which makes it useless in a conditional.

## `hash`, briefly

Once bash has found a command on `PATH` it remembers the path in a hash table and does not search
again. `hash` with no arguments prints what is cached, with a hit count, and `type` says so
explicitly: `strain-report is hashed (/labs/…/tools-b/strain-report)`.

Assigning to `PATH` clears the table, so the obvious trap — prepend a directory, get the old binary
— does **not** happen in bash. The one that does: drop a new executable into a directory that is
*already* earlier on `PATH` than the one currently cached. `PATH` did not change, the table was
never invalidated, and the old path keeps running until `hash -r`. That is the version of "it is
still running the old one" that is genuinely confusing, and `type` will show you the stale entry.

## The shape of the lab

`tools/` and `tools-b/` both hold a `strain-report`; you will put both on `PATH` and see which wins.
`tools/` also holds an `echo` and a `test` (names that collide with builtins) and a `panel-check`
with **no execute bit**. `tools-b/` holds a `bay-audit` that exists nowhere else. `archive/` has
log files for the `locate` half. `notes/` has a handover worth reading first, and a `paths.txt`
telling you exactly how to set `PATH` for this lesson without editing anything permanent.

## Rules of engagement

Set `PATH` with `export` in your interactive shell only. Do not edit `~/.bashrc` — Chapter 8 does
that, and doing it early will make these exercises give the wrong answers in every later shell.
`exec bash -l` puts your `PATH` back. `sudo updatedb` is expected and safe; it takes a second or two.

## What "solved" looks like

You can say why `which echo` and `echo` disagree, and name all five things a command name can
resolve to. You can find the shadowed copy of a script with two different tools. You can state the
two opposite ways `locate` lies and which flag fixes one of them. And you reach for `command -v` in
a script without thinking about it.

## Before you move on

Next is the incident. Overnight logs that "look fine", a run log that numbers its own entries, and
everything from this chapter on the table.
