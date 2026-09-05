# 03/02 — Solutions

**Do not show the student.** This is the instructor copy: worked answers, the numbers a clean seed
actually produces, and the places students reliably go wrong.

Every output below was captured from a freshly seeded container. **The inode numbers will differ on
any other seed** — they are here so you can see the shape of a correct answer, not so you can match
them. What is stable: which numbers are equal to which, and every link count.

---

## Warmup

**1.**
```
$ ls -ia roster
44803 .      44781 ..      44804 .backup
44806 copy.txt   44805 crew-list.txt   44805 roster.txt
```
`-i` prints the inode number, `-a` includes `.`, `..` and `.backup`.

**2.** `roster.txt` and `crew-list.txt` — both 44805. `copy.txt` is 44806, its own file.

**3.** Second column of `ls -l`. For the three-name file it is `3`.

## Core

**4.**
```
$ stat -c '%i %h %s %n' roster/roster.txt roster/crew-list.txt roster/.backup/names.txt roster/copy.txt
44805 3 38 roster/roster.txt
44805 3 38 roster/crew-list.txt
44805 3 38 roster/.backup/names.txt
44806 1 38 roster/copy.txt
```
Same size on all four — size is a property of the contents, and `copy.txt` holds the same bytes.
Same inode on three, and a link count that agrees with how many names those three are.

**5.** `cmp roster/roster.txt roster/copy.txt` exits 0 and prints nothing: byte-identical. That
proves the contents match at this moment and nothing else. Two inodes can hold identical bytes;
writing to one will not change the other. Identity is the inode, not the contents.

**6.** `roster/.backup/names.txt`. The route is arithmetic, not search: the count says three names,
`ls -a roster` shows only two, so the third is elsewhere — and `.backup` is the only other place in
this tree. A hard link is not confined to the directory the file was made in.

**7.** `roster.txt` and `crew-list.txt` both show the new line; `copy.txt` does not. There is one
file with three names and one separate file with one name. The append went to inode 44805 by way of
the name `crew-list.txt`; `copy.txt` is 44806 and never saw it.

**8.**
```
$ ln roster/roster.txt roster/manifest.txt   # count 3 -> 4
$ rm roster/roster.txt                       # count 4 -> 3
$ cat roster/manifest.txt                    # contents intact
```
The data has three names left. `rm` removed one of them.

**9.** The question has no answer. `stat` on `crew-list.txt` and `manifest.txt` returns the same
record — same inode, same size, same `Birth` — because it *is* the same record. Nothing on disk
records which directory entry was created first. The word "original" describes a history the
filesystem does not store.

Students often reach for `Birth`. It is the same for both names, so quoting it argues for the
correct answer.

**10.**
```
$ stat -c '%i %h %n' decks decks/deck-3 decks/deck-4 decks/deck-5
44807 5 decks
44808 2 decks/deck-3
44809 2 decks/deck-4
44810 2 decks/deck-5
```

**11.** The five names for inode 44807:
1. `decks` in the lab root
2. `.` inside `decks`
3. `..` inside `deck-3`
4. `..` inside `deck-4`
5. `..` inside `deck-5`

The rule "subdirectories + 2" is a consequence, not an explanation. Make them name the five.

**12.** `deck-3` is 2: its own name in `decks`, plus its own `.`. It has no subdirectories. A new
empty directory is 2 for the same reason.

**13.**
```
$ stat -c '%i %n' . decks/.. decks/deck-3/../..
44781 .
44781 decks/..
44781 decks/deck-3/../..
```
`..` is not shell syntax and not a kernel special case at this level — it is a directory entry
holding a real inode number, which is exactly why it makes the parent's link count go up.

**14.** Before: `keeper.txt` and `expendable.txt` share 44815, count 2. After `rm expendable.txt`:
```
44815 1 scratch/keeper.txt
```
Same inode, count 1, contents unchanged. `rm` removed a directory entry and decremented a counter.
The inode is freed only when the count reaches 0.

**15.** `unlink`. `rm` is a program; `unlink(2)` is what it calls.

**16.** `cp -r` gives every copy its own inode and count 1 — the link structure is lost and the two
former names become two independent files:
```
44822 1 roster-copy/roster.txt
44823 1 roster-copy/crew-list.txt
```
`cp -a` (or `-d`, or `--preserve=links`) keeps it:
```
44827 3 roster-a/roster.txt
44827 3 roster-a/crew-list.txt
```
Accept `-a` as the practical answer; `--preserve=links` is the one `man cp` names directly.

**17.** Append fails, delete succeeds:
```
$ echo x >> locked/notes.txt
bash: locked/notes.txt: Permission denied
$ rm -f locked/notes.txt      # rc 0, the file is gone
```
Writing the file needs permission on the file. Deleting it removes a *name from a directory*, so it
needs write permission on `locked/`, which the cadet has. Without `-f`, `rm` asks
`remove write-protected regular file …?` — that prompt is `rm` being polite, not the kernel
objecting.

