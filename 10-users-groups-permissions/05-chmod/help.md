# 10/05 — Tutor notes

For the tutor agent. Not for the student. **Never give an answer.** Ask the question.

## What this lesson is actually about

Three things, in order of how long they take to sink in:

1. **Numeric is absolute, symbolic is relative.** Every other confusion in this lesson descends from
   a student who has not internalised that `chmod 755` is a statement about all nine bits.
2. **Deleting a file is a write to its directory.** This is the idea students most reliably get wrong
   and most reliably remember once they have watched `rm` remove a `444 root:root` file they cannot
   write a byte of.
3. **The smallest change that works.** The four `repair/` mistakes are the lesson's spine. A student
   who fixes all four with `chmod 777` has run four correct commands and learned nothing.

`chmod` syntax itself is a twenty-minute skill. Do not spend the session on it.

## The symbolic sequence, 9 to 14

Insist on the written prediction before each run — the sequence is cumulative, so a student who runs
first has destroyed the exercise for every later step. The two that catch people:

- **11** (`o=x`): ask "what would `o+x` have done differently, and how could you tell from this file?"
  If they cannot answer, have them redo the pair from `000` on a scratch copy.
- **13** (`ug=rw`): the `other` triad keeps its `x`. Ask "you used `=`, which is absolute. Absolute
  over what, exactly?"

## Exercise 16 is a genuine trap, and it is fair

Bare `chmod +w` from `000` gives `200`, not `222`, because a `who`-less `+` has the umask applied.
`notes/chmod.txt` says the default `who` is `a`, which is true and still produces the surprise. If a
student is annoyed, they are right to be — this is the one corner of `chmod` where reading the manual
carefully does not save you. The teaching move is not to explain umask (that is lesson 06); it is:
"what else on this system has opinions about new permission bits?" and then let it wait. The
practical takeaway is *always write the `who`*.

## The four repairs, 26 to 40

The intended use comes from `repair/NOTES`, and students skip it. If a student proposes a fix before
having read what the file is *for*, ask what the file is for. That is the entire pedagogy here.

Per-repair questions worth having ready:

- `collect.sh`: "it is readable and it is a valid script. Why did the shell refuse?"
- `id_station`: "which single permission is the breach — and does anybody need to write it?"
- `handover/`: "the file is `644` and owned by you. Why are you changing the directory?"
- `exporter.conf`: "name the three things 777 grants. Which one is the incident?"

Exercise 33 is the one to slow down on. When they discover a `crew` member can delete `week-24.txt`,
do not resolve the discomfort — exercise 34 exists to park it, and the sticky bit is lesson 08.

**Exercise 39, rhea's reply.** Two failure modes: a reply that blames whoever typed 777, and a reply
that is so careful it never says the mode was wrong. Ask "what is the difference between the mode
being wrong and the person being wrong?" rhea's character depends on that distinction — she updates,
and she does not accuse.

## Deleting, 41 to 51

If a student predicts `rm drop/theirs.txt` will fail (most do), do not correct it before they run it.
After it succeeds, the sequence is: "what did `rm` change?" → "where is the name stored?" → "whose
permissions govern that?" Do not supply "a directory is a list of names" — exercise 45 asks them to
produce it, and it is worth more from their own mouth.

If `rm` prompted them, exercise 44 is about *who* prompted. Students assume the kernel. Ask how they
could find out; `rm -f`, or piping input, settles it in one command.

Exercises 46 and 47 are the same idea from both sides and are where it becomes permanent. If a
student only does one, they will lose it within a week.

## Recursion, 52 to 60

`X` is easy to half-learn. A student who says "`X` means only directories" has half of it. Ask about
`tree/bin/run`, which is `700` before the recursive chmod and keeps its `x` after. Both halves —
directories, *and* files that already have execute somewhere — or they do not have it.

Exercise 57 is a good one to ask even of a strong student: how did a recursive `chmod` get inside a
`600` directory? The answer (it fixes the directory before descending) is the sort of implementation
detail that explains a whole class of behaviour.

## Frequent wrong turns

**Reaching for numeric always.** Ask them to write exercise 17 ("take write from everybody except the
owner") numerically without running `stat`. They cannot. That is the argument.

**Reaching for symbolic always.** Exercise 30, the private key. A relative edit on a secret leaves
whatever else was set. Absolute is right when the required end state is known.

**`chmod -R 777` as a diagnostic step.** Some students will do it "just to see". Stop it — not on
moral grounds, but because it destroys the information they were trying to gather, and in this lab
the modes are the exercise.

**Editing outside the lab.** `chmod` on anything under `/etc` or `/opt` is out of bounds. If a student
has done it, have them say what they changed before anything else happens.
