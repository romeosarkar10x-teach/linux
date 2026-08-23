# 02/02 — `ls` shows you what you asked for

> `ls` shows you what it has been asked to show you. That is a much narrower claim than it sounds,
> and this chapter ends with a directory that proves it.

You have run `ls` a thousand times. This lesson is about the gap between "what is in this
directory" and "what `ls` printed", because that gap is where things hide — accidentally, and
otherwise.

## `cd`, properly

Three forms beyond the obvious:

```bash
cd            # home
cd -          # the directory you were in before this one
cd ~cass      # cass's home directory
```

`cd -` is not history. It is one variable, `OLDPWD`, holding exactly one previous directory, and
`cd -` swaps `PWD` and `OLDPWD`. So `cd -` twice puts you back where you started, and there is no
"two directories ago". It also **prints** the directory it moved to, which no other form of `cd`
does — worth knowing before it confuses you inside a script.

`~-` expands to the same thing without moving: `ls ~-` lists the previous directory.

> `cd` with a path that is not a directory fails, and a failed `cd` leaves you where you were. If
> you chain `cd somewhere && rm -rf ./*`, the `&&` is what saves you. Chapter 4 will make you care
> about this one.

## What `ls` hides by default

Two things, and they are different kinds of hiding.

**Dotfiles.** A file whose name begins with `.` is omitted from `ls` output. That is the entire
mechanism — there is no hidden bit, no attribute, no flag on the file. The name starts with a dot,
so `ls` skips it. Any program that does not implement that convention sees the file normally.

```bash
ls        # what you usually get
ls -a     # everything, including . and ..
ls -A     # everything except . and ..
```

`-A` is the one you almost always want. `.` and `..` are in every directory and tell you nothing.

**Directory contents.** By default, when you name a directory, `ls` lists *what is inside it*. To
see the directory itself as an entry:

```bash
ls -d logs        # logs
ls -ld logs       # drwxr-xr-x ... logs
```

`-d` is the difference between "tell me about this thing" and "tell me about its contents", and
you will reach for `-ld` constantly once you start caring about permissions in Chapter 10.

## The long format, field by field

```
-rw-r--r--  1  cadet  crew   24000  Jun 14  2187  strain-2187-06-12.log
     │      │    │      │      │         │              │
     │      │    │      │      │         │              └── name
     │      │    │      │      │         └── modification time
     │      │    │      │      └── size in bytes
     │      │    │      └── group
     │      │    └── owner
     │      └── link count
     └── type + permissions
```

The first character is the file **type** — `-` regular, `d` directory, `l` symlink, and four more
you meet in Chapter 3. The nine after it are permissions (Chapter 10).

Two things about that time column that surprise people:

- It is the **modification** time, not creation. Chapter 3 has all three timestamps.
- If the time is more than six months from now — in either direction — `ls` prints the **year**
  instead of the clock time. That is why some lines say `Jun 14 2187` and others say `Jun 14
  09:15`. The format changes, silently, based on age.

`-h` makes sizes human-readable (`879K` instead of `900000`). It only affects sizes; the
`total` line becomes human-readable too.

## Sorting

`ls` sorts by name by default, and the sort is by **byte value in your locale**, not by dictionary
convention. This container runs in the `C.UTF-8` locale, where every uppercase letter sorts before
every lowercase one:

```bash
$ ls
Archive
archive
current
```

That is not `ls` being clever. It is `A` (0x41) sorting before `a` (0x61). On a desktop Linux with
an `en_US.UTF-8` locale you would very likely see them adjacent instead, because that locale's
collation ignores case at the first pass. **Sort order is a property of the locale, not of `ls`.**

| Flag | Sorts by |
|---|---|
| *(none)* | name |
| `-t` | modification time, newest first |
| `-S` | size, largest first |
| `-X` | extension |
| `-v` | "version" — numbers inside names compared numerically |
| `-r` | reverses whichever of the above is in effect |
| `-U` | nothing — directory order, as stored |

`-r` composes: `ls -ltr` is long format, time-sorted, oldest last-to-first — the single most
useful `ls` invocation there is, because the thing that just changed ends up next to your prompt.

## Recursion, and one column

```bash
ls -R        # descend into every subdirectory, printing a header per directory
ls -1        # one entry per line, no columns
```

You met `-1`'s behaviour in `01/01` without asking for it: `ls` produces columns **only when its
output is a terminal**. In a pipe it is already one-per-line. `-1` forces that behaviour when
output *is* a terminal.

`-R` prints an empty header for empty directories, which is how you tell "empty" from "not
descended into".

## `-F`, and why colour might not work

`-F` appends a character indicating the type: `/` directory, `@` symlink, `*` executable, `|`
FIFO. It is colour for people whose terminal has no colour — and unlike colour, it survives being
piped into a file.

Colour comes from `--color=auto`, which is what the `ls` alias in your shell already does. But
colour is driven by the `LS_COLORS` variable, and **in this container that variable is empty**, so
`--color` produces no colour at all. That is not a bug in `ls`; it is a missing database. One of
this lesson's Dig exercises is to find out what populates it and turn it on.

> Because `ls` is aliased to `ls --color=auto` in interactive shells, `ls` and `\ls` are not the
> same command here. `01/03` told you how to check; this is where it starts to matter.

## Gotchas

> **`ls` on multiple arguments groups them.** Files first, then a labelled block per directory.
> With one directory argument there is no label; with two, there suddenly is. Scripts that parse
> `ls` output break on exactly this.

> **Never parse `ls` output in a script.** Filenames can contain spaces and newlines, and `ls`
> mangles unprintable characters by default when writing to a terminal. Chapter 5 and Chapter 6
> give you the right tools. `ls` is for humans.

## Before you move on

- Dotfiles are hidden by a naming convention, not by a file attribute.
- `-d` asks about the directory itself; without it you get its contents.
- `-t`, `-S`, `-X`, `-v` choose the sort key; `-r` reverses whatever is chosen.
- `ls -l`'s time column silently switches to a year for anything over six months away.
- Sort order comes from the locale; colour comes from `LS_COLORS`, which can be empty.
