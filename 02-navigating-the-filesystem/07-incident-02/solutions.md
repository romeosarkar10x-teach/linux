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

**Debrief.** Model answer:
> `ls` showed nothing because it omits entries whose names begin with a dot unless asked.
> `du` showed forty megabytes because it counts blocks on disk and the dot rule is an `ls`
> convention, not a filesystem one.
> The forty megabytes is one file, `ballast.bin`, 41926656 bytes of a single repeated character.
> A filename is just a sequence of bytes — any byte except `/` and NUL — so it can hold characters
> that are invisible when printed and impossible to type.
> For cass: nothing lied. `ls` and `du` answer different questions, and the name was chosen so
> that the difference between those questions would hide something.

## Added exercises 20–52

**20.**
```
$ ls -ab maintenance
.a\ name\ you\ cannot type\ 

$ LC_ALL=C ls -ab maintenance
.a\ name\ you\ cannot\302\240type\ 
```
The flag never changed; the **locale** did. In a UTF-8 locale, U+00A0 is a perfectly printable
character, so `ls -b` has nothing to escape and prints it — as a space-shaped blank. Under
`LC_ALL=C` there is no multi-byte interpretation, the two bytes are not printable ASCII, and `-b`
escapes them as `\302\240`.

**21.**
```
$ ls -aN maintenance | cat -A
.a name you cannotM-BM- type $
```
`M-BM- ` is `cat -A`'s notation for the two bytes `0xC2 0xA0` — the UTF-8 encoding of U+00A0 NO-BREAK
SPACE. (`M-B` is `0xC2`, `M- ` is `0xA0`.) The final `$` sits one column right of `type`, which is the
trailing space.

**22.** **25 bytes, 24 characters.** The visible text `.a name you cannot type ` is 24 characters
counting the leading dot and the trailing space; one of those characters, the no-break space, is
encoded in two bytes, so the byte count is one higher. Every tool that "counts the name" is answering
one of these two questions and rarely says which.

**23.**
```
$ LC_ALL=C ls -a --quoting-style=shell-escape maintenance
'.a name you cannot'$'\302\240''type '
```
Paste that after `cd ` and `pwd` confirms arrival. The two things it handled: the **trailing space**,
which sits inside the closing quote and so cannot be eaten by word splitting, and the **no-break
space**, emitted as `$'\302\240'` — bash syntax for those exact two bytes. Without the `LC_ALL=C`
prefix the same option prints `'.a name you cannot type '`: still pasteable, but with the no-break
space rendered as itself and therefore invisible.

**24.** Two independent proofs:
- `ls -ab maintenance` ends the line with `\ ` — a backslash-escaped space, which `ls` would not have
  emitted for a space that was not part of the name.
- `stat -c '%N' maintenance/.a*` → `'maintenance/.a name you cannot type '`; the closing quote is
  one column after `type `, so the space is inside the name.

**25.** Typing `cd .a` and pressing Tab completes to `cd .a\ name\ you\ cannot\ type\ ` — bash escapes
the spaces for you, including the trailing one, and leaves the cursor at the end. **Pressing Enter
there fails.** Bash completed from the directory entry, but what it wrote for the no-break space was
either the literal byte pair or an escaped space, depending on your readline settings, and in the
common case you end up with a command line that renders identically to a working one and is not.
This is why the exercise asks you to record what appeared rather than whether it worked.

**26.**
```
$ cd maintenance/.a*
$ pwd
/labs/02-navigating-the-filesystem/07-incident-02/maintenance/.a name you cannot type 
```
**Bash** expanded the pattern, by reading the directory and comparing entries — as bytes — against
`.a*`. It then passed the matching name to `cd` as a single already-formed argument. The name never
went through the tokeniser as text you typed, so no quoting was needed and no character had to be
representable on a keyboard.

**27.**
```
$ ls -l /proc/self/cwd
lrwxrwxrwx 1 cadet cadet 0 … /proc/self/cwd -> /labs/…/maintenance/.a name you cannot type 
```
`pwd` (the builtin) prints `$PWD`, a string the shell maintains. `/proc/self/cwd` is a symlink the
**kernel** materialises from the process's actual current directory. When the name itself is the thing
under suspicion, an answer from the kernel beats an answer from a shell variable.

**28.**
```
$ ls -l  → 41926656
$ stat -c %s → 41926656
$ wc -c  → 41926656
$ wc -l  → 0
```
Zero lines. `wc -l` counts newline **characters**, and the file contains 41926656 `e` bytes and not a
single newline. A file with no newline in it has zero lines by that definition even though it has
content — the same reason `file` reported "with no line terminators".

**29.**
```
$ head -c 32 ballast.bin | cat -A
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
```
It is 40 MiB of the letter `e`. `file` was not wrong: every byte is printable ASCII, so "ASCII text"
is a true description. `file` reads a few hundred bytes from the front and describes what it finds;
it does not, and cannot, tell you the file means nothing.

