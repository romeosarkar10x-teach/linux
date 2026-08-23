# 04/01 — Help: cat and Friends

Five rungs. Climb one at a time. Rung 5 is a near-miss on purpose — it does not work as written.

---

## Level 1 — Questions to ask yourself

- Is the thing you cannot see missing, or is it there and invisible? Those are different problems
  with different flags.
- `wc -l` and "number of lines of text" are not the same claim. What exactly does `wc -l` count?
- When two commands both "number lines" and disagree, which one has an opinion about blank lines?
- Are you asking for a count of lines, or a position in the file? `head`/`tail` do both, with
  different arguments.
- Does the command you just typed stop on its own? If not, what would make it stop, and is that a
  key or a signal?
- Does the tool need a terminal, or will any stream do? What happens to a tool that needs a terminal
  when you put it on the wrong end of a pipe?
- When you predicted an output and got a different one, was your model of the *tool* wrong, or your
  model of the *file*?

## Level 2 — Where to look

- `man 1 cat` — the whole page is under a screen. Read every option; there are only seven and this
  lesson uses six.
- `man 1 nl` — the `-b` entry is the one that explains exercise 11. `-n`, `-w`, `-s`, `-i` are all
  on the same page for exercise 38.
- `man 1 head` and `man 1 tail` — read what `-n` does with a plain number, a `+` number and a `-`
  number. All three are documented and all three are different for one of the two commands.
- `man 1 tail`, the `-f` and `-F` entries, and the paragraph about what happens when the file is
  rotated or replaced.
- `man 1 less` — long, but the COMMANDS section is a keystroke table. Search it for `+F`, for the
  mark commands, and for `-S`.
- `man 1 tac`, the `-s` and `-b` entries.
- `man 2 lseek` for exercise 37. `strace` is not in this image; the reasoning is the exercise.

## Level 3 — The concept, on different data

Make yourself a file that is wrong in the same way `notes/` is wrong, somewhere you cannot break
anything:

```
$ cd $(mktemp -d)
$ printf 'one\ttwo\r\nthree' > demo.txt
$ cat demo.txt
one     two
three$                       <-- prompt is on the same line as "three"
$ wc -l demo.txt
1 demo.txt                   <-- two visible lines of text, one counted
$ cat -A demo.txt
one^Itwo^M$
three                        <-- no $ on the last line at all
```

Three separate facts, all visible at once: a tab renders as blank space and prints as `^I`; a
carriage return is a real character sitting before the newline and prints as `^M`; and a file can
simply *stop*, with no newline on the end, which is why `wc -l` said 1 and why your prompt moved.

Same idea for the numbering disagreement, on four lines instead of a hundred and twenty:

```
$ printf 'a\n\nb\nc\n' > n.txt
$ cat -n n.txt
     1  a
     2
     3  b
     4  c
$ nl n.txt
     1  a

     2  b
     3  c
```

`cat -n` numbers lines. `nl` numbers *body lines*, and blank is not body. That is the entire
difference, and one option changes it.

## Level 4 — Break it down

**"I need lines M to N and I only have `head` and `tail`."** Take them one at a time. `head -n N`
gives you everything from the start through line N. You now have a file whose *last* lines are the
ones you want. How many of them do you want? N − M + 1. Feed that to `tail -n`. Write the arithmetic
down before you type the command; getting an off-by-one here is normal and checking it with `wc -l`
is the fix.

**"`tail -n 5` and `tail -n +5` do different things and I keep guessing."** They are answering
different questions. One is a *quantity from the end*, the other is a *position from the start*.
Test both on a ten-line file you made yourself, where you can see the whole thing, and the rule will
stick better than any sentence here.

**"My `tail -f` printed nothing when I recreated the file."** `tail -f` follows an open file
description, not a name. Ask yourself what happened to the thing it had open when you deleted the
name, and whether the new file with the same name is the same file. Chapter 3 answered "is this the
same file" with a command; use it.

**"`less` did something strange in a pipe."** Sort out which of `less`'s two streams the pipe
affected: the one it writes screens to, or the one it reads your keystrokes from. Only one of them is
standard output, and only one of them is standard input, and `less` needs both.

**"`tac -s` did nothing at all."** Look at what your shell actually handed `tac`, not what you typed.
`$(printf '\n\n')` is not two newlines by the time `tac` sees it — command substitution strips
trailing newlines, so `tac` was given the empty string and did the only sensible thing with it.
`$'...'` quoting exists for exactly this.

**"I do not know what the byte on my screen was."** Do not guess from the shape of it. `cat -v`
names control characters as `^X` and high bytes as `M-x`. If you want the actual number,
`od -c` and `od -An -tx1` are still in your hands from Chapter 3.

## Level 5 — Near-miss

Close to a correct answer for "print lines 4000 through 4010 of the roster", and wrong:

```
head -n 4000 logs/roster.txt | tail -n 10
```

Both numbers are defensible and both are wrong. Count the lines that command prints, count the lines
between 4000 and 4010 inclusive, and count which line it ends on. Two separate off-by-ones, and
fixing one does not fix the other.

And a near-miss for the fragment reassembly:

```
cat fragments/01-head.txt fragments/02-body.txt tac fragments/03-tail.txt
```

`cat` does not take a command as an argument. This asks it to open a file called `tac`, and it will
tell you so — and then carry on and print the third fragment exactly as stored, which is the order
you were trying to fix. A partial failure that still produces plausible output is the worst kind to
skim past.

---

## Never say

Do not hand over: the `nl` option for exercise 12; the exact `head`/`tail` pair for exercises 16 and
17; the name of the `less` follow mode for exercise 35; the `tac` separator spelling for exercise 39;
or the complete `nl` invocation for exercise 38. Point at the man page and let them read it.

Do not confirm or deny a prediction in the Experiment tier before it has been run. Exercises 25, 27,
28 and 29 are each built on the student being wrong once; saying the answer first removes the lesson.

Do not tell the student which fragment is stored backwards in exercise 20. They can read.

Do not explain why `tail -f` and `tail -F` differ in exercise 29 before the student has watched both.
The pair only teaches anything as a contrast.
