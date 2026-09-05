# 13/01 — apt

> Installing software is easy. Knowing what you installed, where it came from,
> and how to take it off again is the part that separates a sysadmin from
> somebody with a keyboard.

Lab: `/labs/13-packages-docs-editors/01-apt`.

You have spent twelve chapters using tools somebody else put on this station.
This chapter is about the machinery that put them there, starting with the front
end you will type most often.

## Six verbs

```
apt update      refresh the list of what is available
apt upgrade     install newer versions of what is already installed
apt install P   install P, and everything P needs
apt remove P    delete P's files
apt purge P     delete P's files and its configuration
apt search TXT  search names and descriptions
apt show P      one package, in detail
apt list        what exists, what is installed, what could be upgraded
```

Two things to get straight immediately.

**`update` does not update anything.** It refreshes the *catalogue* — the list
of package names and versions the machine believes are available. Nothing you
have installed changes. The command that installs newer versions is `upgrade`,
and it can only work with what the catalogue says, which is why the two are
almost always typed together and almost always confused.

**`remove` and `purge` are not the same.** `remove` deletes the package's files
and leaves its configuration behind, on the theory that you might reinstall it
and want your settings. `purge` deletes the configuration too. A package that
has been removed but not purged is still in `dpkg`'s records, in a state you can
see and will meet in the exercises.

## Which of these needs root

`install`, `remove`, `purge`, `update` and `upgrade` change the system, so they
need root, which on this station means `sudo`. `search`, `show` and `list` only
read, so they do not. Typing `sudo` in front of everything is a habit worth not
forming: it is how a typo in a package name becomes a system change instead of
an error message.

## Where packages come from

A repository is not a service. It is a directory containing package files and an
index that lists them, reachable at some URL. `apt update` fetches that index.
`apt install` reads the index, works out which files it needs, downloads them,
and hands them to `dpkg`.

The lab contains one: `repo/`, holding four `.deb` files and a `Packages` index.
Its URL is a `file:` URL, because `file:` is a URL. Nothing about this lesson
needs a network, and that is not a simplification — a local repository is how
real fleets ship software to machines that cannot reach the internet.

The line that would make `apt` read it is in `repo/station.list`, and it is not
installed anywhere yet. Note the `[trusted=yes]` in it. That bracket switches off
the signature check, and lesson 02 is about what exactly it switches off.

## Dependencies

`deck-report` depends on `deck-common`. Install the first and you get the second
without asking. That is the whole point of a package manager, and it has a
consequence people meet the hard way: `apt remove deck-common` does not remove
one package. It removes everything that needs it. Read the list `apt` prints
before you answer `y`, every time — the list is the actual output of the
command, and the `y` is a formality.

The other side of that: a package installed only because something else needed
it is marked *automatic*, and `apt autoremove` deletes automatics that nothing
needs any more. `apt-mark showmanual` shows the packages you asked for by name.

## `apt` versus `apt-get`

`apt` is the interface for a person at a terminal: progress bars, colour, a
summary. `apt-get` is the older one, and its output is stable between releases.
Pipe `apt` anywhere and it tells you so itself:

```
WARNING: apt does not have a stable CLI interface. Use with caution in scripts.
```

Take it at its word. In a script — including any script you write from chapter
12 onward — use `apt-get`.

## What this lesson is for

`notes/page.txt` is from rhea, and it is short: she needs `deck-report` on the
maintenance account tonight and does not want a conversation about where the
station repository came from.

The install takes one command. Everything else in this lesson is about being
able to answer the question she does not want asked — which you will need in
five lessons, when it turns out to matter.
