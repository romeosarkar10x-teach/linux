# 03/06 — Solutions (agent eyes only)

> **Student: do not open this file.** It contains the flag and every answer. Reading it removes the
> only thing this lesson had to offer.

## The shape of the incident

`deck3/console` holds four symlinks and nothing else. Three resolve, one does not:

```
$ ls -lF deck3/console
lrwxrwxrwx 1 cadet crew 26 Mar 30  2187 handbook -> ../docs/panel-handbook.txt
lrwxrwxrwx 1 cadet crew 10 Mar 30  2187 logs -> ../archive/
lrwxrwxrwx 1 cadet crew 21 Mar 30  2187 panel-current -> ../links/panel-active
lrwxrwxrwx 1 cadet crew 43 May  8  2187 strain-feed -> /mnt/eng-array/strain/strain-2187-05-22.csv
```

The live chain is three names for two inodes:

```
console/panel-current  --sym-->  links/panel-active  --sym-->  store/panel-log.txt
                                                                =(hard link)=
                                                              archive/panel-07.log
```

`readlink -f` stops at `store/panel-log.txt`. It never mentions `archive/panel-07.log`, because
`-f` resolves a *path* and knows nothing about the inode's other names. `%h` of 2 is the only
signal that a second name exists, and it does not say where. **That is the pedagogical hinge of the
lesson**; exercise 18 exists to make the student hit it.

`deck3/readings` is the required red herring: `sensor-a.txt` and `sensor-b.txt` are two names for
one inode, and `sensor-c.txt` is a genuine copy with identical bytes and its own inode. Spotting
the pair is a true finding and is not *the* finding. In `ls -l` the three lines are identical
except the link-count column: `2 2 1`.

`strain-feed` is **trace 3** of the sabotage arc (`_handoff/SCENARIOS.md`, 2187-05-2x). Its target
names the engineering mount that went away after dorn did. The chapter never says so and no agent
may say so. The path is read again in Chapter 15.

## Captured reference output

```
== readlink -f ==
handbook      :: [/labs/…/deck3/docs/panel-handbook.txt] rc=0
logs          :: [/labs/…/deck3/archive] rc=0
panel-current :: [/labs/…/deck3/store/panel-log.txt] rc=0
strain-feed   :: [] rc=1

== ls -lL deck3/console/panel-current ==
-rw-r--r-- 2 cadet crew 438 May 24  2187

== inodes/links (%i %h %n) ==
44913 2 deck3/archive/panel-07.log
44913 2 deck3/store/panel-log.txt
44922 2 deck3/readings/sensor-a.txt
44922 2 deck3/readings/sensor-b.txt
44923 1 deck3/readings/sensor-c.txt

== ls -l deck3/readings ==
-rw-r--r-- 2 cadet crew 86 May 21  2187 sensor-a.txt
-rw-r--r-- 2 cadet crew 86 May 21  2187 sensor-b.txt
-rw-r--r-- 1 cadet crew 86 May 21  2187 sensor-c.txt

== find deck3 -xtype l ==
deck3/console/strain-feed

== cat deck3/console/strain-feed ==
cat: deck3/console/strain-feed: No such file or directory      rc=1

== stat -c "%n %F %y" deck3/console/strain-feed ==
deck3/console/strain-feed symbolic link 2187-05-08 17:44:00
```

Inode numbers are seed-specific. Only the equalities matter.

## Per exercise

**1.** Four `l` lines, targets and sizes as in the listing above: 26, 10, 21, 43.

**2.** The size is the byte length of the stored target string.
`echo -n ../links/panel-active | wc -c` → `21`. `ls -F` appends `/` to `logs`' target for display;
the stored string is `../archive`, 10 bytes.

**3.** `console` (the four link entries), `links` (an intermediate hop), `store` (where a log is
kept under a second name), `archive` (the panel logs), `docs` (the handbook), `readings` (sensor
data), `notes` (one note). No conclusion yet is the correct answer.

**4.** One-hop targets are in the table above. `panel-current`'s target is itself a link — and
**you cannot tell that from this output**: `readlink` prints a path, not a type. The honest answer
to "can you?" is no; you have to look at `../links/panel-active`.

**5.** The four-row table above. `strain-feed` prints nothing and exits 1: `-f` requires every
component but the last to exist and the last to be resolvable; it resolved nothing, so it printed
nothing. Empty output with rc 1 is the diagnosis, not a failed command.

