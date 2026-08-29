# 10/05 — Validation rubric

For the validator agent. No script grades this lesson. Judge the written answers and the lab state.

## Non-negotiable

1. **Numeric is absolute; symbolic is relative.** Stated as such, and used correctly in exercises 15
   and 19 — they can say which of the six symbolic commands could not have been written numerically
   without first reading the mode, and why. An answer that treats `chmod 755` as "adding execute" has
   not passed.

2. **The symbolic sequence, 9–14, is correct.** The measured chain from `000` is
   `400, 420, 421, 531, 661, 700`. Exercise 13 must explain that the `other` triad kept its `x`
   because `ug=` names only two triads — `=` is absolute within the triads it names, not across the
   file.

3. **`chmod` requires ownership, not any of the nine bits** (22–25). Exercise 25's answer is "no such
   mode exists, and it could not" with an argument — a bare "no" is half credit.

4. **Deletion is a directory operation.** Exercises 43–49. They must have run `rm drop/theirs.txt`,
   found it succeed, and explained it in terms of the directory's write bit rather than the file's.
   Exercise 49 must split cleanly: directory mode stops deletion, file mode stops editing.

5. **Both halves of `X`** (56). Directories, *and* files that already have execute set for at least
   one triad. One half is not the answer.

6. **`chmod` follows symlinks** (62, 63): `chmod 600 scratch/link` changed `notes/chmod.txt`, and the
   link still reads `lrwxrwxrwx`. A student who reports the link's mode changed did not check.

## Should be present

- `chmod 4` means `chmod 004` (exercise 5) — left-padded, not right.
- Exercise 16's result is `200`, and they noticed it was not `222`. They are not expected to explain
  umask; they are expected to record the discrepancy rather than mistype it away.
- `-c` prints only actual changes and `-v` prints every file (59).
- `--reference` used, and one sentence on when it beats digits (58).
- Exercise 57: recursive `chmod` fixes a directory before descending into it.
- Exercise 51 guesses something equivalent to "write, but you may only delete your own" for `1777`.
  The name is not required; the behaviour is.
- Exercise 67 names `-type f` and says why — symlinks are always `lrwxrwxrwx` and are a false
  positive, not a finding.

## The four repairs, 26–40

Each of the four needs a command **and** a justification tied to the stated use in `repair/NOTES`.
Measured end states, and the fix must be no larger than these:

```
repair/collect.sh    755   (or 750 via a+x from 640 — accept anything that adds x and nothing else)
repair/id_station    600
repair/handover      775   (the change is g+w, on the directory)
repair/exporter.conf 600
```

Reject any answer that reaches the right mode by a route that grants more than asked — `777`, `666`,
`chmod -R` anywhere in `repair/`, or `a+w` on the key. Reaching `600` on `id_station` via `go-r` is a
correct end state with a weak argument; exercise 30 asked for the reasoning, so mark the reasoning.

**Exercise 33 must state that another `crew` member can delete `week-24.txt`** despite the file being
`644` and owned by the student. This is the exercise the lesson is built around. Exercise 34 should
record the unease without resolving it; a student who has already invented the sticky bit is not
wrong, but should not be credited for guessing ahead of the evidence.

**Exercise 36** must name three distinct grants of `777` and rank them with an argument. Read is the
defensible top answer (the token leaks to everyone, no intent required); write is defensible if
argued on impact. "All three are equally bad" is not a ranking.

**Exercise 39, rhea's reply.** Four lines plus a close. Must fix all four, must attribute the fault to
the mode and not to a person, and must not pretend 777 was acceptable. A reply that blames whoever
typed it fails this exercise; so does one that never says the mode was wrong.

**Exercise 40** should separate the two mechanically-findable mistakes (`id_station`, `exporter.conf`
— both visible in `ls -l` and reachable by `find -perm`) from the two that need to know intent
(`collect.sh`, `handover/`). The conclusion — sweeps find excess, never absence — is the point.

## Written answers

- **45** must reduce to "a directory is a list of names" in the student's own words, applied to `rm`.
- **69** must contain: the directory governs names, the file's mode governs contents, and at least one
  concrete alternative (sticky bit, owning the parent directory, immutability). A three-sentence
  answer that only restates the split has not addressed the question.
- **68**'s `harden` must refuse on `drop/theirs.txt` *before* calling `chmod`, and print before and
  after modes. `[ -O "$f" ]` or a uid comparison; a `%U`-versus-`whoami` string compare is acceptable
  but weaker.

## Lab state

The lesson deliberately changes `repair/` and `tree/`. Expected after a complete run:

```
repair/collect.sh    executable
repair/id_station    600
repair/handover      775
repair/exporter.conf 600
tree/                755, with tree/bin/run and tree/bin/helper 755 and the CSVs 644
drop/theirs.txt      gone (exercise 43)
notes/chmod.txt      644  — if it is 600, they did exercise 62 and did not put it back
```

Nothing outside the lab directory may have changed. Reseed before lesson 06.

## The failure that looks like success

Every command run, every mode correct, and exercise 43 answered with "because I have permission".
That is the restatement, not the explanation. Probe with: "You could not write one byte of that file.
Name the thing you *did* have permission to modify." If the answer is not the directory, the central
idea of the lesson is missing regardless of the rest.
