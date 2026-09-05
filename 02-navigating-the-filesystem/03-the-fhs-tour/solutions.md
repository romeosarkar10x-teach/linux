# 02/03 — Solutions

> **Agent eyes only.** Student: `help.md` is your file, not this one.

`$LAB` = `/labs/02-navigating-the-filesystem/03-the-fhs-tour`

---

**1.** `ls -ld /*` → 22 entries, 4 of them symlinks. (`ls /` gives 22 names; `ls -ld /* | grep -c
'^l'` gives 4.)

**2.**
```
/bin   -> usr/bin
/lib   -> usr/lib
/lib64 -> usr/lib64
/sbin  -> usr/sbin
```
All four point into `/usr`, and all four targets are written **relative** (`usr/bin`, not
`/usr/bin`) — relative to `/`, the directory the link lives in. That is usrmerge.

**3.** Any genuine fact from `hier(7)`'s `/var` section. Common finds: `/var/account`,
`/var/crash`, `/var/spool/mail` being the traditional location that `/var/mail` replaced.

**4.** `/boot`, `/media`, `/mnt`, `/srv` are empty.

```bash
ls -A /boot /media /mnt /srv
```
Fastest route is exercise 1's listing followed by `ls -A` on all top-level directories at once and
looking for labels with nothing under them.

The reason is containerisation, not Linux: the container shares the host's kernel so it needs no
`/boot`; it has no removable media, so `/media` and `/mnt` have nothing to mount; and it serves
nothing, so `/srv` is unused. On the Ubuntu VM outside, `/boot` has a kernel and initramfs in it.

**5.** `/etc/os-release` → `PRETTY_NAME="Ubuntu 24.04.4 LTS"`. It lives in `/etc` because it is
**machine-specific**, not because it changes — it is static but not shareable, the bottom-left cell
of the table. Note that `uname -a` reports the *host's* kernel here and is not an answer to the
question asked.

**6.** `/etc/shells`. Two others, any of: `/etc/passwd` (one account per line, colon-separated
fields), `/etc/group`, `/etc/hosts` (one address-to-name mapping per line), `/etc/fstab`,
`/etc/services`.

**7.** `/var/log/dpkg.log`. `/var/log/apt/` is a directory of apt's own logs — a good additional
answer, not a substitute.

**8.**
```bash
type -p ls        # /opt/kestrel/bin/ls
type -p useradd   # /usr/sbin/useradd
```
`useradd` is in `sbin` because it is an administrative command. `ls` is a general command — but on
this station `PATH` finds the Nix copy in `/opt/kestrel/bin` first; `/usr/bin/ls` exists too. A
student who reports both and explains `PATH` order has answered better than the expected answer.

**9.**
```bash
ls -l /opt/kestrel/bin | head
# lrwxrwxrwx ... awk -> /nix/store/ny5hzk...-gawk-5.4.1/bin/awk
```
Every entry is a symlink into `/nix/store`. The hash in the target is the identity of the exact
build; that is what makes the image reproducible.

**10.**
```bash
ls -ld /tmp /var/tmp /var/log
# drwxrwxrwt ... /tmp
# drwxrwxrwt ... /var/tmp
# drwxr-xr-x ... /var/log
```
`/tmp` and `/var/tmp` end in `t` — the **sticky bit**. `/var/log` does not.

Rule: in a directory with the sticky bit set, a user may only delete or rename files they own,
even though the directory itself is writable by everyone. Chapter 10 proves it.

Those two need it because they are the two world-writable shared scratch directories on the
system: without it, any user could delete any other user's temporary files. `/var/log` is
`drwxr-xr-x` — only root writes there, so the problem never arises.

**11.**
```bash
ls /root
# ls: cannot open directory '/root': Permission denied
ls -ld /root
# drwx------ 2 root root ... /root
```
The group and other blocks are `---`: no read, no execute. You need `r` to list the names and `x`
to reach anything inside; you have neither. `/root` is separate from `/home` because `/home` may
be a network mount that is not available early in boot or during recovery, and root has to be able
to log in when it is not.

