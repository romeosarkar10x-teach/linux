# 05/01 — Solutions (agent eyes only)

> **Student: do not open this file.** It contains every answer, and the whole lesson is the habit of
> testing a pattern with `echo` instead of being told what it matches.

Every result below was measured in the container image (bash 5.2.21, `LANG=C.UTF-8`).

## The lab

`panels/` has fourteen entries: ten `panel-NN.log` (01–06, 08, 10, 11, 12), plus `panel-7.log`
(one digit), `PANEL-09.LOG` (upper case), `panel-03.log.bak`, `.panel-00.log`.
`readings/` has thirteen: twelve `2187-05-DD-{0800,1600}.txt` for DD 15–20, plus
`2187-05-17-1600.txt.partial`. `mixed/` has eleven names chosen to break patterns. `deep/` is a
three-level tree with a symlink `deck-03/archive-link -> ../archive` and a hidden
`deck-03/.private.txt`. `empty/` is empty.

## Warmup

**1.** Same names, same order, different layout. `ls` prints one per line into a pipe / in columns to
a terminal; `echo` prints them space-separated on one line. **Both orderings come from different
places:** `ls` sorted its own output, while for `echo *` the *shell* sorted the expansion and `echo`
just printed its arguments in the order given. Both agree here because both use the same collation.

**2.** `echo *.log` → the eleven lowercase `.log` names. `ls *.log` received exactly those eleven
names as eleven separate arguments:
`panel-01.log panel-02.log panel-03.log panel-04.log panel-05.log panel-06.log panel-08.log
panel-10.log panel-11.log panel-12.log panel-7.log`. Note `panel-7.log` sorts *last*: `7` (0x37) is
greater than `1` (0x31).

**3.** `echo *.zip` → `*.zip`. `ls *.zip` → `ls: cannot access '*.zip': No such file or directory`,
exit 2. Nothing matched, so the shell passed the pattern through unchanged and `ls` was asked about
a file literally named `*.zip`.

**4.** `ls *.log | wc -l` → **11**; `ls | wc -l` → **13**. The difference is `PANEL-09.LOG` (case)
and `panel-03.log.bak` (does not end in `.log`). `.panel-00.log` is in neither count — `ls` hides it
too.

## Core

**5.** `panel-7.log`, `PANEL-09.LOG`, `panel-03.log.bak`, `.panel-00.log`.

**6.** Ten. Misses `panel-7.log` (`??` is exactly two characters, `7` is one), `PANEL-09.LOG` (case),
`panel-03.log.bak` (the pattern ends at `.log`), `.panel-00.log` (leading dot).

**7.** `panel-0?.log` → 01–06 and 08 (seven). `panel-1?.log` → 10, 11, 12 (three). Together ten. In
neither: `panel-7.log`, `PANEL-09.LOG`, `panel-03.log.bak`, `.panel-00.log`.

**8.** Result: **`panel-7.log` only.** `[0-9]` matches *exactly one* character, same as `?`, so the
pattern describes a one-digit panel number. Nobody predicts this because `[0-9]` reads as "a number".

**9.** Several work. Measured: `panel-*[0-9].log` gets all eleven lowercase but misses the uppercase
one. Two patterns is the honest answer — `echo panel-*[0-9].log PANEL-09.LOG` — but a single pattern
exists: `[Pp][Aa][Nn][Ee][Ll]-*[0-9].[Ll][Oo][Gg]`, which returns all twelve and excludes
`panel-03.log.bak` (ends `.bak`) and `.panel-00.log` (leading dot). Accept anything that produces
exactly twelve names.

**10.** `panel-03.log.bak`. `*.log` requires the name to *end* in `.log`; `*` matches any string
including the empty one, but only at the position it occupies — there is nothing after `.log` in the
pattern for `.bak` to match against.

**11.** `PANEL-09.LOG` only. Every other visible entry begins with `p`. `[!p]` matched the `P` —
capital P is a different byte from lowercase p. `.panel-00.log` is excluded by the dot rule, not by
the bracket.

