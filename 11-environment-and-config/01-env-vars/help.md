# 11/01 — Tutor notes

For the tutor agent. Guide with questions. Never hand over an answer the student can run a command
to get — and in this lesson every answer is one command away, which makes that rule cheap to keep.

## The one thing they must leave with

**A child gets a copy of the exported variables, made when it starts, and can never write back.**
Everything else in this lesson is a consequence. If a student can state that sentence and use it to
predict exercise 23's failure before running it, the lesson has landed even if their notes are thin.

## Where they get stuck

**Exercise 1's single quotes.** A student who uses double quotes gets `[05]` and concludes that
unexported variables *are* inherited. This is the single most damaging wrong turn available here, and
it looks like success. If their answer to 1 and 2 is "no difference", ask what expanded `$DECK` and
which process did the expanding. Do not tell them about the quotes — ask them to run
`bash -c 'echo hello $DECK'` and `bash -c "echo hello $DECK"` back to back and say which one bash
received a `$` in.

**Exercise 23 feels like a trick.** It is not, and the fix is to slow down on *when*. Ask: at the
moment `./bin/deck-report` starts, what does the shell copy? Then: on the one-line version, when is
`DECK` in the table? A student who says "the newline made it permanent" has it backwards — the
newline made it *ordinary*, and ordinary is unexported.

**Exercise 29–31 is the real cliff.** Three results that seem to contradict each other. Take them in
order and make the student say, each time, *how many processes ran*. Once they answer "one" for
`source` and "two" for `./`, exercise 31 usually resolves itself. If it does not, ask what `( )` is,
and whether the thing inside it was your shell.

**`export -n` versus `unset` (34–35).** Students routinely say "same thing". Ask them for a command
whose output differs. There is exactly one place to look and it is a child process; if they reach for
`echo` or `set` they will find nothing and conclude they were right. Push them to `bash -c`.

**Exercise 40.** Some students will run `unset $EMPTY`, see rc 0, and record it as success. Ask them
to check whether `EMPTY` is still there. The lesson is chapter 5's, arriving late: think about what
the command *received*.

**Exercise 51.** `env -i env` printing nothing surprises everybody, including students who got the
`bash -c` half right. If they are stuck, ask what is different about the two command lines — the
answer is that one of them has a shell in it. This is the exercise that most reliably separates
"I memorised that bash sets PWD and SHLVL" from "I know who sets what".

## Red herrings, and what to do with them

`logs/nightly.log` invites a hunt for the culprit. There is no culprit in this lab and no way to
identify one; the log has three identical lines and a date. A student building a theory about *who*
changed the job should be asked what evidence in the lab supports it. The correct answer to
exercise 62 names a class of thing. rhea's note says so explicitly, and a student who ignores a
written instruction from the person who asked for the work has a problem this lesson cannot fix but
you should name.

`bin/set-station` looks like a broken script. It is not; it does exactly what it says, in the process
that runs it. If a student calls it a bug, ask them to point at the false statement in its output.

## Integrity check

Exercise 59 asks them to confirm rhea's claim about the mtime. A student who writes "confirmed"
without running `stat` has failed the exercise even though the answer is right — rhea specifically
told them not to take her word for it. Ask for the timestamp. It is `2186-07-19 04:31:00`; a student
who has it, ran the command.

## After the answers

If they finish early, the questions worth asking:

- "You have `DECK` exported. I start a program now, then you `unset DECK`. Does the running program
  lose it?" (No. Snapshot at start. This is the half of the rule nobody tests.)
- "`env` shows twelve variables. Where did each one come from?" Three sources: the image, the
  `docker exec`, and `.bashrc`. Splitting them correctly is lesson 03's entry ticket.
- "What is in `PATH` that bash's default does not have, and who put it there?" This is the handoff to
  lesson 02 and they should be left holding the question, not the answer.
