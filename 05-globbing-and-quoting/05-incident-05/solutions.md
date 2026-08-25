# 05/05 — Solutions

Authoring/tutor reference. Do not show the student. Every number here was run in the container.

**Flag: `KESTREL{named_to_survive_the_sweep}`**

## Warmup

**1.** `ls deck-05` → 5. `ls -A deck-05` → 7. `-A` is right for this job. Plain `ls` hides names
beginning with a dot, silently — the first thing in the incident that was decided for the student
without being announced, which is the whole theme.

**2.** The seven, exactly:
`-strain-05.log`, `.handover-05.log`, `05 readings.log`, `panel-03.log~`, `panel-09.log~`,
`.bay-06-notes`, `spare parts.txt`.
The two that do not survive a copy-paste onto a command line unquoted are `05 readings.log` and
`spare parts.txt` (word splitting); `-strain-05.log` survives paste but is read as options.

**3.** `*.log`, `*.txt`, `*.bak`; posted 2187-05-28, sweep 2187-06-01 0300 — four days.

**4.** "removed 41 files", "rm reported 1 failure, continuing".

**5.** 48 − 41 = 7, and `ls -A` shows 7. It agrees.

## The script

**6.** `cd /deck-05` or exit 1. Then: the shell expands the three patterns into one list of existing
filenames and hands the *expanded list* to the loop — not the patterns. For each name, `rm -f $f`,
where `$f` is unquoted and therefore word split and re-globbed before `rm` sees it.

**7.** 05/01 (globbing: what `*` matches — not dotfiles, and `*.log` does not match `*.log~`);
05/04 (word splitting: `$f` unquoted becomes multiple arguments). 05/03 supplies the fix (quote it).

**8.** Only `-strain-05.log`, `05 readings.log` and `spare parts.txt` can be in the list. The two
dotfiles are invisible to `*`; the two `~` files do not match `*.log`, `*.txt` or `*.bak`.
`printf` confirms exactly those three plus the `*.bak` pattern left unmatched and literal.

**9.** Reproduction (measured):
```
cp -a deck-05/. scratch/rep/ ; cd scratch/rep ; touch a.log b.txt c.bak
for f in *.log *.txt *.bak; do rm -f $f; done
```
Removed: `a.log`, `b.txt`, `c.bak`. Left: all seven originals. One error:
```
rm: invalid option -- 's'
Try 'rm ./-strain-05.log' to remove the file '-strain-05.log'.
```
Loop exit status 0.

**10.** Exactly one loud failure. The log says 1. They agree — which is why the log is not evidence
of a cover-up; it is an accurate log of a defective script.

**11.** `05 readings.log`. `-f`. Unquoted `$f` split it into `05` and `readings.log`, neither of
which exists, and `-f` suppresses missing-file errors and forces exit 0. `spare parts.txt` survived
the same way, by accident.

**12.** `-strain-05.log`. `rm` parsed the leading dash as an option bundle and rejected `-s`. That is
`rm`'s argument parsing, not the shell's.

**13.**
| file | reason |
|---|---|
| `-strain-05.log` | leading dash — `rm` read it as options |
| `.handover-05.log` | leading dot — `*` skips dotfiles |
| `05 readings.log` | embedded space — unquoted `$f` split into two nonexistent names |
| `panel-03.log~` | trailing `~` — `*.log` does not match it |
| `panel-09.log~` | same |
| `.bay-06-notes` | leading dot (accident) |
| `spare parts.txt` | embedded space (accident) |

Four distinct mechanisms.

**14.** Three shell, one `rm`. Dot-glob, the `~` non-match and word splitting all happen before `rm`
is executed; only the dash is `rm`'s own option parsing. A student who says two-and-two has usually
put word splitting on `rm`'s side — correct them by asking who counted the arguments.

**15.** `ls -Al --time-style=full-iso deck-05` shows five files at `2187-06-01 02:58:00` and two at
`2187-05-12 11:40` and `2187-05-20 16:05`.

**16.** Three groups: five, one, one. The useful split is five versus two.

**17.** Sweep start 2187-06-01 03:00:00. The five were last written two minutes earlier.

**18.** Supported: five of the seven were last written two minutes before a sweep whose patterns had
been public for four days, and each is named in a way that defeats one of those patterns.
Not ruled out: a single unrelated write pass (a batch rename, a script run, a restore from backup)
could stamp five files at one minute without anyone intending to defeat anything. The lab has no
process log, so this cannot be excluded. Accept any student answer that names an alternative and
says why the lab cannot decide it.

**19.** The last line of a file: `# tag: <one word>`. Only files in a set carry one.

**20.** The five carry `# tag:` lines; `.bay-06-notes` ends `checked` and `spare parts.txt` ends
`pending`. The two discriminators — mtime and tag — agree perfectly. That agreement is the finding;
either alone is weaker.

**21.** No. Same owner (`cadet:crew`), sizes are unremarkable, inode numbers reflect creation order
in the lab and mean nothing. Honest "no" is the right answer, and students who invent a pattern in
the inode numbers should be pushed back on.

