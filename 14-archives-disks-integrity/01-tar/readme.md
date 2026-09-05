# tar

Eleven years of station data lives in archives nobody has opened. Groundside
wants a copy in September, which means somebody has to establish that they open
at all. That somebody is you, and by the end of this lesson you will have
opened seven of them, one of which is lying about its own format.

## Three jobs, one letter each

```
-c   create      make an archive
-t   list        show what is inside, extracting nothing
-x   extract     take the files out
```

Exactly one of those per command. Everything else is a modifier: `-f` for the
archive file, `-v` to print members as they go past, `-z`/`-j`/`-J` for gzip,
bzip2 and xz, `-C` to change directory first.

## Why `-f` goes last

`-f` takes the next word as its argument. In a bundle of short options, the
next word is whatever follows the bundle. So:

```
tar -cfz archive.tar.gz deck-logs      # wrong
```

hands `z` to `-f`, creates a file literally named `z`, and then tries to add
`archive.tar.gz` and `deck-logs` to it. On this station that produces:

```
tar: archive.tar.gz: Cannot stat: No such file or directory
tar: Exiting with failure status due to previous errors
```

and leaves a 10 KB file called `z` sitting in your directory. Write `-czf`.
Put `-f` last, always, and the argument after it.

## Look before you extract

`tar -x` writes files into your current directory and overwrites what is
already there without asking and without telling you what it replaced. There is
no undo. The habit that costs you two seconds:

```
tar -tzf archive.tar.gz | head
```

You are looking for one thing: **is there a single top-level directory?** An
archive whose members all start `deck-logs-2187/` extracts into one tidy
directory. An archive whose members are `settle.conf`, `hatch.conf`,
`report.tsv`… extracts nine files straight into wherever you are standing.
`archives/calibration-export.tar.gz` is the second kind. That is not a hostile
archive; it is an ordinary one made by somebody who was in a hurry.

The other half of the habit is `-C`:

```
mkdir scratch
tar -xzf archives/calibration-export.tar.gz -C scratch
```

`-C` changes directory before extracting. Nothing you care about is in
`scratch`, so nothing you care about can be overwritten.

## Compression flags are only needed on create

Since tar 1.15, reading an archive detects the compression automatically. On
this station:

```
tar -tf archives/hatch-tally.tar.bz2      # works, no -j needed
```

Giving the *wrong* one is worse than giving none. `archives/spare-logs.tar.bz2`
is gzip data with a bzip2 name, and `tar -tjf` on it says
`bzip2: (stdin) is not a bzip2 file.` and exits 2, while plain `tar -tf` reads
it perfectly. `file` will tell you what it actually is. Trust `file`, not the
extension — an extension is a claim somebody typed.

## `--strip-components`

Archives grow wrapper directories. `archives/strain-export.tar.gz` has four of
them before anything useful: `export/2187/07/06/deck-09/strain.tsv`.

```
tar -xzf archives/strain-export.tar.gz -C scratch --strip-components=4
```

drops the first four path components from every member as it extracts, leaving
`scratch/deck-09/strain.tsv`. Strip too many and members with shorter paths are
silently skipped, so count first with `-t`.

## Absolute paths

`archives/etc-backup.tar` was built from `/etc/kestrel`. tar refuses to store a
leading `/` and says so, both when the archive is made and every time it is
listed:

```
tar: Removing leading `/' from member names
```

That warning is tar protecting you. Extraction puts the files under your
current directory, not over the real `/etc`. `--absolute-names` on extract
switches the protection off; you want a specific reason before you type it.

## Exit status

`tar` exits 0 on success and 2 on a fatal error — a missing archive, a wrong
decompressor, an unreadable file. Chapter 8's habit applies: in a script, check
it.

## Files

- `archives/` — seven archives, described in `notes/archives.txt`
- `scratch/` — empty, and the only place you should extract anything
- `notes/tar.txt` — the flags, and the habit
