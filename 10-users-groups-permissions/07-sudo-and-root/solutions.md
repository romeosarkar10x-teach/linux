# 10/07 — Solutions

Instructor copy. Every result below was measured in the container.

---

## What root is

**1.** `id` → `uid=1005(cadet) gid=1008(cadet) groups=1008(cadet),27(sudo),999(plocate),1001(crew)`.
`sudo id` → `uid=0(root) gid=0(root) groups=0(root)`. Not just a different uid: a different gid and a
**shorter** group list.

**2.** It does not need to be in the group. The kernel skips the owner/group/other comparison entirely
for uid 0, so group membership is irrelevant to root — which is why root's group list is short and
still sufficient.

**3.** "Has every permission" implies root passes the check; "exempt" means the check does not happen.
They predict the same outcome for reads and writes, and they differ in *how*, which shows up
immediately: an exempt root needs no group, appears in no ACL, and cannot be excluded by any mode. A
root that merely "had every permission" would still be something you could reason about with the nine
bits, and you cannot.

**4.** `cat scratch/z` → `cat: scratch/z: Permission denied`. `sudo cat scratch/z` → `secret`.

**5.** `whoami` → `cadet`; `sudo whoami` → `root`; `sudo -u rhea whoami` → `rhea`. `whoami` reports
the **effective uid** of the process it runs in, resolved to a name. It is not reporting who logged
in — `logname` or `$SUDO_USER` do that.

**6.** `id -u` — if it prints `0` you are root, whatever the account is called. On a machine where the
account had been renamed to `admin`, `id -u` would still print `0` and `whoami` would print `admin`.
Scripts should test the number.

**7.** Yes, identical: `root:x:0:0:root:/root:/bin/bash`. `getent passwd` accepts a name or a number
and there is one entry behind both.

**8.** `su: Authentication failure` after prompting for a password. `notes/root.txt`: root has no
password set on this station, so nothing you type can match. That is **not** a misconfiguration — it
is the modern default. Administration goes through `sudo`, which is attributable; a shared root
password is not.

**9.** From this chapter: `chown` a file to another user (lesson 06), and read a file whose mode
denies it (exercise 4 above). Also acceptable: kill any process regardless of owner (chapter 9).

---

## sudo as a program

**10.** `-rwsr-xr-x`. An **`s`** where the owner's `x` would be.

**11.** `root` owns it. A setuid-root program runs with root's privileges no matter who starts it, so
`sudo` is root from its first instruction — before it has decided whether you were entitled to ask.

**12.** `4755`. The leading `4` is the setuid bit; lesson 08.

**13.** The **policy**. `sudo` starts as root, then reads `/etc/sudoers` and `/etc/sudoers.d/*` and
refuses if the invoking account is not granted the command. The privilege is unconditional; the
authorisation is not. Naming the file is not naming the mechanism — the mechanism is that a program
which is already root chooses to check.

**14.** Measured on this station:

```
User cadet may run the following commands on kestrel:
    (ALL : ALL) ALL
    (ALL) NOPASSWD: ALL
```

The first comes from `%sudo` in `/etc/sudoers` (cadet is in group `sudo`); the second from
`/etc/sudoers.d/90-cadet`, which adds `NOPASSWD`. Together: anything, as anyone, without a password.

**15.** `env_reset` and `secure_path`. (`mail_badpass` and `use_pty` are also listed and change other
things.)

**16.** It does not tell you whether the command is *safe*, and it does not tell you what the command
will do with the arguments you give it — the policy matches a command line, not an effect. It also
does not tell you whether the grant is still needed, or who granted it.

**17.** `sudo: a password is required` (preceded by `a terminal is required to read the password`).
`-v` explicitly refreshes the authentication timestamp, which means it asks to authenticate; a
`NOPASSWD` rule says a password is not required *to run commands*, not that authentication is
impossible. There is nothing to run, so there is nothing for the rule to exempt.

---

## The environment

**18.** `echo $FOO` prints `bar`; `sudo printenv FOO` prints nothing and exits 1. The behaviour is
`env_reset`.

**19.** Survivors include `TERM`, `PATH` (replaced, not preserved), `HOME=/root`, `USER=root`,
`LOGNAME=root`, and the four sudo adds:

```
SUDO_COMMAND=/opt/kestrel/bin/env
SUDO_GID=1008
SUDO_UID=1005
SUDO_USER=cadet
```

