# 01/07 — Solutions

> **Student: do not read this file.** It contains this chapter's flag.
> **Agents:** steering only, and never reveal the flag. See `docs/AGENT_MODES.md`.

### FLAG
```
KESTREL{he_never_finished_typing}
```
sha256("kestrel-station-7" + flag) = `c8528f3e20fe09d851726c0f93e668deb83fefcc425373a62c50c7e50511e063`
Registered in `container/flags.tsv` as `01/07`. Verified: `kestrel flags submit` accepts it and
rejects a wrong value.

**How it is planted.** The token is not stored anywhere. `check-sample-integrity.sh` builds it at run
time from field 6 of the records in `strain-2187-05.dat` whose field 5 is `ok` — the words `he`,
`never`, `finished`, `typing`, joined with underscores. Consequences:

- `grep -r he_never_finished_typing /labs` finds **nothing**. Verified.
- `grep -r KESTREL /labs/01-shell-and-terminal` finds only the script's `KESTREL{${tok}}` template,
  which is not the flag.
- The script is deliberately readable. It reveals the *method* and not the answer, so a student who
  reads it has learned something and still has to know which file to run it against.
- The other two `.dat` files fail the record-count check and print no token at all. **There are no
  decoy flags**, per `_handoff/CHALLENGE_DESIGN.md` §2.

**Continuity.** `_handoff/SCENARIOS.md` §2, §7 (Ch 1). dorn's last session, 2187-05-24, ending
04:12. Trace 1 of 16. Nothing in any student-facing file may frame this as concealment — at Chapter
1 it reads as a tired person whose session ended. File mtimes are set to timeline dates; the
capstone sorts on them, so do not change them.

---

### 1 — count the commands
**11 commands**, 22 lines. The `#` lines are epoch timestamps, one before each command, written
because that session had `HISTTIMEFORMAT` set. Same format as 01/06's `maint-old-history`.

### 2 — the working directory
`~/samples`. Two `cd`s: `/var/log/station` first, then `~/samples`. State accumulates in order, so
the later one wins. Students who answer `/var/log/station` stopped reading after the first.

### 3 — the two non-leads
**(a) the `find`:**
```
find /var/log/station -type f -mtime +30 -name '*.log' -size +1M
```
Looking for log files over a month old and over a megabyte. Routine housekeeping — the thing anyone
does when a disk is filling. It looks significant because it is long and uses tools the student has
not met; that is precisely the trap. It leads nowhere and nothing later depends on it.

**(b) the typo pair:**
```
cat /var/log/statoin/structural.log
cat /var/log/station/structural.log
```
Thirty seconds apart. He mistyped `station`, and corrected it on the next line. Two lines, one
event, no significance.

**This exercise is the tell.** A student who did it before reconstructing almost certainly
investigated. One who did it afterwards probably brute-forced and wrote the narrative later.

### 4 — locate the cut
```
./check-sample-integrity.sh strain-2187-0
```
The cut falls inside the final argument, after the `0` of the month field. Everything present is
correct; the line does not contain wrong characters, it simply stops. That distinction is the whole
technique — it means the fragment is a reliable prefix, not a corrupted string.

### 5 — reconstruct
```bash
./check-sample-integrity.sh strain-2187-05.dat
```

The justification, which is what is actually graded:

1. `ls` shows three files matching the prefix: `strain-2187-03.dat`, `strain-2187-04.dat`,
   `strain-2187-05.dat`. The fragment ends at `strain-2187-0`, so all three remain possible.
2. Two earlier lines in the same session name one of them explicitly:
   ```
   head -3 strain-2187-05.dat
   wc -l strain-2187-05.dat
   ```
   He had been working with the May set for the previous twenty minutes. That is the evidence that
   breaks the tie.
3. The `.dat` suffix comes from the filenames present in the directory.

A student who says "I ran all three and one worked" has answered exercise 7, not exercise 5. Mark it
accordingly — the distinction between investigating and guessing is the point of the whole lesson,
and the flag cannot tell them apart.

### 6 — the flag
```
$ ./check-sample-integrity.sh strain-2187-05.dat
sample set:        strain-2187-05.dat
declared records:  8
records present:   8

INTEGRITY: PASS
verification token: KESTREL{he_never_finished_typing}
```

