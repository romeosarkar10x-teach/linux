# 09/06 — Help

For the tutor agent. **Never give the answer.** This lesson is unusually easy to spoil, because most
of its answers are one command long. Ask for the command, not for the conclusion.

## What this lesson is for

It is the hinge of the chapter. Lessons 01–05 built the vocabulary for talking *about* processes;
this one is about interrogating *one* process. The next lesson is an investigation that fails
completely if the student's reflex is to kill first, and the sentence that has to land is:
**a process's environment exists in that process and nowhere else.**

If a student finishes this lesson able to run every command and has not internalised that sentence,
they have not finished this lesson. Exercise 16 is where it lands; do not let them answer it in three
words.

## The common stumbles

- **`cat /proc/PID/cmdline` looks broken.** Do not explain NULs. Ask them to pipe it through
  `od -c`. They will see it.
- **`grep` on `environ` "works"** and they conclude NULs do not matter. Ask what `grep -c` returns
  and why. The whole file is one line as far as `grep` is concerned, and `grep` may want `-a`.
- **Permission denied on another user's `environ`.** That is the correct result and it is the point.
  Ask who owns the process and what the mode said in exercise 13.
- **`exe` is `/usr/bin/bash`** and they think they did it wrong. They did not. Ask what is actually
  executing when you run a shell script.
- **`sleep`'s `exe` is a coreutils path.** Ask them what happens if they run
  `readlink /proc/<pid>/exe` for `ls`, `cat` and `sleep` and compare. A multicall binary is a fine
  thing to discover rather than be told.
- **Deleted-but-open confusion.** Ask where they think the bytes went. Then ask what `df` says. The
  gap between `du` and `df` is the classic real-world version of this and worth mentioning as a
  *symptom*, not as an answer.
- **`renice` back down fails** and they assume the lab is broken. Ask them to read the error and then
  read `notes/priority.txt`. It is a real kernel rule and the surprise is the lesson.
- **Exercise 45 (`nice -n -5`).** Many students will report "it failed". Ask what `true` did and what
  `$?` was. The command ran.

## Exercises worth slowing down on

- **15–16.** The distinction between "the environment now" and "the environment it was given" is what
  makes `/proc` evidence rather than configuration. If they answer 16 with "nowhere", ask them to say
  it as a sentence they would put in a report.
- **28–30.** Reading a file through `/proc/<pid>/fd/9` when the name is gone is the moment `/proc`
  stops being trivia.
- **50.** They will expect nice 19 to be visibly slower. It is not, because the container has 24 CPUs
  and no contention. Do not pre-empt this; let them measure it and then ask what niceness is for.
- **65.** This is lesson 07's briefing in disguise. Let them write the list. If they miss `environ`,
  ask which of their items disappears when the process does.

## Things not to say

- Do not name the five reads for exercise 52. That ordering is theirs.
- Do not tell them the space is not freed until the last descriptor closes; ask them to check `df`
  before and after the kill in exercise 30.
- Do not connect this to the next lesson out loud. rhea's page already does it.

## Cleanup

`jobs -p | xargs -r kill`, then `pkill -u $USER -f 'bin/(tagged|wanderer|holdopen|reader-of|spin)'`.
If a student niced something and cannot un-nice it, that is the ratchet working; the process will
exit on its own.
