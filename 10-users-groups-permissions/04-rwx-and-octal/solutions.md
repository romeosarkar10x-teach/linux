# 10/04 — Solutions

Do not read this until you have written your own answers.

---

**1.** `-rw-r--r--`. Character 1: the file type. 2–4: what the owner may do. 5–7: what a member of the
file's group may do. 8–10: what everybody else may do.

**2.** The first. `-` ordinary file, `d` directory, `l` symlink. (`c`, `b`, `s` and `p` exist too and
you will meet the first two in chapter 12.)

**3.** `d`. All three are directories.

**4.** `ls -l notes/` lists what is *inside* `notes`; `ls -ld notes/` describes `notes` itself. `-d`
tells `ls` to treat a directory as the thing being asked about rather than as a place to look.

**5.** `%a` is the octal — `644`. `%A` is the symbolic — `-rw-r--r--`. The same nine bits, twice, plus
the type character in the symbolic form.

**6.** `%U`/`%u` are the same fact, and `%G`/`%g` likewise. The kernel stores the **numbers**; the
names are looked up when something displays them. That is the whole of lesson 03's exercise 53.

**7.** `640`, `755`, `400`, `777`.

**8.** `rw-r-----`, `rwxr-xr-x`, `rw-------`, `rwxr-x--x`.

**9.** `644` for files and `755` for directories, over and over — the defaults produced by a `022`
umask, which is lesson 06. `scratch/` may show `664`/`775` for things you made yourself, because
`cadet`'s umask is `002`. That difference is worth noticing now and is explained in two lessons.

**10.** `/etc/passwd` 644 root:root — every process on the machine has to turn a uid into a name, and
none of that needs to be secret. `/etc/group` 644 root:root — same argument. `/etc/shadow` 640
root:shadow — the hashes, readable only by root and by the small set of programs that run as group
`shadow`. Public half public, secret half secret.

**11.** No. You are the owner, so the kernel uses the owner triad and stops. The owner triad is
`---`. The group and other bits are never reached.

**12.** `cat: scratch/t: Permission denied`. The owner triad, which is empty.

**13.** "The first identity that matches decides, and no other is consulted." Or: "access is decided
by exactly one of the three sets of bits, chosen by who you are, not by adding up all the sets you
qualify for."

**14.** `chmod` needs neither read nor write on the file. Changing a mode is a privilege of the file's
**owner** (and of root), and ownership is not one of the nine bits. That is why you could unlock a
file you had just made unreadable to yourself — a stranger with `rwx` in the other triad could not
have done it.

**15.** cass: no — she is not rhea and not in group `rhea`, so she gets `---`. rhea: yes, owner triad
`rw-`. root: yes, and that answer does not come from the triads at all — root bypasses the permission
check on ordinary files entirely. Modes constrain everybody except the one identity that can change
them.

**16.** `047` — `--- r-- rwx`, or anything of that shape. It would confuse the owner most of all, who
would be the only person on the machine unable to open their own file, and then confuse whoever they
asked for help, who would look at "you own it" and stop thinking.

**17.** `open` 755, `listed` 744, `reachable` 711, `shut` 700.

**18.** The **other** triad, for all four, because you are neither `root` nor in group `root`. That
makes the comparison clean: the only variable between the four directories is the last digit, so
whatever differs in behaviour is caused by those three bits and nothing else.

**19.** All three work. `ls` lists two names, `ls -l` gives full rows, `cat` prints the rota.
Other is `r-x`.

**20.** `ls` lists two names. `ls -l` prints `-????????? ? ? ? ?  ? rota.txt` for each. `cat` is
denied. Other is `r--`: names, and nothing else.

**21.** The mode, owner, group, size and time. Those are not stored in the directory — the directory
holds names and inode numbers. Getting the rest means `stat`-ing each file, which means *reaching*
each file, which needs `x`. `ls` filled in the one column it had and put `?` in every column it could
not get.

**22.** From each file's inode. Reaching an inode through a path requires traversing the directory
that names it, which is exactly what the `x` bit permits. This is also why the error is per-file
question marks rather than a flat refusal: `ls` succeeded at what `r` allows and failed at what `x`
would have allowed.

**23.** `ls maze/reachable` → `Permission denied`. `cat maze/reachable/rota.txt` → the rota. Other is
`--x`.

**24.** `r` and `x` permit different operations and neither implies the other. `r` is "you may read
the list of names in this directory". `x` is "you may use this directory as a step in a path". With
`--x` you may take the step, provided you already know which name to take — and you cannot ask what
the names are.

**25.** `cat maze/reachable/nothere.txt` says `No such file or directory`, while `ls` said `Permission
denied`. So the `--x` directory *will* tell you whether a name exists, one guess at a time. It hides
the list, not the answers. A `--x` directory is not a secret; it is an index that has been taken away,
and a determined guesser gets everything back.

