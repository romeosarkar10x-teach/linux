# 04/04 — Validation (agent eyes only)

No auto-grading. A validating agent reads the student's transcript or answers against this file.
Full measured answers are in `solutions.md`; this file is the *judgement*: what counts, what does
not, and what a wrong answer means.

There is no flag in this lesson.

---

## Reference table

| # | Command / question | Correct result |
|---|---|---|
| 1 | `rm junk/panel-01.log` | no output, rc 0 |
| 2 | `rm` vs `rm -f` on missing file | error + rc 1; silence + rc 0 |
| 3 | `rm junk/old` / `rmdir junk/old` | `Is a directory` / `Directory not empty`, both rc 1 |
| 5 | `rm -v` | `removed 'junk/panel-02.log'`, printed after the unlink |
| 7 | `rm -i … </dev/null` | prompts printed, **nothing deleted**, rc **0** |
| 8 | `rm -I` on six files | one prompt: `rm: remove 6 arguments?` |
| 9 | `-I` threshold | more than three files, or recursive |
| 11 | `rm -f` alone in `awkward/` | no output, rc 0, file `-f` still present |
| 12 / 13 | the two fixes | `rm -- -f` ; `rm ./--force` |
| 16 | one file or two | `ls -b` → `two\nlines.txt`; count 4 |
| 20 | prompt text | `rm: remove write-protected regular file 'protected/keep.txt'?` |
| 21 | same with `</dev/null` | no prompt, deleted, rc 0 |
| 23 | the rule | the **directory's** write bit decides |
| 24 / 25 | `locked/report.txt` | `Permission denied` both times, rc 1 both times |
| 28 | after `rm` of one hard link | link count 1, contents intact, inode unchanged |
| 31 | trailing slash on symlink-to-dir | `Is a directory` / `Not a directory`, both rc 1 |
| 34 | `rm -rf /` | two-line failsafe message, rc 1 |
| 35 | `rm -rf --preserve-root=all /labs` | `skipping '/labs', since it's on a different device` + second line, rc **1** |
| 37 | `rm -rf` on a missing path | rc **0** |
| 41 | `find … -delete` on non-empty dir | `find: cannot delete … Directory not empty`, rc 1 |
| 43 | `/proc/<pid>/fd` entry | path with `(deleted)` appended |
| 45 | `lsof +L1` | the file listed with `NLINK` = 0 |
| 47 | the undeletable tree | inner directory at mode 500; `rm -r` fails `Permission denied` |

Inode numbers, PIDs, `df` figures and `mktemp` paths vary per run. Never mark those against a
literal value; mark the *relationship* (same inode, count went 2→1, reading two equals reading one).

---

## Warmup (1–4)

**Goal.** The student notices that `rm` succeeds silently and refuses in more than one way.

**Accept.** Exact error strings for 2 and 3, with exit statuses. For 4, any of `rm -r` / `rm -rf`
plus a statement that `-r` overrode the `rm` refusal and *satisfied* the `rmdir` one.

**Reject.** "`rm -f` deleted the missing file" — nothing was deleted; `-f` changed the reporting.
Exit statuses quoted from memory rather than shown.

**Red flags.** Answers to 3 that give one reason for both refusals. The two commands fail for
genuinely different reasons and conflating them predicts wrong behaviour later.

## Core (5–33)

**Goal.** The permission rule (23, 27), the unlink model (28, 29), and the shell-before-`rm` idea
(6, 11–19, 33).

**Accept.**
- **6, 18:** evidence the student ran `ls` on the glob before `rm`. This is the single habit the
  tier is teaching; an answer that arrived at the right deletion without checking is a pass with
  notes, not clean.
- **11:** an answer that names **both** effects of `-f` — option parsing consumed it, and "no
  operands" stopped being an error. One effect only is partial.
- **12–14:** both fixes, and a correct account of why `./` is the more general one (it is a fact
  about the path; `--` is a convention the command has to honour).
- **20–23:** the rule stated as a property of the **directory**. Any wording works.
- **24–26:** `chmod` applied to `locked`, not to `report.txt`.
- **28–29:** "removed a name, decremented a counter". Accept `unlink` phrasing.
- **31–32:** both errors, and an explanation that distinguishes *resolving the path* from
  *unlinking the entry*.

**Reject.**
- "`chmod 400` protects a file from deletion." This is the exact folk belief the lesson exists to
  break; it must be marked wrong wherever it appears, including in passing.
- "`-f` forces the delete even without permission" (exercise 25 disproves it on their own screen).
- "`rm` deleted the file the symlink pointed at" (30) — it never follows a symlink.
- Any claim that `rm -i </dev/null` deleted the files, or that its exit status was 1.
- Counting the newline file as two files after exercise 16 has been done.

**Red flags.** A student who fixed `awkward/` by `rm -rf awkward` and moved on. `keep-this.txt` was
supposed to survive; losing it means the glob was never checked, which is the failure mode the whole
tier is about. Redo 10–19 from a reset.

