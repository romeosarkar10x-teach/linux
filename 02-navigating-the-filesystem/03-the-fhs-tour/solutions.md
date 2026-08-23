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

## No flag in this lesson

Chapter 2's only flag is in `07-incident-02`.