**6.** `logs`. Evidence 1: `ls -F` shows `-> ../archive/` with a trailing slash. Evidence 2:
`ls deck3/console/logs` lists `panel-05.log panel-06.log panel-07.log`. (`ls -ldL` prints `d`.)

**7.**
| column | without `-L` | with `-L` |
|---|---|---|
| type | `l` — the link | `-` — the regular file at the end |
| mode | `lrwxrwxrwx`, fixed and meaningless for symlinks | `-rw-r--r--`, the target's real mode |
| size | 21 — length of `../links/panel-active` | 438 — bytes of the log |
| date | Mar 30 2187 — the link's own mtime | May 24 2187 — the target's |
| link count | 1 | **2** — first hint of the hard link |

**8.** `stat` → 44917 (the link's own inode); `stat -L` → 44915 (the target's). The link's inode
stores the target *path string* (and mode/owner/times), not data.

**9.** `console/panel-current` –sym→ `links/panel-active` –sym→ `store/panel-log.txt`, and
`store/panel-log.txt` **is** `archive/panel-07.log` — a hard link, i.e. a second directory entry
for one inode, not a hop. Two symlink hops.

**10.** `cat: deck3/console/strain-feed: No such file or directory`, rc 1. `ls`/`stat` succeed
because they read the link's own inode with `lstat` and never open the target; `cat` must `open()`
it, and that is where the missing path is discovered.

**11.** `/mnt/eng-array/strain/strain-2187-05-22.csv`. Absolute, under a mount point, therefore not
under `/labs` — it names a filesystem that is not part of this tree. The filename carries the date
2187-05-22. (Trace 3. Do not tell the student whose mount it was.)

**12.** `-xtype l` → one line, `deck3/console/strain-feed`. `-type l` → five lines. `-type` tests
the entry itself; `-xtype` tests what it resolves to, and a link that resolves to nothing is still
reported as a link — which is exactly what makes `-xtype l` mean "broken".

**13.** `deck3/links/panel-active` → `../store/panel-log.txt`; the middle hop of the chain, outside
`console`.

**14.** `handbook`, `logs`, `panel-current`, `links/panel-active` all `2187-03-30 08:00`.
`strain-feed` `2187-05-08 17:44` — 39 days later. It was aimed later than the rest of the console
was built. That is a finding; the lesson does not resolve it.

**15.** Three files, all 86 bytes, all `May 21 2187`. The only difference is the link-count column
(second field): `2 2 1`.

**16.** `sensor-a.txt` and `sensor-b.txt` share inode 44922 — one file, two names. `sensor-c.txt`
is 44923, its own file. `%i` says *which* file; `%h` says how many names it has, not where they are.

**17.** Identical bytes are equally consistent with a hard link and with a copy, so `cat` and
`wc -c` cannot discriminate. Contents-only would have given "three copies" — wrong for a and b —
or "all one file" — wrong for c.

**18. (Experiment)** Both `store/panel-log.txt` and `archive/panel-07.log`: inode 44913, `%h` 2.
`readlink -f deck3/console/panel-current` → `…/deck3/store/panel-log.txt`, that name only. `-f`
walks the path string it was handed and stops at the name it lands on; the second directory entry
for that inode lives in a directory the path never visits, and nothing in path resolution would
ever find it. The `2` is the whole hint.

**19. (Experiment)** `cd deck3/console/logs; pwd` → `…/deck3/console/logs`. `pwd -P` →
`…/deck3/archive`. `cd` in bash keeps a logical path built from what you typed; `-P` resolves
symlinks and reports the physical location. `cd -P` would have made them agree.

**20. (Experiment)** With `-h`: rc 0 in both cases, the link's own mtime is set, the target is
irrelevant.
Without `-h`, aimed at `/nope/nothere`: `touch: cannot touch 'dang': No such file or directory`,
rc 1.
Without `-h`, aimed at `missing.txt` in an existing directory: **rc 0, and `missing.txt` is
created**, dated 2187-06-01, with the link now resolving. `touch` without `-h` opens-or-creates the
*target*; on a dangling link that means creating the file the link was pointing at. That is why
rule 1 forbids running it in `deck3` — it would have silently repaired the evidence.

**21. (Stretch)** After `rm target.txt`: `%h` drops to 1, both symlinks still resolve, contents
intact — no symlink named that entry, and the inode survives while any name remains. After
`rm second-name.txt`: the link count reaches 0, the inode is freed, and `cat front` fails with
`No such file or directory`. Note the subtlety worth drawing out: `readlink -f front` **still
succeeds** and still prints `/tmp/…/second-name.txt`, because `-f` only requires every component
*but the last* to exist. It differs from `strain-feed`, where a missing intermediate directory is
what makes `-f` fail. `readlink -e` is the option that requires the final component too. The two
symlinks were never pointing at the data; they were pointing at a *name*.

