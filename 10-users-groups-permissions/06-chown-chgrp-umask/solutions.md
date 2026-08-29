# 10/06 — Solutions

Instructor copy. Every result below was measured in the container.

---

## Reading the two columns

**1.**

```
-rw-r--r-- 1 root root 50 Jun 19  2187 cycle-41.raw
-rw-r--r-- 1 rhea crew 50 Jun 19  2187 cycle-42.raw
-rw-r--r-- 1 4102 4102 29 Jun 18  2187 unclaimed.raw
```

**2.** The numbers as well as the names:

```
root    root    0    0     intake/cycle-41.raw
rhea    crew    1001 1001  intake/cycle-42.raw
UNKNOWN UNKNOWN 4102 4102  intake/unclaimed.raw
```

**3.** `unclaimed.raw`: `ls -l` prints `4102 4102` and `stat -c %U %G` prints `UNKNOWN UNKNOWN`.

**4.** Because the lookup failed. The file stores a uid and a gid — two integers. `ls` asks the
account database for names to print and, finding none, prints the integers instead. It is a property
of the **account database**, not of the file. The file is not damaged and nothing is missing from it.

**5.** Both return nothing and exit 2. No such account, no such group.

**6.** `stat`'s `UNKNOWN` is a *value*, and a script that tests for it will keep working; `ls -l`'s
`4102` is ambiguous with a real account literally named `4102`. For scripts, prefer numeric fields
(`%u`, `%g`) or `find -nouser`, which asks the question directly rather than parsing an answer.

**7.** Establishable: uid 4102, gid 4102, size 29 bytes, mode 644, mtime 2187-06-18 23:12, that no
account currently maps to either number, and the contents. Not establishable: who created it, whether
uid 4102 ever named a person, whether the account was deleted or never existed, and why it is there.
rhea asked for the first list precisely because the second is where people invent things.

---

## chown is root's

**8.** `chown: changing ownership of 'intake/cycle-41.raw': Operation not permitted`

**9.** Same message for `handoff/week-24.txt`. Owning the file does not help.

**10.** Only root may change a file's owner.

**11.** The owner is a field in the inode. The nine bits describe what may be done to the file's
*contents* by three classes of user; none of them describes authority over the inode's own fields.
`chmod` cannot grant a permission that is not one of the nine.

**12.** Quotas: if you could give files away you could dump your storage on somebody else's account.
The second reason is setuid — a program that runs with the permissions of its owner. If you could
hand a file to root, you could hand root a program that root then runs as root. Lesson 08.

**13.** After the first: `cadet crew`. After putting it back: `UNKNOWN UNKNOWN 4102`.

**14.** The file stores **numbers**. Names are a display convenience resolved at read time. `chown`
accepts a number and does not check that anything maps to it.

**15.** `chown: invalid user: 'nosuchuser'` — and this failure is different in kind: it happened
*before* touching the file, in the name-to-number lookup. Exercise 14 succeeded because a number needs
no lookup. Names are validated; numbers are taken at face value.

---

## chgrp is usually yours

**16.** All three files are `cadet cadet`, mode `640`. The directory is `cadet crew`, mode `775`.

**17.** `uid=1005(cadet) gid=1008(cadet) groups=1008(cadet),27(sudo),999(plocate),1001(crew)`.

**18.** Succeeds: `cadet crew`.

**19.** `chgrp: changing group of 'handoff/week-25.txt': Operation not permitted`.

**20.** You may change a file's group if **you own the file** *and* **you are a member of the target
group**. Both halves, every time.

**21.** Because group ownership is how access is *delegated*, and a delegation you can perform on
yourself is not a delegation. The membership half of the rule is what makes `chgrp` a way to share
access you already hold rather than a way to acquire access you were not given: you can only move a
file into a room you are already in.

**22.** Fails, same message. You are in `crew`, but you do not own the file, and the first half of the
rule is not optional.

**23.** `chgrp crew handoff/*.txt` (or `chgrp -R crew handoff`, which also changes the directory —
already `crew`, so harmless here, but say so).

**24.** The files are `640`, so group `crew` now has **read**. Nothing gained write; the `other` triad
is still empty; the files' owner is unchanged. `chgrp` moved who the middle triad applies to, not what
it says.

**25.** `touch handoff/probe.txt` gives group **`cadet`**, not `crew`. The group came from the
creating process — your primary group — not from the directory.

**26.** `sg crew -c 'touch handoff/probe2.txt'` gives `cadet crew`. `sg` ran the command with `crew`
as the primary group; nothing about the directory or the file changed.

**27.** The mechanism exists and it is the setgid bit on the directory (lesson 08). Credit any guess
that says "something set on the directory"; do not credit a student who concludes there is no way.

**28.** Housekeeping.

---

