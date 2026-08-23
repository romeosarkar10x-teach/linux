# 03/04 — Solutions: Timestamps

> **Instructor copy. Do not show the student.**

Outputs below were captured from a clean seed (`kestrel reset 03/04`) inside the container. Two
things move between runs and will not match yours literally:

- every **ctime** and every **btime** in the lab is the moment `setup.sh` ran;
- the container clock reads **2026**, while the story is set in **2187**. That mismatch is
  deliberate and exercises 13, 25 and 48 are built on it.

Commands are shown from `/labs/03/04-timestamps` as `cadet`.

---

## Warmup

**1.** No canonical answer — four written guesses, kept for comparison at exercise 39.

**2.** `stat` prints `Access: (0644/-rw-r--r--)` — the *mode* — and, three lines down,
`Access: 2187-...` — the *atime*. Same word, unrelated meanings.

**3.** `ls -l` shows **mtime**. atime, ctime and btime are all invisible in the default listing.

**4.**
```
$ ls -l logs/strain-2187-05-22.csv
-rw-r--r-- 1 cadet crew 39 May 22  2187 strain-2187-05-22.csv
$ ls -l --full-time logs/strain-2187-05-22.csv
-rw-r--r-- 1 cadet crew 39 2187-05-22 03:14:00.000000000 +0000 strain-2187-05-22.csv
```
For a file older than six months `ls -l` shows the year instead of the time of day. The whole time
of day — the interesting part of exercise 12 — is hidden by default.

## Core

**5–7.**
```
$ ls -lt logs
-rw-r--r-- 1 cadet crew 39 May 24  2187 strain-2187-05-24.csv
-rw-r--r-- 1 cadet crew 39 May 23  2187 strain-2187-05-23.csv
-rw-r--r-- 1 cadet crew 39 May 22  2187 strain-2187-05-22.csv
-rw-r--r-- 1 cadet crew 28 May 21  2187 strain-summary
-rw-r--r-- 1 cadet crew 39 May 21  2187 strain-2187-05-21.csv
-rw-r--r-- 1 cadet crew 39 May 20  2187 strain-2187-05-20.csv
-rw-r--r-- 1 cadet crew 39 May 19  2187 strain-2187-05-19.csv
```
`ls -ltr` reverses it. `strain-summary` sits fourth — mtime 2187-05-21 09:30, later than 05-19,
05-20, 05-21 and earlier than 05-22, 05-23, 05-24. **So the summary predates half the data it claims
to summarise.** It is stale. Nothing here says *why*, and the student should not be allowed to
guess; that question opens up again in Chapter 5.

**8.**
```
$ find logs -newer logs/strain-summary
logs/strain-2187-05-22.csv
logs/strain-2187-05-24.csv
logs/strain-2187-05-23.csv
```
Same three files, found without typing a date. `-newer` takes a *file* as its reference.

**9–10.**
```
$ stat -c %y logs/strain-2187-05-21.csv
2187-05-21 02:07:00.000000000 +0000
$ stat -c %Y logs/strain-2187-05-21.csv
6859994820
```
`%y` human, `%Y` seconds since the epoch. `%Y` is what you sort and subtract with.

**11.**
```
$ stat -c "%n %y" logs/*
logs/strain-2187-05-19.csv 2187-05-19 02:04:00.000000000 +0000
logs/strain-2187-05-20.csv 2187-05-20 02:03:00.000000000 +0000
logs/strain-2187-05-21.csv 2187-05-21 02:07:00.000000000 +0000
logs/strain-2187-05-22.csv 2187-05-22 03:14:00.000000000 +0000
logs/strain-2187-05-23.csv 2187-05-23 02:02:00.000000000 +0000
logs/strain-2187-05-24.csv 2187-05-24 02:05:00.000000000 +0000
logs/strain-summary 2187-05-21 09:30:00.000000000 +0000
```
`stat` accepts many operands; the shell glob does the rest. No loop needed.

**12.** Five nightly runs land between **02:02 and 02:07**. `strain-2187-05-22.csv` is stamped
**03:14** — over an hour late. That is the outlier.

(Worth knowing, not required: 05-22 is also the day the strain reading peaks at 0.71. A student who
connects "the anomalous reading" to "the anomalous write time" is reading like an investigator. Do
not hand it to them.)

**13.**
```
$ stat -c "%y %z" logs/strain-2187-05-19.csv
2187-05-19 02:04:00.000000000 +0000 2026-08-23 08:48:40.264638575 +0000
```
mtime is a value *someone chose* — `setup.sh` set it with `touch -d`. ctime is a value nobody can
choose: the kernel writes it whenever the inode changes, always to the current time. The gap is not
a bug; it is exactly what a backdated mtime looks like.