**22. (Stretch)** 2187-03-30 08:00 (the four links, plus `links/panel-active`) → 04-02 11:00
(`docs/panel-handbook.txt`) → 05-08 17:44 (`strain-feed`) → 05-12 03:12 (`panel-05.log`) → 05-14
03:34 (`panel-06.log`) → 05-21 09:31 (the three `readings` files) → 05-22 06:02
(`notes/dangling.txt`) → 05-24 04:11 (`panel-07.log`). Confirmation:
`find deck3 -newer deck3/notes/dangling.txt` → **two** lines, `deck3/archive/panel-07.log` and
`deck3/store/panel-log.txt` — which is the hard link showing up again, from a direction the student
was not looking. Worth praising if they notice.

**23. (Stretch)** `tail -n 1 deck3/console/panel-current`. That is the handbook's claim
demonstrated: the log was read through the console without naming where it lives.

**24. (Dig)** mtime `2187-05-22 06:02`. The note says the link is being kept because removing it
would destroy the only record of where it pointed, and that path is the only thing worth keeping.
It does not say who wrote it, when the target actually vanished (only when the note was last
written), or whether that mtime is truthful — `touch -d` sets any date.

**25. (Dig)** Recorded: link mtime 2187-05-08 17:44; note mtime 05-22 06:02; the target filename
contains `2187-05-22`; `panel-07.log` lines `05-21 09:30 summariser input stopped arriving`,
`05-22 06:02 feed path unreachable`, `05-24 04:09/04:11 audit`. Inference, and must be labelled as
such: that the target disappeared on the 22nd rather than earlier and was simply noticed then; that
the note's author also wrote the log; that the 05-08 re-aim is connected to any of it.

**26. (Dig)** Load-bearing: `store/panel-log.txt` and `archive/panel-07.log`, one inode across two
directories, the end of the chain. Not load-bearing: `readings/sensor-a.txt` and `sensor-b.txt`. To
someone who ran `ls -l deck3/readings` and stopped, that directory is three identical files —
same size, same date, same shape of name — and the only visible tell is the `2 2 1` in a column
most people never read.

**27. Flag:** `KESTREL{the_link_outlived_the_target}`

Last line of `archive/panel-07.log` (reached as `console/panel-current`):

```
2187-05-24 04:11  audit     nothing that runs depends on it, so it stays: the link outlived the target
```

Last five words, lowercased, underscore-joined. Registered as `03/06` in `container/flags.tsv`:

```
printf '%s%s' 'kestrel-station-7' 'KESTREL{the_link_outlived_the_target}' | sha256sum
8b1c491a46efe43a066bb9d756ae4042a3b9fe249e0c037282671b70669da991
```

Non-greppable: `grep -rl 'the_link_outlived_the_target' /labs` returns nothing. The on-disk line has
spaces, a preceding colon, and eleven words before the five that matter.

## Added exercises 28–52

**28.**
```
deck3/console/handbook:      symbolic link to ../docs/panel-handbook.txt
deck3/console/logs:          symbolic link to ../archive
deck3/console/panel-current: symbolic link to ../links/panel-active
deck3/console/strain-feed:   broken symbolic link to /mnt/eng-array/strain/strain-2187-05-22.csv
```
Only `strain-feed`'s line says **broken**. It is exercise 5's finding by another route. Put
`readlink -f` with its exit status in the report: `file`'s wording is a human sentence that a later
version could reword, while the exit status is a contract, and the report needs to survive being read
by a script.

**29.** All four are `symbolic link`, owner `root`, mode `lrwxrwxrwx`. That proves the difference
between working and dead is **not a property of the link at all** — nothing in the link's own inode
records whether the target exists. It is recorded in exactly one place: whether the path stored in
the link resolves, right now, on this machine. Move the tree, mount the array, and the same
unchanged link changes state.

**30.** `-L` makes `find` resolve every symlink before testing it, so a working link is tested as
whatever it points at — a file or a directory, never `l`. A link that cannot be resolved has nothing
to be tested as, and `find` falls back to reporting the link itself. So `-L … -type l` means "links
that could not be followed". **Type `-xtype l` from memory**: it says what you mean directly, and it
does not change how the rest of the expression behaves.

