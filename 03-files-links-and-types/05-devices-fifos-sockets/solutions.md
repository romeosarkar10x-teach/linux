# 03/05 — Solutions: Devices, FIFOs & Sockets

**Instructor copy. Do not show the student.** Outputs below were captured from the seeded container
as `cadet`. Inode numbers, PIDs, `/dev/pts/N` and any timing-dependent result will differ per build;
everything else is stable.

Two notes before the answers:

- Several of these block. Where a solution says "hangs", that is the correct observed result and the
  student is expected to `Ctrl-C`.
- The container's device cgroup policy refuses `open()` on `zoo/dev-sensor` regardless of mode bits
  and regardless of `root`. That is deliberate (exercise 30) and it also quietly limits exercise 51 —
  see the note there.

---

## Warmup

**1.**

```
$ ls -lF zoo
total 4
lrwxrwxrwx 1 cadet crew          12 ... alias@ -> manifest.txt
drwxr-xr-x 2 cadet crew        4096 ... bay/
brw-rw---- 1 cadet crew       7, 200 ... dev-sensor
-rw-r--r-- 1 cadet crew          47 ... manifest.txt
crw-r--r-- 1 cadet crew       1,   3 ... null-clone
prw-r--r-- 1 cadet crew           0 ... relay|
srwxr-xr-x 1 cadet crew           0 ... telemetry.sock=
```

`l` symlink, `d` directory, `b` block device, `-` regular file, `c` character device, `p` FIFO,
`s` socket.

**2.** `bay/`, `alias@`, `relay|`, `telemetry.sock=`. No suffix: `manifest.txt`, `null-clone`,
`dev-sensor`. `-F` marks neither device type — it cannot distinguish a device node from a regular
file.

**3.**

```
zoo/alias symbolic link
zoo/bay directory
zoo/dev-sensor block special file
zoo/manifest.txt regular file
zoo/null-clone character special file
zoo/relay fifo
zoo/telemetry.sock socket
```

Differences worth naming: `stat` says "special file" where `ls` gives one letter, and says `fifo`
where most prose says "named pipe".

**4.** `null-clone` shows `1,   3` and `dev-sensor` shows `7, 200`. Major and minor, not a byte
count — a device node has no data blocks, so there is no size to print.

---

## Core

**5.**

```
$ file zoo/*
zoo/alias:          symbolic link to manifest.txt
zoo/bay:            directory
zoo/dev-sensor:     block special (7/200)
zoo/manifest.txt:   ASCII text
zoo/null-clone:     character special (1/3)
zoo/relay:          fifo (named pipe)
zoo/telemetry.sock: socket
```

It read contents only for `manifest.txt`. The rest it identified from `stat` alone. Corroborating
evidence: had `file` opened the FIFO to read it, it would have blocked — it did not.

**6.**

```
$ stat -c '%F major=%t minor=%T' zoo/null-clone
character special file major=1 minor=3
$ stat -c '%F major=%t minor=%T' zoo/dev-sensor
block special file major=7 minor=c8
```

`ls -l` prints `7, 200`. `%t`/`%T` are **hex**; `printf '%d\n' 0xc8` → `200`. Same numbers, different
base. `null-clone` is the trap: 1 and 3 look identical in both bases, so a student who checks only
that one concludes there is no disagreement.

**7.** Both are character devices, major 1, minor 3. `zoo/null-clone` is not a copy of and not a link
to `/dev/null` — it *is* `/dev/null`, a second name for the same driver entry point. Deleting
`/dev/null` would not affect it.

**8.**

```
$ echo 'anything at all' > zoo/null-clone ; echo $?
0
$ cat zoo/null-clone
$ stat -c %s zoo/null-clone
0
```

Consistent with exercise 7's claim; does not prove it. An empty regular file, `/dev/full` (for the
read half), or several other devices would look similar under this test. The comparison in exercise 7
is what settles it, and it involves no writing.

**9.**

```
-type p  ./zoo/relay  ./pipe/inbox  ./salvage/feed/strain-input
-type s  ./zoo/telemetry.sock
-type c  ./zoo/null-clone
-type b  ./zoo/dev-sensor
```

