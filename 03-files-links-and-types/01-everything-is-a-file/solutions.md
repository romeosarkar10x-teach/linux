# 03/01 — Solutions

Instructor copy. Do not show the student. Outputs below were captured from the seeded lab; dates and
inode numbers will differ.

---

**1.**
```
$ ls -l types
srwxr-xr-x 1 cadet crew      0 ... control.sock
drwxr-xr-x 2 cadet crew   4096 ... deck-3
prw-rw-rw- 1 cadet crew      0 ... pipeline
lrwxrwxrwx 1 cadet crew     11 ... pointer -> regular.txt
-rw-r--r-- 1 cadet crew     36 ... regular.txt
brw-rw---- 1 cadet crew 7, 200 ... scratch-disk
crw-rw-rw- 1 cadet crew 1,   3 ... void
```
`s` socket · `d` directory · `p` FIFO · `l` symlink · `-` regular · `b` block device · `c` char
device.

**2.** Self-marked. No fixed answer.

**3.**
```
$ ls -F types
control.sock=  deck-3/  pipeline|  pointer@  regular.txt  scratch-disk  void
```
Markers: `=` socket, `/` directory, `|` FIFO, `@` symlink. No marker: `regular.txt`,
`scratch-disk`, `void`. `-F`'s marker set is `/ @ | = *` (plus `>` for doors, which Linux does not
have) — there is no character for a block or character device, so device nodes print bare, exactly
like an unexecutable regular file.

**4.**
```
$ stat -c '%n %F' types/*
types/control.sock socket
types/deck-3 directory
types/pipeline fifo
types/pointer symbolic link
types/regular.txt regular file
types/scratch-disk block special file
types/void character special file
```
(`stat` does not follow the symlink by default, which is why `pointer` reports as a link.)

**5.**
| Entry | `stat -c %F` | `file` |
|---|---|---|
| control.sock | socket | socket |
| deck-3 | directory | directory |
| pipeline | fifo | fifo (named pipe) |
| pointer | symbolic link | symbolic link to regular.txt |
| regular.txt | regular file | ASCII text |
| scratch-disk | block special file | block special (7/200) |
| void | character special file | character special (1/3) |

Differently worded: `pipeline`, `scratch-disk`, `void` (and arguably `pointer` and `regular.txt`,
where `file` adds information rather than rewording). Accept any three with justification.

**6.** `0`. The driver at major 1 minor 3 returns end-of-file on the first read. `head` asked for ten
bytes and got zero, immediately — no waiting, no error.

**7.**
```
$ echo hello > types/void
$ cat types/void
$
```
The write succeeds — the shell reports nothing and the exit status is 0. The driver discards the
bytes. `types/void` is still zero-length because it never had a length; there is no storage behind
it.

**8.**
```
crw-rw-rw- 1 root  root 1, 3 ... /dev/null
crw-rw-rw- 1 cadet crew 1, 3 ... types/void
```
The shared field is the major/minor pair `1, 3`. Owner, group, path and name all differ; the pair is
what identifies the device, so both names route to the same driver instance. `types/void` is a
second `/dev/null`.

**9.** `ls -l` reports 11. `regular.txt` is eleven characters. A symlink's contents *are* the target
path, stored as a plain string with no terminator counted, so its size is the length of that string.

**10.**
```
$ ls -l  types/pointer
lrwxrwxrwx 1 cadet crew 11 ... pointer -> regular.txt
$ ls -lL types/pointer
-rw-r--r-- 1 cadet crew 36 ... pointer
```
The first line describes **the link**: type `l`, permissions `rwxrwxrwx` (symlink modes are ignored
by the kernel), size 11, and the arrow showing the stored path. The second describes **the target**,
reached by following the link: type `-`, the target's real permissions `644`, size 36 — the byte
count of `regular.txt`. The arrow is gone because there is no link in the object being described;
only the name survives from the argument.

**11.**
```
$ file manifest/*
manifest/empty:      empty
manifest/hull-log:   ELF 64-bit LSB pie executable, x86-64, ... stripped
manifest/latin1.txt: ISO-8859 text
manifest/panel.png:  ASCII text
manifest/panelcheck: Bourne-Again shell script, ASCII text executable
manifest/survey.txt: gzip compressed data, from Unix, original size modulo 2^32 31
manifest/utf8.txt:   Unicode text, UTF-8 text
```
Disagreements: `panel.png` (named PNG, is text) and `survey.txt` (named text, is gzip). `hull-log`
has no extension, so nothing disagrees — it is a surprise, not a lie.

**12.** `empty`. Most students predict `ASCII text` or `data`. `empty` is more useful because there
are no bytes to classify: calling it text would assert something `file` cannot know, and calling it
`data` would suggest unrecognised content when there is no content. It is its own answer.