**12.** Canonical answers:

| file | directory | why |
|---|---|---|
| `hullscan` | `/usr/local/bin` | executable, not from the package manager, everyone runs it |
| `hullscan.conf` | `/etc` | configuration, per-machine, plain text |
| `hullscan.1` | `/usr/local/share/man/man1` | static shareable documentation, section 1 |
| `strain-archive.csv` | `/var/lib` (or `/srv`) | large, changes as the system runs, machine data |
| `scratch-run.tmp` | `/tmp` | temporary, nobody needs it after a reboot |
| `kestrel-ops.pid` | `/run` | runtime state, meaningless after a reboot |

**13.** The two intended forks:

- `hullscan` — `/usr/local/bin` versus `/opt/hullscan/bin`. Decided by whether it is one file or a
  self-contained tree, and whether you want to delete it in one move.
- `strain-archive.csv` — `/var/lib` versus `/srv`. Decided by whether the data belongs to a
  program running here, or is being *served* to other machines.

Also defensible: `scratch-run.tmp` in `/var/tmp` if it must survive a reboot, and the man page under
`/usr/share/man` if you are pretending it came from a package.

**14.** Either conclusion passes; the argument is graded.

*For `/usr/local/bin`:* already on everyone's `PATH`, no configuration needed, the standard
layout for exactly this case, and the package manager will never overwrite it.

*For `/opt/hullscan/bin`:* the whole product is one directory, so removing or versioning it is a
single operation, and its config and data can sit alongside it — at the cost of a `PATH` entry and
of deviating from what other admins expect.

`/usr/bin` is wrong: the distribution owns it and an upgrade may overwrite the file.

**15.** *Experiment.* Observed:

```
ls -ld /bin /usr/bin   -> /bin is a symlink; /usr/bin is a directory
ls /bin | wc -l        -> identical to the next line
ls /usr/bin | wc -l    -> identical to the previous line
realpath /bin          -> /usr/bin
cd /bin && pwd         -> /bin
cd .. && pwd           -> /
```

usrmerge: `/bin` is not a directory with its own contents; it is a second name for `/usr/bin`. The
counts are equal because it is one directory. The last line is `02/01`'s logical-path rule — bash
computes `..` against the path you typed, so you land at `/`, not `/usr`.

**16.** *Experiment.* The intended finding is a negative one.

```bash
df /tmp /var/tmp /run /var/log
```
All four report the **same** filesystem — `overlay`, mounted on `/`. `/run` is *not* a tmpfs on
this station.

So `df` supports none of the four predictions. The reboot semantics (`/tmp` and `/run` cleared,
`/var/tmp` and `/var/log` retained) are real, and are documented in `hier(7)`, but the student has
not measured them and cannot from inside a container that has never rebooted. The deliverable is
that separation: what was observed versus what was read.

A student who reports `/run` as memory-backed here has not read their own output.

**17.**
```bash
ls -ltrd /*
```
Oldest first. The newest entry will be one of `/sys`, `/tmp` or `/labs` depending on the moment —
`/sys` because the kernel synthesises it, `/tmp` and `/labs` because things are being written
there. Any of those with a coherent reason is correct.

**18.**
- `/course` — a purist would say `/opt/kestrel/course` (self-contained third-party product) or
  `/usr/local/share/kestrel`. It is at the root because it is typed constantly and is a distinct
  read-only mount.
- `/labs` — a purist would say `/home/cadet/labs`, or `/srv`, or `/var/lib/kestrel`. It is at the
  root because it is a separate volume with its own lifecycle, and because `kestrel reset` wiping
  a path under `$HOME` is a worse failure mode than wiping a path that obviously is not home.

**19.**
```
/usr/share/man          man pages from Debian packages
/usr/share/doc          per-package prose, changelogs, READMEs
/opt/kestrel/share/man  man pages for the Nix-installed course tools
```
`manpath` prints the first and third (plus `/usr/local/man`, `/usr/local/share/man`, both empty
here).

