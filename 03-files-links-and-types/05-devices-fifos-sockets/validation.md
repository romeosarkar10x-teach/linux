# 03/05 — Validation: Devices, FIFOs & Sockets

For the validating agent. The student never sees this file. Judge the *reasoning*, not the command
spelling. Where an exercise asks for a written answer, the words are the deliverable and a correct
command with no explanation is not a pass.

Two things run through the whole lesson and are worth holding onto while marking:

- **A special file's inode holds no data.** For a device it holds a `(type, major, minor)` triple;
  for a FIFO and a socket it holds nothing but a rendezvous point. Any answer that treats a FIFO as
  a place bytes are stored is wrong even when the observed numbers are right.
- **There are two gates in this container**: the filesystem's mode bits, and the container's device
  policy. Exercise 30 is only passed by a student who separates them.

Several exercises block on purpose. A student who reports "it hung" *and says which system call was
waiting and for whom* has passed; "it hung" alone has not.

---

## Warmup

**1. Seven type letters from `ls -lF zoo`**
- Goal: the student reads type off column one, not off the name.
- Expected end state: seven pairs, in listing order: `alias` `l` symlink; `bay` `d` directory;
  `dev-sensor` `b` block device; `manifest.txt` `-` regular file; `null-clone` `c` character device;
  `relay` `p` FIFO; `telemetry.sock` `s` socket.
- Evidence: the written list.
- Accept: "named pipe" for FIFO, "unix socket" for socket, "special file" qualifiers.
- Reject: any assignment derived from the filename — `dev-sensor` is deliberately named to invite
  the wrong guess about which of `b`/`c` it is, and `null-clone` to invite the other.
- Red flags: exactly six letters — they merged `b` and `c`.
- Probe: "Which two did you have to look at twice, and why?"

**2. `ls -F` suffixes**
- Expected: `bay/`, `alias@`, `relay|`, `telemetry.sock=`; `manifest.txt`, `null-clone` and
  `dev-sensor` get none.
- Accept: noting that `-F` has no suffix for *either* device type, so `-F` alone cannot distinguish
  a device node from a regular file.
- Reject: inventing a suffix for the device nodes.

**3. `stat -c '%n %F'` wording**
- Expected strings, exactly: `symbolic link`, `directory`, `block special file`, `regular file`,
  `character special file`, `fifo`, `socket`.
- Accept: notes that `stat` says "special file" where `ls` gives a single letter, and that `stat`
  says `fifo` where most documentation says "named pipe".
- Reject: paraphrases presented as `stat` output. The point is that these are fixed strings a script
  could match on.

**4. Size column that is not a size**
- Expected: `null-clone` shows `1,   3` and `dev-sensor` shows `7, 200`.
- Accept: "major, minor" named, with the observation that a device node has no size to print because
  there are no data blocks.
- Reject: reading the pair as a single number, or as a byte count.

---

## Core

**5. `file zoo/*` on things with no contents**
- Goal: identification from metadata, not from bytes.
- Expected output shapes: `block special (7/200)`, `character special (1/3)`, `fifo (named pipe)`,
  `socket`, `symbolic link to manifest.txt`, `ASCII text`, `directory`.
- Accept: names the four it could not have read (both devices, the FIFO, the socket — the directory
  is a fair fifth answer) and says `file` called `stat` and reported the type and the device numbers
  straight out of the inode.
- Reject: "it read the file" for any special entry. Opening the FIFO to read it would have blocked,
  and `file` did not block — that is available evidence, credit it.
- Probe: "If `file` had opened the FIFO, what would have happened to your prompt?"

**6. `%t`/`%T` versus `ls -l`**
- Expected: `null-clone` — `stat` `1`/`3`, `ls` `1,   3`, agreeing by coincidence. `dev-sensor` —
  `stat` `7`/`c8`, `ls` `7, 200`.
- Accept: one sentence saying `stat`'s `%t`/`%T` print hex and `ls` prints decimal; `0xc8 = 200`;
  the device did not change between the two commands.
- Reject: "stat is wrong"; "there are two different minor numbers"; any answer that does not
  actually convert. Ask for `printf '%d\n' 0xc8` if they assert without arithmetic.