**31.** `deck3/console/logs` is in the list and is a symlink. `-xtype d` applies the *opposite* of the
current follow behaviour: with `find`'s default (do not follow), `-xtype` tests the **target**, so
`logs` matches because `../archive` is a directory. `-type d` would not have listed it.

**32.**
```
$ ls -F deck3/console
handbook@   logs@   panel-current@   strain-feed@
$ ls -lF deck3/console
… handbook -> ../docs/panel-handbook.txt
… logs -> ../archive/          ← trailing slash
… panel-current -> ../links/panel-active
… strain-feed -> /mnt/eng-array/strain/strain-2187-05-22.csv
```
In plain `-F` all four are just `@`. In `-lF` the classifier is also applied to **the target shown
after the arrow**, and `logs` gets `/` because `../archive` is a directory. This is different from
03/03 exercise 37 because printing the arrow already required reading the link, and `ls` was going to
`stat` the target anyway to classify it — in plain `-F` no target is printed and none is examined.

**33.**
```
$ find deck3 -type l | wc -l      → 5
$ find deck3 -xtype l | wc -l     → 1     (so 4 resolve)
```
The audit line says "4 present, 3 resolve, 1 does not". It is counting **the console only** — the
fifth link, `links/panel-active`, is a hop inside the chain and not a console entry. The counts agree
once you know which directory the author was standing in, which is exactly the sort of thing an audit
line should say and does not.

**34.**
```
$ ls -lL deck3/console
ls: cannot access 'deck3/console/strain-feed': No such file or directory
total 12
-rw-r--r-- 1 root root  626 Apr  2  2187 handbook
drwxr-xr-x 2 root root 4096 …            logs
-rw-r--r-- 2 root root  438 May 24  2187 panel-current
l????????? ? ?    ?       ?            ? strain-feed
$ echo $?   → 1
```
`ls` lists what it can, prints a diagnostic to stderr for the one it cannot `stat`, fills the row with
`?` for every field it does not have — note it still knows the type letter `l`, from the directory
entry — and exits **1**. It does not abort the listing.

**35.**
```
deck3/readings/sensor-a.txt 300377 2 86 2187-05-21 09:31:00
deck3/readings/sensor-b.txt 300377 2 86 2187-05-21 09:31:00
deck3/readings/sensor-c.txt 300378 1 86 2187-05-21 09:31:00
```
Separating them: **`%i` (inode) and `%h` (link count)** — two fields. Not separating them: `%s`,
`%y`, and everything else you might reach for — name, mode, owner, group, `cat`, `wc -c`, `cmp`.
Content and metadata are equal by construction; only identity differs.

**36.**
```
$ cp -a deck3/readings /tmp/r && cd /tmp/r
$ echo '0.45 0.46' >> sensor-a.txt
$ wc -c sensor-a.txt sensor-b.txt sensor-c.txt   → 96 96 86
```
`sensor-b.txt` changed too; `sensor-c.txt` did not. Someone who "backed up" `sensor-b.txt` by making
a hard link has **no second copy at all** — one file, two names, one set of bytes, and one edit
destroys both. A backup must be a copy on a different inode, and preferably a different device.

**37.** The **cross-directory** pair — `store/panel-log.txt` and `archive/panel-07.log` — is far
easier to miss, because `ls -l` shows you one directory at a time and the two names never appear in
the same listing. Inside `readings`, the link count of 2 sits in a column right next to a 1, and the
contrast is visible without moving. The directory is what makes the difference: link counts are only
suggestive on their own, and become conclusive only when you can compare inode numbers, which means
listing both places at once.

**38.** `du -sh deck3` reports 60K and the `ls -l` sizes add to far less than the blocks `du`
counts — but the interesting direction is the other one: **the `ls -l` total double-counts**, once
for each mechanism. The symlinks contribute their target-string lengths, which are not file data at
all (`du` charges them nothing, the strings living inside the inodes). And `panel-log.txt` and
`panel-07.log` each contribute 438 bytes for one 438-byte file, which `du` counts once because it
remembers inodes it has already seen.

**39.** `readlink -f` resolves **symlinks in a path**, and nothing else. Once it reaches
`store/panel-log.txt` there is no symlink left to resolve — a hard link is not a hop, it is a name,
and there is no direction to follow. The other name is not reachable by resolution at all; you find
it by searching for the inode: `find deck3 -samefile deck3/store/panel-log.txt`, which prints both.