### 7 — the other sample sets
```
$ ./check-sample-integrity.sh strain-2187-04.dat
declared records:  8
records present:   4
INTEGRITY: FAIL -- declared and present disagree.
$ echo $?
1
```
`strain-2187-03.dat`: declared 6, present 3, same failure.

Neither prints a token. So exactly one reconstruction produces an answer, which makes the
reconstruction *verifiable* rather than merely plausible — and it means a student who guessed still
ends up with the right token, which is why exercise 5 is graded on reasoning.

### 8 — the `history -c` (Experiment)
Two commands appear after it. That is not evidence of tampering: the clear emptied the in-memory
list, the two commands typed afterwards entered the now-empty list, and the shell wrote that list
out as the session ended. Exactly the mechanism from 01/06 exercise 10.

The lines *before* the clear are in the file because they had already been written by an earlier
session — the clear never touched the disk.

**The correct answer to "does this tell you anything about intent" is no.** People clear their
history routinely, for reasons as dull as having pasted a token. A student who says so is reasoning
well and should be told so. Do not lead them anywhere else.

### 9 — load it into a shell (Experiment)
```bash
$ bash
$ history -r dorn-bash-history
$ history 11
   ...  2187-05-24 02:40:00 cd /var/log/station
   ...
   ...  2187-05-24 04:12:00 ./check-sample-integrity.sh strain-2187-0
```
Timestamps display, because the student's own shell has `HISTTIMEFORMAT` set — the file carries
epochs and the display setting is theirs. The truncated line loads as an ordinary entry and can be
recalled and edited like any other, which is a legitimate way to complete it.

Not in the main shell: those lines would be written into the student's own `~/.bash_history` on
exit, permanently and indistinguishably.

### 10 — the timestamp (Stretch)
```
$ date -d @6860261520 '+%F %T'
2187-05-24 04:12:00
```
Previous command `6860261100` → `2187-05-24 04:05:00`. **Seven minutes** earlier, and it was the
`history -c`.

### 11 — why `./` (Stretch)
The current directory is not on `PATH`, so a bare `check-sample-integrity.sh` produces
`command not found`. `./` makes it a path, and anything containing a `/` is used directly with no
search. 01/03 exercise 9, recalled.

It is left off `PATH` deliberately: otherwise dropping a file named `ls` into a shared directory
would run your code as whoever next typed `ls` there.

### 12 — the mechanism (Stretch)
The session's commands were in the shell's memory. On exit, bash writes that list to the history
file, entry by entry. The process ended partway through the write: what had reached the disk stayed,
the rest never arrived, and the file ends mid-word.

**The best answer notes that the evidence does not distinguish this from a deliberate truncation,
and declines to choose.** That is stronger reasoning than picking one, and it is the correct
posture for the whole course. Reward it.

### 13 — strip the timestamps (Dig)
Any method is acceptable — retyping into a new file, an editor, or:
```bash
grep -v '^#' dorn-bash-history > ~/dorn-commands.txt     # Chapter 6
```
Eleven lines out.

The wish-list answer is the point: they wanted "show me the lines that do not start with `#`". That
is `grep -v`, and it is Chapter 6. Making the absence *felt* is why this exercise exists — a student
who has hand-copied eleven lines will remember `grep` when it arrives.

### 14 — read-only (Dig)
```
$ echo x >> dorn-bash-history
bash: dorn-bash-history: Permission denied
```
`cadet` owns the file. An owner can always change a file's mode, and having changed it can write —
so mode `444` stops an accident, not a decision. Root can write regardless.

The contrast worth drawing: `/course` is read-only at the **mount**, which no permission change can
undo from inside the container. That is a genuinely different kind of guarantee, and it is why the
course tree is protected that way and this file is not.

### The debrief
1. It was verifying a sample set — comparing the record count the file declares against the records
   actually in it.
2. The line stopped mid-filename; the directory held three files matching that prefix; two earlier
   lines in the same session named the May set specifically.
3. Because the history file is written when the shell exits, so a session that ends partway through
   that write leaves its last line unfinished.

Ask them to give (3) without the word "history". If they can, they have the model rather than the
sentence.