- Red flags: student only checked `null-clone`, where 1 and 3 look the same in both bases, and
  concluded the two commands agree. That is the trap; send them to `dev-sensor`.

**7. `zoo/null-clone` versus `/dev/null`**
- Expected: both are character devices, major 1, minor 3.
- Accept: "it is not a copy of `/dev/null`, it *is* `/dev/null` — the same driver entry point under
  a second name"; the analogy to two doors into one room is fine.
- Reject: "similar to"; "a link to `/dev/null`" (there is no link here — check they do not say
  symlink or hard link; the inodes are different and `ls -l` shows no arrow).
- Probe: "If you deleted `/dev/null`, would this one stop working?" (No.)

**8. Testing the claim**
- Expected: `echo` succeeds silently, exit 0; `cat` prints nothing; `stat -c %s` prints `0`.
- Accept: all three reported.
- Reject: concluding from this alone that it *is* `/dev/null`. It is consistent with the claim and
  does not establish it — see `help.md` L5. A student who says so unprompted is doing well; one who
  overclaims should be asked what else would behave identically.

**9. `find -type p/s/c/b`**
- Expected: `p` → `zoo/relay`, `pipe/inbox`, `salvage/feed/strain-input` (plus anything they made);
  `s` → `zoo/telemetry.sock`; `c` → `zoo/null-clone`; `b` → `zoo/dev-sensor`.
- Accept: naming `zoo`, `pipe` and `salvage/feed` as the directories holding special files.
- Reject: missing `salvage/feed/strain-input` — it is the one that matters for exercises 47–49 and
  finding it here is the point of running `find` over the whole lab rather than over `zoo`.

**10. Counting non-regular, non-directory**
- Accept: the second number counts every special file — symlinks included, since `! -type f` does
  not exclude `l`.
- Reject: "it counts devices". Check whether they noticed `zoo/alias` falls in this set.

**11. Bytes from `/dev/null`**
- Expected: `wc -c < /dev/null` → `0`.
- Accept: says the read returns EOF immediately rather than "the file is empty" — there is no file
  content to be empty.
- Reject: "it is a zero-byte file".

**12. `head -c 8 /dev/zero | od`**
- Expected: `00 00 00 00 00 00 00 00`.
- Accept: `od` is needed because the bytes are NUL, which a terminal does not display; without it
  the output looks like nothing at all and is indistinguishable from `/dev/null`.
- Reject: "od formats it nicer".

**13. `/dev/full`**
- Expected: `bash: /dev/full: write error: No space left on device` (wording may vary by shell
  version), exit status **1**. Reading gives `00 00 00 00` — reads succeed and return NULs.
- Accept: the asymmetry stated: writes always fail with ENOSPC, reads behave like `/dev/zero`.
- Reject: "reading fails too" without having run it.

**14. What `/dev/full` is for**
- Accept: a reliable way to test that a program handles a full disk / a failing write, without
  filling a disk.
- Reject: "a device that is full"; "a bug".

**15. urandom versus zero, twice each**
- Expected: `/dev/urandom` differs between runs; `/dev/zero` is identical.
- Accept: names `/dev/zero`, `/dev/null` and `/dev/full` (or `random`/`urandom`) as devices sharing a
  major and differing only in what the driver returns — same driver, different minor.
- Reject: an answer that says the difference is in the file, not the driver.

**16. Major numbers across `/dev`**
- Expected: `null` 1,3; `zero` 1,5; `full` 1,7; `random` 1,8; `urandom` 1,9; **`tty` is 5,0**.
- Accept: five share major 1 (the "mem" driver); `/dev/tty` is major 5 and therefore served by a
  different driver — consistent with it doing something categorically different (per-process
  controlling terminal, not a byte source).
- Reject: a list with no inference drawn.

**17. `mkfifo pipe/panel07`**
- Expected: `prw-r--r--`, suffix `|`, size `0`, mode 644 masked by umask.
- Accept: notes the size is 0 at creation and predicts it will stay 0.

**18–19. Rendezvous, both orders**
- Goal: the single most important observation in the lesson.
- Expected 18: `cat` blocks with no output; the moment the `echo` runs, `cat` prints `panel 07 clear`
  and exits, and the `echo` returns at the same instant.
