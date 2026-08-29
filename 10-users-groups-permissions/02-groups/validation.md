# 10/02 — Validation rubric

For the validator agent. No script grades this lesson. Judge the student's written answers and the
state of their lab against the criteria below.

## Non-negotiable — the student has not passed without these

1. **The two lists.** They can state that an account's group membership lives in the account database
   while a process's group list is a copy taken when the process started, and that the two disagree
   between `usermod -aG` and the next login. Exercises 24, 25. Accept "snapshot", "copy", "inherited
   at start". Reject "the change had not taken effect yet" and "you need to refresh" — those are the
   misconception, not the answer.

2. **Where each kind of membership is recorded.** Primary in `/etc/passwd` field 4; supplementary in
   `/etc/group` field 4. They must be able to explain why `getent group cadet` shows an empty member
   list without concluding they are not in the group. Exercises 4, 5, 6.

3. **First match wins.** Owner, then group, then other — one triad is applied, not the union.
   Exercises 11, 13, 15. A student who says "I get owner *and* other" has not passed this point even
   if every command they ran produced the right output.

4. **`-aG` versus `-G`.** They can state that `-G` replaces the supplementary list and destroys
   whatever is not named, that it prints nothing when it does so, and that the primary group survives
   because it is in a different file. Exercises 38, 40, 41.

5. **They did not run exercise 42.** Check: `id -nG cadet` must still contain `sudo`. If it does not,
   the lesson is not complete regardless of what they wrote — repair it before continuing.

## Should be present

- `newgrp` starts a **new shell** with the group as **primary**, and `exit` returns to the unchanged
  original (exercises 28, 31). Extra credit if they noticed that `cadet` became supplementary.
- `sg`/`newgrp` cannot grant a group you are not in — they saw `Password:` and `Invalid password.`
  and drew the right conclusion (exercises 33, 34).
- A file's group comes from the creating process's primary group, not from the directory
  (exercises 29, 30).
- `chgrp` succeeds only to a group the **process** is in (exercise 53). A student who reports that
  `chgrp engineering` failed *after* they had rejoined the group in exercise 36 has understood the
  lesson better than one who reports it succeeded.
- Revocation does not reach running processes (exercise 56).

## Written answers — 51 and 52

Exercise 51 is a message to rhea. Look for: what they did, what they read, and an offer to undo it.
A message that hides the strain export, or that asks permission after the fact without naming the
file, is worse. A student who says they would have asked *first* has answered exercise 27 well and
should be told so.

Exercise 52 is an explanation to a colleague with no jargon. Accept it if a non-technical reader
could act on it. Reject "you need to log out and back in" alone — the exercise asks *why*, and the
why is the whole lesson.

## Lab state to check

```
id -nG cadet            contains sudo, crew, plocate   (see criterion 5)
getent group engineering                                either rhea or rhea,cadet — both fine
id -nG probe            probe crew ops hydroponics      (exercise 41 restored it)
```

If `probe` is `probe hydroponics`, they broke it in exercise 39 and did not restore it in 41 — that
is a real gap in the sequence, not a cosmetic one, since 41 is where the primary-group survival is
observed. Send them back to it.

Nothing in `engineering/` should have been modified. If the student is a member and has edited
`access.txt` or the CSV, ask why — the lesson never asks them to write there.

## Common failure that looks like success

A student who ran every command and reported every output correctly, but whose answer to 24 is "`id`
is out of date", has learned a fact and missed the model. `id` is not out of date; it is answering a
different question accurately. Probe with: "What would `id` have to do to give the other answer, and
why would that be wrong?"
