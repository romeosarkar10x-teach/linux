# 01/06 — Tutor hint ladder

Governed by [`docs/TUTOR_PROTOCOL.md`](../../docs/TUTOR_PROTOCOL.md). One rung per exchange.

**Diagnose first:** ask where they think a command lives the moment after they press Enter. If the
answer is "in `.bash_history`", stop and fix that before anything else — half this lesson's
confusions come from it.

**Safety check before hinting on 11, 12, 16 or 20:** confirm they are in a child shell. If they are
not, say so plainly and immediately. This is plumbing, not pedagogy.

### Exercise 1 — last ten
- **L1 question:** Does the listing command take an argument?
- **L2 locate:** Notes, "Reading the list".
- **L3 concept:** With no argument you get everything; with a number you get that many recent lines.
- **L4 decompose:** Run it bare. Then with a count.
- **L5 near-miss:** If they pipe into something to limit it, accept it and mention the argument.
- **Never say:** —

### Exercise 2 — re-run the previous
- **L1 question:** The notes' table of re-run forms starts with the shortest one. What is it?
- **L2 locate:** Notes, "Re-running things".
- **L3 concept:** A two-character form stands for the whole previous line.
- **L4 decompose:** Run something. Then that form.
- **L5 near-miss:** If they used the up arrow, that works — ask for the typed form as well.
- **Never say:** `!!`.

### Exercise 3 — last argument
- **L1 question:** Which row of the table mentions the last argument?
- **L2 locate:** Notes, "Re-running things", and the callout after it.
- **L3 concept:** Expansion happens when you press Enter, and bash shows you the result before
  running it. That echo is a feature — read it.
- **L4 decompose:** First command. Then the second with the shortcut. Read the echoed line.
- **L5 near-miss:** If they missed the echo, ask what appeared between their input and the output.
- **Never say:** `!$`.

### Exercise 4 — search without running
- **L1 question:** Which key starts a backwards search through history?
- **L2 locate:** Notes, "Searching: `Ctrl-R`".
- **L3 concept:** The search puts a candidate on your line. Pressing Enter runs it; there is a
  different key that stops and leaves it there for you to read. Different example: searching for
  `rm` and finding something you very much do not want to run blind.
- **L4 decompose:** Start the search. Type a fragment. Then find the key that gets you out
  *without* running.
- **L5 near-miss:** If it ran, ask which key they pressed at the end.
- **Never say:** `Ctrl-R`, `Esc`.

### Exercise 5 — search and run
- **L1 question:** What is the risk you are accepting by running straight from a search?
- **L2 locate:** Notes, "Searching: `Ctrl-R`".
- **L3 concept:** The match shown is the most recent one; older matches are behind it, and you may
  not have the one you think.
- **L4 decompose:** Search. Confirm the match is the one you want. Then run.
- **L5 near-miss:** If they ran the wrong command, that is the lesson — ask them to write it up.
- **Never say:** —

### Exercise 6 — three recall forms
- **L1 question:** The table has forms for a number, for a prefix, and for a substring. Can you tell
  which is which by their punctuation?
- **L2 locate:** Notes, "Re-running things".
- **L3 concept:** One matches by position, one by how the command starts, one by anything inside it.
  The substring form is the one with the extra punctuation.
- **L4 decompose:** Get the numbers from the listing. Then each form in turn.
- **L5 near-miss:** If the prefix form matched something unexpected, ask what "most recent" means
  here.
- **Never say:** the three forms.

### Exercise 7 — list versus file
- **L1 question:** When does the file get written?
- **L2 locate:** Notes, "Two places, not one", and "Moving history between shells".
- **L3 concept:** The list is memory and the file is disk, and nothing moves between them until the
  shell exits — or until you ask. Different example: two shells open, one exits, and the other's
  work has not been written yet.
- **L4 decompose:** Run something distinctive. Check the list. Check the file. Then find the flag
  that appends without exiting. Check the file again.
- **L5 near-miss:** If they exit the shell to make it appear, that works and dodges the exercise —
  ask them to do it without exiting.
- **Never say:** `history -a`.