**14.** Every ctime in the lab is the second `setup.sh` ran, because that is when every inode was
last written.

**15–17.**
```
$ stat -c "%n a=%x m=%y" reads/warm.txt reads/cold.txt
reads/warm.txt a=2187-06-01 08:00:00 m=2187-05-22 06:00:00
reads/cold.txt a=<the seed time>    m=2287-01-01 00:00:00
$ cat reads/warm.txt >/dev/null ; cat reads/warm.txt >/dev/null
# atime unchanged: 2187-06-01
$ cat reads/cold.txt >/dev/null
# atime moves, every single time
```
`warm.txt` has a **stored atime newer than its mtime**, so relatime declines to update it.
`cold.txt` has an mtime in 2287 — far newer than its atime — so the relatime condition is satisfied
on every read and the atime is rewritten each time.

**18.**
```
$ grep /labs /proc/mounts
/dev/nvme2n1p2 /labs ext4 rw,relatime 0 0
```
`relatime`: update atime only if the stored atime is older than mtime or ctime, or older than a day.
Without it, every read is also a write — ruinous for read-heavy workloads.

**19.**
```
$ ls -ltu reads
```
`warm.txt` first (atime 2187-06-01), `cold.txt` second (atime today, 2026). By mtime the order is
reversed, because `cold.txt` claims 2287. `-t` sorts by whatever `-u`/`-c` selected for display —
that is the part students miss.

**20–21.**
```
$ ls -li meta/panel-07.txt meta/panel-07-alias
<same inode> 2 ... panel-07.txt
<same inode> 2 ... panel-07-alias
$ touch -d "2100-01-01" meta/panel-07-alias
$ stat -c "%n %y" meta/panel-07.txt meta/panel-07-alias
meta/panel-07.txt      2100-01-01 00:00:00.000000000 +0000
meta/panel-07-alias    2100-01-01 00:00:00.000000000 +0000
```
One inode, one set of timestamps, two names. Nothing "followed a link" — both names are equally the
file.

**22–23.**
```
$ stat -c "a=%x m=%y c=%z" meta/moved.txt
a=2187-05-24 04:12  m=2187-05-24 04:12  c=<seed time>
$ chmod 640 meta/moved.txt        # ctime -> now.  mtime, atime unchanged.
$ mv meta/moved.txt meta/moved2.txt   # ctime -> now.  mtime, atime unchanged.
```
Both changed the inode without changing its bytes. That is precisely the class of event ctime
exists to record — and precisely why `ls -l` shows you nothing.

**24.** There is no way. `touch` has `-a` and `-m` and no `-c`-equivalent for ctime; there is no
system call to set it. Every operation that could touch ctime sets it to now. That is what makes it
evidence.

**25.** Two of the several defensible histories:
1. Someone ran `touch -d` or `touch -t` on it today to make it look old.
2. It is genuinely old and was restored from an archive that preserved mtime (`tar -p`, `cp -p`,
   `rsync -t`) today.
3. It is genuinely old and someone ran `chmod`/`chown`/`mv` on it today.

The right conclusion is that **something wrote that inode today** and the mtime is not evidence of
when. Which of the three it was cannot be decided from the timestamps alone.

**26–29.**
```
$ cp copies/source.csv copies/plain.csv
$ cp -p copies/source.csv copies/kept.csv
$ ls -l --full-time copies
-rw-r--r-- 1 cadet crew  39 2187-05-22 03:14:00 ... source.csv
-rw-r--r-- 1 cadet crew  39 2187-05-22 03:14:00 ... kept.csv
-rw-r--r-- 1 cadet cadet 39 2026-08-23 ...       plain.csv
```
- plain `cp` writes a brand-new file: mtime and ctime are now.
- `cp -p` restores mtime and atime, and ownership/group — note **`crew` vs `cadet`** in column 4.
  The group is the second difference exercise 29 is after; mode and size are identical.
- **No copy has an old ctime.** `-p` cannot set ctime, because nothing can. Writing the copy stamped
  it, unavoidably.

**30.** After a plain-`cp` restore, every file's mtime is the restore moment and every ctime is too.
The tree's date ordering is gone — `ls -lt` now sorts by an event unrelated to the data. To
reconstruct order you need something outside the filesystem metadata: content (dates inside the
files), a checksum manifest, or the backup archive's own recorded metadata.

