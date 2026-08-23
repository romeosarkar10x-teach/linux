# 05/01 — Validation rubric

For the validating agent. There is no auto-grader for this lesson and there will not be one: almost
every answer is a filename list that depends on the student's working directory, and a script that
checks lists cannot tell "matched" from "passed through unmatched", which is the single most
important distinction in the lesson.

Ask the student to show commands **and** output. A correct list with no command behind it is not
evidence.

## The one thing that must be true

The student must be able to say, unprompted, that **the shell expands the pattern before the command
runs, and the command never sees the pattern**. Everything else in this lesson is a consequence.

Test it by asking what `ls` receives when they type `ls *.log` in `panels/`. The answer is eleven
separate arguments, listed. If they say "`ls` looks for files ending in `.log`", they have not got
it, whatever their exercise answers look like — send them back to exercise 37 (`set -x`) and ask
them to read the trace out loud.

## Must be able to do

1. **Predict, then verify.** Given a pattern and a directory listing, state the matches before
   running anything, then check with `echo`. They should be reaching for `echo` by reflex by the end;
   if they are testing patterns with `rm`, stop the session and fix that first.
2. **Explain the three no-match behaviours** — default pass-through, `nullglob`, `failglob` — and
   name one situation where each is the right choice (ex 38, 39, 44).
3. **State the two things `*` never matches**: a `/`, and a leading `.`. Both without hedging.
4. **Distinguish a match from a pass-through** when the pattern and the filename are spelled the
   same (ex 32, 34). This is the hardest single item; see below.
5. **Read a bracket expression correctly**: `[0-9]` is one character (ex 8), `[!p]` is negation,
   `[12][05]` is two independent choices and not a list of two numbers (ex 25).
6. **Say why `[a-z]` missed `A.txt`** in terms of byte values, having measured them (ex 30), and say
   why `[[:lower:]]` is the better habit (ex 31).
7. **Name the sweep survivors and the rule each one exploits** (ex 49–51), including that the
   leading-dash file is a different mechanism from the other three.

## Should be able to do

- Use `globstar` and say where `**` and `find` disagree (ex 41, 43), including that they returned the
  same *count* for different sets.
- Explain why `shopt -s extglob` and an extglob pattern cannot share a line (ex 46).
- Explain why glob results are not word-split but `$(...)` results are (ex 35).

## Common wrong answers, and what each one means

- **"`ls *.zip` failed because the glob failed."** No: the glob succeeded at doing nothing, and `ls`
  failed. Ask what the exit status belonged to.
- **"`echo [set].txt` matched `[set].txt`."** The commonest miss in the lesson, and it is not
  carelessness — the output really is identical either way. Do not correct it. Ask them to run the
  same pattern in `panels/`, where no such file exists, and let the identical output make the point.
- **"`*` matches everything."** Then ask for `.cfg` and for `deep/archive/2187-04.txt`.
- **"`?` and `[0-9]` are different lengths."** Exercise 8 exists for this. Have them count characters
  in `panel-7.log`.
- **"globstar doesn't follow symlinks."** Half true and the docs encourage it. Exercise 41's four
  measurements settle it; require all four, with the working directory shown for each.
- **"`nullglob` is just safer."** Have them run the `cp *.tmp dest/` case (ex 39) and read the error.

## Red flags

- Answers that match `solutions.md` phrasing rather than the student's own measurements.
- Any claim about this lesson's behaviour that was not run in this container. The whole method is
  measurement; a plausible answer from memory is a fail here even when it is correct.
- Testing patterns with `rm` instead of `echo`.
- Reporting `ls | wc -l` counts as file counts after exercise 20 has been done.

## Sign-off question

> The sweep note in `spec/` lists three patterns and says it does not recurse and does not set
> `dotglob`. Without running anything: name a filename that would survive all three patterns, and
> name one that the patterns *would* match but the sweep still could not delete. Say why, for each.

A student who answers both halves has the lesson. The second half — the leading-dash file, matched
by the glob and rejected by the command — is the one that separates "knows globs" from "knows what
happens when a glob meets a command", and it is the mechanism the rest of this chapter is built on.
Do not accept "because it starts with a dash" alone; require the word *option*.
