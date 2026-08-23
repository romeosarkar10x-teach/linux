# 04/03 — Help: `cp` & `mv`

Five rungs. Climb one at a time. Rung 5 is a near-miss on purpose — it will not do what it looks
like it does.

---

## Level 1 — Questions to ask yourself

- Before you press return: does the destination exist right now, and is it a file or a directory?
  Those are three different states and the command means three different things.
- Did you ask for the destination to be a *name*, or a *place to put things*? Which one did the
  command assume?
- When something ended up one level deeper than you expected, what was already sitting at the
  destination path?
- You copied a file and something about it changed. Which of mode, owner, times and link count did
  you actually check, and which are you assuming?
- `mv` finished instantly on a large file, or it did not. What does the difference tell you about
  where the two paths live?
- The file you did not want to lose is gone. Which command overwrote it, and was there any output at
  all when it did?

## Level 2 — Where to look

- `man 1 cp` — read `-r`, `-T`, `-t`, `-i`, `-n`, `-u`, `-p`, `-a`, `-L`, `-d` and `--backup`. Pay
  attention to the sentences that say *when* an option has no effect.
- `man 1 mv` — much shorter. Read the `-T` and `-t` entries and the paragraph about prompting for
  files whose permissions forbid writing.
- `stat -c '%n %i %h %a %U:%G %y'` — one line that answers most of "did that survive the copy?"
- `df --output=source,target /labs /tmp` — the two paths in this container are not on the same
  filesystem, which matters for exercise 35.
- `help set` in bash — search for `noclobber`. It is a shell option, not a `cp` option, which is the
  whole point of exercise 42.
- `/course/04-creating-copying-destroying/03-cp-mv/setup.sh` — the header comment lists what was
  seeded and why. Reading it is allowed.

## Level 3 — The concept, on different data

Do this in a scratch directory of your own, where nothing matters:

```
$ cd "$(mktemp -d)"
$ mkdir tree; echo one > tree/a.txt
$ cp -r tree copy1            # copy1 does not exist
$ find copy1
copy1
copy1/a.txt                   <-- copy1 IS the tree
$ cp -r tree copy1            # copy1 exists now
$ find copy1
copy1
copy1/a.txt
copy1/tree                    <-- the tree went INSIDE
copy1/tree/a.txt
```

Two identical commands, run one after the other, with different results — because the first one
changed the state the second one was reading. That is the entire trailing-slash confusion, and no
slash was involved.

And for the metadata question, on a file you can throw away:

```
$ echo x > f; chmod 640 f; touch -d 2000-01-01 f
$ cp f g; cp -p f h
$ stat -c '%n %a %y' f g h
```

The mode came across both times. One of the two times did not. Exercises 26 to 28 are that
observation, made carefully.

## Level 4 — Break it down

**"It ended up in the wrong place."** Do not re-read the command. Run `ls -ld DESTINATION` *first*,
before you copy. If it prints a line starting with `d`, your source is going inside it. If it says
`No such file or directory`, your source is becoming it. There is no third case.

**"I want the destination to be a name, not a folder."** There is a `cp` and `mv` option whose entire
job is to say "treat the destination as a name even if a directory is sitting there". It is a single
capital letter and `man cp` describes it as no-target-directory.

**"Did the copy really survive intact?"** Check one thing at a time, and check it with `stat`, not by
looking at the file:

1. `%a` — mode. Plain `cp` usually keeps it.
2. `%U:%G` — owner and group. Plain `cp` does not.
3. `%y` — mtime. Plain `cp` does not.
4. `%h` — hard-link count. Plain `cp -r` does not; it makes two independent files out of one.

Whichever of those four you need is what decides between `cp`, `cp -p` and `cp -a`.

**"`-u` did nothing and printed nothing."** That is what "up to date" looks like. Add `-v` and it
will print a line only for the files it actually copied. Then compare the two mtimes with `stat` and
you will see why the ones it skipped were skipped.

**"The prompt never appeared."** `-i` prompts on your terminal. Redirect stdin from anywhere else and
there is nobody to answer, so the answer is no and the exit status is 1. If you want a refusal that
works without a human, you want the other flag.

**"I need every file in `rename/` renamed."** `mv` renames one thing. Something else has to supply
the six names — a `for` loop over `rename/pnl_*.log`, with the new name built from the old one inside
the loop body. Parameter expansion (`${f#prefix}`, `${f%suffix}`) is worth reading up on here, but a
`basename` and a bit of string surgery is equally acceptable.

## Level 5 — Near-miss

This looks like the answer to exercise 30 — rename all six logs at once — and it is not.

```
mv rename/pnl_{01..06}.log rename/panel-{01..06}.log
```

Run it and read the error before you read the rest of this. The brace expansions both work perfectly;
that is not the problem. The shell hands `mv` twelve arguments, and `mv` has exactly one rule for
what to do with more than two: the last one is the destination directory and everything before it
goes into it. `rename/panel-06.log` is not a directory and does not exist, so the whole command
fails — after which you get to work out whether it failed cleanly or moved five files first.

A second near-miss, for the "reproduce this tree exactly" exercise:

```
cp -rp source scratch/mirror
```

`-r` and `-p` together look like they cover everything, and they cover most of it. Two things they do
not cover: what happens to a symlink, and what happens to a pair of names that were one inode. There
is a single flag that means all of this and more; `man cp` spells out exactly which options it is
equivalent to.

---

## Never say

Do not hand over: the letter for the no-target-directory option in exercises 8 and 36; the name of
the flag that is `-dR --preserve=all`; the loop for exercise 30; the shell option in exercise 42;
which of the four `stat` times cannot be preserved in exercise 46; or the reason `mv` prompts in
exercise 43 — that one is a permissions argument the student must make themselves.

Do not confirm or deny a prediction in the Experiment tier before it has been run.

Do not tell a student what state their lab is in. Have them `ls -ld` the destination and read it. The
habit is the lesson.

Do not stop them from overwriting something inside the lab. Losing a file to `cp` once, in a
directory that `kestrel reset` restores, is the point of the chapter.
