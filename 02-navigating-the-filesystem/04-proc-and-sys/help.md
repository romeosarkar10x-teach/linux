# 02/04 — Tutor hint ladder

Read `docs/TUTOR_PROTOCOL.md` first. One rung per exchange. Never state a command.

This lesson has a recurring failure mode: the student treats `/proc` as a place where files were
*written*. Almost every confusion in exercises 17, 18 and 20 dissolves once they accept that the
kernel manufactures the contents at the moment of the read. Steer toward that idea; do not announce
it.

**Escalation notes**

- If the student is stuck on *which file*, that is a `man 5 proc` problem, not a thinking problem —
  go to L2 quickly. It is a very long page; teach them to search inside it rather than scroll.
- If they are stuck on *why the number is zero*, stay at L1/L3 much longer than usual. This is the
  lesson's load-bearing idea and handing it over costs exercises 17, 20 and half of Chapter 6.
- Exercise 16 has a correct answer that sounds like a cop-out ("the kernel is not the container's").
  Do not let a confident-sounding wrong answer past; ask for the second piece of evidence.
- Exercises 9–14 depend on a live process. If their `waiter.sh` died, that is not a wrong answer —
  restart it and continue.

---

### Exercise 1
- **L1 question:** Look at the names in `/proc`. What do most of them have in common, and what do the
  handful that break that pattern have in common with each other?
- **L2 locate:** Notes, "Two synthetic filesystems". Or `man 5 proc`, the opening paragraphs.
- **L3 concept:** A directory can mix two populations. In `/dev` you find `sda1`, `sda2`, `sda3` —
  clearly one family — alongside `null` and `random`, which are something else entirely.
- **L4 decompose:** (1) list it; (2) sort the entries into "name is a number" and "name is a word";
  (3) say what one number could possibly identify.
- **L5 near-miss:** If they say "files and directories", push: the numbered ones are *all*
  directories. What is there exactly one of, per number?
- **Never say:** "one directory per running process".

### Exercise 2
- **L1 question:** Which single file would a program read if it wanted to print the kernel's version?
- **L2 locate:** Notes, system-wide files table.
- **L3 concept:** Both are plain reads of a named file — no flags, no tools beyond the one you use
  for any text file.
- **L4 decompose:** (1) find the version file; (2) find the uptime file; (3) note uptime has two
  numbers, and answer with the first.
- **L5 near-miss:** If they reach for `uname` or `uptime`, accept the curiosity but redirect: the
  exercise says *from `/proc`*, and those commands are reading these files anyway.
- **Never say:** `/proc/version`, `/proc/uptime`.

### Exercise 3
- **L1 question:** You do not know your own PID. Is there a name in `/proc` that means "whoever is
  asking"?
- **L2 locate:** Notes, section on `/proc/self`.
- **L3 concept:** Some names resolve relative to the asker rather than to a fixed target — the way
  `.` means a different directory depending on where you stand.
- **L4 decompose:** (1) `ls` the self directory; (2) find the entry holding a short name; (3) read it.
- **L5 near-miss:** If they read `cmdline` instead of `comm`, ask which one is a *short* name.
- **Never say:** `cat /proc/self/comm`.

### Exercise 4
- **L1 question:** In `/proc/cpuinfo`, what repeats once per processor? In `/sys`, what is the
  directory tree that would have one entry per CPU?
- **L2 locate:** Notes, `/sys` section. `man 5 proc`, search for `cpuinfo`.
- **L3 concept:** Two designs for the same fact: one file with a repeated block, versus one path per
  object with a tiny file at each leaf. Compare `/etc/passwd` (all users, one file) against a
  per-user directory tree.
- **L4 decompose:** (1) read cpuinfo and count a repeating field; (2) find the CPU directory under
  `/sys/devices/system/`; (3) find a file there that names the online range.
- **L5 near-miss:** If they got `0-23` and answered "0-23", ask how many integers that is.
- **Never say:** `/sys/devices/system/cpu/online`, or the number 24.

### Exercise 5
- **L1 question:** Read the first line of the memory file exactly as written. What is at the end?
- **L2 locate:** `man 5 proc`, search `meminfo`.
- **L3 concept:** A file that reports a quantity usually reports the unit next to it. Believing your
  assumption over the printed unit is how a 32 GB machine becomes a 32 MB one.