Directories holding special files: `zoo`, `pipe`, `salvage/feed`. The third one is the point of
running `find` over the whole lab.

**10.** The second count includes every special file *and* the symlink — `! -type f` does not exclude
`l`. `zoo/alias` is in that set.

**11.** `wc -c < /dev/null` → `0`. The read returns EOF immediately; there is no content to be empty.

**12.** `00 00 00 00 00 00 00 00`. The bytes are NUL, which a terminal does not render — without `od`
the output is indistinguishable from `/dev/null`'s nothing.

**13.**

```
$ echo hello > /dev/full
bash: /dev/full: write error: No space left on device
$ echo $?
1
$ head -c 4 /dev/full | od -An -tx1
 00 00 00 00
```

Reads succeed and behave like `/dev/zero`. Only writes fail, always, with `ENOSPC`.

**14.** A reliable way to test that a program handles a failed write / full disk, without filling a
real disk.

**15.** `/dev/urandom` differs between runs; `/dev/zero` is byte-identical. `null`, `zero`, `full`,
`random`, `urandom` all share major 1 — one driver, differing only by minor in what it hands back.

**16.**

```
crw-rw-rw- 1 root root 1,   3 /dev/null
crw-rw-rw- 1 root root 1,   5 /dev/zero
crw-rw-rw- 1 root root 1,   7 /dev/full
crw-rw-rw- 1 root root 1,   8 /dev/random
crw-rw-rw- 1 root root 1,   9 /dev/urandom
crw-rw-rw- 1 root root 5,   0 /dev/tty
```

Five share major 1. `/dev/tty` is major 5 — a different driver, consistent with it doing something
categorically different: it resolves per process to that process's controlling terminal rather than
being a byte source.

**17.**

```
$ mkfifo pipe/panel07 && ls -lF pipe/panel07
prw-r--r-- 1 cadet crew 0 ... pipe/panel07|
```

`p`, suffix `|`, size 0, mode 644 (666 masked by umask 022).

**18.** Terminal A's `cat` prints nothing and does not return — it is blocked inside `open(2)`, before
it has attempted a single read. The instant B's `echo` runs, A prints `panel 07 clear` and exits, and
B returns at the same moment.

**19.** Reversed: B's `echo` is the one that blocks, in `open()` for writing. A's `cat` releases it;
the line appears in A and both commands return. The rule is symmetric — whichever end opens first
waits for the other.

**20.**

```
$ stat -c '%s %b' pipe/panel07
0 0
$ du -h pipe/panel07
0	pipe/panel07
```

Zero bytes stored, and `%b` = 0 blocks says the inode has no data blocks at all. In-flight bytes live
in a kernel buffer attached to the open FIFO, never in the filesystem.

**21.** The reader gets `one` and exits. The second `echo` then has no reader and blocks. The reader
exited because the last writer closed the FIFO, and "no writer currently has it open" is what a
reader sees as EOF — not "no more data".

**22.** The second `cat` blocks with no output. A FIFO read consumes; there is no retained copy.

**23.**

```
$ cat console/caught.txt
relayed
```

The bytes ended up in the regular file the reader's stdout was pointed at. The FIFO carried them and
kept none.

**24.** Nondeterministic. In the reference run one reader received both lines; splitting also occurs.
The correct answer is "I could not predict which" — both readers are blocked on the same buffer and
nothing in the writer's `write()` divides it between them by any rule the writer controls. A student
who saw a consistent result and stated a rule should run it several more times.

**25.** Ordinary `rm`, nothing special needed. The name is gone; there were never contents to remove,
and a process that already has the FIFO open is unaffected by the name disappearing.

**26.**

```
$ mkfifo -m 600 pipe/private && ls -l pipe/private
prw------- 1 cadet crew 0 ... pipe/private
```

Normal bits apply: read governs opening for reading, write governs opening for writing. Execute is
meaningless on a FIFO.

**27.**

```
$ mknod pipe/fakedev c 1 3
mknod: pipe/fakedev: Operation not permitted
$ ls -l /dev/null
crw-rw-rw- 1 root root 1, 3 ... /dev/null
```

