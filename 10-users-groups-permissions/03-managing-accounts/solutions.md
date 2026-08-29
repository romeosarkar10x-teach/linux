# 10/03 — Solutions

Do not read this until you have written your own answers.

---

**1.** `survey-svc` — it is not a person. It needs no home directory, no login shell, and no
membership of `crew`, and treating it like an arrival is how service accounts end up with shells.

**2.** `/bin/sh`. `useradd -D` prints `SHELL=/bin/sh`.

**3.** No — `getent passwd cadet` ends in `/bin/bash`. The default is not what the machine you are
sitting in uses, which is exactly why you read `useradd -D` before your first `useradd` anywhere.

**4.** `UID_MIN 1000` and `UID_MAX 60000` bound the range a new account's number is chosen from;
`HOME_MODE 0750` sets the mode of a home directory `-m` creates; `UMASK 022` is the default for
files a login creates; `USERGROUPS_ENAB yes` makes `useradd` create a group named after the account;
`ENCRYPT_METHOD SHA512` chooses the hash used when a password is set.

**5.** `awk -F: '$3 < 60000 { print $3 }' /etc/passwd | sort -n | tail -1` — 1005, `cadet`, plus
whatever lesson 02's `probe` added (1006).

**6.** The policy says the next arrival goes *above* the highest retired number, which is 4101 — so
4102. `useradd` will choose the lowest free number at or above `UID_MIN`, which is 1007. The policy
and the tool disagree, and the tool wins unless you pass `-u`.

**7.** No output. `useradd` is silent on success, which is normal and is not reassurance.

**8.** `tulane:x:1007:1011::/home/tulane:/bin/sh` — name, password placeholder, uid, gid, gecos
(empty), home, shell. You chose exactly one of them: the name.

**9.** `ls: cannot access '/home/tulane': No such file or directory`. Not a failure — `useradd`
recorded a home directory in field 6 and did not create it, because you did not ask for `-m`. The
account has a home path that does not exist.

**10.** `tulane:x:1011:` — an empty group named after the account. `USERGROUPS_ENAB yes`.

**11.** `tulane:!:20694:0:99999:7:::` — field 2 is `!`. Locked, with no hash behind it, because no
password was ever set.

**12.** `tulane L 2026-08-29 0 99999 7 -1`. `L` for locked. Not usable: no password can match `!`.

**13.** For it: `useradd` is a primitive, and a primitive that silently invented a home directory and
a shell would be harder to build tooling on. Against it: the defaults are the wrong ones for the
overwhelmingly common case, so almost every real invocation has to override them, and forgetting
`-m` is a mistake nobody makes on purpose.

**14.** Both are gone. `userdel` removed the per-account group with the account, because nothing else
was in it. That is the *group* — the home directory is a separate matter.

**15.** `sudo useradd -m -s /bin/bash -c "Tulane, M., hydroponics" -G crew tulane`

**16.** Field 5 now has the description, field 7 is `/bin/bash`, and the home directory in field 6
now exists. The uid was reused from the account you deleted in exercise 14 — lowest free number.

**17.** `.bashrc`, `.profile`, `.bash_logout` and this station's `.kestrel-bashrc-seed`, copied from
`/etc/skel`. `useradd -D` names it: `SKEL=/etc/skel`.

**18.** `drwxr-x---`, mode 750, from `HOME_MODE 0750`. No — Kalvi is not `tulane` and is not in group
`tulane`, so she gets the `other` triad, which is empty.

**19.** `tulane` is primary, `crew` supplementary. The primary is `/etc/passwd` field 4; the
supplementary membership is `/etc/group`'s member list.

**20.** `sudo useradd -m -s /bin/bash -c "Okonkwo, A., hydroponics" -G crew okonkwo` — 1008.

**21.** 1009, the next free number. Create and remove one and it is 1009; create another after the
removal and it is 1009 again, because it went free.

**22.** No `-m` (a service account has no reason to own a home directory full of shell startup
files), and no `-G crew` (it is not crew, and putting it there gives every file that `crew` can reach
to a process nobody is watching). Also no `-s /bin/bash`, for the same reason as lesson 01's
`nologin` accounts.

**23.** `sudo useradd -M -s /usr/sbin/nologin survey-svc` then `sudo passwd -l survey-svc`.

**24.** `survey-svc L …` — identical to Tulane's before a password was set. It was already
unreachable by password, because it never had one. The lock buys you one thing: it survives somebody
later setting a password on the account, and it makes the intent explicit in a file an auditor reads.
Defence in depth, not defence.

**25.** It prints `hello`. The login shell in `/etc/passwd` field 7 is what gets run *when something
logs you in* — `login`, `sshd`, `su`. `sudo -u` runs the command you named. `nologin` is not a
permission and does not restrain root or anything root delegates: it closes one door, the interactive
login, and the account can still own files, run scheduled work, and be the identity of a process.

**26.** `sudo usermod -c "Okonkwo, A., deck-03" okonkwo`

**27.** `sudo usermod -s /bin/sh tulane`; `getent passwd tulane`; `sudo usermod -s /bin/bash tulane`.