## The colon forms

**29.** Same effect: both give `cadet crew`, both exit 0. `chown :group` is `chgrp` with a different
spelling, and both are subject to the same two-part rule.

**30.** `cadet cadet`. `chown user:` sets the group to that user's **login group**, looked up in the
account database.

**31./32.** Measured:

| command | owner | group |
|---|---|---|
| `chown cadet FILE` | set to cadet | **unchanged** |
| `chown cadet:crew FILE` | set | set to crew |
| `chown :crew FILE` | unchanged | set to crew |
| `chown cadet: FILE` | set | set to cadet's login group |

Only `chown USER` with no colon leaves the group alone.

**33.** Both columns. `chown --reference=handoff/rota.txt scratch/colon` leaves both files
`cadet cadet`. There is no way to make `--reference` copy only one; use `chgrp --reference` if you
want the group alone.

**34.** When the right answer is "the same as that file" and you do not want to hardcode it — a
deploy script that must match whatever account the service happens to run as, or fixing one file that
was missed in a directory where everything else is already correct.

**35.** First run: `changed ownership of 'scratch/colon' from cadet:cadet to cadet:crew`. Second run
prints nothing. `-c` is a change log, and silence means no-op.

---

## Recursion and symlinks

**36.** Three groups — `cadet`, `ops` (on `logs/beta.log`) and `crew` (on `data/counts.csv`). The odd
entry is `mixed/data/raw-link`, `lrwxrwxrwx`, a symlink.

**37.** It points to `../intake/cycle-41.raw` — **outside** `mixed/`, and owned by root.

**38./39.** Measured after `chgrp -R crew mixed`:

```
crew drwxr-xr-x mixed
crew drwxr-xr-x mixed/data
crew lrwxrwxrwx mixed/data/raw-link
crew drwxr-xr-x mixed/logs
crew -rw-r--r-- mixed/README
crew -rw-r--r-- mixed/data/counts.csv
crew -rw-r--r-- mixed/logs/alpha.log
crew -rw-r--r-- mixed/logs/beta.log
```

and `intake/cycle-41.raw` is still `root root`. The **link** changed; the **target** did not. Most
students predict the opposite, having just learned `chmod`.

**40.**

```
chmod              always follows the symlink. Changes the target. No option to do otherwise.
chgrp (no -R)      follows the symlink. Changes the target.
chgrp -R           does NOT follow. Changes the links themselves, leaves targets alone.
```

`-h` forces the third behaviour for a single named link.

**41.** `chgrp: changing group of 'scratch/L': Operation not permitted`. The permissions consulted
were **root's file's** — `intake/cycle-41.raw` — because a non-recursive `chgrp` dereferences.

**42.** `stat` does not follow symlinks by default, so it reported the link's own owner (`cadet`).
`chgrp` did follow, and asked about the target. Two tools, two defaults, one path — which is the whole
reason this exercise exists. `stat -L` would have shown you what `chgrp` was aiming at.

**43.** `scratch/Lt` becomes group `crew`; `scratch/t` stays `cadet`. `-h` acted on the link itself.

**44.** Only in exercise 43 — and only because `-h` was given. Otherwise the link's own owner and
group were never consulted by anything; `stat` merely *reported* them.

**45.**

```bash
chgrp -R cadet mixed
chgrp ops  mixed/logs/beta.log
chgrp crew mixed/data/counts.csv
```

Note that the first line also sets the symlink's group, which is harmless and which the student
should be able to say is harmless.

---

## umask

**46.** `umask` prints `0022`; `umask -S` prints `u=rwx,g=rx,o=rx`. The symbolic form lists what is
**allowed** for a directory (`0777` minus the mask); the numeric form lists what is **removed**. They
are complements, and the display flips the sense — which is exactly why students misread one of them.

**47.** `scratch/plain` is `644`; `scratch/pdir` is `755`. Same mask, different *requested* mode:
`0666` for files, `0777` for directories.

**48.**

```
file       0666  110 110 110
umask      0022  000 010 010
result     0644  110 100 100

directory  0777  111 111 111
umask      0022  000 010 010
result     0755  111 101 101
```

**49.** Because the request is `0666`, which contains no execute bit in the first place. There is
nothing for the mask to do. An executable file gets its `x` from a later `chmod`, or from a program
that asks for `0777` on purpose (compilers, `install`).

**50.** Measured: `600` and `700`.

**51.** Measured: `664` and `775`.

**52.** Measured: `666` and `777`. It is **all** permissions — the mask removes nothing. This is the
reversal: `umask 000` is the permissive one and `umask 077` is the strict one.

**53.** `0022`. The subshells inherited the mask, changed their own copy, and exited. A child's umask
change is invisible to its parent, like `cd` in a subshell.

