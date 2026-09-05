# 02/01 — Solutions

> **Agent eyes only.** Student: do not open this file. If you are reading it because you are
> stuck, close it and open `help.md` instead — a tutor agent will walk you up a hint ladder without
> handing you the answer.

Lab root abbreviated below as `$LAB` = `/labs/02-navigating-the-filesystem/01-filesystem-tree`.

---

**1.**
```bash
pwd                 # /labs/... (wherever they were)
cd
pwd                 # /home/cadet
```
Bare `cd` is `cd "$HOME"`. Not `/`, not the previous directory.

**2.** `cat /labs/02-navigating-the-filesystem/01-filesystem-tree/roster.txt`

**3.** `cd "$LAB"` then `cat roster.txt`.

**4.** From `$LAB`:
```bash
ls deck-3
ls /labs/02-navigating-the-filesystem/01-filesystem-tree/deck-3
ls ../01-filesystem-tree/deck-3
```
A fourth: `ls ./deck-3`. A fifth: `ls deck-3/../deck-3`.

**5.** From `$LAB/deck-3/bay-3`: `cat ../bay-1/survey.txt`

**6.** `cat ../../roster.txt`

**7.** From `bay-1`: `cd ../bay-2`

**8.**
```bash
cd deck-3/bay-2/panels/panel-07
cd ../../../..
```
Four, because `deck-3`, `bay-2`, `panels`, `panel-07` are four components below the lab root.

**9.**
```bash
cat ../../../bay-3/survey.txt
cat /labs/02-navigating-the-filesystem/01-filesystem-tree/deck-3/bay-3/survey.txt
```
Either justification is acceptable. The strongest answer notes that the relative path encodes a
fact about the *caller's* location, which a script cannot rely on, while the absolute path encodes
a fact about the tree's layout, which a relocation breaks.

**10.**
```bash
cd shortcut
pwd        # $LAB/shortcut
pwd -P     # $LAB/deck-3/bay-2
```
`/bin/pwd` (the external coreutils one) also prints the physical path, because it has no shell
bookkeeping to consult. `realpath .` works too.

**11.** `realpath shortcut/survey.txt` → `$LAB/deck-3/bay-2/survey.txt`. `readlink -f` is
equivalent here.

**12.** From `$LAB/shortcut`, `cd ..` lands at `$LAB`, not at `$LAB/deck-3`.

The explanation: bash keeps the path you walked in `$PWD` and resolves `..` **textually** against
that string before handing anything to the kernel. `$LAB/shortcut` minus its last component is
`$LAB`. The kernel is never asked "what is the parent of this directory". The shell does this
because a user who typed `cd shortcut` expects `cd ..` to undo it; the physical answer would drop
them somewhere they never went.

**13.** From `panel-07`: `cat ../../readings.log`

**14.**
```bash
dirname deck-3/bay-2/readings.log     # deck-3/bay-2
basename deck-3/bay-2/readings.log    # readings.log
basename deck-3/bay-2/readings.log .log   # readings
```
Both are string operations. `dirname /no/such/path` happily prints `/no/such`.

**15.** *Experiment.* Observed:

```
ls deck-3//bay-1   -> survey.txt
ls deck-3///       -> bay-1 bay-2 bay-3
ls //deck-3        -> ls: cannot access '//deck-3': No such file or directory
ls roster.txt/     -> ls: cannot access 'roster.txt/': Not a directory
```

Three separate rules, and the exercise is designed so the student cannot pass with one of them:

1. **Interior runs of `/` collapse.** `deck-3//bay-1` and `deck-3/bay-1` are the same path.
   Trailing runs collapse too, which is why the second command lists `deck-3` normally.
2. **A leading slash is not a separator, it is the root directory.** So `//deck-3` is an
   *absolute* path naming `deck-3` at the root of the tree, which does not exist. (POSIX reserves
   exactly-two leading slashes as implementation-defined; Linux treats it as `/`. Either way it is
   absolute, and that is the point — the collapsing rule from (1) does not rescue it, because the
   error is not about the slashes at all.)
3. **A trailing slash asserts the path names a directory.** The kernel checks it and returns
   `ENOTDIR` on a regular file. This is the same mechanism that makes `cp x y/` fail safely when
   `y` is not a directory, which Chapter 4 exploits.

A student who says "the third one failed because of the double slash" has the wrong model and
should be pushed: ask them what `ls /deck-3` does.

**16.** *Experiment.* Observed:

```
echo ~       -> /home/cadet
echo "~"     -> ~
echo '~'     -> ~
ls ~/..      -> contents of /home
cd / ; cd ../../.. ; pwd   -> /
```