- Expected 19: the `echo` is the one that blocks; `cat` releases it.
- Accept: "whichever end opens first waits for the other" — symmetric, and the wait is in `open()`,
  before any byte moves.
- Reject: "the writer stores the line and the reader picks it up later". Reject any answer from only
  one of the two orders — 19 exists because students assume the writer never blocks.
- Probe: "Which process was waiting in 19, and what was it waiting for?"

**20. Size after traffic**
- Expected: `stat -c '%s %b'` → `0 0`; `du -h` → `0`.
- Accept: nothing is stored; the bytes live in a kernel buffer attached to the open FIFO, not in the
  filesystem; the inode has no data blocks (`%b` = 0 says so).
- Reject: "it was emptied when it was read".

**21. Two `echo`s, one `cat`**
- Expected: the reader gets `one` and exits; `two` then blocks (or, if they run it fast enough, has
  nobody to talk to). The reader exited because the last writer closed the FIFO, which the reader
  sees as EOF.
- Accept: EOF is "no writers currently have it open", not "no more data".
- Reject: "cat only reads one line".

**22. Reading twice**
- Expected: the second `cat` blocks; the line is gone.
- Accept: a FIFO read consumes; there is no second copy anywhere.

**23. `tee` into the FIFO, `cat` into a file**
- Expected: `console/caught.txt` contains `relayed`.
- Accept: the bytes ended up in the regular file the reader was redirected to — the FIFO carried
  them and kept none.

**24. Two readers, one writer**
- Expected: **nondeterministic**. One reader typically gets both lines; occasionally they split.
- Accept: reporting what happened *and* that a second run may differ, with the reason: both readers
  are blocked on the same buffer and the kernel does not divide a write between them by any rule the
  writer controls.
- Reject: "each reader gets one line" stated as a rule. That is the wrong lesson; if they saw it,
  ask them to run it five more times.
- Red flags: a student who got a consistent result and declares a rule. Correct answer is "I could
  not predict which."

**25. `rm pipe/panel07`**
- Accept: an ordinary `rm`; the name went, and there were never any contents to remove. Removing the
  name does not disturb a process that already has it open.
- Reject: any claim that special permissions were needed.

**26. `mkfifo -m 600`**
- Expected: `prw-------`.
- Accept: read bit governs opening for reading, write bit opening for writing; execute is
  meaningless on a FIFO.
- Reject: "permissions do not apply to special files".

**27. `mknod` refused**
- Expected: `mknod: pipe/fakedev: Operation not permitted` (EPERM). `/dev/null` is owned by root.
- Accept: quoting the error exactly.

**28. Why unrestricted `mknod` breaks everything**
- Goal: the security reasoning, in the student's own words.
- Accept: a device node is only a `(type, major, minor)` triple, so anyone who could create one could
  create a node for the raw disk in a directory they own, give it any mode they liked, and read every
  file on the system past all file permissions — which are enforced by the filesystem the raw device
  sits underneath.
- Reject: "because root owns `/dev`" (that is the symptom, not the reason); vague "for security".
- Probe: "Whose permissions would you be bypassing, and how?"

**29. `cat` a socket**
- Expected: `cat: zoo/telemetry.sock: No such device or address` (ENXIO), exit **1**.
- Accept: the socket is fine; it is not openable with `open(2)` at all. A socket is reached by
  `connect(2)` from a program that speaks its protocol, and `cat` does not.
- Reject: "the socket is broken"; "there is no server" as the *whole* answer — even with a listener,
  `cat` would fail the same way.

**30. Owned, `rw`, still refused — the two gates**
- Goal: the load-bearing exercise of the device half of the lesson.
- Expected: `head -c 4 zoo/dev-sensor` → `Operation not permitted`, despite `brw-rw---- cadet crew`.
- Accept: an answer that separates the gates: the mode bits are the filesystem's check and were
  passed; a second check — the container's device policy, a rule about which `(type, major, minor)`
  a process in this container may open at all — refused independently. `chmod`/`chown` cannot address
  it.
- Reject: "I need to be root" (root inside this container is refused too); "the permissions are
  wrong" (they are not); "the device does not exist" (that is exercise 51's failure mode and gives a
  different error).