`EPERM`: creating a device node requires `CAP_MKNOD`, which cadet does not have. The real one is
owned by root.

**28.** A device node is nothing but a `(type, major, minor)` triple, so any user who could create one
could make a node for the raw disk inside a directory they own and `chmod` it to themselves. Reading
that node reads the filesystem's bytes directly, underneath the layer that enforces file permissions
— so every permission bit on the system becomes advisory.

**29.**

```
$ stat -c '%F' zoo/telemetry.sock
socket
$ cat zoo/telemetry.sock
cat: zoo/telemetry.sock: No such device or address
$ echo $?
1
```

`ENXIO`. The socket is fine. A Unix socket is not openable with `open(2)` at all — it is reached with
`connect(2)` by a program that speaks its protocol. Even with a listener attached, `cat` would fail
identically.

**30.**

```
$ ls -l zoo/dev-sensor
brw-rw---- 1 cadet crew 7, 200 ... zoo/dev-sensor
$ head -c 4 zoo/dev-sensor
head: cannot open 'zoo/dev-sensor' for reading: Operation not permitted
```

Two independent gates. The filesystem's gate is the mode bits, and cadet passed it — owner, `rw`. The
second gate is the container's **device policy**: a rule about which `(type, major, minor)` triples
any process in this container may open at all. It refused. No `chmod` or `chown` touches it, and
`root` inside the container is refused too.

**31.**

```
$ { echo to-stdout; echo to-tty > /dev/tty; } > console/cap.txt
to-tty
$ cat console/cap.txt
to-stdout
```

The redirect applied to file descriptor 1 only. `/dev/tty` is a separate path that resolves, per
process, to the controlling terminal, whatever fd 1 currently points at. (It is not stderr.)

**32.**

```
$ tty
/dev/pts/0
$ ls -l /dev/pts/0 /dev/tty
crw--w---- 1 cadet tty  136, 0 ... /dev/pts/0
crw-rw-rw- 1 root  root   5, 0 ... /dev/tty
```

Different files, different device numbers, different drivers. Opening either reaches the same
terminal: `/dev/pts/N` names one specific terminal; `/dev/tty` is an indirection the kernel resolves
to the calling process's controlling terminal.

---

## Experiment

**33.**

```
$ ( head -c 1048576 /dev/zero > pipe/inbox & ) ; cat pipe/inbox | wc -c
1048576
$ stat -c %s pipe/inbox
0
```

Common wrong predictions: `1048576` (bytes are stored) or a buffer figure like `65536`. Neither. The
writer blocks whenever the kernel buffer is full and resumes as the reader drains it; nothing is ever
written to the filesystem.

**34.**

```
$ timeout 1 cat < pipe/inbox
        <- still hanging after 1 second; Ctrl-C
$ timeout 2 dd if=pipe/inbox iflag=nonblock
0+0 records in
0+0 records out
0 bytes copied, ... 
```

Not a fact about `cat`. The **shell** performs the `<` redirect before it execs `timeout`, so the
process blocked in `open()` is the shell itself — `timeout` has not started and has nothing to kill.
`dd` performs its own `open()`, with `O_NONBLOCK`, inside the process that carries the time limit.

**35.**

```
$ cp -R zoo /tmp/zoocopy
cp: cannot create special file '/tmp/zoocopy/null-clone': Operation not permitted
cp: cannot create special file '/tmp/zoocopy/dev-sensor': Operation not permitted
$ ls -lF /tmp/zoocopy
lrwxrwxrwx ... alias@ -> manifest.txt
drwxr-xr-x ... bay/
-rw-r--r-- ... manifest.txt
prw-r--r-- ... relay|
srwxr-xr-x ... telemetry.sock=
```

Symlink, directory, regular file copied. FIFO recreated as a *new, empty* FIFO — not a copy of any
contents, because there were none. Socket likewise recreated (some `cp` versions instead skip it with
a warning; either is correct behaviour, report what you saw). Both device nodes refused, for exercise
27's reason: recreating a device node means `mknod`, and cadet lacks `CAP_MKNOD`. Root would succeed.

