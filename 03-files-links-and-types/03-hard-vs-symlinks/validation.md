# 03/03 — Validation

For the agent in **validator mode**. Read `docs/VALIDATION_PROTOCOL.md` first. Grade the student's
log and the lab state; there is no auto-grader.

**Inode numbers are not fixed.** They change on every seed and differ per machine. Grade the
*relations* — same/different, count before/after — never a literal number.

**Sizes are fixed** and are gradeable: a symlink's size is the byte length of its target string.
`panels/current` is 12, `panels/current-abs` is 70, `chain/c` is 20, `sizes/short` is 8,
`sizes/long` is 40, `dangling/ghost` is 38, `dangling/ghost-dir` is 16, `dangling/vanished` is 18.
`current-abs` is 70 only because the lab lives at the standard path; if the student moved the tree,
grade the length rule, not the number.

Exercises **19–21** deliberately destroy `target/report.txt` and end with `kestrel reset 03/03`.
Exercises **27 and 29** also mutate the tree. Lab state after the lesson proves little — the log is
the evidence. Run `kestrel reset 03/03` yourself before checking anything state-dependent.

The single distinction this whole lesson grades: **the link versus the thing it points at.** Any
answer that blurs the two is wrong even when its command output is right.

---

## Warmup

**1.** *Goal:* read inode numbers out of a listing and group by them.
*Accept:* three distinct inodes; `panel-07.txt` and `panel-07-alias` grouped together.
*Reject:* four distinct inodes claimed (they read the wrong column, or ran `ls -l` without `-i`).
*Probe:* "which column did you read, and what is the column beside it?"

**2.** *Accept:* the pair named, plus a sentence saying there is **no** original — both are directory
entries pointing at one inode, and the filesystem does not record which came first.
*Reject:* "`panel-07.txt` is the original because the other is called alias." Naming is a human
convention; that is exactly the misconception the exercise is set to catch.
*Red flag:* a student who insists on an original will misread exercise 29. Note it.

**3.** *Accept:* 12 is the length of the string `panel-07.txt`; the symlink's contents *are* that
path. Counting the characters out loud is a good sign.
*Reject:* "because it's a small file", "because it's a pointer", "because it stores an inode
number" — a symlink stores no inode number, it stores text.

**4.** *Evidence:* `panel-07.txt` and the full `/labs/...` path.
*Accept:* relative versus absolute named as the difference.
*Reject:* "one is longer" as the only answer.

## Core

**5.** *Evidence:* four `stat` lines; two share `%i` and show `%h` of 2; the two symlinks show `%h`
of 1 and `%F` of `symbolic link`; sizes 12 and 70 on the links, 40 twice.
*Accept:* the two hard-linked rows marked as the same file.
*Reject:* the two symlinks marked as "the same file as" the target — they are not; they *reach* it.

**6.** *Accept:* two distinct mechanisms in the student's own words — the alias is a second name on
the same inode, so `cat` opens the file directly; `current` is a separate inode holding a path, and
the kernel resolves that path and opens what it names.
*Reject:* "both are links to the file" as the whole answer.
*Probe:* "how many inodes did the kernel touch in each case?"

**7.** *Evidence:* `a -> b` (1), `b -> c` (1), `c -> ../target/report.txt` (20); `total 0`.
*Accept:* `total 0` explained as short targets living inside the inode itself — fast symlinks
allocate no data blocks, and `total` counts blocks.
*Reject:* "because the files are empty". They are not empty; they hold 1, 1 and 20 bytes.

**8.** *Evidence:* `b`, then `c`, then `../target/report.txt`, then `readlink` failing (empty output,
exit 1) on the report itself.
*Accept:* the failure recognised as "not a symlink", not as an error in the student's typing.
*Reject:* a walk that skips a hop, or that stops at `c` without testing it.

**9.** *Accept:* `readlink -f chain/a` giving the absolute report path, plus: `-f` follows every hop
and canonicalises to an absolute path, where plain `readlink` returns exactly one hop of stored text.
*Reject:* "`-f` means force".