**12.** Upper only: `PANEL-*.LOG` (or `[[:upper:]]*`). Either case:
`[Pp][Aa][Nn][Ee][Ll]-*.[Ll][Oo][Gg]` → twelve names, uppercase first (`P` = 0x50 < `p` = 0x70).

**13.** `nocaseglob` is **off** by default. On, `echo panel*` returns twelve including
`PANEL-09.LOG` and `panel-03.log.bak`; off, eleven (uppercase excluded). A script relying on it
breaks because `shopt` state is per-shell and not inherited — the next person's shell has it off,
and the same script then quietly processes a different set of files.

**14.** `echo .*` → `.panel-00.log`. With `shopt -u globskipdots`, `.* ` → `. .. .panel-00.log`.
`globskipdots` is **on** by default in bash 5.2 and excludes `.` and `..` from every glob.

**15.** `rm -rf .*` used to expand to include `..`, so it recursed into the *parent* directory and
deleted everything beside your home directory as well. `globskipdots` removes `.` and `..` from the
expansion, so on bash 5.2+ that specific disaster no longer happens. It is still a terrible command
— `.*` on an older bash, or in another shell, still does the old thing.

**16.** `dotglob` adds `.panel-00.log` in `panels/` and `.cfg` in `mixed/`. It is a **shell
convention**: the filesystem stores `.cfg` like any other name, `stat` and `find` see it without any
special flag, and only the shell's pathname expansion and `ls` apply the rule. Evidence:
`find . -name '.*'` and `ls -a` both show it with no shopt involved.

**17.** `.panel*` — or `.p*`, or `.*log`. Any pattern with an explicit leading dot.

**18.** `-d` tells `ls` not to descend into arguments that are directories — here it mostly stops
`ls` from being clever about ordering and columns; it matters when a match is a directory.
`[135]` is a **set** of three characters, not a range: it matches `1`, `3` or `5`. Result:
`panel-01.log panel-03.log panel-05.log`.

**19.** Both patterns give the same ten names. Inside brackets, `-` between two adjacent characters
makes a range of exactly those two, so `[0-1]` and `[01]` are the same set. `-` is only special
*between* two characters; first or last in the bracket it is a literal dash (`[-a]`, `[a-]`).

**20.** Both give 11 here. `printf '%s\n'` prints one argument per line, so the count is the number
of *arguments the shell produced*. `ls | wc -l` counts lines of `ls` output, and a filename
containing a newline becomes two lines — so the count is of lines, not of files. `ls` also
*descends* into a matched directory unless you pass `-d`, which inflates the count further.

**21.** Thirteen files. The series is `2187-05-DD-{0800,1600}.txt` for DD = 15…20, twelve files. The
odd one is `2187-05-17-1600.txt.partial`.

**22.** `*17*.txt` (or `2187-05-17-*.txt`) → the two 05-17 extracts. `*-0800.txt` (or
`2187-05-*-0800.txt`) → six.

**23.** `2187-05-1[56]-*.txt` → four.

**24.** `*.txt` → 12. `*.txt*` → 13. The extra one is `2187-05-17-1600.txt.partial`: it *contains*
`.txt` but does not end with it. Somebody appended a suffix to a finished filename rather than
changing it.

**25.** `2187-05-1[5-9]-*.txt` → **10** (days 15–19; day 20 has a `2` where the pattern demands `1`).
`2187-05-[12][05]-*.txt` → **4**: `2187-05-15-*` and `2187-05-20-*`. The surprise is that the two
bracket sets combine independently — the pattern means "first digit 1 or 2, second digit 0 or 5",
which describes 10, 15, 20 and 25, not "15 or 20".

**26.** `grep -l 'strain 0.47' *.txt` → `2187-05-17-0800.txt`, `2187-05-17-1600.txt`. No glob could
select these: a glob is matched against the **name** by the shell, which never opens the file. The
name does not record the strain value.

**27.** Example: `2187-05-1?-*.txt` and `2187-05-1[5-9]-*.txt` both return the same ten files today.
A file `2187-05-1X-0800.txt`, or `2187-05-14-0800.txt`, splits them. Put the explicit one in a
script — `?` says "any character here", which is a weaker claim than you usually mean.

