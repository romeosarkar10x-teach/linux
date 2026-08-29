# 10/06 — Tutor notes

For the tutor agent. Not for the student. **Never give an answer.** Ask the question.

## What this lesson is actually about

1. **A file stores two numbers, not two names.** Everything odd in `intake/` follows from this, and a
   student who has it can derive the rest of the lesson unaided.
2. **`chown` is root's; `chgrp` is yours, within your groups.** The two-part `chgrp` rule is the one
   students state as one part.
3. **umask is a mask of bits to remove, applied at creation only.** Two reversals in one sentence, and
   both catch people.

## `unclaimed.raw` — exercises 3 to 7, and 66

This is the chapter's integrity exercise and it is graded like one. The file is owned by uid 4102 and
that is *all* it says. If a student proposes a person, a departure, a deletion or a motive, do not
argue with the story — ask which command produced the evidence for it. Nothing did.

Good questions:

- "`ls -l` printed `4102`. Is that something the file contains, or something `ls` decided?"
- "`getent passwd 4102` returned nothing. What are the two different situations that produce that
  same output?" (never existed; existed and was removed — indistinguishable from here)
- "What would you have to look at, that is not this file, to tell those two apart?"

The last one is worth sitting with. The honest answer is: something outside the filesystem, which the
student does not have. That is the lesson.

**Never supply a name for 4102.** There is no correct name to supply and inventing one would teach
exactly the wrong reflex for chapter 15.

## The chgrp rule — 18 to 22

Students state it as "you can chgrp files you own". Exercise 19 is the counterexample and it is
placed immediately after the success in 18 so they cannot generalise from one data point. If they get
19 wrong, do not restate the rule — ask "what is different between these two commands?" The file is
the same kind of file; the group is not.

Exercise 22 tests the other half. A student who predicted success there has silently swapped the rule
for "you can chgrp into groups you belong to".

## The default group — 25 to 27

The payoff of the lesson. Have them predict the group of `handoff/probe.txt` before running `touch`.
Most say `crew`, reasoning from the directory, which is the intuition setgid exists to satisfy and
which is wrong here. The `sg` command in 26 is the control experiment; make sure they see it as one.

Do **not** name the setgid bit. Exercise 27 asks for a guess and a lesson number, and the guess is
worth more than the answer. If they already know it from elsewhere, ask them to predict what a setgid
directory does to `chgrp`'s two-part rule and leave it hanging.

## Symlinks — 36 to 44

Three tools with three behaviours is genuinely hard to hold, and the exercise set is built so they
derive it rather than memorise it. Insist on the prediction at 38; almost everyone says the target
changes, because that is what `chmod` did last lesson.

Exercise 42 is the subtle one. `stat` said the link was theirs, `chgrp` refused. The question to ask
is "which file was each of those two commands talking about?" — not "what does `-h` do".

## umask — 46 to 60

If a student is fluent here in ten minutes, let them be; the arithmetic is easy. The two things to
insist on:

- **Exercise 52.** `umask 000` is permissive. Ask them to say which direction the number runs, out
  loud, before moving on.
- **Exercise 53.** After three subshells the shell's mask is unchanged. If they are surprised, the
  useful comparison is `cd` in a subshell, which they met in chapter 4.

Exercise 60's `cp -p` is a small trap worth springing: `-p` preserved the group and silently did not
preserve the owner. Ask why `cp` did not complain. (Because preserving the owner would require
`chown`, and it was never going to be allowed to; complaining about it every time would make `-p`
useless for ordinary users.)

## Frequent wrong turns

**Reaching for `sudo` at the first refusal.** Exercise 13 is the only place `sudo` belongs in this
lesson. If a student `sudo`s their way through exercises 8–12, the refusals were the content and they
have skipped it. Ask what they learned from the command succeeding.

**"chgrp gives me access."** It gives *the group* access, and only to a group they are already in.
Ask them to name the account whose access changed.

**Treating `-nouser` as "owned by nobody".** It means "the uid does not resolve". Ask what the file's
uid is, since a file always has one.

**Changing ownership outside the lab.** Out of bounds, including with `sudo`. If it has happened,
find out what before anything else.
