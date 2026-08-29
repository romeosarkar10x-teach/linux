# 10/08 — Solutions

Instructor copy. Every result measured in the container.

**Flag:** `KESTREL{he_needed_to_read_it}` — in `engineering/archive/cycle-41.hash`, which is
`0600 dorn:dorn`. Registered as `10/08`.

**Stage tokens** (never registered with `kestrel flags`):

1. `STAGE{bits_not_names}` — `audit/stage1.txt`, read with the setuid-root `bin/readas`
2. `STAGE{first_match_wins_even_for_you}` — `audit/stage2.txt`, mode `0004`, read as a user outside `crew`
3. `STAGE{a_group_is_not_a_login}` — `engineering/archive/stage3.txt`, after joining `engineering` and re-logging in
4. The flag itself is stage 4: run the setuid-`dorn` helper on a `dorn:dorn` file

---

## The fourth digit

**1.** `4000` setuid, `2000` setgid, `1000` sticky.

**2.** `bin/readas` (`-rwsr-xr-x`) and `bin/summarise-hash` (`-rwsr-x---`). The letter is **`s`**, in
the owner's execute position.

**3.**

```
4755 bin/readas
4750 bin/summarise-hash
755  bin/whoami-really
644  bin/README
```

Leading digit `4` on both, which is setuid.

**4.** `%a` prints the mode with no leading zeros; a file with no special bits has `0` in the fourth
digit and it is not printed. Use `stat -c %04a` if you want them lined up.

**5.** `4755` = `-rwsr-xr-x`; `2775` = `drwxrwsr-x`; `1777` = `drwxrwxrwt`; `4750` = `-rwsr-x---`.

**6.** `0644` = `-rw-r--r--`. The leading digit is `0`.

**7.** `-rwSr--r--`. Capital `S` means **setuid is set and the owner's execute bit is not**. There is
no execute letter to overwrite, so `ls` shows the capital instead.

**8.** `drw-rw-rwT` — sticky set, other's execute missing.

**9.** The mistake is setting the special bit without the execute bit under it. A setuid file nobody
can execute does nothing; a sticky directory nobody can traverse is unusable. In both cases somebody
typed a four-digit mode and got the three-digit part wrong.

## Real and effective

**10.** `uid=1005(cadet) gid=1008(cadet) groups=1008(cadet),27(sudo),999(plocate),1001(crew)`. No
`euid=` field, because the real and effective uids are the same.

**11.** Works, unremarkably: `notes/setuid.txt` is `0644`.

**12.** `root`, `4755`. Effective uid **0** while it runs; real uid **1005**. The real uid never
changes.

**13.** `cat: audit/stage1.txt: Permission denied`. `-r-------- root root`. You are not root and not
in root's group, so **other** applied, and other is `---`.

**14.** `./bin/readas audit/stage1.txt` → `STAGE{bits_not_names}`.

**15.** The **`readas` process** was root — its effective uid was 0 from the moment it started. That
is the uid the kernel checked at `open()`. Your shell was never root and `sudo` was never involved.

**16.** `uid=1005(cadet) …`, unchanged. The file's owner is *you*, so "run as the owner" is "run as
cadet", which is what would have happened anyway.

**17.** Nothing, directly — but if an attacker can write to a file **you** own that is setuid you,
they get to run code as you, which matters the moment somebody else runs it. The setuid bit is only
as trustworthy as the write permission on the file.

**18.** `-rwxr-xr-x 1 root cadet`. **`chown` clears setuid and setgid.**

**19.** Otherwise: make a program, `chmod 4755` it, then `chown root` it — and you have just installed
a root-privileged program of your own writing. The clearing is what stops "give a file away" from
being "grant the file the recipient's privileges".

**20.** `chown` first, `chmod` second. The other order sets the bit and then `chown` silently removes
it, and the install script reports success.

