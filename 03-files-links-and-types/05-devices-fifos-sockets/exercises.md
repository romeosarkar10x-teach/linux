# 03/05 — Exercises: Devices, FIFOs & Sockets

Work in `/labs/03-files-links-and-types/05-devices-fifos-sockets`.

```
cd /labs/03-files-links-and-types/05-devices-fifos-sockets
ls -F
```

Several exercises are supposed to hang. That is the subject matter, not a mistake. **Ctrl-C gets you
out of every one of them.** If you want a second terminal, open another `kestrel enter` in a new
window — some exercises need one.

If you mangle the lab: `kestrel reset 03/05` from the repo root.

---

**Ahead of the syllabus.** This lesson uses `head -c`, `wc -c`, `rm` (Chapter 4), `find -type`
(Chapter 6), `tr`, `sort`, `tee` (Chapter 7), `kill -l` (Chapter 9) before the chapters that teach
them. Use them exactly as written here; you are not expected to know them yet.

## Warmup

**1.** `ls -lF zoo`. Seven entries, seven types. Write down the seven type letters in the order they
appear, and next to each one the name of the type.

**2.** `ls -F` puts a suffix on some names: `/`, `@`, `|`, `=`. Which entry in `zoo` got which
suffix, and which entry got none?

**3.** For each entry in `zoo`, run `stat -c '%n %F' <name>`. Where does `stat`'s wording differ
from the word you wrote in exercise 1?

**4.** `ls -l zoo`. Two entries have something in the size column that is not a size. Which two, and
what is printed there?

---

## Core

**5.** Run `file zoo/*`. `file` normally reads a file's contents to identify it. For which entries in
`zoo` can it not possibly have read any contents, and how did it identify them anyway?

**6.** `stat -c '%F major=%t minor=%T' zoo/null-clone`. Compare the two numbers with what `ls -l`
prints for the same file. Now do the same for `zoo/dev-sensor`. Explain the disagreement in one
sentence.

**7.** `ls -l /dev/null` and `ls -l zoo/null-clone`. Different names, different directories,
different owners possibly — but the same two numbers. What does that mean?

**8.** Test the claim in exercise 7: `echo 'anything at all' > zoo/null-clone`, then
`cat zoo/null-clone`, then `stat -c %s zoo/null-clone`. Report all three results.

**9.** `find . -type p`, then `-type s`, then `-type c`, then `-type b`. List what each one found.
Which directories in the lab have a special file in them?

**10.** `find . -type f | wc -l` and `find . ! -type f ! -type d | wc -l`. What is the second number
counting?

**11.** How many bytes does `/dev/null` give you when you read it? Prove it with `wc -c`.

**12.** `head -c 8 /dev/zero | od -An -tx1`. What did you get? Why is `od` needed here and not for a
text file?

**13.** `echo hello > /dev/full`. Report the exact error and the exit status (`echo $?` immediately
after). Now `head -c 4 /dev/full | od -An -tx1` — does reading fail too?

**14.** In one sentence: what is `/dev/full` for? (It is not a mistake and it is not full of
anything.)

**15.** `head -c 16 /dev/urandom | od -An -tx1`, twice. Then `head -c 16 /dev/zero | od -An -tx1`,
twice. Which one changed between runs, and which two devices differ only in what the driver decides
to hand you?

**16.** `ls -l /dev/null /dev/zero /dev/full /dev/random /dev/urandom /dev/tty`. Which major number
do most of them share? Which one does not, and what does that tell you about which driver serves it?

**17.** `mkfifo pipe/panel07`. Then `ls -lF pipe/panel07`. Report the type letter, the suffix, the
size, and the permissions.

**18.** Open a second terminal (`kestrel enter` again) and `cd` to the lab in both. In terminal A run
`cat pipe/panel07`. Describe what terminal A does. Now, in terminal B, run
`echo 'panel 07 clear' > pipe/panel07`. Describe what happened in both terminals.

**19.** Same two terminals, opposite order: run the `echo` **first**, in B, before any reader exists.
What does B do? Now run the `cat` in A. Report both.