## The glob

**22.** All five contain `.log` somewhere in the name; neither accident does (`.bay-06-notes`,
`spare parts.txt`).

**23.** Four. `.handover-05.log` is missing — `*` does not match a leading dot.

**24.** `shopt -s dotglob`. It makes `*` match names beginning with `.` (still never `.` or `..`).

**25.**
```
cat: invalid option -- 'r'
```
Caused by `-strain-05.log`: `cat` accepts `-s`, `-t`, then rejects `-r`. Quoting does not help
because the shell is behaving correctly — the file genuinely is named with a leading dash, and no
amount of quoting changes what `cat` does with an argument that starts with `-`. Wrong layer.

**26.** `--`. Second fix: a path prefix — `cat ./*.log*` or `cat deck-05/*.log*` from the parent —
which makes every expanded word start with `.` or `d` instead of `-`. It is still one glob, so the
constraint allows it. (Verified: `cat deck-05/*.log*` needs no `--`.)

**27.**
```
shopt -s dotglob
cat -- *.log* | grep '^# tag:'
```
(from inside `deck-05`). The `grep` is convenience; `cat -- *.log*` alone shows the five tags.

**28.** Order:
```
-strain-05.log  .handover-05.log  05 readings.log  panel-03.log~  panel-09.log~
```
Glob results are sorted by the collation of the current locale; the container is `C`/`POSIX`, so it
is byte order: `-` (0x2D) < `.` (0x2E) < `0` (0x30) < `p`. It is the same order `ls` gives here, and
it is *not* what a person sorting by hand would produce — most people would put the dotfile first or
last. Under a `en_US.UTF-8` locale punctuation is weighted differently and the order can change,
which is worth mentioning to a strong student.

**29.** `named to survive the sweep` → `KESTREL{named_to_survive_the_sweep}`.

**30.** Registers.

**31.** Without `dotglob`: `named survive the sweep` — four words, and it does not read. Per
`records/naming-convention.txt`, a set is checkable without a manifest precisely because a broken
phrase announces a missing member. The convention is an integrity check, and the student just used
it as one.

## Reasoning

**32.** (a) Yes — `housekeeping/notice.txt`, posted 2187-05-28. (b) No. mtime is last *modification*,
not creation; a file written weeks earlier and touched at 02:58 has the same mtime. (c) No — nothing
in the lab records a rename. (d) No — five files at one minute is consistent with one person, one
script, or one restore. (e) Yes, demonstrably — the student reproduced the failure.

**33.** `.bay-06-notes`: an unfinished checklist, kept out of the way with a leading dot the way
people hide scratch files. `spare parts.txt`: someone typed a name with a space in it, which is
ordinary and only becomes interesting next to a defective script.

**34.** The tag lines. Alone it would be enough to identify the *set*, but not to place it in time
relative to the notice — so the "named after reading the notice" inference would weaken to "these
five belong together".

**35.** Survives: the five are a set, arranged, and each defeats a different pattern. Collapses: the
timing argument entirely. Without a published pattern there is nothing to have been named *against*
and the mtime cluster is just a batch write.

**36.** Model finding:
> Five of the seven files in `deck-05/` survived the sweep by design: each name defeats one specific
> failure in `sweep.sh` — a leading dash, a leading dot, an embedded space, a trailing tilde — and
> all five were last written at 02:58, two minutes before the 0300 sweep. The other two,
> `.bay-06-notes` and `spare parts.txt`, survived by accident: they are weeks old and carry none of
> the set's tag lines. The two discriminators, modification time and the tag convention, agree.

Reject a fourth sentence naming anyone.

## Experiment

**37.** Not possible with a filename alone. `ls -A` and a `dotglob` glob both see every entry in the
directory; there is no name that hides from them. Closest: a name made only of control characters or
one containing a newline, which `ls` renders as `?` on a terminal and which is hard to *type* but
plainly *listed*. Accept "no, and here is why" as the full-credit answer.

**38.** A subdirectory. `*` matches directory names but `rm -f` refuses them (`cannot remove … : Is a
directory`), and `*` never descends, so anything inside `deck-05/keep/` is untouched by the sweep at
any depth. Also acceptable: a name matching none of the three patterns at all (`readings.LOG` —
globbing is case sensitive).

**39.**
```
cd /deck-05 || exit 1
shopt -s dotglob nullglob
for f in *.log *.txt *.bak *.log~; do rm -f -- "$f"; done
```
Fixes used: `dotglob` (01), the pattern set widened for `~` (01), `"$f"` quoted (03/04), and `--`
(03). Four lines. A student who instead writes `rm -f -- *` has solved a different problem — it
removes the dotfiles too but stops being a *pattern* sweep; worth discussing, not worth failing.

**40.** Nothing extra is needed: `rm -f` already makes a second run a no-op, because with the files
gone the globs match nothing and `nullglob` gives an empty list, and even without `nullglob` the
literal unmatched pattern is a missing file that `-f` swallows. That is the one thing `-f` was
genuinely right about in the original script.