- Red flags: student tries `chmod 777` and reports that it did not help without drawing the
  conclusion. Ask what that experiment ruled out.

**31. `/dev/tty` versus redirected stdout**
- Expected: `to-tty` appears on screen; `console/cap.txt` contains `to-stdout`.
- Accept: the redirect applied to file descriptor 1 only; `/dev/tty` is a separate path that resolves
  to the process's controlling terminal regardless of what fd 1 points at.
- Reject: "`/dev/tty` is stderr". It is not; check they did not confuse this with `2>`.

**32. `tty` versus `/dev/tty`**
- Expected: `tty` prints something like `/dev/pts/0`; `ls -l` on it shows a character device with a
  major of 136 (pts) while `/dev/tty` is 5,0.
- Accept: different files, different device numbers, but opening `/dev/tty` gets you to the same
  terminal — `/dev/tty` is an indirection resolved per process, `/dev/pts/N` names one specific
  terminal.
- Reject: "they are the same file".

---

## Experiment

Throughout this tier: **a prediction must have been written before the run.** No written prediction
is an automatic fail regardless of how right the final answer is, and the validating agent must not
have confirmed or denied any prediction beforehand.

**33. A megabyte through a FIFO**
- Expected: `wc -c` → `1048576`; `stat -c %s` → `0`.
- Accept: the common wrong prediction is that the size becomes 1048576, or some buffer size like
  65536. Any of those, written down and then corrected, is a pass.
- Reject: a prediction of `0` with no reasoning, offered after the fact.
- Probe: "Where were the bytes while the reader had not read them yet?" (Kernel buffer; the writer
  blocks when it fills.)

**34. `timeout 1 cat < pipe/inbox` versus `dd iflag=nonblock`**
- Goal: the subtle one. Expected: **the `timeout` version hangs anyway** and needs Ctrl-C; the `dd`
  version returns at once with `0+0 records in / 0+0 records out`.
- Accept: the explanation, which is not about `cat`: the **shell** performs the `<` redirect before
  it ever executes `timeout`, so the process that blocks in `open()` is the shell, and `timeout` has
  not started and cannot kill anything. `dd` does its own open, with `O_NONBLOCK`, inside the timed
  process.
- Reject: "cat ignores timeout"; "timeout is broken"; any explanation that puts the blame on `cat`.
- Red flags: student predicted both would return and does not investigate the difference. That is the
  exercise; send them back.

**35. `cp -R zoo /tmp/zoocopy`**
- Expected: symlink, directory, regular file recreated; FIFO and socket recreated as new empty
  FIFO/socket-shaped entries (`cp -R` makes a fresh FIFO; the socket may be recreated or skipped
  with a warning depending on version — accept either, provided it is reported accurately); **both
  device nodes refused** with `cp: cannot create special file '/tmp/zoocopy/null-clone': Operation
  not permitted`.
- Accept: the reason the devices failed is exercise 27's reason — copying a device node means
  `mknod`, and cadet lacks the capability. Contents were never the issue.
- Reject: "cp cannot copy devices" as a property of `cp`. Root could.

**36. `cp zoo/relay /tmp/relaycopy` with no `-R`**
- Expected: hangs. `cp` opened the FIFO to read it and is blocked in `open()` waiting for a writer.
- Accept: says that without `-R`, `cp` treats the FIFO as a source of *bytes* rather than as a thing
  to recreate, and there is no writer.
- Reject: "cp crashed".

**37. Three `wc -c`s**
- Expected: `/dev/null` → `0`; `zoo/null-clone` → `0`; **`zoo/relay` hangs** (it is the FIFO).
- Accept: the prediction of which one hangs, written first.
- Reject: predicting the device would hang.

---

## Stretch

**38. Two-stage relay**
- Goal: composition — a FIFO is just a file descriptor source, so ordinary tools chain through it.
- Expected end state: one line entered at `pipe/a` emerges uppercased from `pipe/b`.
- Accept: any working arrangement; the usual shape is `tr a-z A-Z < pipe/a > pipe/b &` then
  `cat pipe/b &` (or in a second terminal) and `echo hello > pipe/a`. Order of startup will matter
  and struggling with that *is* the exercise.