**20.** After all that traffic, `stat -c '%s %b' pipe/panel07` and `du -h pipe/panel07`. How many
bytes are stored in the FIFO? Why?

**21.** With no reader running, in one terminal: `cat pipe/panel07`, and while it waits, in the
other: `echo one > pipe/panel07`, then `echo two > pipe/panel07`. Which lines did the reader get?
What happened to the reader after the first `echo` finished, and why?

**22.** Read a FIFO twice: send one line through, read it, then run `cat pipe/panel07` again with
nobody writing. What do you get? Is the line still in there?

**23.** In terminal A: `timeout 3 cat pipe/panel07 > console/caught.txt`. In terminal B within those
three seconds: `echo relayed | tee pipe/panel07 > /dev/null`. Then `cat console/caught.txt`. What
does this prove about where a FIFO's bytes end up?

**24.** Start two readers in two terminals, both `cat pipe/panel07`. In a third — or by putting one
reader in the background with `&` — send `printf 'one\ntwo\n' > pipe/panel07`. Which reader got what?
Run it again. Same answer?

**25.** `rm pipe/panel07`. Did it need anything special? Now `ls pipe`. What does that tell you about
how a FIFO's *name* differs from a FIFO's *contents*?

**26.** `mkfifo -m 600 pipe/private` and `ls -l pipe/private`. Do the normal permission bits apply to
a FIFO? Which of read and write would each bit be controlling?

**27.** Try to make a device node: `mknod pipe/fakedev c 1 3`. Report the exact error. Then
`ls -l /dev/null` — who owns the real one?

**28.** Given exercise 27's error: why would a system that let any user run `mknod` have no
meaningful file permissions at all? Answer in two sentences, in terms of what a device node is.

**29.** `stat -c '%F' zoo/telemetry.sock`, then `cat zoo/telemetry.sock`. Report the error and the
exit status. Is the socket broken?

**30.** `ls -l zoo/dev-sensor` — you own it, and the mode is `rw` for you. Now
`head -c 4 zoo/dev-sensor`. Report the error. Reconcile it with the permission bits.

**31.** `{ echo to-stdout; echo to-tty > /dev/tty; } > console/cap.txt`. Which of the two lines
appeared on your screen, and which one is in the file? Explain the split.

**32.** `tty` on its own prints the path of your terminal. Run it. Then `ls -l` that path and
`ls -l /dev/tty`. Are they the same file? Are they the same *device*?

---

## Experiment

For each of these: **write your prediction down before you run it.** Then run it, and write down
which part of your prediction was wrong. The wrong part is the exercise.

**33.** Predict the size, in bytes, of `pipe/inbox` after you push a full megabyte through it:
`( head -c 1048576 /dev/zero > pipe/inbox & ) ; cat pipe/inbox | wc -c`, then
`stat -c %s pipe/inbox`. Predict both numbers first.

**34.** Predict what `timeout 1 cat < pipe/inbox` does on an idle FIFO. Then run it. Then predict
what `timeout 2 dd if=pipe/inbox iflag=nonblock` does, and run that. If your two predictions were the
same, the difference between them is the thing to explain — and the explanation is not about `cat`.

**35.** `cp -R zoo /tmp/zoocopy`. Predict, for each of the seven entries, whether it will be copied,
copied as a different type, or refused. Run it, then `ls -lF /tmp/zoocopy` and compare.

**36.** Predict what `cp zoo/relay /tmp/relaycopy` (no `-R`) does. Run it. Ctrl-C when you have seen
enough. Now explain it in terms of what `cp` opens.

**37.** Predict the output of `wc -c < /dev/null`, `wc -c zoo/relay`, and `wc -c zoo/null-clone`. One
of the three will hang; predict which one before you find out.

---

## Stretch

**38.** Build a two-stage relay: `mkfifo pipe/a pipe/b`, then a background job reading `pipe/a` and
writing what it reads, uppercased, into `pipe/b` (`tr a-z A-Z`), then read `pipe/b` in your terminal
while sending a line into `pipe/a`. Get one line all the way through.