**Distinction.** Exercise 27 written so that it would actually change a colleague's behaviour: names
the directory bit, and names the cost (an unwritable directory also blocks creating files).
Exercise 29 that connects "unlink" to the fact that space is not freed until the count *and* the open
descriptors reach zero — that is Dig-tier reasoning arriving early.

## Experiment (34–37)

**Goal.** Predict, be wrong, and locate the failsafe's actual boundary.

**Accept.** A written prediction that exists *before* the run, for all four. For 34, the two-line
message and rc 1, plus a named still-dangerous variant (`--no-preserve-root`, or `rm -rf /*`).
For 35, "the filesystem boundary protected me" with `df` output as evidence. For 36, the correct
classification: the `scratch/tmpdir /` line is the one the failsafe stops; the empty-variable line
and the stray-space glob line are the real dangers. For 37, rc 0 and both consequences of it.

**Reject.** Missing predictions. Marking the Experiment tier without them is not possible — the
tier's content is the gap between prediction and result, and an after-the-fact "I expected that" is
not evidence.

**Red flags.** A student who declined to run exercise 34. Ask them to run it; the refusal is the
folklore, and watching the failsafe fire is the point. A student who ran it as root, or who
tried `--no-preserve-root` "to see" — stop them; that is outside the lab and the container is not
disposable to them.

**Distinction.** Noticing unprompted that `rm -rf /*` defeats the failsafe, and explaining it in
terms of expansion order rather than as a quirk.

## Stretch (38–42)

**Goal.** Build the safe habits: trash, `mktemp`, `trap … EXIT`, `find -delete`, and a correct
scepticism about `shred`.

**Accept.**
- **38:** a function that loops over `"$@"`, quotes its expansions, and produces distinct
  destination names. Two named downsides, any two real ones.
- **39:** the atomicity/ownership argument — `mktemp` creates the path itself, so it cannot already
  exist, cannot belong to someone else, and cannot be a symlink somewhere unexpected.
- **40:** a demonstrated run: nonzero exit **and** an empty temporary directory afterwards.
- **41:** the `-print` run shown before the `-delete` run, plus the non-empty-directory error.
- **42:** the two sentences must mention that the old blocks may survive the overwrite — journalling,
  copy-on-write, snapshots, or SSD wear-levelling. Any one mechanism is enough.

**Reject.** A `trash` function with `$1` unquoted or without a loop (that is the Level 5 near-miss,
and shipping it means the near-miss was skipped). "`shred` securely erases the file" stated flatly —
`man shred`'s own CAUTION contradicts it.

**Red flags.** An `EXIT` trap that was written but never triggered. Ask for the failing run.

## Dig (43–48)

**Goal.** Unlinked-but-open, and the two dangers that live in the shell rather than in `rm`.

**Accept.**
- **43:** the `(deleted)` suffix quoted from `/proc/<pid>/fd`.
- **44:** three `df` readings with reading two equal to reading one. Absolute numbers are free.
- **45:** `lsof +L1`, `NLINK` 0, and an explanation of `+L` as a threshold on link count.
- **46:** three sentences that (a) explain why `df` is honest, (b) name `lsof` as the way to find the
  holder, and (c) give a fix that is signalling/restarting the holder or truncating through
  `/proc/<pid>/fd/<n>`.
- **47:** a construction that actually fails, with the error shown, and the reasoning tied back to
  exercise 23.
- **48:** an answer built on **expansion order**. The failsafe compares arguments; the shell decides
  what the arguments are; therefore anything that expands to a list of ordinary paths is invisible to
  it.

**Reject.** "The file is still there, `rm` failed" for 43 — it succeeded; the *name* is gone.
"Reboot" or "delete more files" as the fix in 46. An answer to 48 that treats it as a bug in `rm`.

**Red flags.** A student who could not reproduce 44 because the reader died — check they backgrounded
`tail -f` and that they killed it only for the third reading.

**Distinction.** A 46 that mentions the descriptor-truncation trick *and* notes it destroys the data
the holder is still writing, so restarting the service is usually correct. That is the answer of
someone who has actually run out of disk at 03:00.

---

## Roll-up

**Clean pass.** All six tiers attempted; predictions written before every Experiment run; exercise
23's rule stated in terms of the directory and applied correctly in 26 and 47; both dash fixes with
the `./` generalisation; the unlink model used, not recited; 43–46 done with real evidence.

**Pass with notes.** The rule is right but arrived at by being told rather than by comparing 20–22
with 24–25; globs deleted without an `ls` check but nothing important was lost; Stretch attempted
with a working `trash` but no downsides named.

**Redo.** `chmod 400 protects a file` survives anywhere in the answers. Or the Experiment tier has no
written predictions. Or `keep-this.txt` was destroyed. Reset the lab and rerun the affected tier from
the top — this lesson is entirely reversible, which is the reason it is taught before the incident.

**Move on when** the student can answer, without looking: *whose permission decides whether a file
can be deleted, and what `rm` actually removes.* Everything in `05-incident-04` assumes both.