**28.** `sudo usermod -aG hydroponics tulane`, then `getent group hydroponics` and
`sudo -u tulane id -nG`. The second is a *new process*, so it sees the change — the lesson-02 point
from the other side.

**29.** One of three. The login name is now `tulane-m`. Field 6 still says `/home/tulane`, and the
directory on disk is still `/home/tulane`. The group is still called `tulane`.

**30.** "`usermod -l` renames the login and nothing else — not the home directory, not the path
recorded in `/etc/passwd`, and not the per-account group — so a rename leaves three things named
after somebody who no longer exists." Undo: `sudo usermod -l tulane tulane-m`.

**31.** `!` — and it was `!` before. Locking prefixes the stored hash with `!`; there was no hash, so
there is nothing to see. Unlocking with `sudo usermod -U okonkwo` gives you `!` again, and
`passwd -u` refuses outright with "unlocking the password would result in a passwordless account".

**32.** Length and shape. A locked account that *had* a password shows `!$6$…` — the `!` followed by
the real SHA-512 hash, which is unmistakable. A locked account that never had one shows exactly `!`
and nothing more. (`*` is a third case: a system account that was never intended to have one.)

**33.** Last password change → field 3. Password expires → field 5. Password inactive → field 7.
Account expires → field 8. Minimum days → field 4. Maximum days → field 5. Warning → field 6.
Note that `chage -l` prints field 5 twice, once as a date and once as a count.

**34.** Days since 1970-01-01 — the epoch, in days rather than seconds.
`date -d "1970-01-01 + 20694 days"` gives the day the account was created, which is when the empty
password was written.

**35.** About 273 years. It is the absence of a decision: `PASS_MAX_DAYS 99999` in
`/etc/login.defs` is the shipped default and means "never", written as a number because the field has
to hold one.

**36.** `sudo chage -M 90 -W 14 tulane`

**37.** Field 5 goes 99999 → 90, field 6 goes 7 → 14. Yes. Nothing else moved — importantly, field 3
did not, so the 90 days are counted from the last change, not from now.

**38.** `sudo chage -E 2187-12-31 okonkwo`

**39.** "Account expires" moved. "Password expires" did not. That is the point: the posting ends on a
date regardless of how recently she chose a password, and expiring the password instead would just
prompt her for a new one and let her carry on.

**40.** The password one you can talk through — they will be prompted for a new password at login and
that is the whole fix. The account one needs root: no password entry can clear field 8, and the user
has no way to change it.

**41.** Field 3 becomes `0`, which reads as "changed at the epoch" and is understood as "must change
now". At the next login they are forced to set a new password before they get a shell.

**42.** Field 5 expires the password; field 7 is the grace period after that before the account is
disabled outright. With `-1` the account waits indefinitely for the person to come back and change
their password. With `7`, somebody on a two-week posting off-station comes home to an account that is
not merely expired but dead, and needs root to get back in. Field 7 is a decision about people who
are away, and that is why it should be set deliberately or not at all.

**43.** `haldane` is owned by `4102 4102` — numbers, not names. `kalvi` is `rhea crew` and `probe` is
`probe probe`.

**44.** `4102` in both columns: it is the uid *and* the gid. `ls` prints the number when it cannot
find a name for it, and it looks up owners and groups in two different databases, so both failed.

**45.** Nothing is printed and the exit status is 2. No account has that number. The files are owned
by a number with no name behind it.

**46.** 4102 is not in the retired list, but 4098–4101 are, in order and one per year or two. Somebody
was following the policy — retiring numbers and recording them — and then stopped, or missed one.
Either the account at 4102 was removed by somebody who did not know about the file, or it was removed
in a hurry.

**47.** `-nouser` tests whether the file's uid resolves to any entry in the account database. It does
not care what the number is. That is why it is the right check: it finds every orphan, not the one
you already know about.

**48.** Step 3 — deciding about the home directory before deleting the account. The README says it in
so many words: "nobody decided what to do with this directory".

**49.** Something a real archive copy does. A `cp -a` or a `tar` extraction run as one user, or a
restore where the uid did not map, can put somebody else's name on a whole tree. To settle it: check
whether *all* the files under `kalvi` are `rhea` or just some; check the mtimes against the copy date
in `homes/README`; and compare with the same directory on the archive host if you can reach it.
Uniform wrong ownership with a uniform mtime is a copy artefact. Mixed ownership is not.

**50.** 1009 — the lowest free number at or above 1000, given tulane 1007, okonkwo 1008.

**51.** `sudo useradd -m relief` — 1009, as predicted.

**52.** `sudo useradd -m -u 4102 relief2`, then `sudo ls -l homes/haldane` prints
`relief2 relief2` on every file. A person who has existed for one second now owns files written in
2181.

**53.** A file does not store an owner's *name*. Its inode stores a uid, a number, and nothing else.
Ownership is resolved at display time by looking that number up in the account database. Creating an
account with that number changed the answer to the lookup, not the file. This is also why the mtimes
did not change: nothing wrote to the files.