- Reject: a solution that abandons the FIFOs for a shell `|`. The pipeline works, but it does not
  demonstrate anything about named pipes; ask them what is different about the two.
- Probe: "Which of your three processes blocked first, and on what?"

**39. FIFO as a logger**
- Expected: all three lines arrive in `console/relay.log`; the reader stays alive across all three.
- Accept: the difference from exercise 21 identified precisely — here one long-lived reader holds the
  FIFO open across several short writers, so each writer's close is not the reader's EOF... **check
  this against what they actually observed.** With `cat` reading and each `echo` being the only
  writer, the reader may well see EOF after the first line and exit. Both outcomes appear in
  practice depending on timing and on whether a writer is still open.
- Accept either observed outcome, provided the student reports what happened accurately and explains
  it in terms of "EOF means no writer currently has it open". A confident claim that contradicts
  their own transcript is the fail.
- Reject: reporting three lines without checking the file.

**40. Hard link to a FIFO**
- Expected: `ln zoo/relay pipe/relay-link` succeeds; both names report the same inode (44890 in the
  reference seed — the number will differ per build, sameness is what matters) and `%h` = 2.
- Accept: of the three, the FIFO and the device node and the socket can all be hard-linked — they are
  ordinary directory entries pointing at ordinary inodes. The identity of a FIFO lives in the inode,
  not in the name, so two names are two doors onto one rendezvous point.
- Reject: "you cannot hard link special files".
- Probe: "If you write into one name and read from the other, does it work?" (Yes.)

**41. One-liner listing `/dev` special files by major**
- Accept: any working construction. A canonical one:
  `find /dev -maxdepth 1 \( -type c -o -type b \) -printf '%y %p\n' | while read t p; do stat -c "$t %n %t %T" "$p"; done | sort -k3`
  — or a single `find ... -exec stat -c '%F %n %t %T' {} +` piped to `sort`.
- Accept sorting on the hex string as long as the student notices it is hex and says the sort is
  lexicographic, not numeric, unless converted.
- Reject: output that omits the type, or that includes symlinks like `/dev/stdin`.

**42. No block devices under `/dev`**
- Expected: `-type c` finds a couple of dozen; `-type b` finds **0**. `/proc/mounts` shows
  `/dev/nvme2n1p2 /labs ext4 rw,relatime 0 0` — a path under `/dev` that does not exist here.
- Accept: the container was given a minimal `/dev` with only the character devices it needs; the
  mount was performed by the host kernel, which resolved that node in the host's `/dev`. A mount does
  not require the node to remain visible inside the mounted namespace — the kernel holds the device
  by its numbers, not by a path.
- Reject: "the disk is not real"; "the mount is fake"; "the node was deleted after mounting" stated
  as fact (plausible mechanism, but nothing here evidences it — accept it only as a hypothesis
  labelled as one).

**43. `/dev/stdin` and friends**
- Expected: all symlinks. `/dev/fd -> /proc/self/fd`, `/dev/stdin -> /proc/self/fd/0` (and 1, 2).
- Accept: `readlink -f /dev/fd` resolves to `/proc/<pid>/fd` for the process that ran it — a
  different answer per process, which is the whole point. These are a view of the calling process's
  open file table, not devices.
- Reject: "character devices"; failing to run `readlink -f`.

**44. Prompt on `/dev/tty` while stdout is redirected**
- Expected end state: a script in `console/`, run as `bash console/ask.sh > console/answer.txt`, that
  shows its prompt on screen and writes only the answer to the file.
- Accept: any script whose prompt goes to `/dev/tty` and whose `read` takes input from `/dev/tty`.
  The `read` half is the part students miss — check they redirected it, or used `read -p` writing to
  the terminal, and can say why stdin was not the problem here but would be under `< file`.
- Reject: a script using `>&2`. It appears to work — stderr is still the terminal — but breaks the
  moment stderr is redirected too, and it does not demonstrate `/dev/tty`. Ask them to run it with
  `2> /dev/null` and watch the prompt vanish.
- Probe: "Run it again with both `>` and `2>` redirected. Does your prompt survive?"

**45. Two ways to lose a reader**
- Goal: the distinction that most descriptions of FIFOs blur.
- Expected (a): exit status **124** — `timeout`'s own status for "I killed it". The writer was stuck
  in `open(2)`; it never wrote a byte, so no write error was possible.
