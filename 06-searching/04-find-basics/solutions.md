# 06/04 — Solutions: `find` Basics

Measured in the container (GNU findutils 4.11.0). Students must not read this file.

## The walk

**1.** **44** lines. The first is `.` — the starting path itself, which `find` evaluates like any
other entry. `find` prints what it is given before it prints what is inside it.

**2.** 44 again. `-print` is the default action: when the expression contains no action, `find`
appends one. The two commands are identical, not similar.

**3.** 21 + 20 + 3 = **44**. Exactly the total, because every entry in this tree is a regular file, a
directory or a symlink — and because `find` visits each entry once, whatever it is. On a real
filesystem the sum can be short by a fifo, socket or device node.

**4.** `-maxdepth 1` → `.`, `archive`, `decks`, `links`, `reports`, `scratch` — six lines, the
starting path plus its immediate children. `-maxdepth 0` → `.` alone: the starting paths and nothing
under them.

**5.** 43. It removed `.`, the starting path itself. `-mindepth 1` is the idiom for "everything
inside, not the thing itself".

**6.** `.` — GNU `find` defaults the path when the first argument looks like an expression. POSIX
requires a path, so this is a **GNU extension**; scripts should write `find . …`.

**7.**
```
find: ‘nosuch’: No such file or directory
```
status **1**. Note `find` keeps going through any other starting paths and only reports failure at
the end.

**8.** It prints `reports/index.txt` and exits 0. A file as a starting path is evaluated against the
expression and that is all. Useful for applying the same test to an explicit list of paths — `find
"$@" -type f …` — which is how `find` gets used inside scripts.

## `-name`

**9.** `links/latest.log` and `links/broken.log` — both symlinks. `latest.log` points at a real log,
so by content it is one; `broken.log` points at nothing. Neither is a *file* that holds log lines,
which is precisely what `-type f` asked.

**10.** `decks/deck-03/bay-01/strain-02.LOG`. Upper case; the index says case is not enforced
because some bays were set up by hand.

**11.** `-name` compares against the **base name** and the glob must match the whole of it. `*.log`
ends at `g`; the tilde is an extra character with nothing left in the pattern to consume it. Both:
`-name '*.log*'` (also matches `.log.gz`) or `-name '*.log' -o -name '*.log~'`.

**12.** `-name '*.log'` gives 13, which includes two symlinks and excludes `strain-02.LOG`. Neither
number is "how many logs". `-name` tests a naming convention; whether a name means what it claims is
a question about the people who typed it.

**13.** `-name` never sees a slash — it is handed one path component. A pattern containing `/` cannot
match any base name, so the answer is always zero and it is always silent. `-path` is the predicate
for that question.

**14.** `find . -path './decks/deck-03/*'` → 10; `find decks/deck-03` → 11 (it includes the starting
directory itself). In a script, **change the starting path**: it is faster (no walk of the other
decks), it does not depend on how the path was spelled, and it cannot be defeated by a symlink
elsewhere in the tree whose path happens to match.

**15.** `./decks/deck-03/bay-02/readings` (a file) and `./decks/deck-04/readings` (a directory).
`cat` on the directory gives `cat: …/readings: Is a directory` and exit 1 — and in a loop with `2>
/dev/null` you would simply lose one of them silently.

**16.** `.` and `./decks/deck-03/.hidden-notes`. The surprise is `.`: the starting path's base name
is literally `.`, and `.*` matches it.

**17.** `find . -name '.hidden-notes'` finds it from a shell where `echo .h*` also expands — but the
decisive proof is `find decks/deck-03 -maxdepth 1 -name '*'`, which lists `.hidden-notes` even though
`ls decks/deck-03` does not. `find` has no dotglob concept; the shell's rule never applies to it.

**18.** `find . -name '-*'` → `./decks/deck-05/-summary.txt`. Nothing special needed. In lesson 01
the problem was `grep`'s **option parser** seeing a leading dash in an argument position; here the
dash is inside a quoted pattern that is the argument to `-name`, so the parser has already decided
what this word is.

## The quoting trap

**19.** It works because there is no `*.log` in the lab root, so the shell finds no match and (with
default `nullglob` off) passes the pattern through untouched. It worked by luck, and the luck is a
property of the directory you happened to be in.

