# 04/02 — Validation: `touch`, `mkdir` & Brace Expansion

For the validating agent. No auto-grading. Read the student's log, check the values, apply the
rubric. If a number disagrees with the table below, ask the student to re-run **before** marking it
wrong — a dirty lab explains most mismatches, and `kestrel reset 04/02` is the fix.

---

## Reference values (measured in the image)

| Thing | Value |
|---|---|
| `umask` | `0022` |
| plain `mkdir` mode | `drwxr-xr-x` (0755) |
| `touch` mode | `-rw-r--r--` (0644) |
| `mkdir -m 777` mode | `drwxrwxrwx` — umask **not** applied |
| `mkdir -p -m 700 perms/x/y/z` | only `z` is 0700; `x` and `y` are 0755 |
| deck-03 subtree | 23 directories |
| deck-04 subtree | 31 directories |
| `find build -type d \| wc -l`, complete build | **55** |
| `echo bay-{01..06}` | `bay-01 … bay-06` |
| `echo bay-{1..6}` | `bay-1 … bay-6` (no padding) |
| `echo bay-{01}` | `bay-{01}` — not an expansion |
| `echo {1..10..3}` | `1 4 7 10` |
| `echo file-{a..c}-{1..2}.txt` | six words, rightmost varies fastest |
| `echo {a,b}*` with files `a1 a2` | `a1 a2 b*` |
| `mkdir existing/deck-03/bay-01` | `File exists`, rc 1 |
| `mkdir -p existing/deck-03/bay-01` | rc 0 |
| `mkdir -p existing/deck-03/bay-02` | `File exists`, rc 1 (bay-02 is a file) |
| `mkdir -p existing/deck-03/bay-02/readings` | `Not a directory`, rc 1 |
| `mkdir -p` under a `chmod 500` parent | `Permission denied`, rc 1, nothing created |
| `rmdir -p build/x/y/z` | removes `z`, `y`, `x` **and `build`** |
| `touch -c missing` | rc 0, no file created |
| `touch -r` | copies atime **and** mtime |
| `touch -d 1969-01-01` | succeeds (pre-epoch, negative seconds) |
| `touch -d 1901-01-01` | clamps to `1901-12-13 20:45:52`, rc 0 |
| `touch -d 2500-01-01` | clamps to `2446-05-10 22:38:55`, rc 0 |
| `ls -Z` | `?` for every entry (no LSM in this container) |
| seeded mtimes | anchor 2187-05-17 04:02, one 2187-05-17 09:30, two 2187-05-18 22:15 |

No flag in this lesson.

---

## Per-exercise rubric

### Warmup 1–4 — brace expansion is textual

**Goal.** See that padding comes from the first element and that a brace group without a comma or
`..` is not an expansion at all.

**Accept.** Ex 1: all three outputs, with the observation that `{01..06}` pads and `{1..6}` does not,
attributed to the **first** element's width. Ex 2: eight words. Ex 3: `bay-{01}` verbatim, and
`bay-01 bay-` for `{01,}`. Ex 4: the `No such file or directory` error, then rc 0, then rc 0 again.

**Reject.** "Braces expand to a range" as the whole answer to ex 3 — the exercise is about when they
do not. Any claim that the upper bound controls padding.

**Red flags.** Outputs copied without the leading `bay-` prefix suggests they ran `echo {01..06}`
and did not read the exercise.

**Distinction.** Notices that the second `mkdir -p` in ex 4 returning 0 is what makes `-p` usable in
a script that may run twice.

### Core 5–11 — what `mkdir -p` forgives

**Goal.** Three distinct failure modes, three distinct messages, and a precise statement of the
single case `-p` forgives.

**Accept.** Ex 9 and 10 as two *different* errors — `Not a directory` for the path-component case,
`File exists` for the target case — with the reason: a file cannot be descended through. Ex 11
phrased as a conjunction: rc 0 only if **every** component including the last is already a
directory.

**Reject.** "`-p` ignores errors." "`-p` makes it work." Merging ex 9 and 10 into one answer.
An ex 11 answer that says "if the directory exists" without qualifying *directory*.

**Red flags.** A student who ran ex 10 before ex 9 will usually have lost the distinction; have them
`kestrel reset 04/02` and redo in order.

**Distinction.** Notices that `mkdir`'s ex-9 message names `bay-02`, not the full path it was asked
for, and works out that `mkdir` reports the component it failed at.

### Core 12–20 — build the tree

**Goal.** Read a spec, spot the two traps, and produce the tree with a small number of expansions.

**Accept.** deck-03 = 23 and deck-04 = 31 in ex 12, arrived at by counting, not by building first.
Ex 17 = **55**, with `build` accounted for. Ex 19's answer must be that a single widened range gives
deck-03 bays 05 and 06 that the spec does not have. Ex 16 may use nested braces or two words; both
are correct.

**Reject.** A tree built with forty `mkdir` calls and no brace expansion — this is a **Redo**, not a
pass, because it is the thing the lesson exists to replace. Bays named `bay-1`. Any `panel-08`,
`panel-09` or `panel-10` (from `panel-{07..11}`).

**Red flags.** 54 in ex 17 — the tree is right, they forgot `build` counts; accept with a note.
Any other number means leftover directories; ask what else is under `build`.

