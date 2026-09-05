# 04/02 — Solutions (agent eyes only)

> **Student: do not open this file.** Every answer is here, including the brace expressions the
> lesson exists to make you derive.

## The shape of the lab

- `spec/deck-tree.txt` — the tree to build. deck-03: bays 01–04, three subdirectories each, plus
  `panel-07` and `panel-11` with `logs/` and `spares/`. deck-04: identical, **six** bays.
- `spec/naming-notes.txt` — states the two traps (two-digit bay numbers; six bays on deck-04) and one
  irrelevant-but-true fact (no panel-08/09/10) that exists to be quoted back in exercise 13.
- `existing/deck-03/` — `bay-01/readings/2187-05-17.txt` exists; **`bay-02` is a regular file**, which
  is what makes exercises 9 and 10 produce two different errors.
- `perms/`, `times/`, `build/` — student workspace. `times/anchor.txt` 2187-05-17 04:02:00,
  `times/one.txt` 2187-05-17 09:30:00, `times/two.txt` 2187-05-18 22:15:00.
- Container umask is **0022**.

**Directory counts (measured):** deck-03 subtree = **23**, deck-04 subtree = **31**,
`find build -type d | wc -l` after a complete build = **55** (54 plus `build` itself).

## Per exercise

**1.** `bay-01 bay-02 bay-03`; `bay-1 bay-2 bay-3 bay-4`; `bay-01 bay-02 bay-03 bay-04 bay-05
bay-06`. Padding is decided by the width of the **first** element as written; `{01..06}` pads to two,
`{1..6}` does not. The upper bound has no say.

**2.** Eight words: 2 × 4. `deck-03/bay-01 … deck-04/bay-04`.

**3.** `echo bay-{01}` → `bay-{01}`. A brace group with neither a comma nor a `..` is not a brace
expansion, and the braces survive into the argument. `echo bay-{01,}` → `bay-01 bay-` — one comma is
enough to make it an expansion, and the empty alternative expands to nothing.

**4.** `mkdir: cannot create directory ‘build/one/two’: No such file or directory`, exit 1.
`mkdir -p` → exit 0. Second `mkdir -p` → exit **0** again. That second zero is the idempotence.

**5.**
```
mkdir: created directory 'build/a'
mkdir: created directory 'build/a/b'
mkdir: created directory 'build/a/b/c'
```
Three.

**6.** `bay-01/` has the `/` suffix from `-F`; `bay-02` has none, so it is a regular file.

**7.** `mkdir: cannot create directory ‘existing/deck-03/bay-01’: File exists`, exit 1.

**8.** Exit 0. `-p` treats "already a directory" as success rather than as an error.

**9.** `mkdir: cannot create directory ‘existing/deck-03/bay-02’: Not a directory`, exit 1. Different
because the obstruction is not the target itself but a *component of the path*, and it is a file, so
`mkdir` cannot descend through it. Note `mkdir` names `bay-02`, not `bay-02/readings`.

**10.** `mkdir: cannot create directory ‘existing/deck-03/bay-02’: File exists`, exit 1. The target
exists but is not a directory, so `-p` does not apply.

**11.** `mkdir -p` exits 0 on an existing path **only if every component of it, including the last,
is already a directory** (and is reachable). Anything else is an error.

**12.** deck-03: 1 + 4 bays + 12 bay subdirectories + 2 panels + 4 panel subdirectories = **23**.
deck-04: 1 + 6 + 18 + 2 + 4 = **31**.

**13.** (a) bay numbers are two digits with a leading zero; (b) deck-04 has six bays, not four. Third
fact: panels are 07 and 11 only — there is no panel-08, 09 or 10, which matters because a student who
reaches for `panel-{07..11}` produces five panels.

**14.** `mkdir -p build/deck-03/bay-{01..04}/{readings,faults,handover}` → `find build -type d | wc -l`
gives 18 at this point (build, deck-03, 4 bays, 12 subdirectories).

**15.** `mkdir -p build/deck-03/panel-{07,11}/{logs,spares}`.

**16.** `mkdir -p build/deck-04/{bay-{01..06}/{readings,faults,handover},panel-{07,11}/{logs,spares}}`
— or the same thing as two words on one command line. Nested braces are legal and expand
outside-in.

**17.** **55.** A student who hand-counted 54 has the tree right and forgot that `find build` counts
`build`.

**18.** Every bay is two digits and there is no `panel-08`. If either is wrong, the cause is
`{1..4}`/`{1..6}` (no padding) or `panel-{07..11}` (a range where a list was wanted).

**19.** It creates `build/deck-03/bay-05` and `bay-06`, which do not exist on deck-03. The shape is
shared; the bay count is not. Two expansions, not one range widened to fit both.

