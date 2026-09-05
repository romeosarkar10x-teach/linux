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

---

## Added exercises 22–52

### 22–23 — where the settings come from
```
$ echo "HC=[$HISTCONTROL] HS=[$HISTSIZE] HFS=[$HISTFILESIZE] HF=[$HISTFILE] HTF=[$HISTTIMEFORMAT]"
HC=[ignoreboth] HS=[100000] HFS=[200000] HF=[/home/cadet/.bash_history] HTF=[%F %T ]
```
They are set in `~/.bashrc` — `HISTCONTROL` near the top, and `HISTSIZE`, `HISTFILESIZE` and
`HISTTIMEFORMAT` again further down, which is why the values you see are the later ones.

```
$ bash -c 'echo "[$HISTSIZE]"'
[]
```
Empty, because `~/.bashrc` is read by *interactive* shells only, and `bash -c` is not one. This is
01/01's interactive/non-interactive split with a visible consequence: history settings — and history
itself — are an interactive-shell feature.

### 24 — memory versus disk
`HISTSIZE` caps the list in memory; `HISTFILESIZE` caps `~/.bash_history` on disk. A pair like
`HISTSIZE=1000 HISTFILESIZE=200000` gives a file far larger than any single session's list, because
the file accumulates across sessions while the list is thrown away at exit. That is the usual
arrangement, and it is useful precisely when you want to search back further than today.

### 25–26 — duplicates
With `HISTCONTROL=ignoredups`, three identical commands in a row produce **one** entry; running
something else and then repeating the first produces a new entry, because `ignoredups` only compares
against the *immediately previous* line, not the whole list. With `HISTCONTROL=` (empty) all five
appear. Empty means "no options set" — it is not the same as unset in general, but here both give
default behaviour.

### 27 — patterns
`HISTIGNORE`, a colon-separated list of patterns:
```
$ HISTIGNORE='history:history *'
$ history
$ history | tail -2
```
The `history` invocations no longer appear. Two patterns are needed because `HISTIGNORE` matches the
whole line, so `history` alone does not cover `history 5`.

### 28 — zero versus no file
`HISTSIZE=0` gives an empty list — nothing is remembered in memory, so `history` prints nothing, and
nothing can be written on exit either. `HISTFILE=` leaves the list working normally for the whole
session and only suppresses the write at the end. One removes the convenience, the other removes the
record.

### 29 — forcing the write
```
$ history -a
$ tail -3 ~/.bash_history
```
`history -a` appends this session's not-yet-written lines. Note the `#<epoch>` comment lines
interleaved, because `HISTTIMEFORMAT` is set.

### 30 — counting the old file
```
$ wc -l < maint-old-history
12
$ grep -vc '^#' maint-old-history
6
```
Twelve lines, six commands — a factor of two, because every command is preceded by its `#<epoch>`
timestamp line. Counting raw lines to count commands is the mistake this exercise exists to make you
make once.

### 31 — `history -c` and the file
`history -c` cleared that shell's in-memory list, not the file. The commands *after* it accumulated
in a fresh, empty list, and were written to the file when the session ended. The file therefore
holds the commands from before the clear — written by some earlier session — and the ones from
after it, with the cleared ones' fate depending on whether they had already been written.

### 32–33 — the timeline
```
$ while read -r l; do
>   case $l in '#'*) date -u -d @"${l#\#}" '+%F %T';; *) echo "  $l";; esac
> done < maint-old-history
2186-09-22 10:40:00
  cd /var/log/station
2186-09-22 10:41:00
  ls -l
2186-09-22 10:42:11
  wc -l structural.log
2186-09-22 10:43:22
  history -c
2186-09-22 10:43:24
  ls -l
2186-09-22 10:46:30
  cat sampler-not
```
First epoch 6839203200, last 6839203590; difference 390 seconds, so six and a half minutes.

Gaps in order: 60, 71, 71, **2**, 186. Two stand out in opposite directions. The two-second gap
follows `history -c` — someone clearing history and immediately looking at something is one motion,
not two decisions. The 186-second gap before the final, incomplete command is the long one: three
minutes of nothing typed, then a command that never finished. Any account of it is inference, and
should be labelled as such.

### 34 — what history does not record
Three, each with its reason: **anything typed with a leading space**, because `HISTCONTROL` here
includes `ignorespace`; **anything typed into a program rather than the shell** — what was entered
in `vim`, `less` or a password prompt is that program's business; and **everything the commands
actually did** — the file records that `wc -l structural.log` was typed, never what it printed or
whether it succeeded.

### 35–36 — event designators
After three commands, `!-2` re-runs the second-from-last. Bash echoes the expansion before running
it, which is the whole safety mechanism.
```
$ ls sampler-notes.txt scratch
$ echo !$
echo scratch
scratch
$ echo !^
echo sampler-notes.txt
sampler-notes.txt
$ echo !*
echo sampler-notes.txt scratch
sampler-notes.txt scratch
```

