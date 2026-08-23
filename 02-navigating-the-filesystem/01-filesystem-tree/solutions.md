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

## No flag in this lesson

Chapter 2's flag is in `07-incident-02`. Nothing here should produce a `KESTREL{...}` string.
