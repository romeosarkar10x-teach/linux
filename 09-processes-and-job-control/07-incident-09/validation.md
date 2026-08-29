# 09/07 — Validation

For the validator agent. Rubric only. Ask for the command and its output, not the conclusion. Ask the
question in exercise 41 of every student, whatever else they got.

## Must be able to do

1. Identify the busiest process on the station by PID, user and command line, using `ps --sort=-pcpu`
   or `top`, and state its `%CPU` — around 50 — without calling the station overloaded.
2. Read the load average correctly against `nproc`: one runnable process on a 24-CPU station is not a
   capacity problem, and the finding is that the station is never idle, not that it is saturated.
3. Show the process has parent 1 and no controlling terminal, and name both ways that happens.
4. State that `etime` cannot date this job, and say what can: `LR_STARTED` in the environment and the
   `started` field in `records/lr-07.txt`, which agree on 2186-10-06.
5. Connect `--tag lr-07` on the command line to `records/lr-07.txt` without being told to.
6. Read `cwd` and the `fd` listing under `sudo`, identify fd 9 as deleted-but-open, recover its
   contents, and say what would have happened to those bytes had the process been killed.
7. Hit the `sudo … < file` redirection error and diagnose it correctly: the shell opened the file, not
   `sudo`.
8. Read the environment, order the note fields numerically, submit the flag, and explain why
   `grep -r` could not have found it.
9. State the constraint in their own words before being prompted: killing the process destroys the
   only copy of the launch note.

## Strong answers look like

- Exercise 5 and exercise 54 written as one careful sentence each: the correlation is real, the cause
  is elsewhere, and rhea is not treated as an opponent.
- Exercise 13 answered as two different questions with two different answers.
- Exercise 43 answered honestly — that killing first would have left them with a launch record, a
  blank authorisation field and no note at all.
- Exercise 57 listed in a sensible order, with the copy of fd 9 taken before anything else.
- A student who killed the process, lost the flag, reset, and can say exactly what they lost has
  learned the lesson. Mark that as a pass with the reason stated.

## Red flags

- Reporting "it has been running for eight months" citing `etime`.
- Any narrative naming a person, or reading the blank `authorised` field as evidence of concealment.
  Blank means blank.
- Claiming the station is overloaded, or reading the load average as a percentage.
- Reporting that rhea was wrong, without conceding the timing.
- Killing the process as the first action, and then reporting the incident from `records/` alone.
- Submitting a `STAGE{}` token as the flag.
- Claiming `grep -r KESTREL` failed because the lab is broken.
- Sending `SIGTERM` to `bin/warden` and reporting the Dig as impossible.

## Partial credit

A student who found the flag but cannot answer exercise 41 has solved a puzzle and missed the
chapter. Send them to `readme.md`'s rule and ask again.

A student who diagnosed the runaway, answered rhea well, and never opened fd 9 has done the job and
missed the deck log. Ask them what the process is working on and where its output goes.