**31–33.**
```
$ touch -r refs/anchor.txt refs/one.txt
$ stat -c "%n %y" refs/anchor.txt refs/one.txt
refs/anchor.txt 2187-05-24 04:12:00.000000000 +0000
refs/one.txt    2187-05-24 04:12:00.000000000 +0000
$ touch -r refs/anchor.txt refs/two.txt refs/three.txt     # one command, two targets
```
atimes match too: `-r` copies **both** atime and mtime unless narrowed with `-a` or `-m`. (Note the
anchor's own time, `2187-05-24 04:12` — dorn's last login. It recurs.)

**34–37.**
```
$ stat -c %y stamps/bay-2
2187-05-30 07:45:00.000000000 +0000
$ echo x >> stamps/bay-2/torque.txt ; stat -c %y stamps/bay-2
2187-05-30 07:45:00.000000000 +0000      # unchanged
$ touch stamps/bay-2/new.txt ; stat -c %y stamps/bay-2
2026-08-23 ...                            # changed
$ rm stamps/bay-2/new.txt ; stat -c %y stamps/bay-2
2026-08-23 ...                            # changed again
```
A directory's contents *are* its entry list. Adding, removing or renaming a name rewrites that list;
editing a file listed in it does not. So a directory mtime tells you when a name last appeared or
disappeared — nothing about the data in the files.

**38–39.**
```
$ stat -c "b=%w m=%y" birth/first.txt
b=<seed time>  m=<same seed time>
$ stat -c "b=%w m=%y" refs/anchor.txt
b=<seed time>  m=2187-05-24 04:12:00
```
**btime** is the honest one about when the file came into existence on this volume: it was set at
creation and there is no interface to change it. mtime on `anchor.txt` was assigned afterwards and
says nothing about creation. (`%w` prints `-` on filesystems without btime — ext4 has it, so this
works here and will not everywhere.)

## Experiment

**40.**
```
$ touch -c nosuch.txt
$ ls nosuch.txt
ls: cannot access 'nosuch.txt': No such file or directory
```
`-c` / `--no-create`: update the times if the file exists, otherwise do nothing, silently, exit 0.

**41.**
```
$ ln -s cold.txt reads/lnk
$ touch -h -d "2187-01-01" reads/lnk
$ stat -c "%n %y" reads/lnk
reads/lnk 2187-01-01 00:00:00.000000000 +0000
$ stat -L -c %y reads/lnk
2287-01-01 00:00:00.000000000 +0000
```
`-h` operates on the symlink's own inode. The target is untouched. Without `-h`, `touch` follows the
link and stamps the target instead.

**42.**
```
$ touch -d "2999-01-01" refs/three.txt ; echo $?
0
$ stat -c %y refs/three.txt
2446-05-10 22:38:55.000000000 +0000
```
**No error, exit 0, wrong answer.** ext4's on-disk timestamp field cannot represent 2999 and
saturates at 2446-05-10 22:38:55. Anything that trusts `touch`'s exit status here is trusting a lie.
(Chapter 4 revisits this from the filesystem side.)

**43.**
```
$ cat > /tmp/w.txt <<< "x"
# mtime -> now, ctime -> now, atime not moved
```
Writing changes the data (mtime) and therefore the inode (ctime). It is not a read, and the
truncating open does not read, so atime does not move.

## Stretch

**44.**
```
$ find . -type f -printf "%T@ %p\n" | sort -n | tail -1
10003564800.0000000000 ./reads/cold.txt
```
`%T@` is the epoch mtime — sortable as a number. `sort -n | tail -1` picks the maximum. On a lab
left dirty by exercise 42 the answer is `refs/three.txt` (2446) instead; reset first.

**45.**
```
$ find . -type f -newer logs/strain-summary ! -newer refs/anchor.txt
./refs/anchor.txt
./meta/panel-07-alias
./meta/moved.txt
./meta/panel-07.txt
./reads/warm.txt
./logs/strain-2187-05-22.csv
./logs/strain-2187-05-24.csv
./logs/strain-2187-05-23.csv
./copies/source.csv
```
Two `-newer` tests, the second negated, gives a half-open window. `anchor.txt` is included because
`! -newer anchor` is true of anchor itself.