**20.** *Dig.* Cleanest answer: **`/usr/X11R6`** — documented in `hier(7)`, absent here; it held
the X Window System's binaries, libraries and headers before X moved into `/usr` proper. Other
correct finds: `/usr/dict`, `/usr/doc`, `/usr/etc`, `/var/yp`, `/var/msgs`, `/media/floppy`,
`/lost+found`.

**21.** *Dig.* `file-hierarchy(7)` — systemd's competing description, listed in `hier(7)`'s SEE
ALSO. It is not installed:

```bash
apropos hierarchy
# find (1), fts (3)..., hier (7) -- description of the filesystem hierarchy
# (no file-hierarchy)
man -k file-hierarchy
# nothing appropriate
```
The point of the exercise: `man file-hierarchy` printing "No manual entry" is consistent with a
typo, a wrong section, or an unbuilt index. An `apropos` search that successfully returns `hier(7)`
proves the index works and that the page genuinely is not there.

**22.** *Dig.*
```bash
du -sh /usr/share/doc                     # 4.8M
du -sh /usr/share/doc/* | sort -h | tail -3
# 308K  /usr/share/doc/man-db
# 536K  /usr/share/doc/util-linux
# 552K  /usr/share/doc/manpages
```
`manpages` wins. The trap is sorting `du -h` output with a plain `sort`, which orders `999K` above
`1.2M` because it compares text. `sort -h` understands the suffixes. `du -s` without `-h` and a
plain `sort -n` also works and avoids the trap entirely — a better answer, if they get there.


---

## Added exercises 23–52

All output below was taken from the running container.

**23.**
```
bin -> usr/bin      sbin -> usr/sbin      lib -> usr/lib      lib64 -> usr/lib64
```
This is the **usrmerge**. It replaced a split in which `/bin` and `/lib` held the programs and
libraries needed to boot and mount `/usr`, and `/usr/bin` held everything else — a distinction that
stopped meaning anything once initramfs took over early boot.

**24.**
```
/var/run  -> /run
/var/lock -> /run/lock
```
Both used to be real directories that had to be cleared at every boot. They moved to `/run`, which
is a tmpfs and therefore empty by construction after a reboot; the symlinks are compatibility for
software that still writes the old paths.

**25.** `bin games include lib sbin share src` appear in both (`/usr/local` also has `etc` and `man`).
`/usr/local` is the same shape one level down, reserved for software the local administrator
installs. The package manager owns `/usr` and must never write to `/usr/local`; that separation is
what makes it safe to reinstall a distribution package without losing local work.

**26.**
```
$ ls -ld /usr/local/man
lrwxrwxrwx 1 root root 9 ... /usr/local/man -> share/man
```
A compatibility link. `/usr/local/man` is where pre-FHS software installed its pages, and enough of
it still does that distributions keep the link pointing at the modern `share/man`. Note the target
is relative, so it survives the tree being moved.

**27.** Survive: `backups cache lib local log mail opt spool tmp` (`/var/tmp` survives by
definition — that is what distinguishes it from `/tmp`). Must not: `run` and `lock`, both of which
are links into the tmpfs at `/run`. Unsure is where honest answers go: `cache` survives a reboot but
may be deleted at any time, which is a different property, and a student who says so has understood
`/var/cache` better than one who filed it neatly.

**28.**
- queues: `/var/spool` (`/var/spool/mail`, print jobs, at/cron jobs)
- deletable downloads: `/var/cache` — `/var/cache/apt/archives` specifically
- must not lose: `/var/lib` — package state, databases; deleting it breaks installed software

**29.**
```
$ ls -ld /var/mail
drwxrwsr-x 2 root mail 4096 ... /var/mail
```
Group `mail`, and an `s` where the group execute bit would be. The intent: every file created in
that directory inherits the `mail` group, so the mail delivery programs can all write each other's
mailboxes without being root. Chapter 10 names the bit; here the intent is enough.

