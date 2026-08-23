# 03/02 — Tutor notes

For the agent in **tutor mode**. Read `docs/TUTOR_PROTOCOL.md` first. Climb one rung at a time and
only on request. Never hand over an answer that the student could have reached with one more
question.

The whole lesson turns on one reframing: **the name is not the file.** A student who has not made
that flip will read every result as a bug. Diagnose which side of the flip they are on before you
help with anything specific.

---

## Exercises 1–3 · reading inode numbers

**L1 — question.** What does `ls -i` add to a listing, and where does the number appear? If two lines
carry the same number, what would that have to mean?

**L2 — locate.** `man ls`, search for `inode`. Your options are `-i` for the number and `-a` for the
hidden entries; the exercise wants both at once.

**L3 — concept elsewhere.** In `/etc`, `stat -c '%i %n' /etc/hostname /etc/hosts` gives two files two
numbers. Two names with *one* number is the case you are looking for in the lab.

**L4 — decompose.** (a) List with inode numbers. (b) Include hidden entries. (c) Sort the numbers by
eye and look for a repeat.

**L5 — near-miss.** `ls -i roster` shows the numbers but hides `.`, `..` and `.backup`. Add the flag
that stops it hiding them.

**Never say:** which two entries share the number, or that they are 44805.

## Exercises 4–9 · the link count and the third name

**L1 — question.** `roster.txt` says 3 in the link-count column, and you can see two names. What is
the count actually counting — names, or something else? If names, where is the third one?

**L2 — locate.** `man stat`, the FORMAT SEQUENCES table: `%i`, `%h`, `%s`, `%n`. `man ln` opens with
one sentence that names both kinds of link.

**L3 — concept elsewhere.** `stat -c '%h %n' /etc/hostname` shows 1. A file with one name has one
link. That is the baseline the roster departs from.

**L4 — decompose.** For exercise 6: (a) the count says how many names exist. (b) You have found two.
(c) The lab has one directory you have not listed yet. (d) `ls -ia` it.

**L5 — near-miss.** You listed `roster` but not `roster/.backup`.

For exercise 9 the student may want a "real" one. Push back with a question, never with the answer:
*after `ln`, is there any field in `stat` on either name that differs?* Let them find that there is
not, and draw the conclusion themselves.

**Never say:** `.backup/names.txt`. Never say "there is no original" — make them prove it.

## Exercises 10–13 · directory link counts

**L1 — question.** `decks` holds three subdirectories and has link count 5. Every hard link is a
directory entry pointing at this inode. Can you name five entries anywhere in the tree that point at
`decks`?

**L2 — locate.** `ls -ia decks` and `ls -ia decks/deck-3`. Compare the inode number of `decks` itself
with what `deck-3/..` reports.

**L3 — concept elsewhere.** `stat -c '%h %n' /tmp` on a busy `/tmp` gives a large number, and the
directory holds exactly that many subdirectories minus two.

**L4 — decompose.** (a) What is `decks`'s own inode number? (b) Which entry inside `decks` has that
number? (c) Which entry inside each `deck-N` has it? (d) Which entry in the lab root has it? Add up.

**L5 — near-miss.** You have counted `decks` and its three `..` entries. One is missing, and it lives
inside `decks` itself.

**Never say:** "subdirectories + 2". That formula is the finding.

## Exercises 14–19 · deletion is a directory write

**L1 — question.** You deleted `expendable.txt` and `keeper.txt` still reads fine. So what did `rm`
remove? And in exercise 17: `rm` succeeded on a file you were not allowed to write to — which object
did the kernel actually check permission on?

**L2 — locate.** `man 1 rm`, first paragraph, names the system call. `man 2 unlink` describes it.
`ls -ld` shows a directory's own mode, which is the mode that matters here.

**L3 — concept elsewhere.** In `/etc` you can read `hostname` but not delete it, and the reason is
not on `hostname`. `ls -ld /etc` shows why.

**L4 — decompose.** For 17: (a) which permissions does `notes.txt` carry? (b) which does `locked/`
carry? (c) appending is a write to which one? (d) removing an entry is a write to which one?

**L5 — near-miss.** Deleting a name edits the directory that holds the name. You have been reading
the file's mode; read the directory's.

**Never say:** "write permission on the directory, not the file" before they have run `ls -ld`.

## Exercises 20–21 · the two things `ln` refuses

**L1 — question.** Before you run it: if a directory could have two parents, what would `..` mean
inside it? And what would `cd ..` repeated do to a tree with a cycle in it?

**L2 — locate.** `man ln`, the paragraph about directories. For 21, `man 2 link` names the error in
its ERRORS list: `EXDEV`.

**L3 — concept elsewhere.** A symlink to a directory is allowed and creates the same visual shape.
Ask why the kernel tolerates that one — the answer is that a symlink is a name pointing at a *path*,
and the link count of the target is untouched.

**L4 — decompose.** For 21: (a) run the `ln`, record the error. (b) `df` both paths. (c)
`stat -c '%d %n'` both paths. (d) which of the two is the kernel's own opinion?

**L5 — near-miss.** `df` reports the backing block device. `%d` reports the device number of the
mounted filesystem. `/home/cadet` and `/labs` are different mounts on the same disk.

**Never say:** "overlay versus the volume". Let the numbers say it.

## Exercises 22–25 · rename, reuse, breaking a link

**L1 — question.** If `mv` inside a filesystem is instant regardless of size, how much data can it
possibly be moving?

**L2 — locate.** `man 2 rename` for 22. For 25, think about what `cp file file.new; mv file.new file`
does to the entry in the directory.

**L3 — concept elsewhere.** `mv /tmp/x /tmp/y` on a 1-byte file and on a 100 MB file take the same
time. Time them.

**L4 — decompose.** For 25: (a) two names, one inode, count 2. (b) `cp` one of them to a third name —
that is a new inode. (c) `mv` the third name over one of the originals. (d) recount.

**L5 — near-miss.** `mv` onto an existing name replaces the *directory entry*. The inode that entry
used to point at loses a link; it does not lose its other name.

**Never say:** the exact three-command sequence for 25.

## Dig 26–28

Preview material. `find -samefile` / `-inum` are Chapter 6 tools; if the student is stuck on `find`
syntax rather than on the idea, give them the syntax — it is not what is being tested here. The idea
being tested is that the only way to enumerate an inode's names is to search the whole filesystem,
because the inode does not know its own names.

For 27, the condition is that a process still holds the file open. Do not name it; ask what happens
if you delete a log file that a running program is writing to, and whether the disk space comes back.
