# 02/04 — Solutions (agent-eyes-only)

> **Student: do not open this file.** It contains the answers. Reading it removes the only thing the
> exercises are for. The tutor agent may read it to know where it is steering, and must never quote
> it.

Values below were captured from the running image. CPU count, memory, uptime, load and PIDs will
differ on another host — the *shape* of every answer is what is being graded.

---

**1.** `ls /proc`

Two populations: a numbered directory per running process (`1`, `1390`, …) and named system-wide
files and directories (`cpuinfo`, `meminfo`, `uptime`, `mounts`, `self`, `sys`, `net`, …).

**2.**
```
$ cat /proc/version
Linux version 7.0.13-arch1-1 (linux@archlinux) (gcc (GCC) 16.1.1 ...) #1 SMP PREEMPT_DYNAMIC ...
$ cat /proc/uptime
1216.44 26890.11
```
Uptime in seconds is the first number. The second is idle time summed over all CPUs, which is why it
can exceed the first.

**3.** `cat /proc/self/comm` → `cat`. Not `bash`: `cat` is the process doing the reading, and `self`
resolves to the reader.

**4.** 24 CPUs.
- `/proc/cpuinfo` — one `processor :` block per CPU (`grep -c` is Chapter 6; here they count by
  reading, or by `wc -l` on the file and dividing, or just by scrolling to `processor : 23`).
- `/sys/devices/system/cpu/online` → `0-23`. Also acceptable: `possible`, `present`, or counting the
  `cpu0` … `cpu23` directories under `/sys/devices/system/cpu/`.

The trap is answering "0-23". That is a range; the count is 24.

**5.** `head -1 /proc/meminfo` → `MemTotal:  31933460 kB`. Unit is **kB**, stated in the file.
≈ 31.9 GB / 30.5 GiB.

**6.** Any three. Model answer:

| Fact | Path |
|---|---|
| 24 CPUs | `/sys/devices/system/cpu/online` |
| ~30.5 GiB RAM | `/proc/meminfo` |
| Kernel 7.0.13-arch1-1 | `/proc/version` |

The path is the graded half.

