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

---

## Added exercises 23–52

**23.**
```
$ stat -c '%n %F %A %i' types/*
types/control.sock socket             srwxr-xr-x 300245
types/deck-3       directory          drwxr-xr-x 300239
types/pipeline     fifo               prw-rw-rw- 300244
types/pointer      symbolic link      lrwxrwxrwx 300241
types/regular.txt  regular file       -rw-r--r-- 300240
types/scratch-disk block special file brw-rw---- 300243
types/void         character special file crw-rw-rw- 300242
```
Two begin with neither `-` nor `d` and are not links: `s` on `control.sock` (socket) and `p` on
`pipeline` (FIFO). (`l`, `b` and `c` are the other three non-`-`, non-`d` characters present.)

**24.** `void` shows `1,   3` and `scratch-disk` shows `7, 200`. Those are the **major and minor
device numbers**, printed in the column where a size would go — a device node has no size, so `ls`
reuses the column for the only numbers that identify it. Major selects the driver, minor selects
which thing that driver handles.

**25.**
```
$ stat -c '%n %t %T' types/void types/scratch-disk
types/void         1 3
types/scratch-disk 7 c8
```
`c8` hex is 200 decimal. `stat`'s `%t`/`%T` are documented as hexadecimal because they are raw fields
lifted out of `st_rdev`, and `stat` is a field-printing tool; `ls` is a human-facing listing and
prints what a person would compare against `/dev`.

**26.** `sizes/nothing.txt` is a regular file whose size is 0 because it contains no bytes — write to
it and the number grows. `types/void` is a character device, and a device node has no contents at
all: the 0 is not a measurement of anything, it is the absence of a field that would be meaningless
here. One zero can change; the other cannot.

**27.** Six entries have `%h` of 1; `types/deck-3` has 2. The second link is the `.` entry **inside**
`deck-3`, which points back at the directory. Every directory starts with two links — its name in the
parent, and its own `.` — and gains one more for each subdirectory's `..`.

**28.**
```
$ file -h types/pointer   → symbolic link to regular.txt
$ file -L types/pointer   → ASCII text
$ stat -c '%F %s'         → symbolic link 11
$ stat -L -c '%F %s'      → regular file 36
```
One rule: **without a "follow" flag, a tool describes the link; with one, it describes the target.**
`file`'s default is `-h`; `stat`'s default is not to follow; `-L` in both cases means "resolve, then
report". The 11 is the length of the string `regular.txt`; the 36 is the length of the file it names.

**29.** With `-L` first, `pointer` prints `symlink`. With `-L` moved to the end, `pointer` prints
`file` — because `test -f` **follows symlinks**, finds a regular file at the other end, and returns
true before `-L` is ever reached. Same rule as exercise 28: every `test` operator except `-L` (and
`-h`) resolves the link first.

**30.**
```
manifest/hull-log:   177   E   L   F 002 001 001  \0 …
manifest/panelcheck:   #   !   /   u   s   r   /   b   i   n   /   e   n   v …
manifest/survey.txt: 037 213  \b  \0 …
```
ELF magic is `0x7F 'E' 'L' 'F'` — `od` prints the first byte as `177` octal. The shebang is the two
literal characters `#!`. The gzip magic is **`037 213`** in octal (`0x1F 0x8B`), followed by `\b`
(`0x08`), the deflate compression method.

**31.** `file -b` drops the `name:` prefix and prints only the description. A script wants it when the
filename is already known and the output is going into a variable or a comparison — with the prefix
you would have to strip a variable-length name, and the name may contain a colon of its own.

**32.**
```
manifest/empty:      binary
manifest/hull-log:   binary
manifest/latin1.txt: iso-8859-1
manifest/panel.png:  us-ascii
manifest/panelcheck: us-ascii
manifest/survey.txt: binary
manifest/utf8.txt:   utf-8
```
`empty`, `hull-log` and `survey.txt` are `binary`. `empty` is one of them because `binary` here means
"no text encoding was identified", and a file with zero bytes offers no evidence for any encoding.
The tool is not claiming it contains binary data; it is declining to claim it contains text.

**33.**
```
$ od -An -tx1 manifest/latin1.txt | head -1
 72 e9 70 61 72 …
$ od -An -tx1 manifest/utf8.txt | head -1
 73 65 6e … 20 e2 80 94 20 …
```
`0xe9` in `latin1.txt` is followed by `0x70` (`p`), an ASCII byte. In UTF-8, any byte of the form
`110xxxxx`/`1110xxxx` must be followed by continuation bytes of the form `10xxxxxx`, i.e. `0x80`–
`0xBF`. `0xe9` announces a three-byte sequence and `0x70` is not a continuation byte, so the file
cannot be UTF-8 — while `utf8.txt`'s `e2 80 94` is exactly the well-formed three-byte encoding of the
em dash.

