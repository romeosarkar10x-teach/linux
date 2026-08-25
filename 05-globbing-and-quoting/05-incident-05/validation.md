# 05/05 — Validation

For the validating agent. No script grades this. Read the student's work and judge it against what
follows.

## The one thing that must be true

**The student separated the five designed survivors from the two accidents using evidence, and can
name the mechanism for each of the four ways `sweep.sh` fails.**

Finding the flag is not sufficient and never was. `shopt -s dotglob; cat -- *.log*` can be arrived
at by pattern-matching on names alone. What proves the incident was solved is the *discrimination*:
five files, weeks apart in time from the other two, each defeating one specific defect in a
four-line script, cross-checked against a naming convention that exists to detect a missing member.

## Must be present

1. The four mechanisms, correctly attributed: leading dash (defeats `rm`'s option parsing), leading
   dot (defeats `*`), embedded space (defeats unquoted `$f`), trailing tilde (defeats `*.log`).
2. Three of those four are the **shell**; only the dash is `rm`. The student must place the boundary
   correctly, especially for word splitting.
3. A reproduction: the student ran the loop from `sweep.sh` on a copy and observed exactly **one**
   loud failure — and can explain why the space file failed silently (`-f`).
4. That one failure agrees with `sweep-2187-06-01.log`. The log is accurate; the script is bad.
5. The two accidents identified as accidents, with both discriminators: mtime weeks earlier, and no
   `# tag:` line.
6. The glob, as one glob, with `dotglob` and with `--` (or a path prefix), and an account of why the
   output order is byte order and why the order matters.
7. The flag `KESTREL{named_to_survive_the_sweep}`, submitted.

## Should be present

- An explicit statement of what the timestamps do **not** establish — mtime is not creation time,
  and a batch write or restore produces the same cluster.
- The `dotglob`-off phrase (`named survive the sweep`) used as a worked example of the naming
  convention doing its job: a set that announces its own incompleteness.
- All four `STAGE{...}` tokens from the Dig, with the lesson each stage tests named.

## Common wrong answers

- **"The files were renamed to survive."** Not established. Nothing records a rename; only a last
  modification time. Downgrade any finding stated this confidently.
- **"The sweep log is falsified — it says 1 failure but four files survived."** The commonest and
  most seductive error. Three of the four mechanisms produce no `rm` invocation at all or a silenced
  one. The student must be able to say which.
- **"`rm -f` deleted the space file's two halves."** No. Neither `05` nor `readings.log` exists;
  nothing was deleted; `-f` swallowed both errors.
- **"Quoting would have saved `-strain-05.log`."** Wrong layer. Quoting protects text from the
  shell; the dash problem is in `rm`'s argument parsing. `--` or `./` is the fix.
- **"`*` matched the dotfiles and `rm` skipped them."** `*` never produced them. The failure is
  earlier than `rm`.
- **A named person.** The lab does not record who named the files. A finding that supplies a name
  has invented evidence and fails this lesson regardless of the flag.

## Red flags

- The flag with no reproduction of the sweep.
- `find`, a loop, or two globs used for the final selection — the constraint was explicit.
- The tag phrase assembled by reading the five files individually and ordering them by hand. Ask how
  they knew the order; if the answer is "it made a sentence", the ordering was not derived.
- Stage 3 solved by counting by eye. The stage exists so the student sees an unquoted `grep` return
  a wrong answer with no error.

## Sign-off question

> `sweep.sh` ran once and five files survived it. Walk the four mechanisms in the order the failure
> happens — earliest point in the pipeline to latest — and say for each one whether a pair of quotes
> around `$f` would have fixed it.

A correct answer orders them: pathname expansion never produces the dotfile or the tilde files
(quotes irrelevant — the name was never in the list); word splitting breaks the space file (quotes
fix it); `rm`'s option parsing rejects the dash file (quotes do **not** fix it — `--` does). Any
answer that claims quoting fixes more than one of the four has not separated the layers, which is
the entire chapter.