**7.** `cat /proc/loadavg` → `2.54 2.31 1.98 1/3932 1414`
1. load average over 1 minute
2. over 5 minutes
3. over 15 minutes
4. runnable-or-running kernel scheduling entities **/** total entities (`1/3932`)
5. the PID of the most recently created process (`1414`)

Fields 4 and 5 are the ones a first guess gets wrong. Documented in `man 5 proc` under
`/proc/loadavg`.

**8.**
```
$ cat /proc/1/cmdline; echo
sleepinfinity
$ cat /proc/1/comm
sleep
```
PID 1 here is `sleep infinity` — the command the container was started with. On the Ubuntu VM PID 1
is an init system (`systemd`) that mounts filesystems, starts services and reaps orphans. A container
is started to run one command, and that command is PID 1; when it exits, the container stops. That
is why the image's entrypoint is a process that does nothing forever.

**9.** `ls /proc/<pid>` for the PID `waiter.sh` printed at startup.

**10.**
```
$ ls -l /proc/1390/cwd /proc/1390/exe
... /proc/1390/cwd -> /labs/02-navigating-the-filesystem/04-proc-and-sys
... /proc/1390/exe -> /usr/bin/bash
```
The surprise: `exe` is **bash**, not `waiter.sh`. A shell script is not something the kernel can
execute. The shebang line tells the kernel to start `bash` and hand it the script as an argument, so
the process's executable image is bash and the script is data. A compiled program would show its own
path here.

(For contrast, `/proc/1/exe` points at
`/nix/store/…-coreutils-full-9.11/bin/coreutils` — `sleep` is a multicall binary in this image, so
even a "real" executable is not at the path you would guess.)

**11.**
```
$ cat /proc/1390/cmdline
bash./waiter.shdeck-3
```
Arguments are stored as a list. The separator is a NUL byte. Most terminals print
nothing for it, so the words run together; a few render it as a space or a `^@`. Any of those is the
right observation — the byte is not a space. A printable separator would be ambiguous, because a filename may legally
contain a space (or a comma, or a newline). `tr` fixes the display; that is Chapter 7 and is not
required here.

**12.**
```
State:   S (sleeping)
PPid:    1384
Threads: 1
```
Sleeping because it is blocked in `sleep 900`. `PPid` is the shell it was launched from.

**13.**
```
$ ls -l /proc/1390/fd
lr-x------ ... 0 -> /dev/pts/0
l-wx------ ... 1 -> /dev/pts/0
l-wx------ ... 2 -> /dev/pts/0
lr-x------ ... 255 -> /labs/.../waiter.sh
```
0 input, 1 output, 2 error — all three attached to the terminal, which is why the script's `echo`
appeared on screen. Note `comm` is mode `-rw-r--r--`: a process may rename itself by writing to it. Size 0 with a
readable, writable file is exercise 17's surprise in miniature.

Descriptor 255 is bash's own handle on the script file; it is not part of the
answer but is worth mentioning if asked.

In a non-interactive run (piped stdin, as under `docker exec -i`) the same descriptors show
`/dev/null` and `pipe:[…]` instead. Both are correct — grade against the student's own transcript.

**14.**
```
$ kill 1390
$ ls /proc/1390
ls: cannot access '/proc/1390': No such file or directory
```
The directory was never stored anywhere. It existed only as long as the object it described.

**15.**
```
$ head -1 /etc/os-release
PRETTY_NAME="Ubuntu 24.04.4 LTS"
$ cat /proc/version
Linux version 7.0.13-arch1-1 (linux@archlinux) ...
```

**16.** `/etc/os-release` is a file placed on disk by the Ubuntu package that built this image — it
describes the **userland**. `/proc/version` is the kernel answering about itself, and a container
does not have a kernel of its own: it is a set of restrictions applied to ordinary processes running
on the one kernel that is booted. That kernel belongs to the Arch Linux host. Both files are telling
the truth about different things.

Second evidence — any of:
- `/proc/cmdline` → `root=UUID=03a6f6d4-… resume=UUID=… initrd=\initramfs-linux.img`. This container
  has no bootloader and no initramfs.
- `/proc/meminfo` / `/proc/cpuinfo` → the whole machine's memory and all 24 CPUs, not a container's
  share.
- `/proc/uptime` → far older than this container.
- `/proc/loadavg` → field 4's total (`3932`) is the whole host's process count; this container has a
  handful.

**17.** Prediction required in writing first.
```
$ ls -l /proc/cpuinfo
-r--r--r-- 1 root root 0 Aug 23 05:26 /proc/cpuinfo
$ wc -l /proc/cpuinfo
672 /proc/cpuinfo
$ ls -l /proc/self/comm
-rw-r--r-- 1 cadet cadet 0 Aug 23 05:56 /proc/self/comm
$ cat /proc/self/comm
cat
$ cat /proc/self/cmdline
cat/proc/self/cmdline
```
`ls -l` performs a `stat`: it asks the filesystem for recorded metadata and never opens the file.
`cat` opens the file and reads. For a file on disk both answers come from the same stored object, so
they agree. In procfs nothing is stored — the text is manufactured by a kernel function at the moment
of the read — so there is no recorded length to report and the size field is 0. Reporting a true size
would mean generating the entire file on every `stat`, which would make `ls /proc` expensive for no
benefit.

The fifth line is unrelated to size: it is the NUL-separated argument list from exercise 11, and here
it happens to show `cat` reading its own command line.

**18.** Prediction required in writing first.
```
$ ls -ld /proc/self
lrwxrwxrwx 1 root root 0 Aug 23 05:57 /proc/self -> 1402
$ ls -ld /proc/self
lrwxrwxrwx 1 root root 0 Aug 23 05:57 /proc/self -> 1403
```
`self` is a magic symlink resolved per-reader: it points at the PID of whoever follows it. Each
command is a new process, so two consecutive `ls` runs are two different processes and get two
different numbers. The numbers usually increase but need not be consecutive — other processes may
have been created in between. If bash reads the file itself (via a redirect, no new process), the
answer is bash's own PID.

**19.** The by-hand scan: `ls /proc`, then read `cmdline` from each numbered directory until one
contains `deck-3`. Narrowing to the largest PIDs first is a legitimate heuristic — a process started
seconds ago has a high PID — and a student who says so has understood something. The count is
typically 5–30 directories in this container.

The point: this is exactly what `grep -r` automates, and the reason it exists is that the manual
version does not scale. On this host `/proc/loadavg` reports 3932 scheduling entities.

**20.** `/proc/cpuinfo`'s recorded size is 0, so a size filter will not report it, even though reading
it produces 672 lines of text. This is correct behaviour, not a bug: a search tool uses `stat` because
it cannot afford to read every file on a filesystem, and it inherits procfs's answer. The practical
lesson — and the reason experienced people exclude `/proc` from whole-filesystem searches — is that
size-based reasoning is meaningless there.

**21.** `/proc/mounts` has 27 lines; `df` reports 5 filesystems. Present only in the mount table:
`proc`, `sysfs`, `cgroup`, `devpts`, `mqueue`, and the `ro` re-mounts of `/proc/bus`, `/proc/fs`,
`/proc/irq`, `/proc/sys`, `/proc/sysrq-trigger`. `df` reports free space, and a pseudo-filesystem has
no capacity to report, so listing it as `0 / 0` would be noise; `df` also collapses duplicate device
entries. Absent from a space report is not the same as contradicted.

**22.**
```
$ echo x > /proc/sys/kernel/hostname
bash: /proc/sys/kernel/hostname: Read-only file system
$ grep "/proc/sys " /proc/mounts
proc /proc/sys proc ro,nosuid,nodev,noexec,relatime 0 0
```
The cause is the **mount option**, not permissions. `Read-only file system` (EROFS) is a property of
the filesystem; a permissions failure would say `Permission denied` (EACCES). `sudo` would not help —
the container runtime deliberately re-mounts `/proc/sys` read-only so a process inside cannot change
the host's kernel settings, since there is only one kernel to change.

Note also that the error is prefixed `bash:` — the shell failed to open the redirect target, so no
program ever ran.

**23.**
```
$ cat /proc/self/limits
...
Max open files            1024                 524288               files
$ help ulimit
$ ulimit -n
1024
$ ulimit -Hn
524288
```
Soft 1024, hard 524288. The soft limit is the one in force; an unprivileged process may raise it up
to the hard limit and may lower the hard limit, but can never raise the hard limit back.

`ulimit` is a bash builtin, and `man ulimit` does **not** document it. In this image it resolves to
`ulimit(3)` — `/usr/share/man/man3/ulimit.3.gz`, a C library function with a completely different
interface, described in its own page as obsolete. A student who follows that page will get the wrong
answer with no warning that they are in the wrong document. `help ulimit` is the correct route — the same lesson as Chapter 0's `help` coverage.

**24.**
```
$ cat /proc/cmdline
root=UUID=03a6f6d4-2086-4feb-9d9a-10341164d21b resume=UUID=08448299-18cd-4fc9-beac-413176299526 rw iommu=pt initrd=\initramfs-linux.img
```
Host-only tokens: `root=UUID=…` (the host's root partition), `resume=UUID=…` (the host's swap
device, for hibernation), `initrd=\initramfs-linux.img` (a bootloader path, with a backslash — this
is a bootloader that reads an EFI partition). None of these can be about the container: the container
has no bootloader, mounts no root device by UUID, and did not exist when this string was written.

Why it matters: the file is world-readable, and anyone who gets a shell in *any* container on this
machine learns the host's disk UUIDs, that it hibernates, and details of its boot layout. It is
reconnaissance handed over for free. This is one of the things a hardened container runtime masks.

---

## Tutor notes

- The single idea worth defending is exercise 17's. Everything else in the lesson is lookup; that one
  is a change in how the student models a filesystem, and it pays off in Chapter 6 and again in
  Chapter 14.
- `/proc/1/exe` pointing at a coreutils multicall binary confuses students who find it. It is real
  and correct: this image's coreutils are built as one binary that behaves differently depending on
  the name it was invoked under.
- Exercise 13's answer legitimately differs between an interactive shell and a piped one. Do not
  correct a student whose transcript shows pipes.
- Nothing in this lesson touches the sabotage arc. It is the last of Chapter 2's teaching lessons
  before `05-tree-and-stat`; keep the tone technical.


---

## Added exercises 25–52

All output below was taken from the running container. Numbers that describe the machine (memory,
CPU count, uptime) are the **host's** and will differ on another box — the shape of the answer is
what matters.

**25.**
```
$ head -1 /proc/stat
cpu  406849 7 45132 17658332 3605776 12499 5594 0 0 0
```
In order: user, nice, system, idle, iowait, irq, softirq, steal, guest, guest_nice. The unit is
**USER_HZ** clock ticks — 100 per second on this kernel — not seconds. `getconf CLK_TCK` reports it.

**26.**
```
$ grep -c '^cpu[0-9]' /proc/stat
24
```
Twenty-four `cpuN` lines plus the aggregate `cpu` line. It matches `nproc` and
`/sys/devices/system/cpu/online`, which reads `0-23`.

**27.**
```
$ wc -l /proc/filesystems
33
```
`nodev` in the first column means the filesystem is not backed by a block device — `proc`, `sysfs`,
`tmpfs`, `cgroup2` and the rest are generated or in memory. Entries with a blank first column
(`ext4`, `xfs`) need something to mount.

**28.**
```
$ cat /proc/self/statm
3653 1232 1001 271 0 735 0
```
size, resident, shared, text, lib (always 0 on modern kernels), data, dt (always 0). The unit is
**pages**, not bytes or kilobytes — multiply by `getconf PAGESIZE` (4096) to get bytes.

**29.**
```
$ ls -l /proc/self/cwd /proc/self/root
/proc/self/cwd  -> /home/cadet
/proc/self/root -> /
```
`cwd` is where the process is standing; `root` is what the process believes `/` to be. They differ
for a process in a chroot or in its own mount namespace, where `root` points at a subdirectory of
the real tree. That is also how you would spot such a process from outside.

**30.**
```
MemTotal:       31932432 kB
MemFree:        11584808 kB
MemAvailable:   15687804 kB
```
`MemFree` is memory nobody is using at all; `MemAvailable` adds the cache and buffers the kernel
would hand back under pressure. Act on `MemAvailable` — a machine with a small `MemFree` and a large
`MemAvailable` is healthy, and treating `MemFree` as "free memory" is the classic beginner's alarm.

**31.**
```
$ cat /proc/uptime
9032.36 176465.89
```
The first is wall-clock seconds since boot; the second is total idle seconds summed **across all
CPUs**. With 24 CPUs there are up to 24 idle-seconds available per elapsed second, so the second
number can be many times the first. 176465 / 9032 ≈ 19.5 of 24 CPUs idle on average.

**32.** Three structural differences:
1. `/proc` is flat at the top — numbered directories plus loose files; `/sys` is a deep tree with
   almost no files at the top level.
2. `/sys` is full of symlinks that cross-link the same object into several trees (`class`, `bus`,
   `devices`); `/proc` barely uses links except inside a process directory.
3. `/sys` files are almost always one value per file; `/proc` files are frequently whole tables
   (`meminfo`, `stat`, `cpuinfo`) that need parsing.

**33.**
```
$ ls -l /sys/class/net
eth0 -> ../../devices/virtual/net/eth0
lo   -> ../../devices/virtual/net/lo
```
`/sys/devices` is the real tree — it mirrors how the hardware actually hangs together. `/sys/class`
is an index into it, grouping by what a thing *is* rather than where it is plugged in.

**34.**
```
$ cat /sys/devices/system/cpu/online
0-23
```
A CPU list: comma-separated ranges, inclusive, with `-` for a run. With CPU 3 offline it would read
`0-2,4-23`. The format appears throughout `/sys` and in `taskset`.

**35.** Any of dozens; `/proc/sys/fs/file-max` (`9223372036854775807`) or a `/sys/class/net/eth0/mtu`
will do. The documentation route is `Documentation/ABI/` in the kernel source, surfaced as
`man 5 sysfs` and `man 5 proc` for the common ones — and for `/proc/sys` specifically, `sysctl -a`
plus `man 5 proc`. The honest answer is that a bare number in `/sys` is not self-describing and you
must look it up.

**36.**
```
$ ls /sys/fs/cgroup | head -5
cgroup.controllers  cgroup.events  cgroup.freeze  cgroup.kill  cgroup.max.depth
```
It describes resource *groups* — how much CPU, memory and I/O a set of processes may use, and which
processes are in the set. It is the mechanism containers are built out of. Chapter 9 goes further.

**37.**
```
$ cat /proc/self/cgroup
0::/
```
The prediction most people write is a long docker path. What you get is `/` — the container has its
own cgroup namespace, so it sees itself at the root of the hierarchy. The answer therefore tells you
about the *container's view*, not the host's; it is evidence of namespacing rather than of layout.

**38.** `/proc/uptime`'s first number changes between two runs — it is generated at read time.
`/proc/version` does not; it is constant for the life of the booted kernel. Both are read the same
way, which is the point: the file interface says nothing about whether the content is static.

**39.**
```
$ wc -c /proc/meminfo
1674 /proc/meminfo
$ ls -l /proc/meminfo
-r--r--r-- 1 root root 0 ... /proc/meminfo
```
`ls` asks `stat`, which reports the *declared* size — zero, because nothing is stored. `wc` reads
until EOF and counts what arrived. In an ordinary filesystem these agree; in procfs the content does
not exist until you ask for it.

**40.**
```
$ cp /proc/cpuinfo ~/cpuinfo.txt
$ ls -l ~/cpuinfo.txt
-r--r--r-- 1 cadet cadet 46052 ... cpuinfo.txt
```
It works, and the copy has a real size — 46052 bytes here, from a file `ls` called zero. `cp` read
the generated content and wrote it into a real file. Note the copy also inherited mode 444.

**41.** No. The copy is an ordinary file and is frozen at the instant it was read. That is the
conclusion: `/proc` files are not files with contents, they are a **read interface to kernel state**,
and copying one converts a live view into a dead snapshot. Useful when you want the snapshot;
misleading when you forget you took one.

**42.**
```
$ realpath /proc/self
/proc/67463
$ realpath /proc/self
/proc/67464
```
`self` resolves to the PID of the process doing the reading, and each `realpath` is a new process
with a new PID. Two runs, two answers, and neither is wrong — the link has no fixed target.

**43.** The size column is meaningless (0) and the times are the moment you looked. The **mode** and
the **owner** are the meaningful ones: they say who is allowed to inspect the process, which is how
`/proc` enforces that you cannot read another user's `environ` or `fd`. Link count is also real for
directories.

**44.**
```
$ grep -E '^(Uid|Gid)' /proc/<pid>/status
Uid:	1005	1005	1005	1005
Gid:	1008	1008	1008	1008
```
Four values each: real, effective, saved-set, filesystem. PID 1 reports the *same* numbers here —
PID 1 is `docker-init` running `sleep infinity`, started as the same unprivileged account you are,
not as uid 0 as init would be on the Ubuntu VM. The exact numbers depend on how the image was
launched; read your own rather than copying these.

**45.** `/proc/<pid>/stat` field 3 is the state character (`S` for a sleeping `sleep`, `R` for
something running) and field 4 is the parent PID; both match `State:` and `PPid:` in `status`. Two
files carry the same facts because `stat` is the old, fixed, whitespace-separated form that tools
parse, and `status` is the human-readable form with labels that can gain fields without breaking
anyone. Parsing `stat` is fragile anyway — the command name in field 2 can contain spaces and
parentheses.

**46.** Two lines to the effect of: every question in this lesson — how much memory, which CPUs,
what is process 4127 doing, what files does it have open — was answered with `cat`, `ls` and a
symlink, using tools written before any of those subsystems existed. Had the kernel exposed each
one through a dedicated system call, every one of those questions would need its own program, and
you could not have answered a new one with tools you already had.

**47.** From the first line of `/proc/self/mountinfo`:
```
- overlay overlay rw,lowerdir=/var/lib/docker/overlay2/l/WSRA7QQ...,upperdir=/var/lib/docker/overlay2/1103b2a.../diff
```
`lowerdir` and `upperdir` are paths on the **host**, inside `/var/lib/docker`. That leaks that this
is Docker, the storage driver in use, and the host's layer identifiers — enough to confirm the
sandbox and to fingerprint the host's configuration. `/proc/mounts` shows the same mount without
those options.

**48.**
```
$ ls -l /proc/config.gz
-r--r--r-- 1 root root 69631 ... /proc/config.gz
```
It is gzip-compressed, so `zcat /proc/config.gz` reads it (`gunzip -c` equally). Note this one *does*
report a size, unlike most of `/proc`. It exists only when the kernel was built with
`CONFIG_IKCONFIG_PROC`.

**49.**
```
$ grep 'Max open files' /proc/self/limits
Max open files            1024                 524288               files
$ cat /proc/sys/fs/file-max
9223372036854775807
```
The limits file is **per process**: this process may hold 1024 descriptors, and may raise that to
524288 itself. `file-max` is the **system-wide** ceiling on open files across every process at once.
One is a quota, the other is a capacity — and here the system-wide one is effectively unlimited.

**50.**
```
$ cat -v /proc/self/environ
HOSTNAME=kestrel^@PWD=/home/cadet^@HOME=/home/cadet^@LANG=C.UTF-8^@...
```
NUL-separated, which is why `cat` alone appears to run it all together — `tr '\0' '\n'` makes it
readable. Reading another user's environment would be a problem because environments routinely carry
tokens, passwords and connection strings passed in at start-up. What stops you is the file's
ownership and mode 400: `/proc/<pid>/environ` is readable only by the process's own user. On this
station PID 1 belongs to the same account you do, so it is readable — that is a property of how the
container was launched, not a general rule.

**51.** They are not. The mechanism is the **PID namespace**: the container gets its own numbering,
starting at 1. Two pieces of evidence from inside:
```
$ readlink /proc/self/ns/pid
pid:[4026533318]              # the host's own shell reports a different inode
$ ls /proc | grep -c '^[0-9]'
13
$ cat /proc/loadavg
2.03 1.59 1.40 6/2104 68222
```
Thirteen visible processes, while `loadavg` — which is not namespaced — reports 2104 running on the
machine. PID 1 being `docker-init` rather than the host's init is the third giveaway.

**52.** Something like:
- Good for: any question about the running kernel or a running process, answered with tools you
  already have and no special privileges.
- Costs: nothing has a size, nothing is stable between reads, and the formats are undocumented
  columns you must look up in `man 5 proc` every time.
- The mistake to avoid: treating a `/proc` read as a fact rather than as an instantaneous sample —
  and, in a container, treating what you see as the whole machine.


## Flags

None. Chapter 2's flag is in `07-incident-02`.