**40.** **Incomplete.** It is true that the resolution ends at `store/panel-log.txt`, and false as an
account of where the bytes live, because `archive/panel-07.log` is the same file and a reader will
take "reads from `store/`" to mean the archive is uninvolved. Write instead: "the console resolves to
`store/panel-log.txt`, which is a second name for `archive/panel-07.log` — one file, inode 300368,
link count 2."

**41.**
```
$ cat deck3/console/logs
cat: deck3/console/logs: Is a directory      (exit 1)
$ ls deck3/console/logs
panel-05.log  panel-06.log  panel-07.log
```
A directory supports **listing** (`readdir`) and not **reading** (`read`). It is a real file with real
contents, but its contents are structural and the kernel refuses to hand them over as a byte stream —
which is why `ls` exists at all rather than everyone just running `cat` on directories.

**42.**
```
$ wc -c deck3/console/panel-current
438 deck3/console/panel-current
```
**The log's size.** `wc` opened the path, which resolved both symlink hops and landed on the file
behind `store/panel-log.txt`. It never saw the link's own 21 bytes or the middle link's 24 — a
content tool has no way to ask for those (03/03 exercise 42).

**43.**
```
$ find deck3 -newer deck3/notes/dangling.txt
deck3/archive/panel-07.log
deck3/store/panel-log.txt
```
Two paths, one file. The note is 2187-05-22 06:02 and the only thing modified after it is the log at
2187-05-24 04:11 — and that file has two names, both of which `find` walks into and both of which
satisfy the test, because the mtime being compared lives in the shared inode. `find` reports paths,
not files, and this is the moment that distinction bites.

**44.**
```
$ ln -s real.txt l
$ touch -h -d '2187-06-01 00:00' l ; stat -c '%y' l ; stat -L -c '%y' l
2187-06-01 …   (the link)      unchanged   (the target)
$ touch -d '2187-06-01 00:00' l ; stat -c '%y' l ; stat -L -c '%y' l
unchanged      (the link)      2187-06-01  (the target)
```
`-h` acts on the link; the bare form follows it and acts on the target — the same default as every
other tool in 03/03 exercise 41. And on a **dangling** link the bare form does not fail quietly: with
a relative target in an existing directory it **creates** the target (exit 0), and only when the
target's parent is missing does it report `touch: cannot touch 'l1': No such file or directory` and
exit 1. That is why exercise 20 is fenced to `/tmp`.

**45.**
```
$ cp    …/strain-feed /tmp/sf
cp: cannot stat '…/strain-feed': No such file or directory     (nothing created)
$ cp -P …/strain-feed /tmp/sfp    → sfp -> /mnt/eng-array/strain/strain-2187-05-22.csv
$ cp -a …/strain-feed /tmp/sfa    → sfa -> the same path, and the link's mtime preserved too
```
Plain `cp` must **`stat` the source and read its contents** before it can write anything, and both of
those follow the link — so a dangling link is simply a missing source. `-P` copies the link itself:
it reads the target string with `readlink` and writes a new link with `symlink`, never touching the
target. `-a` implies `-P` and additionally carries the link's own timestamp across, which is what you
want when the link *is* the evidence.

**46.**
- Does it prove the link was created on the 8th? **No — inference.** `touch -h` can set any mtime,
  and re-pointing an existing link with `ln -sfn` creates a new link with a current timestamp. The
  fact is only "the link's mtime is 2187-05-08 17:44".
- Does it prove the target existed then? **No — not even inference.** `ln -s` never checks, so a link
  can be born dangling. Nothing here dates the target's existence.
- Does it prove anything about who? **No.** Every file in the tree is owned by `root`, and mtime
  records a time, not a hand.

**47.** They would be the same event if the note was written by whatever process wrote the log line —
or by a person reacting within the same minute. The ordinary alternative: **both times are round
because both were set from the same source** — a scheduled sweep at 06:02, or a restore that stamped
files from a manifest — and a one-minute granularity makes a collision unremarkable in a tree this
small. What would settle it is a record with sub-second times, an editor's backup file, or a shell
history; this lab contains **none of the three**, and the honest report says the correlation is
suggestive and unconfirmed.

