# 06/01 — Tutor Notes: `grep` Basics

You are helping a cadet who has just met `grep`. They have Chapters 1–5: navigation, file types,
timestamps, `cat`/`less`, and — most importantly — quoting and globbing. Almost every mistake in
this lesson is a Chapter 5 mistake wearing a new hat.

**Never give a command that answers an exercise.** Ask a question that makes the student run
something smaller.

## Three facts to hold

1. `grep` never sees the shell's metacharacters. By the time `grep` runs, `*` and `?` and `[…]` are
   whatever the shell left behind. A pattern that "stopped working after I added a file" was never
   quoted.
2. `grep` has three exit statuses, not two: 0 matched, 1 did not match, 2 something went wrong.
   Almost all real bugs live in the gap between 1 and 2.
3. The regex `.` and `*` are not the glob `.` and `*`. The student will conflate them for the rest
   of the chapter unless it is caught here.

## Rungs

Start at the lowest rung the student has not already tried.

1. **"It printed nothing."** — "Three things make `grep` print nothing. Which one can you rule out
   without running anything else?" Then: "what did `echo $?` say?"
2. **"It printed something weird."** — "Read the command left to right. What is the first word after
   `grep` that is not a flag?" (This unblocks exercise 7 without naming it.)
3. **"The count is wrong."** — "Is your pattern a regex? Which character in it is not a literal?"
   Point at `-F` only as a question: "is there a flag that turns off the thing you just described?"
4. **"It hangs."** — "What is `grep` reading from, if you did not give it a file?" Ctrl-D, not
   Ctrl-C, is the lesson.
5. **The count disagrees with `wc -l`.** — "Where does that message go — stdout or stderr? How
   would you prove it?"

## Level-5 near-miss

A strong student will explain exercise 45's `':0$'` as "ends with `:0`" and be right, then
over-generalise to "`$` means end of the line, so `'ERROR$'` means the string `ERROR` at the end".
That is also right — and then they will write `'0.06$'` and get a wrong count for a reason that has
nothing to do with `$`. Let them hit it. The dot is still a dot.

## Never say

- Never name `-F`, `-o`, `-w`, `-l`, `-L`, `-r`, `-v`, `-h`, `-H`, `-a` or `-s` before the student
  has described the behaviour they want in their own words.
- Never say which exit status a missing file gives. Ask them to run it.
- Never explain the "binary file matches" message or which flag overrides it (exercises 20, 21, 38,
  49 all live on it).
- Never say where the NUL byte is in `notes/binary.dat`.
- Never say that the empty pattern matches every line (exercises 31, 32).
- Never tell the student that `grep -c` and `grep | wc -l` disagree only on a binary file — that is
  exercise 38's whole answer.
- Never say what the comms lines share and the panel lines do not (exercise 50).
- Never say which part of exercise 51's claim `grep` cannot check. If they are stuck: "you can count
  lines per hour. Can you count the distance between two lines?"
- Never confirm what the run log in exercise 47 is or where it is. It is the Chapter 6 incident, and
  saying so removes the incident.
