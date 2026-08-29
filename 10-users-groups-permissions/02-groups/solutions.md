# 10/02 — Solutions

Do not read this until you have written your own answers.

---

**1.** Both print `cadet sudo plocate crew`. `id -nG` documents that the primary group comes first;
`groups` is a different implementation of the same question and its order is not something to build
on. If order matters to your script, you are asking the wrong question — test membership instead.

**2.** `cadet` and `1008`. The name matches your account name, because `useradd` creates a group per
user by default. That is a convention. The *number* does not match your uid (1005).

**3.** `crew:x:1001:rhea,cass,dorn,cadet` — name, password placeholder, gid, members. Four members
listed.

**4.** `cadet:x:1008:` — empty member list. You are in the group by virtue of field 4 of your
`/etc/passwd` line, which is where *primary* membership lives. `/etc/group`'s member list records
*supplementary* membership only, so a primary member's name is correctly absent.

**5.** `/etc/passwd`, field 4. `getent passwd cadet | cut -d: -f4` → `1008`, which is `cadet`'s gid.

**6.** Two files, two questions: "is X's primary gid this group's gid?" (`/etc/passwd` field 4) and
"is X's name in this group's member list?" (`/etc/group` field 4). Either one is a yes.

**7.** `engineering:x:1002:rhea`. Just rhea. You are not in it.

**8.** rhea: `rhea crew engineering`. You: `cadet sudo plocate crew`. She has `engineering`; you have
`sudo` and `plocate`, which she does not.

**9.** The tail is `rhea:1004 cass:1005 dorn:1006 ops-bot:1007 cadet:1008 hydroponics:1009
probe:1010 nogroup:65534`. The per-account ones are the five whose names match an account name and
whose gids run consecutively in the order the accounts were created. `nogroup` is the group half of
`nobody` and breaks the ≥ 1000 heuristic exactly as `nobody` did in lesson 01.

**10.** `engineering` is `rhea:engineering` mode `750`; every other directory is `cadet:crew`.
`shared` is `775` — group-writable, which the others are not.

**11.** `ls: cannot open directory 'engineering': Permission denied`, rc 2. The kernel checks in
order: are you the owner (no, rhea is); are you in the owning group (no, not yet); otherwise "other"
— and `750` gives other nothing. Only **one** triad is applied, the first that matches. You do not
get the union.

**12.** No. Directory permissions and file permissions are independent. `r` on a directory is
permission to list its names; without `x` you cannot reach the files at all, whatever their own modes
say. You are being stopped at the door, so you have learned nothing about the rooms.

**13.** `drwxr-x---`: the owner (rhea) may read, write and traverse; the group (`engineering`) may
read and traverse but not create or delete; everyone else may do nothing.

**14.** `rhea engineering 750`. The group name — `engineering` — is the one you can do something
about, because groups have members and owners do not.

**15.** `cadet crew 664`. The **owner** triad: you own the file. Note that the group triad would also
have allowed it; the kernel stopped at the first match, and the first match was owner.

**16.** Write permission — on the **file**. Appending modifies a file that already exists, so the
file's `w` bit is what is checked. You did not need `w` on the directory, because you did not create
or remove a name in it. That distinction is lesson 04.

**17.** You cannot read it. rhea asks you to read `engineering/access.txt` before joining, which is
inside the directory the access controls — a small joke with a real point: the "ask first" convention
is the actual control, and the mode is only the enforcement.

**18.** Write your prediction down. Most people predict it works.

**19.** No output means `usermod` had nothing to complain about, which is not the same as "the change
you wanted". Check with `getent group engineering` or `id cadet` — never with `id`.

**20.** `engineering:x:1002:rhea,cadet`.

**21.** `uid=1005(cadet) … 1002(engineering)`. The **account** is in the group.

**22.** No `engineering`. The **process** is not.

**23.** `Permission denied`. The kernel checked your process's credentials, and they have not changed.

**24.** `id cadet` performs a fresh lookup of an account in the account database. `id` with no
argument reports the credentials of the running process, which were fixed when the process was
created. The database is current; your shell is a snapshot.

