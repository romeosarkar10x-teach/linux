# 13/02 — dpkg and repositories

> Every package on this station came from somewhere that a file says is
> trustworthy. Somebody edited that file three weeks ago.

Lab: `/labs/13-packages-docs-editors/02-dpkg-and-repos`.

Lesson 01 was the front end. This is the two things behind it: the program that
actually installs files, and the configuration that decides where packages are
allowed to come from.

## dpkg installs; apt decides

`apt` works out *what* should be installed — which versions, which
dependencies, in which order — and then hands `.deb` files to `dpkg`, which
unpacks them and runs their scripts. Every fact `apt` knows about your installed
software it reads out of dpkg's database in `/var/lib/dpkg/`.

That split is why `dpkg` can do things `apt` cannot, and why it will happily do
one thing `apt` would refuse.

```
dpkg -l [PATTERN]   installed packages, one line each
dpkg -L PACKAGE     the files that package put on disk
dpkg -S PATH        which package owns this file
dpkg -s PACKAGE     the full status stanza
dpkg -i FILE.deb    install a .deb, right now, with no view of any repository
dpkg -c FILE.deb    what is inside a .deb  (installs nothing)
dpkg -I FILE.deb    the .deb's control information  (installs nothing)
```

`-c` and `-I` are the two you should reach for first when handed a `.deb` by
somebody. They read the file and change nothing.

## The two letters

Every `dpkg -l` line starts with a two-character state. The first character is
what was *asked for*; the second is what is *true*.

```
ii   installed and configured — the normal state
rc   removed, configuration files still present
iU   unpacked but NOT configured — something failed partway
un   not installed; the name is known only because something mentioned it
```

`iU` is the one worth recognising on sight. It means the files are on disk and
the package's configuration step did not complete — usually because a dependency
was missing. The files being on disk means the program will very likely *run*,
which is exactly how a half-installed package hides.

## `dpkg -i` does not do dependencies

`apt install` refuses to leave you in a broken state. `dpkg -i` has no
repository, no candidate list, and no plan: it unpacks what you gave it, tries
to configure it, and reports a failure if it cannot. It does not go and find the
missing piece, because it has nowhere to look.

The lab has a `.deb` that fails exactly this way. Install it and read the
failure carefully. Then run the program anyway.

## Where a repository is configured

```
/etc/apt/sources.list            the old single file
/etc/apt/sources.list.d/*.list   one-line format, one file per source
/etc/apt/sources.list.d/*.sources  deb822 format, one field per line
```

apt reads all of them, as a set. Nothing makes one authoritative over another,
and nothing about the directory says which files came with the machine and which
were added afterwards.

`sources/` in the lab holds four examples to read: the one-line format, the
deb822 format, an unsigned repository, and a third-party archive of the shape a
PPA takes once it has been added.

## Signed, unsigned, and the bracket

A repository is trusted when apt can verify its `Release` file against a key it
holds. Keys live in `/usr/share/keyrings` and `/etc/apt/keyrings`, and a source
line names the one it expects with `signed-by=`.

Two ways to end up without that check:

- **No `Release` file at all.** apt refuses:
  `E: The repository '...' does not have a Release file.`
- **`[trusted=yes]`.** apt stops asking. Nothing else changes — the packages are
  not verified, and dpkg installs whatever arrives.

That is the answer to lesson 01's exercise 6, and it deserves saying plainly:
`[trusted=yes]` is not an attack and not a mistake. It is the correct thing to
write for a local mirror you built yourself, which is why every fleet without
internet access has one. It is also what you write when you are in a hurry, and
it looks identical either way.

## apt versus snap

Ubuntu ships a second packaging system, `snap`: self-contained bundles with
their own runtime, updated on their own schedule, from a single store. This
station's image does not have it, and this course does not use it. Know that it
exists, that `snap list` is its `dpkg -l`, and that a program can be installed
twice by two systems with two different versions — which is a real diagnosis you
will make one day, most likely on somebody's laptop.

## The note in the lab

`notes/page.txt` is a note you wrote to yourself: `sources.list.d` has more in it
than the station image ships with. One file, one line, not from any station
build.

That is the whole note. It does not say who added it, and neither does the file.
This lesson gives you the commands to find out what a repository is and what it
has installed; it does not ask you to conclude anything yet.
