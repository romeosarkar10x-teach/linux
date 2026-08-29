# 10/04 — Tutor notes

For the tutor agent. Not for the student. **Never give an answer.** Ask the question.

## What this lesson is actually about

Two things, and neither is octal arithmetic:

1. **One triad, the first that matches.** Not a union.
2. **`r` and `x` on a directory are independent permissions over different operations**, and almost
   every confusing permission failure a student meets for the next five years is one of the two
   lopsided combinations.

Octal is a five-minute skill. If a student is slow at it, drill it in passing and spend the time on
the maze.

## The maze — exercises 17 to 28

Insist on the written prediction before each run. The whole design is that `listed` (744) and
`reachable` (711) behave in ways nobody predicts correctly the first time, and the surprise does not
happen if they ran the command first.

When `ls -l maze/listed` prints question marks, ask:

- "`ls` printed the names. Where did it get them?"
- "It printed `?` for the size. Where would the size have come from?"
- "What did it have to do to get there, and which bit is that?"

When `cat maze/reachable/rota.txt` works, ask:

- "You just read a file in a directory you cannot list. Which of those two operations did the `x` bit
  permit?"
- "Could you have found that file if I had not told you the name?"

Exercise 25 is the sharp one and students skip past it. `cat` on a *nonexistent* name in the `--x`
directory says `No such file or directory` — so the directory answers existence questions one at a
time. Make them notice: `--x` hides the index, not the data. It is not a security boundary against
somebody patient.

## The trap in exercise 12

`chmod 044` on their own file. Some students refuse to believe the result and check for a typo. Do
not confirm or deny — ask them to say, out loud, which triad the kernel used and why it did not go on
to the next one. The follow-up worth having is exercise 14: they fixed it with `chmod`, which needed
neither `r` nor `w`. Ownership is not one of the nine bits.

## Frequent wrong turns

**"I'm in `crew`, and the file is `crew`, and I'm also `other`, so I get both."** The core
misconception. Ask them to construct a mode where that belief would let somebody in and the kernel
does not (exercise 16 does it for them).

**Answering exercise 37 from the file's mode.** Expected, and cheap to be wrong about here. Do not
correct it — ask "what does deleting a file actually remove?" If they say "the file", ask what a
directory contains. Let lesson 05 land the rest.

**Attributing `tools/adjust` to a person (exercise 39).** Firmly out of bounds. The listing gives a
mode, an owner and a timestamp. It does not give an author, an intent, or a story. If a student
writes one, the correct move is to ask which line of the listing supports it — none does. This
matters beyond the exercise: the same discipline is what chapter 15 is graded on.

**`chmod -R` anywhere near a real path (exercise 45).** If a student starts typing one, stop them
plainly. This lesson does not need `chmod` at all except inside `scratch/`.

## cass's page

She is right, rhea is wrong, and rhea is being reasonable — "if you can list it you can read it" is
true of every directory most people ever meet. The scene that matters is exercise 32: the student has
to correct somebody senior without making it a defeat, and has to end with a *specific ask* (execute
on the directory), not "please give me access". If their reply asks for read on the file, they have
diagnosed it and then requested the wrong fix, which is worth one more round.

Do not let the student conclude the mode was set maliciously. 744 on a directory is a `chmod` typo or
a copied recipe; it is the single most common accidental mode there is.

## Hints in order for a stuck student

1. "Name the two things you tried. Did they need the same permission?"
2. "What does `ls` need? What does `cat` need? Are they the same bit?"
3. "Run `namei -l` on the full path and read it from the top."
4. Only then: point at the directory section of `notes/modes.txt` and ask them to read `r` and `x`
   aloud as two separate sentences.
