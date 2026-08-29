# 09/03 — Validation: Signals

For the validator agent. Judge understanding, not phrasing. No script grades this lesson.

## Must be right

A student passes this lesson only if all of these hold.

1. **A signal carries no data.** They can say that the only information in a signal is which one it
   is, and that there is no reply channel.
2. **The three dispositions**, and that KILL and STOP allow none of them. If they say "you can trap
   9 if you're root" or "you can trap it in C", they have not got it — nothing can.
3. **128+N**, applied in both directions. Given 137 they say KILL; given "killed by INT" they say
   130. They must also know this is a *convention* the shell reports and that a program can exit 143
   for its own reasons (exercise 15).
4. **What 9 costs, concretely.** The `bin/tidy` demonstration, in their own words, with at least one
   specific consequence: an unflushed buffer, a stale lock, a half-written record. "It's not clean" is
   not enough.
5. **A signal reaches one process.** They can state what happened to `bin/orphan-demo`'s child, and
   they must not believe that killing a parent kills its children.
6. **A zombie is a table entry, not a process**, and `kill` cannot remove one. They must know that
   what clears it is the parent reading the exit status.
7. **Why this station accumulates zombies** — pid 1 is `sleep infinity` and never reaps. If they call
   this a bug in the lab rather than a property of the container, probe further.

## Should be right

- STOP freezes and holds memory and open files; only CPU is freed (exercise 34).
- A TERM sent to a stopped process is pending and lands on CONT (exercise 36).
- Ctrl-Z is TSTP and catchable; STOP is not (exercise 37).
- The escalation order with a wait between steps, and that reaching KILL is a finding to record.
- A large zombie count is a pid-table problem, not a memory problem (exercise 46).

## The hard one

Exercises 23–25 and 23a/23b. Full marks needs **both halves**:

- a background job started by a **non-interactive** shell has INT and QUIT set to ignored, and
- a shell **will not install a trap for a signal it inherited as ignored**, silently.

A student who has only the first half will say "INT doesn't work in scripts", which is close enough
to keep going but should be pushed on: ask them why the `trap` line did not at least produce an
error. A student who read `SigIgn: 0000000000000006` and decoded it to INT and QUIT has done real
work — say so. A student who concludes `bin/catcher` is buggy has the wrong model and needs
exercise 24's `trap -p` demonstration before they move on.

Partial credit is fine here. This is the deepest fact in the chapter and it defeats experienced
people.

## Red flags

- **"`kill -9` is fine, I always use it."** The lesson did not land. Send them back to 26–29.
- **"Zombies are using up memory."** Ask for the number in `top`.
- Treating exit status as proof of cause without reservation (see must-have 3).
- Claiming to have written, or heard of, something that survives KILL (exercise 59).
- Answering exercise 49 with a rule ("never use -9") rather than a condition. rhea asked for what the
  machine does, and the useful answer is the fifth claim: needing 9 is a diagnosis.

## Not required

- Signal numbers beyond the table in `notes/signals.txt`. Nobody needs 34–64 memorised.
- Real-time signals, `sigqueue`, signal masks in C, or `sigaction` semantics.
- `bg`/`fg`/`jobs` — lesson 05.
- `pkill`/`pgrep` pattern precision — lesson 04. Exercise 14's over-broad match is a preview; a
  student who noticed it killed the wrong thing has done well, and one who did not is not behind.
- `/proc/<pid>/environ` and `lsof` — lesson 06. Exercise 60 only needs "the command line, the
  environment and the open files, and all three are gone once it is dead."

## Reporting exercises

48 and 50 are about restraint. A good answer to 48 says 137 means KILL *and* says the status does not
name who sent it. A good answer to 50 gives an operator a checkable condition, not a warning. Reject
anything in 48 or 50 that names a person; nothing in this lab supports that, and this chapter's
incident is coming.
