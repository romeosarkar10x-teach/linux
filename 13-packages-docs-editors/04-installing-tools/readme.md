# 13/04 — Getting a tool you do not have

You have been working with what the station shipped with. This lesson is about
the moment you need something it did not ship with — and about the fact that
there is more than one way to get it, only one of which anything keeps track of.

## Three routes, in order of preference

**One: it is in the archive.** `apt search`, `apt show`, `sudo apt install`.
This is the route to take whenever it is available. The package is recorded,
upgraded when the archive updates, removable in one command, and its files are
attributable with `dpkg -S`.

**Two: it is a `.deb` from somewhere else.** `sudo apt install ./thing.deb` —
lesson 02. Still tracked by dpkg, still visible to `dpkg -l`, but nothing will
ever upgrade it, because no repository offers it.

**Three: it is a tarball.** Extract it and copy the tree into a prefix. Nothing
records this. `dpkg -S` will not attribute the files. `apt` will not upgrade
them. Removing it means remembering exactly what you copied, and the only place
that is written down is your own notes.

The cost goes up at each step, and so does the amount you have to remember.
Choose the lowest number that works.

## Check before you install

`notes/candidates.txt` lists tools worth having. Some of them are already here.
Check first — with `command -v`, not with `apt`:

```
apt-cache policy htop
  Installed: (none)
```

and yet `htop` runs. This is not a bug and it is not a lie. Several tools on
this station were installed by a *different* packaging system — the same one
whose manual pages surfaced under `/nix/store` in lesson 03 — and apt has no
knowledge of it. Two package managers on one machine, neither aware of the
other, both correct about their own half.

This is worth internalising now, because the reflex it should produce is: ask
the *system* whether a command exists, not the package manager.

```
command -v NAME      the one that would run
type -a NAME         every one, in PATH order
```

## /usr/local, and why it exists

```
/usr/bin        the distribution's programs. Not yours.
/usr/local/bin  programs you installed by hand. Yours.
~/.local/bin    programs for one user. No root needed.
/opt/NAME       a self-contained third-party tree.
```

The split is a contract: the package manager promises never to write to
`/usr/local`, and in exchange you promise not to drop hand-built files into
`/usr/bin` where the next upgrade will overwrite them. Keep your end and the two
never collide.

`/usr/local/bin` is already on `PATH`, and `/usr/local/share/man` is already on
the manpath, which is why a tarball that lays itself out as `bin/` and
`share/man/` installs with a single `cp -r`.

## Look inside a tarball before you extract it

```
tar -tzf thing.tar.gz | head
```

`t` lists, `x` extracts. A well-behaved archive contains exactly one top-level
directory and everything else inside it. One that does not will scatter files
across your current directory, and there is no undo. Look first. Always.

## What you lose on route three

`notes/page.txt` puts it plainly: something that arrives in `/usr/local` leaves
no record of what it is, when it arrived, or who put it there. That is the
accepted cost of installing by hand, and for a tool you fetched deliberately it
is a fair trade.

It is a less comfortable property when you are the one asking where a program
came from. Keep it in mind. You will want it later in this chapter.

## When you are done

You can find and install a tool from the archive, install one from a tarball
into a prefix that will not fight the package manager, tell which of the two a
given command came from, and say what each route costs you.
