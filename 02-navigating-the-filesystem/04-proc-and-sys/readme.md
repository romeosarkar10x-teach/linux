# 02/04 — The kernel, as files

> The kernel will tell you what it is doing, in files, if you ask. Nothing under `/proc` is on a
> disk anywhere — which is the most interesting thing you will learn this week.

`/proc` looks like a directory tree. It has files with sizes and permissions and modification
times, and `cat` reads them exactly as it reads anything else. But no part of it is stored
anywhere. Every read is answered by the kernel, on the spot, out of its own live state.

This is a design choice with a name — "everything is a file" — and it is why you already know how
to inspect a running Linux system. You do not need a new tool. You need `cat` and `ls`.

## Two synthetic filesystems

```bash
$ ls /proc | head
1
632
650
acpi
buddyinfo
cmdline
cpuinfo
```

`/proc` is **procfs**: one numbered directory per running process, plus a pile of files describing
the system as a whole. `/sys` is **sysfs**: the kernel's device and driver model, arranged as a
tree of one-value-per-file, nested as deep as the hardware is. Both are mounted at boot and occupy no disk.

The difference in style is worth seeing. `/proc` files are usually human-formatted blocks of
text; `/sys` files usually hold a single value:

```bash
$ cat /proc/uptime
2420635.76 14187970.59
$ cat /sys/devices/system/cpu/online
0-23
$ cat /sys/class/net/lo/mtu
65536
```

## System-wide files worth knowing

| File | Holds |
|---|---|
| `/proc/cpuinfo` | one block per processor: model, flags, speed |
| `/proc/meminfo` | memory totals and breakdown, in kB |
| `/proc/uptime` | seconds since boot, and idle CPU-seconds |
| `/proc/loadavg` | 1/5/15-minute load, running/total processes, last PID |
| `/proc/version` | the kernel's own version string |
| `/proc/mounts` | every mounted filesystem |
| `/proc/cmdline` | the arguments the kernel itself was booted with |

Read them. That is the whole interface.

## One directory per process

Every running process has a directory named for its **process id**:

```bash
$ ls /proc/1
cmdline  comm  cwd  environ  exe  fd  limits  maps  status  ...
```

The useful entries:

| Entry | What it gives you |
|---|---|
| `cmdline` | the full command line, **NUL-separated** |
| `comm` | the short name, one line |
| `cwd` | a symlink to the process's working directory |
| `exe` | a symlink to the executable file it is running |
| `fd/` | a directory of symlinks, one per open file descriptor |
| `status` | a readable summary: state, ids, memory, threads |
| `limits` | resource limits, soft and hard |

And a shortcut that makes all of this usable:

```bash
$ cat /proc/self/comm
cat
```

`/proc/self` is a magic symlink pointing at **the directory of whichever process is reading it**.
So `cat /proc/self/comm` prints `cat`, because `cat` is the process doing the reading. That is not
a trick question — it is the single most useful thing in `/proc`.

> **`cmdline` is NUL-separated, not space-separated.** `cat /proc/1/cmdline` looks like the
> arguments run together, because the separators are invisible. Pipe it through `tr '\0' ' '` to
> read it. You have `tr` from nothing yet — Chapter 7 owns it — so for now just notice the
> squashing and remember why.

## The size-zero surprise

```bash
$ ls -l /proc/cpuinfo
-r--r--r-- 1 root root 0 Aug 23 05:50 /proc/cpuinfo
$ cat /proc/cpuinfo | wc -l
600
```

The file reports **size 0** and produces hundreds of lines. Both facts are true. `ls` asks the
filesystem how big the file is; procfs answers "I don't know, I have not generated it yet",
because the content does not exist until you read it. `cat` reads until end-of-file and gets
everything.

This is worth internalising now, because in Chapter 5 and Chapter 6 you will write things that
select files by size, and `/proc` will lie to all of them.

## The station is not the machine

Two files that should agree, and do not:

```bash
$ cat /etc/os-release | head -1
PRETTY_NAME="Ubuntu 24.04.4 LTS"
$ cat /proc/version
Linux version 7.0.13-arch1-1 ...
```

`/etc` describes the **distribution** — the userland: which programs are installed, how they are
laid out, what the package manager thinks. `/proc/version` describes the **kernel**, and a
container does not have its own. It shares the host's. So a container built from Ubuntu, running
on an Arch Linux host, honestly reports both.

The same logic explains why `/proc/cpuinfo` here lists every processor on the host machine and
`/proc/meminfo` reports the host's total memory. The container is a view, not a machine.

## Writing to `/proc` and `/sys`

Some of these files are writable, and writing to them changes kernel behaviour immediately. That
is how much of system tuning is done. As an unprivileged user in a container you will be refused,
and that refusal is itself the exercise — you are not going to break anything here, and it is
worth seeing what the failure looks like.

## Gotchas

> **Process directories vanish.** `/proc/1234` exists while the process does and not afterwards.
> A listing you take now may name directories that are gone by the time you read them.

> **Some entries are readable only by their owner.** `environ` and `fd/` are `-r--------`. You can
> see the entry and not its contents. That is a permission, and Chapter 10 explains the mode.

## Before you move on

- `/proc` and `/sys` are generated by the kernel on read; nothing is stored on disk.
- One numbered directory per process; `/proc/self` is whichever process is reading.
- `cmdline` is NUL-separated; `comm` is the short name.
- Files in `/proc` report size 0 and still produce output.
- `/etc/os-release` describes the userland, `/proc/version` describes the kernel, and in a
  container they legitimately disagree.