**13.**
```
$ file manifest/latin1.txt manifest/utf8.txt
manifest/latin1.txt: ISO-8859 text
manifest/utf8.txt:   Unicode text, UTF-8 text
$ od -c manifest/latin1.txt | head -1
0000000   r 351   p   a   r   a   t   i   o   n       p   a   n   n   e ...
$ od -c manifest/utf8.txt | head -1
0000000   s   e   n   s   o   r       d   r   i   f   t     342 200 224 ...
```
`latin1.txt` holds é as **one** byte, octal 351 (0xE9). `utf8.txt` holds an em dash as **three**
bytes, 342 200 224 (0xE2 0x80 0x94). 0xE9 alone is not a valid UTF-8 sequence — 0xE9 introduces a
three-byte sequence and the bytes that follow it are plain ASCII, not continuation bytes — so `file`
rules out UTF-8 and falls back to ISO-8859. Neither file is damaged; they are two encodings.

**14.** `application/gzip; charset=binary` and `text/plain; charset=us-ascii`. Use `-i` when a
program consumes the answer — dispatching on content type, choosing a decompressor, setting an HTTP
header. The prose form is written for humans and its wording is not stable across versions.

**15.**
```
$ cat types/control.sock
cat: types/control.sock: No such device or address
$ cat types/pipeline
^C
```
The socket fails instantly: `open()` on an AF_UNIX socket file is not how you connect to one, and
the kernel says so with ENXIO. `cat` cannot speak the protocol and never gets the chance to try.

The FIFO hangs. Opening a FIFO for reading blocks until some process opens the same FIFO for
writing. Nothing else is running, so nothing ever will, and `cat` waits until `Ctrl-C`. Common wrong
prediction: that both would print nothing and exit, on the assumption that "a file you can open is a
file you can read to the end". A FIFO has no end until a writer arrives and leaves.

**16.**
```
$ head -c 10 types/scratch-disk
head: cannot open 'types/scratch-disk' for reading: Operation not permitted
$ stat -c '%s %b' types/scratch-disk
0 0
$ file -s types/scratch-disk
types/scratch-disk: no read permission
```
Reconciled: the node exists and is a perfectly valid directory entry — `stat` reads it fine. Size 0,
blocks 0, because a device node stores nothing; the size field is not a measurement, it is unused.
The open fails at major 7 minor 200: major 7 is the loop driver, and no loop device is attached at
instance 200. The `Operation not permitted` phrasing (rather than "no such device") is the driver's
answer, and `file -s` reports the same refusal in its own words. Creating the name did not create
the device.

**17.**
```bash
for f in types/*; do
  if   [ -L "$f" ]; then t="symbolic link"
  elif [ -d "$f" ]; then t="directory"
  elif [ -p "$f" ]; then t="fifo"
  elif [ -S "$f" ]; then t="socket"
  elif [ -b "$f" ]; then t="block special file"
  elif [ -c "$f" ]; then t="character special file"
  elif [ -f "$f" ]; then t="regular file"
  fi
  echo "$f $t"
done
```
`-L` must come first: every other `test` operator follows symlinks, so `pointer` passes `-f` and
would be reported as a regular file. `stat -c %F` is better because it asks the inode once and gets
the answer, rather than asking seven yes/no questions and depending on the author getting their
order right.

**18.**
```
$ stat -c '%s %b %B' sizes/four-k.txt sizes/nothing.txt types/void
4096 8 512
0 0 512
0 0 512
```
`nothing.txt` and `void` both report 0, for unrelated reasons. `nothing.txt` is a regular file whose
size happens to be zero: it has a size, and you can change it by writing to it. `void` has no size
*to* have — the field is not a measurement of anything, and writing to it will never make it
non-zero. (`four-k.txt` shows the normal case: 4096 bytes, 8 blocks of 512.)

**19.**
```
$ od -c manifest/hull-log   | head -1
0000000 177   E   L   F 002 001 001  \0 ...
$ od -c manifest/panelcheck | head -1
0000000   #   !   /   u   s   r   /   b   i   n   /   e   n   v     b ...
```
`\177ELF` is the ELF magic number; `#!` is the shebang. `file` matched each against its signature
database. The executable bit is irrelevant to the verdict — `hull-log` and `panelcheck` would be
described identically with mode 644.

**20.** `-h, --no-dereference` and `-L, --dereference`. Two options are needed because `file` has no
fixed default: without `POSIXLY_CORRECT` in the environment, not following links is the default and
`-L` turns following on; with it set, following is the default and `-h` turns it off. Since either
behaviour can be the default depending on the environment, each needs an explicit name so a script
can pin it.

**21.** `mknod x c 1 5` creates a character device at major 1 minor 5, which is `/dev/zero` — reads
return an endless run of zero bytes. Evidence: `ls -l /dev/zero` shows `1, 5`. It is a duplicate
rather than a new device because the major/minor pair, not the path, is what selects the driver and
instance.

**22.**
```
$ mknod mine c 1 3
mknod: mine: Operation not permitted
```
`CAP_MKNOD` is restricted to root. The reason is that a device node is an access path to a driver,
and the permissions that protect a device live on the node — so a user who can create nodes can
create their own `b 259 0` for the root disk in their home directory, mode 600, owned by themselves,
and read every byte of the filesystem past every file permission on it. Restricting node creation is
what makes the permissions in `/dev` meaningful.