**21.** `-rwsr-xr-x 1 root`, and `./scratch/s.sh` prints **`1005`**. The kernel ignored setuid because
the file is a `#!` script: the thing actually executed is `/bin/bash`, which is not setuid, and
honouring the bit here would open a race between reading the shebang and opening the script.

**22.** Either a small compiled program that does one fixed thing, or a `sudoers` line naming the
script. On a real station: the `sudoers` line, every time — it is attributable, reviewable, and
revocable, and lesson 07's warning about granting a program that runs other programs applies to it in
a form you can at least read.

## Finding them

**23.** Two files, plus `find: './dropbox': Permission denied` on stderr. No directories: `-4000` is
setuid, and none of the directories here has it.

**24.**

```
-rwsr-xr-x root:root ./bin/readas
-rwsr-x--- dorn:engineering ./bin/summarise-hash
```

**25.** `/` is "**any** of these bits". `/6000` adds the setgid objects — `shared` and `shared/plans`.

**26.** `find . -perm 4750` matches a file whose mode is **exactly** `4750`: setuid, and `rwx r-x ---`
and nothing else. `-perm -4750` would match anything with *at least* those bits, so `4777` would match
too. One result: `./bin/summarise-hash`.

**27.** `-2000`: `shared` and `shared/plans`, setgid directories. `-1000 -type d`: `dropbox`, sticky.

**28.** `dropbox` is `1733` — no **read** for other, and no execute either. Writing into a directory
and listing it are different permissions (lesson 04). `find` needs to read the directory's entries;
it may not.

**29.** The audit:

```
bin/readas          4755 root:root         setuid root. Runs as root for anybody. Not legitimate.
bin/summarise-hash  4750 dorn:engineering  setuid dorn, executable only by engineering. The finding.
shared              2775 root:engineering  setgid dir: new entries get group engineering. Correct.
shared/plans        2775 root:engineering  same, inherited. Correct.
dropbox             1733 root:crew         sticky write-only drop box. Correct.
```

**30.** On this station: `sudo`, `su`, `passwd`, `newgrp`, `gpasswd`, `chfn`, `chsh`, `mount`,
`umount`. `sudo` runs a command as another user after checking a policy; `passwd` changes your
password; `mount` attaches a filesystem.

**31.** `/etc/shadow` is `640 root:shadow`. Changing your own password means writing to a file you
cannot even read, so `passwd` must run as root — and its safety comes entirely from the fact that it
only ever edits *your* line.

**32.** It is the normal state of a working system; several things simply cannot be done any other
way. What makes one a problem is **scope**: whether the program does one fixed narrow thing (`passwd`
edits your own line) or an arbitrary thing on a path you supply (`cat` reads whatever you name).

## The one that is supposed to be there

**33.** `shared` is engineering's collaborative directory. Remove the setgid bit and every file
created there gets its creator's primary group instead of `engineering`, so the second person cannot
write it — silently, and only for files made after the change. That is cass's month.

**34.** `775` — group write — is what lets two people edit each other's files. The `2` is what makes
those files land in the shared group in the first place. You need both; either alone fails.

**35.** For reporting it: a world-readable directory whose contents are group-writable is worth
knowing about. Against: it is exactly the documented shape for group collaboration, it is owned by
`root` so nobody can change its mode by accident, and the alternative is worse. Commit to: **not a
finding.** Note it in the report as "setgid, verified intentional".

**36.** `1733`: sticky; owner `rwx`; group `-wx`; other `-wx`. Anybody may create and enter, nobody
but the owner may list, and the sticky bit restricts deletion.

**37.** Write (`w`) without read (`r`) on the directory: you can add entries, you cannot enumerate
them. It is for a drop box — cass can leave you a file without seeing what else has been left.

**38.** Deleting is a write to the *directory*, and you have that. The sticky bit adds a second check
on top of it: you must also own the file or the directory. You own neither.