- **L4 decompose:** (1) read the first line; (2) copy the unit verbatim; (3) convert to GB yourself.
- **L5 near-miss:** If they say bytes, ask them to re-read the line and quote it.
- **Never say:** "kB".

### Exercise 6
- **L1 question:** What is something you would like to know about this machine that no amount of
  `cd` would tell you?
- **L2 locate:** Notes, the system-wide files table — every row is a candidate.
- **L3 concept:** Pair each fact with its source path, the way a citation pairs a claim with a page
  number. A fact without its path is not checkable by anyone else.
- **L4 decompose:** (1) pick three rows; (2) read each; (3) write fact + path.
- **L5 near-miss:** If they list three facts with no paths, that is the half that is graded — ask
  for it.
- **Never say:** which three to pick.

### Exercise 7
- **L1 question:** Three of the five fields are obviously a series. What could the remaining two be,
  given they are not averages?
- **L2 locate:** `man 5 proc` — search for `loadavg`; the entry is short and explicit.
- **L3 concept:** The fourth field is a fraction with a slash in it, which is a strong hint it is a
  count over a count rather than a rate.
- **L4 decompose:** (1) find the loadavg paragraph; (2) map field 4's two halves; (3) map field 5.
- **L5 near-miss:** If they call field 4 "CPU usage", ask what the slash separates.
- **Never say:** "runnable / total processes, and the most recent PID".

### Exercise 8
- **L1 question:** What is the *first* process the kernel starts, and what does that process have to
  do for the rest of the system to work?
- **L2 locate:** Notes, "one directory per process". Read PID 1's `cmdline` and `comm`.
- **L3 concept:** On a normal Linux machine PID 1 is an init system with a large job. A container is
  started to run one thing; whatever that thing is becomes PID 1 by default.
- **L4 decompose:** (1) read `/proc/1/cmdline`; (2) read `/proc/1/comm`; (3) ask what would happen
  to this container if that process exited.
- **L5 near-miss:** If they say "systemd", ask them to read the file rather than recall the fact.
- **Never say:** `sleep infinity`.

### Exercise 9
- **L1 question:** You have a PID. `/proc` is organised by PID. What is the path?
- **L2 locate:** Notes, "one directory per process".
- **L3 concept:** The number is the directory name, not the contents of anything.
- **L4 decompose:** (1) note the PID printed at startup; (2) list that directory.
- **L5 near-miss:** If they get "No such file", their process died — restart it.
- **Never say:** the literal path.

### Exercise 10
- **L1 question:** Two entries in that directory are symlinks pointing outside `/proc`. Which
  command shows you where a symlink points?
- **L2 locate:** Notes table — the `cwd` and `exe` rows. `ls -l` from 02/02.
- **L3 concept:** Your shell script is not an executable image the kernel can run on its own. Ask
  what the first line of the script asked the kernel to start.
- **L4 decompose:** (1) `ls -l` both symlinks; (2) compare `exe`'s target to the path of the script
  you ran; (3) explain the difference.
- **L5 near-miss:** If they say "the link is broken because it does not say waiter.sh", ask what
  program is *interpreting* waiter.sh.
- **Never say:** "it points at bash".

### Exercise 11
- **L1 question:** How many arguments did you type, and how many word-gaps do you see in the output?
- **L2 locate:** Notes, the NUL-separated `cmdline` note.
- **L3 concept:** The shell hands the kernel a list of strings, not one string. To store a list in a
  flat file you need a separator, and any printable separator could legally appear inside an
  argument.
- **L4 decompose:** (1) read `cmdline`; (2) say where each argument boundary must be; (3) say what
  byte is sitting there.
- **L5 near-miss:** If they say "the spaces were deleted", ask what would happen to a filename that
  legitimately contains a space.
- **Never say:** "NUL bytes", nor `tr` — Chapter 7 owns that.

### Exercise 12
- **L1 question:** `status` is long. Which three lines have names that match the three things you
  were asked for?
