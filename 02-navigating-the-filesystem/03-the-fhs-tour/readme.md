# 02/03 — Where things live

> There is a convention for where things live on a Linux system. Kestrel follows it in the places
> where following it was easier than not.

The layout of a Linux root directory is not arbitrary and it is not enforced. It is a written
convention — the **Filesystem Hierarchy Standard**, FHS — that distributions mostly follow and
that individual admins routinely violate. Knowing it is what lets you guess correctly on a machine
you have never seen: where the config is, where the logs are, where a package put its binary.

The whole thing is documented on the machine itself:

```bash
man 7 hier
```

Read it once at some point. It is short, and it is the only authority you need.

## The organising question

FHS sorts directories along two axes, and once you see them the layout stops feeling like trivia:

|  | **Static** (changes only when you install things) | **Variable** (changes while the system runs) |
|---|---|---|
| **Shareable** across machines | `/usr`, `/opt` | `/var/mail`, `/srv` |
| **Not shareable** | `/etc`, `/boot` | `/var/log`, `/var/run`, `/tmp` |

That table is why `/etc` is not inside `/usr`, and why logs are not next to the programs that
write them. A machine could mount `/usr` read-only, or share it over a network, and still work —
because everything that changes lives somewhere else.

## The tour

**`/`** — the root of the one tree. Contains directories, not files.

**`/bin`, `/sbin`, `/lib`** — on any modern distribution these are **symlinks into `/usr`**. Check
this station:

```bash
$ ls -ld /bin /sbin /lib
lrwxrwxrwx ... /bin -> usr/bin
lrwxrwxrwx ... /lib -> usr/lib
lrwxrwxrwx ... /sbin -> usr/sbin
```

They used to be real directories, holding the minimum needed to boot before `/usr` was mounted.
That distinction died when initramfs made it unnecessary, and the merge — "usrmerge" — happened
across distributions between 2012 and 2022. You will still find documentation that assumes they
are separate. It is out of date.

**`/usr`** — the bulk of the operating system. Programs, libraries, documentation, man pages,
icons. **Not** "user files" — the name is a historical accident; read it as "unix system
resources" if that helps.

- `/usr/bin` — commands anyone can run
- `/usr/sbin` — commands intended for the administrator (`useradd`, `fdisk`)
- `/usr/share` — architecture-independent data: man pages, docs, timezone tables
- `/usr/local` — **your** machine's local additions, in the same shape (`/usr/local/bin`,
  `/usr/local/share`). The package manager will never touch it, which is exactly the point.

**`/etc`** — system-wide configuration, and by convention **plain text**. Per-machine, never
shared. `/etc/passwd`, `/etc/shells`, `/etc/hostname`, `/etc/os-release`. If a program on this
station behaves oddly, its `/etc` file is the first thing to read.

**`/var`** — data that changes as the system runs. `/var/log` (logs), `/var/lib` (a program's
persistent state — package databases, for instance), `/var/cache` (regenerable), `/var/tmp`
(temporary files that must survive a reboot), `/var/spool` (queued work).

**`/tmp`** — temporary, and free to be wiped at any reboot. Note its permissions:

```bash
$ ls -ld /tmp
drwxrwxrwt 1 root root 4096 ... /tmp
```

That trailing `t` is the sticky bit: anyone may create files, but only the owner may delete their
own. Chapter 10 explains it properly. For now, notice that a directory's mode can encode a policy.

**`/home`** — one directory per human user. `/root` is separate, and is *not* under `/home`,
because `/home` might be a network mount that is not available when root needs to log in.

**`/opt`** — self-contained third-party software: one subdirectory per product, containing its own
`bin`, `lib`, whatever it likes. This station uses it: `/opt/kestrel` holds every course tool.

**`/proc`, `/sys`, `/dev`** — not on any disk. The kernel presents information as files here. The
next lesson is entirely about `/proc`.

**`/boot`** — the kernel and bootloader. **`/srv`** — data served by this machine (web roots,
shares). **`/media`, `/mnt`** — mount points for removable and temporary filesystems.

**`/run`** — runtime state since boot: process id files, sockets. Empty at every boot, on a
memory-backed filesystem. `/var/run` is a symlink to it on this station.

## Two things this station does that the FHS does not describe

Worth noticing, because the exercises will ask:

- **`/course` and `/labs`** — invented for this course. `/course` is the lesson material, mounted
  read-only; `/labs` is your working volume. Neither is standard. This is normal: FHS tells you
  where *system* things go, and says nothing about mount points somebody adds.
- **`/nix`** — the store the course tools were built into. `/opt/kestrel/bin` is a directory of
  symlinks into it. A single-directory-at-root layout like this is exactly the kind of thing FHS
  does not sanction and the world does anyway.

## Gotchas

> **Several of these directories are empty in this container.** `/boot`, `/srv`, `/media`, `/mnt`
> have nothing in them. That is a fact about containers — no kernel of its own, no removable
> media, nothing being served — not a fact about Linux. On the Ubuntu VM outside, `/boot` is full.

> **`/usr/local` versus `/opt`.** Both are for software that is not from the distribution. The
> rule of thumb: `/usr/local` when the thing spreads out into the standard shape and you want it
> on `PATH` like everything else; `/opt` when it is one self-contained blob you might delete whole.
> Reasonable people disagree, and both answers are defensible for most software.

## Before you move on

- FHS is a convention, documented in `man 7 hier`, not something the kernel enforces.
- The organising axes are static/variable and shareable/not.
- `/bin`, `/sbin`, `/lib` are symlinks into `/usr` on any current distribution.
- `/etc` is per-machine text configuration; `/var` is state that changes as the system runs.
- `/proc`, `/sys` and `/dev` are not stored on any disk.
