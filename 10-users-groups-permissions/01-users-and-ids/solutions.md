# 10/01 — Solutions

Do not read this until you have written your own answers.

---

**1.** `whoami` prints `cadet`. `id` adds: the uid as a number (1005), the primary group as both
number and name (1008, `cadet`), and every supplementary group — `sudo` (27), `plocate` (999),
`crew` (1001). `whoami` answered "what name"; `id` answered "what privileges".

**2.** uid 1005, primary gid 1008. Four groups. They are **not** equal, and on this container none of
the five human accounts has a matching pair.

**3.** `id -u` → `1005`, `id -un` → `cadet`. `-g` asks about the primary *group*: `1008` and `cadet`.
The group happens to be named after the account, which is a convention and not a rule.

**4.** `id -G` → `1008 27 999 1001`; `id -nG` → `cadet sudo plocate crew`. In a script use the
numbers: names are looked up and the lookup can change or fail, whereas the numbers are what the
kernel actually checks. A membership test on names also breaks if two groups have similar names.

**5.** Identity is not a secret; authorisation is. Knowing rhea's uid does not let you act as her —
that needs her credentials or root. The secrets live in `/etc/shadow`, which is not world-readable.

**6.** uid 0, gid 0.

**7.** `id: 'nosuchperson': no such user`, `rc=1`. A script uses the status; the message is for a
person and is not stable across tools or locales.

**8.** 24.

**9.** `cadet` / `x` / `1005` / `1008` / *(empty gecos)* / `/home/cadet` / `/bin/bash` — name,
password placeholder, uid, primary gid, gecos, home, shell.

**10.** `cadet:1005:1008:/bin/bash`. Field 7 is the program the login process runs as you. It is not
a permission — it is what gets started.

**11.** `/usr/sbin/nologin`. It stops an interactive login from producing a usable shell: `nologin`
prints a refusal and exits non-zero. It does **not** stop the account owning files, running
processes, being the target of `sudo -u`, or being used by a service that never logs in — which is
exactly how a summariser ran under `ops-bot` for eighteen months in chapter 9.

**12.** Both empty. `$USER` is an environment variable that a login program sets and every child
inherits. `whoami` asks the kernel for this process's effective uid and looks the number up. One is
a copied label, the other is a live question.

**13.** `logname: no login name`. `logname` reads the login accounting record (`utmp`). A `docker
exec` session is not a login — no record was written, so there is nothing to read. Note that this is
a *correct* failure: `logname` refused rather than guessing.

**14.** `x`, on every line. The hash it replaced moved to `/etc/shadow`.

**15.** `/etc/passwd` is `root:root 644`; `/etc/shadow` is `root:shadow 640`. Every program that
prints a username instead of a uid must read the mapping, so the mapping is public — and it can be
public precisely because the secrets were moved out of it.

**16.** `cat: /etc/shadow: Permission denied`. Mode 640, owner `root`, group `shadow`: you are
neither, so you fall through to the "other" bits, which are empty. The file is for root and for
programs that run with group `shadow`.

**17.** `dorn:x:1003:1006::/home/dorn:/bin/bash`. `getent` takes a key that is either a name or a
number, and looks in the correct field for each. The number is the account's real identity, so
looking up by number always works even when the name is unhelpful.

**18.** `rc=2`. Note that it differs from `id`'s `1` in exercise 7 — "not found" is `getent`'s
documented 2. Never assume a non-zero status means the same thing across two tools.

**19.** Two lines: `rhea` and `ops-bot`. `rhea` matched on field 4 (her primary gid is 1004);
`ops-bot` matched on field 3 (its uid is 1004). Same digits, different meaning, and `grep` cannot
tell them apart because it is matching text.

**20.** `ops-bot`. `getent` asked "which account has uid 1004", looking only at field 3. `grep` asked
"which lines contain the characters 1004 anywhere".