**28.** Measured:
```
2187-05-20-0800.txt
2187-05-20-1600.txt
ls: cannot access '2187-05-3*': No such file or directory
```
Exit status **2**. `ls` listed the two files the second pattern matched *and* complained about the
literal `2187-05-3*` it was handed for the first. (The error appears after the names because it goes
to stderr while the names go to a buffered stdout — the order is not meaningful, the exit status is.)
One command, a partial success and a nonzero exit, which is exactly what a script checking `$?` will
misread.

**29.** Measured in `mixed/`:
- `*` → 10 names (everything except `.cfg`)
- `*.txt` → `-dash.txt 1st.txt A.txt [set].txt a.txt star*.txt two words.txt what?.txt` (8)
- `?.txt` → `A.txt a.txt`
- `*~` → `notes.txt~`
- `[a-z]*` → `a.txt notes.txt~ star*.txt two words.txt what?.txt` (5)
- `[[:upper:]]*` → `A.txt README`
- `[[:digit:]]*` → `1st.txt`

**30.** `printf '%d\n' "'A" "'a" "'-" "'1" "'["` → 65, 97, 45, 49, 91. The range `a`–`z` is 97–122,
so only `a` (97) is inside it. `A` (65), `-` (45), `1` (49) and `[` (91) are all below it. `README`
and `[set].txt` are excluded for the same reason as `A.txt`: their first byte is under 97.

**31.** `[[:lower:]]*` gives the same five names here as `[a-z]*`. The difference is portability:
`[[:lower:]]` asks the locale "is this a lowercase letter", which is the question you meant, while
`[a-z]` asks "is this byte inside the collation range from a to z", which on `en_US.UTF-8` also
catches `A` (that locale interleaves `aAbBcC…`). Write `[[:lower:]]` in anything somebody else will
run.

**32.** `echo star*.txt` prints `star*.txt`, and the interesting part is that the output is the same
whether the file matched or not. The distinguishing test: run the identical pattern where no such
file exists — `cd ../panels; echo star*.txt` also prints `star*.txt`, this time because nothing
matched. Back in `mixed/`, `echo star*` prints `star*.txt`, which is a *different* string from the
pattern, so that one is a real match. Comparing pattern text with output text is the technique.

**33.** `star[*].txt`, or `*[*]*`. Inside a bracket expression `*` is an ordinary character, so
`[*]` means "one asterisk". Quoting (`'star*.txt'`) also works and is lesson 3.

**34.** `what[?].txt` and `[[]set].txt` (or `*[]]*`, or `[[]s*`). `echo [set].txt` prints
`[set].txt` — **not a match**. The pattern means "one character from the set {s,e,t}, then `.txt`",
no such file exists, so the unmatched pattern was passed through as literal text that happens to be
spelled identically to the filename. Proof: `echo [set].txt` in `panels/` prints the same thing.

**35.** `ls two*` → one line; `ls -l two*` → one line. The glob expanded to **one** argument, spaces
and all: the shell does not re-split the names it produced. `ls $(echo two*)` → two errors,
`cannot access 'two'` and `cannot access 'words.txt'`, exit 2 — because command substitution *is*
subject to word splitting. Glob output: safe. Unquoted `$(...)` and unquoted `$var`: split.

**36.** `ls *dash*` → `ls: invalid option -- '.'`, exit 2. The glob matched, the shell handed `ls`
the name `-dash.txt`, and `ls` read it as a bundle of option letters — `d`, `a`, `s`, `h` are all
real `ls` options, and it got as far as the `.` before complaining. `ls -dash.txt` gives the exact
same error, which is the point: **once the shell has expanded, the command cannot tell the two
apart.** The two working forms: `ls -- -dash.txt` and `ls ./-dash.txt` (which prints `./-dash.txt`).

## Experiment

**37.** `set -x; ls *.log` prints:
```
+ ls panel-01.log panel-02.log panel-03.log panel-04.log panel-05.log panel-06.log panel-08.log panel-10.log panel-11.log panel-12.log panel-7.log
```
The trace shows the command *after* expansion. The `*` is not there. This is the proof that the
shell, not `ls`, did the matching.