**20.** 55 directories, matching `spec/deck-tree.txt` entry for entry.

**21.** `umask` → `0022`. `mkdir perms/plain` → `drwxr-xr-x`. Arithmetic: default directory mode 0777
minus the umask bits → 0777 & ~0022 = 0755.

**22.** `-rw-r--r--` = 0644. The default for files is 0666, not 0777, because the kernel never grants
execute on a newly created file; 0666 & ~0022 = 0644.

**23.** `perms/private` → `drwx------`. `perms/open` → **`drwxrwxrwx`**. The second is the proof: with
a umask of 0022 a plain `mkdir` cannot produce group- or other-write, so a mode given with `-m` is
applied **exactly, without the umask being subtracted**.

**24.** `mkdir perms/private2 && chmod 700 perms/private2`. In between, the directory existed at 0755
— world-readable and world-executable — so anything watching the parent directory could have entered
it and listed it during that window. `-m` closes the window by setting the mode at creation.

**25.** Only `perms/x/y/z` is 0700. `perms/x` and `perms/x/y` are `drwxr-xr-x`. Rule: under `-p`, `-m`
applies to the **final** component only; intermediate directories are created with the default mode
and the umask.

**26.** `rmdir: failed to remove 'perms/x': Directory not empty`. Then `rmdir -p perms/x/y/z` exits 0
— and it removed `y` and `x` as well, because it climbs upward removing each parent that is now
empty. The surprise for most students is that it did not stop at `z`. It stops at `perms` only
because `perms` still has other entries in it; on an otherwise empty lab it would have taken that
too.

**27.** `touch build/deck-03/bay-01/readings/2187-05-{01..30}.txt` → 30 files, mode `-rw-r--r--`,
same 0644 as exercise 22 — `touch` creates with 0666 and the umask subtracts.

**28.** `touch times/anchor.txt` sets atime and mtime to now; ctime moves too, because the inode
changed. `touch -c times/nothing-here.txt` does nothing, creates nothing, exits **0**. The file does
not appear.

**29.** `times/one.txt` gets 2187-05-17 04:02:00 — anchor's mtime. `-r` copies **both** atime and
mtime from the reference file, unless you narrow it with `-a` or `-m`.

**30.** `touch -a -d ...` moves atime to 2187-01-01 and leaves mtime at 2187-05-18 22:15. Then
`touch -m -d ...` moves mtime to 2187-02-02 and leaves atime at 2187-01-01. The one that moves
without being asked in either command is **ctime** — every one of these writes the inode, and ctime
is not settable. A student who only ran `stat -c %y` will not have seen it, which is the point.

**31.** `1 4 7 10` — a three-element range with a step, the step being the third field. `a b c d e`.
`file-a-1.txt file-a-2.txt file-b-1.txt file-b-2.txt file-c-1.txt file-c-2.txt` — six words, with the
**rightmost** group varying fastest.

**32.** Quoted: one directory named `a directory with spaces` under `build/`. Unquoted: **four**
arguments, so `mkdir` creates `build/a` and then `directory`, `with` and `spaces` in the *current*
directory, not under `build/`. Cleanup needs `rm -rf 'build/a directory with spaces'` and
`rm -rf directory with spaces` — three separate names.

**33.** One command line:
```
mkdir -p build/deck-03/{bay-{01..04}/{readings,faults,handover},panel-{07,11}/{logs,spares}} \
         build/deck-04/{bay-{01..06}/{readings,faults,handover},panel-{07,11}/{logs,spares}}
```
One `mkdir` invocation. `find build -type d | wc -l` → 55.

**34.** Any correct loop, e.g.
```
for d in 03 04; do
  case $d in 03) bays="01 02 03 04";; 04) bays="01 02 03 04 05 06";; esac
  for b in $bays; do for s in readings faults handover; do mkdir -p build/deck-$d/bay-$b/$s; done; done
  for p in 07 11; do for s in logs spares; do mkdir -p build/deck-$d/panel-$p/$s; done; done
done
```
Both defences are accepted. For the brace version: it is one line and there is nothing to get out of
step. For the loop: the differing bay counts are stated as data instead of hidden in the width of a
range, and it survives someone adding a deck. Reject only an answer with no reasoning.

**35.** `find build -type d -name readings -exec touch {}/.keep \;` — or with `-execdir`, or
`find ... -print0 | xargs -0 -I{} touch {}/.keep`. Ten `.keep` files (four bays on deck-03, six on
deck-04).

**36.**
```
$ printf '#!/bin/bash\nmkdir -p build/idem/a/b\n' > build/mk.sh; chmod +x build/mk.sh
$ for i in 1 2 3; do ./build/mk.sh; find build/idem | sort | md5sum; done
```
Three identical sums, three exit codes of 0. Without `-p`, the second run prints
`mkdir: cannot create directory ‘build/idem/a’: File exists` and exits 1 — which in a script with
`set -e` stops everything after it.