### Exercise 8 — reading maint-old-history
- **L1 question:** It is a text file. Have you simply read it?
- **L2 locate:** Notes, "The file is just a file".
- **L3 concept:** Not every line is a command. Half of them start with a character that means
  something specific here.
- **L4 decompose:** Read it. Separate the two kinds of line. Count one kind.
- **L5 near-miss:** If they count every line as a command, ask what the `#` lines have in common.
- **Never say:** "timestamps".

### Exercise 9 — the truncated last line
- **L1 question:** The last line names something that does not exist. What in this directory does it
  nearly name?
- **L2 locate:** Notes, "Two places, not one", last bullet.
- **L3 concept:** The file is written by the shell as the session ends, so an interruption at the
  wrong moment leaves the final line unfinished. Different example: a log file cut mid-entry when a
  machine loses power.
- **L4 decompose:** Read the fragment. Look at the directory. Then ask what would have to happen for
  a file to end mid-word.
- **L5 near-miss:** If they say "the user made a typo", ask whether a typo would be *missing the
  rest of the word* or *having the wrong letters*.
- **Never say:** the completed filename.

### Exercise 10 — what history -c does not do
- **L1 question:** Which of the two places — memory or disk — does that command touch?
- **L2 locate:** Notes, the callout under "Moving history between shells".
- **L3 concept:** Clearing the list empties memory only. The file is unaffected at that instant, and
  anything typed afterwards is appended to a now-shorter list which is written on exit.
- **L4 decompose:** Say what it clears. Say what it does not. Then look at what follows it in the
  file and explain how those lines got there.
- **L5 near-miss:** If they say it deleted the file, ask them to look at the file again.
- **Never say:** —

### Exercise 11 — the leading space
- **L1 question:** Which value of `HISTCONTROL` mentions a space?
- **L2 locate:** Notes, "Controlling what gets recorded".
- **L3 concept:** A single leading space is a signal to the shell to skip recording. It exists so
  secrets do not land in a plain-text file in your home directory. Different example: typing an API
  token into a `curl` line.
- **L4 decompose:** Check the setting's value first. Then run a command with a leading space. Then
  look at the list.
- **L5 near-miss:** If it was recorded anyway, ask what their `HISTCONTROL` actually contains.
- **Never say:** `ignorespace`.

### Exercise 12 — a tiny HISTSIZE
- **L1 question:** What does that variable control — the file, or memory?
- **L2 locate:** Notes, "Controlling what gets recorded", the second block.
- **L3 concept:** The list is capped; older lines fall off the front. A child shell's settings do
  not reach back into its parent — which is the more important half of this exercise.
- **L4 decompose:** Child shell. Set it. Run five commands. List. Exit. Check the parent.
- **L5 near-miss:** If their main session lost history, they were not in a child shell — note it and
  move on.
- **Never say:** —

### Exercise 13 — `!!` twice (Experiment)
- **L1 question:** After the third line runs, what is now "the previous command"?
- **L2 locate:** Notes, "Re-running things".
- **L3 concept:** The expansion is resolved against history *at the moment you press Enter*, and the
  expanded line is itself added to history. So the reference moves.
- **L4 decompose:** Both predictions written. Then run all four lines.
- **L5 near-miss:** If they predicted the fourth would repeat `echo one`, that is a reasonable
  prediction — ask what the third line put into history.
- **Never say:** the outcome.

### Exercise 14 — `!$` and `!^` (Experiment)
- **L1 question:** Same question as exercise 13: by the time line three runs, what is line two?
- **L2 locate:** Notes, "Re-running things".
- **L3 concept:** The second line is added to history in its **expanded** form, so the third line's
  reference points at the expansion, not at the original command. This is the single most common
  history-expansion surprise.
- **L4 decompose:** All three predictions written first. Then run, reading each echoed expansion.
- **L5 near-miss:** If the third result confuses them, tell them to look at the echoed line rather
  than the output.
- **Never say:** the result of the third line.

### Exercise 15 — two shells (Experiment)
- **L1 question:** Where does a running shell keep its list?
- **L2 locate:** Notes, "Two places, not one".
- **L3 concept:** Two shells are two processes with two separate memories. Nothing crosses between
  them without going through the file, and nothing goes to the file until something writes it.
