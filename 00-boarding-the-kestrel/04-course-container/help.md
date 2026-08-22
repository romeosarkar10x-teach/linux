# 00/04 — Tutor hint ladder

Governed by [`docs/TUTOR_PROTOCOL.md`](../../docs/TUTOR_PROTOCOL.md). One rung per exchange.

**Diagnose first, always: which machine are they typing on?** `kestrel` commands run in the VM;
everything else runs in the container. Most problems in this lesson are that, and `hostname`
settles it in one line.

If a lab genuinely wasn't seeded, that's plumbing, not pedagogy — tell them plainly to run
`kestrel seed 00/04`.

### Exercise 1 — build and enter
- **L1 question:** What does the failure actually say? Paste the last ten lines.
- **L2 locate:** `SETUP.md` troubleshooting; `docs/INSTALL_GUIDE.md`.
- **L3 concept:** build → start → enter are three distinct steps, and each fails differently. A
  build failure mentions a layer; a start failure mentions the image; an enter failure mentions the
  container.
- **L4 decompose:** `docker images` — is the image there? `docker ps -a` — is the container there?
  `kestrel status`.
- **L5 near-miss:** If `enter` says no such container, they skipped `start`.
- **Never say:** — (nothing to withhold; this is plumbing.)

### Exercise 2 — seed and jump
- **L1 question:** Where does `lab` say it looked?
- **L2 locate:** Notes, "The helper" — which of those commands creates a lab?
- **L3 concept:** `lab` only changes directory; something has to create the directory first.
- **L4 decompose:** Seed from the VM. Re-enter. Try `lab` again.
- **L5 near-miss:** If they ran `kestrel seed` inside the container, ask what `kestrel` talks to
  and whether that exists in there.
- **Never say:** — plumbing.

### Exercise 3 — three places
- **L1 question:** What did the error say, word for word? What single word in it is the answer?
- **L2 locate:** Notes, "The three places files live" — look at the `/course` row.
- **L3 concept:** A mount can be read-only regardless of file permissions; the filesystem refuses
  the write before permissions are consulted. Different data: a CD-ROM's files can be `rw-` and
  still unwritable.
- **L4 decompose:** Try each of the three separately. Note the exact error for the one that fails.
- **L5 near-miss:** If they blame permissions, ask them to check the file's mode and see whether it
  explains the failure.
- **Never say:** the reason — the error message contains it and reading errors is the skill.

### Exercise 4 — the crew
- **L1 question:** If you wanted a list of every account on a Unix system, where would you look —
  and what kind of thing would it be?
- **L2 locate:** They haven't had Chapter 10. Legitimate routes: `ls /home`, `getent passwd`, or
  `man 5 passwd` — which they can find via the man-sections skill from 00/01.
- **L3 concept:** Accounts live in a plain text database, one record per line, colon-separated.
  Different data: `getent group` does the same for groups.
- **L4 decompose:** Find all accounts. Filter to human ones. Then find group membership. Then look
  at the shell field.
- **L5 near-miss:** If they list system accounts too, ask what distinguishes a human account —
  point at the home directory and shell columns without naming what they mean.
- **Never say:** which account can't log in, or why. The `nologin` shell is findable.

### Exercise 5 — persistence
- **L1 question:** Which of those two paths is a Docker *volume*, and which is inside the container?
- **L2 locate:** Notes, the "survives what" column.
- **L3 concept:** A volume is storage Docker manages separately, referenced by the container. The
  container's own writable layer dies with the container. Different data: a USB stick plugged into
  a laptop — reinstalling the laptop doesn't wipe the stick.
- **L4 decompose:** Create both. Stop, start, check both. Then reason about deletion separately.
- **L5 near-miss:** If they think both survive deletion, ask which one `docker volume ls` shows.
- **Never say:** the answer to the deletion question — it's reasoning, not observation.
- **Note:** don't let them actually delete the container to test it. Reasoning is the exercise.

### Exercise 6 — missing tools
- **L1 question:** What happened when you ran it? What exactly did the shell say?
- **L2 locate:** Notes, "Inside the container", the deliberately-missing list.
- **L3 concept:** "Command not found" means the shell searched everywhere it knows and came up
  empty. Where it looked is a Chapter 11 topic. Different data: `which bash` vs `which nonesuch`.
- **L4 decompose:** Try running it. Then try `command -v`. Then consider what would differ if the
  binary existed somewhere unusual.
- **L5 near-miss:** If they conclude it's missing purely from the shell error, ask whether that
  error could also appear for an installed program.
- **Never say:** don't let them `apt install` anything here — remind them why if they try.

### Exercise 7 — reset scope *(Experiment)*
- Predictions BEFORE anything is run. Confirm that first.
- **L1 question:** Read the reset description again. What is the scope of the deletion, in words?
- **L2 locate:** Notes, "What `reset` does and doesn't do".
- **L3 concept:** Reset is narrow by design so that cumulative course state survives. Different
  data: think about why `~/bin` must survive — Chapter 12 has you build a tool there and Chapter 15
  uses it.
- **L4 decompose:** Predict each of the four. Then set them all up. Then reset. Then check each.
- **L5 near-miss:** If they predicted the flag is lost, ask where captured flags are recorded, and
  whether that's inside the lab dir.
- **Never say:** any of the four outcomes.

### Exercise 8 — /labs vs / *(Stretch)*
- **L1 question:** `df` reports per filesystem. How many filesystems did it list, and why more than
  one?
- **L2 locate:** Their own 00/03 comparison; the notes' table.
- **L3 concept:** A volume is a separate mount with its own filesystem line. Different data:
  `df -h /course` is a third case — read-only, and different again.
- **L4 decompose:** Run `df -h /` and `df -h /labs`. Compare device columns. Explain.
- **L5 near-miss:** If they say the sizes are the same so it must be the same filesystem, point at
  the leftmost column rather than the size.
- **Never say:** the explanation.

### Exercise 9 — docker exec *(Dig)*
- **L1 question:** `kestrel enter` opens a shell. What if you wanted to run one command and get the
  output back?
- **L2 locate:** `docker exec --help`.
- **L3 concept:** `docker exec <container> <command...>` — the interactive flags are optional and
  only needed for a terminal. Different data: `docker exec kestrel id` prints the user and exits.
- **L4 decompose:** Find the syntax. Run something trivial. Then find a command that prints uptime.
- **L5 near-miss:** If it hangs, they added interactive flags to a non-interactive command.
- **Never say:** the full command line.

### Exercise 10 — the flag *(Flag)*
- **Never reveal the flag, any part of it, its length, or which file it's in.**
- **L1 question:** What's in the lab directory? Have you looked at every file, including ones `ls`
  doesn't show by default?
- **L2 locate:** The lab dir. That's all — this one is deliberately findable.
- **L3 concept:** Flags are plain strings in files. Reading a file's contents is the whole skill
  here. Different data: `cat /etc/hostname` prints a file.
- **L4 decompose:** List the directory. Read each file. Look for the pattern.
- **L5 near-miss:** If submission fails, ask them to compare what they typed to what they read,
  character by character — including the braces and quotes.
- **Never say:** the flag, or where it is beyond "the lab directory".