**20.** In `scratch/` the glob expands to the single existing name, so the command becomes `find .
-name strain-01.log`. It searched for that literal name and printed it. Dangerous because the answer
looks right: you asked for all logs, you got a subset, and there is no error, no warning and nothing
in the output that says a pattern was substituted.

**21.**
```
find: paths must precede expression: ‘panel-09.log’
find: possible unquoted pattern after predicate ‘-name’?
```
The glob expanded to two names; the second landed where `find` expects nothing.

**22.** The **wrong answer** (exercise 20) is worst — the error is loud and the accidental success is
harmless. The habit: quote the pattern. Single quotes, every time, even when it looks unnecessary.

**23.** Yes, identically — `-path` takes a glob as an argument like any other word, and the shell does
not know or care which predicate the word belongs to. `mkdir -p scratch/a; touch 'scratch/a/x.log';
cd scratch; find . -path *a*` behaves the same way. Nothing about `find` is involved; the shell
expands first.

## `-type`

**24.** `links/broken.log`. A symlink is a file in its own right — it has an inode and holds a path
as its content. Whether that path resolves is a separate question, which `-type l` does not ask.

**25.** `-L` makes `find` follow symlinks, so `links/deck-03` stops being one entry and becomes the
whole deck-03 subtree, walked again under a second set of names. Nine results. Note this is how a
symlink loop turns a `find` into an infinite one; `-L` detects cycles, but the duplicate results are
real.

**26.** Under `-L` a broken link cannot be resolved, so `find` falls back to reporting it as itself:
`find -L links -type l` still prints `links/broken.log`. That fallback is exactly what makes `-L`
plus `-type l` a useless test for "broken links" and `-xtype l` the right one.

**27.** `-type l` asks what the entry is; `-xtype l` asks what its target is — so under the default
(no `-L`) it is true only for links whose target is missing or is itself a link.

**28.** Without the slash, `links/deck-03` is a symlink and `find` does not follow it: one entry. With
the trailing slash the kernel resolves the link when `find` opens the path, so `find` is walking a
directory. The trailing slash is a request to resolve, the same rule as in Chapter 4's `cp`.

**29.** The comma lets `-type` take several type letters at once — `f,d` is `f` or `d` without needing
`\( -o \)`. Missing from 44: the three symlinks. 41 + 3 = 44.

**30.** `decks/deck-04/empty` and `decks/deck-05/bay-03/empty`. No empty files, because every file
`setup.sh` created got content. `-empty` is one predicate that means two different things depending
on `-type`: no entries, versus zero bytes.

## Depth

**31.** Eleven: `.`, `archive`, `archive/2187-05`, `archive/2187-06`, `decks`, the three `deck-0N`, and
`links`, `reports`, `scratch`. All the `bay-NN` directories are at depth 3 (`./decks/deck-03/bay-01`)
and are cut.

**32.** `./links/broken.log`, `./links/latest.log`, `./scratch/strain-01.log` — each has two slashes
after the leading `./`, i.e. one directory between the start and the file. Depth counts components
below the starting path, not slashes in the absolute path.

**33.** Identical output, both three lines. `-maxdepth` is a global option and applies wherever it is
written.

**34.** Because the habit generalises and the result does not. `-prune`, `-depth` and the action
predicates *are* position-sensitive, and a reader scanning a long `find` line needs the scope of the
walk stated before the filters. Also: the two forms are only equivalent because this `find` accepts
the late option; a different implementation may warn, error, or in the case of `-depth` change the
answer.

**35.** `find . -mindepth 3 -name '*.log' | wc -l` → **10**. Check: `-maxdepth 2` gives 3, and
3 + 10 = 13, the total. The two bounds partition the tree at the same place, so the counts must sum;
a student whose numbers do not sum has an off-by-one in one of the bounds and can find it without
being told which.

**36.** The lab root contains no regular files at all — only directories. For deck-03 the same
question is `find decks/deck-03 -maxdepth 1 -type f | wc -l` → 4 (`.hidden-notes`, `panel-03.log`,
`panel-03.log~`, `panel-09.log`).

## Combining tests