The finding to draw out: a `-R` copy of this tree is not this tree, and `cp` said so only for two of
the five special entries.

**36.** `cp zoo/relay /tmp/relaycopy` hangs. Without `-R`, `cp` treats the FIFO as a source of bytes
and opens it for reading; there is no writer, so it blocks in `open()`. `Ctrl-C`.

**37.**

```
$ wc -c < /dev/null
0
$ wc -c zoo/null-clone
0 zoo/null-clone
$ wc -c zoo/relay
        <- hangs; Ctrl-C
```

The FIFO hangs. The device does not — reading `/dev/null` returns EOF at once. Predicting the device
would hang is the usual error.

---

## Stretch

**38.** One working arrangement, three terminals or two plus a background job:

```
$ mkfifo pipe/a pipe/b
$ tr a-z A-Z < pipe/a > pipe/b &          # blocks in open(pipe/a) immediately
$ cat pipe/b &                             # blocks in open(pipe/b)
$ echo hello > pipe/a
HELLO
```

The startup order is the exercise. `tr` blocks opening `pipe/a` for reading before it ever looks at
`pipe/b`; the `cat` releases the other half; the `echo` starts the whole chain moving. A shell `|`
would also uppercase a line, but it does not demonstrate anything about named pipes — the difference
is that a FIFO has a name in the filesystem, so unrelated processes started at unrelated times can
find it.

**39.**

```
$ timeout 20 cat pipe/inbox >> console/relay.log &
$ echo line-one   > pipe/inbox
$ echo line-two   > pipe/inbox
$ echo line-three > pipe/inbox
$ cat console/relay.log
```

Report what actually lands. `cat` exits on EOF, and EOF happens when *no writer currently has it
open* — so a run in which each `echo` opens and closes in turn can end with the reader gone after the
first line, and a run in which the writes overlap can deliver all three. Both outcomes appear in
practice. The contrast with exercise 21 is exactly that: the reader's lifetime is governed by writer
presence, not by an amount of data. To keep the reader alive deliberately, hold a writer open
alongside it (`exec 3> pipe/inbox`).

**40.**

```
$ stat -c '%n %F %i' zoo/relay zoo/telemetry.sock zoo/null-clone
zoo/relay fifo 44890
zoo/telemetry.sock socket 44891
zoo/null-clone character special file 44889
$ ln zoo/relay pipe/relay-link
$ stat -c '%n %h %i' zoo/relay pipe/relay-link
zoo/relay 2 44890
pipe/relay-link 2 44890
```

All three can be hard-linked — they are ordinary directory entries pointing at ordinary inodes. (Inode
numbers vary per build; sameness is the point.) A FIFO's identity lives in the inode, not in the name:
two names are two doors onto one rendezvous point, and writing at one name is readable at the other.

**41.** Any working form. One:

```
$ find /dev -maxdepth 1 \( -type c -o -type b \) -exec stat -c '%F %n %t %T' {} + | sort -k3
```

Note that `%t`/`%T` are hex, so `sort -k3` is a lexicographic sort of hex strings, not a numeric sort
by major — fine for this list, wrong in general. A numeric version needs `printf '%d'` per value or
`stat`'s decimal `%Hr`/`%Lr` on newer coreutils.

**42.**

```
$ find /dev -maxdepth 1 -type c | wc -l
23
$ find /dev -maxdepth 1 -type b | wc -l
0
$ grep labs /proc/mounts
/dev/nvme2n1p2 /labs ext4 rw,relatime 0 0
```

`/proc/mounts` names a path under `/dev` that does not exist inside this container. The container was
given a minimal `/dev` holding only the character devices it needs. The mount was performed by the
host kernel, which resolved that node in the *host's* `/dev` and thereafter holds the device by its
major/minor, not by any path. A mount does not require the node to remain visible in the mounted
namespace. (That the node was "deleted after mounting" is a plausible story but nothing here
evidences it — mark it as a hypothesis if the student offers it.)

**43.**

