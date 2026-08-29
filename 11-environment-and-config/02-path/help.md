# 11/02 — Tutor notes

For the AI tutor. Do not give answers. Ask the question that makes the student measure.

## The one thing they must leave with

`PATH` order is a trust decision, and the same command name can be a different program on two
terminals without either machine being broken. Everything else in this lesson is machinery in service
of that. A student who can explain rhea's four-lines-versus-three page (exercise 54) without guessing
has it; a student who can recite the seven entries but shrugs at the page does not.

## Where they get stuck, in order

**Exercise 9 vs 7.** `which ls` says `/opt/kestrel/bin/ls` and `type ls` says it is an alias. Students
decide one tool is broken. Neither is. Ask: *what question does each tool think you asked?* `which`
searches `PATH` for a file. `type` reports what bash will do. Those coincide most of the time, and
this station is a place where they do not.

**Exercise 25.** The single hardest item. They set `PATH` for one command, expect the alias to protect
them, and get the wrapper anyway. Do not explain. Ask them to run `type ls`, read the replacement
text aloud, and say what the *first word* of that text is. The chain — alias expands, first word of
the replacement resolves through the normal order, wrapper is found — is theirs to assemble.

**Exercise 31, the real cliff.** They put a non-executable copy first and predict a failure. They get
v1 from `bin/`, rc 0. If they call it a bug, ask what bash should do with a candidate it cannot run:
stop, or keep looking? Both are defensible; bash keeps looking. Then send them to 32 to see the other
case. The pair 31/32 is the lesson: skipping is not the same as failing, and which one you get
depends on whether an executable copy exists further down.

**Exercises 34–36.** Five tools, three answers. Some students want one tool declared correct. Push
back: which of them is *wrong*? None. They answer different questions and the disagreement is the
signal. Exercise 36's honest answer is "none of them alone" — accept it, do not let them talk
themselves into a single-tool answer.

**Exercise 42.** The stale hash. The tell is that the error names a path they did not type. If they
miss it, ask them to compare exactly what they typed with exactly what the error quotes.

**Exercise 45.** Many students have absorbed folklore that you must `hash -r` after editing `PATH`.
Measurement says otherwise: any assignment to `PATH`, even the same value, empties the table. Let them
find it. Then ask the follow-up that matters: if editing `PATH` clears it, what situation leaves a
stale entry? (The file moves; `PATH` does not change. Exercises 42 and 44.)

**Exercise 46.** Someone will do this outside the parentheses and lose their shell. That is a fine
thing to happen once. Do not hand them a repair — ask what they still have (builtins: `cd`, `echo`,
`type`; and `exit`), and let them either rebuild `PATH` by hand or leave and re-enter. Then ask what
`$PATH:` was for.

## Red herrings

- `notes/path.txt` and `notes/lookup.txt` are the *station's* notes and are correct. They are also
  incomplete: they list the five tools without mentioning that the tools can disagree. If a student
  says the notes are wrong about exercise 34, they have misread — the notes are silent, not wrong.
- `broken/README` deliberately predicts nothing. It tells them to run it twice and says neither
  result is the one most people predict. If they want to be told which, refuse.
- `override/deck-report` pointing at `/srv/decks` while `bin/deck-report` points at
  `/var/lib/kestrel/decks` looks like a bug in one of them. Neither is a bug; that is exercise 19.
- The wrapper's comment says it is not hostile. Students distrust it anyway. Good instinct, wrong
  target — ask them to read it and say what it actually does. The point of exercise 26 is that the
  hostile version is no harder to write.

## Integrity check

`stat -c '%y' notes/path.txt` should read `2186-08-02 11:20:00`. If it does not, they edited the
station's notes instead of working in `scratch/`. Not a hanging offence; ask them to reset.

## If they finish early

Ask them to write down, for their own laptop, the answer to exercise 47: is their personal `bin`
directory in front of the system's or behind it, and which did they *choose*? Most people have never
decided; they inherited it from a snippet. That is the lesson landing.
