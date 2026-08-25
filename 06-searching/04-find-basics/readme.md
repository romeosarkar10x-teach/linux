# 06/04 — `find`: Walking the Tree

> `grep` answers "which lines". `find` answers "which files". Everything in this lesson is about the
> second question, and about the fact that `find` is not a search tool — it is a walk with a filter
> bolted on.

## What `find` actually is

`find` takes a list of starting paths, walks every file under them, and evaluates an **expression**
against each one. If the expression is true, it acts. The default action is `-print`, which is why

```
find . -name '*.log'
```

and

```
find . -name '*.log' -print
```

produce byte-identical output. There is no index, no cache, and no shortcut: `find` opens every
directory it is pointed at. On a small tree that is instant. On a filesystem it is not, and Chapter
6's last lesson is about the tool that trades freshness for speed.

The order of arguments is fixed and unforgiving: **paths first, expression second**. `find -name
'*.txt'` works because the path defaults to `.`; `find -name '*.txt' .` does not.

## `-name` matches one component, with glob syntax

`-name` compares its pattern against the file's **base name** — the last component of the path, with
no slashes in it. So `-name '*/deck-03/*'` matches nothing, ever: no base name contains a slash.

The pattern is a **glob**, not a regex. `*`, `?` and `[...]` mean what they mean to the shell, `.` is
an ordinary dot, and `*.log` does not match `panel-03.log~`, because the tilde is a character and the
pattern ends at `g`. Two things follow: an editor backup is not a log by this test, and neither is
`strain-02.LOG`, because `-name` is case-sensitive. `-iname` fixes the second; nothing fixes the
first except deciding what you meant.

And unlike the shell, `-name '*'` **does** match dotfiles. `find` never had a `dotglob` problem;
it sees `.hidden-notes` like anything else.

## The quoting trap

This is the most common `find` bug in existence, and it is silent about half the time:

```
find . -name *.log
```

The shell expands `*.log` **in your current directory** before `find` runs. If there is nothing
matching there, the glob is left alone and the command works by accident. If there is exactly one
match, `find` searches the whole tree for that one name and you get a plausible, wrong answer with no
error. If there are two or more, you get:

```
find: paths must precede expression: ‘panel-09.log’
find: possible unquoted pattern after predicate ‘-name’?
```

The error is the lucky case. Quote the pattern. Always.

## `-type`

`-type f` regular file, `-d` directory, `-l` symlink; also `b c p s` for the device and socket types
from Chapter 3. This is how you separate a *file* called `readings` from a *directory* called
`readings`, and it is worth reaching for by reflex: an unfiltered `find . -name x` will hand you both
and your next command will not expect it.

Symlinks are their own type. `find` does not follow them by default, so a symlink to a directory is
one entry, not a subtree, and a **broken** symlink is still `-type l` — it exists as a name. `find
-L` follows links instead, which turns the broken one into an error and the directory link into a
walk. `-xtype l` is the trick for "a link whose target is missing".

## Depth

`-maxdepth n` stops descending past *n* levels below each starting path; `-mindepth n` suppresses
everything shallower. `-maxdepth 1` is "this directory only" and `-maxdepth 0` is "the starting paths
themselves and nothing else" — the way to run a test against exactly the arguments you gave.

These are **global options**: they apply to the whole command no matter where you write them. Older
`find` warned you when you put `-maxdepth` after a test; findutils 4.11 does not warn at all, and the
result is the same either way. Write them first regardless — the habit is what saves you when you
move on to `-prune` and `-depth`, where position genuinely changes the answer.

## `-path`, and combining tests

`-path` matches the whole path as `find` prints it, slashes and all, so `-path '*/bay-01/*'` is how
you say "somewhere under a directory named bay-01". The pattern is still a glob, and `*` in `-path`
happily crosses slashes.

Tests written next to each other are **and**ed. `-o` is or, `!` is not, and `\( \)` groups. `-a`
binds tighter than `-o`, exactly like `&&` and `||`, which is where this bites:

```
find . -name '*.log' -o -name '*.txt' -type f     # 19 here
find . \( -name '*.log' -o -name '*.txt' \) -type f  # 17 here
```

The first reads "(is a .log) or (is a .txt and is a regular file)" and lets two symlinks through.
Group anything with an `-o` in it.

## The shape of the lab

`decks/` is three levels deep with mixed-case names, a `.LOG`, an editor backup, a file and a
directory both called `readings`, a name with spaces and a name starting with a dash. `archive/` has
two same-named logs at the same depth. `links/` has a link to a file, a link to a directory, and a
broken one. `reports/` holds two notes worth reading before you start. `scratch/` contains exactly
one `.log`, which is there to make the quoting trap fire.

## What "solved" looks like

You can say what `-name` compares against and why it can never contain a slash. You have made the
unquoted-glob bug fire in all three of its forms, including the silent one. You can separate a file
from a directory of the same name, count only real files under a subtree, and say what `-maxdepth 1`
means without guessing.

## Before you move on

The next lesson is where `find` becomes dangerous and useful at the same time: matching on size,
time and permission, and running a command on every hit. The chapter's incident is solved with it.
