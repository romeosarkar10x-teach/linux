# 06/06 — Solutions

Every number here was measured in the container. If your count differs, the index is in a different
state than the one described — say so out loud rather than adjusting the answer.

## The index, before you touch it

**1.** One hit: `/sys/module/acpi_x86/parameters/check_lps0_constraints`. The letters `strain` are
inside `con-strain-ts`. There is no strain log in the answer at all.

**2.** It matches a **substring of the whole path**, not the basename, and not as a glob. That single
sentence explains exercises 1, 3, 11 and the glob failure in exercise 55's neighbourhood.

**3.** `/usr/share/man/man3/labs.3.gz` — `labs` as a substring of the path, and `/labs` matched inside
`man3/labs.3.gz` … read it again: the pattern `/labs` appears as `…/man3/labs…`. Same rule.

**4.** `find /labs/06-searching -name '*strain*' | wc -l` → **8**. `locate -c strain` → **1**. `find`
is correct about the disk *now*; `locate` is correct about the index *as of the last `updatedb`*. The
index was built when `/labs` was an empty volume mount.

**5.** Status 0 with no output would mean "the query ran and the index contains no matching path". It
would tell you nothing about whether the file exists. Absence of evidence, and a stale index makes it
absence of stale evidence.

**6.** `-rw-r----- 1 root plocate 1360004 /var/cache/locatedb`, built at image build time. It is
stale by however long your container has existed, and stale by the entire contents of `/labs`
regardless.

**7.** `locate -c ''` → **74838**. `find / -xdev 2>/dev/null | wc -l` → **20465**. They disagree by
more than 3x: the database was built before the volume mounts existed and counted a different
filesystem view, and `-xdev` refuses to cross into mounts that `updatedb` did index. Two different
questions. `locate` returns in ~0.002s; `find` takes seconds.

**8.**
```
updatedb: can not open a temporary file for '/var/cache/locatedb'
/var/cache/: Permission denied
```
rc **1**. Reading needs only membership of the `plocate` group (mode 0640 root:plocate, and `cadet`
is in that group). Writing needs to traverse every directory on the system including ones you cannot
read — that is a root-level walk by definition.

## The index, after you rebuild it

**9.** `sudo updatedb` → rc 0. `locate -c strain` → **51**. The 50 new ones are all under `/labs`:
they had in common that they did not exist, as far as the index was concerned, because `/labs` is a
volume that was empty at image build time.

**10.** Reasonable when you are looking for something that has existed for a while and you remember
part of its path. Not reasonable for anything created since the last `updatedb`, anything just
deleted, or anything whose existence you need to be *sure* about.

**11.** `-b` matches against the **basename** only. Without it, `strain-2187-06-03.log` would also
match any path containing that string in a directory component; more usefully, `-b` lets a short
basename pattern stop matching the directories above it.

**12.** `locate strain` → 51, `locate STRAIN` → 0 hits with that exact case in the paths (uppercase
does not appear), `locate -i STRAIN` → **52**. The extra is
`/labs/06-searching/04-find-basics/decks/deck-05/bay-01/Strain-01.log` — the only path in the tree
with a capital `S`, deliberately seeded in lesson 04.

**13.** Two hits. It is **BRE** (POSIX basic, with GNU extensions). Check: `locate -r 'panel\|strain'`
matches both alternatives; `locate -r 'panel|strain'` matches nothing, because `|` is a literal there.

**14.** `-l 3` limits output to 3 results. They are the first three the search happens to produce —
database order, which is roughly sorted path order but is not a promise. It is a "stop early" flag,
not a "top three" flag.

**15.** The index still contains the path; nothing has told it the file was removed.

**16.** `-e` makes `locate` `stat()` each candidate and print only ones that still exist. Output is
empty and the exit status is **1**. The cost is that you have gone back to touching the filesystem —
on a large result set, you have given away most of the speed that was the reason to use `locate`.

**17.** Restored file: `locate panel-index-05` prints it again — accidentally right, for the wrong
reason. `touch scratch/vanish.log; locate vanish` returns an unrelated stale path and not the new
file. Two kinds of wrong: a **false positive** (indexed, gone) and a **false negative** (exists, not
indexed). The stale index produces both, and they fail in opposite directions.