### 37 — the leading space
` echo secret` does not appear in `history`, and does not appear in `$HISTFILE` after exit either —
it never entered the list, and the file is written from the list. There is no second chance for it
to be recorded.

### 38 — no such event
```
$ !nosuchprefix
bash: !nosuchprefix: event not found
$ echo $?
0
```
The message is the interesting part; the status is the surprise. The line was never run, so `$?`
still holds the status of the command *before* it. Do not use `$?` to test whether a history
expansion worked.

### 39 — quoting and expansion
`echo '!$'` prints `!$` literally. `echo "!$"` **expands** — history expansion happens before
quoting is considered, and single quotes suppress it while double quotes do not. This is the one
expansion in bash that single quotes stop and double quotes do not, and it catches people writing
`grep "foo!" file`.

### 40 — two rules
One: prefer `Alt-.` while composing and `Ctrl-R` with `Esc`, so you see the text before Enter.
Two: never put `!` inside double quotes in an interactive shell — use single quotes — because the
expansion runs before you can see what it produced.

### 41 — history files are not evidence by themselves
```
$ bash
$ HISTFILE=scratch/elsewhere-history
$ echo one; echo two; echo three
$ exit
$ cat scratch/elsewhere-history
```
The three commands are in `scratch/elsewhere-history` and not in `~/.bash_history`. A single history
file shows what a shell chose to write; it does not show what an account did.

### 42 — strong and weak
Strong: the file is a contemporaneous record with timestamps, written by the shell rather than by
the person, and it is hard to produce accidentally. Weak: it omits space-prefixed commands, omits
everything typed inside other programs, and can be redirected wholesale by setting `HISTFILE`, as
exercise 41 shows. It is therefore good evidence of *some* of what happened and no evidence at all
of what did not.

### 43 — the safe keys
`Esc` (or the right arrow) puts the found command on the line instead of running it; `Ctrl-G`
abandons the search entirely. The scenario: you `Ctrl-R` for `rm`, the first match is a longer,
more destructive `rm` than the one you were thinking of, and `Enter` runs it before you have read
the whole line.

### 45–46 — `fc` and substitution
```
$ fc -l -5
19	 echo alpha beta
20	 echo beta
...
$ fc 20
```
`fc -l` lists; `fc N` opens entry N in an editor and runs it on save; `fc -s old=new` re-runs with a
substitution. The short form is `^old^new^`:
```
$ echo alpha beta
alpha beta
$ ^alpha^gamma^
echo gamma beta
gamma beta
```
Note it applies to the **previous** command only, and only to the first occurrence.

### 47 — print, do not run
```
$ echo beta
beta
$ !!:p
echo beta
```
`:p` prints the expansion instead of running it. Nothing was executed — but the expanded line *is*
added to the history list, so a following `!!` will run it. That is the point: `:p` is "show me,
then let me press up".

### 48 — head and tail of a path
```
$ echo /labs/01-shell-and-terminal/06-history/sampler-notes.txt
$ echo !$:h
echo /labs/01-shell-and-terminal/06-history
$ echo !!:t
echo 06-history
```
`:h` strips the last component (head), `:t` keeps only it (tail). Note the second one operated on
the *previous* line's last word, which was already the directory — a small demonstration of why
chaining these is easy to get wrong.

### 49 — `histverify`
```
$ shopt -s histverify
```
With it set, `!!` and friends put the expanded line on your prompt for editing instead of running it
immediately; you press Enter yourself. It converts every history expansion into the safe form from
exercise 47. `shopt -u histverify` turns it off; the default here is off.

### 50 — `history -n`
`history -r` reads the whole file and appends all of it to your list, so running it twice gives you
duplicates. `history -n` reads only lines that have been added since this shell last read the file,
which is what you want in a shell you keep open next to others.

### 51 — `histappend`
`shopt -s histappend` makes the shell append to the file on exit instead of overwriting it. Default
here is off:
```
$ shopt histappend
histappend     	off
```
It fixes the case where the last shell to exit destroys another shell's contribution. It does not
give you a *live* shared history — for that you still need `history -a` and `history -n`, because
nothing is written until exit.

### 52 — dates in one pass
```
$ while read -r l; do
>   case $l in '#'*) date -u -d @"${l#\#}" '+%F %T';; *) echo "  $l";; esac
> done < maint-old-history
```
`date -d @SECONDS` converts an epoch; the `while read` loop is Chapter 8's material, and `date`'s
`-d` is documented in its own man page. A `case` and a loop are reaching ahead — Chapter 8 owns
both — but the alternative is running `date` by hand six times, which is also a correct answer.