- **L2 locate:** `man 5 proc`, search `status`; or just read the file.
- **L3 concept:** These files are designed to be read by programs, so the field names are terse but
  literal. "Parent" is not spelled out.
- **L4 decompose:** (1) read the file; (2) find the three fields; (3) sanity-check the parent PID
  against the shell you ran it from.
- **L5 near-miss:** If the state letter confuses them, the file spells it out in brackets.
- **Never say:** the field names verbatim.

### Exercise 13
- **L1 question:** Every process gets three descriptors for free. What are they conventionally
  called, and what should they be attached to for a process started from your shell?
- **L2 locate:** Notes, the `fd/` row. Chapter 1's discussion of what a terminal is.
- **L3 concept:** A descriptor is a symlink to whatever the process can read from or write to. If the
  target is a terminal device, that process's output lands on your screen.
- **L4 decompose:** (1) `ls -l` the `fd` directory; (2) identify 0, 1, 2; (3) say which was
  predictable.
- **L5 near-miss:** If they ignore the extra high-numbered descriptor, that is fine — but if they
  ask, it is bash holding the script file open.
- **Never say:** "stdin, stdout, stderr" before they have tried to name them.

### Exercise 14
- **L1 question:** What is left in `/proc` for a process that no longer exists?
- **L2 locate:** Notes, gotchas — process directories vanish.
- **L3 concept:** These directories are not records. Nothing is archived; the entry exists only while
  the object it describes exists.
- **L4 decompose:** (1) kill it; (2) re-run exercise 9; (3) quote the error verbatim.
- **L5 near-miss:** If they paraphrase the error, ask for the exact wording — it is the deliverable.
- **Never say:** the error text.

### Exercise 15
- **L1 question:** Which of those two files describes software that was *installed*, and which
  describes software that is *running*?
- **L2 locate:** Notes, "The station is not the machine".
- **L3 concept:** `/etc` is files on disk placed there by a package. `/proc` is the kernel answering
  about itself.
- **L4 decompose:** (1) read both; (2) write both down; (3) do not explain yet — that is exercise 16.
- **L5 near-miss:** If they conclude one of the files is lying, hold that thought for 16.
- **Never say:** the explanation.

### Exercise 16
- **L1 question:** How many kernels are running on this hardware right now?
- **L2 locate:** Notes, "The station is not the machine".
- **L3 concept:** A container is a set of restrictions applied to ordinary processes. Restricted
  processes still execute on the one kernel that is booted. Compare: two users on one machine each
  see their own home directory, but there is only one clock.
- **L4 decompose:** (1) say where `/etc/os-release` came from; (2) say who answers a read of
  `/proc/version`; (3) look for a second `/proc` file describing hardware or boot rather than
  userland.
- **L5 near-miss:** If they are hunting for the second piece of evidence, ask what a *kernel* is told
  at boot that a container could never have supplied.
- **Never say:** `/proc/cmdline`, `/proc/meminfo`, or "it shares the host kernel".

### Exercise 17
- **L1 question:** What question is `ls -l` actually asking, and does it ever open the file?
- **L2 locate:** Notes, "the size-zero surprise".
- **L3 concept:** For an ordinary file the size is a fact recorded in advance, because the bytes are
  already sitting on a disk. Ask whether that is true of text that does not exist until someone
  reads it.
- **L4 decompose:** (1) run all five; (2) state what `ls` asks; (3) state what `cat` asks; (4) say
  which of the two the kernel could answer without generating the content.
- **L5 near-miss:** If they say "procfs is buggy" or "the file is empty", ask them to reconcile that
  with 672 lines of output.
- **Never say:** "the size field is not populated because the content is generated on read".

### Exercise 18
- **L1 question:** At the instant you run a command, how many processes are involved, and which one
  is doing the reading?
- **L2 locate:** Notes, `/proc/self`.
- **L3 concept:** `self` is resolved per-reader, not per-file. Two different readers following the
  same name get two different places — like two people each following a sign that says "your desk".
- **L4 decompose:** (1) run it twice; (2) note both PIDs; (3) say what was created and destroyed
  between them.
- **L5 near-miss:** If they expected the same number both times, ask whether the second `ls` is the
  same process as the first.
