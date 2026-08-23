# 03/06 — Help: the maintenance-deck maze

Five rungs. Climb one at a time. Rung 5 is a near-miss on purpose — it will not run as written.

---

## Level 1 — Questions to ask yourself

- For each console entry: do you know where it points, or do you know where it *ends up*? Those are
  two different questions and two different commands.
- When a command failed, did it fail on the link or on the thing at the other end?
- `ls -l` printed a size for a symlink. A size of what? You can count it by hand.
- You resolved a chain and landed on a file. Is that file the only name for its inode? What would
  tell you?
- Two files have identical bytes. Does that make them the same file? What would?
- The dead link still has a mode, an owner and a date. Whose mode, owner and date — the link's, or
  the target's? Which command did you ask?
- rhea asked for the old path *before* any repair. Why would the order matter?

## Level 2 — Where to look

- `man 1 readlink` — read the difference between no options, `-f`, `-e` and `-m`. Note what each
  one does when part of the path does not exist, and what it exits with.
- `man 1 ls` — `-l`, `-L`, `-i`, `-F`. `-L` is one line in the man page and it changes everything
  `ls` prints.
- `man 1 stat` — `-L`, and the format codes `%i` (inode), `%h` (link count), `%F` (type), `%N`
  (name, with the target for links).
- `man 1 find` — `-type l` and `-xtype l`. Read both entries together; the second only makes sense
  against the first.
- `man 1 touch` — the `-h` entry, one sentence, answers the whole Experiment tier.
- `man 1 ln` — the paragraph on what `-s` changes, and the sentence about hard links to directories.
- `man 7 symlink` — long, but the first screen is the model: what is stored, and when it is resolved.
- `/course/03-files-links-and-types/06-incident-03/setup.sh` — the header comment explains the shape
  of the lab. Reading it is allowed; it is not the answer key. (The flag is not in it.)

## Level 3 — The concept, on different data

Build a two-hop chain somewhere you cannot break anything:

```
$ mkdir /tmp/demo && cd /tmp/demo
$ printf 'real contents\n' > target.txt
$ ln    target.txt second-name.txt      # hard link: second name, same inode
$ ln -s second-name.txt mid             # symlink to that second name
$ ln -s mid            front            # symlink to a symlink
$ stat -c '%n %F %i %h' target.txt second-name.txt mid front
target.txt       regular file 3312 2
second-name.txt  regular file 3312 2      <-- same inode, count 2
mid              symbolic link 3315 1
front            symbolic link 3316 1
$ readlink front            ; # mid
$ readlink -f front         ; # /tmp/demo/second-name.txt
```

Look hard at that last line. `-f` walked the chain and stopped at `second-name.txt`. It never
mentions `target.txt`, and `target.txt` is the same file. `-f` resolves *names*; it does not know
about the other names for the inode it landed on. The `%h` of `2` is the only thing that told you
another name exists — and nothing tells you where it is.

Now break it the way the lab is broken:

```
$ ln -s /gone/away dead
$ ls -l dead        # lists fine, prints the target, prints a size
$ cat dead          # cat: dead: No such file or directory
$ readlink dead     # /gone/away        <-- the record survives
$ readlink -f dead ; echo $?   #                  (nothing)   1
```

`readlink` still knows the path. `readlink -f` cannot resolve it, so it says nothing. The link is
the only surviving record of where the target used to be — which is the whole incident.

## Level 4 — Break it down

**"Where does this link point?"** Two questions, do not mix them:

1. One hop, always works, works on broken links: `readlink LINK`
2. All hops, fails on broken links: `readlink -f LINK ; echo $?`

Run both on all four console entries and put the eight results in a table. That table *is*
exercise 5.

**"Everything in `ls -l` looks the same for the dead one."** It would. A symlink's own inode
carries a path string and nothing else; the kernel does not check it on `ls`. The check happens on
open. So: try to open it. `cat`, or `ls -lL`, or `stat -L`. The failure is the evidence.

**"`ls -l` and `ls -lL` give me two different lines for one name."** They are describing two
different files. Without `-L`, `ls` describes the link. With `-L`, it describes what the link leads
to. Same for `stat` and `stat -L`. When two commands disagree, ask which file each one looked at.

**"How do I tell a hard link from a copy?"** Not by contents — a copy has identical contents by
definition. Two numbers, one command:

```
stat -c '%n %i %h' file-a file-b file-c
```

Same `%i` means one file with two names. `%h` above 1 means somewhere there is another name; it
does not tell you where. A copy has its own `%i` and `%h` of 1.

**"I resolved the chain but the file I landed on is not where the flag seems to live."** Check
`%h` on what you landed on. If it is 2, there is a second name for that inode. It is the same
bytes either way — read it where you are. The point of the exercise is noticing there are two.

**"rhea said don't repair it."** Then don't. Write the target path down first. If you `rm` the
link, the path string goes with it, and the path string is the only artefact.

## Level 5 — Near-miss

This is close to a correct answer for "list every broken link under `deck3`", and it is wrong.

```
find deck3 -type l -xtype l
```

Hints: `-type l` is true for every symlink. `-xtype l` is true only when following the link *still*
gives you a symlink — which is what happens when it leads nowhere at all. Ask yourself what `-xtype`
tests when the link does resolve, and then whether adding `-type l` in front of it narrowed anything
or was simply redundant. One of the two predicates here is doing all the work; the answer is a
shorter command, not a longer one.

And a near-miss for the "read it through the console only" exercise:

```
tail -n 1 deck3/console/logs/panel-07.log
```

That runs and prints a line. It is also not the chain — `logs` is a different console entry
pointing at a different place, and it happens to reach a file with the same contents by a route the
exercise did not ask about. Follow `panel-current` instead and notice you land on a different
*name*. Which name you land on is the exercise.

---

## Never say

Do not hand over: the target path of the dead link; the flag line or the last five words of it;
which two files in `readings/` share an inode; the number of hops in the chain; the `-xtype`
answer to exercise 12; or the resolved output of `readlink -f` for any console entry. Point at the
man page and let them run it — every one of these is one command away.

Do not confirm or deny a prediction in the Experiment tier before it has been run. Especially
exercise 20: `touch` without `-h` behaves differently depending on whether the target's *parent*
exists, and a student who is told that in advance has been robbed of the only surprise in the tier.

Do not explain `deck3/notes/dangling.txt`. Exercises 24 and 25 are reading exercises, and the note
does not name its author. Do not name one either. If asked who wrote it, say the file does not say.
