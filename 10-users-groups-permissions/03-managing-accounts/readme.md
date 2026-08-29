# 10/03 — Managing accounts

> "The account was removed in 2181. The directory is still there. It belongs to 4102."

Two lessons ago an account was a line you read. This one is a line you write. Creating and removing
accounts is the least interesting root work there is, right up until the moment somebody discovers
that the new hydroponics tech can read the last hydroponics tech's mail.

`useradd` is the primitive, and it is spartan on purpose: bare `useradd tulane` creates the account
and *nothing else* — no home directory, and the shell is whatever `useradd -D` says, which on this
station is `/bin/sh` rather than bash. The form you will actually type is
`useradd -m -s /bin/bash -c "Tulane, M." -G crew tulane`, and every one of those flags is there
because the bare command does not do it. Debian also ships `adduser`, a friendly script that wraps
`useradd` and asks questions. Use it when it is there. Learn `useradd`, because it is everywhere.

Removal is where the damage lives, and it comes in two halves that people assume are one.
`userdel merrick` removes the account. It does not remove `/home/merrick`, and it cannot, because it
has no way to know whether anybody still wants what is in there. So the directory stays, and its
owner — a number that no longer maps to a name — is what `ls -l` now prints. `find -nouser` is how
you go looking for those.

That would be untidy and nothing worse, except for the second half: `useradd` allocates the **lowest
free uid**. Retire 4102 today, create an account tomorrow, and the new account may be handed 4102 —
at which point every file the departed person left, everywhere on the station, silently becomes the
new person's. Nothing was copied, nothing was changed, and `ls -l` will show their name on it. This
lesson makes you do it, on purpose, in a directory where it is safe, because reading about it does
not produce the right amount of alarm.

Then `/etc/shadow`, which only root can read and which has nine fields. Two of them are called
"expires" and they mean different things: field 5 expires the **password** (pick a new one, carry
on), field 8 expires the **account** (it stops, and no password will help). `chage -l` reads all of
it back in dates instead of day counts, and `passwd -S` gives the one-line summary. Locking is the
step that matters operationally: `usermod -L` (or `passwd -l`) puts a `!` in front of the password
hash so nothing can match it, and unlocking puts the hash back. Locking is reversible and instant.
Deletion is neither, which is why the station's offboarding note tells you to lock first and think
later.

## What you will be able to do

- [ ] Create an account with a home, a shell, a description and a group, in one command
- [ ] Read `useradd -D` and `/etc/login.defs`, and say what a bare `useradd` will do before you run it
- [ ] Name the three fields `useradd` writes to that are *not* in `/etc/passwd`
- [ ] Modify an account's shell, description, groups and name with `usermod`, and say what `-l` does not change
- [ ] Explain the difference between `userdel` and `userdel -r`, and why the default is the unhelpful one
- [ ] Find files with no owner and explain what happened to them
- [ ] Demonstrate uid reuse and state the policy that prevents it
- [ ] Read all nine fields of a `/etc/shadow` line
- [ ] Distinguish password expiry from account expiry, and set each one
- [ ] Lock and unlock an account, and say what the lock does to the stored hash
- [ ] Say why locking is the first offboarding step and deletion is the last

## Files

```
roster/arrivals.txt        two arrivals, one service account, two departures
roster/offboarding.txt     how it is meant to be done here
roster/uid-policy.txt      the policy about reuse
roster/retired-uids.txt    four numbers, one of which you will meet
notes/accounts.txt         useradd, usermod, userdel
notes/shadow.txt           the nine fields
notes/page.txt             rhea, 06:15
homes/                     four home directories off the archive host
scratch/                   yours
```

Everything in this lesson needs `sudo`. Every account you create is one you will remove again by the
end; the accounts named in `arrivals.txt` do not exist yet, and `probe` is the throwaway from lesson
02, still locked and still with no home.

One standing rule for this lesson, and it is not part of the fiction: **never run `usermod`,
`userdel`, `passwd -l` or `chage` against `cadet`, `rhea`, `cass`, `dorn`, `ops-bot`, `ubuntu` or
`root`.** Every exercise here names the account it wants you to touch, and all of them are accounts
you created yourself.
