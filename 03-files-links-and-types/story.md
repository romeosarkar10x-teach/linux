# Chapter 3 — story

**Chapter arc.** The maintenance-deck maze. **Trace 3** — a symlink whose target went away with the
engineering mount after dorn did. The dead target's *path name* matters in Chapter 15; here it is
just a broken link.

---

### `01-everything-is-a-file`
> The first character of every `ls -l` line is the station telling you what kind of thing it is.
> Most people read past it for years.

### `02-inodes`
> A filename is not a file. It is a label somebody stuck on one, and labels come off — which is
> how two names end up meaning the same thing and nobody notices for a decade.

### `03-hard-vs-symlinks`
> Half the maintenance tree is links pointing at other links. Three of them go somewhere.

### `04-timestamps`
> Every file on this station remembers three different times, none of which is "when it was
> created", and the difference between them is about to become your job.

Quietly the most load-bearing lesson in the course — the capstone is a sorting-by-date exercise.

### `05-devices-fifos-sockets`
> Some files are not storage. They are holes in the wall that two programs shout through. You are
> going to build one and shout through it.

### `06-incident-03` — the incident
> Four links in the maintenance tree. Three go somewhere. One has been pointing at nothing since
> before you arrived, and nothing that runs depends on it, which is why nobody noticed.