**18.** `chmod -w locked` — the directory. Nothing about `notes.txt` matters.

**19.** The mirror image. `sealed` is 555, `bolted.txt` is 666:
```
$ echo x >> sealed/bolted.txt      # rc 0
$ rm -f sealed/bolted.txt
rm: cannot remove 'sealed/bolted.txt': Permission denied
$ : > sealed/new.txt
bash: sealed/new.txt: Permission denied
```
Writable and undeletable. The rule: file mode governs the contents, directory mode governs which
names exist.

## Experiment

**20.**
```
$ ln decks decks-link
ln: decks: hard link not allowed for directory
```
Two names for one directory would give it two parents, so `..` has no single correct answer, and the
tree would contain a cycle — `find`, `du`, `rm -r` and `pwd` would all have to cope with a graph they
assume is a tree. Linux refuses for everyone, root included. (Symlinks are the sanctioned way, and
that is lesson 03.)

**21.**
```
$ ln roster/roster.txt /home/cadet/xdev
ln: failed to create hard link '/home/cadet/xdev' => 'roster/roster.txt': Invalid cross-device link
$ stat -c '%d %n' /labs /home/cadet
66309 /labs
69 /home/cadet
```
A directory entry stores an inode *number*, which is only meaningful inside one filesystem. Across
two filesystems the number means nothing, so the link cannot exist.

`df` shows one device backing both paths, which is what makes this worth doing: the physical disk is
irrelevant. `/labs` is a separate mount — a named Docker volume — and `%d` gives the kernel's device
number, which is the authority. Students who trust `df` here get it wrong, and that is the lesson.

## Stretch

**22.** `mv roster/copy.txt roster/renamed.txt` — inode 44806 before, 44806 after. A rename within
one filesystem writes directory entries and touches no data. Across filesystems `mv` cannot rename:
it copies every byte to the destination and unlinks the source, which is why it is slow, why it can
half-finish, and why the result has a new inode.

**23.** Whether the number is reused varies; ext4 commonly reuses it promptly. Either result is a
correct report. The conclusion is what matters: an inode number identifies a file only while some
name for it still exists. As a stored identifier across a deletion it is unsafe.

**24.** `stat -c '%d %i %n'`. Inode numbers restart per filesystem, so 44805 can exist on several
mounted filesystems at once. The pair (device, inode) is unique on a running system.

**25.** No `rm` needed:
```
$ cp roster/crew-list.txt /tmp/tmp.txt   # new inode
$ echo 'edited' >> /tmp/tmp.txt
$ mv /tmp/tmp.txt roster/crew-list.txt   # replaces the directory entry
```
`mv` over an existing name unlinks the old entry as part of the rename. The other name still points
at the old inode, now count 1, with the old contents. This is exactly what an editor that saves by
write-to-temp-then-rename does, and it is why hard links quietly stop tracking each other after an
edit. Editors that write in place (truncate and rewrite the same inode) keep the link.

## Dig

**26.** `find . -samefile roster/crew-list.txt` and `find . -inum 44805` both list all the names.
`-samefile` is better in a script: no number to hard-code, and it survives a re-seed. Chapter 6
teaches `find` properly; here it is only the shortcut for what they already did by hand in 6.

**27.** `man 2 unlink`: the space is not released while any process still holds the file open. The
last name can be gone and the data still be live; it is freed when the last descriptor closes. This
is why deleting a huge log does not always give the disk space back — Chapter 9 revisits it.

**28.**
```
$ df -i /labs
Filesystem       Inodes   IUsed    IFree IUse% Mounted on
/dev/nvme2n1p2 23912448 2411545 21500903   11% /labs
```
Inodes are a finite, separately-counted resource fixed at format time on ext4. A filesystem can run
out of them while `df -h` still shows free space, and file creation fails with `No space left on
device` on a disk that visibly has room. Millions of tiny files is the usual cause.

---

## Added exercises 29–52

**29.**
```
$ ls -lai roster
300258 drwxr-xr-x 3 cadet crew 4096 … .
300257 drwxr-xr-x 7 cadet crew 4096 … ..
300259 drwxr-xr-x 2 cadet crew 4096 … .backup
300261 -rw-r--r-- 1 cadet crew   38 … copy.txt
300260 -rw-r--r-- 3 cadet crew   38 … crew-list.txt
300260 -rw-r--r-- 3 cadet crew   38 … roster.txt
```
(Numbers vary per seed; the relationships do not.) `300260` appears twice because `roster.txt` and
`crew-list.txt` are two names for one inode. The other repeat is not inside this listing: `.` is
`roster` itself, so `300258` is also what `ls -id roster` prints from the parent.

