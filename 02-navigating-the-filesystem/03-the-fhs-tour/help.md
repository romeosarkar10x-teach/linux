# 02/03 — Tutor hint ladder

Rules: `docs/TUTOR_PROTOCOL.md`. One rung per exchange. This lesson is mostly recall and reading;
resist the urge to lecture — send them to `man 7 hier` and let them read.

---

### Exercise 1
- **L1 question:** Which flag from `02/02` shows you the *type* of each entry without descending into it?
- **L2 locate:** `02/02` notes, "What `ls` hides by default".
- **L3 concept:** `ls -ld /etc /var` prints two lines describing those directories rather than their contents.
- **L4 decompose:** (1) list `/`; (2) get one line per top-level entry, with types; (3) count the lines whose first character is not `d`.
- **L5 near-miss:** If they listed the *contents* of each directory, point at `-d`.
- **Never say:** `ls -ld /*`.

### Exercise 2
- **L1 question:** What does the long listing put after the name of a symlink?
- **L2 locate:** `02/02` notes, the long-format diagram; their own output from exercise 1.
- **L3 concept:** `ls -ld /var/run` on this station shows an arrow and a destination.
- **L4 decompose:** (1) reuse exercise 1's command; (2) read every line beginning with `l`; (3) copy what follows each arrow; (4) look at the four targets together.
- **L5 near-miss:** If they found three, ask them to re-read their own output — there is a fourth, and it is easy to skim past.
- **Never say:** the names, or that all four point into `/usr`.

### Exercise 3
- **L1 question:** How do you open section 7 of the manual rather than section 1?
- **L2 locate:** `00/05`, on `man` sections.
- **L3 concept:** `man 5 passwd` and `man 1 passwd` are different pages about related things. The number goes before the name.
- **L4 decompose:** (1) open the page; (2) search inside `less` with `/`; (3) find the `/var` block; (4) note one claim not in the notes.
- **L5 near-miss:** If they cannot search, remind them `/` inside `less` and `n` for the next match.
- **Never say:** what the page says about `/var`.

### Exercise 4
- **L1 question:** How would you list the contents of every top-level directory in one command?
- **L2 locate:** `02/02` notes, "Gotchas" — multi-argument `ls` prints a label per directory.
- **L3 concept:** `ls /etc /var` prints two labelled blocks. A block with a label and nothing under it means the directory is empty.
- **L4 decompose:** (1) list all top-level directories at once; (2) find the labels with no entries beneath them; (3) for each, ask what would put something there on a real machine.
- **L5 near-miss:** If they include `/proc` or `/sys` in the empty set, have them re-run — those are very much not empty.
- **Never say:** the four names, or the container explanation.

### Exercise 5
- **L1 question:** Which `/etc` file is specifically about identifying the operating system?
- **L2 locate:** Notes, "The tour", the `/etc` paragraph, which names it.
- **L3 concept:** `/etc/hostname` holds one machine-specific fact in plain text. There is a file that does the same job for the OS identity.
- **L4 decompose:** (1) list `/etc` and look for a name containing "release"; (2) read it; (3) answer the "why `/etc`" half using the static/variable table.
- **L5 near-miss:** If they used `lsb_release` or `uname`, accept the answer and ask which *file* it came from.
- **Never say:** `/etc/os-release`.

### Exercise 6
- **L1 question:** What was the file in `01/02` that listed valid login shells?
- **L2 locate:** `01/02` notes.
- **L3 concept:** `/etc` is full of line-per-record text files. `/etc/hostname` is a one-line one; there are several with many lines and one record each.
- **L4 decompose:** (1) recall the shells file; (2) list `/etc` and open two or three candidates; (3) for each, say what one line represents.
- **L5 near-miss:** If they pick `/etc/passwd`, that is a good answer — ask them what separates the fields and whether it is really "one thing per line".
- **Never say:** candidate filenames.

### Exercise 7
- **L1 question:** Which of the two `/var` subdirectories in the notes is for things you read after the fact?
- **L2 locate:** Notes, "The tour", the `/var` paragraph.
- **L3 concept:** A package manager records what it did somewhere durable. The name of the tool is usually in the name of the log.
- **L4 decompose:** (1) list the log directory; (2) look for names matching the two package tools this image has; (3) name the file without reading it.
- **L5 near-miss:** If they name the `apt` directory rather than a file, point out that one is a directory.
- **Never say:** `dpkg.log`.

### Exercise 8
- **L1 question:** Which of these two commands is one you would only run as an administrator?
- **L2 locate:** Notes, "The tour", the `/usr` bullets.
- **L3 concept:** `type -p` from `01/03` answers "where is this program" without any guessing.
- **L4 decompose:** (1) locate each; (2) note the two different directories; (3) map each onto the notes' description.
- **L5 near-miss:** If they used `which`, remind them of `01/03`'s reason to prefer `type`.
- **Never say:** the two paths.