**38.** In `empty/`:
- `echo *` → `*` (rc 0)
- `ls *` → `ls: cannot access '*': No such file or directory`, rc **2**
- `nullglob` on: `echo "[" * "]"` → `[ ]`; `ls *` → lists the empty directory, rc **0** — because
  `ls` was run with **no arguments** and defaulted to `.`
- `failglob` on: `ls *` → `bash: no match: *`, and **`ls` never runs**. The shell aborts the command
  before execution.

**39.** With `nullglob`: `rm *.tmp` → `rm: missing operand`, rc 1. `cp *.tmp dest/` →
`cp: missing destination file operand after 'dest/'`, rc 1 — the pattern vanished, so `cp` saw one
argument and read `dest/` as the *source*. That is the danger: `nullglob` makes `rm` safer (nothing
to delete instead of an error about a file named `*.tmp`) and makes any command whose last argument
is a destination **shift its arguments**. `cp a* b* dest/` with everything unmatched becomes
`cp dest/`; with `a*` unmatched it becomes `cp <b-files> dest/`, which is fine, and with only `b*`
unmatched it becomes `cp <a-files> dest/`, also fine — the failure mode is the count changing under
you.

**40.** `echo deck-03/*/*` → **7**: `deck-03/archive-link/2187-04.txt` plus the six
`bay-NN/{faults,readings}` directories. Two levels of `*` land on directories in the bays but on a
file through the link, because the link is one component "shallower". `echo deck-03/*/*/*` → the six
`bay-NN/{faults,readings}/2187-05-17.txt` files. Neither pattern sees `.private.txt`.

**41.** In `deep/`: `**/*.txt` → 7 names (`archive/2187-04.txt` and the six bay files);
`**/` → 12 directory names, **including `deck-03/archive-link/`**; `deck-03/**` → 17 entries starting
with `deck-03/` itself and including `deck-03/archive-link` but nothing beneath it.

The four counts:
```
      **/*.txt | grep -c link   -> 0
    ./**/*.txt | grep -c link   -> 1
  deep/**/*.txt | grep -c link  -> 1     (run from the lab root)
           **/ | grep -c link   -> 1
```
The rule, measured on bash 5.2.21: `**` used with **no preceding path component** does not recurse
through a symlinked directory, but the identical `**` with *any* prefix — even `./` — does. `**/`
lists a symlinked directory as a match either way; the difference is only whether it is descended
into. Accept any statement that says the prefix changes the result; reject "globstar never follows
symlinks", which is what the documentation implies and what the fourth measurement disproves.

**42.** `deep/*/*/*` → **7**. `shopt -s globstar; deep/**` → **20**. `**` includes the intermediate
directories themselves and every depth, where the fixed-depth pattern returns exactly one level.

## Stretch

**43.** Glob: `shopt -s globstar; printf '%s\n' deep/**/*.txt` → **8**. `find`:
`find deep -name '*.txt'` → **8**. Same count, different sets. The glob returns
`deep/deck-03/archive-link/2187-04.txt`, following the symlink, which `find` does not without `-L`.
`find` returns `deep/deck-03/.private.txt`, which no glob in this lesson reaches, because `find`
has no dot rule. Each tool finds exactly one thing the other misses, and both report eight — so a
matching count is not evidence the two agree.

**44.** `nullglob` right / `failglob` wrong — a loop that may legitimately have nothing to do:
```
shopt -s nullglob
for f in *.tmp; do rm -- "$f"; done      # <-- this line: with nullglob off, $f is the literal '*.tmp'
```
`failglob` right / `nullglob` wrong — a command that must not run on the wrong argument count:
```
shopt -s failglob
cp backups/*.tar.gz /restore/           # <-- this line: with nullglob, this becomes 'cp /restore/'
```

**45.** With both on, an unmatched pattern silently becomes no arguments *and* every dot-file is now
in scope — so a sweep can quietly delete the configuration it was never meant to see, and the run
that deleted nothing looks identical to the run that deleted everything. Neither on: unmatched
patterns produce a loud error and dot-files are out of scope by default.

