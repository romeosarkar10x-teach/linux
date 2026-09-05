# 03/06 — Exercises

**Lab:** `/labs/03-files-links-and-types/06-incident-03`
Seed it with `kestrel seed 03/06`. Reset with `kestrel reset 03/06`.

In-chapter tools only: `ls`, `stat`, `file`, `ln`, `readlink`, `touch`, `find` (`-type`, `-xtype`,
`-newer`), `cat`, `head`, `tail`, `wc`, `cd`, `pwd`, `echo`. No `grep`, no `find -name`.

Do not create, delete or repair any link until exercise 5 is written down. Do not modify anything
in `deck3` at all.

Keep a log. Commands that failed count as findings — write them down with their exact error and
exit status.

---

## Warmup

**1.** `ls -lF deck3/console`. Four entries. For each one, write down the type letter, the target
path exactly as printed, and the size in the size column.

**2.** The four sizes in exercise 1 are not the sizes of any file on this station. Work out what
number `ls` is actually printing for a symlink. Prove it on one entry with `echo -n <target> | wc -c`.

**3.** `ls -l deck3` and `ls -F deck3`. Seven directories. Say in one line what each one appears to be
for, from its name and its contents, without following any link yet.

## Core

**4.** Follow each console entry exactly one hop: `readlink deck3/console/*`. Which entry's one-hop
target is itself a link? How can you tell from this output alone — and can you?

**5.** Now resolve all four to the end: for each, run `readlink -f deck3/console/<name>; echo $?`.
Record the printed path and the exit status for all four. **This is the written statement rule
1 demands.** One of them prints nothing. Say what the empty output plus the exit status means.

**6.** Which console entry is a link to a directory? Show two pieces of evidence: something in the
`ls -lF` output of exercise 1, and something you get by listing *through* the link.

**7.** `ls -l deck3/console/panel-current` and then `ls -lL deck3/console/panel-current`. The two
lines disagree about type, size, permissions and date. Explain each disagreement in terms of which
file each command is describing.

**8.** `stat deck3/console/handbook` and `stat -L deck3/console/handbook`. Report the inode number
from each. Which one is the link's own inode, and what is stored in that inode?

**9.** Get the whole chain in order. Starting at `deck3/console/panel-current`, write down every
name you pass through and every hop, until you reach something that is not a link. How many hops,
and what kind of link is each hop?

**10.** `cat deck3/console/strain-feed`. Report the exact error and the exit status. Then
`ls -l deck3/console/strain-feed` and `stat -c '%n %F %s' deck3/console/strain-feed`. Both of those
succeed. Explain in one sentence why the listing works when the read does not.

**11.** Write down the full target path of the dead link, character for character. That path is what
rhea asked for. Say what kind of place it names, from its shape alone, and which part of it is not
under `/labs`.

**12.** `find deck3 -xtype l`. What did it find, and how many? Now `find deck3 -type l` and count.
State the difference between the two tests in one sentence.

**13.** `find deck3 -type l -exec ls -l {} \;` — or `ls -l` on each by hand. There are five symlinks
in the tree, not four. Where is the fifth, and what is it doing?

**14.** Every symlink in this tree has a timestamp of its own. `stat -c '%n %y' ` each of the five.
Four of them share a date. One does not. Which, and how much later?

**15.** `ls -l deck3/readings`. Three files, same size, same date, same-looking names. Is anything
in that listing different between them? Point at the exact column.

**16.** `ls -i deck3/readings/*` and `stat -c '%n %i %h' deck3/readings/*`. State exactly which of
the three files are the same file, and which is a separate file, and what each of the two numbers
told you.

**17.** `cat` all three files in `deck3/readings`. Identical bytes. Given that, explain why exercise
16's answer is still true — and what you would have concluded if you had only ever run `cat` and
`wc -c`.

## Experiment

For each of these: **write your prediction down before you run it.** Then run it. The part you got
wrong is the exercise.

**18.** Predict the inode number and link count of `deck3/store/panel-log.txt` and of
`deck3/archive/panel-07.log`. Predict whether `readlink -f deck3/console/panel-current` will name
one, the other, or both. Then run `stat -c '%n %i %h' ` on both and `readlink -f` on the link.
Explain why `-f` stopped where it did.

**19.** Predict what happens if you `cd deck3/console/logs` and then run `pwd`. Predict the exact
string. Then run it, and also run `pwd -P`. Account for the difference.

