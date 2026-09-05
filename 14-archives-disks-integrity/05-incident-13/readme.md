# 05 — Incident 13: the export that passed

The strain export for June is sitting in `export/`. It has a checksum file and
the checksum file passes. `ops-bot` has confirmed it. The captain would like it
signed off today.

There is also a `MANIFEST.txt` in that directory, written by hand by whoever
specified the export, describing what the export was *supposed* to contain. As
far as anyone can tell, nobody has ever checked the archive against it.

That is the whole job. Check it.

## The constraint

**The archive must not be modified.** Not repacked, not recompressed, not
"cleaned up". Extract to `scratch/` and work on the copy. When you are done you
must be able to demonstrate — not assert — that the bytes in `export/` are the
bytes that were there when you started.

That constraint is not busywork. An export under review is evidence, and
evidence you have edited is evidence nobody can use. Lesson 04 gave you the
tool for proving it.

## What you have

- `export/strain-archive-2187-06.tar.gz` — twenty daily logs for deck-04.
- `export/SHA256SUMS` — the export's own checksum file.
- `export/MANIFEST.txt` — expected line count and hash per day file. Handwritten.
- `export/console-note.txt.gz` — a note from the bay console.
- `readings/deck-04-daily-max.csv` — the deck's own daily maximum strain
  readings, recorded independently of the export, with the clamp threshold.
- `bin/manifest-audit` — a deck ops tool. Run it with no arguments for usage.

## The tool

`manifest-audit` has three commands and will refuse to do any of them if the
archive's bytes have changed. It exits 3 if you modified the archive, 4 if the
audit is incomplete, 5 if your findings are wrong. It tells you which.

Each command that succeeds prints a `STAGE{...}` token. Those are progress
markers for you; they are not flags and `kestrel flags` does not know them.

## What you are looking for

Not corruption. The archive is intact and you will prove that in the first
minute. The question is whether "intact" and "correct" are the same thing, and
this export is the counterexample.

When you find the pattern, write it down as an attestation and submit it. The
flag is `KESTREL{...}` and you submit it the usual way.

## Two things that will waste your time

There is a file in `export/` that will not decompress the way its name says it
should. Work out what it actually is, note it, and move on — it is a bad
filename, not a finding.

And one line of `MANIFEST.txt` does not match its file, in a way that will make
you want to throw the whole manifest out. Look at that line closely before you
do. A manifest written by a person can contain a person's mistake without
being wrong about everything else. Deciding which parts of a document to trust,
line by line, is most of this job.

## Report

Facts, and only facts. Name what you measured. Do not name a person; you have
no evidence about who, and this incident does not contain any.