`SUDO_USER` is how a root-run script can find out who actually invoked it.

**20.** `printenv HOME` → `/home/cadet`; `sudo printenv HOME` → `/root`. It breaks anything that writes
into `~` — `sudo somebuild` leaving root-owned files in `/root/.cache` is the classic, and worse,
`sudo` a tool that writes a config to `~` and then wondering why your own copy did not change.

**21.** `id` prints `HIJACKED`. `sudo id` prints `uid=0(root) gid=0(root) groups=0(root)` — the real
one.

**22.** Your shell searched *your* `PATH` and found the fake first. `sudo` replaced `PATH` with
`secure_path` from the policy, so it searched a fixed list of system directories and never saw
`scratch/bin`. The attack is exactly the one you just performed: put a fake `id`, `ls` or `service`
early in a victim's `PATH` and wait for them to type `sudo`.

**23.** Measured: `secure_path=/opt/kestrel/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin`.
Conspicuously absent: anything under a user's home, and `.`.

**24.** Housekeeping. `hash -r` matters because bash caches the resolved path of a command it has run.

**25.** `-E` preserves your environment. A policy forbids it because every reason for `env_reset`
applies with more force when the command runs as root — `LD_PRELOAD`, `PYTHONPATH`, `IFS`, `PATH`
itself. `-E` is refused outright by many policies, and where it is allowed it should be for a named
variable, not wholesale.

---

## What sudo cannot do

**26.** `bash: /etc/zz-test: Permission denied`, exit 1. The process denied was **your shell**, which
opened the file for writing before `sudo` was executed at all. `sudo` never ran.

**27.** `echo hi | sudo tee /etc/zz-test > /dev/null` — creates it `root root`. Then
`sudo rm -f /etc/zz-test`.

**28.** `sudo sh -c 'echo hi > /etc/zz-test'`. The difference: `tee` hands root a single program with
a fixed job and passes the data on stdin; `sh -c` hands root **a shell**, which will interpret
whatever is inside the quotes — including anything a variable expands to.

**29.** `tee`. In somebody else's script the `sh -c` form is a place where an unquoted variable turns
into arbitrary root code, and it is very hard to review at a glance.

**30.**

```
sudo: cd: command not found
sudo: "cd" is a shell built-in command, it cannot be run directly.
```

`sudo` executes a program. `cd` is not one — it changes the calling shell's own state, which is why it
cannot be a separate program (chapter 9, exercise on `type`).

**31.** `sudo -s` → `pwd` is `/labs/10-users-groups-permissions/07-sudo-and-root`, your current
directory. `sudo -i` → `pwd` is `/root`. `-i` simulates an initial login: root's shell, root's home,
root's login files. `-s` runs a shell as root but starts where you were.

**32.** Measured: **both** print `/root`, because this policy sets `HOME` for the target user
regardless. The difference shows in `pwd` (above) and in which startup files are read: `-i` is a
**login shell**, so it reads root's profile and gets root's login environment; `-s` is not.

**33.** `printf '%s\n' "$line" | sudo tee -a /path/to/file > /dev/null`. Rejected: `sudo echo >> f`
(the redirect is yours and it will fail); `sudo sh -c "echo $line >> f"` (the variable is expanded
into a root shell, which is an injection waiting for a filename with a `;` in it).

---

## sudo -u

**34.** `uid=1001(rhea) gid=1004(rhea) groups=1004(rhea),1001(crew),1002(engineering)`. She has
**engineering**; you do not. You have `sudo` and `plocate`; she does not.

**35.** `sudo -u rhea pwd` prints the directory you were already in. `sudo -u rhea` runs a command as
her, and a command inherits its parent's working directory — it is not a login. `-i` would put you in
her home.

**36.** Argue for `sudo -u rhea cat`. It uses the *least* privilege that answers the question: rhea's
access is exactly the access being tested, and if it fails, the failure is informative. `sudo cat`
succeeds unconditionally and tells you nothing about whether the intended reader can read it.

**37.** `sudo -u rhea` records "cadet ran cat as rhea", which names the delegation. It is also far
easier to write narrowly in a policy — `cadet ALL=(rhea) /usr/bin/cat /path` is a grant somebody can
read and revoke, whereas the equivalent as root is a grant of root.

