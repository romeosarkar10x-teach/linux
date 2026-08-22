# Chapter 12 — story

**Chapter arc.** **Trace 12** — the adjustment itself, in source, readable. A script named for
cleaning up that mostly rewrites values above a threshold in place and logs the run as a cleanup.
Not dorn's hand; this one is the thing he found.

The student can finally *see* it here and cannot yet prove what it means. That is Chapter 14's job.

Roleplay: **ops-bot**, which reports the script's own log line — "cleanup complete, 0 files removed"
— and considers the matter closed.

---

### `01-first-script`
> Everything you have typed twice this month is a script you have not written yet.

### `02-arguments`
> A script that only works on one file is a note to yourself. The difference is about four
> characters and one of them is a quote mark.

### `03-conditionals`
> Three ways to test the same thing, one of which is a builtin that behaves differently, and the
> station's older scripts use all three.

### `04-loops`
> Reading a file line by line is where most shell scripts quietly break on the first filename with
> a space in it.

### `05-case-and-functions`
> `case` is how a script with four modes stays readable. It is also how a script hides a fourth
> mode nobody reads down to.

Quiet setup for the incident's red herring. Do not lean on it.

### `06-input-and-arithmetic`
> Shell arithmetic is limited, awkward, and enough. Knowing exactly where it stops is what keeps you
> from writing something worse than the problem.

### `07-robust-scripts`
> A script that fails silently in the middle is worse than one that never ran. Four lines at the
> top prevent most of it, and `shellcheck` catches most of the rest.

### `08-ship-a-tool`
> `stationctl`. Executable, on your PATH, with a `--help` that answers the question people will
> actually ask. This is the first thing you will leave behind that is better than what you found.

Deliberate echo of `notes.txt` containing `later`. Never state the comparison.

### `09-incident-11` — the incident
> There is a housekeeping script in the ops tree. It is named for cleaning up. Read it before you
> run it.

Write the audit tool, don't fix the script. The flag is produced by the student's own tool against
the ops tree — it exists nowhere until their script is correct.