Tilde expansion is performed by the **shell**, during word expansion, before `echo` is executed.
`echo` never sees a `~` in the first case — it receives the literal string `/home/cadet`. Both
quote styles suppress the expansion (unlike `$VAR`, which survives double quotes — that asymmetry
is worth pointing out if the student raises it).

The last line: `..` in `/` is an entry that points at `/` itself, so walking up from root is a
no-op rather than an error.

**17.**
```bash
pwd
echo "$PWD"
cd /tmp
echo "$PWD"
```
`$OLDPWD` holds the previous one; `cd -` uses it. Watch for students who write `echo $(pwd)` —
that still runs `pwd`.

**18.**
```bash
mkdir "$LAB/gone" && cd "$LAB/gone"
rmdir "$LAB/gone"
pwd       # still prints $LAB/gone  -- from the shell's $PWD
pwd -P    # pwd: error retrieving current directory: getcwd: cannot access parent
          # directories: No such file or directory
ls        # ls: cannot open directory '.': No such file or directory
```
The shell's variable is stale; the kernel has no path for the inode any more. The process still has
a valid working directory — it is just unnameable. `cd` to any absolute path recovers.

**19.**
```bash
dirname deck-3/bay-1/survey.txt deck-3/bay-2/survey.txt deck-3/bay-3/survey.txt
basename -a -s .txt deck-3/bay-1/survey.txt deck-3/bay-2/survey.txt deck-3/bay-3/survey.txt
```
`dirname` needs no flag because every operand is unambiguous. `basename`'s classic two-argument
form already means `basename PATH SUFFIX`, so multiple operands would be ambiguous; `-a` switches
it into multi-operand mode and `-s` supplies the suffix separately. `-as .txt` bundles them.

**20.**
```bash
realpath --relative-to=deck-3/bay-2/panels/panel-07 deck-3/bay-3/survey.txt
# ../../../bay-3/survey.txt
```
Verify: `cd deck-3/bay-2/panels/panel-07 && cat ../../../bay-3/survey.txt`. Note this is the same
path as exercise 9 — a student who notices that has understood both.

`--relative-base` is the trap: it only shortens paths *under* the given base and otherwise emits an
absolute path.

**21.**
```bash
cd -P shortcut
pwd            # $LAB/deck-3/bay-2   -- immediately, no -P needed
```
Found via `help cd`, not `man cd` — `cd` is a builtin. The persistent form is `set -o physical`
(equivalently `set -P`). With it on, `cd shortcut; cd ..` lands in `deck-3`, because `$PWD` was
never fictional in the first place.


---

## Added exercises 22–52

Throughout, `$LAB` is `/labs/02-navigating-the-filesystem/01-filesystem-tree`. All output below was
taken from the running container.

**22.** From `deck-3/bay-2/panels/panel-07`, the seven:

```
$LAB/roster.txt
$LAB/shortcut
$LAB/deck-3/bay-1/survey.txt
$LAB/deck-3/bay-2/survey.txt
$LAB/deck-3/bay-2/readings.log
$LAB/deck-3/bay-2/panels/panel-07/panel.txt
$LAB/deck-3/bay-3/survey.txt
```

The directories `deck-3`, `bay-1`, `bay-2`, `bay-3`, `panels`, `panel-07` are also legitimate
answers if the student counts them; the point is that every one starts at `/`.

**23.** From `panel-07`:

```
panel.txt                        ../../../../roster.txt
../../survey.txt                 ../../../../shortcut
../../readings.log               ../../../bay-1/survey.txt
../../../bay-3/survey.txt
```

Three checks: `cat panel.txt`, `cat ../../readings.log`, `cat ../../../bay-1/survey.txt`.

**24.** Absolute for all seven. The rule at the end is the load-bearing part: *a relative path is a
statement about where you are standing; if you do not control where the process starts, you cannot
make that statement.* Scripts do not control it, so scripts use absolute paths — or compute one at
the top and use it as a prefix.

**25–26.** Any five will do. The character counts always favour relative here (`../../survey.txt` is
17; the absolute equivalent is 60-odd), and the sentence to look for is that the relative form is
shorter but only correct from one place. Typing cost is not the criterion.

**27.** `cd -` swaps `$PWD` and `$OLDPWD`. On the first use in a fresh shell:

```
$ bash -c 'cd -'
bash: line 1: cd: OLDPWD not set
$ echo $?
1
```

`$OLDPWD` does not exist until the first successful `cd`, so there is nothing to go back to.

**28.** `cd -` prints the directory it moved to. It is the one `cd` form where you did not type the
destination, so the shell tells you what it picked. Same reason `cd` with no argument prints
nothing — you know where `$HOME` is.

**29.** From the lab root:

```bash
cd ./deck-3/bay-2/panels/../../bay-1/../bay-3
pwd     # $LAB/deck-3/bay-3
```

**30.**
```
$ ls -a deck-3
.  ..  bay-1  bay-2  bay-3
```
They are entries in the directory, which is why `ls -a` shows them and why `..` works in a program
that knows nothing about the shell. In `/`, `..` is `/` itself:

```
$ stat -c '%i %n' / /..
4108698 /
4108698 /..
```

Same inode, so the same directory. The root is its own parent; the tree has no edge to fall off.

**31.**
```
$ ls -l shortcut
lrwxrwxrwx 1 root root 12 ... shortcut -> deck-3/bay-2
$ realpath shortcut
$LAB/deck-3/bay-2
```
`ls -l` reads the link; `realpath` follows it. Note the target stored in the link is *relative* —
`deck-3/bay-2`, resolved against the directory the link lives in.

**32.** `ls shortcut` and `ls deck-3/bay-2` print the same three entries. The argument to reach for
is inode identity: `ls -di shortcut/ deck-3/bay-2` gives one number twice. A copy would have two.

**33.** Logical prediction: `$LAB/..` — that is `/labs/02-navigating-the-filesystem` — because the
shell strips `shortcut` from `$PWD` textually, then strips the lesson directory. Physical
prediction: `$LAB`, because the real parent chain from `bay-2` is `deck-3` then the lab root.
Observed:

```
$ cd shortcut && cd ../.. && pwd
/labs/02-navigating-the-filesystem
```

The logical rule won. `cd` keeps a *fiction* of where you are and edits it as text.

**34.**
```
$ cd shortcut
$ pwd                 # $LAB/shortcut
$ echo "$PWD"         # $LAB/shortcut
$ pwd -P              # $LAB/deck-3/bay-2
```
`pwd` and `$PWD` agree because `pwd` with no options prints `$PWD` — the shell's own bookkeeping.
`pwd -P` asks the kernel, which has never heard of `shortcut`.

**35.** Physical: `$LAB/deck-3/bay-2/panels/panel-07/panel.txt`. Logical as typed:
`$LAB/shortcut/panels/panel-07/panel.txt`. Both open the same file.

**36.**
```
$ cat shortcut/../bay-1/survey.txt
bay 1: 12 panels, last survey 2187-04-02
```
This is the exercise that pays for the whole lesson, and it catches almost everyone. `shortcut/..`
is **not** the lab root here, even though `cd shortcut; cd ..` goes there. Path resolution inside
`cat` is done by the kernel, one component at a time: `shortcut` becomes `deck-3/bay-2`, then `..`
is `deck-3`, then `bay-1/survey.txt`. The logical rule is a *shell* convenience for `cd` and `$PWD`
only; it does not exist below that.

**37.** All five from the lab root:

| command | output |
| `ls .` | `deck-3  roster.txt  shortcut` |
| `ls ./.` | same |
| `ls ././deck-3` | `bay-1  bay-2  bay-3` |
| `ls deck-3/..` | same as `ls .` |
| `ls deck-3/../..` | the contents of `/labs/02-navigating-the-filesystem` |

Repeated `.` is free; each one resolves to the directory you are already in.

**38.**
```
$ cd deck-3/bay-1/survey.txt
bash: cd: deck-3/bay-1/survey.txt: Not a directory
$ echo $?
1
$ pwd     # unchanged
```
A failed `cd` does not move you. Worth knowing before writing `cd somewhere; rm -rf *`.

**39.** `ls ~` lists `/home/cadet`. `ls ~/` does the same. `ls "~"` fails:

```
ls: cannot access '~': No such file or directory
```
exit status 2. Tilde expansion is done by the shell before `ls` runs, and quoting suppresses it, so
`ls` receives a literal one-character filename. There is no file called `~`.

**40.**
```
$ basename /      prints  /
$ dirname /       prints  /
$ basename ''     prints  an empty line
$ dirname ''      prints  .
```
`dirname ''` printing `.` is the surprise: an empty path has no directory part, and these tools
answer with the most useful non-empty string rather than failing.

**41.**
```
$ realpath deck-3/bay-9/nothing.txt
realpath: deck-3/bay-9/nothing.txt: No such file or directory
$ echo $?
1
```
The default mode is `-E`: every component *except the last* must exist, and `bay-9` does not. With
`-m` nothing needs to exist and it succeeds:

```
$ realpath -m deck-3/bay-9/nothing.txt
$LAB/deck-3/bay-9/nothing.txt
```