**30.** `roster/.` is `roster`, and `roster/..` is the lab directory:
```
$ ls -id roster roster/. roster/.backup/..
300258 roster    300258 roster/.    300258 roster/.backup/..
$ ls -id . roster/..
300257 .         300257 roster/..
```
`.` and `..` are entries stored in the directory, not shell syntax — the shell passes them through
untouched and the kernel resolves them like any other name.

**31.**
```
$ rm decks/deck-5/status.txt && rmdir decks/deck-5
$ stat -c %h decks     → 4
$ mkdir decks/deck-6 decks/deck-7
$ stat -c %h decks     → 6
```
**link count = number of subdirectories + 2** — one for the directory's own name in its parent, one
for its own `.`, and one `..` from each child.

**32.** The two links of an empty directory are its name in the parent and its own `.`; there are no
children to contribute `..`. So `%h` answers "how many subdirectories does this have?" in a single
`stat` — subtract 2 — without `ls` having to read the directory and `stat` every entry, which on a
directory with a million entries is the difference between instant and minutes.

**33.**
```
step                       %h
echo hi > a                 1
ln a b                      2
ln a c                      3
ln a d                      4
rm d                        3
rm c                        2
rm b                        1
rm a                        0 (inode gone; stat fails)
```

**34.** At the last `rm`, when the count went from **1** to 0. The kernel watches exactly one number
— the link count in the inode — and frees the blocks when it reaches zero (and see exercise 40 for
the second condition). Every earlier `rm` removed a name and nothing else.

**35.**
```
$ stat -c '%b %B %s' roster/roster.txt roster/crew-list.txt roster/.backup/names.txt
8 512 38
8 512 38
8 512 38
```
They are identical because all three names lead to one inode, and blocks, block size and size are
fields *of the inode* — there is nothing per-name to differ. A fourth name costs one directory entry
(a few bytes inside an existing directory block) and no file data at all.

**36.** `roster/.backup`'s contents would change — the entry `names.txt` would be removed from it.
`roster/roster.txt`'s contents would not change by a byte; only its link count, which lives in the
inode, would drop from 3 to 2. Deleting a name is a write to a *directory*.

**37.**
```
$ echo one > a ; ln a b ; stat -c %h a      → 2
$ rm b ; stat -c %h a                       → 1
$ echo two > c ; mv c a ; stat -c '%i %h' a → new inode, 1
```
`rm` calls `unlink` directly. `mv` onto an existing name calls `rename`, which unlinks the
destination as part of the same operation — so the old inode's count reaches 0 there too, but the
call that did it was `rename`, not `unlink`.

**38.**
```
$ head -c 100000 /dev/zero > f1 ; ln f1 f2
$ du -sh .                → 104K
$ du -ah .                → 100K ./f1   /   104K .
$ du -sh --count-links .  → 204K
```
`du` charged for `f1` only and skipped `f2` — it remembers inodes it has already counted. The default
is right for "how much disk am I using" because the 100 KB exists once: counting it twice would
report space that does not exist.

**39.**
```
$ echo data > op ; exec 3<op ; rm op
$ ls -l /proc/self/fd/
lr-x------ … 3 -> /tmp/t3/op (deleted)
```
The link count is now 0. The data is still there because the descriptor is still open: the last name
is gone but the file is not, and `/proc` will still show you the path it used to have, marked
`(deleted)`.

**40.** `man 2 unlink`: the inode and its blocks are freed when the link count reaches zero **and**
no process holds the file open. Both must be true. This is why `rm` on a 40 GB log gives no space
back while the daemon writing it is still running — and why restarting the daemon suddenly does.

**41.** **Whether you may delete a name is governed by the write and execute bits on the directory
that holds it; whether you may change a file's contents is governed by the write bit on the file.**
A file's own mode bits never govern the existence of its names — `locked/notes.txt` at 444 sits in a
writable directory and goes; `sealed/bolted.txt` at 666 sits in a mode-555 directory and stays,
though you can append to it freely.

**42.**
```
$ cp -r roster roster-copy
$ stat -c '%i %h %n' roster-copy/*
4109132 1 roster-copy/copy.txt
4109133 1 roster-copy/crew-list.txt
4109134 1 roster-copy/roster.txt
```
Every link count is 1. `cp -r` read each name and wrote a separate new file, so the relationship is
gone: the copy has three independent files with identical contents where the original had one file
with three names. Editing one in the copy no longer changes the others.

**43.**
```
$ cp -a roster roster-a
$ stat -c '%i %h %n' roster-a/roster.txt roster-a/crew-list.txt
4109138 3 roster-a/roster.txt
4109138 3 roster-a/crew-list.txt
```
Inside the copy they **do** share an inode — `-a` implies `--preserve=links`, which notices that two
sources are the same inode and links the destinations together. Neither shares an inode with the
original: `--preserve=links` reproduces the link *structure*, it does not link back to the source.
That is the distinction `cp -l` gets wrong in exercise 44.

