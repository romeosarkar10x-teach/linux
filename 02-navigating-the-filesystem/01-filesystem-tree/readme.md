# 02/01 — One tree, no drives

> Eleven years of people putting things where they fit rather than where they belong. You are the
> first person in three weeks with a reason to know the difference.

If you came from Windows, the first thing to unlearn is drive letters. Linux has exactly one
filesystem tree. It starts at `/` — pronounced "root", written as a single slash — and everything
else hangs off it. A second disk, a USB stick, a network share, the container's `/labs` volume:
they do not become `D:`, they get **attached to a directory** somewhere in the one tree.

```
/
├── bin -> usr/bin
├── etc/
├── home/
│   └── cadet/
├── labs/          <- a separate disk, grafted on here
├── proc/          <- not a disk at all
└── var/
```

You will meet the specific directories in `03-the-fhs-tour`. This lesson is about *addressing* —
how you name a place in that tree, and how the shell turns the name you typed into the place you
meant.

## The working directory

Every process has a **current working directory**: one directory it considers "here". Your shell
has one, and it changes when you `cd`.

```bash
$ pwd
/home/cadet
```

`pwd` — print working directory. It is a builtin, and it is the answer to almost every "why did
that not work" question you will have this chapter.

The working directory is per-process, not global. Two terminals can sit in two different
directories, and a program you launch inherits the directory you launched it from — which is
Chapter 9's problem, but it explains a lot of Chapter 4's accidents.

## Absolute and relative

A path is a sequence of names separated by `/`. There are exactly two kinds.

| | Starts with | Resolved from | Example |
|---|---|---|---|
| **Absolute** | `/` | the root of the tree | `/var/log/station.log` |
| **Relative** | anything else | your working directory | `log/station.log` |

That is the entire rule. A leading slash means "start at root"; no leading slash means "start
here". `/etc` is one place forever. `etc` is a different place depending on where you are standing.

> The `/` between names is a **separator**, not part of a name. The `/` at the front is a
> different thing entirely — it is the name of the root directory. This is why `/` alone is a
> valid path and `etc/` and `etc` name the same directory.

## The two directories in every directory

Every directory contains two entries that are not files you made:

- `.` — this directory
- `..` — the parent directory

They are real entries, not shell tricks. `ls -a` will show them. `..` in the root directory points
at the root directory, so `cd /../../..` lands you at `/` and no error is raised.

This gives you relative paths that walk upward:

```bash
$ pwd
/home/cadet/notes
$ cat ../roster.txt        # /home/cadet/roster.txt
$ cd ../../                # /home
$ ls ./                    # same as: ls
```

`./` in front of a name has one job that matters a great deal: it makes the name a *path* rather
than a bare word. `./deck-report` runs the program in this directory; `deck-report` searches
`PATH` and probably fails. You met that in `01/03`.

## `~` — home

`~` is expanded by the **shell**, before the command ever sees it, into your home directory:

```bash
$ echo ~
/home/cadet
$ ls ~/notes
```

Variants worth knowing: `~cass` is cass's home directory, and `~-` is your previous directory
(see `02/02`). Because the expansion happens in the shell, quoting kills it: `ls "~"` looks for a
directory literally named `~` and fails. That is not a bug you will hit often, but it is a bug you
will hit once.

## Resolution, and where the surprises come from

Paths are resolved one component at a time, left to right. Each component must exist and must be a
directory (except the last). Two consequences:

- `//etc` and `/etc///` and `/etc/./` all name `/etc`. Repeated and trailing slashes collapse.
- A **trailing slash asserts "this is a directory"**. `cat notes.txt/` fails with `Not a
  directory`. This becomes important, and dangerous, when you meet `cp` and `mv` in Chapter 4.

The interesting case is symlinks. `/bin` on this station is a symlink to `usr/bin`. Watch:

```bash
$ cd /bin
$ pwd
/bin
$ pwd -P
/usr/bin
```

`pwd` reports the **logical** path — the one you walked, symlinks intact, remembered by the shell
in `$PWD`. `pwd -P` asks the kernel where you actually are: the **physical** path, every symlink
resolved. The shell maintains the fiction because you almost always want it; `..` from `/bin`
takes you to `/`, not to `/usr`, for the same reason.

When you want the truth about a path without moving:

```bash
$ realpath /bin/ls
/usr/bin/ls
```

## Naming pieces of a path

Two small tools that do exactly one thing each, and that scripts use constantly:

```bash
$ dirname /var/log/station.log
/var/log
$ basename /var/log/station.log
station.log
$ basename /var/log/station.log .log
station
```

They are pure string operations. Neither one touches the disk, and neither one cares whether the
path exists.

## Gotchas

> **`cd` with no argument goes home.** Not to `/`, not nowhere. `cd` alone is `cd ~`.

> **A failed `cd` leaves you where you were.** It does not half-move. Check `pwd` after any `cd`
> that printed an error, and build the habit of reading `cd`'s error rather than retyping faster.

> **`pwd` can lie about deleted directories.** If someone deletes the directory you are sitting
> in, your shell's `$PWD` still names it. `pwd -P` will fail. You are in a directory that has no
> name any more — a real state, and one you can produce on purpose.

## Before you move on

- One tree, rooted at `/`; other disks are attached to directories inside it.
- Absolute paths start with `/` and mean the same thing from anywhere; relative paths don't.
- `.` and `..` are real directory entries, and `..` from `/` is `/`.
- `~` is expanded by the shell, so quoting it prevents the expansion.
- `pwd` is logical (symlinks preserved), `pwd -P` and `realpath` are physical.
