# 02/02 — Solutions

> **Agent eyes only.** Student: do not open this. `help.md` is the file you want.

`$LAB` = `/labs/02-navigating-the-filesystem/02-cd-and-ls-deep`

---

**1.**
```bash
ls logs        # 5
ls -A logs     # 7   (+ .keep, .rotated)
ls -a logs     # 9   (+ . and ..)
ls             # 7
ls -a          # 9
ls -A          # 7
```
The lab root has no dotfiles of its own, so `-a`'s only additions there are `.` and `..` — which
is exactly the two-entry difference the exercise asks about.

**2.** `-a` shows everything including `.` and `..`; `-A` shows everything except those two.

**3.** `ls -lh logs` — `hull-2187-06-10.log` reads `879K`, and the `total` line becomes `920K`.

**4.** `.rotated`. Told it is a directory by `ls -lA logs` (leading `d`) or `ls -FA logs` (trailing
`/`). It is invisible to plain `ls` because its name begins with `.` — nothing else.

**5.** `ls logs/.rotated` → `strain-2187-04.log.2`, `strain-2187-05.log.1`. No `-a` needed: the
files inside are not themselves dotfiles.

**6.**
```bash
ls -t logs     # strain-06-12, thermal-06-13, strain-06-13, strain-06-11, hull-06-10
ls -tr logs    # the reverse
```
Note the trap: the newest **mtime** is `strain-2187-06-12.log`, whose name carries the *second*
latest date. Seeded that way on purpose.

**7.** `ls -S logs` → hull (900000), strain-06-12 (24000), thermal-06-13 (6300), strain-06-13
(1400), strain-06-11 (180).

**8.** The three orders:

| Sort | Order |
|---|---|
| name | hull-06-10, strain-06-11, strain-06-12, strain-06-13, thermal-06-13 |
| time (`-t`) | strain-06-12, thermal-06-13, strain-06-13, strain-06-11, hull-06-10 |
| size (`-S`) | hull-06-10, strain-06-12, thermal-06-13, strain-06-13, strain-06-11 |

No two agree. Name and size share a first element and diverge immediately.

**9.**
```bash
ls current      # lists the five files
ls -l current   # lrwxrwxrwx 1 cadet crew 4 ... current -> logs
```
The rule: **`-l` does not follow a symlink given as an argument.** No `-d` is required. `ls` with
no `-l` descends into it; `-l` describes the entry. (`-L` forces dereferencing even with `-l`.)

This is the misconception the lesson is built to kill: students assume `-d` is what stops the
descent. `-d` stops it for directories; for a symlink argument, `-l` already did.

**10.** `ls -ld logs` → one line, type `d`. `-d` means "do not descend into directory arguments;
list them as entries".

**11.** `Archive` before `archive`, because in this locale the comparison is by byte value and
`A` (0x41) < `a` (0x61). The responsible setting is `LC_COLLATE` (set here via `LANG=C.UTF-8`).

`locale -a` on this image prints only:
```
C
C.utf8
POSIX
```
So the contrast **cannot be demonstrated here** — `LC_ALL=en_US.UTF-8 ls` silently falls back and
the order does not change. "I could not demonstrate it and here is why" is the correct answer.

**12.**
```bash
ls -1 logs
ls logs | cat
```
`ls` produces columns only when its standard output is a terminal. Redirecting or piping makes it
one-per-line without any flag. Same mechanism as `01/01`.

**13.**
```bash
ls runs      # run-1, run-10, run-11, run-2, run-20, run-3, run-9
ls -v runs   # run-1, run-2, run-3, run-9, run-10, run-11, run-20
```
Default compares character by character, so `1` beats `9` at the second character. `-v` compares
runs of digits as numbers.

**14.** `ls -R deep`. Two directories at any depth: `deck-3` and `deck-3/bay-2`. `empty-bay` is
covered only if they also ran `ls -R empty-bay` or `ls -R *`; it appears as a label with nothing
beneath it, which is how "visited and empty" is distinguished from "not visited".

**15.** `ls Archive logs` prints a `Archive:` label, its entries, a blank line, a `logs:` label, its
entries. A script doing `for f in $(ls Archive logs)` would treat `Archive:` as a filename.

**16.** *Experiment.* Observed:

```
ls current        -> the five log files
ls -l current     -> lrwxrwxrwx ... current -> logs
ls -ld current    -> lrwxrwxrwx ... current -> logs
ls current/       -> the five log files
ls -ld current/   -> drwxr-xr-x ... current/
```

Three mechanisms, deliberately overlapping:

