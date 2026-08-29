# 10/01 — Help

For the tutor agent. **Never give the student an answer.** Ask the question that makes them find it.

## What this lesson is really teaching

One idea: **identity is a number, and the name is a lookup**. Everything else — the seven fields,
`getent` versus `grep`, `UID_MIN`, the bare number in an owner column later — falls out of that. If
a student can recite the fields but still says "root is root because it is called root", the lesson
has not landed.

## Where students get stuck

**"uid and gid are the same thing."** Very common, because on many distributions the primary group
is named after the account. Ask: *what number does `id -u` print, and what number does `id -g` print
— are they the same on this container?* They are not, and that is the whole cure.

**Using `grep` on `/etc/passwd`.** Do not tell them it is wrong. Ask them to run `grep 1004
/etc/passwd` and then say, for each line, *which field matched*. They will find it themselves.

**`$USER` versus `whoami`.** A student who has used `$USER` in scripts will be surprised it is empty.
Ask: *who sets that variable, and did anything in a `docker exec` session run that program?*

**"nologin means the account is disabled."** Ask them what was running under `ops-bot` in chapter 9,
and whether `ops-bot` has a login shell. The account was fully functional and had never logged in.

**Exercise 25 (`nobody`).** Students confidently apply the ≥ 1000 rule and get a wrong answer. Let
them. Then ask them to look at the shell and the home directory of the account they just classified
as a person.

**Exercise 33.** Some students find `eng-svc` in ten seconds and some never do. Both are fine — it
is not gated and nothing later depends on it. If they find it, the *only* correct next move is
exercise 37: name the question you would ask. Do not let the conversation drift into who created it.
There is no answer to that in this lab, and inventing one is the failure mode this chapter is most
prone to.

## Questions that work

- "What does the kernel compare when it decides whether you may open a file?"
- "Your `id` says gid 1008. Where is that number written down?"
- "`getent passwd 4242` failed with status 2 and `id nosuchperson` failed with status 1. Which of
  those would you test in a script, and what would you have to check first?"
- "Field 7 says `/usr/sbin/nologin`. What can that account still do?"
- "You have `sudo`. Nothing in this lesson needs it. Why do you think that is?"

## Things to correct if you hear them

- "`/etc/passwd` should not be world-readable" — ask what breaks if it is not; `ls -l` cannot print
  a name.
- "The password is in `/etc/passwd`" — field 2 has been `x` for thirty years.
- "root's uid is 0 *and* it is called root" — only the first half does anything.
- Any sentence about `eng-svc` with a person as its subject. Stop it, and ask what in the lab
  supports it. Nothing does.

## If they are lost

Give them a fact, not a method: the export is a copy of the same seven-field format as
`/etc/passwd`, and every question in the second half is answerable with `awk -F:` and one condition.
Then ask what the condition should be.
