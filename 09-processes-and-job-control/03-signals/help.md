# 09/03 — Help: Signals

For the tutor agent. Do not give the student the answer. Ask the question that makes the machine
answer it for them.

## The shape of this lesson

The student arrives believing `kill -9` is `kill` with more force. Everything here is arranged to
break that belief with evidence rather than assertion: `bin/tidy` under TERM versus under KILL is the
demonstration, and it takes ten seconds. Point at it early and let it do the arguing.

The second half is about families, and the student's model there is usually "kill the parent, kill
the tree". `bin/orphan-demo` disproves it in one run.

## Where they get stuck

**"I sent TERM and nothing happened."** Which program? If it is `bin/catcher`, that is the lesson
working. Ask them what the script's first three lines say.

**"The INT trap doesn't fire and I don't know why."** This is the deep one, and it is exercises
23–25. Do not explain it. Ask: *what dispositions did this process inherit?* Then point at
`grep SigIgn /proc/<pid>/status`. When they see `0006` ask them what bit 1 and bit 2 are, and whether
the script asked for that. The rule that lands hardest is the second half — bash silently refuses to
trap a signal it inherited as ignored — and the proof is `trap -p INT` printing `trap -- '' SIGINT`.

**"Exit code 143 is a signal, right? So 130 is signal 130?"** Ask them to write down 143 − 128, then
run `kill -l 143` and `kill -l 137` and compare with `kill -l 15` and `kill -l 9`. They will see the
tool doing the subtraction.

**"The zombie won't die."** Good. Ask what a zombie *is* — not what it does. When they say "an entry
in the table", ask what a `kill` delivers to a table entry.

**"There are dozens of zombies and I only ran the thing three times."** True, and not their fault.
`notes/family.txt` explains it: pid 1 here is `sleep infinity`. Ask them to run `ps -p 1 -o comm,args`
before they read the note.

**"I killed the parent and the children are still running."** Ask for the children's ppid now versus
before. That is the whole finding, and they made it themselves.

**"`kill -TERM 1` returned 0 and nothing happened."** Ask them what would happen to everything else in
the container if it had worked. The kernel's reasoning is theirs to reconstruct.

## Two-terminal exercises

Several exercises want a second shell. If the student only has one, `cmd &` plus the same prompt works
for everything here — nothing in this lesson needs a controlling terminal except the interactive-shell
comparison in exercise 23, which is written as a `bash -ic` one-liner precisely so it fits in one.

## Things not to say

Do not give them the escalation order (exercise 32) — they can derive it from exercises 26–28, and
derived it sticks. Do not name the resource that runs out in exercise 46; ask what a pid is and
whether there are infinitely many. Do not answer exercise 49's five claims one by one; ask which of
the five they could test in the next two minutes, and let them find that four of the five are testable
in this lab.

## Common wrong answers worth engaging

- *"Zombies leak memory."* Ask them to find the zombie's memory in `top`. RSS is 0.
- *"STOP is like a pause button so it's safe."* Ask what happens to the process's open network
  connection, its file locks, and anything waiting on it. Ask what it is still holding.
- *"`kill -9` is faster."* True and irrelevant: ask what TERM costs them, in seconds, on `bin/tidy`.
- *"Trapping EXIT covers everything."* Exercise 52 is exactly this. Let them run it.

## Scope

Job control (`bg`, `fg`, `jobs`, Ctrl-Z at a real prompt) is lesson 05, not here — exercise 37 mentions
TSTP only to contrast it with STOP. `pkill`/`pgrep` targeting is lesson 04; exercise 14's over-broad
`-f` pattern is a deliberate preview and should be left as a puzzle. `/proc/<pid>/environ` and `lsof`
are lesson 06; exercise 60 points at them without teaching them.

Do not raise the incident. The student meets it in lesson 07 and the constraint that matters — trace
before you signal — is exercise 60's answer, which they should reach on their own here.