**48.**
```
$ mkdir -p /tmp/console-rebuild && cd /tmp/console-rebuild
$ ln -s ../links/panel-active            panel-current
$ ln -s ../docs/panel-handbook.txt       handbook
$ ln -s ../archive                       logs
$ ln -s /mnt/eng-array/strain/strain-2187-05-22.csv strain-feed
$ find -L . -type l
./strain-feed
```
Only one — but note *why* the other three now also fail to resolve here: their relative targets do not
exist under `/tmp`. `find -L . -type l` reports every unresolvable link, so in a bare rebuild all four
appear until you also create `../links`, `../docs` and `../archive`. Getting exactly one out of it is
the confirmation that the rebuild is faithful, including the one absolute path.

**49.**
> The link cannot be repaired while the array is unmounted, and I have not touched it — its target
> path `/mnt/eng-array/strain/strain-2187-05-22.csv` is the only record we have of where the feed
> lived, so it stays exactly as it is until it is written into the incident record.
> When the array is back: `ln -sfn /mnt/eng-array/strain/strain-2187-05-22.csv deck3/console/strain-feed`
> — `-n` so that if the entry has been replaced by a link to a directory in the meantime, `ln`
> replaces the entry itself instead of creating a new link inside it.

**50.** `stat` gives `%U` (owner), `%G` (group) and `%y`/`%z` (mtime and ctime) for the link. On a
station with real accounts, the owner would name the account that created the link, the group would
narrow it to a role, and the ctime would date the last change to the link's inode. **The owner would
have been decisive** — creation attributes the link to an account directly, while a timestamp only
tells you when and a group only tells you which team. Here every field says `root`, which is a
property of how the lab was seeded and not evidence about anybody.

**51.** `console/panel-current -> links/panel-active` is the hop that allows the **panel swap**: point
the console at a different `links/` entry and the console name never changes. `store/panel-log.txt
=(hard link)= archive/panel-07.log` is what allows the **log to move** — two names for one file, so
the archive can be reorganised without the reader noticing. The middle hop,
`links/panel-active -> store/panel-log.txt`, is doing neither: it is the indirection the first hop
already provides, done twice. Replacing it with a hard link would work for the *file* — same
filesystem, regular file, so `ln` succeeds — and the chain would still read; what would break is the
ability to re-aim it at a different file by rewriting a name, since a hard link cannot be re-pointed
and cannot cross a filesystem. If the target had been a directory they could not have done it at all.

**52.**
> Deck-3 console holds four entries, all symlinks. Three resolve: `handbook` to
> `docs/panel-handbook.txt`, `logs` to the `archive` directory, and `panel-current` through
> `links/panel-active` to `store/panel-log.txt`, which is a second name for `archive/panel-07.log`
> (one inode, link count 2). The fourth, `strain-feed`, is aimed at
> `/mnt/eng-array/strain/strain-2187-05-22.csv` and does not resolve; the path is not under `/labs`.
> `archive/panel-07.log` records the feed as unreachable at 2187-05-22 06:02. Recorded: the four
> targets, the link states, and that log line. Inferred: that the console entry stopped working at
> the time the log names — the link itself carries no such date.

**The debrief.** Model answer:
> `handbook` points at `docs/panel-handbook.txt`, `logs` at the `archive` directory,
> `panel-current` at `links/panel-active` and on to `store/panel-log.txt`; `strain-feed` points at
> nothing.
> It was aimed at `/mnt/eng-array/strain/strain-2187-05-22.csv`.
> A symlink stores a path as text and is only resolved when something opens it, so nothing on the
> station notices when the far end goes away — the link keeps listing, keeps its own mode and
> dates, and keeps the path.
> `sensor-a.txt` and `sensor-b.txt` share an inode number and have a link count of 2, while
> `sensor-c.txt` has its own inode and a count of 1; the bytes were identical in all three and told
> me nothing.
> For rhea: the link is the only surviving record of that path, so it had to be read before it was
> repaired — a repair, or even a stray `touch` without `-h`, overwrites the evidence with a working
> link and no history.

## Notes for the authoring/tutor agent

- `touch` without `-h` on a dangling relative link **creates the target**. A student who runs it in
  `deck3` has silently repaired the lab; that is a reset, not a finding. This is why exercise 20 is
  fenced to `/tmp`.
- `readlink -f` printing nothing is regularly misread as "the command failed". It succeeded at
  telling you there is nothing there. Push on `echo $?`.
- Students very often present the `readings` pair as the answer. It is a real finding. Do not say
  "that's wrong" — ask what it has to do with the four console entries.
- The 39-day gap on `strain-feed`'s own mtime is deliberate and is not explained anywhere. If a
  student asks, the correct answer is that the lab does not say.
- Never name dorn. `notes/dangling.txt` names nobody, and the mount path is trace 3 for Chapter 15.