**34.**
```
$ file -z manifest/survey.txt
manifest/survey.txt: ASCII text (gzip compressed data, from Unix, original size modulo 2^32 31)
```
`-z` decompressed the stream and described **the contents**, keeping the container description in
parentheses. On a 40 MB archive it would have cost a full decompression — CPU and, depending on the
format, temporary space — to answer a question you asked about the outside of the file.

**35.** A PNG begins with the eight bytes `89 50 4E 47 0D 0A 1A 0A` — the high-bit byte, the letters
`PNG`, and a CRLF/EOF trap sequence. `file` ignoring the extension is correct because the extension is
a claim made by whoever named the file and the magic is a property of the bytes: any tool that trusted
the name would be trusting the least reliable field available, which is exactly the mistake this whole
lab is built to break.

**36.**
```
$ file -s types/scratch-disk
types/scratch-disk: no read permission
```
`-s` means "read special files": normally `file` refuses to open device nodes and FIFOs, because
opening one can block or have side effects, and reports only the node type. `-s` tells it to go
ahead and read — which is how you identify a filesystem on a raw disk. Here the open is refused
before any of that, so the answer is the refusal.

**37.**
```
test -f types/pointer  → true      test -f types/void  → false
test -L types/pointer  → true      test -L types/void  → false
test -e types/pointer  → true      test -e types/void  → true
test -c types/pointer  → false     test -c types/void  → true
```
`test -f types/pointer` being true proves `test` looked at **the target**, not the link: the link
itself is not a regular file. `-L` is the exception that reports on the link.

**38.** Both print `0`. The character device satisfied each read immediately with end-of-file: zero
bytes, no error, no waiting. That is a *behaviour* implemented by the driver at major 1 minor 3, not a
size — there is no storage anywhere whose extent the 0 could be describing. A `wc -c` of 0 on a
regular file and on this device are the same number reported for entirely different reasons.

**39.** The byte count stays 0. The six bytes went to the driver behind major 1 minor 3, which accepts
every write, reports success, and discards the data. The thing that decided their fate is **the kernel
driver selected by the major number** — not the filesystem, which stored nothing, and not the
permissions, which allowed it.

**40.**
```
$ stat -c '%t %T' /dev/null types/void
1 3
1 3
```
No: writing to one can never be observed through the other, because there is nothing to observe. The
major/minor pair selects a **driver and unit**, and this one discards everything. Two nodes with the
same pair are two doors to the same driver, so they behave identically — but the driver's behaviour is
to keep nothing. Owner and path differ; behaviour does not.

**41.**
```
$ head -c 10 types/scratch-disk
head: cannot open 'types/scratch-disk' for reading: Operation not permitted
```
`EPERM`, not `ENODEV` and not `EIO`. The file permissions would allow it — `cadet` owns the node,
mode 660. The refusal came from **outside the filesystem**: the container's device cgroup does not
grant access to major 7, so the kernel refuses the open before any driver is consulted. A missing
loop device would have given a different error; this one says "you are not allowed to ask".

**42.**
```
sizes/four-k.txt  4096 8 512
sizes/nothing.txt 0    0 512
types/void        0    0 512
```
Two categories. `nothing.txt`'s zeros are **measurements**: a real file with no content and therefore
no blocks. `void`'s zeros are **absences**: a device node has neither content nor blocks to count, so
the fields are reported as 0 for want of anything to put there. `four-k.txt` shows what a real
measurement looks like — 8 × 512 = 4096 bytes actually allocated.

**43.**
```
$ cp -P types/pointer ~/p2
$ ls -l ~/p2   → lrwxrwxrwx … 11 … p2 -> regular.txt
```
A symlink's "contents" are the target **path as a string**, and its size is the length of that string
— 11 bytes for `regular.txt`. For a string this short the bytes are stored inside the inode itself (a
"fast symlink"), which is why `du` charges nothing for it: there is no data block.

