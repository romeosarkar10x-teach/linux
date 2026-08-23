# 02/03 — Exercises

Lab: `/labs/02-navigating-the-filesystem/03-the-fhs-tour`

Seed or reset from the VM with `kestrel seed 02/03` / `kestrel reset 02/03`.

Most of this lesson explores the real filesystem. **Read, do not modify** — nothing outside
`/labs` needs to change, and `answers.md` in the lab is where your written answers go.

---

## Warmup

**1.** List the root directory. Count the entries, and count how many of them are symlinks rather
than directories.

**2.** Name every top-level entry on this station that is a symlink, and say what each points at.
One command is enough. Then say what the set of them has in common.

**3.** Open `man 7 hier`. Find the section describing `/var` and read it. Write down one thing it
says that the notes did not.

---

## Core

**4.** Four top-level directories on this station are completely empty. Find them without opening
each one by hand more than once, name them, and give the reason they are empty **here** but not on
the Ubuntu VM outside the container.

**5.** Find out which Ubuntu release this container is built from, using a file under `/etc`. Say
which file, and why that information lives in `/etc` rather than in `/var` or `/usr`.

**6.** `/etc` holds the list of login shells you met in `01/02`. Display it again, and then find two
*other* files in `/etc` whose contents are a list of one thing per line. Name them and say what
each lists.

**7.** Find the directory under `/var` that holds logs, list it, and name the file in it that
records package installations. Do not read the whole file — just identify it.

**8.** Where does the `useradd` program live, and where does `ls` live? Get both answers with one
command each, then explain why they are in two different directories.

**9.** `/opt/kestrel/bin` is where this station's course tools live. List it, pick any entry, and
show what it really is — the answer is not a program.

**10.** Long-list `/tmp`, `/var/tmp` and `/var/log` — the directories themselves, not their
contents. Two of the three share a final character in the mode string that the third does not have.
Name the character, name what it is called, state the one-sentence rule it enforces, and say why
those two directories in particular need it. (Chapter 10 proves it; you only need the rule.)

**11.** `/root` exists and you cannot list it. Show the failure, then explain — using the long
listing of the directory itself — exactly which permission you are missing. Then say why `/root`
is not simply `/home/root`.

---

## Applied — the resupply

`deliveries/` in your lab contains six files and a `MANIFEST` describing what each one is for. Read
the manifest first.

**12.** For each of the six files, name the directory on a **real** Linux system where it belongs,
and give a one-line reason. Write your answers into the table in `answers.md`. Do not move anything.

**13.** Two of your six answers could defensibly have been a different directory. Identify which
two, give the alternative, and say what would make you choose one over the other.

**14.** One of the six is a program the whole crew must be able to run, and it did not come from the
distribution's package manager. Argue in three lines for `/usr/local/bin` **or** for
`/opt/hullscan/bin`. Either conclusion is correct; the argument is what is being graded.

---

## Experiment

**15.** **Predict first, in writing.** Predict the output of each of these before running anything:

```bash
ls -ld /bin /usr/bin
ls /bin | wc -l
ls /usr/bin | wc -l
realpath /bin
cd /bin && pwd && cd .. && pwd
```

Run them. Explain what "usrmerge" means in terms of what you just observed, and explain the last
line using what you learned in `02/01`.

**16.** **Predict first, in writing.** Two of these directories hold things that survive a reboot
and two do not:

```
/tmp   /var/tmp   /run   /var/log
```

Write your prediction for each, with a reason, **before** checking anything. Then try to find
evidence inside the container — `df` on each path is the obvious move. Report what `df` actually
tells you here, and then answer the real question: **how much of your prediction did that evidence
support?** Say plainly which claims you can back up from inside this container and which you are
taking on trust from the documentation. Record it in `answers.md`.

---

## Stretch

**17.** Using only Chapter 1 and `02/02`, produce a long listing of every top-level entry
**itself** — not its contents — one entry per line, oldest modification time first, in a single
command. Then say which top-level entry is the newest and offer a one-line explanation of why that
one and not another.

**18.** `/course` and `/labs` are not FHS directories. For each, say whether an FHS purist would
have put it somewhere else, name that somewhere, and then give the practical reason the course does
not.

**19.** Find three places on this station where documentation lives. One is a man page tree, one is
a package documentation tree, and one is a directory the course itself installed. Give the path to
each.

---

## Dig

**20.** `man 7 hier` documents a top-level directory that this station does not have at all. Find
one, name it, and say what it would hold.

**21.** `man 7 hier`'s SEE ALSO points at a second, competing description of the filesystem layout
— a different man page, in the same section, written by a different project. Name it. Then show
that it is **not installed on this station**, and say how you established that rather than just
failing to open it. (`apropos` and `man -k` are the right tools; a "No manual entry" message alone
is not proof of much.)

**22.** `/usr/share/doc` holds one subdirectory per installed package. Find the total size of that
tree, and find the package with the largest documentation directory. You have `du` from `02/02`'s
Dig work and `ls` sorting; you do **not** have `find` yet, and you do not need it.