### Exercise 9
- **L1 question:** What did the long listing tell you about `/bin` in exercise 2? Try the same thing here.
- **L2 locate:** Notes, "Two things this station does that the FHS does not describe".
- **L3 concept:** A directory can be full of pointers rather than files. `/etc/alternatives` on Debian systems is exactly that.
- **L4 decompose:** (1) list the directory long-form; (2) read the first character of any line; (3) follow one arrow, or resolve it.
- **L5 near-miss:** If they say "it is a program", ask them to run the long listing rather than the plain one.
- **Never say:** the word symlink, or `/nix/store`.

### Exercise 10
- **L1 question:** Compare the three mode strings character by character. Which position differs, and which two agree?
- **L2 locate:** Notes, "The tour", the `/tmp` block.
- **L3 concept:** The last character of the mode is normally `x` or `-`. On some directories it is a letter you have not met.
- **L4 decompose:** (1) long listing of all three directories themselves; (2) line up the mode strings; (3) find the odd character out; (4) look up its name — `man 7 hier` will not have it; `man 1 chmod` will; (5) ask what those two directories have in common that the third does not.
- **L5 near-miss:** If they say "`/tmp` is world-writable", that is the *precondition*, not the answer — ask what would happen in a world-writable directory without the extra character.
- **Never say:** "sticky bit", or the rule.

### Exercise 11
- **L1 question:** Which of the three permission letters do you need to *list* a directory's contents?
- **L2 locate:** Notes, "The tour", `/home` and `/root`.
- **L3 concept:** `ls -ld /root` shows a mode where the group and other blocks are entirely dashes. Compare with a directory you *can* list.
- **L4 decompose:** (1) attempt the listing and record the error verbatim; (2) long-list the directory itself; (3) identify which block applies to you; (4) answer the `/home` half from the notes.
- **L5 near-miss:** If they try `sudo`, stop them — the exercise is about reading the permission, and Chapter 10 owns `sudo`.
- **Never say:** the mode, or the network-mount reason.

### Exercise 12
- **L1 question:** For each file, is it static or variable? Shareable or machine-specific?
- **L2 locate:** Notes, "The organising question"; `man 7 hier` for anything you are unsure of.
- **L3 concept:** Take a file not in your list — a font. Static, shareable, architecture-independent. That puts it under one specific tree, and the reasoning got you there without memorising anything.
- **L4 decompose:** For each file in turn: (1) does it change while the system runs; (2) would another machine want the same copy; (3) is it configuration, data, a program, or throwaway.
- **L5 near-miss:** If they put the `.pid` file in `/var/log`, ask how long the value stays meaningful.
- **Never say:** any of the six destinations.

### Exercise 13
- **L1 question:** Which of your six answers did you hesitate over?
- **L2 locate:** Notes, "Gotchas", the `/usr/local` versus `/opt` block; and the `/var/tmp` versus `/tmp` distinction.
- **L3 concept:** Two genuine forks exist here: local-software layout, and how long a temporary file must survive.
- **L4 decompose:** (1) re-read your six reasons; (2) mark any where the reason would also justify a different directory; (3) state what tips it.
- **L5 near-miss:** If they name only one, point them at the temporary file.
- **Never say:** which two.

### Exercise 14
- **L1 question:** Does this program want to be on everyone's `PATH`, or does it want to be deletable in one move?
- **L2 locate:** Notes, "Gotchas", the `/usr/local` versus `/opt` block.
- **L3 concept:** The distribution's package manager owns `/usr/bin` and will overwrite it. Both `/usr/local` and `/opt` exist to stay out of its way; they differ in shape, not in purpose.
- **L4 decompose:** (1) name what each choice makes easy; (2) name what each makes annoying; (3) commit to one and say what would change your mind.
- **L5 near-miss:** If they answer "`/usr/bin`", point at who owns that directory.
- **Never say:** which one you would pick.

### Exercise 15
- **L1 question:** If `/bin` is a symlink to `usr/bin`, how many files are in each?
- **L2 locate:** Notes, "The tour", the `/bin` block; `02/01` on logical versus physical paths.
- **L3 concept:** Two names for one directory means every count, every listing and every `du` sees the same thing twice.
- **L4 decompose:** (1) write five predictions; (2) run all five; (3) explain the equal counts; (4) explain the last line with `02/01`'s logical-path rule.
- **L5 near-miss:** If the counts differ, one of the commands was mistyped — have them re-run.
- **Never say:** that `cd ..` from `/bin` lands at `/`.
- **Grading note:** missing prediction fails.