**Distinction.** Builds deck-03 and deck-04 in one command line, and can say why one range cannot
serve both.

### Core 21–27 — modes, umask and `-m`

**Goal.** Derive 0755 and 0644 from the umask, then show that `-m` bypasses it.

**Accept.** Ex 21 as `0777 & ~0022 = 0755`. Ex 22 must explain the 0666 base — the kernel does not
grant execute on a new file. Ex 23's `drwxrwxrwx` is the proof and must be identified as such. Ex 25:
only the final component gets `-m`. Ex 26 must report that `rmdir -p` removed `y` and `x` too.

**Reject.** "`-m` is the same as `chmod`." Ex 24 answered without naming the window — the answer is
that the directory sits at 0755 between the two commands and anything can enter it then.

**Red flags.** A 0777 answer for ex 23 stated as "because I asked for 777" with no contrast against
ex 21; the contrast is the whole exercise.

**Distinction.** Ex 24 extends the race to the case where the attacker holds an open descriptor or a
hard link across the `chmod`, and notes permission is checked at open time.

### Core 28–30 — `touch` and the three times

**Goal.** Creation as a side effect, `-c` suppressing it, `-r` copying both times, and ctime moving
regardless.

**Accept.** Ex 28: rc **0** with no file created. Ex 29: `times/one.txt` becomes 2187-05-17 04:02 —
both atime and mtime. Ex 30 must name **ctime** as the one that moves uninvited, in both commands.

**Reject.** Ex 28 answered with a nonzero exit status. Ex 30 answered with only `%y`, having never
looked at `%z`.

**Red flags.** A student who ran plain `touch` on `anchor.txt` early has destroyed the seeded
reference time for ex 29; reset.

**Distinction.** Connects ctime to Chapter 3 lesson 04 without being prompted: it is not settable
because it records that the inode changed.

### Experiment 31–32

**Goal.** The written prediction, then the wrong part named.

**Accept.** A prediction recorded **before** the run. Ex 31 must note that the rightmost group varies
fastest. Ex 32 must report **four** arguments and directories scattered into the cwd, not under
`build`, plus a cleanup of three separate names.

**Reject.** Any Experiment answer with no prediction, or with a prediction that suspiciously matches
the output exactly. Predicting is the exercise; being wrong is a pass.

**Red flags.** Ex 32 cleaned up with a single `rm -rf` and no statement of what was removed.

**Distinction.** Ex 31 predicts the odometer order (rightmost fastest) correctly and says why —
brace expansion is a nested loop with the last group innermost.

### Stretch 33–38

**Goal.** One command line for the whole tree; a defensible position on braces versus loops; the
timestamp boundaries.

**Accept.** Ex 33: one `mkdir` invocation, 55. Ex 34: **either** side argued, with reasons — this is
a judgement exercise and both answers are correct; only "no reasoning" fails. Ex 35: ten `.keep`
files. Ex 36: three identical md5 sums and the observation about `set -e`. Ex 37: both `--` and
`./`, and ideally that they work at different layers. Ex 38: all three of 1971/2187/**1969** succeed,
then the two clamps `1901-12-13 20:45:52` and `2446-05-10 22:38:55`, both at rc 0.

**Reject.** Ex 38 claiming 1969 fails — it does not; the field is signed. Ex 38 reporting the clamps
as errors — `touch` exits 0 and says nothing, which is the finding.

**Red flags.** Ex 33 done as two command lines and reported as one. Ex 37 offering only `--`.

**Distinction.** Ex 37 argues `./` is the more portable habit because it needs no cooperation from
the command. Ex 38 recognises `2446-05-10 22:38:55` as the same ext4 ceiling met in Chapter 3.

### Dig 39–42

**Goal.** Partial-failure semantics, expansion order, the race argued concretely, and a flag that
does nothing here.

**Accept.** Ex 39: rc 1, `Permission denied`, **nothing created**, with `find` as evidence, and the
nuance that `-p` is not atomic in general. Ex 40: `a1 a2 b*` with the correct order — brace first,
then globbing, and `b*` survives literally because it matched nothing. Ex 41: a concrete scenario, and
for files the recognition that there is no `-m` on `touch` so the answer is the umask or `install -m`.
Ex 42: `?` for every entry, because no LSM supplies a context here.

**Reject.** Ex 40 claiming globbing runs first. Ex 42 concluding `-Z` is broken.

**Red flags.** Ex 39 reported from reasoning rather than from a run — the `find` output must be in
the log.

**Distinction.** Ex 40 states the full order (brace, then parameter/command/arithmetic, then
pathname) and that brace expansion is purely textual, which is why it can name things that do not
exist.

---

## Roll-up

**Pass** — the tree is built with brace expansion and counts 55; the three `mkdir` errors are
distinguished; `-m` versus umask is demonstrated with `drwxrwxrwx`; `touch -c` rc 0 and `-r` copying
both times are reported; both Experiments have predictions written before the run.

**Redo** — the tree was built with one `mkdir` per directory; or ex 9 and 10 are collapsed into one
error; or Experiment predictions are missing or back-filled; or ex 38 asserts that pre-epoch dates
fail.

**Distinction** — one command line for the full tree, ctime identified unprompted in ex 30, the
`mkdir`/`chmod` race argued with an open descriptor or hard link surviving the `chmod`, and the
expansion order in ex 40 stated in full.