**26.** `two levels of guessing`. Four `x` bits: `/`, `/labs`, and every component down —
`10-users-groups-permissions`, `04-rwx-and-octal`, `maze`, `maze/reachable`, `maze/reachable/deeper` —
then the file's own `r`. Count them on your own path; the point is that it is every component, not
just the last.

**27.** `700`. Everything is denied: `ls`, `ls -l`, `cat` on a name you know, `cd`. You would have to
*be* root — the owner — or be in a group with bits set, and there are none.

**28.**

| mode | `ls` | `ls -l` | `cat known-name` |
|------|------|---------|------------------|
| 755 `r-x` | works | works | works |
| 744 `r--` | names only | `?` columns | denied |
| 711 `--x` | denied | denied | works |
| 700 `---` | denied | denied | denied |

**29.** `maze/listed` — the `r--` case. She can list the directory and cannot open a file in it, which
is exactly the 744 behaviour.

**30.** The assumption is that a directory's `r` bit implies access to what it names — that listing
and reaching are the same permission. They are two independent bits, and the interesting failures on
Unix are almost always somebody assuming that two independent things are one thing.

**31.** Consistent. To be sure which directory she means you need the path — one `pwd` and one
`ls -ld` from her, or the output of `namei -l` on the file she is trying to open, which gives you the
whole chain in one message.

**32.** "You are not doing anything wrong and rhea is not wrong about the general case — she is wrong
about this directory. A directory's `r` bit lets you see the names in it, and its `x` bit is what lets
you actually reach the files; this one has `r` without `x`, which is why `ls` works and `cat` does
not, and why `ls -l` gives you a row of question marks. What you want to ask for is execute
permission on the directory, not read on the file — the file's own mode is fine."

**33.** `namei -l /path/to/the/file`. One command, and it prints the mode of every component of the
path plus the file, which turns three rounds of guessing into one answer.

**34.** rhea, via the **owner** triad (`rw-`). cass: no — not the owner, not in `engineering`, so
**other**, which is `---`. kalvi: no, same reason. Note that cass and kalvi are both in `crew`, which
is not the file's group and therefore irrelevant.

**35.** Add kalvi to `engineering`. It is a change to *her*, not to the file — and that is the right
shape of change, because it is recorded, revocable and visible to an auditor, where loosening the
file's mode would grant it to everybody at once and leave no record of who asked.

**36.** cass (owner, `rw-`) and anybody in `crew` (group, `rw-`) — so rhea and kalvi too. Everyone
else may read it. The directory being `drwxrwxr-x` matters for a different question, which is 37.

**37.** Yes — and the mode you had to look at is the **directory's**, not the file's. Deleting a file
means removing a name from a directory, so it is governed by `w` on the directory. `galley/` is
`drwxrwxr-x` and cass is the owner, so she may remove any name in it, including files she cannot
write. Lesson 05 spends a while on this.

**38.** List `tools/`: yes, it is `drwxr-xr-x`. Run `tools/report`: yes, `-rwxr-xr-x` gives other
`r-x`. Run `tools/adjust`: no, `-rwx------` and she is not root.

**39.** You can say: it is executable, only root can run it, only root can read it, it was last
modified at 02:55 on 19 March, and it lives beside a tool that is world-readable and world-runnable.
You **cannot** say who wrote it, what it does, why it was modified at that hour, or whether the
modification was the creation. A timestamp is when the bytes last changed and nothing more. Be strict
about that boundary: everything past it is a story you brought with you.

**40.** `queue/` is `--x` for both group and other, so cass may traverse it and may not list it. She
can read `queue/README` — she knows the name, the traversal is permitted, and the file is `r--` for
other. She cannot discover anything else in there.

**41.** Plenty of legitimate uses. A directory of per-user files where everybody should reach their
own and nobody should enumerate the rest — mail spools and home-directory parents are the classic
case, and `/home` itself is often `--x` for other on shared machines. It stops browsing without
stopping work.

**42.** Nobody except root, who is not checked. Beyond the literal effect it *communicates*: somebody
set every bit to zero deliberately, which no default ever does. It is a note to the next reader
saying "this is not to be used", and the name `quarantine` agrees with it.

**43.** Every account on the machine can rewrite it, so nothing it says can be relied upon — including
by whatever reads it to decide something is alive. Given `ops-bot:ops` it should be `664` at the
loosest, and `644` if only ops-bot writes it.

**44.** `heartbeat`, at `-rw-rw-rw-`. Against the alternatives: `tools/adjust` is *suspicious* but
correctly restricted, so raising it is a question, not a finding. `quarantine/` is deliberate.
`strain/.private` is exactly as private as its name. `heartbeat` is the only one where the mode
itself is wrong and the fix is unambiguous — and world-writable files are how tampering is done
without any privilege at all.

**45.** Nothing would work for anybody who is not root. Every path lookup on the station crosses `/`;
removing other's `x` there would deny every non-root process every file outside its own reach in one
stroke. It is the single most effective way to break a machine with one command, and it is why
`chmod -R` near the root of a filesystem is the beginner's catastrophe.

