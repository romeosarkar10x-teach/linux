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

---

## Core — the merges and the redirections

**23.** Four top-level entries are symlinks into `usr`. Name all four and their targets, and say in
one line what the arrangement is called and what it replaced.

*Done looks like:* four pairs and the name.

**24.** `/var` contains two entries that are symlinks rather than directories. Find them, report
their targets, and explain what each redirection is for.

*Done looks like:* two links and two purposes.

**25.** Compare `ls /usr` and `ls /usr/local`. They overlap heavily. Say what the overlap means and
which of the two a distribution's package manager is allowed to write to.

*Done looks like:* the overlapping names and the rule.

**26.** `/usr/local/man` is not a directory. Show what it is and say why that link exists at all,
given that `/usr/local/share/man` is the modern location.

*Done looks like:* the listing and the reason.

**27.** List `/var` and assign each entry to one of three groups: things that survive a reboot,
things that must not, and things you are unsure about. Keep the unsure group honest.

*Done looks like:* three lists.

**28.** Name the `/var` subdirectory for each: printer and mail queues; package downloads that could
be deleted and re-fetched; databases that programs would break without.

*Done looks like:* three paths with one line each.

**29.** `/var/mail` has a group that is not `root` and a mode that the other `/var` entries do not
have. Report both, and say what arrangement they are there to support. (Chapter 10 explains the
mechanism; name the intent.)

*Done looks like:* the listing and one sentence.

---

## Core — where a program actually is

**30.** Find the real location of `ls` on this station, following every link to the end. Report the
chain, and say how many hops it took.

*Done looks like:* the chain and the count.

**31.** `/opt/kestrel/bin` has around a hundred entries and none of them are programs. Say what they
all are, and what one directory they all point into.

*Done looks like:* the answer and a sample entry.

**32.** Given exercise 31, say how this station's tool layout differs from what `man 7 hier` would
lead you to expect, and give one advantage of the arrangement.

*Done looks like:* the difference and the advantage.

**33.** `/nix` is not in the FHS. Say what it holds here, count its entries, and say which
top-level FHS directory it is playing the role of.

*Done looks like:* the count and the mapping.

**34.** Find out where `bash` itself lives on this station and whether it is the distribution's copy
or the station's. Give your evidence.

*Done looks like:* the path and the evidence.

**35.** Name the difference in intent between `/usr/bin` and `/usr/sbin`, then check whether that
distinction is still enforced here — is `/usr/sbin` on your `$PATH`?

*Done looks like:* the intent and the `$PATH` check.

---

## Experiment — predict before you run

**36.** **Predict first.** Predict what `cat /etc/os-release | head -3` and `cat
/etc/debian_version` will say, and whether they will agree. Then run both.

*Done looks like:* two predictions, two outputs, and an explanation of the disagreement.

**37.** **Predict first.** Predict how many entries `/etc` has, to the nearest twenty, and how many
of them end in `.d`. Then count both.

*Done looks like:* two guesses and two counts.

**38.** **Predict first.** Predict what a `.d` suffix on a directory in `/etc` means, from the
examples alone, before reading anything. Then check your theory against `man 7 hier` or a `.d`
directory's own contents.

*Done looks like:* the theory and the check.

**39.** **Predict first.** Predict whether `/dev` contains ordinary files. Then list it and report
what the first character of the mode is for five entries of your choosing.

*Done looks like:* the prediction and five modes.

**40.** **Predict first.** Predict what `stat -f -c '%T' /tmp` reports for the filesystem type, and
whether `/tmp`, `/usr` and `/var` will report the same. Run all three.

*Done looks like:* the prediction and three answers.

---

## Stretch

**41.** From exercise 40: everything reports one filesystem. Say what that tells you about this
station compared with a real machine, and name one exercise in this lesson whose answer would be
different on real hardware.

*Done looks like:* two sentences.

**42.** Using 02/02: rank the top-level directories by the size of their own directory entry, and
say why that ranking tells you almost nothing about how much data is in each.

*Done looks like:* the ranking and the caveat.

**43.** Using 02/01: `/bin` is a symlink to `usr/bin` — a *relative* target. Say what would break if
it were `/usr/bin` instead, and what would break if the target were `../usr/bin`.

*Done looks like:* two answers.

**44.** Write the rule you would give a new cadet for deciding between `/etc`, `/var` and `/usr` for
a file they have just been handed. Three lines, no examples.

*Done looks like:* three lines.

**45.** Apply your rule from exercise 44 to the six deliveries again. Say whether it produces the
same answers you gave in exercise 12, and fix whichever is wrong.

*Done looks like:* six checks and any corrections.

**46.** `man 7 hier` describes `/usr/src` and `/usr/games`. Both exist here and both are empty. Give
a reason each is empty on a container image specifically.

*Done looks like:* two reasons.

---

## Dig

**47.** Find the total size of `/usr/share/man` and the number of language subdirectories in it. Say
what would be reclaimed by removing all but one language, and why an image builder might not bother.

*Done looks like:* the size, the count, and the judgement.

**48.** `man` finds pages in more than one tree. Find the setting or command that reports the search
path it uses, and report the list. Say which entry covers `/opt/kestrel`, if any.

*Done looks like:* the command, the list, and the answer.

**49.** Determine, without opening it, whether `/root` is on the same filesystem as `/home/cadet`,
and say what command answered it.

*Done looks like:* the answer and the command.

**50.** `/proc` and `/sys` both show a size of `0` in `ls -l`. Say what that means, and predict —
without doing the work, which is 02/04's job — whether `du` on them would be meaningful.

*Done looks like:* the meaning and the prediction.

**51.** Find the top-level directory whose modification time is oldest and the one whose is newest.
Account for both, and say which of the two dates is telling you about the image build and which
about your own session.

*Done looks like:* two entries with times and the account.

**52.** Write the three-sentence summary of the FHS you would put at the top of a crew handbook: the
question it answers, the one rule that covers most cases, and the honest caveat about how strictly
real systems follow it.

*Done looks like:* three sentences.
