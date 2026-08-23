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