**25.** Credentials are handed to a process by the kernel when it is created and are **copied** into
every child. They are held in the process, not looked up per access. Nothing goes back and re-reads
`/etc/group` for a process that already exists, so a shell started before the change keeps the old
set for its entire life — as does every command you run from it, since they are its children.

**26.** `cadet sudo plocate crew engineering` — but note that `sg` starts a **new** process, and a new
process gets a fresh set of credentials built from the account database at the moment of creation.
It is current because it is new.

**27.** It works, and `access.txt` says additions go through the lead and that the group is a record
of who was asked. Answering "no, I would have asked first" is a perfectly good answer to this
exercise and rhea's scene in lesson 07 will assume you thought about it.

**28.** `id -gn` → `engineering`; `id -nG` → `engineering sudo plocate crew cadet`. Two changes:
`engineering` was added, **and it became your primary group** — `cadet` is now merely supplementary.
A file you create right now will belong to group `engineering`.

**29.** `from-newgrp` is group `engineering`; `from-normal` is group `cadet`. Neither is `crew`,
even though `scratch/` itself is `cadet:crew` — a new file takes its group from the creating
**process**, not from the directory it lands in. (There is one exception, the setgid directory, and
it is lesson 08.)

**30.** The **primary** group — the one `id -gn` reports. Supplementary membership grants access and
never decides the ownership of anything you create.

**31.** `id -gn` → `cadet`. `newgrp` started a shell; `exit` leaves it and drops you back into the
one that never changed.

**32.** `Removing user cadet from group engineering`. `getent group engineering` → `rhea` only.

**33.** `Password:`, and then `Invalid password.` It is asking for the **group's** password, not
yours. `sg` will let a non-member in if the group has a password and they know it.

**34.** No password is set, so no password can be right, and it refuses. The rule: `newgrp` and `sg`
change which of *your* groups is active. They are not a way to acquire a group you are not in.

**35.** `-rw-r----- root shadow`. Group passwords live in `/etc/gshadow`, readable only by root and
the `shadow` group. They are a bad idea because a group password is a shared secret: everyone who
needs the group must know it, nobody's use of it is attributable, and it cannot be revoked from one
person.

**36.** `getent group engineering` → `rhea,cadet`; `id cadet` shows it; `id` still does not, in this
shell, forever.

**37.** `probe crew ops hydroponics`.

**38.** `-aG` **adds** to the supplementary list. `-G` **sets** the supplementary list to exactly what
you typed, removing everything else.

**39.** `probe` (primary) and `hydroponics`. `crew` and `ops` are gone.

**40.** `probe hydroponics`. Two memberships destroyed, and the command printed **nothing**. There is
no confirmation, no summary of what was removed, and no undo. That is the entire danger.

**41.** `probe crew ops hydroponics` again. The primary group survived because it lives in
`/etc/passwd` field 4, and `-G` only touches supplementary lists in `/etc/group`. `usermod -g` is the
one that changes the primary, and it is a different flag on purpose.

**42.** It would set your supplementary groups to exactly `engineering` — removing `sudo`, `crew` and
`plocate`. Your current shell would keep working, because of exercise 25, and the moment you closed
it you would have no way to get `sudo` back. Recovery needs somebody with root by another route: on
this station, `docker exec -u root`. On a real machine, single-user mode or the console.

**43.** "Adding a group is always `usermod -aG` or `gpasswd -a`; `usermod -G` is a *replace* and is
never the right command for adding one person to one group. Prefer `gpasswd -a USER GROUP`, which has
no destructive form to mistype."

**44.** 22.

**45.** 13 have members. The other nine are either per-account groups (nobody is listed because the
member is primary), or system groups a package created and nothing was ever added to — `tty`, `disk`,
`www-data` exist so that files and devices have a group to belong to.

**46.** `crew engineering medical galley hydroponics deck-02 deck-03 deck-05 comms archive-ro`.
Departments: everything except `crew` (which is everybody) and `archive-ro` (which is a capability,
not a department).