**37.** Two ways: `mkdir -- -tmp` (the `--` ends option parsing) and `mkdir ./-tmp` (the name no
longer *starts* with a dash). Removal has the identical problem: `rmdir -- -tmp` or `rmdir ./-tmp`.
Note the two fixes work at different layers — `--` is a convention `mkdir` implements, while `./` is
a fact about the path and needs no cooperation from the command at all. The second is the more
portable habit.

**38.** All three of 1971, 2187 and **1969** succeed; 1969 is before the epoch and stores as a
negative number of seconds, which the field is signed and therefore able to hold. Pushing the ends
(measured in this container's ext4):
```
touch -d 1901-01-01 f  -> 1901-12-13 20:45:52   (the 32-bit signed minimum)
touch -d 2500-01-01 f  -> 2446-05-10 22:38:55   (the ext4 maximum, met in Chapter 3 lesson 04)
```
Both exit 0. `touch` does not warn that it silently gave you a different date, which is the finding.

**39.** Measured:
```
$ e=$(mktemp -d); mkdir -p $e/a/b; chmod 500 $e/a/b; mkdir -p $e/a/b/c/d; echo $?
mkdir: cannot create directory ‘/tmp/tmp.XXXX/a/b/c’: Permission denied
1
$ find $e            ->  $e, $e/a, $e/a/b  — nothing new was created
```
It fails at the first component it has to create, `c`, and creates nothing. `-p` is not atomic in
general — if the failure had come later it would have left the earlier components behind — but here
there is nothing earlier to leave.

**40.**
```
$ cd $(mktemp -d); touch a1 a2
$ echo {a,b}*
a1 a2 b*
```
Brace expansion ran first, producing `a*` and `b*`; *then* globbing ran on each. `a*` matched two
files; `b*` matched nothing and, under bash's default `nullglob`-off behaviour, was left as the
literal text. If globbing had run first the `{a,b}` would still be braces in the output. General
rule: brace expansion is the **first** expansion the shell performs, before parameter, command,
arithmetic and pathname expansion — and it is purely textual, which is why it can produce names that
do not exist.

**41.** Concrete case: a directory that will hold private material, created on a shared filesystem by
a process that another user can watch. Between `mkdir` and `chmod` the directory is 0755, so that
user can `cd` into it and open anything already placed there — or, worse, keep an open file
descriptor or a hard link that survives the `chmod`, since permission is checked at open time.
For files, `touch` + `chmod` is worse: the file exists at 0644 and is readable immediately, and the
right answer is not `chmod` at all but creating it with the correct umask in force (or `install -m`),
because there is no `-m` on `touch`.

**42.** `ls -Z` prints `?` for every entry. `-Z` reports the SELinux (or SMACK) security context, and
this container has no LSM providing one, so there is no context to print. `mkdir -Z` and
`--context` exist for systems where a newly created directory would otherwise get a default context
that is wrong for its contents; here they are inert.

## Added exercises 43–52

**43.**

```
$ mkdir ok1 ok1 ok2
mkdir: cannot create directory ‘ok1’: File exists
$ echo $?
1
$ ls
ok1  ok2
```

`mkdir` processes operands left to right, independently. The failure on the second `ok1` does not
stop `ok2` from being created; the exit status is 1 because *at least one* operand failed. This is
the standard coreutils contract, and it means a non-zero status tells you something went wrong but
not how much got done.

**44.**

```
$ mkdir ""
mkdir: cannot create directory ‘’: No such file or directory
```

Status 1. The empty string is a legal C string but never a legal pathname, so `mkdir("")` returns
`ENOENT` — "no such file or directory" — which is what the kernel says about a path that resolves to
nothing. The message reads as though something is missing; what is missing is the path itself.

**45.**

```
$ rmdir k
rmdir: failed to remove 'k': Directory not empty
$ echo $?
1
$ rmdir --ignore-fail-on-non-empty k
$ echo $?
0
```

The second form does not remove anything — it suppresses only the non-empty failure, which is what
makes it usable in cleanup scripts. `rmdir -p k/l/m` then removes `m`, `l` and `k` in that order and
stops when it runs out of components; `ls k` afterwards gives
`ls: cannot access 'k': No such file or directory` with status 2. Unlike exercise 26 there is nothing
non-empty left behind at any level, so the climb goes all the way to the top of the path it was
given — and no further, because `-p` climbs the *operand*, not the filesystem.

**46.**

```
$ mkdir -p x/y/../z
$ find x -type d | sort
x
x/y
x/z
```

Three directories, and `x/y` exists even though nothing in the final path names it. `mkdir -p` walks
the components left to right and creates each one that is missing, so it created `x`, then `x/y`,
then applied `..` to step back to `x`, then created `z`. It did not canonicalise the path first — if
it had, `x/y` would never have existed. Real scripts hit this when a variable expands to a path with
a `..` in it and leaves a stray directory behind.

**47.** `touch -h` changes the timestamps of the **symlink itself**; without `-h`, `touch` follows the
link and stamps the target.

```
$ touch -h -d '2187-01-01' build/link-to-anchor
$ stat -c '%y %n' build/link-to-anchor times/anchor.txt
2187-01-01 00:00:00.000000000 +0000 build/link-to-anchor
2187-05-17 04:02:00.000000000 +0000 times/anchor.txt
```

The target is untouched. The plain form would have set `times/anchor.txt` to 2187-01-01 and left the
link's own mtime alone — which is why `-h` exists at all: a link's timestamps are otherwise almost
unreachable. (Chapter 3 lesson 06 used the same distinction on dangling links.)

**48.** Status **0**. `mkdir -p` on a symlink that points at an existing directory succeeds, because
`-p`'s test is "does the path already resolve to a directory", and a symlink to a directory does.
Exercise 10's `bay-02` failed because it resolves to a regular file. The refined rule:

> `mkdir -p PATH` exits 0 when every component of PATH either exists as a directory (after symlink
> resolution) or can be created; it fails only when a component exists and is *not* a directory.

**49.**

```
drwx------ … m1
-rw------- … m2
```

`0777 & ~077 = 0700` for the directory and `0666 & ~077 = 0600` for the file — the file never gets
the execute bits regardless of the umask, which is the exercise 22 point again. The parentheses
matter because `umask` is a shell builtin that changes the *shell's* state: run without a subshell it
would persist for the rest of the session and quietly change the mode of everything you created
afterwards.

**50.**

```
$ echo a{b,{c,d}}e
abe ace ade
$ echo x{,,}
x x x
$ echo pre{}post
pre{}post
$ echo {1..10..3}
1 4 7 10
```

Nested braces expand outwards then inwards, so the inner list is flattened into the outer one.
`x{,,}` has three empty alternatives and so produces the word three times — empty is a legal
alternative. `{}` is **not** an expansion: brace expansion needs either a comma or a `..` range
inside, so `pre{}post` is left completely alone and passed through literally (this is why `find -exec
… {} \;` works unquoted). `{1..10..3}` steps by 3 and stops at 10 because 10 is on the step;
`{1..10..4}` would stop at 9.

**51.**

```
$ stat -c '%x|%y|%z|%w' times/anchor.txt
2187-05-17 04:02:00…|2187-05-17 04:02:00…|<now>|<creation time>
```

After a `touch -d`, mtime moves to the value you asked for and **ctime** moves to *now* — you cannot
set the change time, because it records when the inode last changed, and setting the mtime is itself
a change to the inode. The birth time `%w` does not move either; on this ext4 filesystem it is
recorded once at creation and never updated. That is exactly why ctime is the useful field in a
forensic reading: mtime and atime are attacker-writable with a one-line `touch`, ctime is not, and a
file whose mtime is older than its ctime has had its timestamps set by hand.

**52.**

```
$ touch -t 218705170402.30 build/stamped.txt
$ stat -c '%y' build/stamped.txt
2187-05-17 04:02:30.000000000 +0000

$ touch -t 2187-05-17 build/bad
touch: invalid date format ‘2187-05-17’      # status 1
$ touch -d 'not a date' build/bad2
touch: invalid date format ‘not a date’      # status 1
```

`-t` takes digits only, no separators, so an ISO date is not a valid `-t` argument even though it
looks like a date — the same string is fine after `-d`. `touch -d @0` sets 1970-01-01 00:00:00 UTC
and `touch -d yesterday` sets this time on the previous day.

For a script on someone else's machine: `@seconds`. It has no locale, no timezone and no ambiguity
about `05/06`, and it is the only one of the four whose meaning cannot change under `LC_TIME` or
`TZ`. `-t` is next best; the English phrases are convenient at a prompt and a liability in a script.

## Notes for the authoring/tutor agent

- Exercises 9 and 10 must be run in that order. Doing 10 first spoils the distinction.
- `rmdir -p` in exercise 26 will happily eat `perms/` if the student has emptied it. That is correct
  behaviour, not a broken lab; `kestrel reset 04/02` restores.
- Exercise 33's `find` count is 55 only if `build/` was emptied first. If a student's number is 85 or
  so, they still have exercise 27's thirty `.txt` files — those are files, not directories, so the
  count is unaffected; a wrong count means leftover *directories*, most often from exercise 32.
- No flag in this lesson. The chapter's only flag is in `05-incident-04`.
