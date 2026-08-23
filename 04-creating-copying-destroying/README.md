# Chapter 4 — Creating, Copying & Destroying

> There is a manifest. There is no tree. Somebody wrote down exactly what they copied on
> 2187-05-17, and a week later the thing they copied it from stopped existing.

## Incident briefing

Chapters 2 and 3 were read-only. You listed, you followed links, you read timestamps, and nothing
you typed could have made the station worse. That ends here.

This chapter is the four commands that change the disk: `mkdir`, `cp`, `mv`, `rm`. Each of them
does one obvious thing and two or three surprising ones, and the surprises are not exotic — they
are the trailing slash on a destination that does not exist yet, the `-i` flag that prompts only
when stdin is a terminal, the `chmod 400` that does not protect a file from deletion because
deleting a file is not writing to it. Every one of those is a way somebody has destroyed real work,
which is why this chapter's exercises are written to make you destroy things on purpose, in a
directory `kestrel reset` puts back.

It opens with reading, though — `cat`, `head`, `tail`, `less`, `wc`, `nl`, `cat -A`. Not because
reading is new, but because the only way to be confident about a change is to be fluent at reading
the state before it and the state after it. Then `mkdir -p` and brace expansion, which is the
difference between forty commands and one. Then `cp` and `mv`, where the trailing slash lives. Then
`rm`, and the folklore around it, most of which is wrong.

The incident is a manifest. Sixteen rows describing fifteen files, a tree that no longer exists,
a salvage directory holding two of the fifteen, and a `.bak` copy of the manifest that is nine
hours older, disagrees, and is dangerous precisely because it is internally consistent. Rebuild
what the manifest describes. Then answer the harder question, which is what the evidence in front
of you does *not* support — a distinction the log's author did not make.

## Learning objectives

- [ ] Read a file with the right tool: `cat`, `head`, `tail`, `less`, `nl`, `wc`, `tail -f`
- [ ] Reveal what is not printable — `cat -A`, tabs, CRLF, and a missing final newline
- [ ] Create directory trees with `mkdir -p` and brace expansion instead of one call per directory
- [ ] Say exactly what `mkdir -p` swallows and the one error it cannot
- [ ] Set permissions at creation with `mkdir -m`, and predict how `umask` alters the result
- [ ] Create and stamp files with `touch`, including `-c`, `-r`, `-a`, `-m`
- [ ] Copy files and trees: `cp`, `cp -r`, `cp -a`, `-i`, `-n`, `-u`, `--backup`
- [ ] State what `cp -a` preserves that plain `cp` does not, and what nothing preserves
- [ ] Predict `cp`/`mv` behaviour from whether the destination exists and whether it is a directory
- [ ] Explain the trailing slash on a destination, and use it deliberately as a safety device
- [ ] Distinguish `mv` within a filesystem from `mv` across one, in terms of inodes and atomicity
- [ ] Delete safely: `rm`, `-r`, `-i`, `-I`, `-f`, and the exit statuses each one lies about
- [ ] Delete files whose names begin with a dash — `rm --` and `rm ./name`
- [ ] Explain why deleting a file is a write to its *directory*, and what that means for `chmod 400`
- [ ] Describe what `rm` frees, what it does not, and where an unlinked-but-open file still lives
- [ ] Build a `trash` function, use `mktemp` and `trap`, and say why `shred` cannot promise much

## Prerequisites

- Chapter 0 — the container is built and `kestrel seed` / `kestrel reset` work
- Chapter 2 — `ls -l` read column by column, `stat`, `du`, and paths that fight back
- Chapter 3 — inodes, link counts, hard links versus symlinks, and the three timestamps

## Lessons

- [`01-cat-and-friends`](01-cat-and-friends/readme.md) — reading a file with the right tool, and seeing the bytes that do not print
- [`02-touch-mkdir`](02-touch-mkdir/readme.md) — `touch`, `mkdir -p`, brace expansion, `-m` and `umask`
- [`03-cp-mv`](03-cp-mv/readme.md) — `cp` vs `mv`, `-a`, the trailing slash, and the destructive overwrite
- [`04-rm-safely`](04-rm-safely/readme.md) — `rm` without folklore: `-i` vs `-I` vs `-f`, dash-names, `mktemp`, `trap`
- [`05-incident-04`](05-incident-04/readme.md) — **the incident.** A manifest for a tree that no longer exists

## Flags in this chapter

**1** — in `05-incident-04`. It is not written down anywhere. You read it out of the manifest, using
a convention the manifest itself states, after settling which of two conflicting rows is the real
one.