**39.** Make a FIFO act as a logger: run `timeout 20 cat pipe/inbox >> console/relay.log &` and then
send it three separate lines with three separate `echo`s. Did all three arrive? Did the reader stay
alive between them? Explain why this differs from exercise 21.

**40.** `stat -c '%n %F %i' zoo/relay zoo/telemetry.sock zoo/null-clone` — special files have inode
numbers like anything else. Which of the three could you make a hard link to? Try `ln zoo/relay
pipe/relay-link` and check `stat -c %h` on both names. What does that say about where a FIFO's
identity lives?

**41.** Write a one-line command that lists every special file (not regular, not directory, not
symlink) under `/dev` with its type and its major/minor pair, sorted by major. `find`, `-printf` or
`stat`, `sort`.

**42.** `find /dev -maxdepth 1 -type c | wc -l` and `-type b | wc -l`. This container has no block
devices under `/dev` at all, but the disk that `/labs` lives on is obviously real. Where did the
block device go? (`findmnt /labs` or `cat /proc/mounts | grep labs` for evidence, then reason.)

**43.** `ls -lF /dev/stdin /dev/stdout /dev/stderr /dev/fd`. These are not devices. What are they,
and what do they point at? Follow one all the way down with `readlink -f`.

**44.** Redirect a command's stdout to a file **and** have it prompt you on the terminal anyway:
write a small script in `console/` that asks a question on `/dev/tty`, reads the answer from
`/dev/tty`, and prints the answer on stdout. Run it with `> console/answer.txt` and confirm the
prompt appeared on screen and only the answer landed in the file.

**45.** Two ways to lose a reader, and they do not feel the same to the writer.
(a) With nobody reading: `mkfifo pipe/oneshot`, then
`timeout 3 bash -c 'echo boom > pipe/oneshot'; echo $?`. Report the exit status and say which system
call the writer was stuck in — it never got as far as writing.
(b) With a reader that quits early, and a writer that has a lot left to say:
`( timeout 2 head -c 10 pipe/oneshot > /dev/null ) &` then
`head -c 5000000 /dev/zero > pipe/oneshot; echo $?`. Report the exit status, subtract 128, and look
that number up with `kill -l`. Which signal, and what was the kernel telling the writer?
Explain why (a) and (b) are different failures even though both end with "no reader".

**46.** Recreate `/dev/null` for yourself — or fail to, correctly. Attempt `mknod`, get refused, then
answer: without `CAP_MKNOD`, is there **any** file you can create in your own directory that discards
everything written to it and reads as empty? Argue for or against with evidence.

---

## Dig

**47.** `salvage/feed` was recovered from the maintenance deck. `ls -l salvage/feed` and describe
what you find, including the type of each entry. Do not draw a conclusion yet — describe.

**48.** The summariser that produced `salvage/feed/strain-summary` is documented as reading its input
from `salvage/feed/strain-input` and appending a line per day. Using only the types and timestamps in
that directory, state (a) what would happen to that summariser today if it ran, and (b) what you
cannot determine from this directory alone. Be strict about (b).

**49.** `cat salvage/feed/notes.txt`. The note says the log directory was checked and "everything is
there". In what sense is that statement true, and in what sense did checking that a name exists fail
to check anything at all?

**50.** `/dev/urandom` and `/dev/random` are different minor numbers on the same major. Find out what
the difference between them was historically, and what it is on current Linux
(`man 4 random` is in the image). Then answer: for filling a 100 MB file with unpredictable bytes,
does the choice matter today?

**51.** A device node is a `(type, major, minor)` triple in an inode. `mknod` can therefore create a
node for a driver that **does not exist**. Predict what `stat` says about such a node versus what
opening it says, then reason about why `ls` can describe a device that cannot possibly work.
(`zoo/dev-sensor` is major 7 — the loop driver — minor 200, with nothing attached.)

**52.** Seven types, and you have handled six of them directly. Write the seven-row table from
memory: type letter, `stat -c %F` string, one sentence on what the inode holds instead of data
(where applicable), and one command that creates it. For the one type you have not created, say why
you cannot.