**20.** Predict what `touch -h -d '2187-06-01 00:00'` does to a dangling symlink, given that the
target does not exist. Then predict what the same `touch` *without* `-h` does. Predict it twice:
once for a link aimed at `/nope/nothere`, where the target's parent directory does not exist, and
once for a link aimed at `missing.txt` in a directory that does exist. Do not run any of this on
`deck3` — build both links in a fresh directory under `/tmp` and run all four commands there.
Report the exit statuses, and say what `touch` without `-h` is actually trying to do.

## Stretch

**21.** Build the whole thing yourself in `/tmp/maze`, from nothing: a regular file, a hard link to
it under a second name, a symlink to that second name, and a symlink to that symlink. Then break it
in the same way this lab is broken — delete the regular file's *first* name only, and report which
of your links still resolve and why. Then delete the second name too, and report again.

**22.** Using only timestamps, order the events in `deck3` from oldest to newest: the five symlinks,
`notes/dangling.txt`, and the three files in `archive/`. Then use `find deck3 -newer <file>` to
confirm one of your orderings without reading a single date.

**23.** `deck3/docs/panel-handbook.txt` claims the console is built so a panel can be swapped without
moving a log file. Test that claim: from the lab, using only the console, read the last line of the
panel-07 log without ever typing `archive` or `store`. Show the command.

## Dig

**24.** `cat deck3/notes/dangling.txt`, and report its mtime. The note gives a reason for leaving the
broken link in place. State the reason in your own words, and then state what the note does **not**
tell you: who wrote it, when the target actually disappeared, and whether the mtime is honest.

**25.** The dead link's target path and the note's mtime are the same day. `deck3/archive/panel-07.log`
has a line about that day too. Lay out the three pieces of evidence as a timeline with the dates,
and mark which parts are recorded fact and which are your inference. Be strict about the second
list.

**26.** Two files in this lab share an inode and are in different directories. Two other files share
an inode and are in the same directory. One of those pairs is load-bearing for the incident and the
other is not. Say which is which, and say what the pair that is *not* load-bearing would have looked
like to someone who checked with `ls -l` and stopped.

## Flag

**27.** The flag is not stored as a flag anywhere in this lab. Follow the live chain from
`deck3/console/panel-current` to its end and read the last line of the file you land on.

Take the last five words of that line. Lowercase them, join them with underscores, and wrap the
result:

```
KESTREL{...}
```

Submit from the VM (not inside the container):

```
kestrel flags submit 'KESTREL{...}'
```

If it is rejected, count your words again from the end of the line — the punctuation before them is
not a word.

## Core — the console as evidence

**28.** `file deck3/console/*`. Four lines. Quote them. One of the four says something none of the
others do, and it is the same finding you made in exercise 5 by a different route. Say which route
you would put in a report, and why.

**29.** `stat -c '%n %F %U %A' deck3/console/*`. All four lines are identical apart from the name.
Say what that proves about the difference between the working links and the dead one — and where
that difference *is* recorded, given that it is not in any of those four fields.

**30.** `find deck3 -xtype l` returns one path. `find -L deck3 -type l` returns the same one. Explain
why `-L` — "follow symlinks" — makes `-type l` report only the **broken** link. Then say which of the
two forms you would rather type from memory at three in the morning.

**31.** `find deck3 -xtype d` lists nine paths, and one of them is not a directory. Name it, and say
what `-xtype d` actually tested for it.

**32.** `ls -F deck3/console` gives all four entries the same marker. `ls -lF deck3/console` gives
one of them something extra — not on the name, on the far side of the arrow. Run both, report where
the extra character appears and which entry gets it, and explain what `ls` had to do to know to print
it. Bear in mind exercise 37 of 03/03, where `-F` could not tell a broken link from a working one:
say why this case is different.

**33.** Count the symlinks in the whole tree with `find deck3 -type l | wc -l`, then count the ones
that resolve. Give both numbers and the arithmetic that connects them to the audit line in
`archive/panel-07.log`. Say whether the log's count agrees with yours, and if it does not, say which
directory the log's author was standing in.

**34.** `ls -lL deck3/console` on the whole directory rather than one entry. Report what happens to
the dead entry's line. Say what `ls` does when `-L` fails on one entry out of four, and what exit
status you get.

## Core — the copy, the link, and the count

**35.** `stat -c '%n %i %h %s %y' deck3/readings/*`. Of the five fields, name every one that would
have let you separate the pair from the copy, and every one that would not. There are more of the
second kind than the first.

**36.** Append a line to `deck3/readings/sensor-a.txt` — copy the directory to `/tmp` first, this
lab's `deck3` is not to be modified. In the copy, show which of the other two files changed. Then
say what that means for someone who "backed up" `sensor-b.txt` and thinks they have a second copy.

