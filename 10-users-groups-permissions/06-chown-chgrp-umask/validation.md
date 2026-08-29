# 10/06 — Validation rubric

For the validator agent. No script grades this lesson. Judge the written answers and the lab state.

## Non-negotiable

1. **A file stores a uid and a gid — numbers.** Names come from a lookup performed at display time.
   Exercises 4, 6, 14, 69. A student who says the file "lost its owner" or "has no owner" has not
   passed; the file has uid 4102 and always did.

2. **`chown` is root's, and no `chmod` reaches it.** Exercises 10, 11, and one concrete reason at 12
   (quota, or setuid — either is acceptable, setuid with a mechanism sketch is better).

3. **The `chgrp` rule has two halves**: own the file, *and* be in the target group. Exercises 20, 22.
   One half is a fail; both, stated as a conjunction, passes.

4. **A new file's group comes from the creating process, not the directory** (25, 26), with the `sg`
   experiment cited as the evidence rather than asserted. Exercise 27 should guess "something on the
   directory" and defer; a student who invents a wrong mechanism confidently is worse than one who
   says they do not know.

5. **umask is a mask of bits removed, applied only at creation.** Exercises 48 (arithmetic written
   out), 52 (`umask 000` is permissive), 55 (existing files unaffected), 57 (`chmod` is not masked).
   All four.

6. **The three symlink behaviours** (40), correct and distinguished: `chmod` always follows;
   `chgrp` without `-R` follows; `chgrp -R` does not, and changes the links themselves.

## Should be present

- `getent passwd 4102` returning nothing, and the student noting it cannot distinguish "deleted" from
  "never existed" (5, 7).
- `chown USER` with no colon leaves the group alone (31/32) — the row students get wrong.
- `chown USER:` sets the group to that user's login group (30).
- `--reference` copies **both** columns (33).
- `-c` prints nothing on the second run (35).
- Exercise 42: `stat` did not follow the link, `chgrp` did — stated as two tools with two defaults.
- `-nouser` means "the uid does not resolve" (62).
- `cp -p` kept the group and silently dropped the owner, and why that was inevitable (60).
- Measured umask results present and correct: `077` → `600`/`700`; `002` → `664`/`775`; `000` →
  `666`/`777`; `u=rwx,g=rx,o=` → `0027` → `640`; `mkdir -m 755` under `077` → `755`.

## Exercise 7 and 66 — the integrity check

`intake/unclaimed.raw` supports: uid 4102, gid 4102, 29 bytes, mode 644, mtime 2187-06-18 23:12, no
matching account, and its contents. It supports **no person, no motive, and no event**.

A student who names anybody, asserts an account was deleted, or builds a narrative from the timestamp
has failed this part regardless of the quality of the rest — and should be told which specific claim
outran the evidence. Credit answers that say plainly what cannot be determined from here. Exercise 66
must carry that restraint into rhea's reply, and its second paragraph must name the mechanism
(process primary group) rather than proposing to run `chgrp` more often.

## Judgement answers

- **67** needs two reasons, one of which is the window between creation and the next run.
- **68**'s `owned-by` must validate the account *before* running `find`, exit 1, and print to stderr.
  `id -u` or `getent passwd` are both fine; parsing `/etc/passwd` by hand is worse and should be
  noted.
- **69** must state that the file did not change — not one byte, not the mtime, not the inode — and
  that what the new account gained is the owner's authority, including `chmod`, regardless of the
  other two triads.

## Lab state

The lesson changes groups in `handoff/` and `mixed/` on purpose. Expected after a complete run:

```
handoff/*.txt          group crew, mode 640, owner cadet
handoff/probe.txt      deleted (exercise 28)
handoff/probe2.txt     deleted (exercise 28)
mixed/                 restored per exercise 45: everything cadet except
                       logs/beta.log (ops) and data/counts.csv (crew)
intake/unclaimed.raw   back to 4102:4102 (exercise 13) -- check this one
intake/cycle-41.raw    root:root, untouched
intake/cycle-42.raw    rhea:crew, untouched
umask in their shell   0022 (exercise 54 asked them to set it back)
```

If `intake/unclaimed.raw` is still `cadet:crew`, they did the first half of exercise 13 and not the
second; that is a real miss, since the rest of the lesson reads that file. Nothing outside the lab
directory may have changed ownership — check with `sudo find /labs -newer …` if there is any doubt,
and ask before assuming.

## The failure that looks like success

Every command run, every mode and group correct, and exercise 7 answered with a confident paragraph
about who used to own uid 4102. That student has learned the tools and not the discipline, and this
chapter is where the discipline starts mattering. Probe with: "Which command's output supports the
sentence you just wrote?" If the answer is none, the exercise is not passed.