- **Never say:** "each command is a new process, so self resolves to a new PID".

### Exercise 19
- **L1 question:** You have to open each numbered directory and look. What are you looking *at* in
  each one?
- **L2 locate:** Exercises 9 and 11 — the same file, one process at a time.
- **L3 concept:** This is a linear scan by hand. The cost is not the reading, it is that you must do
  it once per candidate and cannot stop early with confidence.
- **L4 decompose:** (1) list `/proc`; (2) ignore the word-named entries; (3) read `cmdline` from each
  numbered one until you find your argument; (4) count how many you opened.
- **L5 near-miss:** If they reach for `ps` or `grep`, remind them the constraint is the exercise —
  and that noticing how badly they want `grep` is the point.
- **Never say:** anything that resembles `grep -r`.

### Exercise 20
- **L1 question:** What number would a size-based search compare against 100 KB for that file?
- **L2 locate:** Exercise 17's finding.
- **L3 concept:** A search tool asks the same question `ls` asks, for speed — it cannot afford to
  read every file's contents. It inherits whatever that answer is, including when the answer is
  misleading.
- **L4 decompose:** (1) state the recorded size; (2) state the actual byte count when read; (3) say
  which one a size filter sees.
- **L5 near-miss:** If they say "it is a bug in the search tool", ask what the tool would have to do
  instead, and how long that would take across a whole filesystem.
- **Never say:** "it will be skipped, and that is correct behaviour".

### Exercise 21
- **L1 question:** Which of the two is a list of *mounts*, and which is a report of *space*? What
  would make a mount uninteresting to a space report?
- **L2 locate:** 02/02's `df` work; `man 1 df`.
- **L3 concept:** `df` filters. Pseudo-filesystems have no meaningful capacity, so reporting them as
  "0 used of 0" is noise. Deduplication and bind mounts also collapse rows.
- **L4 decompose:** (1) count lines in each; (2) pick one mount present only in the long list; (3)
  say why a size report would omit it.
- **L5 near-miss:** If they claim the outputs conflict, ask whether "absent" and "contradicted" are
  the same thing.
- **Never say:** a specific filesystem to name.

### Exercise 22
- **L1 question:** The error names a property of a filesystem, not of a user. Which word in it is
  doing that?
- **L2 locate:** `/proc/mounts` — look at the line for the path you tried to write.
- **L3 concept:** Two different refusals exist and they read differently: one is about who you are,
  one is about how the storage was attached. The kernel tells you which.
- **L4 decompose:** (1) attempt the write; (2) quote the error; (3) find the matching mount line;
  (4) name the option that explains it.
- **L5 near-miss:** If they say "because I am not root", ask what error they would have got if that
  were the reason — and whether becoming root would help here.
- **Never say:** "`/proc/sys` is mounted `ro`".

### Exercise 23
- **L1 question:** Two numbers per limit. What is the difference between a limit you may raise and a
  limit you may not?
- **L2 locate:** `/proc/self/limits` column headers; then `help ulimit`.
- **L3 concept:** A soft limit is the one in force and you may lower it or raise it up to the hard
  ceiling. The hard one only ever goes down for an unprivileged process.
- **L4 decompose:** (1) read the limits file; (2) find the open-files row; (3) find the builtin;
  (4) find the flag that prints the hard value instead.
- **L5 near-miss:** If `man ulimit` gives them the wrong page or none, that is the hint — shell
  builtins are documented by the shell.
- **Never say:** `ulimit -n` / `ulimit -Hn`.

### Exercise 24
- **L1 question:** What is handed to the kernel at boot, before any filesystem is mounted?
- **L2 locate:** Notes, system-wide files table. `man 5 proc`, search for `cmdline` — note there are
  two entries with that name.
- **L3 concept:** The bootloader must tell the kernel where the root filesystem is, because the
  kernel cannot look it up before it has one. That string is preserved and readable afterwards.
- **L4 decompose:** (1) read it; (2) find a token naming a device or a UUID; (3) ask what an attacker
  with a shell in this container learns from it.
- **L5 near-miss:** If they name a token that is about the container, point out the container was
  not running when this string was written.
- **Never say:** "it leaks the host's disk UUIDs".
