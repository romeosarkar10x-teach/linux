# 01/07 — Tutor hint ladder

Governed by [`docs/TUTOR_PROTOCOL.md`](../../docs/TUTOR_PROTOCOL.md). One rung per exchange.

**This is an incident. Hint more slowly than usual.** The value of a finale is that the student
assembles it themselves; a tutor who compresses the search has removed the exercise. Prefer asking
what they have already ruled out.

**Never reveal the flag, the reconstructed command, or which `.dat` file is the right one.** If the
student asks directly, say plainly that you will not, and offer to work through the evidence with
them instead. That refusal is required by `docs/AGENT_MODES.md`.

**Do not narrate the story.** This lab is trace 1 of an arc that resolves in Chapter 15
(`_handoff/SCENARIOS.md`). Nothing here means anything sinister yet, and it is not the tutor's job
to make it sound like it does. If the student speculates about dorn, engage with the *evidence* they
can point at and let the rest alone.

**Diagnose first:** ask whether they have read the entire file, in order, before theorising. Most
students go straight to the last line. That is the wrong end.

### Exercise 1 — count the commands
- **L1 question:** Is every line in that file a command?
- **L2 locate:** 01/06 notes, "The file is just a file"; 01/06 exercise 8, which is the same skill on
  a different file.
- **L3 concept:** Timestamped history files interleave two kinds of line. You met this exact format
  in the previous lesson.
- **L4 decompose:** Read it. Sort the lines into two kinds. Count one kind.
- **L5 near-miss:** If they count every line, ask what the `#` lines have in common.
- **Never say:** the count.

### Exercise 2 — the working directory
- **L1 question:** Does anything in the history *change* the working directory?
- **L2 locate:** The history file itself.
- **L3 concept:** A history is a sequence, and state accumulates through it. Where you end up depends
  on every directory change along the way, in order.
- **L4 decompose:** Find every line that moves. Apply them in order. Where do you finish?
- **L5 near-miss:** If they name the first directory change, ask whether it was the last one.
- **Never say:** the directory.

### Exercise 3 — the two non-leads
- **L1 question:** For each line in that file: could it plausibly have produced something the next
  line acts on? Which lines are self-contained?
- **L2 locate:** The history file.
- **L3 concept:** Investigations proceed by elimination. A line that is interesting to *you* is not
  the same as a line that is interesting to the *case* — and a very long, complicated-looking command
  is often just somebody doing routine work. Different example: a lengthy backup command in the
  middle of a log is usually a backup, not a clue.
- **L4 decompose:** Take the longest line. What is it for? Now look for two lines that are nearly
  identical to each other — what is the difference between them, and what does that difference tell
  you happened?
- **L5 near-miss:** If they are convinced the long line matters, ask what they would do with its
  output if they had it, and whether that gets them closer to the last line.
- **Never say:** which two lines, or the words "typo" and "housekeeping".

### Exercise 4 — locate the cut
- **L1 question:** Read the last line out loud. At what point does it stop making sense?
- **L2 locate:** 01/06 exercise 9 — the same task, easier data.
- **L3 concept:** A cut leaves the correct characters and then nothing. It does not leave wrong
  characters. So the fragment is a genuine prefix of what was typed.
- **L4 decompose:** Which word is incomplete? What is the last character of it? What would normally
  follow a word of that shape?
- **L5 near-miss:** If they say the whole line is wrong, ask which part of it they are confident
  about.
- **Never say:** —

### Exercise 5 — reconstruct
- **L1 question:** The fragment names something incompletely. What is in this directory that starts
  the same way?
- **L2 locate:** `ls` in the lab; the history file's earlier lines.
- **L3 concept:** Reconstruction is evidence, not invention. Every character you add should come from
  something you can point at — a filename that exists, a command earlier in the same history. If you
  are choosing between candidates, look for an earlier line that names one of them specifically.
  Different example: a log ending `cp report-2186-1` in a directory holding `report-2186-11.txt` and
  `report-2186-12.txt` — the tie is broken by whatever else the session touched.
- **L4 decompose:** List the candidates that match the fragment. Then go back through the history and
  ask which of them the session had already been working with.
- **L5 near-miss:** If they have narrowed it to the right file but are unsure, ask what would happen
  if they were wrong — and point out that the lab tells them, loudly.
- **Never say:** the filename, or the completed command.

### Exercise 6 — the flag
- **L1 question:** Did the script run, or did it refuse? Read what it said.
- **L2 locate:** Its own usage line.
- **L3 concept:** The script tells you what it needs. A refusal is information about the argument,
  not about the reconstruction being hopeless.
- **L4 decompose:** Run it with the argument. Read every line of output, not just the last.
- **L5 near-miss:** If they get a `command not found`, that is 01/03 exercise 9 — ask where the shell
  looks for commands.
- **Never say:** the flag, under any circumstances, including if the student claims to have already
  found it.

### Exercise 7 — the other sample sets
- **L1 question:** What did the script report for the other two, and did it stop before or after the
  point where it reported a token?
- **L2 locate:** The script's output.
- **L3 concept:** The fact that the wrong files fail *loudly* is what makes the reconstruction
  verifiable. If all three had succeeded with different tokens, none of them could be trusted.
