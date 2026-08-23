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

## Flags

None. Chapter 2's flag is in `07-incident-02`.