**37.** `deck3/store/panel-log.txt` and `deck3/archive/panel-07.log` share an inode across two
directories. `sensor-a.txt` and `sensor-b.txt` share one inside a single directory. Say which of the
two arrangements is easier to miss with `ls -l`, and why the *directory* is what makes it so.

**38.** Add up the sizes reported by `ls -l` for everything under `deck3` and compare it to
`du -sh deck3`. State which of the two double-counts what, and name the two mechanisms responsible —
one for the symlinks, one for the hard-linked pair.

**39.** `readlink -f deck3/console/panel-current` names `store/panel-log.txt` and not
`archive/panel-07.log`, even though those are the same file. Explain why in terms of what
`readlink -f` resolves and what it does not. Then say what command *would* give you the other name.

**40.** From exercise 39: if the incident report says "the console reads from `store/`", is that a
true statement, a false one, or an incomplete one? Defend the answer in two sentences, and say what
you would write instead.

## Experiment — predict before you run

**41.** **Predict first.** Predict what `cat deck3/console/logs` does, given that `logs` resolves to a
directory. Predict the exact error. Then run it, and run `ls deck3/console/logs` as well. Say which
of the two verbs a directory supports and which it does not.

**42.** **Predict first.** Predict the output of `wc -c deck3/console/panel-current`. Predict the
number before you run it, and say which of the four candidate numbers you are choosing between — the
link's size, the middle link's size, the log's size, or an error. Then run it.

**43.** **Predict first.** Predict what `find deck3 -newer deck3/notes/dangling.txt` returns. Predict
how many paths and which. Then run it and explain why the count is what it is — including why one
file appears under two names.

**44.** **Predict first.** In a fresh `/tmp` directory, make a symlink `l` to a file that exists, then
`touch -h -d '2187-06-01 00:00' l` and `touch -d '2187-06-01 00:00' l`. Predict which of the two
changes the link's timestamp and which changes the target's. Check both with
`stat -c '%n %y' l` and `stat -L -c '%n %y' l`.

**45.** **Predict first.** Predict what `cp deck3/console/strain-feed /tmp/sf` does. Then predict
`cp -P` and `cp -a`. Run all three in `/tmp` and report the three results. Explain the first one in
terms of what `cp` must do before it can copy anything.

## Stretch

**46.** The dead link's timestamp is 2187-05-08 and the other four are 2187-03-30. State what that
gap does and does not establish. Specifically: does it prove the link was created on the 8th, does it
prove the target existed then, and does it prove anything about who did it? One sentence each,
marked fact or inference.

**47.** The note's mtime is 2187-05-22 06:02 and `archive/panel-07.log` has a line timestamped
2187-05-22 06:02. Say what would have to be true for those to be the same event, and name one
ordinary thing that would produce the coincidence without them being related. Then say what evidence
would settle it, and whether this lab contains it.

**48.** Reconstruct the console entirely in `/tmp/console-rebuild` without looking at `deck3` again,
from your notes alone: four links with the same four targets and the same relative-versus-absolute
shape. Then run `find -L . -type l` in your rebuild and confirm it reports exactly one entry.

**49.** Rhea wants the dead link repaired. You cannot: the target does not exist and the mount is
gone. Write the two-line reply that says what you can do instead, and make one of the two lines a
concrete command she could run when the array comes back — using `ln -sfn` and saying why the `n`
is there.

## Dig

**50.** Nothing in this lab identifies who made the dead link. List, precisely, the three fields that
`stat` gives you for `deck3/console/strain-feed`, say what each one would have told you on a station
where the accounts were not all `root`, and say which single field would have been decisive. Do not
name anyone.

**51.** The handbook says a panel can be swapped without moving a log file. The chain is
`console/panel-current -> links/panel-active -> store/panel-log.txt =(hard link)= archive/panel-07.log`.
Say which hop exists to allow the panel swap, which hop exists to allow the *log* to move, and which
hop is doing neither. Then say what would break, and what would not, if someone replaced the middle
symlink with a hard link — and whether they could.

**52.** Write the paragraph you would put at the top of the incident record. It must contain: the
four console entries and their state, the full target path of the dead one, the date the feed stopped
according to the log, and one sentence marking clearly which part of that is recorded and which part
is inferred. No speculation about people. Keep it under 120 words.

## The debrief — required

Written, four sentences — one each:

- where each of the four console entries points, and which goes nowhere,
- the full path the dead one was aimed at,
- why a symlink can outlive its target,
- how you told the hard links from the copy.

Then one more sentence: what you would tell rhea, who asked for the old path before anybody repairs
anything. Say why she asked for it in that order.
