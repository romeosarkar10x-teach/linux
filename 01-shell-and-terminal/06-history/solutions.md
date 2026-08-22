# 01/06 — Solutions

> **Student: do not read this file.**
> **Agents:** steering only. See `docs/AGENT_MODES.md`.

No flag in this lesson. The chapter's flag is in `07-incident-01`, and it depends directly on
exercise 9 here.

**Verified against the course image.**

### 1 — last ten
```
$ history 10
  501  2187-06-14 09:02:11 cd /labs
  ...
```
Timestamps appear because the image sets `HISTTIMEFORMAT` in `.bashrc`.

### 2 — re-run the previous
`!!`. `sudo !!` is the form everyone actually uses.

### 3 — last argument
```
$ wc -l sampler-notes.txt
2 sampler-notes.txt
$ head -1 !$
head -1 sampler-notes.txt
Sampler notes, deck 3.
```
The middle line is bash echoing the expansion before running it. That echo is the safety feature —
it is the only chance you get to see that `!$` grabbed something other than what you meant.

### 4 — search without running
`Ctrl-R`, type a fragment, then `Esc` (or right arrow) to drop the match onto the line without
running it. `Ctrl-G` also exits without running but discards the match entirely.

### 5 — search and run
Same search, `Enter` at the end. Prefer inspecting first: the match shown is the *most recent* one,
older matches are hidden behind it, and running blind means running whatever happened to be found.

### 6 — three recall forms
```bash
!512              # by number
!cat              # most recent starting with "cat"
!?strain?         # most recent containing "strain"
```
On a shared machine, avoid the prefix form: "most recent command starting with `rm`" is not a thing
you want to run without looking.

### 7 — list versus file
```bash
$ echo distinctive-marker-9134
$ history | tail -2                      # present
$ tail -3 ~/.bash_history                # absent
$ history -a
$ tail -3 ~/.bash_history                # present
```
`history -w` also works but overwrites the file with the whole list, which loses another shell's
appended lines. `-a` is the right tool.

### 8 — reading maint-old-history
**Six commands**: `cd /var/log/station`, `ls -l`, `wc -l structural.log`, `history -c`, `ls -l`,
`cat sampler-not`.

Thirteen lines, but the `#` lines are not commands — they are seconds since 1970, written before
each command because that session had `HISTTIMEFORMAT` set.

Last **complete** command: `ls -l`.

### 9 — the truncated last line
It was going to be `cat sampler-notes.txt` — that file is in the same lab directory.

The reason: the history file is written when the shell exits. A session that ends abruptly — killed,
disconnected, machine powered off — can be interrupted partway through that write, leaving the final
line cut mid-word.

Reject "it was a typo". A typo gives you wrong letters; this gives you the *right* letters and then
nothing. The line stops, it is not wrong.

**This is the lesson 01/07 depends on.** A student who has not internalised it will try to
brute-force the incident.

### 10 — what history -c does not do
It clears the in-memory list. It does not delete or truncate `~/.bash_history` at that moment.

The commands after it are in the file because they were typed *after* the clear, entered the
now-empty list, and were written out when the session ended.

The commands *before* it survive because they had already been written by an earlier session — the
clear never reached the disk at all. This is exactly why "clear my history" is not a thing you can
do with one command, and why people who try end up with strange, partial files.

### 11 — the leading space
```bash
$ bash
$  echo secret-token-here
$ history | tail -3
```
The command is absent. `echo "$HISTCONTROL"` → `ignoreboth`, which is `ignoredups` plus
`ignorespace`.

The word `ignorespace` never literally appears, which catches people. `ignoreboth` includes it.

Legitimate use: keeping a token or password out of a plain-text file that sits in your home
directory and is readable for as long as the account exists.

### 12 — a tiny HISTSIZE
```bash
$ bash
$ HISTSIZE=3
$ cd scratch; touch a b c d e     # five distinct commands
$ history
```
Roughly three entries — older lines fall off the front.

Exit, and the main session's `HISTSIZE` and list are untouched. A child's variables do not
propagate to its parent, which is 01/01's process model and Chapter 11's environment model arriving
together.

### 13 — `!!` twice (Experiment)
```
$ echo one
one
$ echo two
two
$ !!
echo two
two
$ !!
echo two
two
```
The third line ran `echo two`. The fourth ran `echo two` **again** — because line three's expansion
was recorded in history as `echo two`, so "the previous command" is now that.