**44.**
```
$ cp -rl roster /home/cadet/roster-l
cp: cannot create hard link '/home/cadet/roster-l/roster.txt' to '…/roster/roster.txt': Invalid cross-device link
```
Same `EXDEV` as exercise 21, and for the same reason: `-l` asks for hard links **to the source
files**, and a hard link cannot cross a filesystem boundary. Within one filesystem `cp -rl` works and
gives you a tree that costs almost nothing.

**45.**
```
$ ln -s decks decks-slink
$ ls -l decks-slink   → lrwxrwxrwx … decks-slink -> decks
```
It succeeds. A symlink can name a **directory**, a target on another filesystem, or a path that does
not exist at all, because it stores a *path string* rather than an inode reference. The loop argument
does not apply because path resolution knows a symlink when it sees one: it counts them and gives up
with `ELOOP` after about forty, whereas a hard-linked directory loop would be indistinguishable from
real structure and nothing walking the tree could detect it.

**46.**
```
$ touch a ; stat -c %i a   → 4109144
$ rm a ; touch b ; stat -c %i b → 4109144
```
On this run the number came straight back on the very first new file. Neither outcome is a rule: the
allocator is free to reuse a freed inode immediately or never, and the answer depends on the
filesystem, the allocation policy and what else is running. **An inode number identifies a file only
for as long as you hold something that keeps it alive** — an open descriptor, or a name you know has
not been removed. Recording a number now and matching it later identifies nothing.

**47.**
```
$ stat -c '%d:%i %n' /labs/03-files-links-and-types/02-inodes/roster/roster.txt /home/cadet
66309:300260 …/roster/roster.txt
51:…         /home/cadet
```
Two paths are the same file when **both** halves match: the same inode number on the same device.
Inode 300260 exists on device 66309 and, almost certainly, a completely unrelated inode 300260 exists
on device 51 — which is exactly why `find -inum` needs a starting directory and why backup tools
store the pair.

**48.**
```
$ chmod 600 roster/crew-list.txt
$ ls -l roster/roster.txt   → -rw------- 3 cadet crew 38 …
```
Mode, owner, group, size and timestamps all live in the **inode**, not in the directory entry. A
directory entry holds a name and an inode number and nothing else, so there is nowhere for a per-name
permission to be stored. The result is not a side effect; it is the only thing that could happen.

**49.**
```
$ echo 'zaid  ops' >> roster/crew-list.txt      # both names still one inode
$ cp roster/crew-list.txt /tmp/t && mv /tmp/t roster/crew-list.txt   # split: %h now 1 and 1
$ rm roster/roster.txt && ln roster/crew-list.txt roster/roster.txt  # re-joined: %h 2
```
Re-joining required **choosing which of the two contents survives** — here `crew-list.txt`'s, the
newer one — and destroying the other. Splitting a link loses the fact that they were the same file
but keeps two sets of bytes; re-linking keeps one set and discards the other. There is no operation
that merges them, which is why this is a decision and not an undo.

**50.** `-inum` matches a number on whatever filesystem it walks into, so point it at a starting
directory that spans a mount point and it will happily return a file on the *other* filesystem that
merely happens to carry the same inode number — a completely unrelated file. `-samefile` compares the
device as well as the inode and will not. **The deciding factor is whether more than one filesystem
is in the search path** (exercise 47's other half).

**51.**
```
$ df -i /labs   → 23912448 total, 2624162 used, 21288286 free (11%)
$ df /labs      → 375356492 1K-blocks
```
375356492 KB ÷ 23912448 inodes ≈ **16 KB of space per inode**, which is `mke2fs`'s default ratio.
It is a bet that the average file is at least that big. A filesystem holding millions of small files
— a mail spool, a package cache, a node_modules tree — exhausts the inode table long before it fills
the disk, and the fix is a re-format with a smaller `-i`, not a bigger disk.

**52.** Under `cp -r` the restored tree has **a thousand independent files**: a hundred times the disk
usage, and an edit to one no longer shows in the other names. Under `cp -a` the link structure inside
the tree is reproduced — ten inodes, a thousand names — though the numbers themselves are new. A tool
that records inode numbers and re-creates the links (`tar` and `rsync -H` both do) gets the same
result by the same reasoning. For `/etc` you want the links preserved: sharing is often deliberate
there, and silently multiplying a config file into independent copies means the next edit fixes one
of them. For build artefacts, `cp -r` is fine and sometimes preferable — the links are an
optimisation the build tool made, nothing depends on them, and independent copies are easier to
reason about when you start deleting things.