**18.** Something like: "`locate` answers 'was there a path like this at the last index run' in
milliseconds; use it to *find candidates* on a stable system, never to *prove* a file does or does
not exist — for that, `find` or `stat` the path."

**19.** `locate -0 strain | tr '\0' '\n' | wc -l` → **51**. `-0` separates results with NUL so that
paths containing newlines or spaces survive being piped. It is the twin of `find -print0` from
lesson 05, and pairs with `xargs -0` the same way.

## Which command will actually run

With `export PATH="$PWD/tools:$PWD/tools-b:$PATH"`.

**20.** `which strain-report` → `…/tools/strain-report`. Its output says `2186 build, superseded`;
the `tools-b/` copy says `corrected 2187 build`. The winner is neither the newer nor the better one.
`PATH` encodes only **order**.

**21.** Two lines, `tools/` then `tools-b/`: **`PATH` order**, left to right, first match first.

**22.** `strain-report: tools/ version -- 2186 build, superseded`. Agrees with 20, which is the only
reason `which` looked useful in this exercise — see 23.

**23.** `which echo` prints `…/tools/echo`, an executable file, rc 0. `echo hello` prints `hello`.
`which` is a separate program: it can only look at `PATH`. It cannot see the shell's builtins,
because the builtin does not exist outside the shell process.

**24.** `type echo` → `echo is a shell builtin`. `type -a echo` → the builtin, then **four** files:
`…/tools/echo`, `/opt/kestrel/bin/echo`, `/usr/bin/echo`, `/bin/echo`. The builtin wins.

**25.** `-P` forces the `PATH` search and skips builtins, functions and aliases: `type -P echo` →
`…/tools/echo`. Use it when you specifically want the file — for example to pass a path to something
that will `exec` it.

**26.** `which cd` prints nothing, rc **1**. `type cd` → `cd is a shell builtin`. `type` answered the
question you asked ("what is `cd`"); `which` answered "is there a file called cd on PATH", which was
not the question.

**27.** With `alias panel-check='echo aliased'`:
- `which panel-check` → **nothing, rc 1**. It is a separate process, so the alias is invisible to it;
  and the only file of that name has no execute bit, so its `PATH` scan rejects that too. It misses
  the thing that will actually run *and* the thing that is on disk.