**10.** *Evidence:* without `-L`, inode of the link, size 12, `symbolic link`; with `-L`, the
target's inode, size 40, `regular file`.
*Accept:* all three fields accounted for, and the phrase that `-L` makes `stat` describe the target.
*Reject:* the size change explained and the inode change ignored.

**11.** *Evidence:* type character, mode, size, and the arrow differ; the link count differs too.
*Accept:* `ls -lL` is the one showing count 2, because it is describing the target.
*Reject:* the reverse.

**12.** *Evidence:* `cat: perms/back-door: Permission denied`.
*Accept:* the relevant line is `sealed.txt` at mode `----------`; the distraction is
`back-door`'s own `lrwxrwxrwx`.
*Reject:* any explanation that blames the link's permissions, or that says the link is "protected".
*Red flag:* "the file is owned by root" — it is not; `ls -l` shows `cadet crew`. They are guessing.

**13.** *Accept:* a rule of the form "a symlink's mode bits are never consulted; the open is checked
against the target's mode." Both readings follow from it.
*Reject:* a rule that mentions `lrwxrwxrwx` as granting anything.

**14.** *Evidence:* `cat: dangling/ghost: No such file or directory`.
*Accept:* the *target* `/mnt/engineering/strain-2187-05-22.csv` named as the thing that does not
exist; the link plainly does, they just listed it.
*Reject:* "the link doesn't exist".
*Probe:* "you just saw it in `ls -l`. So which of the two names is the error about?"

**15.** *Evidence:* `broken symbolic link to /mnt/engineering/strain-2187-05-22.csv`.
*Accept:* `file` states the brokenness outright; `ls -l` only shows the arrow and leaves the student
to test the target.
*Reject:* claiming `ls -l` colour-codes it — colour is terminal configuration, not evidence.

**16.** *Accept:* `readlink dangling/ghost` and `stat -c %N` (or `stat --printf='%N\n'`); note that
`%N` prints quotes and the arrow, so if the student offers it they must say so.
*Reject:* `ls -l` piped through `awk` counts only if they acknowledge it breaks on names with
spaces. `cut -d'>' -f2` is fragile — accept with the caveat, probe otherwise.

**17.** *Evidence:*
`vanished`: `-f` prints `.../target/gone.csv`, exit 0; `-e` prints nothing, exit 1.
`ghost`: `-f` prints nothing, exit 1; `-e` prints nothing, exit 1.
*Accept:* the pattern stated as a components rule — `-f` requires every component but the last to
exist; `-e` requires all of them, last included. `target/` exists so `vanished` canonicalises;
`/mnt/engineering` does not, so `ghost` cannot.
*Reject:* "`-f` is for files and `-e` is for existence" — a slogan, not the rule. Probe with
`ghost`, which their slogan cannot explain.

**18.** *Evidence:* `cat: loop/ring-a: Too many levels of symbolic links`.
*Accept:* `ls -l` never resolves the targets, it only reads the two directory entries, so there is
no loop to fall into.
*Reject:* "`ls` is smarter and detects the loop".

**19.** *Evidence:* link count on the target's inode 1 before, 2 after `ln`; `mine-soft` is its own
inode, count 1, size 17 (the length of `target/report.txt`).
*Accept:* `ls -li` showing `mine-hard` sharing the report's inode.
*Reject:* a count of 3 claimed — the symlink does not add to it. That is the whole point.

**20.** *Expected end state:* `target/report.txt` gone; `mine-hard` reads fine, count back to 1;
`cat mine-soft` fails with `No such file or directory`.
*Accept:* both results, plus the count.
*Reject:* surprise that `mine-hard` still works stated without explanation. Probe: "what does the
inode count as, names or contents?"
*Red flag:* the student deleted `mine-hard` instead. Have them reset and redo.

**21.** *Evidence:* `target/report.txt` back, `mine-hard`/`mine-soft` gone.
*Accept:* a confirming `ls`.
*Reject:* moving on without checking. Everything after this depends on a clean tree.