**37.** `.hidden-notes`, `strain-02.LOG`, `readings`, `panel-03.log~`, `raw.txt`, `-summary.txt`,
`bay 03 notes.txt`, `strain-01.txt`, `handover.txt`, `index.txt`. `strain-02.LOG` is a log by
content and by convention and is excluded purely by case; `panel-03.log~` and `strain-01.txt` are
also arguable.

**38.** 19.

**39.** Grouped gives fewer — the student should predict 17 and be able to say why before running it.

**40.** `links/latest.log` and `links/broken.log`. The ungrouped expression means
`(-name '*.log') OR (-name '*.txt' AND -type f)`: `-a` is implicit between adjacent tests and binds
tighter than `-o`, so `-type f` attaches only to the `.txt` branch and the `.log` branch is
unfiltered.

**41.** `find . -path '*/bay-01/*' -type f -iname '*.log'` → **4**:
`decks/deck-03/bay-01/strain-01.log`, `decks/deck-03/bay-01/strain-02.LOG`,
`decks/deck-04/bay-01/strain-01.log`, `decks/deck-05/bay-01/Strain-01.log`. A student who answers 3
has silently dropped `strain-02.LOG`, which is exactly the hit `-iname` was for.

**42.** `find decks ! -path 'decks/deck-03*'` or `find decks/deck-04 decks/deck-05`. The second is
faster and cannot be fooled by a path spelled differently; the first survives a caller who only hands
you one starting path.

**43.** The printed paths begin with the starting path exactly as you typed it — `decks/deck-03/…`
and `decks/deck-04/…`, no `./`. So the output of two runs with differently spelled starting paths
does not sort together, and any script that dedupes or joins on these strings has to normalise
first.

## Beyond globs

**44.** It misses `decks/deck-05/bay-01/Strain-01.log` (upper-case S) and
`decks/deck-03/bay-01/strain-02.LOG` (upper-case extension, and `0[12]` would have matched the `02`).
`-regex` has no `-i`; the case-insensitive form is `-iregex`.

**45.** The default is **emacs** regular expressions (a GNU dialect). `-regextype posix-extended`
switches to ERE, which is what makes `(panel|strain)` and `+` work without backslashes — exactly the
BRE/ERE distinction from lesson 03, exposed as a `find` option instead of a `grep` flag.

**46.** `find . -regex 'strain-01\.log'` → nothing, because `-regex` must match the **entire path**
(`./scratch/strain-01.log`), not a piece of it. `find . -regex '.*strain-01\.log'` finds four. Unlike
`grep`, `-regex` is implicitly anchored at both ends.

**47.** `-regex` when the condition genuinely spans path components (`.*/bay-0[13]/.*\.log`) or when
you are inside a script that must not spawn a second process per hundred thousand paths. `-name` plus
`grep` when the pattern is easier to read that way or you already have it in a variable. The cost of
the pipe: it turns structured results into a byte stream split on newlines, so any filename
containing a newline is silently split into two wrong paths — which is why the next lesson's
`-print0` exists.

## Experiment

**48.** `mkdir scratch/fake.log; find scratch -name '*.log'` returns the directory alongside the
file. Fix: add `-type f`. This is not hypothetical — bundle and package directories with extensions
are common.

**49.** `touch $'scratch/two\nlines'; find scratch | wc -l` counts the newline as a line break, so the
count is one too high and one of the "paths" is a fragment. `-name '*'` does not help — the damage is
in `find`'s output format, not its matching. The honest count is `find scratch -printf '.' | wc -c`
or `find scratch -print0 | tr -dc '\0' | wc -c`.

**50.** Both find it; `/labs` is near-instant and `/` takes noticeably longer (order of a second here
versus a few milliseconds). `find` spends its time on `opendir`/`readdir`/`stat` for every directory
under the starting path — the work is proportional to the size of the tree walked, not to the number
of matches.

**51.** `-name ''` matches nothing (no base name is the empty string), status 0. `grep ''` matched
**every** line, because the empty regex matches at every position. Opposite results from the same
looking argument: `-name` is a whole-string glob comparison, `grep`'s pattern is a substring search.

