# 01/01 — Tutor hint ladder

Governed by [`docs/TUTOR_PROTOCOL.md`](../../docs/TUTOR_PROTOCOL.md). One rung per exchange.

**Diagnose first:** almost every confusion in this lesson is the student collapsing three things
into one word. If an answer is muddled, ask *which of the three* they mean before anything else.

### Exercise 1 — tty, PID, program
- **L1 question:** Which of the three — emulator, tty, shell — does each of those three facts
  belong to?
- **L2 locate:** Notes, "Which tty am I on" and "Which shell am I in".
- **L3 concept:** A PID is a number the kernel assigns; a program name is what is running under it.
  Getting from one to the other needs the process table. Example on different data: if you knew
  process 1 existed, `ps -p 1` would tell you it is `init` or `systemd`.
- **L4 decompose:** (1) print the tty; (2) print the shell's own PID; (3) look that PID up.
- **L5 near-miss:** If they have `ps` alone and are hunting for their shell by eye, point out that
  they already printed the exact number they need.
- **Never say:** `tty`, `echo $$`, `ps -p $$` as a set.

### Exercise 2 — whoami vs id
- **L1 question:** What does the second command show that the first cannot?
- **L2 locate:** Notes, "Who am I to the machine".
- **L3 concept:** One reports a name; the other reports the numeric identity plus every group.
- **L4 decompose:** Run both. Diff them by eye. Name one fact present in only one.
- **L5 near-miss:** If they say "id is longer", ask *which specific fact* they would need in a
  permissions bug.
- **Never say:** the word "groups" as the answer.

### Exercise 3 — processes on your tty
- **L1 question:** What is the simplest possible invocation of the process-listing command?
- **L2 locate:** Notes, "Nesting", the bare listing.
- **L3 concept:** With no arguments it defaults to *your* processes on *your* terminal, which is
  usually what you want and occasionally not enough.
- **L4 decompose:** Run it bare. Count the lines. Account for each one.
- **L5 near-miss:** If they reach for `ps aux` and get 200 lines, ask what they were trying to
  narrow to.
- **Never say:** —

### Exercise 4 — not a tty
- **L1 question:** What has to be true about a program's output for it to *not* be connected to a
  terminal?