**46.** `shopt -s extglob; echo !(a*)` on one line fails with
`syntax error near unexpected token '('` because bash **parses the whole line before executing any
of it**, so `extglob` is not yet on when `!(a*)` is parsed. In a script file the `shopt` is on a
line that has already run by the time the next line is parsed. Then, in `mixed/`:
`echo !(*.txt)` → `README notes.txt~`. (`.cfg` still needs `dotglob`.)

**47.** `panel-0[1-6].log` — six names. It is correct **because of the data**: it relies on panels
1–6 all having been named with the leading zero. `panel-7.log` proves the naming is not enforced, so
a future `panel-4.log` would be missed. A pattern robust to both would be
`panel-[0-9].log panel-0[1-6].log` — two patterns, because a glob cannot express "the number is
between 1 and 6".

**48.** `ls -d */` in `deep/deck-03` → `archive-link/ bay-01/ bay-02/ bay-03/`. The trailing slash is
part of the *pattern*: a name only matches if the path with a slash appended resolves, which is only
true for directories. `archive-link` is included, because it is a symlink **to** a directory and the
kernel resolves `archive-link/` happily — so `*/` means "directory or symlink to one", not
"directory". `ls -d */.` gives the same four with `/.` appended and has the same property.

## Dig

**49.** With `echo` standing in for `rm`:
- `panels/`: `*.log` → the eleven lowercase logs; `*.bak` → `panel-03.log.bak`; `*.txt` → no match.
  **Survivors: `PANEL-09.LOG` and `.panel-00.log`.**
- `readings/`: `*.txt` → twelve; `*.log` and `*.bak` → no match.
  **Survivor: `2187-05-17-1600.txt.partial`.**
- `mixed/`: `*.txt` → eight; `*.log` and `*.bak` → no match.
  **Survivors: `.cfg`, `README`, `notes.txt~`.**

**50.** Dotglob rule: `.panel-00.log`, `.cfg`. No-recursion rule: nothing in these three directories
— but `deep/` is untouched entirely by a sweep pointed at the lab root, which is the same rule at
one remove. Neither: `PANEL-09.LOG` (case), `2187-05-17-1600.txt.partial` (suffix after the
extension), `README` (no extension), `notes.txt~` (the tilde is after the extension).

**51.** One sentence each:
- **Leading dot** — defeats all three patterns at once, because `*` does not match a leading dot
  unless `dotglob` is set, and the note says the sweep does not set it.
- **Trailing tilde** — defeats `*.txt` and `*.log`, because those require the name to *end* in the
  extension and `notes.txt~` ends in `~`.
- **No extension** — defeats all three, because each pattern requires a literal `.log`, `.txt` or
  `.bak` at the end and `README` has no dot at all.
- **Leading dash** — does **not** defeat the pattern; `-dash.txt` matches `*.txt` and the shell hands
  it to the command. It defeats the *command*: measured, `rm *.txt` in a copy of `mixed/` fails with
  `rm: invalid option -- 'a'` / `Try 'rm ./-dash.txt' to remove the file '-dash.txt'`, exit 1, and
  **deletes nothing at all** — one dash-named file protects every other file in the directory from
  that sweep. This is a different mechanism from the other three and the student must say so.

**52.** Makes possible: anyone who has read the wall knows exactly which names will be removed and
which will not, so a name can be chosen in advance to fall outside the pattern. Does not prove:
that any particular surviving file was named deliberately. A name that survives a known pattern is
equally consistent with carelessness — `README` and `notes.txt~` are what an editor and a hurried
human produce without any intent at all.

## Notes for the authoring/tutor agent

- Exercise 34's `[set].txt` result is the lesson's best trap: the unmatched pattern is spelled
  identically to the filename, so "it worked" and "it did nothing" look the same. Do not resolve it
  for the student; send them to `panels/` to run the same pattern where the file does not exist.
- Exercise 41 documents behaviour that contradicts the common reading of the `globstar` docs. It was
  measured four ways on bash 5.2.21 in this image. If a student reports the opposite, have them show
  the exact command including its working directory — the prefix is the variable.
- Exercise 51's dash answer is the seed of the chapter incident. Do not connect them out loud.
- `spec/sweep-notes.txt` is deliberately neutral about who benefits from the pattern being public.
  Nothing in this lesson names anybody, and no agent may.
