# 09/04 — Solutions: kill, pkill and pgrep

Pids differ; everything else should not.

---

## Warmup

**1.** All three agree. `$!` is the shell's record of the job it just started, `ps -ef | grep` is a
text search over a snapshot, `pgrep -f` is the same search done by a tool that knows it is searching
processes.

**2.** The `grep` itself:
```
cadet  8211  8203  0 09:14 ?  00:00:00 grep --color=auto panel-mon
```
`ps` wrote its output while `grep` was already running, and `grep`'s own command line contains the
pattern.

**3.** `pgrep` excludes itself deliberately. It knows its own pid and drops it from the results —
something `grep` cannot do, because `grep` is not reading the process table, it is reading a stream
of text that happens to describe one.

**4.** `kill` would have signalled all three, with no output. You would have known only if you looked
afterwards. That is the whole lesson: the failure is silent and the only defence is running `pgrep`
first and *reading* it.

**5.** `pkill -f panel-mon` — intended for `panel-mon`, it also matched `panel-monitor`, which was not
stray. Forty-one minutes with no panel readings.

**6.** Keep the prediction. Most people write "panel-mon".

## comm

**7.** rc 1. `pgrep` with no `-f` searches `comm`, which for `bin/panelctl` is `bash` — the script is
not the executable, `bash` is.

**8.**
```
    PID COMMAND         COMMAND
   8221 bash            bash bin/panelctl 300
```
`pgrep` searched the middle column. `panelctl` appears only in the third.

**9.** Default matching searches the executable's name; `-f` searches the whole command line as the
kernel recorded it in `/proc/<pid>/cmdline`.

**10.** `panelwatch`. `bin/deckwatch` ends with `exec bin/panelwatch …`, and `bin/panelwatch` is a
symlink to `perl`. `comm` is the basename of the file that is *currently executing* — not the script
you typed, not the interpreter's real name, and not the path.

**11.**
```
panel-watchdog-
```
Fifteen characters, cut mid-word. The real name is `panel-watchdog-daemon`, 21. `comm` is a
fixed-width field and it has always been fifteen.