**46.** It prints one line per path component with each one's mode and owner, from `/` down to the
file. It exists precisely for "the file is 644, why can I not read it" — it answers the question about
the whole path in one shot instead of four `ls -ld` calls.

**47.** The `drwx------ root root shut` line, and the file's line is replaced by
`rota.txt - Permission denied` — `namei` could not even stat it. No: `ls -l maze/shut/rota.txt` would
also have been denied, and would have told you only that you were denied, not where.

**48.** "644 tells you what the file permits once you can reach it. Reaching it means traversing every
directory in the path, each of which needs `x` for you — so a perfectly readable file inside a
directory you cannot traverse is unreadable, and `namei -l` will show you which component said no."

**49.**

```bash
mkdir -p scratch/outer/inner
echo secret > scratch/outer/inner/f      # 644, yours, plainly readable
cat scratch/outer/inner/f                # works
chmod 644 scratch/outer/inner            # remove x from the PARENT only
cat scratch/outer/inner/f                # denied — the file did not change
stat -c '%a' scratch/outer/inner/f       # still 644
chmod 755 scratch/outer/inner            # put it back
```

The file's own mode is printed unchanged on either side of the denial, which is the proof.

**50.** It does not — `cd: maze/listed: Permission denied`. `cd` needs `x`, because being *in* a
directory means using it in every subsequent path. Most people guess it needs `r`, because `ls`
worked; `ls` and `cd` want different bits.

**51.** `drwxrwxrwt`. Guesses that are on the right track: something that makes world-writable safe;
something about not being able to delete other people's files. It is the sticky bit, and lesson 08.

**52.** `-rwsr-xr-x`. It runs as its owner rather than as you — which is how an unprivileged user can
change a password stored in a file only root may write. Also lesson 08.

**53.** Take the ten characters as a claim you can check rather than a thing you have memorised:
`stat -c '%a'` will give you four digits when there is a fourth digit to give, `man 1 ls` documents
every letter it can print, and `find -perm` can search for the bit once you know its number. The
useful habit is noticing that a character is not one of the six you expect, rather than reading past
it.

**54.** It asks for entries directly under `/etc` with the world-write bit set. The answers —
`/etc/rmt`, `/etc/os-release`, `/etc/mtab` — are all **symlinks**, whose own mode is always
`lrwxrwxrwx` and is never consulted; what matters is the target's mode. So it is reassuring, and it is
also a lesson about the check: a naive world-writable audit that does not exclude symlinks reports
false positives forever, and people learn to ignore it. `find /etc -maxdepth 1 -type f -perm -o=w`
is the question you meant.

**55.** `stat` reads the *inode*, and reaching an inode needs `x` on `/etc`, not `r` on the file. `cat`
reads the file's contents, which needs `r`, and `440` gives other nothing. Metadata and content are
separately protected: you can always see how locked a door is.

**56.** No. `lrwxrwxrwx` is what every symlink shows and it means nothing — the kernel never consults
a symlink's own mode. `echo hi >> /opt/kestrel/bin/awk` follows the link and is refused by the
*target*, which is a read-only nix store path. A symlink's mode is good for exactly one thing:
reminding you that you are looking at a symlink.

**57.**

```bash
perms() { stat -c '%a %A %U %G %n' -- "$1"; }
```

`stat` works identically on a directory; it is `ls` that needs `-d` to be told not to look inside.
The `--` matters as soon as a filename starts with a dash.

**58.**

```bash
perms() {
  local line ww=""
  line=$(stat -c '%a %A %U %G %n' -- "$1") || return
  [ -w "$1" ] && [ "$(stat -c '%a' -- "$1" | tail -c 2)" -ge 2 ] &&
    case $(stat -c '%A' -- "$1") in *w?) ww=" WORLD-WRITABLE";; esac
  printf '%s%s\n' "$line" "$ww"
}
```

Simpler and better: test the character directly — `case $(stat -c %A -- "$1") in *w?) ...` — because
the octal arithmetic is where people introduce a bug. Make the test file with
`touch scratch/hb && chmod 666 scratch/hb`.

**59.** Private key `600`. Shared script everyone runs `755`. Config only root reads `600`, or `640`
with a group if a service needs it. Collaborative team directory `2775` — and if you wrote `775` you
have the right instinct and are missing lesson 08's digit. The one most people are least sure about is
the last, and correctly so: it is the only one of the four where the answer depends on a bit that has
not been taught yet.

**60.** Reading is denied — the file's `---` owner triad. Renaming and deleting both **work**, because
neither one touches the file: both are operations on the *directory entry*, and you have `rwx` on
`scratch/`. `notes/modes.txt` says it in the directory section — `w` on a directory is permission to
create and remove names, which is permission over the directory and not over the files. The part it
does not explain is `/tmp`, where everyone has `w` on the directory and cannot delete each other's
files. That is lesson 08.
