# 11/04 — Tutor notes

For the AI tutor. Never hand over an answer.

## The one thing they must leave with

An alias is a text substitution that exists only in interactive shells; a function is a piece of your
shell that beats `PATH` outright. Both change what a word means, and `which` cannot see either. If a
student leaves able to explain ops-bot's two-versus-three lines from scratch, they have it.

## Where they get stuck

**Exercises 7–9.** "Command not found" for an alias they just defined. Do not explain parsing; ask
them to run the same two commands on two lines and say what is different about *when* bash saw the
word `g`. The word to steer them toward is "parsed".

**Exercise 12.** Some students insist aliases take arguments because `ll /etc` works. Ask where the
`/etc` went — the answer in exercise 11 is that it was never touched, just left in place. Then ask
them to write an alias that puts an argument in the *middle*. They cannot, and that is the lesson.

**Exercises 18–20, the payoff.** Same file, two answers. Students often blame the script or the
sourcing. Have them run `type deck-report` in both shells. If they still flail, ask what lesson 03,
exercise 30 said about `expand_aliases`.

**Exercise 21.** Do not let them say `which` is broken. It found a real file. It answered a different
question, exactly as in lesson 02. Third time the course has made this point; by now they should
recognise it without being told, and if they do, say so.

**Exercise 34.** Insist they copy the file to `scratch/` before deleting `local`. A student who edits
`rc/functions.sh` in place loses the reference and the validator will see it.

**Exercise 43, the cliff.** Everyone predicts an error message. It is a segfault, exit 139, silent.
Do not warn them; the exercise says "do not predict — measure" and the surprise is the teaching. If
they refuse to run it, ask what they think bash does when it runs out of stack, and whether they have
ever seen bash print a message about that.

**Exercise 48.** The hardest reasoning in the lesson. `deck 5` works, and it works for a reason the
author did not intend. Ask: when the file was sourced, what was `$1`? Then: so what is the alias's
text, exactly? Then: where did your `5` go? Three questions, no answers given.

**Exercise 52.** They may not believe a function can overwrite their variable. Have them set `i` to
something memorable first. Seeing `i=3` where they put `IMPORTANT` does the work.

## Red herrings

- `bin/deck-report` genuinely understands `--terse`. Students sometimes decide the program was
  tampered with. Its mtime is `2185-11-02 14:20:00` and ops-bot's claim is true — exercise 22 exists
  to make them check rather than assume.
- The `[wrapped]` line in `rc/functions.sh` is on stderr and looks like a safeguard. Exercise 37
  should lead them to say it is a courtesy that a hostile version would simply omit.
- `rc/broken.sh` mistake 1 *works*. Students who run it and move on have missed the exercise. Make
  them do 49 before they form an opinion.

## Integrity check

`stat -c '%y' bin/deck-report` must be `2185-11-02 14:20:00` — ops-bot's claim depends on it.
`rc/functions.sh` and `rc/aliases.sh` must be unmodified; exercise 34 explicitly says to copy.

## If they finish early

Ask them to run `alias` and `declare -F` on their own laptop account and find one thing they did not
know was defined. Then ask which of those would vanish inside a script, and whether anything they have
written depends on one that would.