**52.** `touch scratch/x1 scratch/sub-x2` inside `scratch/sub/`: from `scratch/`, `ls x*` lists only
what is in `scratch/` while `find . -name 'x*'` descends. Neither is wrong — `ls` was asked about one
directory and `find` about a tree. Accept any construction that makes the recursion the difference.

## Stretch

**53.** 12. `-prune` tells `find` not to descend into the matched directory; the `scratch` entry
itself is still visited and, because `-prune` is true, the `-o` short-circuits and the entry is not
printed. `-print` is required because as soon as you write **any** action in the expression, `find`
stops adding the implicit one — without it, the whole command prints nothing at all.

**54.** Default is pre-order: a directory is reported before its contents. `-depth` is post-order:
contents first. Anything that removes or renames a directory needs post-order, which is why `-delete`
implies `-depth` — you cannot unlink a directory you are still walking.

**55.** `(-name '*.log') OR (-print)`. For a `.log` the first test succeeds, `-o` short-circuits, and
**nothing is printed** — but the expression contains an action, so the implicit `-print` is gone too.
So it prints every entry that is *not* named `*.log`: 44 − 13 = **31**. The reason it is not simply
"everything that is not a log" is that the count depends on the short-circuit and on the implicit
action disappearing, and swapping the two operands changes the answer to 44.

**56.** For example:
```
find . -name '*.log' | wc -l                                   # 13
find . -type f -exec grep -l 'strain 0\.' {} + | wc -l         # 14
find decks -type f | wc -l                                     # 16
```
Three defensible answers to one question. The number to hand over is **none of them alone** — the
answer is "define log first", and the handover file says so. (`-exec` is next lesson; a student who
reaches for it early has read ahead, which is fine.)

## Dig

**57.** Only the **path** distinguishes them — `archive/2187-05/` versus `archive/2187-06/` — and in
this lesson that means `-path`. Base name, depth and type are identical. To tell them apart by
content you need something that reads bytes: `grep`, or `cmp`, or the size and mtime predicates in
lesson 05. The general point: `find` classifies by metadata and name; it never opens a file.

**58.** `find . -name '*.log' ! -name 'panel-[0-9][0-9].log' ! -name 'strain-[0-9][0-9].log'` gives
`links/latest.log`, `links/broken.log` and `decks/deck-05/bay-01/Strain-01.log`. The first two are
not naming mistakes at all — they are symlinks, a different kind of thing that happens to end in
`.log`. The third is a genuine mistake: a hand-made bay with a capital S. `panel-03.log~` does not
appear, because the filter that found these already excluded it by extension — a second, invisible
convention.

**59.** Three, from the measurements:
- `strain-02.LOG` — a real log that `-name '*.log'` never sees: **false negative**, it never gets
  rotated and grows forever.
- `links/broken.log` — matched as a log, but deleting it removes a dangling name and no data; and
  `links/latest.log`, if resolved with `-L`, deletes the *target*: **false positive**, and the
  destructive kind.
- `decks/deck-04/readings` — if the command was written with `-name readings` or without `-type f`,
  a directory reaches `rm`; with `-r` in the recipe that is a subtree. **False positive.**
Also acceptable: `panel-03.log~` (deliberately kept, would be swept) and `bay 03 notes.txt` (a space
that breaks any unquoted `$(find …)` loop).

## Authoring notes

- Counts: total 44, f 21, d 20, l 3; `-name '*.log'` 13, `+ -type f` 11, `-iname` 14; `-name '*.txt'`
  6; ungrouped `-o` 19 vs grouped 17; `-name '*.log' -o -print` 31; prune 12; `-type f,d` 41.
- `find` 4.11.0 emits **no warning** for `-maxdepth` written after a test. An earlier draft of the
  readme claimed it did; measured, it does not, and exercise 34 was rewritten around that.
- Exercise 41's answer is 4, not 3 — `-iname` catches `strain-02.LOG`, which is also under `bay-01`.
  This is the exercise most likely to be marked wrong by a careless validator.
- Exercise 35: `-maxdepth 2` 3 + `-mindepth 3` 10 = 13. The two bounds partition; the sum is the
  check the exercise is really asking for.
- The three symlinks in `links/` carry most of the lesson's weight (exercises 9, 24–28, 58, 59).
  Do not remove `broken.log`.