**38.** Measured: it **fails** — `touch: cannot touch 'scratch/hers': Permission denied`. `scratch` is
`cadet:crew 755`; rhea is in `crew`, so the group triad applies and it is `r-x`. The missing bit is
group **write** on the directory.

**39.** `chmod g+w scratch`, then `sudo -u rhea touch scratch/hers` gives `-rw-rw-r-- rhea rhea` (664,
because rhea's umask is `002`). You can `rm` it without `sudo`: deleting is a write to the directory,
which you own and can write. Put `scratch` back with `chmod 755 scratch`.

**40.** Anything only uid 0 may do: `chown` across accounts, reading a file no account is meant to
read (`/etc/shadow`), killing another user's process, mounting. Running as some other ordinary user
cannot get you there, and pretending otherwise wastes a round trip.

---

## Reading a policy

**41.** `root ALL=(ALL:ALL) ALL` — user `root`, on all hosts, may run as any user and any group, all
commands. `%sudo ALL=(ALL:ALL) ALL` — every member of group `sudo`, same terms.

**42.** `%` marks a **group** rather than a user.

**43.** `cass kestrel=(root) NOPASSWD: /usr/bin/systemctl restart hydroponics` — cass, on the host
`kestrel` only, may run exactly that command as root, without a password.

**44.** `dorn kestrel=(rhea) /opt/kestrel/bin/summarise` — dorn may run one program **as rhea**, with a
password. That is the right shape when what is needed is somebody else's *data access*, not
administrative power: it grants rhea's reach over rhea's files and nothing else, and it is legible in
one line six months later.

**45.** Because one `sudoers` file is often distributed to many machines. The host field lets the same
policy grant differently per host, and a grant that names a host cannot silently follow the file onto
another one.

**46.** `use_pty` runs the command on a pseudo-terminal of its own, so it cannot push characters back
into your terminal's input buffer after it exits — an old trick for making the next thing you "type"
be something you did not type.

**47.** `find` has `-exec`, which runs any command you name on the files it finds. `sudo find / -name
x -exec /bin/sh \;` is a root shell. The grant said "find"; the effect is "anything".

**48.** `vi`/`vim` (`:!cmd`, `:shell`), `less` and `more` (`!cmd`), `awk` (`system()`),
`env`, `perl`, `python`, `tar` (`--to-command`), `git` (`-c core.pager=`). The general rule: if it can
run another program, granting it grants that program.

---

## Four grants

**49.** The **arguments**. `tail -f /var/log/exporter.log` in a policy matches that command line, but
policies match the command and any arguments the rule does not pin — and in the common misreading,
the grantee supplies their own.

**50.** `sudo tail -f /etc/shadow`, or `sudo tail -n 99999 /etc/sudoers`. The grant was meant to be
"watch one log"; what it gives is "read any file on the station", because `tail` reads whatever it is
pointed at and it is running as root.

**51.** `vi` can run shell commands, so granting `sudo vi` is granting a root shell.

**52.** Grant C is good because: (a) the command is **fixed and complete** — the verb and its object
are both in the rule, nothing is left for the caller to supply; (b) the effect is **bounded** —
restarting one service cannot read a file or change a mode; (c) it is **specific to a host**. The
`NOPASSWD` is defensible precisely because the command is exact.

**53.** `ls /opt/kestrel/bin | wc -l` → **215** entries on this station. The star covers all of them,
which includes `env`, `awk`, `find`, `perl`, `less` and `bash` — so the grant is root, spelled at
length. You would need to enumerate the directory and check for anything that can execute another
program, and you would also need to know who can *write* to that directory, because a grant on a
glob is a grant on whatever lands there tomorrow.

**54.** C (fixed command, bounded effect) → A (fixed path, unpinned arguments: read anything) → D
(215 programs, several of which are shells, plus whatever is added later) → B (a shell, immediately
and unambiguously). Accept A and D swapped with an argument about what is in `/opt/kestrel/bin`; B
must be last and C must be first.

**55.** Grant a wrapper instead:

```
haldane kestrel=(root) NOPASSWD: /opt/station/bin/watch-exporter-log
```

where the wrapper takes **no arguments**, refuses to run if given any, hardcodes the path, and execs
`tail -f` on it. It must not accept a filename, must not accept flags, and must not pass `"$@"` to
anything.

**56.** Nothing. The notes are unattributed and the policy file records who is granted, not who wrote
the line. You can say the grant is wide and that whoever wrote it used a glob; you cannot say who, and
"somebody in a hurry" is the note's own characterisation, not evidence.

---

## One line needs root

**57.** `head -1 /etc/shadow`. You know before running it because `/etc/shadow` is `640 root:shadow`
(lesson 03) and you are not in `shadow`. The other four lines read `/etc/passwd`, the clock, and
`uptime`, all world-readable.

**58.** `head: cannot open '/etc/shadow' for reading: Permission denied`, and the script exits **1**
because of `set -euo pipefail`.

**59.** All five lines now run as root — including the redirection into `$out`, so the output file is
now **owned by root**, wherever the caller pointed it. The script also inherits root's `HOME` and
`PATH`.

**60.** `sudo whole-script.sh` grants root to every line of a script in order to satisfy one, and to
every line somebody adds to it later.

**61.**

```bash
#!/usr/bin/env bash
set -euo pipefail
out=${1:-/tmp/counts-summary.txt}
{
  echo "run at $(date -Is)"
  echo "uptime: $(uptime)"
  wc -l < /etc/passwd
  sudo head -1 /etc/shadow
  echo "done"
} > "$out"
```

Run as yourself: the file is yours, and only the one line is privileged.

**62.** Worse: the script now requires an interactive-capable `sudo` and will hang or fail in an
unattended context, and it hides a privileged operation inside something that looks unprivileged.
Better: the privilege is scoped to one line, the output file belongs to the caller, and the policy can
grant exactly `head -1 /etc/shadow` instead of "a shell script".

**63.** With `TARGET` empty, `rm -rf "${TARGET}"/*` expands to `rm -rf /*`. The character doing the
damage is the **`/`** after the closing brace — it is outside the quotes and outside the variable, so
an empty variable leaves an absolute path. Quoting the variable, which the author did, does not help
at all.

**64.**

```bash
: "${TARGET:?TARGET must be set to a non-empty path}"
case $TARGET in
  ''|/|/*/..*) echo "refusing: $TARGET" >&2; exit 1 ;;
esac
```

`set -u` alone is not enough because `TARGET` is *set* — the script assigns `TARGET="${TARGET:-}"`,
so it is set and empty, and `set -u` only fires on unset. `${VAR:?}` fires on empty as well as unset,
which is the distinction.

---

## Writing the request

**65.** Who (which account), what (the exact operation), where (the exact path), as whom (root or a
service account), how long, and why the ordinary route does not work.

**66.** Literally, draft 1 asks somebody to decide, on the student's behalf, which of several possible
grants to make — a group membership, a `sudo -u`, or root — over an unspecified set of paths, for an
unspecified time. It is a request for a *decision*, dressed as a request for access, and the person
who grants it carries the whole risk of having guessed.

**67.** Model draft:

```
Who:      cadet
What:     read, no writes
Where:    /srv/engineering/archive/cycle-41/  (that directory only, not the tree above it)
As whom:  rhea, via sudo -u -- I do not need root and would rather not have it
How long: one shift, 2187-06-21. Please revoke after.
Why not:  the directory is group engineering and I am not in engineering. I checked with
          namei -l and the block is on the directory's group triad, not on the files. I am
          checking whether cycle 41's raw counts match what was exported; if you would rather
          run the comparison yourself I will send you the two commands instead.
```

Marking: six headings, a real path, a stated duration, and a "why not" that describes what was tried.
The last two lines — offering the alternative — are what turn a request into something granting.

**68.** `sudo -u rhea` is clearly right: the access needed *is* rhea's access, it is temporary, and it
is one line in a policy to add and one to remove. A group membership is defensible if the need is
ongoing, but it is permanent by default, survives being forgotten, and applies to every
`engineering` path rather than one. Root is defensible only as "the station is small and rhea trusts
you", which is exactly the reasoning her reply rejects.

**69.** Her reason is **accountability**, not risk: she has to be able to state later exactly what was
granted, to whom, and for how long. That is why a vague request cannot be granted even when the person
asking is trustworthy — trust does not produce a record. The implication for verbal grants is that
they are indistinguishable, six months on, from grants nobody made: they cannot be enumerated,
reviewed, or revoked, and the person who gave one has no way to prove its scope. A grant that is not
written down is not a grant, it is a habit.
