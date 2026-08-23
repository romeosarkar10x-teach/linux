# 02/07 — Solutions (agent eyes only)

> **Student: do not open this file.** It contains the flag and every answer. Reading it removes the
> only thing this lesson had to offer.

## The shape of the incident

`maintenance` contains two directories, both dot-prefixed, so plain `ls` shows nothing and exits 0.
One is `.cache`, genuinely empty — the required red herring. The other is:

```
.a name you cannot type
              ^
              this is U+00A0 NO-BREAK SPACE, not the space key
```

…and it has a **trailing space** as well. So the name has three obstacles stacked: the leading dot
hides it from `ls`, the ordinary spaces defeat unquoted `cd`, and the U+00A0 plus the trailing
space defeat *correct* quoting too — a student who types `cd 'maintenance/.a name you cannot type '`
has quoted perfectly and still gets `No such file or directory`. That failure is the lesson.

Inside: `ballast.bin` (41926656 bytes = 40 MiB of the letter `e`, which is the entire 40M),
`audit-notes.txt` (687 bytes, trace 2, mtime 2187-05-15 23:41), and `.keep`.

`overnight/` next door is the second red herring: visible, boring, 24K.

## Per exercise

**1.** `ls maintenance` → nothing, `echo $?` → `0`. `du -sh maintenance` → `40M`.

**2.** `du -h -d 1 maintenance`:
```
40M	maintenance/.a name you cannot type 
4.0K	maintenance/.cache
40M	maintenance
```

**3.** `ls -a maintenance | wc -l` → 4 (`.`, `..`, and the two directories); `ls -A` → 2.

**4.** The 40M is the spaced dot-directory; `.cache` is 4.0K, i.e. its own directory block and
nothing else. Evidence is exercise 2's output.

**5.** `ls -a maintenance/.cache` → exactly `.` and `..`; `ls -A` → nothing; `du -sh` → 4.0K.
The point of the exercise is that plain `ls` is no longer admissible evidence.

**6.** `du -sh overnight` → `24K`; five files, four run logs and a `NOTES`. 24K cannot explain a
40M discrepancy. Irrelevant.

**7.** The canonical failure:
```
$ cd "maintenance/.a name you cannot type "
bash: cd: maintenance/.a name you cannot type : No such file or directory
```
Ways in: tab completion (`cd maintenance/.a<TAB>`), a glob (`cd maintenance/.a*`), or pasting the
output of `stat -c %N`.

**8.** `pwd` → `/labs/02-navigating-the-filesystem/07-incident-02/maintenance/.a name you cannot type `.
`ls -a` → `.`, `..`, `.keep`, `audit-notes.txt`, `ballast.bin`.

**9.** `ballast.bin`, `41926656` bytes, `file` reports
`ASCII text, with very long lines (65536), with no line terminators` — it is 40 MiB of `e` with no
newline. The sentence: `du` sums bytes on disk and never consults the dot rule; `ls` omits names
starting with `.` unless told otherwise. Both were telling the truth about different questions.

**10.** `LC_ALL=C ls -b -A maintenance`:
```
.a\ name\ you\ cannot\302\240type\ 
.cache
```
Two characters are not what a reader would guess: the `\302\240` (U+00A0 NO-BREAK SPACE, encoded
as two bytes in UTF-8) between `cannot` and `type`, and the trailing space, which prints as
nothing at end of line. Plain `ls -b` under `C.UTF-8` escapes neither — forcing the C locale is
what makes the bytes non-printable and therefore escaped. This is the technique from lesson 06.

**11.** `stat -c %N "maintenance/.a"*` → `'maintenance/.a name you cannot type '`. Paste-safe,
because the quotes cover the spaces — but the U+00A0 is a *printable* character, so `stat` has no
reason to escape it and renders it as a blank. The name can be copied and cannot be typed.

**12.** (a) fails — the string is right in every respect except the two characters. (b) succeeds —
completion reads the name off disk. (c) succeeds — `cd maintenance/.a*`; the shell expands the glob
against the directory, so the exact bytes never pass through the keyboard. (d) succeeds — a paste
carries the U+00A0. The generalisation: (b), (c) and (d) all work because the *filesystem* supplies
the name; only (a) requires the human to reproduce it.

