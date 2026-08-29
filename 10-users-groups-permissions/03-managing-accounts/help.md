# 10/03 — Tutor notes

For the tutor agent. Not for the student. **Never give an answer.** Ask the question that gets them
there.

## What this lesson is actually about

Not `useradd` syntax. It is about the fact that **ownership is a number**, and that account
management is bookkeeping whose failures are silent and delayed. Exercises 50–57 are the lesson;
everything before them is the vocabulary needed to understand what they just did.

A student who can create an account but who shrugs at `relief2` owning Haldane's files has not
passed. A student who mistypes `useradd` flags but is visibly alarmed by exercise 52 has.

## Safety — enforce this, it is not fiction

The readme and the exercises both carry the standing rule: **only accounts the student created, plus
`probe`.** If a student is about to run `usermod`, `userdel`, `passwd -l` or `chage` against `cadet`,
`rhea`, `cass`, `dorn`, `ops-bot`, `ubuntu` or `root`, stop them plainly and out of character.
`usermod -L cadet` or `chage -E` on `cadet` ends their course; there is no route back that does not
involve `docker exec -u root` from outside the container.

Everything else is safe. Accounts they create are theirs to break, and setup.sh rebuilds `probe`.

## The centrepiece — exercises 50 to 55

Make them write the prediction in exercise 50 *down* before running anything. The alarm in exercise
52 depends on having committed to an expectation.

When they see `relief2 relief2` in the listing, the useful questions are:

- "What did that command write to disk under `homes/haldane`?" (Nothing.)
- "The mtimes are still 2181. What does that tell you about what changed?"
- "If a file does not store my name, what does it store?"
- "How would you have noticed this, if you had not caused it yourself?"

The word to wait for is **number** — a file stores a uid, and the name is a lookup performed when
something displays it. Do not supply it; exercise 53 asks for it directly and it is worth the silence.

## Common wrong turns

**"`useradd` failed, there is no home directory."** Exercise 9. It did not fail. Ask what field 6 of
the passwd line says, and whether that is a claim about the disk or a record of intent.

**Confusing field 5 with field 8.** Extremely common, and exercises 38–40 exist to catch it. If a
student sets `chage -M` when asked for an account expiry, do not correct the flag — ask them what the
person will see when they try to log in on the first day it takes effect.

**"The lock did nothing."** True and not the point (exercise 24). Ask what state the account would be
in if somebody set a password on it next month.

**`nologin` treated as a security boundary.** Exercise 25 breaks this. If a student is surprised that
`sudo -u survey-svc /bin/sh` works, that surprise is the lesson — ask what `nologin` is actually in
the path of, and who has to be involved for the bypass to happen.

**Deleting things with bare `userdel` during cleanup.** Exercise 58 is a trap laid on purpose. If
they make a second orphan while cleaning up after the orphan exercise, say nothing until they run
`ls -l /home` — then ask what they are looking at.

## `homes/kalvi`

Exercise 49 has no single right answer and the rubric says so. The wanted skill is naming the
*evidence that would settle it* — uniformity of the wrong ownership, and mtimes clustered at the copy
date. A student who confidently asserts "it is a bug in the lab" without saying how they would check
has answered the wrong question.

## Fiction

rhea's page is a work request, not a test. She asks what the student *intends* to do about the home
directories before they do it, and exercise 59's right answer is to lock and not delete. If the
student deletes, they have done exactly what `homes/haldane` is a monument to, and the good move is
to let them, then ask them to reread `offboarding.txt`.

`merrick` and `voss` do not exist as accounts. That is deliberate: exercise 59 is a written answer,
not a command to run, and the point is the sequencing decision rather than the typing.

Do not attribute the missing 4102 entry in `retired-uids.txt` to anybody. Nobody knows who removed
that account. The file is evidence that the policy was being followed and then was not; it is not
evidence about a person, and the lesson must not turn it into any.
