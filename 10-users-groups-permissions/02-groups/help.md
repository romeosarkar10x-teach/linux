# 10/02 — Tutor notes

For the tutor agent. Not for the student. **Never give an answer.** Ask the question that makes the
student find it.

## What this lesson is actually about

One idea, and it is not "how to add somebody to a group". It is: **an account's group list and a
running process's group list are two different things, and they disagree for as long as the shell
lives.** Everything else in the lesson is scaffolding around that.

If a student finishes with the mechanics of `usermod -aG` but cannot explain why their shell did not
see it, they have not passed. If they can explain that but keep mistyping the flag, they are fine —
that is a habit, and exercise 43 gives them the habit.

## The centrepiece — exercises 21, 22, 23

The design is deliberate: the student adds themselves to `engineering`, `id cadet` shows it, `id`
does not, and `ls engineering` is still denied. Most students hit this and assume the `usermod`
failed. Do not correct that assumption directly. Ask:

- "Which of those two commands asked the account database, and which asked your shell?"
- "When did this shell get its group list? Could it have got it before you ran `usermod`?"
- "Run `id` in a brand-new shell — what do you predict, and why?"

The word you want out of them is **copy**, or **snapshot**. Exercise 25 asks for it explicitly, and it
is worth waiting for rather than supplying.

## The things students get wrong here, reliably

**"`groups` and `id -nG` disagree."** They do not; the order is just unspecified. If a student is
building a script on positional output, redirect them to exercise 57 — test membership, do not parse
an ordered list.

**"`getent group cadet` is empty so I am not in it."** Very common and a good sign — they are reading
carefully. Ask where else membership could be recorded. Point at `/etc/passwd` field 4 only if two
questions have failed. Primary in `passwd`, supplementary in `group`.

**"I will just use `sg` to get into engineering."** Let them try it (exercise 33). It prompts for a
password and refuses. Do not pre-empt the failure; it is a much better lesson after they have run it.

**Permission triads treated as cumulative.** A student who thinks "I am other AND in the group, so I
get both" will predict exercise 11 wrongly for the wrong reason. Ask: "if the owner triad were `---`
and other were `rwx`, what could the owner do?" The answer — nothing — makes first-match-wins land.

**The `-aG` / `-G` distinction, before exercise 37.** If a student asks preemptively, do not explain
it. Send them to `probe` and let `usermod -G` eat two groups in silence. The silence is the point;
being told is not the same experience.

## Safety — say this once, plainly

Exercise 42 asks what `sudo usermod -G engineering cadet` would do and **explicitly says not to run
it**. If a student is about to run it anyway, stop them, plainly and outside the fiction: it would
remove `cadet` from `sudo`, and once the current shell exits there is no way back without root from
outside the container. Recovery is `docker exec -u root`, which is not something the course expects a
student to reach for. Losing `sudo` ends the chapter for them.

Everything else in this lesson is safe. `probe` exists to be broken, and the setup rebuilds it.

## Fiction

rhea's page is not hostile. She added an eleven-year-old membership list to a task queue and moved
on — this is housekeeping, not accusation. If a student decides `engineering` should be hers to
approve rather than theirs to take (exercises 27, 51), that is the *better* answer and it should be
praised without being required. Her scene in lesson 07 assumes they considered it.

`access.txt` living inside the directory it controls is a joke, and if the student notices it, say so.
It also makes a real point: the convention is the control, the mode is only the enforcement.

The `eng-svc` account from lesson 01 does not appear here. If the student brings it up, note that
group membership will not tell them who created it either — exercise 50 — and leave it. Do not
attribute it to a person.

## Hints, in order, for a stuck student

1. "You have run two commands with the same name and got two different answers. What is different
   about the two questions they ask?"
2. "Where does a process get its group list, and when?"
3. "What would have to happen for your shell to notice?"
4. Only then: name the re-login rule, and ask them to state why it is true rather than repeating it.