- **L4 decompose:** Run all three. Compare the declared and present counts. Then answer the question
  about uniqueness.
- **L5 near-miss:** If they conclude "so I could have guessed", agree — and ask how they would have
  known which of the three answers to submit.
- **Never say:** —

### Exercise 8 — the `history -c` (Experiment)
- **L1 question:** Which of the two places — memory or disk — does that command touch?
- **L2 locate:** 01/06 notes, the callout under "Moving history between shells"; 01/06 exercise 10.
- **L3 concept:** Clearing the list is a memory operation. Anything typed afterwards goes into the
  now-empty list and is written on exit, which is exactly why lines appear after it.
- **L4 decompose:** Prediction in writing. Then look at what is actually in the file after that line
  and reconcile.
- **L5 near-miss:** If they conclude the file was tampered with, slow down: ask them to explain the
  file using only the mechanism from 01/06, and see if it fits. It does.
- **Never say:** anything that frames this as concealment. It is a person clearing their own history,
  which people do routinely.

### Exercise 9 — load it into a shell (Experiment)
- **L1 question:** Which 01/06 flag reads a file into the history list?
- **L2 locate:** 01/06 exercise 20; `help history`.
- **L3 concept:** The list will render whatever it loads using your own display settings, so
  timestamps appear if you have them switched on. And the truncated line is just text — it loads
  like any other line.
- **L4 decompose:** Predictions written. Child shell. Load. List. Exit.
- **L5 near-miss:** If they did it in their main shell, tell them to check their own history file
  afterwards for 2187 timestamps.
- **Never say:** —

### Exercise 10 — the timestamp (Stretch)
- **L1 question:** You did this in the previous lesson. Which command?
- **L2 locate:** 01/06 exercise 19; `man date`.
- **L3 concept:** Same conversion, different file.
- **L4 decompose:** Take the last `#` line. Convert. Then the one before it. Subtract.
- **L5 near-miss:** If the interval looks implausible, check which two timestamps they used.
- **Never say:** —

### Exercise 11 — why `./` (Stretch)
- **L1 question:** Where does the shell look for a command word?
- **L2 locate:** 01/03 notes, "Five kinds of command word", item 5; 01/03 exercise 9.
- **L3 concept:** The current directory is not searched, so a program sitting right in front of you
  still needs a path.
- **L4 decompose:** Say what `./` means. Then say what error you get without it.
- **L5 near-miss:** If they say "it means run it", push for *why* that is necessary.
- **Never say:** —

### Exercise 12 — the mechanism (Stretch)
- **L1 question:** At the moment the file was being written, what was the shell doing?
- **L2 locate:** 01/06 notes, "Two places, not one".
- **L3 concept:** The write happens at exit, line by line, into a file. If the process ends partway
  through that write, whatever had been flushed is on disk and the rest never arrives. Nothing needs
  to go wrong beyond the timing.
- **L4 decompose:** Where were the lines before the write? What triggers the write? What is left if
  it is interrupted?
- **L5 near-miss:** If they reach for deliberate truncation, ask what the simplest explanation is and
  whether the evidence distinguishes them. It does not, and saying so is a *better* answer than
  picking one.
- **Never say:** anything that asserts intent, either way.

### Exercise 13 — strip the timestamps (Dig)
- **L1 question:** You have no filtering tool. What do you have that can select part of a file, or
  that can put text somewhere?
- **L2 locate:** Chapter 0's redirection; 01/06's history builtin.
- **L3 concept:** With a small file, hand-assembly is legitimate. The exercise is partly to make the
  absence of a filter *felt* — Chapter 6 exists because of exactly this frustration.
- **L4 decompose:** Get the content somewhere writable. Remove what you do not want, however you
  like. Then articulate what tool you wanted.
- **L5 near-miss:** If they discover `grep -v` on their own, accept it and ask them to also say what
  they would have done without it.
- **Never say:** `grep -v '^#'`.

### Exercise 14 — read-only (Dig)
- **L1 question:** What exactly does the error say, and which part of the system produced it?
- **L2 locate:** `ls -l` on the file.
- **L3 concept:** File permissions are advisory against the owner: the owner can change the
  permissions and then change the file. Real protection is somebody else owning it, or a
  filesystem that will not accept writes at all. Different example: `/course` in this container is
  read-only at the *mount* level, which is a much stronger statement.
- **L4 decompose:** Try a write. Read the error. Look at who owns the file. Ask what that owner can
  do about the mode.
- **L5 near-miss:** If they actually modify it, that fails the incident's one rule — tell them to
  `kestrel reset 01/07` and note it.
- **Never say:** the chmod invocation.

---

## If the student is stuck for a long time

In order:

1. Have they read the whole file, in order? Most have not.
2. Have they done exercise 3 — the elimination — *before* reconstructing? Most have not.
3. Do they understand 01/06 exercise 9? If not, send them back to it. That is the prerequisite, and
   it is better to spend twenty minutes there than to hand them this.
4. Have they simply run `ls` in the lab directory?

That fourth question resolves more of these than the other three together.
