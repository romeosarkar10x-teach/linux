# 05/02 — Solutions (agent eyes only)

> **Student: do not open this file.**

Measured in the container image (bash 5.2.21, `LANG=C.UTF-8`).

## Warmup

**1.** `abd acd`. Then `abd abe acd ace` — **four** words. Adjacent expressions multiply.

**2.** `1 2 3 4 5` and `01 02 03 04 05`. Padding comes from either endpoint being written with a
leading zero: `echo {1..05}` also gives `01 02 03 04 05`. The width is that of the widest endpoint.

**3.** `file file.bak`. `{,.bak}` is a list of two elements where the first is the empty string, so
the prefix `file` is emitted once bare and once with `.bak` appended.

**4.** `panel-03.cfg` and `panel-05.cfg` have `.bak` files; `panel-09.cfg` and `panel-11.cfg` do not.

## Core — the three forms

**5.** `a b c d e`; `e d c b a`; `a f k p u z`. The third counts by 5 through the character codes,
starting at `a` and stopping at or before `z`.

**6.** `0 5 10 15 20` and `20 15 10 5 0`. **No** — the step is always written positive; the direction
comes from which endpoint is larger. A negative step is not an error but is not how you express
descent.

**7.** `10 7 4 1`. Both endpoints are in the list here. The interesting case is that the step lands
exactly on 1; had it been `{10..1..4}` you would get `10 6 2` and the endpoint 1 would be missing —
the series stops at the last value that does not overshoot.

**8.** `-2 -1 0 1 2`; `2 1 0 -1 -2`. Negative endpoints are fine and the minus sign is not confused
with the `..`.

**9.** `1 2 3 4 5`. A step of zero is silently treated as 1 rather than being an error or an infinite
loop. Nobody expects this; the useful lesson is that bad input to a brace expression tends to produce
*something* rather than a complaint.

**10.** `a1 a2 b1 b2`; `a-1 a-2 b-1 b-2`; **12**. The arithmetic is 4 × 3 — the number of elements in
each expression multiplied, exactly like a Cartesian product.

**11.** `abf acdf acef`. The inner `{d,e}` produced `d e`; `c{d,e}` made that `cd ce`; so the outer
list is the three elements `b`, `cd`, `ce`, each wrapped in `a`…`f`.

**12.** `b a c` — braces preserve the written order. Globs sort; braces do not. This matters when a
brace expression feeds a command whose output order you then rely on.

**13.**
- `{abc}` — no comma and no `..`, so not a list and not a sequence.
- `{a}` — a single element is not a list; bash requires at least one comma.
- `{a, b}` — the space is not part of any element; whitespace disqualifies the expression.
- `{a,b` — no closing brace.
- `{a..3}` — endpoints must be both numeric or both single alphabetic characters, not one of each.

All five are printed literally, exit status 0.

## Core — building the deck

**14.** `mkdir -p deck-05/bay-0{1..8}/{readings,faults,handover}` — 33 directories
(1 + 8 + 24). Accept any equivalent.

**15.** Measured: **33**.

**16.** It created `bay-06`, which gap 1 says does not exist. It failed to create `bay-08/spares`
(gap 2) and all three `panel-*` directories with their `logs/` and `spares/` (not in the naive
expression at all).

**17.** `echo bay-0{1..12}` → `bay-01 … bay-09 bay-010 bay-011 bay-012`. The literal `0` in the
prefix is not padding, it is a character; once the numbers reach two digits the names are wrong. The
correct form puts the zero inside: `bay-{01..12}` → `bay-01 … bay-12`.

**18.** One accepted answer:
```
mkdir -p build/deck-05/bay-0{1,2,3,4,5,7,8}/{readings,faults,handover} \
         build/deck-05/bay-08/spares \
         build/deck-05/panel-{03,05,09}/{logs,spares}
```
`find build/deck-05 -type d | wc -l` → **39**. Any single command producing 39 with the right names
is correct; `bay-{01..05,07,08}` is a neater way to write the bay list and should be praised.

**19.** 1 (deck-05) + 7 (bays) + 21 (7 × 3 subdirectories) + 1 (bay-08/spares) + 3 (panels) + 6
(3 × 2) = **39**.

**20.** For: the expression stays regular and readable, and the exception is one visible line rather
than a gap hidden inside a list. Against: it creates a directory that must not exist, even for a
moment, and if the `rmdir` fails or is edited away later, the tree is silently wrong. On a station
where a directory's existence is itself a claim about what was fitted, the second argument wins.

**21.** List form `panel-{03,05,09}`; sequence form `panel-{03..09..2}` — which gives `03 05 07 09`,
four panels, not three. Only the list can express a set with no arithmetic behind it. This is gap 3
stated as a command.

**22.** Nothing happened and nothing complained. `-p` makes `mkdir` treat an existing directory as
success rather than an error, which is what makes the whole build idempotent.