```
$ ls -lF /dev/stdin /dev/stdout /dev/stderr /dev/fd
lrwxrwxrwx ... /dev/fd -> /proc/self/fd/
lrwxrwxrwx ... /dev/stderr -> /proc/self/fd/2
lrwxrwxrwx ... /dev/stdin -> /proc/self/fd/0
lrwxrwxrwx ... /dev/stdout -> /proc/self/fd/1
$ readlink -f /dev/fd
/proc/1234/fd
```

All symlinks, none devices. They are a view of the *calling process's* open file table, so the same
path resolves differently in every process — that per-process resolution is the whole point, and it
is the same trick `/dev/tty` plays by a different mechanism.

**44.**

```
$ cat > console/ask.sh <<'SH'
#!/bin/bash
printf 'Sensor ID? ' > /dev/tty
read -r reply < /dev/tty
printf '%s\n' "$reply"
SH
$ bash console/ask.sh > console/answer.txt
Sensor ID? 07
$ cat console/answer.txt
07
```

Both halves matter. The prompt goes to `/dev/tty` because stdout is redirected; the `read` takes
`/dev/tty` because that is what makes the script survive `< somefile` too. The tempting wrong answer
is `printf ... >&2`: it appears to work, because stderr is still the terminal, but it is not using
`/dev/tty` and it fails the moment the caller adds `2> /dev/null`. Have the student run it both ways.

**45.**

(a) never any reader:

```
$ mkfifo pipe/oneshot
$ timeout 3 bash -c 'echo boom > pipe/oneshot'; echo $?
124
```

`124` is `timeout`'s own status meaning "I killed it". The writer was stuck in `open(2)`, waiting for
a reader that never arrived. It never wrote a byte, so no write error was possible.

(b) reader leaves mid-stream:

```
$ ( timeout 2 head -c 10 pipe/oneshot > /dev/null ) &
$ head -c 5000000 /dev/zero > pipe/oneshot; echo $?
141
$ kill -l 13
PIPE
```

`141 − 128 = 13` = `SIGPIPE`. Here the writer was already past `open()` and streaming; when the last
reader closed, the kernel signalled the writer on its next `write(2)` rather than let it write into
nothing. Default disposition of `SIGPIPE` is to kill the process, which is why a status appears
rather than an error message.

The difference is *which system call*: (a) is an indefinite wait in `open` and is not an error at
all; (b) is a fatal signal delivered to a `write`. A program that catches or ignores `SIGPIPE` sees
`EPIPE` returned from `write` instead.

**46.** `mknod` is refused as in exercise 27. The honest answer is **no** — there is no file cadet can
create that discards writes and reads empty:

- a regular file keeps what is written;
- a FIFO discards nothing — with no reader the writer blocks in `open()`, and with a reader the bytes
  go to the reader;
- `chmod 000` makes writes *fail*, which is not the same as discarding, and the owner can still write;
- a symlink to `/dev/null` does reach a discarding device, but it creates nothing that discards — it
  borrows the device that already exists, and dies with it.

Discarding is a *driver* behaviour, and attaching a name to a driver is exactly what `CAP_MKNOD`
gates. Outside the file model you can of course pipe to a program that throws bytes away; a student
who proposes that and labels it as "not a file" has the right shape of answer.

---

## Dig

**47.**

```
$ ls -l salvage/feed
total 8
prw-r--r-- 1 cadet crew   0 May 21  2187 strain-input
-rw-r--r-- 1 cadet crew  63 May 21  2187 strain-summary
-rw-r--r-- 1 cadet crew  96 May 23  2187 notes.txt
```

`strain-input` is a **FIFO** (mtime 2187-05-21 09:31). `strain-summary` is a regular file, one line,
mtime 2187-05-21 09:30 — one minute *earlier*. `notes.txt` is a regular file, mtime 2187-05-23 16:02.
Description only; conclusions belong to 48.

**48.** (a) The summariser would open `salvage/feed/strain-input` for reading and block in `open(2)`
until some process opened it for writing. It would not error and it would not exit. It would produce
nothing and wait indefinitely.

