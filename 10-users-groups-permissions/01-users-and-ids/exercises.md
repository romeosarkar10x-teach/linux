# 10/01 — Exercises: users and ids

```
cd /labs/10-users-groups-permissions/01-users-and-ids
ls -F
```

Chapters 1–10 tools. Wrecked the lab? `kestrel reset 10/01`. Do not edit `/etc/passwd` or
`/etc/group`; you have `sudo` and this lesson is not the place to use it.

---

## Warmup — who are you

**1.** `whoami`. One word. Now `id`. Write down every distinct piece of information the second
command gave you that the first did not.

**2.** From your `id` output: your uid, your primary gid, and how many groups you are in. State the
uid and the gid as numbers and say whether they are equal.

**3.** `id -u` and `id -un`. Which is the number and which is the name? Now `id -g` and `id -gn` —
same pattern, different question. What question does `-g` answer that `-u` does not?

**4.** `id -G` then `id -nG`. Same list, two spellings. Which one would you use inside a script that
tests membership, and why is the other one riskier there?

**5.** `id rhea`. You have just read another account's identity with no privilege at all. Say in one
sentence why that is not a security problem.

**6.** `id root`. What is root's uid and primary gid?

**7.** `id nosuchperson; echo "rc=$?"`. Read the error and the status. Which one would a script use?

## /etc/passwd, field by field

**8.** `wc -l /etc/passwd`. How many accounts does this container have?

**9.** `getent passwd cadet`. Split the line into its seven fields by hand and label each one.

**10.** `getent passwd cadet | cut -d: -f1,3,4,7`. Confirm the uid and gid you wrote down in exercise
2. What is in field 7 and what does the login program do with it?

**11.** `getent passwd ops-bot | cut -d: -f7`. Different from yours. Read `notes/accounts.txt` on
field 7 and say precisely what that value prevents — and what it does not prevent.

**12.** `echo "USER=$USER LOGNAME=$LOGNAME"`. In this container both are empty. Now `whoami`.
Explain the difference between what the two commands are asking.

**13.** `logname`. It fails. Read the message. What does `logname` consult, and why is there nothing
for it to consult here?

**14.** `cut -d: -f2 /etc/passwd | sort -u`. One value on every line. What is it, and where did the
thing it replaced go?

**15.** `ls -l /etc/passwd /etc/shadow`. Compare owner, group and mode. Write the one sentence that
explains why one of these is readable by everybody and the other is not.

**16.** Try `cat /etc/shadow` as yourself. Read the error. You have `sudo` — do not use it yet. What
did the permission bits just tell you about who this file is for?

**17.** `getent passwd 1003`. Which account, and what have you just proved about looking things up by
number instead of by name?

**18.** `getent passwd 4242; echo "rc=$?"`. What is the exit status of a lookup that finds nothing?
Compare it with the status from exercise 7.

## The grep trap

**19.** `grep 1004 /etc/passwd`. Two lines. Look at *why* each one matched — which field carried the
`1004` in each case? They are not the same field.

**20.** `getent passwd 1004`. One line, and it is one of the two. Say in one sentence what `getent`
asked that `grep` did not.

**21.** `grep cass /etc/passwd` and `getent passwd cass`. Same answer here. Now describe the account
name that would make these two disagree, and say which one would be wrong. Then find the field in
`roster/passwd.export` that would make `grep deck` return seven lines, none of them an account named
`deck`.

**22.** Write the `grep` that is actually correct for "the line whose *name* field is `cass`". You
need an anchor and a delimiter. Then say why you would still use `getent`.

## System accounts versus people

**23.** `grep -E '^(UID_MIN|UID_MAX)' /etc/login.defs`. What is `UID_MIN` on this system?

**24.** `awk -F: '$3 >= 1000' /etc/passwd | cut -d: -f1`. List them. Which of these are people?

**25.** One name in that list is not a person and not really an account either. Which one, and what
is its uid? Why does the `>= 1000` rule fail on it?

**26.** State the rule from exercise 23 as a sentence, and then state the exception from exercise 25
as a second sentence. Both are needed; neither is optional.

## The export

**27.** `wc -l roster/passwd.export`. How many accounts were on the station on 2187-06-10?

**28.** `cut -d: -f7 roster/passwd.export | sort | uniq -c | sort -rn`. Three distinct shells. Report
the counts.