### Exercise 16
- **L1 question:** What would count as *evidence* for "this does not survive a reboot"?
- **L2 locate:** Notes, "The tour", `/tmp`, `/var/tmp` and `/run`; `df` from `02/02`'s vocabulary.
- **L3 concept:** `df` names the filesystem behind a path. On the Ubuntu VM outside, `df /run` and `df /home` name two different filesystems, and one of them is memory-backed. Ask what it would mean if they named the *same* one.
- **L4 decompose:** (1) predict four, with reasons, in writing; (2) run `df` on each path; (3) compare the four lines; (4) decide what that comparison does and does not establish; (5) separate the claims you proved from the claims you read.
- **L5 near-miss:** If they report that `/run` is a tmpfs here, have them re-read their own `df` output — it is not, and noticing that is the exercise.
- **Never say:** that all four are on the same overlay filesystem, or which two survive a reboot.
- **Grading note:** missing prediction fails. Honesty about the untestable ones is the point of the exercise.

### Exercise 17
- **L1 question:** Which flag stops `ls` descending, and which sorts by time?
- **L2 locate:** `02/02` notes, "Sorting"; and `-d`.
- **L3 concept:** `ls -ltrd /etc /var` is the whole shape, with two arguments instead of all of them.
- **L4 decompose:** (1) the not-descending flag; (2) the time sort; (3) the reverse; (4) the long format; (5) how to name every top-level entry at once.
- **L5 near-miss:** If they typed all twenty paths by hand, that is a correct answer — mention that Chapter 5 gives them a shorter way, and do not explain it.
- **Never say:** the glob.

### Exercise 18
- **L1 question:** Is the course material static or variable? Is your lab work?
- **L2 locate:** Notes, "The organising question"; "Two things this station does".
- **L3 concept:** Software shipped as a self-contained blob has an FHS home. Data belonging to a service has a different one.
- **L4 decompose:** (1) classify each on both axes; (2) name the FHS directory that matches; (3) say what typing that path forty times a day would feel like.
- **L5 near-miss:** If they say "there is no right answer", push for the purist's answer first, then the practical one.
- **Never say:** `/opt` or `/srv` as the answers.

### Exercise 19
- **L1 question:** Where did `man` find the page you read in exercise 3?
- **L2 locate:** Notes, "The tour", `/usr/share`; `00/05` on `man`.
- **L3 concept:** `manpath` prints where man pages are looked for. Packages install prose separately from man pages.
- **L4 decompose:** (1) find the man tree; (2) find the per-package documentation tree under the same parent; (3) recall where the course tools were installed and look for a documentation directory there.
- **L5 near-miss:** If they give three subdirectories of one tree, point out the exercise says three different kinds.
- **Never say:** the three paths.

### Exercise 20
- **L1 question:** As you read `man 7 hier`, check each path it names against this station. Which one is missing?
- **L2 locate:** `man 7 hier`.
- **L3 concept:** The page is older than some of what it documents. Graphical-desktop directories are the obvious place to look on a server image.
- **L4 decompose:** (1) read the page's headings; (2) test a few with a listing; (3) report the first one that does not exist.
- **L5 near-miss:** If they name `/lost+found`, that is a legitimate answer — ask them what creates it and on what kind of filesystem.
- **Never say:** the name.

### Exercise 21
- **L1 question:** What is in `man 7 hier`'s SEE ALSO list that is also in section 7?
- **L2 locate:** The bottom of `man 7 hier`.
- **L3 concept:** `apropos` searches the *installed* page index. A page that is referenced but not installed will be absent from it while still being named in the reference.
- **L4 decompose:** (1) read SEE ALSO; (2) pick the section-7 entry that is not `hier` itself; (3) search the index for it; (4) state what an empty index result proves that a failed `man` does not.
- **L5 near-miss:** If they say "`man` said no manual entry, so it is not installed", ask what else produces that message — a typo, a missing section, an unbuilt index.
- **Never say:** `file-hierarchy(7)`.

### Exercise 22
- **L1 question:** How do you get one total per subdirectory rather than one grand total?
- **L2 locate:** `man du`; `02/02` exercise 24 if they did it.
- **L3 concept:** `du -sh /var/log` gives one number. Giving it several directories gives several numbers, one per argument.
- **L4 decompose:** (1) grand total for the tree; (2) one line per subdirectory; (3) sort those lines by size — note that `879K` and `1.2M` do not sort correctly as plain text, and `sort` has a flag for that; (4) take the last line.
- **L5 near-miss:** If their sort puts `999K` above `1.2M`, that is the trap — point at the sort flag, not at `du`.
- **Never say:** `sort -h`, or the winning package.

---

## Escalation notes

The applied section (12–14) has no single right answer and students who want to be told one will
stall. Push them to commit to an answer with a reason; the rubric rewards a defended wrong answer
over an undefended right one, and they should be told that.
