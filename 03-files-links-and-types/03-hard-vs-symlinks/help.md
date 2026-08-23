# 03/03 — Help

Five rungs. Climb one at a time. Do not read ahead of where you are stuck.

---

## L1 — Questions to ask yourself

- Is the thing in front of you a link, or the thing a link points at? Which of the two is your
  command actually talking about?
- When a command fails, which of the two names in the situation is the one that does not exist?
- Does this command dereference by default, or not? What flag flips it?
- If a symlink's contents are a path string, what would `ls -l` report as its size?
- Two names, one inode: what number in `ls -l` proves it, and what number in `ls -li` proves it?
- Relative to *what* is a relative target resolved?

## L2 — Where to look

- The type character is the first column of `ls -l`: `-` regular, `l` symlink, `d` directory.
- Inode numbers come from `ls -i` or `stat -c %i`. Link counts are the number right after the mode
  in `ls -l`, or `stat -c %h`.
- `man readlink` is short — under thirty lines. Read the whole thing; the answer to several
  exercises is in it.
- `man ln` — look for the flags about *symbolic*, about *relative*, and about *no-dereference*.
- `man ls` — search for `classify` and for `slash`.
- `man stat` — the `-L` line, and the `%N` entry in the format table.
- Nearly every tool spells "follow the link" as `-L` and "do not" as `-P` or `-h`/`-n`. Once you
  notice that, you can guess the flag before you look it up.

## L3 — The concept, on different data

Say `/etc/hostname` holds the text `kestrel`.

Now imagine a file `/tmp/note` whose contents are literally the eight characters `/etc/hosts`, and a
flag on that file that says "these contents are a path, not data". That is all a symlink is. `cat`
on it does not print `/etc/hosts` — the kernel sees the flag, reads the path, and starts over from
there. `readlink` is the command that ignores the flag and just prints the contents.

Now imagine instead that the directory entry `/tmp/note` does not have contents of its own at all —
it holds the same inode number as `/etc/hostname`. That is a hard link. There is nothing to follow;
there is one file with two entries in two directories, and the inode counts how many entries name
it. Delete one entry, the count goes 2 to 1, the file is fine. Delete the last one and the file is
gone because nothing names it any more.

Two mechanisms, one arrow in the listing. Every question in this lesson is answerable by asking
which of those two pictures applies.

## L4 — Break it down

**"Where does this chain end up?"**
1. `readlink X` — one hop, exactly what is stored.
2. Is that output itself a link? `ls -l` on it.
3. Repeat until `readlink` fails, which means you have reached something that is not a link.
4. `readlink -f X` should equal your last step. If it does not, you missed a hop or resolved a
   relative target from the wrong directory.

**"Is this link broken?"**
1. `ls -l` — you now know the target string.
2. `readlink -e` — exit 0 means the target is there, exit 1 means it is not.
3. If it is broken, `readlink -f` may still print the intended path, and that path is usually the
   finding worth writing down.

**"Same file or two files?"**
1. `ls -li` both names. Same inode number → one file.
2. Link count > 1 → other names exist somewhere.
3. Different inodes but identical contents → copies, or a symlink. The type character separates
   those two cases.

**"Why did that fail?"**
1. Write the error out. Note which *path* it names.
2. Decide whether that path is the link or the target.
3. `Permission denied` on a link is always about the target's mode. `No such file or directory` on
   a link you can see listed is always about the target's absence.

## L5 — Near-miss

Here is the full working method for a different link, in a different tree. It is not any of the
lab's links, and it will not give you a lab answer — but the shape is the same.

```
$ ls -l /tmp/demo
lrwxrwxrwx 1 cadet crew 9 Aug 23 08:20 alias -> real.log
-rw-r----- 1 cadet crew 0 Aug 23 08:20 real.log

$ readlink /tmp/demo/alias
real.log                      # one hop, relative — resolved from /tmp/demo, not from here

$ readlink -f /tmp/demo/alias
/tmp/demo/real.log            # absolute, chain fully walked

$ readlink -e /tmp/demo/alias ; echo $?
/tmp/demo/real.log
0                             # exit 0: the target is really there

$ stat -c '%i %s %F' /tmp/demo/alias
1301 9 symbolic link         # size 9 = len("real.log")+... count it yourself

$ stat -L -c '%i %s %F' /tmp/demo/alias
1302 0 regular file          # -L crossed over to the target: different inode, different size
```

Do that sequence on a lab link and you will have everything the Core tier asks for. The one thing
this example does *not* show you is what any of it looks like when the target is missing — that is
the half you have to go and see for yourself.

## Never say

- Never state which lab entries share an inode, or give any inode number from the lab.
- Never say which three links dangle, or name their targets.
- Never say what `chain/a` finally resolves to.
- Never explain why `cat perms/back-door` fails — ask which line of `ls -l perms` describes the file
  being opened.
- Never predict on the student's behalf in exercises 23, 24 or 25. The written prediction is the
  exercise; a prediction supplied by a tutor is worth nothing.
- Never hand over `ln -r`, `readlink -m`, or the `ls` marker flags. Those are Dig exercises; point
  at the man page section and stop.
- Never say "just use `readlink -f`" when the student has not yet worked out what one hop means.
