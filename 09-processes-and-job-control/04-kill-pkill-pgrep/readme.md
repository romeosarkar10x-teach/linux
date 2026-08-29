# 09/04 — kill, pkill and pgrep

> Killing by name is fast and occasionally kills something you did not mean. On a station with one
> sysadmin, "occasionally" is your problem.

Lesson 03 gave you `kill PID` and a table of signals. That works and it does not scale: you found the
pid with `ps` and your eyes, and doing that for eleven processes is eleven chances to mistype a
number. So there are tools that select by name — and the entire risk of this lesson is that they
select *more* than you meant, silently, and then act.

`pgrep` prints the pids that match. `pkill` sends a signal to the same set. They take the same
options and do the same matching, and the only difference between them is whether anything happens.
Which gives you the one rule this lesson exists to install: **run `pgrep -a` first, read the list,
then run the same command as `pkill`.** Not because you are being careful — because the list is the
only place the mistake is visible.

The mistakes are all about what "the name" is. By default these tools match `comm`: the basename of
the executable that is running, **truncated to fifteen characters**. Not the arguments, not the path,
and — this is the one that catches everyone — not the name of your script. A bash script's `comm` is
`bash`. Every script in this lab is invisible to a plain `pgrep` and findable with `-f`, which
matches the full command line instead.

`-f` solves that and introduces the second problem, because the pattern is a **regular expression**,
the ERE dialect from Chapter 6, and it is unanchored. `panel-mon` matches `panel-monitor` too. There
is no warning; there is one extra pid in the list. `notes/incident-log.txt` records the day that
happened on this deck: forty-one minutes with no panel readings, caused by a command that matched
exactly what it said it would.

So: `-a` to see what you matched, `-x` for a whole-name match, `-c` to count before you look, `-u` to
scope to a user, `-P` for one parent's children, `-n` and `-o` for newest and oldest. And `pkill -e`,
which says what it killed after it has killed it — worth typing every time, because it turns a silent
action into a receipt.

## What you will be able to do

- [ ] Explain the relationship between `pgrep` and `pkill`, and why you run one before the other
- [ ] Say what `comm` is, how wide it is, and why a script's `comm` is not its name
- [ ] Choose between the default matching and `-f`, and say what each one searches
- [ ] Predict what an unanchored pattern will match, and find the extras before you signal them
- [ ] Treat the pattern as an ERE, not a glob, and say what `panel*` really means
- [ ] Use `-a`, `-l`, `-c`, `-x`, `-v`, `-u`, `-U`, `-n`, `-o`, `-P` and `-r` deliberately
- [ ] Send a signal other than TERM with `pkill --signal`
- [ ] Explain why `ps -ef | grep foo` finds the `grep` and `pgrep foo` does not find itself
- [ ] State how `killall` differs from `pkill`, and when the difference bites
- [ ] Signal a whole process group or a whole user's processes, and say why that is a bigger hammer
- [ ] Write a selection you would be willing to hand to somebody else to run

## Files

```
bin/panel-mon SECS        harmless. Also a substring of the next one
bin/panel-monitor SECS    a different program, and the one that matters
bin/panelctl SECS         a bash script; prints its own comm to prove the point
bin/pane SECS             four letters. `panel*` matches it; work out why
bin/crew-report SECS      innocent bystander
bin/deckwatch SECS        execs a symlink, so its comm is neither bash nor deckwatch
bin/deckwatch-long SECS   same, through a 24-character name. Watch it get cut
bin/fleet N SECS          a parent with N known children, for -P
bin/named LABEL SECS      several identical processes told apart only by argv
notes/select.txt          matching, options, and the rule
notes/incident-log.txt    the March entry. Read it before you type pkill
notes/page.txt            rhea, who is not saying don't
scratch/                  yours
```
