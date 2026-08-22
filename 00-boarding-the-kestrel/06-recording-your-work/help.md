# 00/06 — Tutor hint ladder

Governed by [`docs/TUTOR_PROTOCOL.md`](../../docs/TUTOR_PROTOCOL.md). One rung per exchange.

These exercises are about the evidence a validator will read. A student who half-does this lesson
is unvalidatable for the rest of the course, so hold the line here.

### Exercise 1 — timestamps
- **L1 question:** Run `history | tail`. Do you see times? What would have to be set for you to?
- **L2 locate:** Notes, "History", the four settings.
- **L3 concept:** History stores commands; timestamps are only *displayed* if a format variable
  says how. Different data: set `HISTTIMEFORMAT='%T '` in your current shell and re-run `history`.
- **L4 decompose:** Check whether the variable is set. Look at its value. Run `history`.
- **L5 near-miss:** If they see no times, ask whether the variable is set in *this* shell — check
  with `echo`.
- **Never say:** the variable name if they haven't looked at the notes; it's right there.

### Exercise 2 — first transcript
- **L1 question:** What did `script` print when you started it, and where did it say it was writing?
- **L2 locate:** Notes, "Transcripts with `script`".
- **L3 concept:** `script` starts a nested shell that copies everything to a file. You're in a shell
  inside a shell until you `exit`. Different data: run `echo $$` inside and outside — the numbers
  differ. (Chapter 1 explains `$$`.)
- **L4 decompose:** Start it. Run the commands. Exit. Then look at the file.
- **L5 near-miss:** If the file is empty, ask whether they exited the script session or just closed
  the terminal.
- **Never say:** the flag combination — it's in the notes.

### Exercise 3 — replay
- **L1 question:** What information is in the `.timing` file that isn't in the `.log`?
- **L2 locate:** Notes, the `scriptreplay` line; `man scriptreplay`.
- **L3 concept:** The log holds *what*; the timing file holds *when*. Together they reconstruct the
  session in time. Different data: a chess game's move list versus the same list with clock times.
- **L4 decompose:** Find the replay command. Give it both files. Watch.
- **L5 near-miss:** If replay is instant, they omitted the timing file argument.
- **Never say:** the answer to what timing contributes — that's the exercise.

### Exercise 4 — per-lesson snapshot
- **L1 question:** If bash writes history on exit, and you haven't exited, what's in the file right
  now?
- **L2 locate:** Notes, `history -a`.
- **L3 concept:** In-memory history and the file are different things until something flushes.
  Different data: an unsaved document.
- **L4 decompose:** Flush. Redirect. Check.
- **L5 near-miss:** If their file is missing recent commands, ask what order they did the two steps
  in.
- **Never say:** the flush flag before they've read the notes — send them there.

### Exercise 5 — docker cp
- **L1 question:** Which of `/labs` and `/home/cadet` is a Docker volume? You worked this out in
  00/04.
- **L2 locate:** Their 00/04 answers; notes, "Getting it out of the container".
- **L3 concept:** Copying out creates an independent copy on the VM's filesystem, outside Docker's
  lifecycle entirely.
- **L4 decompose:** Copy. Verify on the VM. Stop/start. Verify inside.
- **L5 near-miss:** If `docker cp` errors on the path, ask whether they're running it in the VM or
  the container.
- **Never say:** which copy survives deletion — they derived it in 00/04.

### Exercise 6 — OBS
- Environmental. If OBS won't capture, it's usually Wayland vs X11 — ask which session type they
  logged into.
- On legibility: do not accept "it's fine". Ask them to read a specific character from the recorded
  playback. If they can't, the font is too small.

### Exercise 7 — what gets recorded *(Experiment)*
- Predictions BEFORE testing. Confirm that first.
- **L1 question:** Does bash record what you *ran*, or what you *typed*? Are those the same?
- **L2 locate:** `man bash`, search for `HISTCONTROL`.
- **L3 concept:** History records typed lines, subject to filters. Two filters matter: duplicates
  and leading spaces. Different data: predict what a setting named `ignoreboth` would do before you
  read what it does.
- **L4 decompose:** Test them one at a time, checking the file after each.
- **L5 near-miss:** If the leading-space case surprises them, ask what a setting called
  `ignorespace` would be for.
- **Never say:** which cases are recorded. Every one must be observed.

### Exercise 8 — timing from history *(Stretch)*
- **L1 question:** With `HISTTIMEFORMAT` set, what does each history line actually contain?
- **L2 locate:** Their own history output.
- **L3 concept:** Elapsed time is arithmetic on timestamps; the largest gap needs comparing
  consecutive pairs. Different data: how would you find the longest gap in a train timetable by eye?
- **L4 decompose:** First timestamp. Last timestamp. Subtract. Then scan for the big jump.
- **L5 near-miss:** If they're trying to automate it and floundering, remind them Chapter 7 exists
  and that by eye is explicitly allowed here.
- **Never say:** don't hand them a Chapter 7 pipeline — those tools aren't taught yet.

### Exercise 9 — script flags *(Dig)*
- **L1 question:** What happens to yesterday's transcript if you run `script` again with the same
  filename?
- **L2 locate:** `man script`, OPTIONS.
- **L3 concept:** Output is buffered for speed; a crash loses whatever is still in the buffer. One
  flag trades speed for durability. Different data: the same tradeoff exists for log files
  generally.
- **L4 decompose:** Find the append flag. Find the flush flag. Then reason about the crash.
- **L5 near-miss:** If they picked append for the crash case, ask what append protects — the old
  file, or the current one.
- **Never say:** either flag.

### Exercise 10 — HISTCONTROL *(Dig)*
- **L1 question:** In exercise 7, one of your cases wasn't recorded. What setting would explain it?
- **L2 locate:** `man bash`, search `HISTCONTROL`. It's in the Shell Variables section.
- **L3 concept:** A colon-separated list of filters. Different data: `HISTIGNORE` is a sibling that
  filters by pattern instead.
- **L4 decompose:** Find the variable. List its values. Then reason about which destroys evidence.
- **L5 near-miss:** If they name the variable but not all values, ask how many the man page lists.
- **Never say:** the values.