**30.** `file -i ballast.bin` → `text/plain; charset=us-ascii`. A program deciding whether to open it
would conclude "a text file, safe to load into a buffer" and then try to load 40 MB of a single line
into an editor. The MIME type describes the bytes' *form* and says nothing about size, structure or
whether the content is meaningful.

**31.**
```
$ du -ab maintenance/.a*
0         .keep
687       audit-notes.txt
41926656  ballast.bin
41927343  <the directory>
```
0 + 687 + 41926656 = 41927343 — the total **exactly**. So `du -b` charges nothing for the directory
entry itself: with `--apparent-size` (which `-b` implies), a directory's own apparent size is reported
as 0 in this image, and the total is purely the sum of the files.

**32.**
```
$ du -s --block-size=1 maintenance  → 41943040
$ du -sb maintenance                → 41927343
difference                            15697 bytes
```
`--block-size=1` still counts **allocated blocks**, just expressed in bytes: 41943040 = 40960 KiB.
`-b` counts **apparent bytes**. The difference is `ballast.bin` rounded up to a block boundary plus a
full block for each of `audit-notes.txt`, `.cache` and the two directories. The blocks figure answers
"how much would I free by deleting this"; the apparent figure answers "how much would I have to copy
over the network".

**33.** `tree -a --du -h maintenance` → `40M used in 3 directories, 3 files`, agreeing with
`du -sh maintenance` at this rounding. They agree because one file dominates: 40 MiB swamps the
block-rounding differences that made lesson 5's `manifest` disagree by 23K. Round to the megabyte and
apparent size and allocated size converge; the disagreement lives in the small files.

**34.** `df -h /labs` reports a 358G filesystem, 273G used, 68G available, 81% full. The 40M is about
**0.01%** of it — nothing. But cass was not reporting a capacity problem: she reported that `ls` and
`du` disagreed about a directory, which is a *correctness* alarm, and correctness alarms do not scale
with size. She was right to raise it and would have been right at 40K.

**35.**
```
$ tree maintenance
maintenance

0 directories, 0 files

$ tree -a maintenance
maintenance
├── .a name you cannot type 
│   ├── .keep
│   ├── audit-notes.txt
│   └── ballast.bin
└── .cache

3 directories, 3 files
```
One rule: **`tree`, like `ls`, skips names beginning with a dot unless given `-a`** — and because both
of `maintenance`'s children are dotted, the skip is total. The count line is not a filesystem fact; it
counts what was printed.

**36.**
```
$ du -sh .cache               → 4.0K
$ du -sb .cache               → 0
$ du -s --block-size=1 .cache → 4096
```
It is both. The directory holds no entries other than `.` and `..`, so its apparent size — the bytes
you would have to copy — is 0. But a directory is itself an object with a data block, and the
filesystem allocated 4096 bytes to hold the entry list, empty or not. `-h` and `--block-size=1` report
that allocation; `-b` reports the content.

**37.** `du --inodes -s .` → **4**. Three files (`ballast.bin`, `audit-notes.txt`, `.keep`) plus the
directory itself. The directory is the one that is not a file you listed, and it is why the number is
not 3.

**38.**
```
$ cat maintenance/.a*/audit-notes.txt
audit, deck 3, continued
…
```
It works with no quoting. Same mechanism as exercise 26: bash expands `maintenance/.a*/audit-notes.txt`
by matching directory entries as bytes, and hands `cat` one finished argument. Globbing is the general
escape hatch for an untypeable name — the pattern only has to match, not reproduce.

**39.** `cd ..` then `ls` shows nothing (both children are dotted); `ls -a` shows `.cache` and the
stowaway. `cd -` returns you to the stowaway directory and prints its path. What `cd -` had stored is
`$OLDPWD` — the exact byte string, no-break space and trailing space included, which you could not
have retyped.

**40.**
```
$ stat -c '%N' maintenance/.a*
'maintenance/.a name you cannot type '
```
A reader still cannot determine **which bytes** the blanks are. `%N` quotes for display: it shows you
where the name starts and stops, so the trailing space is provable, but a no-break space inside single
quotes looks exactly like a space. To find out, run exercise 20's `LC_ALL=C ls -ab` or exercise 21's
`ls -aN | cat -A`.

**41.**
```
audit-notes.txt   2187-05-15 23:41:00
ballast.bin       today, the moment the lab was seeded
```
Read naively: the notes were written 160 years before the ballast, so the notes came first. That
conclusion is worthless. `touch -d` sets an mtime to any value at all, and the 2187 date is exactly
the kind of value nobody sets by accident — it is *stated*, not *observed*. An mtime is a claim stored
in the inode, and the only thing it proves is that something wrote that claim.