**30.**
```
$ type ls
ls is /opt/kestrel/bin/ls
$ ls -l /opt/kestrel/bin/ls
ls -> /nix/store/...-coreutils-full-9.11/bin/ls
$ realpath /opt/kestrel/bin/ls
/nix/store/kl3gf8ld3xp638ss3k178r38qn9ywahn-coreutils-full-9.11/bin/coreutils
```
Two hops, and the second one is the surprise: `ls` in the store is itself a link to `coreutils`, a
single multi-call binary that decides what to do from the name it was invoked under.

**31.** They are all symlinks into `/nix/store`. Sample:
```
awk -> /nix/store/ny5hzk3l36pldfsjkh56ia7y55xr23vd-gawk-5.4.1/bin/awk
```
`/opt/kestrel/bin` is a directory of pointers, not a directory of programs. It is first on `$PATH`,
so it decides which version of every tool the course actually gets.

**32.** `man 7 hier` expects programs to live in `/usr/bin` (distribution) or `/usr/local/bin`
(local); here they live in a content-addressed store and are exposed by a directory of links. The
advantage: the exact version of every tool is pinned in the path itself, so the course's `awk` is
`gawk-5.4.1` on every machine that builds the image, regardless of what Ubuntu ships.

**33.** `/nix` holds one entry, `store`, with 87 package directories in it. It is playing the role of
`/usr` — it is where the installed software lives — with the difference that many versions can
coexist because the version is part of the path.

**34.**
```
$ type -a bash
bash is /usr/bin/bash
bash is /bin/bash
```
Ubuntu's own copy, not a store path — so `bash` is the one tool in the course that comes from the
distribution rather than from `/opt/kestrel/bin`. Evidence: no `/nix/store` in the path, and it is
not listed in `/opt/kestrel/bin`.

**35.** `/usr/bin` is for programs any user runs; `/usr/sbin` is for system administration programs.
The distinction is not enforced here:
```
$ echo $PATH
/opt/kestrel/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
```
`sbin` directories are on the path for an ordinary user, which is now the Debian/Ubuntu default. The
directories still differ in intent; they no longer differ in reachability.

**36.**
```
$ head -3 /etc/os-release
PRETTY_NAME="Ubuntu 24.04.4 LTS"
NAME="Ubuntu"
VERSION_ID="24.04"
$ cat /etc/debian_version
trixie/sid
```
They disagree and both are correct. `debian_version` records the Debian branch this Ubuntu release
was forked from; it is not a claim that you are running Debian. The lesson is to prefer
`/etc/os-release`, which every modern distribution provides and which says what it means.

**37.** 94 entries in `/etc`; eighteen of them end in `.d` (`apparmor.d cron.d init.d ld.so.conf.d
logrotate.d pam.d profile.d rc0.d …` — `ls -d /etc/*.d | wc -l` counts them). Any guess within
twenty is fine; the exercise is calibration, not the number.

**38.** The theory to reach: a `foo.d` directory holds fragments that are read *as if* concatenated
into `foo`, so that packages can drop a file in rather than edit a shared one. Check it against
`/etc/profile.d` — every `.sh` in there is sourced by `/etc/profile`, which you can read. This is the
single most useful pattern in `/etc`.

**39.** No ordinary files to speak of:
```
$ ls -l /dev | head
crw-rw-rw- 1 root root 1, 3 ... null
crw-rw-rw- 1 root root 1, 5 ... zero
brw-rw---- ...              (block devices, if any)
drwxrwxrwt ...              shm
lrwxrwxrwx ...              stdin -> /proc/self/fd/0
```
First characters: `c` character device, `b` block device, `d` directory, `l` symlink, `p` FIFO. The
size columns are replaced by a major and minor number for devices — a device has no size.

**40.**
```
$ stat -f -c %T /tmp /usr /var
overlayfs
overlayfs
overlayfs
```
All three are the container's overlay. For contrast, `/proc` reports `proc` and `/sys` reports
`sysfs`, which is 02/04's subject.

**41.** On a real machine `/tmp` is often tmpfs and `/var` is often a separate partition; here every
FHS directory is one overlay, so nothing about durability or free space can be established from
inside. Exercise 16's `df` evidence is the one that would change: on real hardware `df` would show
different filesystems for `/tmp`, `/run` and `/var/log`, and the prediction would be checkable.