- **L2 locate:** Notes, the `echo hi | tty` example.
- **L3 concept:** A pipe replaces the program's standard streams. On a different example: `whoami |
  cat` still works, because `whoami` does not care — but a program that *asks* will notice.
- **L4 decompose:** Run it plainly. Then put it on the receiving end of a pipe. Compare.
- **L5 near-miss:** If they redirect input rather than output, ask which end the program is
  reporting on.
- **Never say:** the exact pipeline.

### Exercise 5 — ls through a pipe
- **L1 question:** Which of the two outputs would be easier for *another program* to read?
- **L2 locate:** Notes, "Which tty am I on", last paragraph.
- **L3 concept:** Columns are a courtesy to humans and a hazard to programs. A tool that detects a
  terminal can be polite when a human is watching and predictable when one is not. Same idea makes
  `grep` colour its matches on screen and not in a file.
- **L4 decompose:** Run bare. Run into a pipe. Count names per line in each.
- **L5 near-miss:** If they see no difference, check they piped rather than just adding a flag.
- **Never say:** "one name per line".

### Exercise 6 — child shell
- **L1 question:** If you start a shell from a shell, how many shells are running?
- **L2 locate:** Notes, "Nesting".
- **L3 concept:** A child is a separate process with its own PID and its own state; leaving it
  returns you to the parent, unchanged. Same shape as opening a subfolder and going back up —
  except it is processes, not directories.
- **L4 decompose:** Read PID. Start child. Read PID. Leave. Read PID.
- **L5 near-miss:** If the two outer readings differ, they have probably nested twice by accident —
  have them run the bare process listing.
- **Never say:** —

### Exercise 7 — three deep
- **L1 question:** How will you *know* you are three deep rather than believing you are?
- **L2 locate:** Notes, the `ps` listing showing two bash lines.
- **L3 concept:** The process listing is the evidence; the count of shells in it is the depth.
- **L4 decompose:** Nest three times, listing after each. Then exit, listing after each.
- **L5 near-miss:** If they close the window instead of exiting, ask what the difference is.
- **Never say:** —

### Exercise 8 — SHELL vs ps
- **L1 question:** Where does the value in `$SHELL` come from, and when was it set?
- **L2 locate:** Notes, the Gotcha callout.
- **L3 concept:** One is a recorded preference, fixed at login. The other is a live measurement.
  They agree until you do something, and then only one of them updates.
- **L4 decompose:** Read both. Change your actual shell without logging out. Read both again.
- **L5 near-miss:** If they cannot make them disagree, ask what the notes say happens when you type
  the name of another shell.
- **Never say:** `dash`.

### Exercise 9 — the device file
- **L1 question:** The tty printed a path. What does a long listing of that path show?
- **L2 locate:** Notes, "the tty is a real file"; also `ls -l` from boot.dev.
- **L3 concept:** The first character of a long-listing line is the file's *type*, and there are
  more types than "file" and "directory". On different data: `/dev/null` is one of these too.
- **L4 decompose:** Print the path. Long-list that exact path. Read character one.
- **L5 near-miss:** If they list `/dev` entirely and drown, point them at the one path they already
  have.
- **Never say:** "character device".

### Exercise 10 — two sessions (Experiment)
- **L1 question:** What would have to be true for two windows to share a tty?
- **L2 locate:** Notes, "pts" paragraph.
- **L3 concept:** Each new session gets its own pseudo-terminal, and each shell is its own process.
  Prediction and observation both count here; a wrong prediction that is *explained* is a pass.
- **L4 decompose:** Write the prediction down first. Then measure in both.
- **L5 near-miss:** If they skipped writing the prediction, that is the exercise — send them back.
- **Never say:** the answer before their prediction exists.

### Exercise 11 — exit and the child (Experiment)
- **L1 question:** What happens to a process when it ends — does anything remain?
- **L2 locate:** Notes, "Nesting".
- **L3 concept:** A finished process leaves the table. PIDs are reused eventually, but not
  instantly, and not predictably.
- **L4 decompose:** Predict. Note the child PID. Exit. List. Look for it.
- **L5 near-miss:** If they claim the PID was reused, ask what evidence they have.
- **Never say:** —

### Exercise 12 — identify this session (Stretch)
- **L1 question:** Which of the five facts do you not yet have a command for?
- **L2 locate:** Everything needed is in this lesson's notes plus Chapter 0.
- **L3 concept:** The value is that the combination is unique — user and host are shared, tty and
  PID are not.
- **L4 decompose:** One command per fact, then combine into one line by hand.
- **L5 near-miss:** If they try to build it with a pipeline, tell them that machinery is Chapter 8
  and hand-assembly is fine now.
- **Never say:** —

### Exercise 13 — tty3 vs pts (Stretch)
- **L1 question:** Which of those two could you reach by pressing a key combination on a physical
  keyboard?
- **L2 locate:** Notes, "Which tty am I on".
- **L3 concept:** One is a device wired to hardware; the other is created on demand by software and
  disappears when the session ends.
- **L4 decompose:** Say where each one comes into existence, and when each one goes away.
- **L5 near-miss:** If they say "one is fake", push for what is actually different about it.
- **Never say:** "pseudo".

### Exercise 14 — parent PID (Dig)
- **L1 question:** What is the process-listing tool's option for choosing which columns you get?
- **L2 locate:** `man ps`, the OUTPUT FORMAT CONTROL section.
- **L3 concept:** Default columns are a choice, not a limit. Most listing tools let you name the
  fields you want. The field you need is the parent's identifier.
- **L4 decompose:** Find the section. Find the field name for a parent's PID. Ask for it.
- **L5 near-miss:** If they have the option but not the field name, point at the STANDARD FORMAT
  SPECIFIERS list, do not name the field.
- **Never say:** `ppid`, `-o`.

### Exercise 15 — who and w (Dig)
- **L1 question:** Run both. Which has more columns?
- **L2 locate:** `man who`, `man w`.
- **L3 concept:** Both read the same login records; one summarises sessions, the other adds what
  each session is doing right now.
- **L4 decompose:** Run both, diff by eye, then read each man page's DESCRIPTION first line.
- **L5 near-miss:** If they report only formatting differences, ask which command answers "what is
  cass doing".
- **Never say:** the WHAT column by name.