**42.** Both files' **ctime** is the moment the lab was seeded, minutes ago. mtime is settable by any
process that owns the file; ctime is set by the kernel whenever the inode changes and there is no
interface to forge it. **The ctime goes in the incident report** ("this inode was last modified at
…"), the mtime goes in a footnote ("the file claims a modification date of 2187-05-15").

**43.** `.cache` is inode 300225 and the stowaway is 300226 — consecutive, `.cache` first, which is
the order `setup.sh` created them in. The suggestion bears very little weight: inode numbers are
allocated by the filesystem from whatever is free, they are reused after deletion, and on a busy
filesystem two directories created a second apart can land anywhere. It is a hint to check against
timestamps, never evidence on its own.

**44.** `du -sh overnight` → 24K; `NOTES` reads `nothing unusual overnight.` It is in the lab because
it is the obvious place to look: a visible, plausibly-named directory of logs, sitting beside the
problem, containing nothing. Starting there would have cost you the time it takes to read four run
logs and conclude they say what they say.

**45.** The sentence is:
> the summariser is the only thing that touches both.
The file records a discrepancy between a maintenance log and a strain series, three enumerated
explanations, one of them checked and eliminated, and a decision to keep a copy before raising it. It
does not say who wrote it and neither should you.

**46.** The copy is `ballast.bin` — the only thing in the lab that could be a bulk copy of anything.
And the lab does **not** give you enough to say what it is a copy of: it is 40 MiB of a single
repeated byte, which is not a copy of any data at all. To settle it you would need the summariser's
output to compare against, the series the notes mention, and a tool that can search file contents —
none of which Chapter 2 has given you.

**47.**
```
ls -ab                                   .a\ name\ you\ cannot type\ 
LC_ALL=C ls -ab                          .a\ name\ you\ cannot\302\240type\ 
LC_ALL=C ls -a --quoting-style=shell-escape   '.a name you cannot'$'\302\240''type '
stat -c %N                               '.a name you cannot type '
```
Ranked by byte-recoverability, best first: **`LC_ALL=C` `shell-escape`** and **`LC_ALL=C ls -ab`**
(both name every non-ASCII byte in octal), then **`ls -ab`** (proves the spaces and the trailing
space, hides the no-break space), then **`stat -c %N`** (proves only the boundaries).

**48.** **`LC_ALL=C ls -a --quoting-style=shell-escape`.** `LC_ALL=C ls -ab` names the bytes but its
bare backslash escapes are not bash syntax, so it fails the paste test. `ls -ab` under UTF-8 fails the
byte test. `stat -c %N` pastes safely enough but fails the byte test too, and would not survive a name
containing a single quote.

**49.** A name containing ESC would have had those bytes written straight to your terminal by `-N`:
the terminal would have obeyed them, and the name could have repositioned the cursor to overwrite the
line above, or coloured itself to look like a different entry. `ls` defaults to `-q` on a terminal —
every non-printable byte becomes `?` — which is what makes that attack awkward. It is also what made
this investigation awkward: the default silently replaces the evidence with a question mark, and the
no-break space is printable anyway, so neither the default nor the safety flag would have shown you
the problem. You had to ask for the bytes.

**50.**
1. `ls -a <dir>` — establish that the entry exists and roughly what it looks like.
2. `LC_ALL=C ls -ab <dir>` — get every non-ASCII byte in octal.
3. `ls -aN <dir> | cat -A` — confirm the byte pairs and locate any trailing whitespace against the `$`.
4. `stat -c '%N' <dir>/<glob>` — get the boundaries, and a form you can paste after `cd`.

**51.** A flag in a file could have been reached by anyone who got into the directory — one `cat` and
you are done, and the exercise would have been "find the hidden directory". Making the **name** the
flag means you cannot finish without reading it byte by byte and deciding what each byte is. The
property that would have been lost is the one the whole incident is about: that seeing a name and
knowing a name are different things.

**52.** A directory listing is a *rendering*: it takes the bytes the filesystem stores and draws them
in your locale, on your terminal, under whatever quoting rules are in force, and every stage of that
can lose information. What you can type is narrower still — a keyboard produces a small subset of
legal filename bytes — so "I can see it and I cannot reach it" is not a paradox but the normal
relationship between the three.

---

## Notes for the authoring/tutor agent

- `file` on `ballast.bin` says "ASCII text" rather than "data" because it is printable characters.
  Students who expected binary are right to be surprised; it is filler, and nothing more.
- `du --apparent-size` reports directory entries as 0 in this image, which is what makes the 15697
  arithmetic close. If a student's numbers differ, have them check they ran `-B1` and not `-h`.
- `audit-notes.txt` is **trace 2** of the sabotage arc (`_handoff/SCENARIOS.md`, 2187-05-15). It is
  dorn's. The chapter never says so and no agent may say so. It is read again in Chapter 15.