**54.** You changed **this shell process's** umask, and therefore the default mode of files created by
this shell and by anything it starts from now on. You changed no existing file and nothing on disk.

**55.** No. `stat -c %a scratch/plain` still prints `644`. The umask is consulted at creation and
never again; it is not recorded anywhere on the file.

**56.** `755`. `-m` supplies the mode explicitly and the umask is not applied to it — the same as
`chmod` after the fact, but without the window in between where the directory exists with the wrong
mode. That window is the reason `-m` exists.

**57.** `644`. The file was created `600` and then explicitly `chmod`ed. The umask applies to
**creation** only; an explicit `chmod` is never masked.

**58.** `0027`, and a file created under it is `640`. Students who predicted `0750` have read the
symbolic form as a mask instead of as a permission set — `umask -S` and `umask` are inverses, and the
symbolic *argument* is also stated as what is allowed.

**59.** (a) `umask 002` — files `664`, directories `775`; the group can edit everything, which is what
was asked, and it depends on the group being right. (b) `umask 077` — files `600`, directories `700`.
Accept `007` for (b) only with an argument about a dedicated group.

**60.** Measured: `c1` is `644 cadet cadet`; `c2` is `644 cadet crew`. `-p` preserves mode,
timestamps and ownership *as far as it is permitted to* — it kept the group `crew`, because you are in
`crew`, and it silently did **not** keep the owner `rhea`, because preserving the owner would be
`chown`, and `chown` is root's. The failure was inevitable and `cp` does not complain about it.

---

## Finding things by owner

**61.** `./intake/cycle-41.raw`.

**62.** `./intake/unclaimed.raw`. `-nouser` tests that **no account maps to the file's uid** — it is a
statement about the account database, not about the file having no owner. Every file has a uid.

**63.** Identical output for both here (`intake/cycle-42.raw`, `mixed/data/counts.csv`,
`notes/*.txt`, `scratch/README`, plus anything you created in `scratch`). Measured: `-group 4102` also works and finds `unclaimed.raw` — GNU `find`
accepts a number for `-group` when the name does not resolve, so the two are equivalent here too.
They diverge only in the pathological case of a group literally *named* with digits, where `-group`
takes the name and `-gid` takes the number.

**64.** `find /labs ! -user cadet 2>/dev/null` — or `-not -user cadet`. The redirect is worth having;
`/labs` contains directories you cannot traverse.

**65.** `stat -c '%u %U %y %n' intake/* | sort -n`

---

## Judgement

**66.** Model reply:

```
intake/unclaimed.raw is owned by uid 4102 and gid 4102, and nothing on the station maps either
number to a name -- getent returns nothing for both. It is 29 bytes, mode 644, last modified
2187-06-18 23:12. That is the whole of what the file supports. I can't tell you whether 4102 was
ever an account, whether it was deleted or never created, or who wrote the file, and I'd rather
not guess.

The handoff group is not a per-file mistake. A new file's group comes from the process that
creates it -- my primary group is cadet, so everything I touch comes out cadet, and chgrp after
the fact only fixes the ones I remember. sg crew confirms it: run the same touch under crew and
the file lands as crew. The fix belongs on the directory, not on the files, and I think it's the
bit we haven't covered yet.
```

Marking: the first paragraph must decline to identify a person; the second must name the mechanism
(process primary group) rather than proposing to `chgrp` more often.

**67.** (1) It fixes files after the fact, so there is always a window in which a file has the wrong
group — and if the window matters at all, it matters most immediately after creation, which is exactly
when the job has not yet run. (2) It is a recurring job papering over a one-line property of the
directory; the first time somebody moves the directory or adds a second one, it is wrong again and
silently. A third, if offered: a blanket `-R` also rewrites files that were deliberately given a
different group.

**68.**

```bash
owned-by() {
  local user=$1 path=${2:-.}
  if ! id -u "$user" >/dev/null 2>&1; then
    echo "owned-by: no such account: $user" >&2
    return 1
  fi
  find "$path" -user "$user" -printf '%m %u %p\n' 2>/dev/null
}
```

`id -u` is the check, because it consults the same database `find -user` will. Testing: `cadet`
returns most of the tree, `root` returns `intake/cycle-41.raw`, `nosuchuser` prints the message and
exits 1 without running `find`.

**69.** The file stores the number `4102` and nothing else. Creating an account that is assigned uid
4102 makes the name lookup succeed, so `ls -l` now prints that account's name where it printed
`4102`, and `find -nouser` no longer matches it. Nothing about the file changed — not one byte, not
the mtime, not the inode. What the new account gained is the **owner's** permissions on that file,
including the right to `chmod` it and to read it whatever the group and other triads say. This is why
uid reuse is a real hazard and why deleting an account without dealing with its files is only half a
deletion.