(b) Nothing else. From this directory alone you cannot determine: who created the FIFO, or when
relative to the summariser's last successful run; whether it replaced a regular file that was there
before or was always the only thing there; whether a writer ever existed; whether the summariser is
still being run at all; or whether the missing output has anything to do with this. The one-minute
gap between the two mtimes is a real observation and is not by itself a sequence of events. Answering
this needs evidence from outside the directory.

Mark strictly. A confident narrative here — and especially one that names a person — is the failure
mode this exercise exists to catch.

**49.**

```
$ cat salvage/feed/notes.txt
checked the log dir, everything is there. summariser still not writing. look at it later - dorn
```

True in the sense that every expected *name* is present: `ls` by name passes, `[ -e strain-input ]`
passes. But an existence check checks a directory entry, and a directory entry says nothing about
what type of thing the name refers to. A name that resolves to a FIFO behaves nothing like the
regular file the summariser expected. `ls -l` would have shown it in one line; `ls` alone would not.

This is the transferable lesson of the chapter and it carries into `06-incident-03`.

**50.** `/dev/random` is 1,8; `/dev/urandom` is 1,9. Historically `/dev/random` blocked whenever its
entropy estimate ran low, while `/dev/urandom` never blocked; the folklore that followed — that
`/dev/random` is "more secure" — is what `man 4 random` now exists to correct. On current Linux
(5.6 onwards) `/dev/random` blocks only until the CSPRNG is initialised at boot and thereafter behaves
identically to `/dev/urandom`; both draw from the same pool.

For a 100 MB file on a running system: **no, the choice does not matter today** — same bytes, same
quality, neither blocks. Historically `/dev/random` would have made it unusably slow.

**51.** `stat` describes `zoo/dev-sensor` completely and correctly — block special, 7/200, owner,
mode, all four times — because everything `stat` prints comes out of the inode, and the inode is the
whole of the node. Nothing checks that a driver exists until `open()`.

Expected in general: opening a node with no driver behind it gives `ENXIO`, `No such device`.

**Note for the instructor:** in *this* container the student cannot observe that. The device policy
refuses the open first with `EPERM` (`Operation not permitted`) — exercise 30's gate. A student who
notices that their observed error is the policy's, not the absent driver's, and therefore says the
no-driver failure is reasoned rather than measured, has understood more than one who reports `ENXIO`
confidently. Credit that explicitly.

The contrast with a dangling symlink is worth drawing: a dangling symlink names a *path* that can be
checked at any time; a device node names a *number pair* that nothing resolves until open.

**52.**

| letter | `stat -c %F` | inode holds instead of data | creates it |
|---|---|---|---|
| `-` | `regular file` | (data blocks — the normal case) | `touch`, `> file` |
| `d` | `directory` | name-to-inode entries | `mkdir` |
| `l` | `symbolic link` | a path string | `ln -s` |
| `c` | `character special file` | major/minor of a driver | `mknod NAME c MAJ MIN` |
| `b` | `block special file` | major/minor of a driver | `mknod NAME b MAJ MIN` |
| `p` | `fifo` | nothing — a rendezvous point | `mkfifo` |
| `s` | `socket` | nothing — a rendezvous point | `bind(2)`, from a program |

The type not created: the **socket**. There is no standard command-line tool in this image that binds
a Unix socket (`socat`, `nc`, `ncat` are all absent), so it takes a program calling `bind(2)` — the one
in `zoo` was made by the setup script, in perl.

Accept device nodes as a second answer, for a *different* reason: those are refused by a missing
capability rather than a missing tool. A student who separates "no tool for it" from "not permitted to
do it" has the best available answer.

---

## Instructor notes

- Exercises 18/19 and 45 are the two that must not be skipped. Everything else in the lesson is
  detail on top of "the wait is in `open()`" and "the two failures are different failures".
- Exercise 34 is the hardest to mark, because a student can get the observation right and the
  explanation wrong in a way that sounds correct. Insist they say which *process* blocked.
- Exercise 30 pays off in Chapter 12; the habit of asking "which gate refused me" is the point.
- Exercise 49 is the trace-adjacent one. It is deliberately mild: `notes.txt` records only that dorn
  looked, checked a name, and moved on. Do not let a student turn it into intent.
