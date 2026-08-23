# 03/04 — Help: Timestamps

Five rungs. Climb one at a time. Rung 5 is a near-miss on purpose — it will not run as written.

---

## Level 1 — Questions to ask yourself

- Which of the three times does the command you just ran actually touch? Contents? Metadata? Neither?
- `ls -l` shows exactly one time. Do you know which one, or are you assuming?
- When you sorted with `-t`, which time was being displayed at that moment?
- If a time changed and the contents did not, what part of the file *did* change?
- If a time did **not** change and you expected it to, is the kernel refusing to write it — and why
  would a kernel refuse to write a timestamp?
- A timestamp is a number in a fixed-width field, not a string. What does that limit?
- You keep resetting the lab. Are you sure the state you are reading is the seeded state?

## Level 2 — Where to look

- `stat FILE` — all four times at full precision. `man stat` lists the `%` format codes; the ones
  for times are near the top of the list.
- `man 1 touch` — read the `-a`, `-m`, `-c`, `-r`, `-h`, `-d` and `-t` entries. Note carefully which
  time each one is *incapable* of setting.
- `man 1 ls` — search for `--time` and for `-u` and `-c`. Read what each says about sorting, not
  just about display.
- `man 1 find` — `-newer`, `-newermt`, and the `-newerXY` family.
- `/proc/mounts` — the options the lab volume is mounted with.
- `man 8 mount` — search for `relatime`. The paragraph is four lines and answers exercises 15–19.
- `man 1 cp` — `-p` and `--preserve`, and what `-a` adds.
- `/course/03-files-links-and-types/04-timestamps/setup.sh` — the header comment explains the shape
  of the lab. Reading it is allowed; it is not the answer key.

## Level 3 — The concept, on different data

Take a file you own somewhere outside the lab, `/tmp/demo.txt`:

```
$ printf 'hello\n' > /tmp/demo.txt
$ stat -c 'a=%x m=%y c=%z' /tmp/demo.txt
a=... 10:00:01  m=... 10:00:01  c=... 10:00:01
$ chmod 600 /tmp/demo.txt
$ stat -c 'a=%x m=%y c=%z' /tmp/demo.txt
a=... 10:00:01  m=... 10:00:01  c=... 10:00:47      <-- only c moved
$ printf 'more\n' >> /tmp/demo.txt
$ stat -c 'a=%x m=%y c=%z' /tmp/demo.txt
a=... 10:00:01  m=... 10:01:12  c=... 10:01:12      <-- m moved, and c came with it
```

That is the whole model. Changing contents changes the inode too, so mtime never moves alone.
Changing the inode without touching contents moves ctime alone. Nothing moves ctime backwards.

Same idea for the copy question, on a different file:

```
$ touch -d '2000-01-01' /tmp/old.txt
$ cp /tmp/old.txt /tmp/a.txt ; cp -p /tmp/old.txt /tmp/b.txt
$ stat -c '%n %y' /tmp/old.txt /tmp/a.txt /tmp/b.txt
```

Run that and the answer to exercises 26–30 is in front of you, in a directory you cannot break.

## Level 4 — Break it down

**"Which time does this command move?"** Do not reason about it. Measure it:

1. `stat -c 'a=%x m=%y c=%z' FILE` — write the three values down.
2. Run the one command you are asking about. One command, not three.
3. `stat -c 'a=%x m=%y c=%z' FILE` again.
4. Diff the two by eye. Exactly the ones that changed, changed.

**"My atime will not move."** Compare atime with mtime *first*. The relatime rule only permits an
update when the stored atime is already older than mtime or ctime, or is over a day old. If atime is
newer than mtime, a read writes nothing. That is not a broken lab, it is the mount option.

**"Sorting gives me the wrong order."** `-t` sorts by whatever time `ls` is currently showing. If
you asked for atime with `-u`, `-t` sorted atimes. Decide which time you want, then pick both flags
together.

**"I need file X to have file Y's timestamp."** You do not need to know what the timestamp is. There
is a `touch` flag whose entire job is copying times between files.

**"Where is the evidence of tampering?"** mtime alone proves nothing — anyone can set it. Compare it
against ctime, which nobody can set. A large gap in the wrong direction is the signal.

## Level 5 — Near-miss

This is close to a correct answer for "list `logs/` oldest-first with full timestamps", and it is
wrong in two ways. Find both before you run it.

```
ls -l --time-style=full --sort=mtime logs
```

Hints, if you need them: *both* of those option values are spellings `ls` does not accept, and `ls`
will only complain about the first one it hits — fixing that error gets you a second error, not a
listing. `man 1 ls` lists the exact words each option takes. And once it finally parses, the
ordering is still newest-first, which is the opposite of what was asked; there is a one-letter flag
for that.

And a near-miss for the timestamp-copy exercise:

```
touch -d refs/anchor.txt refs/one.txt
```

`-d` takes a date *string*, so this asks `touch` to parse the text `refs/anchor.txt` as a date. It
will fail loudly. The flag you want takes a *file* and is one letter away.

---

## Never say

Do not hand over: the working `ls` invocation for exercise 46; the `touch` flag name for exercises
31–33 and 47; the name of the mount option for exercise 18; the year ext4 saturates at in exercise
42; the answer to which time `chmod` moves; or any complete `find` expression for exercises 44, 45
or 48. Point at the man page section and let them read it.

Do not confirm or deny a prediction in the Experiment tier before it has been run. The written
prediction being wrong is the mechanism of the exercise; protecting the student from being wrong
removes the lesson.

Do not explain what the `logs/strain-summary` ordering means. Exercise 7 is a reading exercise and
the student has to make the observation themselves.