**12.**
```
pgrep: pattern that searches for process name longer than 15 characters will result in zero matches
Try `pgrep -f' option to match against the complete command line.
```
rc 1. The suggestion works: `pgrep -af panel-watchdog-daemon` finds it. So does `pgrep -alx
'panel-watchdog-'`, matching the truncated name — which works and which you should never write down,
because it depends on where the truncation lands.

## The substring problem

**13.** Two pids:
```
8990 bash bin/panel-mon 300
8991 bash bin/panel-monitor 300
```
`panel-mon` is a substring of `panel-monitor` and the pattern is unanchored.

**14.** You would have stopped both. `panel-monitor` is the one the shift log says mattered.

**15.**
```
$ pgrep -axf 'bash bin/panel-mon 300'
8990 bash bin/panel-mon 300
```
`-x` requires the *whole* string to match, and with `-f` the whole string is the whole command line —
which starts with `bash`, because the kernel recorded the interpreter as argv[0]. Leave `bash` out and
`-xf` matches nothing.

**16.** `pgrep -af 'panel-mon [0-9]+$'` returns the one pid. So does `pgrep -af 'panel-mon '` with the
trailing space, because `panel-monitor` has an `i` there, not a space. At three in the morning the
trailing space is the one people actually type; the anchored ERE is the one that survives being run
against a command line whose arguments you did not predict. Either beats `-xf`, which breaks the
moment an argument changes.

**17.** `pgrep -cf panel` gives 3: `panel-mon`, `panel-monitor`, `panelctl`. `-c` is right when you
already know what you are matching and want to check a number stayed the same — a monitoring check. It
is a way to avoid looking when you use it *instead* of `-a` before a `pkill`.

**18.** Four, including `pane`. As an ERE, `panel*` is: `p`, `a`, `n`, `e`, then `l` **zero or more
times**. `*` is a quantifier on the preceding character, not a wildcard. `pane` matches with zero
`l`s.

**19.** `panel.*` — `panel` followed by any characters. Or just `panel`, since the match is unanchored
anyway, which is the better answer and the one that shows you understood exercise 13.

**20.** `pgrep -cf 'bin/'` gives 3 here, which is the trap in miniature: the number is small today
because the station is quiet, and nothing about the pattern keeps it that way. No. `bin/` describes where
a program lives, not what it is, and it is a pattern that will grow new matches as the station changes
without anyone touching your command.

## Selecting properly

**21.**
```
$ pkill -ef panel-monitor
bash killed (pid 8991)
```
A receipt. Without `-e` a successful `pkill` prints nothing at all, which is indistinguishable from a
`pkill` that matched nothing except by rc.

**22.** It reported `bash`, not `panel-monitor`. `-e` prints the process **name** — `comm` — even
though the selection was made with `-f`. So the receipt confirms *how many* and *which pids*, and is
useless for confirming *what*. Read the pids against your `pgrep -a`.

**23.** `pgrep -u cadet -c` gives 33; `ps -e --no-headers | wc -l` gives 57. The difference is
everything cadet does not own, which on this station is nothing — plus, crucially, `pgrep`'s own
counting rules. Compare the two on a machine with more than one user and the number means something;
here it mostly tells you cadet owns most of the box.

**24.** `pgrep -u root -af panel` prints nothing, rc **1**. Not a failure: rc 1 is "no processes
matched", which is a perfectly good answer to a question. Chapter 6's `grep` had the same convention.

**25.** `pgrep -a named` finds nothing — `comm` is `bash` for all four. `pgrep -af named` finds four.
`pgrep -af 'named gamma'` selects one, and the field that made it possible is **argv**: the four
processes are identical in every way except their arguments, and only `-f` can see those.

**26.** `-n` gives `delta`, `-o` gives `alpha` — the order they were started in. Note that `-n` and
`-o` are about start *time*, not pid, and those usually but not always agree.

**27.**
```
$ pgrep -aP 9039
9042 bash bin/panel-mon 300
9043 bash bin/panel-mon 300
9044 bash bin/panel-mon 300
```
`-P` matches on the ppid field and it takes a **pid**, not a pattern — it is a filter, not a search.

**28.** Still there, ppid now **1**. Same finding as lesson 03: a signal reaches the process you
named.

**29.**
```
pgrep -aP <parent>          # read it
pkill -P <parent>           # then the children
kill <parent>               # then the parent
```
Children first, because once the parent is gone `-P <parent>` selects nothing and you have lost the
only cheap way to name them.

**30.** It counts every process cadet owns that does **not** match `panel` — 65 on this container, including
your own shell, your `pgrep`, and pid 1. `-v` is dangerous with `pkill` because the set it selects is
defined by what you did not think of, and it grows every time the station starts something new.

## Signalling

**31.** HUP (1), replacing TERM (15), which is `pkill`'s default exactly as it is `kill`'s.

**32.** Both work. `-HUP` is unambiguous for signal names; the short *numeric* form is where it gets
awkward, because `pkill -9 pattern` reads fine but `pkill -1 pattern` looks like a typo for something
else, and `pgrep`/`pkill` also take `-<number>` options that are not signals in other tools. Write
`--signal` in anything anyone else will read.

**33.** It did not print `panel-mon: done`, and if it had held a lock, a temporary file or a half-
written line, those would still be there. Lesson 03, `bin/tidy`.

**34.** rc 1, not an error — nothing matched.
```
pkill -ef panelctl || echo "panelctl was not running"
```

**35.** `killall panel-mon` says `panel-mon: no process found`. `killall` matches the process **name**
exactly — `comm` again — and `comm` is `bash`. `pkill -f` matched because it looked at the command
line. Two tools, two defaults, and the one with the more alarming name is the more conservative.

**36.** It would send TERM to every process whose `comm` is `bash` — which on this station is your own
interactive shell, every lab script currently running, and anything a background job is using as an
interpreter. You would be logged out by your own command, and the receipt would arrive after you
stopped being able to read it.

**37.** The fleet's pgid is not its pid: the fleet was started from a script, and the script's shell
was the group leader. Its children share the same pgid. A process group is "everything started as
part of this job", and it is set by whoever created the job, not by the processes in it.

**37a.** From an interactive shell each background job gets its own process group, so
`kill -TERM -<pgid>` takes the fleet and all its children in one signal, and `pgrep -af panel-mon`
comes back empty. This is the tool for "stop this job and everything it started".

**37b.** In a **script** there is no job control: the script, the fleet, and the fleet's children are
all in one process group — the script's. So `kill -TERM -<pgid>` includes the script that is running
the command, and the script dies with status 143 before it reaches the next line. The group was set by
the shell that started everything, and in a non-interactive shell that is one group for the whole run.

**38.** One pid: you can get one process wrong. A process group: you can get a job wrong, which is
bounded by whatever the job started, and possibly your own script. `pkill -u cadet`: you can get
everything wrong, including your shell, in nine characters. The ranking is the same as the number of
processes you did not name individually.

## Reporting

**39.**
> 2187-03-02 — ran `pkill -f panel-mon`. That pattern is unanchored, so it also matched
> `panel-monitor`, which was not stray and which I stopped. Panel readings resumed at 14:23 after I
> restarted it.

Note it says what was matched. "I meant panel-mon" is not information anybody can act on.

**40.**
```
pgrep -af 'panel-mon [0-9]+$'
pkill -ef 'panel-mon [0-9]+$'
```
Same pattern in both, so that what she reads is what runs. Changing the pattern between the preview
and the action is the only way to make the two-command rule useless.

**41.** `pgrep -acf panel` (how many), `pgrep -af panel` (which ones), and
`ps -o pid,etime,args -p $(pgrep -df, -f panel)` (how long they have been up — a process that started
this morning and one that started in 2186 are different decisions). Any three that turn the pattern
into a list count.

**42.** "Read the `pgrep -a` output before you turn it into a `pkill`, and run the same pattern in
both."

## Experiment

**43.** Yes:
```
$ pgrep -a sleep | grep 168
168 [sleep] <defunct>
```
`pkill` would return success and change nothing — lesson 03, exercise 42. So a script that treats
`pgrep --quiet name` as "still running" will spin forever waiting for a zombie to disappear. (There is
no `-q`; the long form is `--quiet`.) The fix is to check the state, not the existence — `pgrep -r Z`
selects zombies and `pgrep -r S,R` selects the ones that are actually there.

**44.** You can catch it if the other `pgrep` is slow enough. It excludes **itself** — its own pid —
not other `pgrep` processes. There is no special case for the name.

**45.** `pgrep -f panel-mon` does not find `scratch/pm`; `pgrep -f 'scratch/pm'` does. The rename
changed the command line, which is the only thing `-f` searches. It changed nothing about what the
program is or does — same bytes, same behaviour, invisible to your pattern.

**46.** Nothing in `pgrep` can distinguish them: same `comm`, same command line, same user, same
parent. `-n` and `-o` can pick one by age, and that is a choice about which, not a way to identify
either. If you need to tell two processes apart you need the pid — from `$!` when you started them,
from the start time, or from something inside the process (lesson 06). This is why "identify the job
by its command line" is a design decision with a lifespan.

**47.** rc 0, meaning "at least one matched". It does not say how many. `pgrep -cf` before, or
`pkill -ef` and count the receipt lines.

**48.**
```bash
preview() {
  local n
  pgrep -a "$@" || { echo "preview: nothing matches"; return 1; }
  n=$(pgrep -c "$@")
  read -r -p "kill these $n? [y/N] " a
  [ "$a" = y ] && pkill -e "$@"
}
```
`preview -f panel-mon` shows two, and the number is the part that catches the mistake — you expected
one.

**49.** It is not faster; it is two commands with a prompt in the middle instead of two commands. It
is worth having because it makes the pattern *identical* in the preview and the action, which is the
error the two-command habit still allows.

**50.** `pgrep -af '.'` prints `168 [sleep] <defunct>` for the zombie. Its `cmdline` is empty, so
`pgrep` fell back to the name in brackets — the same convention `ps` uses for a process with no
readable command line. That is why the two counts agree: `-f` does not simply skip processes with no
command line.

## Stretch

**51.** `--ns PID` restricts matching to processes in the same namespaces as that pid, and `--nslist`
picks which namespaces to compare. It is for a host that can see into containers. Inside this
container everything you can see is already in your namespaces, so the filter never removes anything.

**52.**
```
ps -o pid,etime,args -p $(pgrep -d, -u cadet -v -f "$$") | awk '$2 ~ /-|[0-9]+:[0-9]+:/'
```
`pgrep` did the selection — user, and excluding your own shell. `ps` did the age, because `pgrep` has
no notion of elapsed time and `etime` is a `ps` format field. Splitting the work that way round is the
general pattern: select with `pgrep`, describe with `ps`.

**53.** `pgrep -a` shows you the selection; a real `--dry-run` would show you the *action* — which
signal, to which pids, under which permissions, including the ones `pkill` would fail to signal. The
gap is small, and the day it matters is the day half your matches are owned by another user and you
find out one at a time.

**54.** `-x` is cheaper — one character, available now, and you can do it yourself. Renaming is more
reliable, because it fixes the problem for everybody who ever types that pattern including the people
who have not read the shift log. From where you sit you can only do the cheap one, which is why the
shift log entry matters: it is how the expensive fix eventually gets made.

**55.** Add the full command line, the start time and the environment — `ps -o pid,lstart,args` and
`cat /proc/<pid>/environ | tr '\0' '\n'` — and write it to a file before the `pkill`, not to the
terminal. The terminal scrolls, and the environment cannot be recovered after the process is gone.