**54.** It works, and no, it should not. `relief2` is not Haldane, has no relationship to Haldane, and
was created after Haldane left the station. But the kernel has no concept of either of those things —
it compared the process's uid to the file's uid, they matched, and the owner triad said read.

**55.** "A newly created account was allocated uid 4102, which had been in use by a removed account
whose home directory was never dealt with. As a result the new account owns, and can read, every file
that account left behind; no file was copied or modified, and nothing in the file listing would look
wrong to somebody who did not know the history."

**56.** The cost is bookkeeping that must never be skipped. A retired-uid list is a file somebody has
to maintain by hand, forever, and it is only correct if every removal updates it — so the policy
works exactly as well as the least careful removal anybody does. The lab's own `retired-uids.txt`,
which stops at 4101 while 4102's files sit next to it, is the demonstration.

**57.** `sudo userdel -r relief2`, then `sudo ls -l homes/haldane` shows `4102` again. (`userdel`
may warn that the mail spool was not found; that is harmless.) Note the direction: removing the
account did not restore anything, it just removed the name that was making the lookup succeed.

**58.** `sudo userdel -r relief`, then `ls /home`. If you had used bare `userdel`, `/home/relief`
would still be there — with a number in the owner column, and you would have made a second orphan
inside the exercise about orphans.

**59.** For each: `sudo usermod -L merrick` (or `passwd -l`), and `sudo chage -E <the departure date>
merrick` so the account is expired as well as locked. The step **not** to do today is `userdel -r`:
the departures are already two months old, the convention's two-week wait has long passed, but step 3
has not happened — nobody has said what becomes of the home directories, and `homes/haldane` is what
doing that step out of order looks like. Lock now, delete when somebody decides.

**60.** "Tulane and Okonkwo have accounts, both in crew with bash and a home directory; survey-svc
exists with no login and is locked. I have locked and expired the two rotation-6 accounts rather than
removing them. Looking at the archived homes, one directory — haldane — belongs to a user number that
no longer exists on the station, which means that account was removed without anyone deciding what to
do with its files, and anyone we create with that number in future would inherit them. Before I
remove Merrick's and Voss's accounts I need somebody to tell me whether their home directories are
archived, handed over, or deleted."

**61.** No. `homes/probe` is owned by `probe`, which exists — `ls -l` shows a name, and
`find -nouser` does not match it. An account with no home directory of its own can still own
directories; "orphan" means the owner is a number the database cannot resolve, not "the owner is
unusual". The difference is whether there is still somebody to ask.

**62.** `sudo find / -xdev \( -nouser -o -nogroup \) -printf '%U %G %p\n'`. It is a full traversal of
every inode on the filesystem, so on a large disk it is slow and it evicts the page cache, and
`-xdev` is there so it does not wander into other mounts. Run it out of hours, accept that it is slow
rather than trying to make it clever, and store the output so that next month's run can be diffed
against it — the new orphans are what you care about.

**63.** `sudo userdel -r tulane`, `sudo userdel -r okonkwo`, `sudo userdel -r survey-svc` (which has
no home, so `-r` has nothing to do and says so). Then `getent passwd tulane okonkwo survey-svc` and
`ls /home`.

**64.** Gone. `userdel` removed each per-account group along with its account. It only does that when
the group is otherwise empty and is the account's own — it will not delete `crew` because you removed
somebody from it.

**65.**

```bash
newcrew() {
  local name=$1 gecos=$2 dept=$3
  if getent passwd "$name" >/dev/null; then
    printf 'newcrew: %s already exists\n' "$name" >&2
    return 1
  fi
  sudo useradd -m -s /bin/bash -c "$gecos, $dept" -G crew "$name" || return
  sudo passwd -l "$name" >/dev/null
  printf 'created %s (uid %s), crew, locked pending a password\n' \
         "$name" "$(id -u "$name")"
}
```

`getent passwd` asks the account database the question you actually mean. `grep` asks whether a
string appears in one file — it would match a substring of a longer name, match a name appearing in
somebody's gecos field, and miss accounts that come from anywhere other than `/etc/passwd`.

**66.** 9, which `man useradd` gives as "username already in use". Test the status because the message
is prose: it is translated into the user's language, it has been reworded between versions, and it
goes to stderr where a script has to go out of its way to catch it. The number is the interface.

**67.** Perl — the first line is `#! /usr/bin/perl`. It tells you `adduser` is a policy layer written
by a distribution, not part of the shadow tools, so its behaviour is Debian's and its flags will not
be there on a Red Hat machine or in a minimal container. Fine at a prompt, wrong in a script you want
to survive a move.

**68.** Because a great deal of ordinary, unprivileged software needs to turn a uid into a name — `ls`
does it on every listing — and nothing about that requires the password hashes. Making
`/etc/passwd` 640 would break name lookup for every non-root process; leaving the hashes in it would
hand every user on the machine a file to attack offline at their leisure. Splitting the file lets the
public half stay public and the secret half stay secret, which is the same reasoning as
`engineering/access.txt` in lesson 02: separate the thing everyone must read from the thing almost
nobody may.