## Stretch

**41.** With no `.bak` files, `*.bak` matches nothing and (default `nullglob` off) is passed through
**literally**, so the loop runs one extra iteration with `f=*.bak` and `rm -f` is asked to delete a
file literally named `*.bak`. It does not exist; `-f` silences it; exit 0. Reproducible in
`scratch/`. The unquoted `$f` also re-globs it, which changes nothing here but would matter if a
file called `*.bak` existed.

**42.** `shopt -s nullglob` makes the unmatched pattern vanish, so the loop iterates zero times for
that pattern. Better than the literal pass-through, but both are wrong for housekeeping: `nullglob`
turns "nothing matched" into silence, and silence is indistinguishable from success. `failglob`
aborts the command loudly when a pattern matches nothing, which is the behaviour you want in a job
that runs unattended at 0300 — you want to hear about a pattern that stopped matching.

**43.**
```
ls -A | grep -n '^-\|[[:space:]]\|^\.'
```
or, better, `printf '%q\n' * .[!.]* 2>/dev/null` — anything `%q` decides to quote is a name that
would defeat a naive loop. Cannot detect: names that match no pattern (the `~` and `.LOG` cases),
directories, or anything the glob never produced in the first place. The audit only sees what the
glob hands it, which is the same blind spot as the sweep.

**44.** No. `manifest-2187-05-28.txt` states that it records names and nothing else — and it is not
in the lab as a name list; it is a summary. Nothing in `deck-05/`, the sweep log or `records/` names
a removed file. For that to be possible the sweep would have had to log each `rm`, or the manifest
would have had to list the 48 entries. Both are one line of change, and neither was made.

## Dig — tokens

**45.** Stage 1. The notice says index files are `bay-NN-<something>.tar`. Most `bay-0N` files are
`.txt`; the `.tar` ones are even-numbered — except one.
```
printf '%s\n' records/bay-0[13579]-*.tar   # -> records/bay-07-sequence.tar
```
`STAGE{first_pattern_holds}`

**46.** Stage 2. `records/{old,new,draft}/panel-{03,05,09}-{a,b}.note` = 3 × 3 × 2 = **18** words.
Brace expansion is unconditional — it produces all 18 whether they exist or not, which is exactly
why it cannot be used to *find* anything. Test all 18 at once:
```
ls -d records/{old,new,draft}/panel-{03,05,09}-{a,b}.note 2>/dev/null
```
→ `records/draft/panel-05-b.note`. The decoys `old/panel-11-a.note` and `new/panel-07-b.note` are
deliberately outside the expansion. `STAGE{eighteen_names_one_file}`

**47.** Stage 3. Wrong first:
```
$ cd housekeeping && grep -c * notice.txt
sweep-2187-06-01.log:0
sweep.sh:0
notice.txt:0
```
The `*` expanded to the directory contents; the first filename became the *pattern* and the rest
became files, so `grep` counted `sweep-2187-06-01.log` as a regex in three files and reported zeros.
No error, exit status 1, an answer that looks like data. Right:
```
$ grep -c '\*' housekeeping/notice.txt
3
```
(the three published pattern lines). Line 3 of `records/draft/stage-3.txt` is the record.
Token on that line, field 6: `STAGE{fourth_field_is_empty}`.
Note the trap tokens on the wrong lines (`STAGE{that_was_the_unquoted_answer}` etc.) — these are
receipts that fail loudly at stage 4's text, and none of them register with `kestrel flags`.

**48.** Stage 4.
```
IFS=: read -r a b c d e f <<< '3:STAGE{quote_it_or_lose_it}:deck-05::yes:STAGE{fourth_field_is_empty}'
printf '%s\n' "$f"
```
→ `STAGE{fourth_field_is_empty}`. Field 4 is empty because `IFS=:` is a non-whitespace separator and
does **not** collapse runs — `::` makes an empty field. A student using `cut -d: -f6` gets the same
answer and should be asked what would have happened with fewer variables than fields (the last
variable absorbs the remainder).

**49.** Stage 1 → globbing (05/01). Stage 2 → brace expansion (05/02). Stage 3 → quoting (05/03).
Stage 4 → word splitting (05/04).

**50.** `records/draft/stage-4.txt` stops at "somebody read the notice, and then named things," and
explicitly says the lab does not record who. A name in a lab file would be a fact the student did
not derive, and the whole chapter is about not accepting expansions you did not perform yourself.

## Notes for the authoring/tutor agent

- The one-glob constraint is the lesson. Two globs, a `find`, or a hand-typed list all produce the
  five files and all destroy the ordering argument, which is where the flag actually lives.
- The mtime discriminator is Chapter 2/3 work reused under pressure. If a student reaches the flag
  without ever separating design from accident, they have not solved the incident — send them back
  to exercise 15.
- rhea asked for the separation. rhea is not implicated by anything here and nothing in this lab
  should be allowed to suggest otherwise.
- No file in this lesson names anyone as the author of the five. Do not supply one.
