# 04/04 — Help: `rm`, Safely

Five rungs. Climb one at a time. Rung 5 is a near-miss on purpose — it will not do what it looks
like it does.

---

## Level 1 — Questions to ask yourself

- What does `rm` actually remove: the file, or a name for the file? What is the difference, and which
  one does `stat -c %h` measure?
- When `rm` refused, whose permission bits did it consult — the file's, or the directory's? Which one
  did you look at?
- When `rm` did **not** refuse but you expected it to, was there a prompt you never saw? Was stdin a
  terminal?
- `-f` is spelled "force". Force *what*? Name the two things it changes and the one thing it cannot.
- Before a glob-and-delete: did the shell hand `rm` the list you think it did? What is the cheapest
  way to find out that does not delete anything?
- The filename starts with a dash. Is that a problem with `rm`, or a problem with the convention that
  every command shares?
- The disk did not get emptier after you deleted the big file. What still exists that you cannot see
  with `ls`?
- You are about to run something with `-rf` and a variable in it. What does that command become if
  the variable is empty?

## Level 2 — Where to look

- `man 1 rm` — read `-f`, `-i`, `-I`, `-r`, `--preserve-root` and the RETURN VALUE section. `-I` has
  its threshold written down; do not guess it.
- `man 1 rmdir` — and specifically why it exists at all when `rm -r` is more capable.
- `man 7 path_resolution` and `man 2 unlink` — the ERRORS list on `unlink` is where the directory
  permission rule is stated in plain language (`EACCES`).
- `man 1 mktemp`, `help trap` (a bash builtin, so `help`, not `man`) — the Stretch tier.
- `man 1 find` — `-delete` and `-exec`; read the warning attached to `-delete`.
- `man 1 shred` — read the CAUTION paragraph before you form an opinion about it.
- `man 8 lsof` — search for `+L`. The argument after it is a number and it is a *threshold*.
- `/proc/<pid>/fd` — `ls -l` on it, on any process you started.
- `/course/04-creating-copying-destroying/04-rm-safely/setup.sh` — the header comment maps the lab.
  Reading it is allowed; it is not an answer key.

## Level 3 — The concept, on different data

Two names for one file, outside the lab where nothing matters:

```
$ printf 'hello\n' > /tmp/one.txt
$ ln /tmp/one.txt /tmp/two.txt
$ stat -c '%n inode=%i links=%h' /tmp/one.txt /tmp/two.txt
/tmp/one.txt inode=41123 links=2
/tmp/two.txt inode=41123 links=2
$ rm /tmp/one.txt
$ stat -c '%n inode=%i links=%h' /tmp/two.txt ; cat /tmp/two.txt
/tmp/two.txt inode=41123 links=1
hello
```

Nothing was deleted. A name was removed and a counter went down. When the counter reaches zero *and*
no process has the file open, the blocks come back.

The permission rule, on a directory you build yourself:

```
$ mkdir /tmp/d && printf 'x\n' > /tmp/d/f && chmod 400 /tmp/d/f
$ rm -f /tmp/d/f          # succeeds: the file is read-only, the directory is not
$ printf 'x\n' > /tmp/d/f && chmod 555 /tmp/d
$ rm -f /tmp/d/f          # fails: the file is writable, the directory is not
```

Run both. The pair is the whole of exercises 20–27, on files you cannot miss.

## Level 4 — Break it down

**"`rm` deleted my read-only file."** It was never the file's decision. Deleting is editing the
*directory* — removing an entry from it — so the bit that matters is write on the directory. The
prompt you got was a courtesy, not a permission check, and `-f` turns the courtesy off.

**"`rm -f` still says Permission denied."** Then it is the other case: check `ls -ld` on the
directory, not `ls -l` on the file. `-f` suppresses prompts and missing-file errors. It does not
acquire permissions you do not have.

**"There was no prompt."** `rm` only prompts when stdin is a terminal. Inside a pipeline, a script,
or with `</dev/null`, the courtesy prompt is skipped and the delete happens. Test the same command
both ways before you conclude anything about what `rm` "does".

**"I cannot delete a file called `-f`."** The problem happened before `rm` ran: nothing marks that
argument as a filename. Two independent fixes exist. One asks the command to stop parsing options
(`--`); the other stops it being a lone dash-word at all by giving it a path (`./`). Work out which
one still works with a command that does not honour `--`.

**"How do I check a glob without deleting anything?"** Replace `rm` with `ls` or `echo` and run the
identical line. The shell expands the same words either way — that is the point of doing it. Do this
every single time before a destructive glob; it costs one line.

**"The disk is still full."** Space is freed when link count reaches zero *and* the last open file
descriptor closes. `lsof` has a flag that lists exactly the files stuck between those two conditions.
Look at `+L` in the man page and think about what number you want after it.

**"Which of these `rm -rf` lines is dangerous?"** Stop reading them as `rm` and read them as the
shell: write out what each word expands to when the variable is empty or the path has a stray space.
The failsafe in `rm` matches the literal argument `/` after expansion — so it catches one of them and
cannot possibly catch the others.

## Level 5 — Near-miss

This is close to a `trash` function and it is wrong in two ways. Find both before you run it.

```
trash() { mv $1 trash/$(date +%s); }
```

Hints: `$1` is unquoted, so a filename with a space becomes two arguments and `mv` gets a
destination it did not expect; and only `$1` is used, so `trash a b c` silently ignores `b` and `c`.
There is a third thing worth arguing about: `trash/$(date +%s)` is a single name, so two files
trashed in the same second collide — and the collision is a silent overwrite, which is the exact
outcome the function existed to prevent.

And a near-miss for the awkward-names tier:

```
rm -f -- *
```

It runs, and it deletes more than the exercise asked for — including `keep-this.txt`. `--` fixes
the *dash* problem; it does nothing about the *glob* problem. Check what `*` expands to with `ls`
before you put `rm` in front of it.

---

## Never say

Do not hand over: the two fixes for a dash-leading filename in exercises 12–14 (point at
`man rm`'s description of `--`, and let them work out the path form themselves); the `lsof` flag for
exercise 45; the exact `find` expression for exercise 41; the working `trash` function for exercise
38; the `trap ... EXIT` line for exercise 40; or the answer to exercise 23 or 27 — the directory
rule is the single most valuable thing in this lesson and it has to be *derived* from the two
experiments, not told.

Do not confirm or deny a prediction in the Experiment tier before it has been run. Exercise 34 in
particular: the student is supposed to type `rm -rf /`, feel the fear, and be refused. Telling them
in advance that it is safe removes the experience the exercise exists to give.

Do not tell the student which of the three commands in exercise 36 is the safe one. That
identification *is* the exercise.

For exercise 47, do not describe the construction. The student has the rule from exercise 23; ask
them which directory `rm -r` has to write to in order to remove a file two levels down.
