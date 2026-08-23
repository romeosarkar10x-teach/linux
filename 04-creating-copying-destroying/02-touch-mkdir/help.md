# 04/02 — Help: touch and mkdir

Five rungs. Climb one at a time. Rung 5 does not work as written.

---

## Level 1 — Questions to ask yourself

- Who expanded that word — the shell, or the command? If you are not sure, put `echo` in front of it.
- Does your brace group contain a comma or a `..`? If neither, it is not an expansion.
- Are the numbers you want padded? Which element of the range decides that?
- The command failed. Did it fail because the thing exists, because something *else* exists in its
  place, or because you could not write there? Those are three different errors and they say so.
- When you set a mode, are you setting it, or are you asking for it and letting the umask subtract?
- Did the command create the file, or did it only touch a file that was already there? How would you
  tell the two apart afterwards?
- You ran the command twice. Should the second run have changed anything?

## Level 2 — Where to look

- `man 1 mkdir` — short. `-p`, `-m`, `-v` are the whole lesson. Read what `-m` says about the umask.
- `man 1 touch` — `-c`, `-r`, `-a`, `-m`, `-d`. You saw these in Chapter 3 lesson 04; the new part is
  the sentence about creating the file.
- `man 1 rmdir` — `-p`, and its one paragraph about what it does with the parent directories.
- `man bash`, the **EXPANSION** section, subsection *Brace Expansion*. Four paragraphs. It states the
  evaluation order relative to the other expansions, which is exercise 40.
- `man 1 umask` is a shell builtin — `help umask` in bash, or the *SHELL BUILTIN COMMANDS* section.
- `spec/naming-notes.txt` in the lab. It is reference material, not a hint, and it is there because
  the obvious brace expression is wrong twice.

## Level 3 — The concept, on different data

Do this somewhere disposable and watch the shell, not the command:

```
$ cd $(mktemp -d)
$ echo crate-{1..3}
crate-1 crate-2 crate-3
$ echo crate-{01..03}
crate-01 crate-02 crate-03        <-- padding comes from the FIRST element's width
$ echo crate-{01}
crate-{01}                        <-- no comma, no ..: not an expansion at all
$ echo crate-{a,b}/{x,y}
crate-a/x crate-a/y crate-b/x crate-b/y   <-- adjacent groups multiply, rightmost varies fastest
```

Every one of those was `echo`. Nothing was created. Get the expansion right with `echo` first, then
change `echo` to `mkdir -p`. That habit is worth more than any flag in this lesson.

And the three failure modes of `mkdir`, on four lines:

```
$ mkdir -p a/b ; touch a/file
$ mkdir a/b            ; echo $?    # mkdir: ... 'a/b': File exists            -> 1
$ mkdir -p a/b         ; echo $?    #                                          -> 0
$ mkdir -p a/file/c    ; echo $?    # mkdir: ... 'a/file': Not a directory     -> 1
$ mkdir -p a/file      ; echo $?    # mkdir: ... 'a/file': File exists         -> 1
```

Read those four together. `-p` forgives exactly one thing: *the directory I was asked to make is
already a directory.* It forgives nothing about files standing in the way.

## Level 4 — Break it down

**"My tree came out with `bay-1` instead of `bay-01`."** The padding of a `{x..y}` range is decided
by the width of the first element as you wrote it. `{1..4}` gives one digit. `{01..04}` gives two.
Nothing about the *upper* bound matters.

**"I built both decks in one expansion and the bay counts are wrong."** They are not the same shape.
An expansion that produces the right paths for deck-03 produces two extra bays under it if you widen
the range to suit deck-04. Two decks, two expansions — or one command line with two words in it,
which is still one command.

**"How do I count what I built?"** `find build -type d | wc -l`, and remember it counts `build`
itself. If your number is one off, that is almost certainly why. If it is off by more, `find build
-type d | sort` and read.

**"`mkdir -m 777` and `mkdir` + `chmod 777` gave me the same thing, so what is the difference?"** The
end state is the same. The path there is not: the second version leaves the directory sitting at the
umask-derived mode for a moment, and during that moment it exists and is reachable by anyone who can
see the parent. Ask yourself who could be looking, and what they could do in that window. Then ask
whether the same reasoning works for `touch` plus `chmod`, because for files the answer is worse.

**"`rmdir -p` deleted more than I told it to."** Read the man page sentence about parents again.
It removes the named directory and then keeps going upwards for as long as each parent is empty.
That is the documented behaviour, and it is why it is not a safe habit.

**"The shell keeps eating my filename."** A leading `-` makes it look like an option; spaces make it
look like several arguments. Two independent problems with two different fixes, and a name that has
both needs both.

## Level 5 — Near-miss

Close to a correct answer for "build the deck-03 bays with their three subdirectories", and wrong in
two ways at once:

```
mkdir build/deck-03/bay-{1..4}/{readings faults handover}
```

One of the two brace groups is not an expansion — it has spaces where it needs commas, so the shell
splits it into three separate arguments, two of which are bare words. And even with that fixed the
command still fails, because of what is missing between `build` and `bay-1`.

Worse than failing: it half-succeeds. Four paths error out with `No such file or directory`, and the
two bare words `faults` and `handover` are perfectly good relative paths, so `mkdir` creates them in
whatever directory you happened to be standing in. Run it, then `ls`, then clean up.

And a near-miss for the timestamp exercises:

```
touch -r '2187-05-17 04:02' times/one.txt
```

`-r` takes a *file* whose times are to be copied, not a date. This asks `touch` to read the times of
a file named `2187-05-17 04:02`, which does not exist, and it will say so. The flag that takes a date
string is one letter away and you used it in Chapter 3.

---

## Never say

Do not hand over: the working brace expression for exercises 14, 16 or 33; the name of the `mkdir`
flag for exercise 23; the two dash-name techniques in exercise 37; or the `find`-driven form in
exercise 35. Point at `man bash` EXPANSION and let them build it with `echo` first.

Do not confirm or deny a prediction in the Experiment tier before it has been run.

Do not tell the student the directory counts for exercise 12 or 17. Recounting by hand until the two
numbers agree is the exercise. If they are stuck, ask them how `find` counts `build` itself.

Do not pre-empt exercise 26 by mentioning what `rmdir -p` does to parents; and do not pre-empt
exercise 30 by saying which timestamp moves.
