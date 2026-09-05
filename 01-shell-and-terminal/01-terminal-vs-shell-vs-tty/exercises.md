# 01/01 — Exercises

Seed and enter the lab first:

```bash
kestrel seed 01/01      # in the VM
kestrel enter
lab 01/01               # inside the container
```

Keep written answers in `~/01-01-answers.md`.

---

**Ahead of the syllabus.** This lesson uses `ps -p`, which Chapter 9 teaches properly. Use it
exactly as written here; you are not expected to know it yet.

## Warmup

**1.** Report which tty you are on, what your shell's PID is, and what program that PID is.

*Done looks like:* three commands, three outputs, recorded.

**2.** Print your username two different ways — the short answer and the complete one — and say what
the complete one tells you that the short one does not.

*Done looks like:* both outputs and one sentence.

**3.** Show every process attached to your tty.

*Done looks like:* a listing that includes at least your shell and the listing command itself.

---

## Core

**4.** Run `tty` normally. Then run it so that it prints `not a tty`. Then explain, in one sentence,
what changed about the environment the program was running in — not about the program.

*Done looks like:* both outputs and the sentence.

**5.** In the lab, run `ls consoles`. Then run it so that its output goes through a pipe to `cat`.
The two outputs differ. Write down how, and why a program would deliberately behave differently
depending on where its output is going.

*Done looks like:* both outputs recorded and the reason stated.

**6.** Start a child shell. Prove it is a different process from the one you started in. Then get
back to the original and prove *that*.

*Done looks like:* four PID readings — before, inside, and after — with the two outer ones equal.

**7.** Go three shells deep. From the innermost, list the processes on your tty. Then get all the
way back out to your original shell, counting how many `exit`s it takes.

*Done looks like:* the process listing showing the nesting, and the count.

**8.** `$SHELL` and `ps -p $$` can disagree. Make them disagree, and record both readings at the
moment they do.

*Done looks like:* the two readings side by side, plus one sentence on which one you would trust in
a bug report and why.

**9.** Find the tty device file itself in the filesystem and show that it is a file. Then say what
kind of file it is — the listing tells you, in its first character.

*Done looks like:* a long listing of your own tty device, and the type named.

---

## Experiment

**10.** **Predict first, then run.** Two shells, two windows — or two `kestrel enter` sessions. In
each, run `tty` and `echo $$`.

Write down, *before running anything*: will the two ttys be the same or different? Will the two PIDs
be the same or different?

Then run it. Then explain any difference between your prediction and reality.

*Done looks like:* prediction, observation, explanation. The explanation matters more than being
right.

**11.** **Predict first, then run.** In one shell, note your PID. Start a child shell and note its
PID. Now, from the child, run `exit` — but predict first what `ps` in the *parent* will show
afterwards, and whether the child's PID will ever be reused while you watch.

*Done looks like:* prediction, observation, one sentence on what happened to the child process.

---

## Stretch

**12.** Using only what Chapter 0 gave you plus this lesson, write a single line in your answers
file that identifies this machine completely enough that someone reading it three weeks later could
tell it apart from any other shell session on the station: user, host, shell, tty, PID.

*Done looks like:* one line containing all five facts, and the commands you used to get each.

**13.** `deck-roster.txt` lists which decks have consoles. Your session is on a pseudo-terminal, not
one of those. Write two sentences explaining the difference between the `tty3` in that file and the
`/dev/pts/N` you are actually sitting on.

*Done looks like:* two sentences that get the hardware/software distinction right.

---

## Dig

**14.** `ps -p $$` shows four columns. Make it show the parent process ID as well, so you can see
what started your shell. The flag for that is not in the notes.

*Done looks like:* a `ps` invocation showing your shell's PID *and* its parent's, plus the name of
the parent process.

**15.** `who` and `w` both report who is logged in, and both show tty names. One of them also shows
what each session is currently running. Find out which, and say what the difference is between the
two commands in one sentence each.

*Done looks like:* both outputs and the two sentences.

---

## Core — the three things you keep confusing

**16.** Write down, in your own words and without looking at the readme, one sentence each for
*terminal*, *shell*, and *tty*. Then read the readme's definitions and mark which of your three was
furthest off.

*Done looks like:* three sentences, and an honest note about which one you had wrong.

**17.** Name the program that is drawing the window or pane you are typing into, and the program
that is interpreting what you type. They are different programs. Say which is which.

*Done looks like:* two program names, correctly assigned.

**18.** `echo $0` in your login shell, then `echo $0` inside `bash`, then inside `sh`. Three
readings. What is `$0` actually reporting?

*Done looks like:* three outputs and one sentence.

**19.** Run `ps` with no arguments. Every process it lists has something in common. What?

*Done looks like:* the listing and the common property named.

**20.** Now run `ps -p $$ -o pid,ppid,tty,comm`. Read each column aloud and say what it means.

*Done looks like:* the output and four short glosses.

**21.** Start a child shell, and from inside it run the exercise-20 command again. Which column
changed, and which stayed the same?

*Done looks like:* both outputs and the comparison.

**22.** From that child shell, run `ps -p $PPID -o pid,comm`. Whose PID is that?

*Done looks like:* the output and the answer in one word.

**23.** Exit back to your first shell and run `echo $PPID` there. What is the parent of your login
shell, and why is that a different kind of answer from exercise 22's?

*Done looks like:* the PID, the program name, and the sentence.

---

## Core — the terminal is a file

**24.** `echo hello > /dev/pts/N`, using your own tty's number. Where did the text appear, and which
program put it there?

*Done looks like:* the observed behaviour and the answer.