**21.** They agree here. They disagree as soon as one account's name is a substring of another's, or
appears in another's gecos or home path — an account named `cassette` would make `grep cass` return
two lines, and the extra one is wrong. `grep deck` on the export returns seven lines because `deck
02` / `deck 03` / `deck 05` appear in the gecos field; there is no account called `deck`.

**22.** `grep '^cass:' /etc/passwd` — anchor at the start of the line and include the field
delimiter. It is correct, and you would still use `getent`, because `getent` also consults any other
name source the system is configured with (LDAP, NIS, `systemd-homed`), and `grep` only ever sees the
local file.

**23.** `UID_MIN 1000`, `UID_MAX 60000`.

**24.** `nobody`, `ubuntu`, `rhea`, `cass`, `dorn`, `ops-bot`, `cadet`. People: rhea, cass, dorn and
you. `ubuntu` is the image's default account and `ops-bot` is automation.

**25.** `nobody`, uid **65534**. The rule says "≥ 1000 means somebody asked for it", and `nobody` is
the most system of all system accounts — it exists to be the identity with no privileges. Its uid is
high because it is conventionally `2^16 − 2`, chosen to be the largest value that fits in the old
16-bit uid type, which puts it above `UID_MIN` by accident of history.

**26.** "Accounts with uid ≥ `UID_MIN` were created by somebody rather than by a package." And:
"`nobody`, and on some systems `nfsnobody`, sit above the boundary for historical reasons and are
system accounts anyway." Both sentences, always.

**27.** 34.

**28.** 20 × `/bin/bash`, 13 × `/usr/sbin/nologin`, 1 × `/bin/sync`.

**29.** `sync`, uid 4. `sync(1)` flushes the filesystem buffers to disk and exits. As a login shell
it means: logging in as `sync` syncs the disks and immediately logs you back out. It is a deliberate
old-Unix convenience, and it is also the clearest possible demonstration that field 7 is just "a
program to run", with no requirement that the program be a shell.

**30.** 13 system, 21 at or above 1000. 13 + 21 = 34. ✓

**31.** `awk -F: '$3 >= 1000 && $7 == "/bin/bash"' roster/passwd.export | wc -l` → **19**.

**32.** The crew list has 17 people aboard. 19 − 17 = 2: `dorn`, whose account survives him (he left
2187-05-24 and the list says so), and `cadet`, who is on a training berth and not established crew.
Every extra accounted for, by name.

**33.** `eng-svc`, uid **1207**, shell `/usr/sbin/nologin`. (`nobody` is excluded by the question;
every other account at or above 1000 has `/bin/bash`.)

**34.** Everything else that a person or a service got sits in a tight block — 1001 to 1018, then
`cadet` at 1500. `eng-svc` sits alone at 1207, in the gap. Numbers are handed out sequentially by
`useradd` unless somebody names one explicitly, so a uid on its own in a gap was chosen by hand.

**35.** Only `eng-svc`. Every other service account in the export has a description in gecos —
`station logging daemon`, `hull monitor`, `door log daemon`, `operations automation`, `strain sampler
service`. The convention is followed thirteen times and broken once.

**36.** Nineteen accounts have a login shell and a uid in the human range; seventeen match a person
on the crew list, one belongs to somebody who has left, and one is a training berth. The service
accounts are identifiable by their uid block, their `nologin` shell and their gecos description.
`eng-svc` matches the service pattern in shell only: its uid is out of the block and it has no
description, so I cannot classify it from the export alone.

**37.** Ask the account database for its creation date and who requested it. (Do not run it, do not
guess the answer, and do not name a person.)

**38.** `sync` (uid 4, gid 65534) and `man` (uid 6, gid 12). Neither is a person. Old system accounts
predate the "give each user their own group" convention and were assigned to shared system groups.