- Expected (b): exit status **141**. 141 − 128 = 13; `kill -l 13` → `PIPE`. The writer was killed by
  `SIGPIPE` on a `write(2)` to a FIFO whose last reader had closed.
- Accept: the difference stated as a difference in *which system call*: (a) never got past `open`, so
  the failure is an indefinite wait, not an error; (b) was already streaming, and the kernel signals
  a writer whose reader has gone rather than letting it write into nothing. (A program that catches
  or ignores SIGPIPE sees `EPIPE` from `write` instead — mention it if the student raises it, do not
  require it.)
- Reject: "both give an error"; "the pipe is broken" for (a); any answer that quotes 141 without
  doing the subtraction and the `kill -l` lookup.
- Red flags: student reports 124 for (b) or 141 for (a) — they crossed the two runs. Ask them to
  re-run with `set -x`.

**46. Recreate `/dev/null` without `CAP_MKNOD`**
- Goal: argued reasoning under a constraint, with the honest answer being no.
- Expected: `mknod` refused as in exercise 27.
- Accept: **no** — no *file* can do it. A regular file keeps what is written; a FIFO discards only
  while nobody reads and otherwise blocks the writer; a symlink to `/dev/null` reaches the real
  device but is not a file of their own making that discards, and depends on `/dev/null` existing.
  A student who proposes the symlink and correctly labels it as reaching the existing device rather
  than creating a new one has answered well.
- Accept also: naming what would work outside the file model — a program (`> /dev/null` replaced by
  piping to `cat > /dev/null`, or `: > file` each time) — provided they mark it as not a file.
- Reject: "yes, a FIFO" with no test. Have them try it: the writer blocks.
- Reject: a `chmod 000` file — writes fail, they do not get discarded, and the owner can still write.

---

## Dig

**47. Describe `salvage/feed`**
- Goal: description before conclusion. This is the trace-planting exercise; discipline matters more
  than insight here.
- Expected: three entries — `strain-input` is a **FIFO** (`prw-`, size 0, mtime 2187-05-21 09:31);
  `strain-summary` is a regular file, one line, mtime 2187-05-21 09:30; `notes.txt` is a regular
  file, mtime 2187-05-23 16:02.
- Accept: type, size and time for each, with no conclusion attached.
- Reject: a description that has already jumped to "so the summariser is broken". Correct, possibly,
  and it is exercise 48's job.

**48. What would happen, and what cannot be determined**
- Expected (a): the summariser opens `strain-input` for reading and **blocks in `open()`** until some
  process opens it for writing. Nothing is ever produced; it does not error, it waits.
- Expected (b) — strictness is the grading criterion. From this directory alone the student cannot
  determine: who created the FIFO or when relative to the summariser's last run; whether the FIFO
  replaced a regular file or was always there; whether a writer once existed and stopped; whether the
  summariser is even still being run; whether the missing output is due to this at all.
- Accept: the `strain-summary` mtime being **one minute before** the FIFO's as a real observation,
  and the refusal to convert it into a story.
- Reject: "someone sabotaged it"; "dorn did this"; naming any person. Also reject a (b) that lists
  only one unknown — the exercise says be strict.
- Red flags: a confident narrative. Ask: "what would you have to look at to distinguish those?" The
  honest answer is "something outside this directory", and that is the right answer.

**49. "Everything is there"**
- Expected: true in the sense that every expected *name* exists in the directory; a listing by name,
  or a test like `[ -e strain-input ]`, passes.
- Accept: the general point — checking existence checks the directory entry and says nothing about
  type, and a name that resolves to the wrong type behaves nothing like the file that was expected.
  A one-line `ls -l` would have shown it; `ls` alone would not.
- Reject: an answer that only says "the note is wrong". It is not wrong; it is uninformative, and the
  difference is the lesson.

**50. `random` versus `urandom`**
- Expected: minor 8 and 9 on major 1.
- Accept: historically `/dev/random` blocked when its entropy estimate ran low while `/dev/urandom`
  never blocked; on current Linux (5.6+) `/dev/random` blocks only until the CSPRNG is initialised at
  boot and thereafter behaves like `/dev/urandom`, and both draw from the same pool. For a 100 MB
  file: **no, the choice does not matter today** on a running system — same bytes, same quality,
  neither will block after boot.