1. **`-l` does not dereference a symlink argument.** That alone explains lines 2 and 3.
2. **`-d` does not descend into directory arguments.** Here it changes nothing for lines 2/3,
   because `-l` had already stopped the descent — which is the trap.
3. **A trailing slash is a path-level assertion** that the path names a directory, so the kernel
   resolves the symlink *before* `ls` ever gets to choose. That is why line 5 reports a directory
   with mode `drwxr-xr-x` under the name `current/`.

A student who says "`-d` and `/` do the same thing" is refuted by line 5 alone.

**17.** *Experiment.*
```
cd logs   -> $LAB/logs
cd ../deep -> $LAB/deep
cd -      -> $LAB/logs     (and cd - prints the destination)
cd -      -> $LAB/deep
```
`cd -` swaps `PWD` and `OLDPWD`. One stored value, so two invocations are the identity and there is
no way back to a third directory. `pushd`/`popd` maintain an actual stack; not required here.

**18.** *Experiment.* All five files show `2187` rather than a clock time, because every one of them
is roughly 161 years away from the container's clock. The rule: `ls -l` prints the year instead of
the time whenever the timestamp is more than about six months from now, **in either direction**.
Students who predicted "some will show times" are wrong but pass, provided the explanation
addresses it. Verify with `touch -d now /tmp/x && ls -l /tmp/x`.

**19.**
```bash
type ls          # ls is aliased to `ls --color=auto'
\ls logs
command ls logs
/opt/kestrel/bin/ls logs
```
Any two of the last three. `01/03` established `type` over `which` for exactly this.

**20.** `ls -lhrtA logs` — long, human sizes, reversed, time-sorted, almost-all. Letters may be in
any order. Expanded: `-l -h -r -t -A`.

**21.** From `$LAB/deep/deck-3/bay-2`, having previously been somewhere else: `ls ~-`. Equivalent
but less idiomatic: `ls "$OLDPWD"`.

**22.**
```bash
ls -ld logs current
# drwxr-xr-x 3 cadet crew 4096 ... logs
# lrwxrwxrwx 1 cadet crew    4 ... current -> logs
```
Different type character, different link count, different size, and one has an arrow. `stat`,
`file` and `readlink current` all work too.

Watch for `ls -i logs current`: that lists the *contents* of both and the inode numbers are
identical, which is true but answers a different question — the entries in the parent are what
differ.

**23.** *Dig.*
```bash
echo "[$LS_COLORS]"          # []
man ls                       # the --color entry names LS_COLORS
apropos color                # dircolors(1) -- color setup for ls
dircolors -b                 # prints an assignment
eval "$(dircolors -b)"
ls --color=always -d logs current | cat -v   # now shows ESC[ sequences
```
Two gotchas worth noting for the tutor:

- With `TERM` unset or `dumb`, `dircolors -b` emits `LS_COLORS='';` — an empty assignment. A
  student in a non-interactive `docker exec` will hit this; inside `kestrel enter` they will not.
- Ubuntu's stock `~/.bashrc` guards its `dircolors` call with `[ -x /usr/bin/dircolors ]`. On this
  image `dircolors` lives in the Nix closure at `/opt/kestrel/bin`, so the guard fails and the
  variable is never populated. That is the whole reason colour is off here, and a student who
  works that out has done something genuinely good — but it is not required.

Permanence would mean adding the `eval` line to a shell startup file. Chapter 11 owns that; do not
let them edit `~/.bashrc` yet.

**24.** *Dig.*
```bash
ls -ls logs
# 880 ... 900000 hull-2187-06-10.log
#   4 ...    180 strain-2187-06-11.log
#  24 ...  24000 strain-2187-06-12.log
#   4 ...   1400 strain-2187-06-13.log
#   8 ...   6300 thermal-2187-06-13.log
```
The pair is `strain-2187-06-11.log` (180 bytes) and `strain-2187-06-13.log` (1400 bytes): a
7.8× difference in bytes, identical 4-block allocation. Blocks here are 1 KiB units in `ls`'s
reporting and the filesystem allocates in 4 KiB chunks, so anything from 1 byte to 4096 bytes
costs the same. Chapter 3 revisits this with `stat` and `du`.

**25.** *Dig.* `ls -U logs` → thermal-06-13, strain-06-13, strain-06-12, hull-06-10, strain-06-11.

That is the order the directory itself stores the entries, which is a function of the order they
were created and which slots freed-up entries reused. Useless for humans; occasionally the only
surviving evidence of the sequence in which a directory was built. Do not oversell this — on many
modern filesystems the order is a hash and encodes nothing.

---

## No flag in this lesson

Chapter 2's only flag is in `07-incident-02`.
