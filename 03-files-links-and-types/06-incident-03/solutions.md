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

**28.** Model debrief:
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