- ``type panel-check`` → ``panel-check is aliased to `echo aliased'``
- `command -v panel-check` → `alias panel-check='echo aliased'`
`command -v` prints something re-usable as shell input; `type` prints a sentence; `which` is wrong
twice over. (Remove the alias and `type` reports the file path, rc 0 — exercise 37.)

**28.** `which deck-scan` → `…/tools/deck-scan`, rc 0. Running `deck-scan` prints `function version`.
General rule: **`which` runs in a child process, and functions, aliases, builtins and keywords live
only in the parent shell's memory.** They are not on disk and cannot be inherited, so no external
program can ever report them.

**29.** `type -t`: `echo`→`builtin`, `cd`→`builtin`, `if`→`keyword`, `deck-scan`→`function`,
`strain-report`→`file`, `nosuchcmd`→ empty output, rc 1. The five categories are **alias, keyword,
function, builtin, file** — resolved in that order.

**30.** `type if` → `if is a shell keyword`. It is part of bash's grammar, not a command. `which if`
prints nothing and exits 1.

**31.** `command -v` on the six → `echo`, `cd`, `if`, `…/tools/panel-check`, `deck-scan`,
`…/tools/strain-report`, and rc 1 for `nosuchcmd`. For scripts, `command -v` is better: it is POSIX,
its exit status is the answer, and it prints a bare path for files rather than a sentence you would
have to strip.

**32.** rc **1** and no output.
```
command -v jq >/dev/null 2>&1 || { echo "need jq; install it and retry" >&2; exit 1; }
```

**33.** `command -V echo` → `echo is a shell builtin`, the same sentence `type echo` gives. `type` is
the one to type from memory in an interactive shell; `command -v` is the one for scripts.

**34.** With `alias strain-report='echo ALIASED'` defined, `\strain-report` runs
`…/tools/strain-report`. The backslash suppresses **alias expansion only**. It does not suppress a
function, a builtin, or the `PATH` order — a function of that name would still win.

**35.** `command -pv echo` → `echo`. `-p` swaps in a default `PATH`, but `echo` is a builtin and
builtins are resolved before `PATH` is consulted at all. `-p` helps when `PATH` itself is broken or
hostile and you need the system's standard utilities.

## The file that cannot run

**36.** `-rw-r--r--` — no execute bit, on any of the three classes.

**37.** `type panel-check` → `panel-check is …/tools/panel-check`, rc **0**. `command -v` likewise,
rc 0. `type -P panel-check` likewise. Running it:
```
bash: /labs/06-searching/06-locate-which-type-whereis/tools/panel-check: Permission denied
```
rc **126** — the status bash reserves for "found it, could not execute it".

**38.** It means `command -v foo` is a *name resolution* test, not a *can I run this* test. Properly:
```
p=$(command -v foo) && [ -x "$p" ] || { echo "foo not runnable" >&2; exit 1; }
```
(and remember `-x` is meaningless for a builtin or function, where `command -v` prints a name rather
than a path — branch on `type -t` if you need to be exact.)

**39.** `which panel-check` prints nothing, rc **1**, because `which` tests for the execute bit while
scanning `PATH`. Here it agrees with reality. But it is right by accident of implementation: the same
tool is confidently wrong about aliases, functions, builtins and keywords, so you cannot use "which
was right that time" as a reason to trust it.

**40.** After `chmod +x tools/panel-check`, `which` finds it (rc 0) and `type` is unchanged; the two
now agree. `chmod 644 tools/panel-check` restores the trap.

## `PATH` order and `hash`

**41.** The first entries are the two lab directories you prepended, then the login `PATH`. To shadow
`grep` you would need write access to any directory that appears **before** the one holding the real
`grep` — which is exactly why a writable directory early on `PATH` is a security problem, and why
`.` is never on `PATH` by default.

**42.** `PATH="$PWD/tools-b:$PATH" bash -c 'strain-report'` → the `tools-b` version. You changed the
**environment of one command**, not the disk. The assignment applies to that invocation only; your
own shell's `PATH` is untouched.

**43.** After `hash -r; strain-report; hash`:
```
hits	command
   1	/labs/06-searching/06-locate-which-type-whereis/tools/strain-report