**42.** `cd $1` unquoted. A breaking value: `deck-3/bay 1` — the shell splits it into two words and
`cd` reports `too many arguments`. A silent unintended value: the empty string, which makes the
command a bare `cd` and sends the script to `$HOME` without a word. Fix: `cd "$1"`, and better,
`cd "$1" || exit 1`.

**43.** The rule: *write the absolute path of A and of B under each other, strike out the shared
leading components, emit one `..` for each component left in A, then append what is left of B.*
Tested lab root to `panel-07`, `panel-07` to `bay-3/survey.txt` (`../../../bay-3/survey.txt`), and
`bay-1` to `roster.txt` (`../../roster.txt`).

**44.** In a child shell:

```
$ bash
$ cd /labs/02-navigating-the-filesystem/01-filesystem-tree
$ PWD=/etc
$ pwd            # /etc   -- a lie
$ ls             # still the lab, unchanged
$ cd -           # goes to $OLDPWD, prints it
$ exit
```
`pwd` breaks, because it prints `$PWD`. Nothing else does, because every actual file operation uses
the process's real working directory, which is kernel state you cannot assign to. The child shell
matters: the damage dies with it.

**45.** Three sentences to the effect of: `pwd` is a builtin because the shell already tracks `$PWD`
and because only a builtin can report the *logical* path; a separate program exists because the
utility must be available to things that are not bash; a bare `pwd` runs the builtin, since builtins
are searched before `$PATH`. Proof:

```
$ type -a pwd
pwd is a shell builtin
pwd is /opt/kestrel/bin/pwd
pwd is /usr/bin/pwd
pwd is /bin/pwd
$ cd shortcut
$ pwd            # $LAB/shortcut       -- logical, so it is the builtin
$ /bin/pwd       # $LAB/deck-3/bay-2   -- the program, which can only be physical
```

**46.** Two sentences on the order of: a failed `cd` leaves the process where it was and the script
carries on regardless, so every command after it runs against the wrong directory; if those commands
write or delete, the blast lands somewhere nobody chose. Concrete failure:
`cd deck-3/bay-1/survey.txt` above — status 1, still in the lab root, and the next line runs there.

**47.** No difference:

```
$ cd shortcut/ ; pwd ; pwd -P
$LAB/shortcut
$LAB/deck-3/bay-2
```
`cd` strips the trailing slash before recording `$PWD`. Worth checking rather than assuming, because
for *other* commands a trailing slash on a symlink is meaningful — it asserts "directory", and some
tools follow the link because of it.

**48.** `set -o physical` (or `set -P`), found in `help set`, not `man`, because `set` is a builtin.

```
$ ( set -o physical; cd shortcut; pwd; cd ../..; pwd )
$LAB/deck-3/bay-2
$LAB
```
Exercise 33 now lands in the lab root instead of one level above it, and `pwd` never tells the
fiction in the first place.

**49.** `man realpath` and `man 7 path_resolution`: a loop is caught by a limit on how many symlinks
may be followed while resolving one path, and the call fails with `ELOOP` — "Too many levels of
symbolic links". Accept any answer that names `ELOOP` or quotes that message. A student who built a
loop in the lab to find out has ignored the instruction, but has learned it.

**50.** From `realpath --help`: `realpath` has `--relative-to=DIR` and `-m`, neither of which
`readlink` offers; `readlink` without `-f` prints the link's *stored target* rather than resolving
it, which `realpath` will not do. Demonstration:

```
$ readlink shortcut
deck-3/bay-2
$ realpath shortcut
$LAB/deck-3/bay-2
$ realpath --relative-to=deck-3 shortcut
bay-2
```
On this box `readlink -f shortcut` and `realpath shortcut` print the same thing, so the difference
is in the options, not in the common case.

**51.** They never touch the disk — they are string operations:

```
$ dirname /no/such/place/at/all/file.txt
/no/such/place/at/all
$ basename /nonexistent/deck-99/panel.txt
panel.txt
```
Neither path exists and neither command complains. Why it matters: they are safe on paths you are
about to create, and equally they will hand you a confident answer about a path that is nonsense, so
they prove nothing about existence.

**52.** Longest in the lab:
`$LAB/deck-3/bay-2/panels/panel-07/panel.txt` — nine components below `/`, counting the four in
`/labs/02-navigating-the-filesystem/01-filesystem-tree`. Limits:

```
$ getconf PATH_MAX /
4096
$ getconf NAME_MAX /
255
```
4096 bytes for a whole path, 255 for a single name, both properties of the filesystem rather than of
the shell. `man 7 path_resolution` is the page describing the whole procedure, including the symlink
limit from exercise 49.

---

## No flag in this lesson

Chapter 2's flag is in `07-incident-02`. Nothing here should produce a `KESTREL{...}` string.
