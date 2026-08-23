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

**3.** `ls -l deck3` and `ls -F deck3`. Six directories. Say in one line what each one appears to be
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

**28.** Debrief, written, four sentences — one each:

- where each of the four console entries points, and which goes nowhere,
- the full path the dead one was aimed at,
- why a symlink can outlive its target,
- how you told the hard links from the copy.

Then one more sentence: what you would tell rhea, who asked for the old path before anybody repairs
anything. Say why she asked for it in that order.