**23.** Nothing warned. `bay-99` is a string like any other, and `echo` printed it. A glob given a
name that matches nothing either passes the pattern through (default) or errors (`failglob`) — but a
brace expression has no concept of a match to fail.

**24.** `mkdir -p build/deck-05/bay-08/{readings,faults,handover,spares}`.

## Core — braces meet the filesystem

**25.** `bay-01` (with `readings/` and `faults/`) and `bay-02` (with `readings/` only).

**26.** All three paths printed. The shell said nothing — it never looked. `ls -d` on the same three
paths reports the two that do not exist, because `ls` does look.

**27.** The glob returns **two**: `existing/deck-05/bay-01/readings` and
`existing/deck-05/bay-02/readings`. The brace expression returned three strings; the glob returned
two paths that exist. Braces make names, globs find them.

**28.** A glob is matched against the **filesystem** and can only produce paths that exist; a brace
expression is pure **string** manipulation and produces whatever the arithmetic says, existing or
not.

## Core — the `{,.bak}` idiom

**29.** `cp scratch/x.cfg scratch/x.cfg.bak`.

**30.** `cp panel-{09,11}.cfg{,.bak}` — note both braces on one line; it expands to a four-word
command, which is `cp` with two sources and a destination and is therefore **wrong**. The correct
answer needs the pairs kept together:
`for f in panel-09 panel-11; do cp $f.cfg{,.bak}; done`, or simply two `cp` commands. A student who
writes the one-liner and does not test it will silently create nothing and get
`cp: target 'panel-11.cfg.bak': No such file or directory` and exit 1. Have them run it. The lesson is that `{,.bak}`
composes with a *prefix*, not with another brace expression.

**31.** It overwrites the existing `.bak` without a prompt. Measured: after
`echo new > p.cfg; echo old > p.cfg.bak; mv p.cfg{,.bak}`, only `p.cfg.bak` remains and it contains
`new`. The old backup is gone. This is the idiom's one sharp edge.

**32.** Measured: `rm: cannot remove 'panel-07.cfg': No such file or directory`, exit **1**.
`panel-03.cfg` **was** deleted; `panel-05.cfg`, `panel-09.cfg` and `panel-11.cfg` remain. A partial
deletion plus a nonzero exit.

**33.** No — a script that half-succeeds and returns 1 will be retried, and the retry now fails on
the file that was already removed. `rm -f scratch/panel-{03,07}.cfg` makes the missing file a
non-event and exits 0, which is honest about what the command means: *ensure these are gone*.

## Experiment

**34.** The brace trace is `+ echo panel-01.log panel-02.log panel-99.log` — three names, one of
which does not exist. The glob trace is `+ echo panel-01.log … panel-7.log` — eleven names, every
one of which exists. The brace expansion consulted nothing; the glob consulted the directory.

**35.** Measured trace: ten arguments. `panel-{0,1}*.log` first became **two patterns**,
`panel-0*.log` and `panel-1*.log`, and each was then matched against the disk (7 + 3). Brace
expansion ran first — which is why the glob saw two patterns instead of one.

**36.** `echo {1..$n}` prints `{1..$n}` literally. Brace expansion runs **before** parameter
expansion, so the braces were examined while `$n` was still the four characters `$`, `n` — not a
number, so not a sequence, so passed through. `eval echo {1..$n}` prints `1 2 3 4 5`: `eval` runs the
whole expansion pass a second time, and on that pass the text really does read `{1..5}`.

**37.**
```
seq 1 "$n"
for ((i=1; i<=n; i++)); do echo "$i"; done
eval echo {1.."$n"}
```
Ranking: the C-style loop first (no subprocess, no quoting hazard, obvious to a reader), `seq` second
(clear, but a external command and its output must be word-split to be useful), `eval` last by a
wide margin — it re-parses its argument, so any shell metacharacter that reaches `$n` is executed.
Accept any ranking that puts `eval` last with that reason.

**38.** `1..3 7`. Bash saw commas, so it read the whole thing as a **list** of two elements — the
literal string `1..3`, and `7`. A sequence and a list cannot be mixed inside one pair of braces; the
comma wins.

**39.** `ab,ce ade`. The backslash made the first comma an ordinary character inside the element, so
the list has two elements, `b,c` and `d`. Without it the list would have three elements, `b`, `c`,
`d`, giving `abe ace ade`.

**40.** `ab a b` — three words for four combinations. The fourth is empty + empty = the empty
string, and an unquoted word that expands to nothing is **removed**, not passed as an empty argument.
Measured: `set -- {a,}{b,}; echo $#` → **3**, and the three are `ab`, `a`, `b`. Contrast
`set -- {a,x}{b,y}` → **4**. `printf '[%s]\n' {a,}{b,}` prints three lines, not four, which is the
proof — the empty word never reaches the command.