```
`hits` is how many times bash used the cached path instead of searching.

**44.** It runs the **`tools/` version immediately** — the prediction is wrong. **Assigning to `PATH`
flushes bash's hash table.** Bash cannot know whether the new `PATH` invalidates a cached entry, so
it discards all of them.

**44b.** The file has to go into a directory **earlier on `PATH` than the cached one**, without
touching `PATH`. Measured, with `scratch` first and `strain-report` hashed from `tools/`:
```
$ printf '#!/bin/bash\necho scratch version\n' > scratch/strain-report; chmod 755 scratch/strain-report
$ strain-report
strain-report: tools/ version -- 2186 build, superseded      # stale cache
$ type strain-report
strain-report is hashed (/labs/…/tools/strain-report)
$ hash -r; strain-report
scratch version
```

**45.** (1) `type -a NAME` — is there an alias or function shadowing it, and what does the `PATH`
order actually say. (2) `hash -r` and retry — is it a stale cache. (3) `echo $PATH` in *that* shell,
not yours — did the install go somewhere that is not on it, or behind the old copy.

**46.** `type` reports the **cached** path and says so: `strain-report is hashed (…)`. After `hash -r`
it reports the plain `PATH` search result. `help type`: `-a` displays all locations, and it forces a
`PATH` search rather than trusting the hash table.

## `whereis`

**47.** `whereis grep` →
```
/usr/bin/grep /nix/store/9lqzdycwrkvx471lblr9vgkldf2gh0rq-kestrel-env/bin/grep /usr/share/man/man1/grep.1.gz /usr/share/info/grep.info.gz
```
Two binaries (the Debian one and the Nix one this course actually uses), one man page, one info page.

**48.** `whereis -b bash` → `/usr/bin/bash` (binaries only). `whereis -m bash` → the man page
(manuals only). There is also `-s` for sources.

**49.** `whereis -l` prints the directory list `whereis` searches — `bin: /usr/bin`, `bin: /usr/sbin`,
and so on. It is largely **compiled in**, a fixed idea of where a Unix system puts things. See 51 for
the part that is not.

**50.**
```
$ whereis nosuchcmd; echo "rc=$?"
nosuchcmd:
rc=0
```
It prints the name with an empty list and **exits 0**. The status carries no information, so an `if
whereis …` is always true — you would have to parse the output, which is exactly the thing exit
statuses exist to avoid.

**51.** It finds both lab copies because `whereis` *does* also consult `$PATH` on top of its built-in
list. Confirmed: `env -u PATH whereis strain-report` finds nothing for `strain-report` while still
finding `grep` from the compiled-in directories.

**52.**

| tool | answers | searches | confidently wrong when |
|---|---|---|---|
| `locate` | "has a path like this ever been indexed" | a prebuilt database | the index is stale — in both directions |
| `which` | "is there an executable file with this name on `PATH`" | `PATH`, in a child process | an alias, function, builtin or keyword is what actually runs |
| `type` | "what will this name do in *this* shell" | the shell's own resolution order | never, for that question — but it will report a file it cannot execute (rc 126) |
| `whereis` | "where does a Unix system keep this program and its docs" | a compiled-in list plus `PATH` | the thing is not in a standard location; and it exits 0 on failure |

## Experiment

**53.** With `scratch/ls` empty, executable, and `scratch` first on `PATH`, `ls -d .` prints nothing,
rc 0. Three ways to get the real one **without editing `PATH` back**:
```
/usr/bin/ls -d .            # absolute path: no search at all
PATH=/usr/bin ls -d .       # PATH override for one command
hash -p /usr/bin/ls ls; ls -d .   # pin the hash table entry by hand
```
All three print `.`. The trap: **`command ls -d .` does not work** — `command` bypasses functions and
aliases, not `PATH` order, so it still runs `scratch/ls`. Nor does `\ls`, for the same reason. Nor
does `$(type -P ls)`, which returns `scratch/ls`. `env -i /usr/bin/ls` also works but that is the
absolute path again.

**54.** `type` finds something and `which` finds nothing whenever the name is not a file: a function
(`deck-scan` from 28, once the file is out of `PATH`), a builtin (`cd`), a keyword (`if`), or an
alias. Also: a file without the execute bit — `type panel-check` succeeds, `which panel-check` fails.

**55.** `enable -n echo; echo hello` → `tools/echo was run, with args: hello`. `enable echo` restores
the builtin. It proves "builtins always win" is a statement about the **default configuration**, not
about the shell's architecture: the resolution order is data, and a shell option can change it.

**56.** `time locate -c strain` → `real 0m0.002s`. `time find / -xdev -name '*strain*' 2>/dev/null` is
seconds, and it walks 20465 entries. To be honest you would have to add the cost of the `sudo
updatedb` that made the fast answer possible — and amortise it over how many queries you actually run
before the index goes stale again.

## Stretch

**57.** One shape:
```bash
whichreally() {
  local t; t=$(type -t "$1") || { printf '%s: not found\n' "$1" >&2; return 1; }
  case $t in
    alias)    type "$1" ;;
    function) printf '%s: shell function\n' "$1"; type "$1" ;;
    builtin|keyword) printf '%s: shell %s\n' "$1" "$t" ;;
    file)     local p; p=$(type -P "$1"); printf '%s\n' "$p"
              [ -x "$p" ] || { printf '%s: found but not executable\n' "$p" >&2; return 1; } ;;
  esac
}
```
On the six names it reports builtin, builtin, keyword, function, the file path, and rc 1 for
`nosuchcmd`.

**58.** `man updatedb.conf` documents `PRUNEFS`, `PRUNEPATHS` and `PRUNE_BIND_MOUNTS`. Two good
answers: **network and virtual filesystems** (`nfs`, `proc`, `sysfs`, `tmpfs`) — indexing them is
either slow over the wire or meaningless because the contents are synthesised per read; and **`/tmp`
and similar** — the contents are gone before anyone queries the index, so every entry is a guaranteed
future false positive.

Then check this station, and get a surprise: **there is no `/etc/updatedb.conf` here.**
```
$ ls -l /etc/updatedb.conf
ls: cannot access '/etc/updatedb.conf': No such file or directory
$ locate -c /proc
2765
```
With no config file, `updatedb` fell back to compiled-in behaviour and indexed `/proc`. So the
correct answer to "does it exclude `/proc`" on *this* machine is no — the man page describes what the
tool can be told to do, not what it did. The habit worth taking: read the config that is actually
present, and if there is none, measure.

**59.** (1) The index is stale and the file is already deleted. (2) The file exists but the colleague
lacks execute permission on a directory in the path, or read permission on the file — `locate` shows
paths its *database* knows about, not paths the caller can traverse. (3) It is on a filesystem that
is not mounted in their namespace/container, or a broken symlink. Only the first is a stale-index
problem, and `locate -e` distinguishes it from the others in one command.

**60.** Four copies because several packaging layers each ship one: the Nix environment
(`/opt/kestrel/bin`), the distribution (`/usr/bin`), the historical `/bin` (a symlink-compatible
path), and the lab's decoy in `tools/`. `execvp("echo", …)` does its own `PATH` walk with no shell
involved, so it takes the **first on `PATH`** — measured: `/opt/kestrel/bin/env echo hello` printed
`tools/echo was run`, the builtin never entering the picture.

## Dig

**61.** 
```
$ stat -c '%n %y' tools/strain-report tools-b/strain-report
tools/strain-report   2186-11-02 16:20:00
tools-b/strain-report 2187-06-10 08:05:00
```
The one that runs (`tools/`) is seven months older. The second half — "not the better one" — is the
real point: `PATH` encodes **search order and nothing else**. Not version, not mtime, not quality,
not intent. Any belief that the right one wins is a belief about whoever wrote the `PATH`.

**62.** `/labs`: after `sudo updatedb`, `locate -c /labs` → **816**, and `locate strain` returns lab
files. That is **evidence** — a path was indexed, and one hit would have been enough.

`/proc`: `locate /proc/self` → `/proc/self`, and `locate -c /proc` → **2765**. Also evidence, and it
is the opposite of what most people predict. Had those come back empty, the empty result would have
been **absence of evidence** only: consistent with a prune rule, and equally consistent with the
index being stale or the names not matching. The asymmetry is the point — a hit proves indexing, a
miss proves nothing. Confirming a *negative* needs the config, and on this station there is no
`/etc/updatedb.conf` to read (exercise 58).

**63.** It lets them put a file named after any common command in front of the real one, so the next
time root runs that command by name they run the attacker's file with root's privileges. The check is
`echo "$PATH" | tr ':' '\n'` for root's shell, plus `ls -ld` on each entry looking for anything
group- or world-writable or owned by a non-root user, and `type -a` on a handful of common commands
to see which file actually wins. Report it; do not test it by planting anything.

**64.** `find` — with `-mtime`, and it is not one of this lesson's four, which is itself the answer to
half the question. Of the four: `locate` would help only if the log predates the last `updatedb`, and
would **actively mislead** you about anything written last night, which is precisely the window an
incident is about. `type`, `which` and `whereis` answer questions about *commands*, not about data
files, and none of them will find a log at all.

---

## Authoring notes

Deliberate traps, so a tutor recognises them as intentional:

- **Ex 1–3** — the pre-`updatedb` hits are real matches on the *wrong* thing (`constraints`,
  `labs.3.gz`). A student who skims will report "locate found the strain logs".
- **Ex 12** — the +1 from `-i` is the single capital-S file seeded back in lesson 04. It rewards
  actually diffing the two outputs instead of accepting the count.
- **Ex 13** — `locate -r` is BRE, not ERE. `|` failing silently is the check.
- **Ex 37/38** — `type`/`command -v` return rc 0 for a file with no execute bit; running it is rc 126.
  This is the single most useful surprise in the lesson.
- **Ex 44** — the exercise text tells the student to predict the wrong answer on purpose. Assigning to
  `PATH` flushes the hash table; the stale-cache case only exists via 44b.
- **Ex 53** — `command ls`, `\ls` and `$(type -P ls)` all fail to bypass a `PATH` shadow. Students
  reliably offer `command` as one of the three.
- **Ex 50** — `whereis` exits 0 on failure.
- **Ex 61** — the winning copy is deliberately the older one, so "newest wins" dies on measurement.