**47.** Different **members** is expected — the export is a copy from a different machine's database
taken four days earlier, and this container is a training environment with a different population.
The different **gid** for `crew` (1000 in the export, 1001 here) is the one to check: the same name
with two numbers means files copied between the two systems would land with the wrong group, silently.

**48.** `archive-ro` is a *capability* group — it names a permission ("may read the archive"), not a
team. It is better than granting the same access to `crew` because it is a list of exactly who has
that access and can be read at a glance, and because removing somebody's access is one command that
does not also take away everything else they do.

**49.** `18 crew`, `3 deck-05`, `2 sudo`. `crew` is everybody aboard, so it is not a boundary at
all — granting access to `crew` is granting it to the station. It is still useful as a *floor* ("at
least someone aboard"), which is what `shared/` uses it for.

**50.** You cannot determine **when** anybody was added, or by whom, or why. `/etc/group` records
state, not history. That would be in the account database's audit log, or in whatever ticket the
addition was requested in — which is exactly what `engineering/access.txt` means by "a record of who
was asked".

**51.** "I added myself to `engineering` to read the strain export for the 13th while working through
the permissions material; the data I read was `strain-export-2187-06-13.csv`. Tell me if you would
rather I had asked first and I will drop the membership."

**52.** "Adding you to a group changes the account database, but your shell got its group list when
it started and keeps that copy until it exits — so the change is real and your current session cannot
see it. Log out and back in, and it will work. If you need it right now without logging out, run
`newgrp engineering`, which starts a fresh shell with the new list."

**53.** `chgrp engineering scratch/f` → `Operation not permitted`. `chgrp crew scratch/f` → works.
`chgrp ops` → not permitted. You may give a file you own to a group **you are in** — and "you are in"
means your *process*, which is why `engineering` fails even after exercise 36 put it in the account
database. Only root can hand a file to a group it is not in.

**54.** Group `crew`, not `cadet` — compare with `from-normal` in exercise 29. Yes, that is exactly
what it is for: `sg GROUP -c 'command'` runs one command with `GROUP` as the primary, so files it
creates get that group. It is the one-shot version of exercise 29 and it does not leave you sitting
in a nested shell you have to remember to leave.

**55.** `/proc/<pid>/status`, the `Groups:` line — `27 999 1001 1008`, by number. Also `Uid:` and
`Gid:` with four columns each (real, effective, saved, filesystem). Chapter 9's point again: what a
process *is* is readable from outside it.

**56.** Nothing happens to them. They keep the credentials they were given and keep the access. So
removing somebody from a group revokes *future* access, not current: to make a revocation real you
also have to end their sessions and their running processes. This is the honest answer to "I removed
their access" and it is why offboarding has more steps than adding.

**57.**

```bash
ingroup()         { id -nG    | tr ' ' '\n' | grep -qx -- "$1"; }
account_ingroup() { id -nG "$(id -un)" | tr ' ' '\n' | grep -qx -- "$1"; }
```

The first asks the process, the second asks the database. Between `usermod -aG` and your next login
they disagree, which is the whole lesson. Note `grep -qx` rather than a substring match — `crew`
must not match `crew-relief`.

**58.**

```bash
members() {
  local g=$1 gid
  gid=$(getent group "$g" | cut -d: -f3) || return 1
  { getent group "$g" | cut -d: -f4 | tr ',' '\n'
    getent passwd | awk -F: -v g="$gid" '$4 == g { print $1 }'
  } | sed '/^$/d' | sort -u
}
```

On `crew`: rhea, cass, dorn, cadet. On `cadet`: just `cadet`, found entirely through the second half.

**59.** `getconf NGROUPS_MAX` → 65536 here. A number that large rewards **many small groups**: there
is no practical reason to overload one broad group when you can create a precise one per capability,
which is the case for `archive-ro` in exercise 48.

**60.** Every group is a thing somebody has to know exists, decide about, and clean up. Thirty groups
means thirty membership lists that drift, and a new arrival needs a decision on each one — so the
cost is paid by whoever onboards people and by whoever audits access, in time and in mistakes, while
the benefit goes to whoever needs to revoke one thing precisely. rhea's "the membership list is
eleven years old" is that cost, arriving late.