**39.** With sticky set, an entry may be removed only by the entry's owner, the directory's owner, or
root — write permission on the directory is necessary and no longer sufficient.

**40.** `/tmp` is `1777`. Without sticky, anybody could delete or replace anybody else's temporary
file — including swapping a file another program is about to reopen for one of their own. Sticky is
what makes a world-writable shared directory survivable.

**41.** A mistake. It is not a finding and it is not broken; removing it converts a safe shared
directory into one where anybody can delete anybody's file.

## The one that is not

**42.** `-rwsr-x--- 1 dorn engineering 39384 May 18 2187 bin/summarise-hash`. Mode `4750`, owner
`dorn`, group `engineering`, mtime **2187-05-18**.

**43.** `bash: ./bin/summarise-hash: Permission denied`. You are neither `dorn` nor in `engineering`,
so **other** applied, and other is `---`. You would have to be dorn or in `engineering` to execute it
at all.

**44.** Only dorn and members of engineering may run it, and whoever runs it, it runs as **dorn**.

**45.** Everything dorn can read — his home directory, his files anywhere on the station, and any file
whose group or other bits admit him. Not root's files: dorn is not root. The scope is one ordinary
account's entire reach, which is a great deal more than one archive.

**46.** `cat: audit/stage2.txt: Permission denied`, mode `-------r--`, owner `cadet:crew`. The kernel
uses the **first matching triad and stops**. You are the owner, the owner triad is `---`, and it never
consults the other triad that would have let you in.

**47.** `sudo -u nobody cat audit/stage2.txt` (or `sudo -u ops-bot`) → `STAGE{first_match_wins_even_for_you}`.

**48.** `sudo -u rhea` fails because rhea is in `crew`, so the **group** triad applies to her, and that
is `---` too. Only an account that is neither the owner nor in `crew` reaches the `r` in the other
triad. Same rule as 46, from the other side: the triad that applies is chosen by identity, not by
generosity.

## Joining a group

**49.** Who: cadet. What: read, no writes. Where: this lab's `engineering/` only. As whom: yourself,
via group membership. How long: today. Why: the audit. You are responsible for the **how long** —
taking yourself back out and telling her.

**50.** `engineering:x:1002:rhea` — you are not in it, `id` agrees, and
`ls: cannot open directory 'engineering/archive': Permission denied`. Consistent.

**51.** After `sudo usermod -aG engineering cadet`, `getent group engineering` shows
`engineering:x:1002:rhea,cadet` and `id` still does not. **`id` is telling the truth about your
running shell**: the group list of a process is fixed when the process is created and inherited from
its parent, and your shell's parent list predates the change.

**52.** Your group memberships are read at login and copied into every process you start; adding you
to a group edits `/etc/group`, not any process that is already running.

**53.** `-G` without `-a` **replaces** the list, so you would keep only `engineering` and lose `sudo`,
`crew` and `plocate`. Losing `sudo` means losing the ability to put it back.

**54.** `newgrp engineering` (or any fresh login). `id` now lists `1002(engineering)`.
`ls engineering/archive` → `README cycle-41.hash stage3.txt`, and `stage3.txt` holds
`STAGE{a_group_is_not_a_login}`.

**55.** `id -gn` → `engineering`. `newgrp` makes the named group your **primary** group for that
shell, so new files get group `engineering` wherever you make them:
`-rw-r--r-- 1 cadet engineering 0 scratch/g`.

**56.** Outside that shell your primary group is `cadet` again, and `shared/mine2` still comes out
`cadet engineering`. **In a setgid directory the new entry takes the directory's group, not the
creator's.**

**57.** With `g-s`, `shared/mine3` is `cadet cadet`. Nothing errors and nothing warns; only files
created after the change are affected, which is why the damage is noticed late.

**58.** New directories inside a setgid directory inherit the setgid bit as well as the group.
Without that, the scheme would work for one level and quietly stop at the first subdirectory anybody
made.