**25.** Open a second session, find *its* tty, and write a line to it from your first session.
Describe exactly what the person in the second session sees.

*Done looks like:* the command and a description of the effect.

**26.** Explain, in two sentences, why exercise 25 works at all — what a tty device file is a handle
*to*.

*Done looks like:* two sentences that do not use the word "magic".

**27.** `ls -l /dev/pts/` — how many pseudo-terminals exist right now, and does the count match the
number of sessions you have open?

*Done looks like:* the listing, the count, and the comparison.

**28.** `cat` with no arguments and no redirection. Type a line. Where is that line coming *from*?
Name the file. Then leave `cat` without killing it.

*Done looks like:* the file named and the exit keystroke recorded.

**29.** `echo $$ > /dev/null` and `echo $$ > /dev/pts/N`. Same command shape, two very different
destinations. Say in one sentence what both destinations have in common.

*Done looks like:* the sentence, with the word "file" in it.

---

## Core — sessions and what survives them

**30.** Run `ps -o pid,ppid,tty,comm -t "$(tty | sed 's|/dev/||')"` — or just `ps` — and count the
processes on your tty. Now start a child shell and count again.

*Done looks like:* two counts and the difference explained.

**31.** In one session, `echo "$$" > ~/first-pid.txt`. Open a second session and `cat` that file.
Did the second session know the first session's PID before you wrote it down? Why not?

*Done looks like:* the two outputs and one sentence about what is and is not shared between
sessions.

**32.** Set a shell variable — `MARKER=one` — in your first session. Check `echo $MARKER` in the
second session. Explain the result.

*Done looks like:* the empty output and the explanation.

**33.** Now `export MARKER=one` and check the second session again. Same result. Say why `export`
did not help, and what it *would* have helped with.

*Done looks like:* the result and the corrected mental model.

**34.** Leave a child shell running in one session. From another session, run `ps` and find it. What
does that tell you about whether "your shells" are private to your terminal?

*Done looks like:* the sighting and one sentence.

---

## Experiment — predict before you run

**35.** **Predict first.** Will `tty` inside `$(...)` print the same device as `tty` on its own? Write
your prediction, then run `echo "$(tty)"` and `tty`.

*Done looks like:* prediction, both outputs, and an explanation of any surprise.

**36.** **Predict first.** `ps` piped into `cat` versus `ps` alone. Will the output differ? Predict,
then run both.

*Done looks like:* prediction, both outputs, and the reason.

**37.** **Predict first.** You run `bash` three times without exiting. How many `bash` processes will
`ps` show on your tty? Predict the number, then check.

*Done looks like:* the predicted number, the actual number, and the arithmetic.

**38.** **Predict first.** From the innermost of those shells, will `echo $$` ever match the outermost
shell's PID? Predict yes or no, then prove it.

*Done looks like:* the prediction and the proof.

**39.** **Predict first.** If you close the terminal window while a child shell is running, what
happens to the child? Predict, then try it in a session you do not mind losing, and check from
another session.

*Done looks like:* prediction, observation, and one sentence. Chapter 9 explains the mechanism.

---

## Stretch

**40.** Write a single command line that prints your tty, your PID and your shell's program name on
one line, separated by spaces. Use `printf`, not three `echo`s.

*Done looks like:* one line of output and the command that produced it.

**41.** Someone sends you a bug report that says "the command failed in my terminal". List the four
facts from this lesson you would ask for, and say what each one would rule in or out.

*Done looks like:* four facts, each with a reason.

**42.** `consoles/` in the lab holds one file per station console. Read them and say which of those
consoles could be a real serial terminal and which must be a pseudo-terminal, giving your reasoning
from the names alone.

*Done looks like:* a split list and the reasoning.

**43.** Explain to a colleague, in three sentences, why `$SHELL` is a bad way to find out what shell
you are running right now.

*Done looks like:* three sentences that mention login, environment, and the actual process.

**44.** Your answers file for this lesson should already identify this session. Add one sentence
saying what would change in that identification if you reconnected tomorrow, and what would not.

*Done looks like:* one sentence separating the stable facts from the per-session ones.

---

## Dig

**45.** `ps` has a flag that shows the process hierarchy as a tree. Find it and use it to show your
nested shells. The notes do not name it.

*Done looks like:* a tree output with the nesting visible.

**46.** There is a command that prints the name of the terminal *the running process's parent* is
on, without `ps`. Find any route to that answer and describe it.

*Done looks like:* the route and the answer.

**47.** `/dev/tty` is not the same file as `/dev/pts/3`, but writing to it usually has the same
effect. Find out what `/dev/tty` actually is, and say when the two would differ.

*Done looks like:* an explanation and one concrete case.

**48.** Find out what a *session leader* is and whether your shell is one. `ps -o sid,pid` is a
starting point.

*Done looks like:* the readings and a definition in your own words.

**49.** Find out how many pseudo-terminals this system will allow at once, and where that limit is
recorded. It is a file.

*Done looks like:* the number and the path.

**50.** `stty -a` prints your terminal's settings. Find the setting that decides which key sends an
interrupt, and confirm it matches the key you actually use.

*Done looks like:* the relevant line and the key named.

**51.** Break your terminal on purpose: `cat` a binary file such as `/bin/ls` to the screen. Then
find the command that puts the terminal back in a sane state. Do this last.

*Done looks like:* the mess, the recovery command, and one sentence on what got broken.

**52.** After exercise 51, say what "the terminal" turned out to be holding that neither the shell
nor the program you ran was holding.

*Done looks like:* one sentence naming terminal state as the answer.