**39.** On the real `/etc/passwd`: `sync`, `games`, `man`, `_apt`, and **all five** of `rhea`, `cass`,
`dorn`, `ops-bot`, `cadet` — including you. So `chown NAME:NAME` is a guess, and on this container it
is the wrong guess every time for a human account. Use `chown NAME:` (which means "the account's own
primary group") or name the group explicitly. Lesson 06 does this properly.

**40.** Both 24. They differ on any system where accounts come from somewhere other than the local
file — a directory service, for instance — because `getent` asks the whole name-service stack and
`wc -l /etc/passwd` counts one file. Trust `getent`.

**41.** `cadet sudo plocate crew` versus `rhea crew engineering`. Shared: `crew`. She has
`engineering`, you do not. You have `sudo`, she does not — which is going to be the subject of an
uncomfortable conversation in lesson 07.

**42.** `/home/rhea`, and `ls` fails: `ls: cannot open directory '/home/rhea': Permission denied`,
rc 2. `ls -ld` shows `drwxr-x--- rhea rhea`: owner and group only, nothing for other. You are not
rhea and you are not in her group.

**43.** "The export contains one account, `eng-svc`, that does not match the pattern of the station's
service accounts and does not match any name on the crew list; I could not classify it from the
export and I have not tried to." No accusation, no person, no verb with an actor.

**44.** "This is a classification, not a recommendation — an account I could not classify is an
account to ask about, not an account to remove."

**45.** "All of this is derived from an export taken 2187-06-10; anything created, changed or removed
since then will not appear."

**46.** Two lines have `$3 == 0`. Which one is root? **Both.** There is no field that says
"this is the real root"; uid 0 is root, and an account is whatever its uid says it is. The name
`root` is a label that happens to be conventional.

**47.** It would be root: every kernel check compares the number. Historically, write access to
`/etc/passwd` *was* root, which is why the file is `root`-owned mode 644 and why `passwd` is one of
the few setuid programs on the system (lesson 08). `sudo` exists so that granting somebody the
ability to do one administrative thing does not require handing them uid 0 permanently.

**48.**

```
awk -F: '{ printf "%-14s %6s %s\n", $1, $3, $7 }' roster/passwd.export
cut -d: -f1,3,7 roster/passwd.export | column -t -s:
```

`column -t` is shorter to type and re-aligns to the data; the `awk` version has fixed widths, so its
output is stable when the input changes. Use `column` at a prompt and `awk` in anything whose output
gets diffed.

**49.** `cut -d: -f4 roster/passwd.export | sort -n | uniq -c | sort -rn`. One gid is shared: 65534,
by `sync` and `nobody`.

**50.** Three lines, one per key, in the order you asked. With a key that does not exist you get the
lines for the ones that do and `rc=2` — a partial success reports failure, so never treat `getent`'s
zero status as "all of them were found" unless you also count the lines.

**51.** Two files. The primary group comes from field 4 of `/etc/passwd`; the supplementary groups
come from the member lists in `/etc/group`. Prove it: `getent passwd cadet | cut -d: -f4` gives 1008,
and `getent group crew` shows `cadet` in the member list, while `getent group cadet` does **not** list
you as a member — you are in it by field 4, not by membership. That asymmetry is lesson 02.

**52.**

```bash
whois_uid() {
  local ent
  if ent=$(getent passwd "$1"); then
    printf '%s\n' "${ent%%:*}"
  else
    printf 'uid %s (no account)\n' "$1"
    return 1
  fi
}
```

**53.** `0 root 0 root`. `%u`/`%g` are the numbers, `%U`/`%G` the looked-up names. If the owning
account is deleted, the lookup fails and `stat` prints the *number* in the `%U` field — as does
`ls -l`. A bare number in an owner column means "no account has this uid", and in lesson 06 you will
meet a file that shows one.

**54.** Lock the password so the credentials stop working; end any running sessions and processes;
decide what happens to the files the account owns — reassign them to somebody who will answer for
them, or archive them — *then* remove the account. Removing first leaves every file owned by an
unresolvable number, which is how a station ends up with orphaned trees nobody will claim. Lesson 03.

**55.** They get the list of valid account names, which turns "guess the username and the password"
into "guess the password". The defence is not hiding the file — it is that the password is not in it,
plus rate limiting and key-based authentication, so that knowing the name buys nothing.
