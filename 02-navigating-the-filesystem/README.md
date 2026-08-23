# Chapter 2 — Navigating the Filesystem

> Disk accounting says a directory holds forty megabytes. `ls` says it holds nothing.

## Incident briefing

Chapter 1 was your own shell. This chapter is the station's disk.

`/` on the Kestrel is not a metaphor and not a mess: it is a documented layout, and once you can
read it you can tell at a glance whether a file is where it belongs. You will walk that tree,
learn what each top-level directory is *for*, and meet two directories that are not on any disk at
all — `/proc` and `/sys`, where the kernel answers questions in the shape of files.

Then it gets adversarial. You will learn that a directory listing is an opinion, that a file's size
is at least three different numbers depending on who is asking, and that a filename is bytes —
which means a name can be printed on your screen and still be impossible for you to type.

That last fact is the incident. cass reports a directory that eats forty megabytes and contains
nothing. Both halves of her report are true. Finding out how takes everything in this chapter and
nothing from any later one: no `find`, no `grep`.

## Learning objectives

- [ ] Move around by absolute and relative path without guessing — `cd`, `pwd`, `.`, `..`, `~`, `-`
- [ ] Read `ls -l` completely: type character, permissions, links, owner, size, time
- [ ] Know what lives in `/etc`, `/var`, `/usr`, `/tmp`, `/opt`, `/home`, `/dev`, `/proc`, `/sys`
- [ ] Read kernel and process state out of `/proc` — and know why its files have size 0
- [ ] Tell apart a file's apparent size, its size on disk, and what `du` reports for its directory
- [ ] Use `stat` and `file` to ask precise questions instead of trusting a name or an extension
- [ ] Survive filenames containing spaces, leading dashes, glob characters and invisible bytes
- [ ] Reveal a filename's actual bytes with `LC_ALL=C ls -b`, and quote it with `stat -c %N`
- [ ] Understand that `ls` showing nothing and a directory being empty are different claims

## Prerequisites

- Chapter 0 — the container is built and `kestrel seed` / `kestrel reset` work
- Chapter 1 — comfortable with command anatomy, options, quoting basics, tab completion and history

## Lessons

- [`01-filesystem-tree`](01-filesystem-tree/readme.md) — root, absolute and relative paths, `.`, `..`, `~`, `-`
- [`02-cd-and-ls-deep`](02-cd-and-ls-deep/readme.md) — `ls` in depth: `-l`, `-a`, `-A`, `-d`, `-h`, `-t`, `-r`, sorting and what each column means
- [`03-the-fhs-tour`](03-the-fhs-tour/readme.md) — the Filesystem Hierarchy Standard, one directory at a time, on a real system
- [`04-proc-and-sys`](04-proc-and-sys/readme.md) — the kernel as files: `/proc/<pid>`, `/proc/self`, `/proc/sys`, and why the container is not the machine
- [`05-tree-and-stat`](05-tree-and-stat/readme.md) — `tree`, `stat`, `file`, `du`, `df`: four tools that disagree about size, all correctly
- [`06-paths-in-anger`](06-paths-in-anger/readme.md) — hostile filenames: spaces, dashes, newlines, lookalikes, invisible bytes, `--` and `./`
- [`07-incident-02`](07-incident-02/readme.md) — **the incident.** Forty megabytes of nothing

## Flags in this chapter

**1** — in `07-incident-02`. It is not stored in any file; it is derived from something you find.