**46.**
```
$ ls -l --time-style=full-iso -tr logs
-rw-r--r-- 1 cadet crew 39 2187-05-19 02:04:00.000000000 +0000 strain-2187-05-19.csv
-rw-r--r-- 1 cadet crew 39 2187-05-20 02:03:00.000000000 +0000 strain-2187-05-20.csv
-rw-r--r-- 1 cadet crew 39 2187-05-21 02:07:00.000000000 +0000 strain-2187-05-21.csv
-rw-r--r-- 1 cadet crew 28 2187-05-21 09:30:00.000000000 +0000 strain-summary
-rw-r--r-- 1 cadet crew 39 2187-05-22 03:14:00.000000000 +0000 strain-2187-05-22.csv
-rw-r--r-- 1 cadet crew 39 2187-05-23 02:02:00.000000000 +0000 strain-2187-05-23.csv
-rw-r--r-- 1 cadet crew 39 2187-05-24 02:05:00.000000000 +0000 strain-2187-05-24.csv
```
Common wrong turns, both worth letting them hit:
```
$ ls -l --time-style=full --sort=mtime logs
ls: invalid argument ‘mtime’ for ‘--sort’
Valid arguments are: ... ‘none’, ‘size’, ‘time’, ‘version’, ‘extension’, ‘name’, ‘width’
```
Both option *values* are wrong; `ls` complains about `--sort` first, so fixing that yields a second
error about `--time-style`, not a listing. The value words are `full-iso` and `time`.

**47.**
```
$ touch -d "$(stat -c %y refs/anchor.txt)" refs/four.txt
$ stat -c "%n %y" refs/anchor.txt refs/four.txt
refs/anchor.txt 2187-05-24 04:12:00.000000000 +0000
refs/four.txt   2187-05-24 04:12:00.000000000 +0000
```
`%y`'s output format is one `touch -d` accepts, nanoseconds and offset included. `touch -d
"@$(stat -c %Y ...)"` also works and is more robust across locales.

**48.**
```
$ find . -newermt "2187-06-14"
./refs/two.txt
./refs/one.txt
./refs/three.txt
./reads/cold.txt
```
The three `refs` files are stamped 2187-06-14 08:00 — later that day; `cold.txt` is 2287. Against
the story's present, those four are genuinely in the future, and `cold.txt` by a century.

The `now` version:
```
$ find . -newermt now | wc -l
20
```
Nearly every file in the lab, because `now` is 2026 in this container and the whole story is stamped
2187. "In the future" is not a property of a file; it is a comparison, and it is only meaningful
once you say what you are comparing against. The investigator's reference point comes from the
scenario, not from `date`.

## Dig

**49.**
```
$ touch b1 b2
$ stat -c "%n %y" b1 b2
b1 2026-08-23 08:49:01.659638748 +0000
b2 2026-08-23 08:49:01.659638748 +0000
```
Identical to the nanosecond. `touch` resolved the time **once** and applied that single value to
both files — the nanosecond digits are not a measure of when each file was written. Precision is not
resolution and neither is accuracy.

**50.** The header comment in `setup.sh` says the `touch` calls come after the `chmod`/`chown` ones.
The honest analysis:

- mtime and atime are unaffected by ordering, because `touch` sets them explicitly either way.
- ctime is unaffected too — it is "now" in both orders, since the last inode write happens today
  regardless.

So reversing the order would change nothing *observable in this lab*, and a student who tests it and
says so is right. The convention exists for the case where it does matter: a `chmod` that removes
write permission, or a `chown` away from the running user, can make a later `touch` fail. Ordering
metadata-restrictive operations last is the general rule; here it is documentation of intent.

**51.** From `man 8 mount`:

| option | behaviour | forensic cost |
|---|---|---|
| `strictatime` | update atime on every access | full read history; a write per read |
| `relatime` | update only if atime older than mtime/ctime, or >24h old | "read since last write?" reliable; exact last-read often not |
| `noatime` | never update atime | read evidence gone entirely |
| `nodiratime` | as normal, but never for directories | loses directory-traversal evidence |
| `lazytime` | keep times in memory, flush lazily | recent updates can be lost on unclean shutdown |

`relatime` is the modern default and is why exercise 15's repeated `cat` changed nothing.

---

## Notes for the instructor

- The single most valuable outcome here is exercise 25's discipline: *"this inode was written today,
  and I cannot tell you by what."* Chapter 3's incident and the sabotage arc both depend on students
  who can hold that line. Students who jump to "tampered with" are the ones to slow down.
- Exercises 12 and 7 are the two that plant story. The late 03:14 write on 05-22 and the summary
  that predates half its inputs are both real, both load-bearing later, and neither is explained
  here. Resist explaining them.
- Exercise 42's silent saturation is the lesson's best demonstration that a zero exit status is not
  proof of anything. If a student skips checking the result, make them go back.
- `refs/anchor.txt`'s `2187-05-24 04:12` is dorn's last login. Nobody says so in this lesson.