**41.** Measured: **20** directories. `run-{001..010}` and `run-{1..10}` produce disjoint name sets —
`run-001` and `run-1` are different strings — so the second command created ten *more* directories
rather than finding the ten that were there.

**42.** `run-001 … run-010 run-1 run-10 run-2 run-3 …`. All ten padded names sort before all ten
unpadded ones (`0` < `1`), and among the unpadded, `run-10` sorts immediately after `run-1` and
before `run-2`. Padding makes lexical order match numeric order, which is why it is worth the two
characters everywhere a name will ever be sorted, globbed or listed.

## Stretch

**43.** `touch scratch/2187-05-30-{00..23}00.txt` — measured **24** words, first is
`2187-05-30-0000.txt`.

**44.**
```
mkdir -p deck-0{5,6,7}/bay-0{1,2,3,4,5,7,8}/{readings,faults,handover} \
         deck-0{5,6,7}/bay-08/spares \
         deck-0{5,6,7}/panel-{03,05,09}/{logs,spares}
```
Measured **117** directories: 3 × 39.

**45.** 26³ = **17576**, confirmed by `wc -w`. Dangerous because the command line is built entirely
in memory before anything runs, a small typo multiplies rather than adds, and a correct expression of
this size passed to `rm` or `mkdir` is one keystroke from being a much larger correct expression.
There is no confirmation step between the expansion and the command.

**46.** `bay-0{1,2,4,5}` — the skipped element simply is not written. A glob plus a check is better
when the reason for the exception is a *runtime* fact: `bay-03` being busy is true today and false
tomorrow, and a hand-edited brace expression encodes today's accident permanently, with no record of
why 03 is missing. The brace expression's silence about the gap is exactly the problem.

**47.** Measured with `set -x`: `+ rm -rf /logs /tmp`. Brace expansion runs first and produces
`$BASE/logs` and `$BASE/tmp`; `$BASE` then expands to nothing, leaving two absolute paths at the root
of the filesystem. The single character: `"` — `rm -rf "$BASE"/{logs,tmp}` still fails, but it fails
on `/logs`… so the honest answer is `${BASE:?}` — the `?` — which aborts the whole command with
`BASE: parameter null or not set` when the variable is unset. Accept `set -u` at the top of the
script as an equally good answer, and accept quoting only if the student notices it does not actually
save them here.

**48.** `mkdir -p deck-05/bay-01/readings deck-05/bay-02/readings deck-05/bay-03/readings` — write
the names out. Measured: `dash -c 'echo a{b,c}d'` prints `a{b,c}d`. Braces are a bash/ksh/zsh
feature and POSIX `sh` has nothing equivalent; portability means writing the list by hand or using a
`for` loop over an explicit word list.

## Dig

**49.**
- Gap 1 (bay-06 missing) defeats **sequence contiguity** — `{1..8}` cannot skip.
- Gap 2 (bay-08 has a fourth subdirectory) defeats **uniform combination** — every element of one
  expression is combined with every element of the next, so one bay cannot differ.
- Gap 3 (panels 03, 05, 09) defeats **arithmetic** — no start, end and step produce that set.

Together they are a complete argument for why a real tree eventually stops being expressible as one
brace expression, which is the honest end of this lesson.

**50.** The spec was written first and the tree built from it, then the tree diverged and `gaps.txt`
was written to explain the divergence. A number reserved but never built is a spec artefact: the
builder produced eight bays' worth of *plan* and seven bays' worth of *hardware*. If the tree had
come first, nothing would have reserved 06 at all. Accept any answer that gets "spec first, and the
gaps file is a later correction".

**51.** A second file correcting the first means every reader must find both, and a reader who finds
only `deck-spec.txt` will build the wrong tree — which is exactly what exercise 15 has them do.
Before merging you would have to check that the tree on disk matches `gaps.txt` and not
`deck-spec.txt`, and find out whether anything else — scripts, other specs, the sweep pattern from
lesson 1 — was written against the uncorrected version.

**52.** `touch panel-{01..99}.log`, or `touch panel-{03,05,99}.log`, or any expression whose range
runs past the real panels. On a real system: the mtime and the inode number. A file created as
collateral in a bulk command shares its timestamp to the second with its siblings and sits in the
same inode run; a file that had been there all along does neither. `stat` shows both.

## Notes for the authoring/tutor agent

- Exercise 30 is a deliberate trap and the solution above is the important one to read: the
  compose-two-braces one-liner *looks* right and produces a broken `cp`. Do not fix it for the
  student, make them run it.
- Exercise 47's answer is `${BASE:?}` or `set -u`, not quoting. Many sources say quoting; measure it.
- Exercises 50–52 are inference about how the station's trees were built. Nothing here names anybody,
  and no agent may. The point is that regular naming implies a generator, and a generator implies
  someone who chose the exceptions.