**59.** `-rw------- 1 dorn dorn`. The **owner** triad applies to dorn; you are matched by *other*,
which is `---`. Group membership is irrelevant — the group here is `dorn`, and even if it were
`engineering` the file gives group nothing.

**60.** `./bin/summarise-hash engineering/archive/cycle-41.hash`:

```
cycle-41 raw export, sha256 manifest, taken 2187-05-18.

  9f2c1a  cycle-41-strain.raw
  4be07d  cycle-41-strain.summary

KESTREL{he_needed_to_read_it}
```

**61.** He took a hash of a raw export and of the summary built from it, and recorded that the two do
not describe the same numbers. He says he checked four times and could not read the archive as
himself. The file does not say who clamped anything, why, or on whose instruction, and neither should
the answer.

**62.** `./bin/summarise-hash /home/dorn/.profile` prints it. The flaw: the program takes an arbitrary
path and reads it as dorn, so it is not "a tool that reads one archive" — it is **dorn's read access,
handed to anybody who can execute it**.

**63.** No. `engineering` today is rhea and, for one day, you. Next year it is whoever gets added, and
nobody adding a person to an engineering group is thinking about a binary in a lab directory. A grant
attached to a group outlives every assumption made about the group.

**64.** `sudo chmod u-s bin/summarise-hash` → `-rwxr-x--- 1 dorn engineering`. The helper now runs as
whoever runs it, so `./bin/summarise-hash engineering/archive/cycle-41.hash` gives
`Permission denied`. The file is still there, still readable as evidence, and no longer a privilege.

**65.** For `chmod u-s`: it removes the privilege and preserves the artefact — mode, owner and mtime
are the audit's evidence, and deleting evidence three weeks into somebody's absence is not your call.
For `rm`: a disarmed binary in a bin directory is a thing somebody re-arms with one `chmod`.
Defensible answer: `chmod u-s` now, tell rhea it exists and where, and let her decide about removal.
Whichever you pick, the sentence to rhea is the same: what it was, what it could reach, and what you
changed.

**66.** `sudo gpasswd -d cadet engineering`. Because a grant with an end date that nobody enforces is a
permanent grant. Trust is not the issue: she has to be able to say, later, exactly who was in
`engineering` on which day, and that is only true if people leave when they said they would.

**67.** The request dorn did not send:

```
Who:      dorn
What:     read, no writes -- I need to hash two files and compare them
Where:    the engineering archive, cycle-41 raw export and its summary
As whom:  you, via sudo -u rhea, or by you running the two commands yourself
How long: one run. I do not need standing access.
Why not:  the archive is group engineering and I am not in it. I think the summary
          does not match the raw file it came from and I would like to be wrong.
```

The point being that the last line is the whole reason, and a setuid binary never had to say it to
anybody.

## Debrief

**68.** Model answer: *"`bin/summarise-hash` is a setuid copy of `cat` owned by dorn — it reads any
file you name with dorn's access, not just the archive. I cleared the setuid bit with `chmod u-s` and
left the file otherwise untouched; it is dated 2187-05-18. While I had engineering I read
`archive/README`, `stage3.txt` and `cycle-41.hash`, and nothing else."*

Marking: all three parts, and the third one honest and specific.

**69.** Supported: a setuid binary owned by dorn, executable by `engineering`, last modified
2187-05-18, capable of reading anything dorn could read; and one file recording two hashes that
disagree. Not supported: that dorn built it, that he built it for this, that anybody was hiding
anything, or what the disagreement means. The line to write: *"setuid-dorn helper, mtime 2187-05-18,
grants dorn's read access to any path; disabled."* The line not to write: anything with a motive in
it.

**70.** Something like: *permission is something the nine bits can give you and take away, exemption is
what root has instead — and a setuid binary is a way of lending one specific person's permissions to
everybody who can run it, which is neither, and is why it needs a reason.*
