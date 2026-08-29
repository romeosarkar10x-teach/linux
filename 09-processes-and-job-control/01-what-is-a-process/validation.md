# 09/01 — Validation

For the AI tutor. Judgement only; there is no grading script and there must not be one. Pids differ
on every run — never check a pid value, check a relationship.

## Passing this lesson

The student can:

1. **Separate program from process.** Says, unprompted or when asked, that one file on disk can be
   several running processes, and does not use "the program" to mean "the running thing" when it
   matters.
2. **Read the four identity fields.** Gets pid, ppid, user and start/elapsed time for any process on
   the station, and knows which `ps` invocation gives each.
3. **Explain fork and exec separately.** Fork duplicates and produces a new pid; exec replaces the
   program and keeps the pid. Can point at `bin/nest` as the evidence for exec and `bin/forker` as the
   evidence for fork.
4. **Justify builtins from the model.** Explains why `cd` cannot be an external program using the fact
   that a child cannot change its parent's state.
5. **Use `ps -eo`.** Builds a column list for a specific question rather than running `ps aux` and
   reading with their eyes. Bonus if they use the trailing `=` before a pipe.
6. **Locate a parent from data.** Given a family of processes, identifies the parent from the PPID
   column and says so, rather than from the order of output.
7. **Know what killing a parent does.** States that children survive and are re-parented to pid 1. This
   one matters more than it looks; the incident turns on it.
8. **Treat `args` as a claim.** Says the `CMD`/`args` column is set by the caller and is not proof of
   which program is running. Ranks `/proc/PID/exe` above `comm` above `args`.

## Signals the student is not there yet

- Believing plain `ps` shows the machine. Ask them what `ps -e --no-headers | wc -l` gives and why it
  is bigger.
- Thinking `exec` starts something. Send them back to `bin/nest` and ask for the pid on each line.
- Thinking a pid identifies a program for all time. Ask what happens to a stored pid after the process
  exits. If they have not met reuse, that is fine at this stage — but they should not be confident.
- Reaching for `grep` on `ps` output to select by user or by name when an option does it.
- Any claim that killing a parent kills its children. Have them run exercise 29 and read the PPID.
- Concluding from `CMD` alone that a named program is running. This is the misconception Chapter 12
  will exploit; correct it here, gently, and let them keep the habit.

## Roleplay and tutoring notes

- rhea's page asks for a method, not a result. If the student rushes to diagnose the load in this
  lesson, redirect: the diagnosis is lesson 07's, and jumping to it here means guessing.
- Do not confirm or deny anything about the station's actual load. The student has no evidence yet.
- If the student asks whether something is scheduled, do not answer for the station. Let them find, in
  09/06 and 09/07, that nothing on this station schedules anything.
- Never hand over a `ps -eo` line. Ask which column would answer their question, and let them find the
  name in `notes/ps.txt` or `man ps`.

## Not required here

Signals, `kill`, job control, `/proc` beyond `exe`, `nice`, `top`. All later in this chapter. A
student who wanders into them early has not failed anything; bring them back to the tree.

## Flag

None in this lesson.
