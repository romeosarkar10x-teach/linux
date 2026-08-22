# Chapter 5 — story

**Chapter arc.** Files named to survive a cleanup sweep. **Trace 5** — the first artefact that is
unambiguously *chosen* rather than careless. The student is meant to conclude "somebody named
these" and nothing further.

First chained CTF (`SCENARIOS.md` §8), and deliberately the gentlest one in the course.

---

### `01-globs`
> The shell rewrites your command before the command ever sees it. Everybody knows this. Almost
> nobody knows exactly when.

### `02-brace-expansion`
> Braces are not globs. They do not look at the disk, they do not care what exists, and they will
> happily build you four hundred directory names for something that has never been there.

### `03-quoting`
> Three kinds of quote, each switching off a different thing. Getting this wrong is how a cleanup
> script deletes the wrong forty files.

### `04-word-splitting`
> A filename with a space in it is one filename. The shell disagrees, loudly, unless you tell it
> not to. Somebody on this station knows that and has been using it.

The chapter's only nod at intent. It does not go further.

### `05-incident-05` — the incident
> Housekeeping ran a fortnight ago and removed everything matching its pattern. Some files are still
> here. They were not missed by accident.

One glob, no `find`, no loops. Two of the survivors are just badly named by a human in a hurry and
must be excluded.
