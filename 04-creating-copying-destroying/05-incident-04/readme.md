# 04/05 — Incident: deleted, not moved

> There is a manifest. There is no tree. Rebuild what the manifest describes.

## The page

cass forwards one line from the archivist at 07:15:

> "Deck-03 salvage tree is not where the index says it is. There is a manifest in `records/`. I need
> the tree back, and I need to know whether it was deleted or whether somebody moved it — because if
> it was moved, it is still on this station and I would rather find it than rebuild it."

That is the whole briefing. Two questions, and they are not the same question.

## What this lesson is

Everything in Chapter 4, used at once and against a real constraint:

- `cat`, `nl`, `head`, `tail`, `less` to read a manifest that does not fit on a screen.
- `mkdir -p` and brace expansion to build fifteen paths without typing fifteen paths.
- `cp` and `mv` to place the two files that survived, without destroying them in the process.
- `rm` — mostly by not using it.
- `mktemp` for anything you are not sure about.

No new commands. No `grep`, no `find -name`, no `sed`, no `awk` — those are Chapters 6 and 7. If you
already know them, using them here will get you the wrong answer faster: this manifest is meant to be
*read*, and the thing that matters about it is visible to a human and invisible to a pattern.

## The constraint

**Build the tree with brace expansion and `mkdir -p`, not with forty `mkdir` calls.** The validating
agent counts commands. Somebody who brute-forces fifteen directories one at a time has rebuilt the
tree and learned nothing the chapter was for, and passes with notes rather than clean.

The same applies to the files. Fifteen files with fifteen recorded sizes; there is a way to create a
file of an exact size that you met in Chapter 3, and there is a way to say fifteen names in one line
that you met in lesson 02.

## The shape of it

```
$ ls -F
rebuild/  records/  salvage/
```

- `records/tree-manifest.txt` — the manifest. Four columns: path, size, recorded, note.
- `records/tree-manifest.txt.bak` — a second copy of the manifest. It is **older**. It disagrees with
  the first one in more than one way, and it says on it what it is for.
- `records/copy-notes.txt` — why the copy was taken. Written by somebody who is not named on it.
- `salvage/` — two of the fifteen files survived. Two.
- `rebuild/` — empty. Your tree goes in here.

> **A manifest is a record of a tree, not a copy of one.** It survives because it is small and it
> lives somewhere else. Everything in this lesson follows from that: what a manifest can prove, what
> it cannot, and what happens when two manifests of the same tree disagree.

## Rules of engagement

1. **Read the manifest before you build anything.** All of it, including the header. There is an
   instruction in the header that tells you how to check your own work, and it is the only thing in
   the lab that does.
2. **Two manifests disagree. Decide which one is authoritative and write down why** before you use
   either of them. This is not a formality; one of them will build you a tree that is wrong in a way
   you cannot see afterwards.
3. **In-chapter tools only.** `ls`, `cat`, `nl`, `head`, `tail`, `less`, `wc`, `stat`, `du`, `file`,
   `mkdir`, `touch`, `cp`, `mv`, `rm`, `mktemp`, brace expansion, `cd`, `pwd`. Chapter 3's `stat`
   and `find -type` are fair. No `grep`, no `find -name`, no `sed`, no `awk`.
4. **Do not delete anything in `salvage/`.** Two files out of fifteen survived. If you `mv` them into
   place and get it wrong, they are gone; `cp` and they are not. Decide deliberately.
5. **Do not open `setup.sh`.** It is the answer key.
6. **Record what you tried, including what failed.** Sizes that came out wrong are findings.

## The flag

The manifest header tells you how engineering confirms a manifest. Do that, on the right manifest,
in the right order, and you get three words. The flag is those three words joined with underscores:

```
KESTREL{word_word_word}
```

Submit it from the VM, not from inside the container:

```
./container/bin/kestrel flags submit 'KESTREL{...}'
```

The flag is not written anywhere in the lab. There is nothing to find with a search; there is
something to *read correctly*.

## What "solved" looks like

You will be able to state, in one sentence each:

- what the manifest says the tree contained, and how many files that actually is;
- what the two rows four minutes apart mean, and which of the two describes a file that existed;
- which manifest is authoritative and what the other one is;
- what the surviving two files prove that the manifest alone could not;
- and the archivist's actual question: whether this tree was deleted or moved, and what evidence
  would distinguish those two — including the evidence you do **not** have.

## Before you move on

The last one is the point of the incident. "Deleted" and "moved" leave different traces, and by the
time somebody asks you, most of those traces have expired. Be exact about what you can prove.