**44.**
```
$ ln -sfn nowhere ~/dang
$ ls -l ~/dang     → lrwxrwxrwx … 7 … dang -> nowhere
$ file ~/dang      → broken symbolic link to nowhere
$ stat -c '%F'     → symbolic link
$ test -e ~/dang   → false
```
**`file` says it outright** — "broken symbolic link". `ls -l` shows the arrow but cannot tell you the
target is missing; `stat` describes the link and is silent about the target; `test -e` returns false,
which is informative only if you already suspected.

**45.**
```
$ ls -F types
control.sock=   deck-3/   pipeline|   pointer@   regular.txt   scratch-disk   void
```
`/` directory, `@` symlink, `|` FIFO, `=` socket, `*` would mark an executable. `regular.txt` gets
none because it is a plain non-executable file. **Device nodes get no marker at all** — `scratch-disk`
and `void` are indistinguishable from a regular file in `-F` output. It is a real gap, and the reason
`-F` is a convenience rather than a diagnostic: use `ls -l` or `stat -c %F` when the type matters.

**46.**
```
$ od -c sizes/four-k.txt
0000000   p   p   p   p   p   p   p   p   p   p   p   p   p   p   p   p
*
0010000
```
The `*` means "the previous line repeats until the next offset shown" — `od` collapses identical
lines by default, and `-v` disables that and would print all 256. The final line is the file's length
as an offset: `0010000` in **octal**, which is 4096.

**47.**
| entry | `stat -c %F` | `file` |
|---|---|---|
| control.sock | socket | socket |
| deck-3 | directory | directory |
| pipeline | fifo | fifo (named pipe) |
| pointer | symbolic link | symbolic link to regular.txt |
| regular.txt | regular file | ASCII text |
| scratch-disk | block special file | block special (7/200) |
| void | character special file | character special (1/3) |

The three that disagree in substance are `pointer` (file names the target), `regular.txt` (file
describes contents, stat describes type) and the two device nodes (file gives the numbers). **In a bug
report use `stat`'s wording for the type and `file`'s parenthetical for the identifying detail**:
`stat` says what the inode is, which is the fact; `file` adds what is inside or behind it, which is
the context.

**48.** `file --version` names the database:
```
magic file from /nix/store/…-file-5.48/share/misc/magic
```
(`file -C` compiles a `.mgc` from source rules; `$MAGIC` overrides the path.) Remove it and exercise
30's answers collapse: `file` would still recognise text versus non-text by scanning for printable
bytes, so `ASCII text` and `empty` would survive, but `ELF …`, `gzip compressed data` and
`Bourne-Again shell script` all come from database entries and would degrade to `data`.

**49.**
```
$ stat -c '%f' types/void         → 21b6
$ stat -c '%f' types/regular.txt  → 81a4
$ stat -c '%f' types/scratch-disk → 61b0
```
The **top hex digits carry the type**: `0x2000` character device, `0x8000` regular file, `0x6000`
block device (and `0x4000` directory, `0xA000` symlink, `0x1000` FIFO, `0xC000` socket). The bottom
three digits are the permission bits: `1b6` is 0666, matching `crw-rw-rw-`; `1a4` is 0644, matching
`-rw-r--r--`; `1b0` is 0660, matching `brw-rw----`.

**50.** Because the type is part of the address, not a label on it. The kernel looks at the type
character first and picks which of **two separate driver tables** to search — the character-device
table or the block-device table — and only then uses the major number as an index into that table.
Major 7 in the block table is the loop driver; major 7 in the character table is something else
entirely. `c 1 3` and `b 1 3` name two unrelated drivers.

**51.**
```
$ cat types/control.sock
cat: types/control.sock: No such device or address
```
`cat` called **`open`**, and `open` on an AF_UNIX socket fails with `ENXIO`. A socket is reached by
`socket()` + `connect()` to that path, not by opening the path — and the connection needs a process
on the other side that has `listen`ed. The filename is purely a **rendezvous point**: a well-known
address two processes can agree on. Nothing ever flows through the directory entry, which is why it is
the one type here where the name is not a channel even in principle.

**52.** "Everything is a file" is a claim about the **interface**, not about storage: every one of
these seven things is named in a single hierarchy, described by an inode with an owner, a mode and a
type, and reached through the same handful of syscalls — `open`, `read`, `write`, `close`, `stat`.
What differs is what the kernel does after `open`, which is why four of the seven do not answer `cat`
in the way a regular file does: a device hands the call to a driver, a FIFO blocks until a writer
appears, a socket refuses `open` entirely, and a directory is readable only through `readdir`. The
unifying fact is that you use the same vocabulary to name and inspect all of them, and one set of
permission rules governs the lot.