- Accept a student who hedges on very early boot or on unusual embedded platforms.
- Reject: "random is more secure than urandom" stated flatly — that is the myth `man 4 random`
  exists to kill. Reject any answer that did not consult the man page.

**51. A node for a driver that is not there**
- Expected: `stat` describes `zoo/dev-sensor` perfectly — block special, 7/200, owner, mode, times —
  because everything it prints is in the inode. Opening it fails.
- Note for the marker: in *this* container the open is refused by the device policy
  (`Operation not permitted`), not by the absent driver, so the student cannot distinguish the two
  causes from inside. A student who says "I got EPERM, which is the container's policy, so I have
  not actually observed the no-driver failure" has understood more than one who blithely reports
  `ENXIO`. Accept the reasoning about what *would* happen (ENXIO / `No such device`) as long as it is
  labelled as reasoning.
- Accept: `ls` can describe an unusable device because a device node is a name for a driver, not a
  connection to one; nothing checks that the driver exists until `open`.
- Reject: "the file is corrupt"; conflating this with the dangling-symlink case without noting the
  difference (a dangling symlink names a *path*; this names a *number pair*).

**52. The seven-row table, from memory**
- Goal: the consolidation. Expect it written without looking.
- Expected rows:
  | letter | `%F` | inode holds | create with |
  |---|---|---|---|
  | `-` | `regular file` | data blocks | `touch`, any redirect |
  | `d` | `directory` | name→inode entries | `mkdir` |
  | `l` | `symbolic link` | a path string | `ln -s` |
  | `c` | `character special file` | major/minor | `mknod NAME c MAJ MIN` |
  | `b` | `block special file` | major/minor | `mknod NAME b MAJ MIN` |
  | `p` | `fifo` | nothing; a rendezvous | `mkfifo` |
  | `s` | `socket` | nothing; a rendezvous | `bind(2)` from a program |
- Accept: the socket as "the one I could not create" — there is no standard command-line tool in this
  image that binds a Unix socket (`socat` and `nc` are absent), so it must be created by a program
  that calls `bind(2)`; the one in `zoo` was made by the setup script.
- Accept device nodes as a second correct answer to "could not create", since `mknod` is refused —
  that is a different reason (a missing capability, not a missing tool) and a student who names both
  reasons separately has the best answer available.
- Reject: a table with fewer than seven rows; "FIFOs store the data until it is read".

---

## Roll-up

The student has finished this lesson when they can, unprompted:

1. Identify any of the seven types from `ls -l`, `stat -c %F` and `file`, and say which of the three
   they would trust if they disagreed.
2. Read a device node as a `(type, major, minor)` triple that names a driver, and explain that two
   names with the same triple are the same device — not copies.
3. State the FIFO rendezvous rule symmetrically: whichever end opens first blocks in `open()`, and
   nothing is ever stored in the filesystem.
4. Distinguish the two ways a FIFO write fails — blocked forever in `open` with no reader, versus
   `SIGPIPE` when a reader leaves mid-stream — and say which system call each belongs to.
5. Separate the filesystem's permission check from the container's device policy when a read they
   are entitled to make is refused anyway.
6. Say why `cat` cannot read a socket, without calling the socket broken.
7. Explain why a `cp` of a tree can silently produce something that is not that tree.

Fail the lesson — do not wave it through — if the student finishes still believing any of:

- a FIFO stores what is written to it until someone reads it;
- a device node contains, or connects to, data;
- `zoo/null-clone` is a copy of or a link to `/dev/null`;
- permission bits are the only thing that can refuse an open;
- `/dev/urandom` is the inferior of `/dev/random`;
- a hanging command is a broken command;
- the existence of a name is evidence about what the name refers to.

The last one carries directly into `06-incident-03` and, eventually, into the sabotage arc. Exercise
49 is where it is taught and exercise 48 is where the discipline of *not* completing the story is
tested. A student who wrote a confident account of what happened in `salvage/feed` has learned the
opposite of the intended lesson and should be sent back to 47 to describe before concluding.