**22.** *Evidence:* `ls -l` sizes 8 and 40; `stat -L -c %s` gives 5 for both. `sizes/leaf.txt` is a
hard link to the leaf at the bottom of `very/`, which is how the short route reaches the same inode —
`ls -li sizes` and the deep path show one inode with link count 2.
*Accept:* the link sizes differ because the stored *routes* differ in length; the target sizes match
because it is one file.
*Reject:* the two pairs conflated, or `stat` run without `-L` and the difference reported as real;
"they point at two copies of the same content" (it is one inode, and they can show it).

## Experiment

**23.** **A written prediction must exist before the run.** No prediction, no credit — send them back.
*Evidence:* after `mv`, `cat moved/renamed/near` works (target `note.txt` is relative and moved
with the directory); `cat moved/renamed/far` fails, because it stores the old absolute path
containing `inner`.
*Accept:* a wrong prediction that is then corrected in writing. That is the exercise working.
*Reject:* a prediction visibly written after the fact — check whether it matches the output too
neatly and probe the reasoning.
*Red flag:* the student thinks a symlink stores an inode or a file handle. Symlinks store text and
are resolved at every use; say only that much and let them re-derive.

**24.** *Evidence:* `copy-default` is a regular file (`cp` follows by default); `copy-P` is a symlink
`-> panel-07.txt`; `cp dangling/ghost copy-ghost` fails with
`cp: cannot stat 'dangling/ghost': No such file or directory` and creates nothing.
*Accept:* the third explained as `cp` needing to stat the source before reading it, and `stat`
following the link to something that is not there.
*Reject:* "`cp` refuses to copy broken links" as a rule — it has no such rule; `cp -P` copies it fine
and is worth suggesting as a probe.

**25.** *Evidence:* `ln -s ../f d` with `d` a directory creates `d/f -> ../f`. `ln` places the link
*inside* an existing directory when the last argument is one.
*Accept:* built and shown under `/tmp`, plus `-n`/`--no-dereference` explained as making `ln` treat
a symlinked directory as a link rather than descending into it, and `-f` as replacing it — `ln -sfn`
being the standard way to atomically repoint a directory symlink.
*Reject:* an answer given only from the man page with nothing built.

## Stretch

**26.** *Evidence:* exactly five — `dangling/ghost`, `dangling/ghost-dir`, `dangling/vanished`,
`loop/ring-a`, `loop/ring-b` — sorted into the three dangling links (target does not exist) and the
two loop links (`ELOOP`: resolution never terminates, so `-e` cannot confirm anything).
*Accept:* a loop of the shape `for f in */*; do [ -L "$f" ] && { readlink -e "$f" >/dev/null || echo "$f"; }; done`
— or any equivalent driven by `readlink -e`'s exit status — **plus** both reasons named, and the
`loop/` pair correctly excluded from "dangling".
*Reject:* `find` (Chapter 6 — not yet); a hand-typed list with no command; a scan using `readlink -f`
(it succeeds on `vanished` and would miss it — a real and instructive bug, probe for it); calling all
five dangling.
*Red flag:* more than five results, or ordinary files in the list. Without the `[ -L "$f" ]` guard
`readlink -e` also fails on every regular file. Worth making them find it themselves.
*Probe:* "which of these five would `cat` report as `No such file or directory`, and which gives a
different error?" (`Too many levels of symbolic links` for the pair.)

**27.** *Evidence:* `readlink chain/a` still prints `b` — the stored text is unchanged by the
deletion. `readlink -f chain/a` prints the canonical path of `b`, exit 0 (its parent exists).
`cat chain/a` fails with `No such file or directory`.
*Accept:* three different answers recognised as answers to three different questions: what is
stored, what does it canonicalise to, can it be opened.
*Reject:* "all three fail".

**28.** *Accept:* `ln -sfn target/report.txt chain/a` (or `ln -sf`), then `readlink chain/a` printing
the target directly and `cat` working.
*Reject:* `rm chain/a` first — the exercise forbids it. `ln -sf` without `-n` is fine here because
`chain/a` is not a directory link; the student should be able to say why.

