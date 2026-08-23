# 03/05 — Help: Devices, FIFOs & Sockets

Five rungs. Climb one at a time. Rung 5 is a near-miss on purpose — it will not do what it looks
like it does.

Before anything else: several exercises in this lesson are **supposed to hang**. A blocked FIFO open
is the lesson, not a bug. `Ctrl-C` gets you out of every one of them.

---

## Level 1 — Questions to ask yourself

- Does this file *store bytes*, or does it *connect two programs*? Which of the seven types can even
  hold content?
- You ran `ls -l` and saw two numbers where the size normally goes. What does that tell you about
  what the inode is holding?
- `stat` and `ls -l` disagree about a device's numbers. Do they disagree about the *value*, or about
  how the value is printed?
- Two names, same major and minor. Are they two devices, or two doors onto one?
- Your command is hanging. Who is on the other end? Has anyone opened the other end at all?
- The size of that FIFO is 0 after a megabyte went through it. Where would the megabyte have been
  stored, if it were stored?
- You got "Operation not permitted" on a file you own with `rw` set. Permission bits are checked by
  the filesystem. Who else gets a vote?
- Your output went to the file instead of the screen. Which file descriptor did you redirect, and is
  there a path that reaches the terminal regardless?

## Level 2 — Where to look

- `ls -l` first column, and `ls -F` suffixes — `man 1 ls`, search for `--classify`.
- `stat -c '%F %t %T %s %h'` — `man 1 stat`, the format-code list. `%t` and `%T` have a note about
  their base; read it carefully before you compare them to `ls -l`.
- `man 1 file` — what it prints for each special type, and where it gets that (hint: not the name).
- `man 4 null`, `man 4 zero`, `man 4 full`, `man 4 random`, `man 4 tty` — one short page each. These
  answer most of the character-device exercises directly.
- `man 7 fifo` — the rendezvous rule is in the first two paragraphs. `man 3 mkfifo`, `man 1 mkfifo`.
- `man 2 write` — the ERRORS section, `EPIPE`. `man 7 signal` for what `SIGPIPE` does by default.
- `man 2 mknod` — the ERRORS section names the capability you are missing. `man 7 capabilities` for
  what that capability is.
- `man 7 unix` — why `cat` cannot read a socket.
- `/proc/mounts` — which device the lab lives on. `ls -l /dev` — whether that device has a node here.
- `/course/03-files-links-and-types/05-devices-fifos-sockets/setup.sh` — the header explains the
  shape of the lab. Reading it is allowed; it is not the answer key.

## Level 3 — The concept, on different data

Two terminals, a scratch FIFO, nothing to do with the lab. Terminal A:

```
$ mkfifo /tmp/demo
$ ls -l /tmp/demo
prw-r--r-- 1 cadet cadet 0 ... /tmp/demo
$ cat /tmp/demo
        <- hangs here, on open(), before it reads anything
```

Terminal B:

```
$ echo ping > /tmp/demo
$ 
```

Terminal A prints `ping` and exits. Now note three things: A blocked *before* B existed; B returned
immediately once A was waiting; and after all of it, `stat -c %s /tmp/demo` is still `0`. The bytes
were never in the file. The file is the rendezvous point, not the container.

Reverse the order — start B first — and B is the one that hangs. The rule is symmetric.

## Level 4 — Break it down

**"Which type is this?"** Do not guess from the name. One command answers it three ways:
`ls -lF NAME; stat -c '%F' NAME; file NAME`. If those three ever disagree, that itself is the
finding — write it down.

**"The two numbers do not match `stat`."** Take the `stat` value and convert: `printf '%d\n' 0xc8`.
Now compare. Nothing about the device changed between the two commands.

**"Is this the same device as /dev/X?"** Compare the triple, not the name: type letter, major,
minor. `stat -c '%F %t %T' a b` puts both on screen at once.

**"My `cat < fifo` hangs and `Ctrl-C` feels like cheating."** It is not cheating, but if you want a
non-blocking look: `timeout 2 dd if=FIFO iflag=nonblock`. And note *why* wrapping the redirect
version in `timeout` does not help — the shell performs the redirect before `timeout` is ever
executed, so the thing that blocks is not the thing that got the time limit. Put the redirect inside
the command that is being timed.

**"Writing to a FIFO with no reader."** Two different failures, and the exercise wants both:
if there was *never* a reader, the writer blocks in `open()` and never writes a byte. If a reader
was there and left mid-stream, the writer is already past `open()` and gets a signal on its next
write. Measure the exit status in each case; a status over 128 means a signal, and `kill -l N-128`
names it.

**"Operation not permitted on a file I own."** Separate the two gates. The mode bits are the
filesystem's gate and you already passed it. A container also has a device gate — a policy about
which `(type, major, minor)` triples any process inside may open at all. Nothing you can do with
`chmod` or `chown` addresses the second gate. Say which gate refused you, and how you know.

**"My prompt went into the file."** stdout was redirected. `/dev/tty` is not stdout; it is a
character device that resolves, per process, to that process's controlling terminal. Write the
prompt there explicitly.

## Level 5 — Near-miss

This is close to a correct check for "is `zoo/null-clone` really `/dev/null`?" and it proves less
than it appears to.

```
$ echo hello > zoo/null-clone && cat zoo/null-clone && stat -c %s zoo/null-clone
0
```

Zero bytes in, zero bytes out — so it discards. But a plain empty regular file you had no write
permission on would also read back as nothing, and several other devices swallow writes too. This
observation is consistent with the claim; it does not establish it. There is a comparison that
settles it in one command, and it does not involve writing anything.

And a near-miss for the two-terminal FIFO work:

```
$ echo hello > pipe/inbox &
$ cat pipe/inbox
```

This does appear to work, and it will teach you the wrong rule. Backgrounding the writer hides the
blocking `open()` — the part you were sent to observe — and the `&` means you cannot see which of
the two actually waited for the other. Use two terminals for exercises 18 and 19; run them in both
orders.

---

## Never say

Do not hand over: the identity of `zoo/null-clone` (exercise 7 exists so the student finds it); the
base `%t`/`%T` print in, for exercise 6; the capability name for exercises 27–28; the word for what
refuses the read in exercise 30; the path `/dev/tty` for exercises 31 and 44; the signal name for
exercise 45; or which of `salvage/feed`'s entries is the FIFO in exercises 47–49. Name the man page
and let them read it.

Do not confirm or deny an Experiment-tier prediction before it has been run. The written prediction
being wrong is the mechanism of the exercise.

Do not tell the student what is wrong with the recovered feed in exercises 47–49. The whole exercise
is noticing that one of those entries cannot be read the way its neighbour can, and saying — in
writing, without overclaiming — exactly how much that does and does not prove about why the
summariser produced nothing.
