# Chapter 3 — Files, Links & Types

> Four links in the maintenance tree. Three go somewhere. One has been pointing at nothing since
> before you arrived, and nothing that runs depends on it, which is why nobody noticed.

## Incident briefing

Chapter 2 taught you to read a directory listing. This chapter is about the first character of
every line in it, and about the number two columns later that almost nobody reads.

There are seven kinds of thing a directory entry can be, and only one of them is a file full of
bytes. The rest are directories, symlinks, FIFOs, sockets, and two flavours of device node — names
whose inode holds a path, or a rendezvous point, or a pair of driver numbers, and no data at all.
You will handle six of the seven directly, build a pipe and shout through it, and find out why
`cat /dev/null` is instant and `cat` on a socket is an error.

Underneath all seven is the inode. A filename is not a file; it is a label in a directory, and one
file can carry several labels. That is a hard link. A symlink is something else entirely: a small
file whose contents are a *path string*, resolved only when something opens it, never checked
before. Which is why a symlink can outlive the thing it points at, indefinitely, in plain sight.

Then time. Every file remembers three of them, none of which is "when it was created", one of
which cannot be forged by any command in this course. By the end of the chapter you can tell a
tidied-up file from an honest one.

The incident is deck 3's console: four links, three that resolve, one that has pointed at nothing
since before you came aboard. rhea wants the dead one's target path written down *before* anybody
repairs it, because the link is the only surviving record of where that path was. Next to it sit
two files that look like copies of each other and are not, which is a real finding and is not the
finding.

## Learning objectives

- [ ] Name all seven file types from the `ls -l` type character and from `stat -c %F`
- [ ] Explain what an inode holds and what it does not — and why the name is not in it
- [ ] Read and reason about the link-count column, and know when a count above 1 matters
- [ ] Create hard links and symlinks with `ln` / `ln -s`, and say why one cannot cross filesystems
- [ ] Follow a link one hop with `readlink` and all the way with `readlink -f`, `-e`, `-m`
- [ ] Tell a hard link from a copy using `ls -i` and `stat -c %h`, never using contents
- [ ] Find broken links with `find -xtype l`, and say why `-type l` cannot do it
- [ ] Describe the link itself rather than its target: `ls -l` vs `ls -lL`, `stat` vs `stat -L`
- [ ] Read atime, mtime and ctime; know which commands move which, and which cannot be set
- [ ] Use `touch` precisely — `-a`, `-m`, `-r`, `-d`, `-t`, and `-h` for links
- [ ] Compare files by time with `find -newer` / `-newermt`, and sort by the time you meant
- [ ] Create and use a FIFO; explain why it blocks, and where its bytes are (nowhere)
- [ ] Read a device node as a `(type, major, minor)` triple, and say why `mknod` is privileged

## Prerequisites

- Chapter 0 — the container is built and `kestrel seed` / `kestrel reset` work
- Chapter 2 — `ls -l` read column by column, `stat`, `file`, `du`, and paths that fight back

## Lessons

- [`01-everything-is-a-file`](01-everything-is-a-file/readme.md) — the seven types, the type character, and what "everything is a file" actually claims
- [`02-inodes`](02-inodes/readme.md) — the inode, the directory entry, and why a filename is not a file
- [`03-hard-vs-symlinks`](03-hard-vs-symlinks/readme.md) — `ln` vs `ln -s`, link counts, `readlink`, dangling links, `-L` everywhere
- [`04-timestamps`](04-timestamps/readme.md) — atime, mtime, ctime; `touch`, `relatime`, `find -newer`, and the one time nobody can forge
- [`05-devices-fifos-sockets`](05-devices-fifos-sockets/readme.md) — files that are not storage: FIFOs, sockets, `/dev/null`, major and minor numbers
- [`06-incident-03`](06-incident-03/readme.md) — **the incident.** The maintenance-deck maze

## Flags in this chapter

**1** — in `06-incident-03`. It is not stored as a flag in any file; you derive it from a line you
reach by following the chain.