The intuitive prediction is that the fourth would run `echo one`, walking backwards. It does not.
The reference always means "the line before this one", and the line before is the expansion.

### 14 — `!$` and `!^` (Experiment)
```
$ ls sampler-notes.txt scratch
sampler-notes.txt

scratch:
$ echo !$
echo scratch
scratch
$ echo !^
echo scratch
scratch
```
Both give `scratch`. The intuitive prediction for the third is `sampler-notes.txt`, and it is wrong
for the same reason as exercise 13: by the time it runs, the previous command is `echo scratch`, and
`scratch` is that command's first argument as well as its last.

Verified in the image. A student reporting `sampler-notes.txt` as observed output did not run the
three lines in order.

### 15 — two shells (Experiment)
B does not see A's command — two processes, two lists, and nothing has touched the disk.

After A exits (writing its list) and B runs `history -r`, B sees it. Live sharing would require
every shell to write on every command and re-read constantly, which is what people build with
`PROMPT_COMMAND='history -a; history -r'` — Chapter 11 territory.

### 16 — HISTFILE unset versus empty (Stretch)
Both suppress the write. In bash, an empty `HISTFILE` and an unset `HISTFILE` both result in no
history file being written on exit.

**The correct finding is that the distinction did not matter here**, and a student who reports that
has done the exercise properly. The 01/04 distinction is real at the level of the shell's variable
table; whether any given program acts on it is a separate, empirical question. That is the lesson.

### 17 — where `!$` bites (Stretch)
```bash
$ cp sampler-notes.txt maint-old-history scratch/
$ head -1 !$
head -1 scratch/
head: error reading 'scratch/': Is a directory
```
The last argument was the destination directory, not a file. With `Alt-.` the text appears on the
line while you are composing it, and you see `scratch/` before pressing Enter. With `!$` you find
out afterwards.

Better examples are ones where running it would matter — a `rm` whose last argument is not what the
student expected.

### 18 — classify history (Stretch)
```
$ type history
history is a shell builtin
```
The list lives in the shell process's memory. A separate program would be a child and could not read
it — and could certainly not show commands that have not been written to any file. Same argument as
`cd` and `unset`; that is the three the probe asks for.

### 19 — decoding the epoch (Dig)
```
$ date -d @6839203404 '+%F %T'
2186-09-22 10:43:24
```
That is the `ls -l` which is the last complete command. `man date`, the `-d`/`--date` option, and
the `@` notation described under DATE STRING.

Second zero is 1970-01-01 00:00:00 UTC. The container runs UTC, so no timezone adjustment applies.

Watch for students converting `6839203590` (the truncated `cat sampler-not` line) and calling it the
last complete command. It is the last *line*, not the last complete command.

### 20 — loading another history file (Dig)
```bash
$ bash                            # child shell -- important
$ history -r maint-old-history
$ history 7
   10  2186-09-22 10:40:00 cd /var/log/station
   11  2186-09-22 10:41:00 ls -l
   12  2186-09-22 10:42:11 wc -l structural.log
   13  2186-09-22 10:43:22 history -c
   14  2186-09-22 10:43:24 ls -l
   15  2186-09-22 10:46:30 cat sampler-not
```
Verified working in the image.

Why not in the main shell: those lines are now part of *your* list, and on exit they get written
into *your* history file. Another account's commands are then permanently mixed into your own
record, dated 2186, with nothing marking them as imported. A validator — or anyone — reading your
history later would have no way to tell them apart.

That is worth saying to the student explicitly. It is also a preview of Chapter 15, where the
integrity of exactly this kind of record is the whole exercise.

### 21 — substitution on recall (Dig)
```
$ wc -l sampler-notes.txt
2 sampler-notes.txt
$ ^sampler-notes.txt^maint-old-history
wc -l maint-old-history
13 maint-old-history
```
Or the long form: `!!:s/sampler-notes.txt/maint-old-history/`.

`man bash` → HISTORY EXPANSION → Event Designators, Word Designators, Modifiers. The `^old^new`
shorthand is documented at the end of the Event Designators subsection.

It replaces the **first** occurrence only. `!!:gs/old/new/` replaces all of them.