**13.** `ls -A` → 2 lines (`-A` is `-a` minus `.` and `..`). `tree maintenance` →
`0 directories, 0 files` — it saw nothing to descend into. `tree -a maintenance` →
`3 directories, 3 files`: the two subdirectories plus `maintenance` itself, and `.keep`,
`audit-notes.txt`, `ballast.bin`. `tree` applies the same dot rule as `ls`.

**14.** `du -s -B1 maintenance` → `41943040`; `du -sb maintenance` → `41927343`; difference
`15697`. Breakdown: on disk, three directories × 4096 + `audit-notes.txt` rounded up to 4096 =
16384, against an apparent 687 (`du --apparent-size` reports the directories as 0 here);
`41926656` is exactly 10236 × 4096 so `ballast.bin` contributes nothing to the gap.
16384 − 687 = 15697. cass's disk accounting reports the on-disk figure — that is what actually
consumes the filesystem.

**15.** The notes describe a mismatch between a strain series and a maintenance log for deck 3, three
candidate explanations, one ruled out, and a decision to keep a copy of the summariser's output
before raising it with anyone. **The file does not name its author and neither does anything else in
the chapter.** At 687 bytes it cannot be the 40M; `ballast.bin` is. The two facts are unrelated —
the notes are why someone made a hidden directory, not why it is large.

**16.** `audit-notes.txt` mtime `2187-05-15 23:41:00`; `ballast.bin` carries the seed time. The gap
shows the notes were last written long before the filler existed. It does **not** establish who
created either, whether the mtimes are honest (`touch -d` sets any date), or that the directory was
hidden on that date.

**17.** `ls -1iA maintenance` → two different inode numbers (seed-specific, e.g. 44766 and 44765).
Different inodes mean two genuinely separate directories; identical ones would have meant one
directory reached by two names.

**18.** `du -ab maintenance` — `-a` reports files as well as directories, `-b` is bytes and
apparent size. The `41926656` line is `ballast.bin`.

**19.** **Flag:** `KESTREL{a_name_you_cannot_type}`

Derivation: name is `.a name you cannot\302\240type `; drop the dot, lowercase (already), each run
of whitespace including the U+00A0 becomes one underscore, trailing one dropped →
`a_name_you_cannot_type`.

Registered as `02/07` in `container/flags.tsv`:
```
printf '%s%s' 'kestrel-station-7' 'KESTREL{a_name_you_cannot_type}' | sha256sum
e211eb6678cb04d073fcb09a5d27f67ac008f1429e4c0b65758fdbfd59a79450
```

The flag exists in no file in the lab. `grep -r a_name_you_cannot_type /labs` returns nothing —
the on-disk name has spaces and a no-break space where the flag has underscores.

**20.** Model debrief:
> `ls` showed nothing because it omits entries whose names begin with a dot unless asked.
> `du` showed forty megabytes because it counts blocks on disk and the dot rule is an `ls`
> convention, not a filesystem one.
> The forty megabytes is one file, `ballast.bin`, 41926656 bytes of a single repeated character.
> A filename is just a sequence of bytes — any byte except `/` and NUL — so it can hold characters
> that are invisible when printed and impossible to type.
> For cass: nothing lied. `ls` and `du` answer different questions, and the name was chosen so
> that the difference between those questions would hide something.

## Notes for the authoring/tutor agent

- `file` on `ballast.bin` says "ASCII text" rather than "data" because it is printable characters.
  Students who expected binary are right to be surprised; it is filler, and nothing more.
- `du --apparent-size` reports directory entries as 0 in this image, which is what makes the 15697
  arithmetic close. If a student's numbers differ, have them check they ran `-B1` and not `-h`.
- `audit-notes.txt` is **trace 2** of the sabotage arc (`_handoff/SCENARIOS.md`, 2187-05-15). It is
  dorn's. The chapter never says so and no agent may say so. It is read again in Chapter 15.