- **L4 decompose:** Predictions written. Then A runs something. B checks. A exits. B reads the file.
- **L5 near-miss:** If B still does not see it after the read, ask whether A actually exited, and
  whether A's shell was configured to write on exit.
- **Never say:** —

### Exercise 16 — HISTFILE unset versus empty (Stretch)
- **L1 question:** Which lesson taught you that those are different states?
- **L2 locate:** 01/04 notes, "Unset is not empty"; this lesson's `HISTFILE` line.
- **L3 concept:** The distinction is real in principle. Whether it produces different *behaviour*
  here is an empirical question, and finding out that it does not is a perfectly good result.
- **L4 decompose:** Prediction. Child shell, unset it, run something, exit, check the file's
  modification time. Child shell again, set it empty, repeat.
- **L5 near-miss:** If both cases behave identically, that is a finding — have them write it down
  rather than hunting for a difference that is not there.
- **Never say:** the outcome either way.

### Exercise 17 — where `!$` bites (Stretch)
- **L1 question:** When does `!$` get expanded, relative to when you decide to use it?
- **L2 locate:** Notes, the "`!$` versus `Alt-.`" callout.
- **L3 concept:** One shows you the text while you can still change it; the other commits and then
  tells you. Any command with several arguments, where the last one is not the interesting one, sets
  the trap. Different example: `cp a.txt b.txt backup/` — the last argument is the directory.
- **L4 decompose:** Construct a previous command whose last argument is not what you want. Use both
  approaches. Compare when you found out.
- **L5 near-miss:** If their example is harmless, ask them to make it one where running it would
  matter.
- **Never say:** the example.

### Exercise 18 — classify history (Stretch)
- **L1 question:** Where does the history list live?
- **L2 locate:** 01/03 notes; this lesson's "Two places, not one".
- **L3 concept:** Same argument as `cd` and `unset`. Memory belonging to the shell can only be read
  and modified by the shell itself.
- **L4 decompose:** Classify it. Then ask what a separate program would need access to.
- **L5 near-miss:** If they say it reads the file, ask how it would show commands not yet written.
- **Never say:** "builtin".

### Exercise 19 — decoding the epoch (Dig)
- **L1 question:** Which everyday command deals with dates and times?
- **L2 locate:** `man date`, and search within it for the `@` character.
- **L3 concept:** A count of seconds since a fixed instant is the standard machine representation
  of a moment, and the date tool can be told to interpret a number that way rather than as a
  format. Different example: file modification times are stored the same way.
- **L4 decompose:** Find the option that sets which date to display. Find how to feed it an epoch
  value. Apply it to the right `#` line.
- **L5 near-miss:** If they get the current date, they are formatting rather than converting — point
  them back at the `@` notation.
- **Never say:** `date -d @`.

### Exercise 20 — loading another history file (Dig)
- **L1 question:** The notes list four flags for moving history around. Which one reads?
- **L2 locate:** Notes, "Moving history between shells"; `help history`.
- **L3 concept:** The read flag takes a filename, so it can load any file, not just your own. The
  danger is that the loaded lines then belong to your list and will be written to *your* file when
  the shell exits.
- **L4 decompose:** Child shell. Read the file. List. Then reason about what would happen on exit in
  a non-child shell.
- **L5 near-miss:** If they did it in their main shell, tell them to clear the list before exiting,
  and note it.
- **Never say:** `history -r`.

### Exercise 21 — substitution on recall (Dig)
- **L1 question:** `man bash` has a section on history expansion. Have you found Event Designators?
- **L2 locate:** `man bash`, HISTORY EXPANSION → Event Designators → Word Designators → Modifiers.
- **L3 concept:** A recalled command can have modifiers appended that transform it before it runs —
  including a search-and-replace on the text. There is also a shorthand form for "previous command,
  with this replaced by that". Different example: fixing `grpe` to `grep` in a long pipeline.
- **L4 decompose:** Find Modifiers. Find the substitute modifier. Then look just above for the
  shorthand that applies it to the previous command directly.
- **L5 near-miss:** If they retype the command with the new filename, that works and is not the
  exercise.
- **Never say:** `^old^new`, `!!:s/`.