**42.** Every directory entry is 4096 bytes except `/proc` and `/sys`, which report 0, so the
"ranking" is nearly flat. The size of a directory is the size of its own list of names — not of
anything under it. `du -sh` answers the real question, and gives a wildly different order.

**43.** With `/usr/bin` as the target, nothing breaks on a running system but the link stops working
the moment the tree is mounted somewhere else — in a chroot, an installer, or a rescue mount, where
`/usr/bin` means the *host's*. With `../usr/bin` it would also work today, because `/..` is `/`, but
it says something less precise: `usr/bin` is anchored in the directory the link lives in, which is
exactly the guarantee you want.

**44.** Something like:
- If it is a setting a human edits and the machine reads at start-up, it goes in `/etc`.
- If the machine writes it while running and it varies over time, it goes in `/var`.
- If it is installed, read-only in normal operation, and would be identical on every station, it
  goes in `/usr` — `/usr/local` when it did not come from the package manager.

**45.** The rule gives: `hullscan` → `/usr/local/bin`; `hullscan.conf` → `/etc`; `hullscan.1` →
`/usr/local/share/man/man1`; `strain-archive.csv` → `/var/lib` (machine-written, grows over time);
`scratch-run.tmp` → `/tmp`; `kestrel-ops.pid` → `/run`. If exercise 12 put the archive in `/usr` or
the pid file in `/var/run` spelled that way, this is where it gets fixed — `/var/run` is a link to
`/run` and new software should write the real path.

**46.** `/usr/games` is empty because no games package is installed and an image built for a course
never will be. `/usr/src` is empty because kernel headers and sources are not shipped in a container
image — the container uses the host's kernel, so there is nothing to build against and nothing to
build. Both directories survive because `base-files` creates them, not because anything uses them.

**47.**
```
$ du -sh /usr/share/man
12M     /usr/share/man
$ ls /usr/share/man | wc -l
32
```
32 entries, of which the `manN` directories are the English pages and the rest — `de fr ja zh_CN` and
so on — are translations. Removing all but one language reclaims a few megabytes at most. An image
builder might not bother because the saving is small next to the image, and because the removal has
to be repeated and maintained; `dpkg` path-exclusion is the real answer if it matters.

**48.**
```
$ manpath
/opt/kestrel/share/man:/usr/local/man:/usr/local/share/man:/usr/share/man
```
Four trees, and the first covers `/opt/kestrel` — the station's own tools are documented and `man`
finds them first, in the same order `$PATH` uses.

**49.** Same filesystem:
```
$ stat -c '%d %n' /root /home/cadet
51 /root
51 /home/cadet
```
`%d` is the device number the file lives on; equal numbers mean one filesystem. This answers the
question without needing to read either directory, which matters because `/root` is mode 700.

**50.** A `0` size means the file has no stored content: `/proc` and `/sys` are generated on demand
by the kernel, and the size field is not filled in because nothing knows the length until you read
it. `du` on them would be meaningless — it would report near zero for files that produce kilobytes
when read, and it would take a long time doing it.

**51.** Oldest: the usrmerge symlinks and `/boot`, `/usr/games`, `/usr/src` at `Apr 22 2024` — the
date of the Ubuntu base image layer. Newest: `/tmp` and `/proc`, which change while you are logged
in, and `/labs`, which changed when the lesson was seeded. The 2024 dates are the image build; the
today dates are your own session. Nothing in between is station history — the station is fiction and
the filesystem is honest about it.

**52.** Something to the effect of: the FHS answers "where does this file go, and where do I look for
it" so that two people who have never met can find each other's work. The rule that covers most
cases is the three-way split — editable settings in `/etc`, machine-written state in `/var`,
installed read-only material in `/usr`. The caveat: real systems diverge constantly, `/opt` and
`/usr/local` exist precisely because the standard could not decide, and this station's own
`/nix/store` follows none of it — so read the standard as a strong convention, not as a law.

---

## No flag in this lesson

Chapter 2's only flag is in `07-incident-02`.