**29.** *Evidence:* after `rm panels/panel-07.txt`, `panel-07-alias` reads fine (the inode still has
a name); `cat panels/current` fails — its stored text names a path that is gone.
*Accept:* repair by repointing the link: `ln -sfn panel-07-alias panels/current`. The data never
moved; only the name in the link's contents changed.
*Reject:* recreating `panel-07.txt` — explicitly excluded. `ln panels/panel-07-alias
panels/panel-07.txt` is recreating it under a technicality; probe whether they see that.

**30.** *Evidence:* inside a symlinked directory, `pwd` prints the symlinked path, `pwd -P` prints
the real one.
*Accept:* `-P` named as the kernel's truth; the shell maintains the logical path as a convenience.
*Reject:* a claim that `cd` "resolves" the link — the shell deliberately does not, which is why the
two differ.

## Dig

**31.** *Evidence:* `ln -sr` (`--relative`); the arrow shows a relative path like `../t.txt`.
*Accept:* both absolute paths handed to `ln`, and the resulting relative arrow shown.
*Reject:* the student hand-writing a relative target and claiming the flag did it.

**32.** *Evidence:* `-m`, which requires nothing to exist and canonicalises purely textually.
*Accept:* a path where `-e` fails, `-f` fails, and `-m` prints — e.g. two nonexistent components
deep. `dangling/ghost` works if `/mnt/engineering` is absent.
*Reject:* `-m` demonstrated only on a path that exists, where all three agree.

**33.** *Evidence:* `ls -F` appends `@` to every symlink, including one pointing at a directory;
`ls -p` appends `/` to real directories only and marks symlinks not at all — not even a
symlink-to-directory.
*Accept:* `-F` chosen for "which of these are links?", with the reason that `-p` is silent on links
by design.
*Reject:* the symlink-to-directory case untested. It is the discriminating case and the exercise
asks for it explicitly.
*Red flag:* the student reports `-p` marking a symlinked directory with `/`. They tested a real
directory by mistake, or their `ls` is aliased; check the command.

## Wrap-up

**The wrap-up.** No flag. Grade the four sentences.
*Accept:* hard link = an additional directory entry naming the same inode, counted by the inode's
link count. Symlink = a file whose contents are a path string, resolved at every use. A dangling
link exists because nothing checks the target — not at creation, not on deletion of the target;
the text just stays. `readlink -f` gives a canonical path whose final component need not exist,
where `-e` returns nothing unless the whole path resolves to something real.
*Reject:* "a symlink is a shortcut" as the whole of sentence two.
*Red flag:* sentence three answered as "because the target was deleted" — that is an instance, not
a reason. `ln -s nope N` succeeds with nothing named `nope` anywhere; probe with that.

---

## Roll-up — load-bearing

The student is ready for `04-timestamps` and for `06-incident-03` only if all of these hold.

1. **They separate the link from the target without prompting.** Every failure in this lesson is
   diagnosed by asking which of the two names an error is about. If exercise 12 or 14 needed the
   validator to point that out, re-run 12–17 before moving on.
2. **They can state the size rule and recompute it.** Given an arrow, they should be able to predict
   the size in `ls -l` and be right.
3. **They know `readlink`, `readlink -f` and `readlink -e` answer three different questions**, and
   can say which one to reach for. Exercises 17 and 27 both test this; a student who passes 17 by
   pattern-matching usually fails 27.
4. **They understand that deleting a name is not deleting a file.** Exercise 20 is the proof and
   exercise 29 is the application.
5. **They found all five unresolvable links with a command, not by eye, and separated the three
   dangling ones from the two in the loop** (26). The incident lesson is
   a larger tree where eyes do not scale.
6. **They wrote predictions before running 23, 24 and 25.** A student who skipped the prediction got
   the outputs and none of the lesson.

If 1 or 3 fail, do not advance. Chapter 3's incident is a link maze and both are load-bearing there.