**29.** One of those three is neither a login shell nor `nologin`. Which account has it, and what
does that program actually do? (`man sync`, and think about what happens at login.)

**30.** `awk -F: '$3 < 1000' roster/passwd.export | wc -l`. System accounts. Now the complement.
Do your two numbers add up to exercise 27's?

**31.** Of the accounts with uid ≥ 1000, how many have `/bin/bash` in field 7? Write the one `awk`
that answers it.

**32.** Compare that number with the number of names in `roster/crew-list.txt`. They do not match.
Read the bottom of the crew list and account for the difference exactly — every extra, by name.

**33.** Now the reverse question. Which account has uid ≥ 1000, is not `nobody`, and is *not* a login
shell? Name it and give its uid.

**34.** That account's uid is not in the same block as everything else. `cut -d: -f3
roster/passwd.export | sort -n | tail -5` and say what is odd about where it sits.

**35.** `awk -F: '$5 == ""' roster/passwd.export`. Which accounts have an empty gecos field? Compare
with the other service accounts in the export — do they have one?

**36.** Answer rhea's question in three sentences: which accounts in the export belong to a person,
how you decided, and which single account you cannot classify from the export alone.

**37.** Write down the one command you would run next to classify it — not what it would prove, just
what you would ask. Do not run it; you do not have that database.

## Reading identity properly

**38.** `awk -F: '$3 != $4' roster/passwd.export`. Accounts where uid and primary gid differ. Two of
them. Are they people?

**39.** Now the same on the real `/etc/passwd`. Different answer. Is your own account in the list?
What does this do to the habit of writing `chown NAME:NAME`?

**40.** `getent passwd | wc -l` versus `wc -l /etc/passwd`. Same number here. Describe a system where
they would differ, and say which command you would trust there.

**41.** `id -nG cadet` and `id -nG rhea`. Write down both lists. Which groups do you share, and which
does she have that you do not? (Lesson 02 is about that difference; just record it now.)

**42.** `getent passwd rhea | cut -d: -f6`. Her home directory. `ls -ld` it. Can you enter it? Try
`ls /home/rhea` and record exactly what happens.

## Reporting

**43.** Write the sentence you would send rhea about `eng-svc`-shaped findings in general: an account
you cannot tie to a person and cannot tie to a service. It must not accuse anybody of anything.

**44.** rhea's question was "which accounts belong to a person". Somebody else will read your answer
as "which accounts should be deleted". Write the one sentence that stops that reading.

**45.** Your answer for the export was derived from a copy taken on 2187-06-10. Write the caveat you
attach to it, in one sentence.

## Experiment

**46.** In `scratch/`, copy `roster/passwd.export` and add a line for an account called `harmless`
with uid 0. Now `awk -F: '$3 == 0' scratch/your-copy`. Two accounts. Which one is root?

**47.** Same copy: change `cadet`'s uid to 0 and leave the name alone. From the file alone, what
would that account be able to do? Now say why editing `/etc/passwd` is the historical way people got
root, and why `sudo` exists partly so that nobody has to.

**48.** Write a one-liner that prints every account in the export as `name uid shell`, aligned in
columns. `awk` with `printf`, or `column -t` — try both and keep the one you would actually type.

**49.** Write a one-liner that prints, for each distinct primary gid in the export, how many accounts
use it. Is any gid shared?

**50.** `getent passwd cadet rhea dorn`. Multiple keys in one call. What is the exit status if one of
the three does not exist? Test it and report.

## Stretch

**51.** `id` prints groups you are in. Where does it get them from — is it one file or two? Prove
your answer with `getent`.

**52.** Write `whois_uid()`: takes a uid, prints the account name if it exists and `uid NUM (no
account)` if it does not, and exits non-zero in the second case. Use `getent`, not `grep`.

**53.** `stat -c '%u %U %g %G' /etc/passwd`. Four values, two pairs. Explain what happens to the `%U`
output on a system where the owning account was deleted — and predict what you will see in lesson 06.

**54.** The export has `dorn` in it, and the crew list says he left on 2187-05-24. What has to happen
to an account when its holder leaves, and in what order? List the steps; lesson 03 does them.

**55.** Argue the other side of exercise 5: identity being public is *mostly* harmless. Name the one
thing an attacker gets from a world-readable `/etc/passwd` that they would otherwise have to guess,
and what the defence against that is.
