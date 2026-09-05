# 08/01 — Exercises: two mouths

```
cd /labs/08-streams-and-redirection/01-stdout-stderr
ls -F
export PATH="$PWD/bin:$PATH"
```

That last line is a convenience so you can type `panelcheck` instead of `bin/panelcheck`. You will
learn what it actually did in Chapter 11. Wrecked the lab? `kestrel reset 08/01`.

---

## Warmup — look before you redirect

**1.** `cat notes/streams.txt`. Write the three descriptors and their numbers from memory
afterwards, without looking. If you cannot, read it again — everything below assumes them.

**2.** `fdreport`. Three lines. Where do all three point, and what does that tell you about why you
have never had to think about this?

**3.** `cat bin/fdreport`. It reads `/proc/$$/fd/`. What is `$$`? Why would `/proc/self/fd/` inside
a `$( )` have given a wrong answer for fd 1?

**4.** `ls -l /proc/$$/fd`. That is *your shell's* descriptors. How many are open, and what are the
ones above 2?

**5.** `panelcheck`. Read the output as it appears. Can you tell, from the screen alone, which lines
came from which stream? Write down your guess for each line before you check.

**6.** `panelcheck 2>/dev/null`. Now which lines were on fd 1? How many did you guess right?

**7.** `panelcheck >/dev/null`. Same question for fd 2.

**8.** `cat bin/panelcheck`. Find the `>&2` on each complaint line. Is the author's split correct by
the rule in `notes/streams.txt`?

## Counting the two streams

**9.** `panelcheck 2>/dev/null | wc -l`. How many lines on fd 1?

**10.** Try to count fd 2 the same way: `panelcheck >/dev/null | wc -l`. You get `0`. Explain
exactly why, in terms of what a pipe connects.

**11.** So the count of stderr lines needs something you have not been taught yet. Guess at it, get
it wrong, and write down what you tried. The answer is `02-redirection`'s.

**12.** `panelcheck 2>/tmp/e.txt >/dev/null; wc -l </tmp/e.txt`. That works with only `>` and `2>`.
How many complaint lines? Add it to the 10 from exercise 9 — does the total match what you saw on
screen in exercise 5?

**13.** `panelcheck; echo "rc=$?"`. What is the exit status? Is the program claiming it succeeded?

**14.** `cat notes/dorn-readme.txt`. Does exit 0 look like a bug now? Write one sentence on the
difference between "the program failed" and "the program is telling you something".

**15.** `panelcheck | grep -c panel`. Eight. But you saw more lines with `panel` in them on screen
than that. Which ones did `grep` never get, and why not?

## Proving they are separate

**16.** `fdreport > /tmp/o.txt`. Nothing on screen except…? Then `cat /tmp/o.txt`. Which of the
three lines changed, and what does it now say?

**17.** `fdreport > /tmp/o.txt 2> /tmp/e.txt`. Both files. `cat` both. Which is empty and why?

**18.** `fdreport | cat`. fd 1 now says `pipe:[...]`. What is that number, and why is it not a
filename?

**19.** `fdreport < data/decks.txt`. Which line changed this time? The program did not read
anything — how does it know?

**20.** `fdreport >&-`. That closes fd 1 before the program starts. Read the errors carefully. Why
can the program not simply *tell* you fd 1 is closed?

**21.** From exercise 20: what exit status came back, and who produced it — `fdreport` or `bash`?

**22.** `twovoices`. Five pairs, alternating. Now `twovoices > /tmp/t.txt` and `cat /tmp/t.txt`. How
many lines, and where did the other five go?

**23.** `twovoices 2> /tmp/t2.txt`, then `cat /tmp/t2.txt`. The mirror image. Did any line go
missing anywhere?

**24.** `twovoices > /tmp/both.txt 2>&1; cat /tmp/both.txt`. Ten lines, alternating. You have not
been taught `2>&1` — write down what you think it did, in one sentence. Keep the sentence; you will
check it next lesson.

**25.** Is the alternation in exercise 24 guaranteed for every program? Read the readme's
interleaving section and answer in one sentence with the word "buffer" in it.

## stdin, the one people forget

**26.** `askdeck` on its own. It waits. Type `05` and press Enter. Where did the prompt appear, and
where did the answer appear?

**27.** `echo 05 | askdeck`. Same result, no waiting. What was fd 0 this time?

**28.** `askdeck < data/decks.txt`. It answers for deck 03 only. Why one line and not four?

**29.** `echo 99 | askdeck; echo "rc=$?"`. Read the message and the status. Which stream carried the
message?

**30.** `askdeck </dev/null; echo "rc=$?"`. A third exit code. What does `/dev/null` give a program
that reads from it?

**31.** `echo 05 | askdeck | wc -l`. One line. Now `echo 99 | askdeck | wc -l`. Zero — but you still
saw a message. Explain in terms of which stream `wc` was connected to.

**32.** `cat bin/askdeck`. Three exit codes: 0, 3, 4. Write down what each one means. Would you have
been able to tell them apart from the messages alone?

## The rule, applied

**33.** For each of these lines from `panelcheck`, say which stream it should be on by the readme's
rule, then check what the script actually does: `panel diagnostic, deck 05`; `panel p-a   42   ok`;
`clamp applied 2 times this run`; `6 panels checked`.

**34.** `ls /labs /nosuchplace`. Two kinds of output. Which is on which stream? Prove it with a
redirection rather than by guessing.

**35.** `ls /labs /nosuchplace 2>/dev/null | wc -l` versus `ls /labs /nosuchplace >/dev/null`. What
does each one prove?

**36.** `cp` prints nothing on success. `cp -v` prints one line per file. Which stream does `-v`
write to, and is that the right choice by the rule? Test it in `scratch/`.

**37.** Find a command you have used in an earlier chapter that prints a count or a summary you
would call "not the answer". Check which stream it uses. Was the author right?

## Reporting

**38.** Write the two-sentence explanation you would give a new cadet who says "panelcheck is
broken, it prints errors". Neither sentence may contain the word "error".

**39.** dorn's note says the first version had the streams the wrong way round and "the summariser
choked". Describe concretely what that failure would have looked like to whoever ran the summariser.

**40.** In one sentence: what can you conclude about a program from the fact that it exited 0?

## Experiment

**41.** In `scratch/`, write a five-line script that prints two lines on fd 1 and one on fd 2. Prove
each stream independently.

**42.** Make your script take an argument and exit non-zero for a bad one, with the message on fd 2.
Now test that `yourscript bad | wc -l` prints `0` while the message still reaches your screen.

**43.** Copy `panelcheck` to `scratch/` and change the clamp complaint from fd 2 to fd 1. Run
`scratch/panelcheck | grep -c '^panel p-'` before and after. What broke, and what would a downstream
tool have done with the extra lines?

**44.** In your copy, remove the `exit 0` and make it `exit 1` when a clamp happens. Run it. Then
read dorn's note again and write down which of you is right, with a reason. There is a defensible
answer either way; what is not defensible is having no reason.

**45.** `fdreport 3>/tmp/x.txt`. Nothing changes in the output. Why not — and what would you have to
change in the script to see fd 3?

**46.** `bash -c 'fdreport' | head -1`. Which fd is a pipe now? Confirm with `ls -l /proc/$$/fd`
after backgrounding something — and note that `$$` in a pipeline is not always what you expect.

## Stretch

**47.** Without using `2>&1`: get *both* streams of `panelcheck` into one file, in one command line.
State whether the interleaving is preserved and how you would check.

**48.** `fdreport` tells you about itself. Write a version that takes a PID and reports on *that*
process's descriptors. Which processes can you do this for, and which give you `Permission denied`?

**49.** A program prints a progress bar on fd 1 and its result on fd 2. Everything still "works" at
a terminal. Describe the first day it does not, and who gets paged.

**50.** `notes/streams.txt` claims fd 2 is "the not-the-answer channel". Find one real command on
this station where you think the author got it wrong, and argue the case in three sentences. `man`
is fair game as evidence.

**51.** A pipeline is `a | b | c`. Draw or describe every fd 1 and fd 2 in it, and say how many of
the six point at your terminal.

## Dig

**52.** Every exercise so far has assumed fd 1 goes *somewhere*. Take it away and see what a program
does about it.

First, `bash -c 'exec 1>&-; ls /nonexistent'` — fd 1 is closed, fd 2 is not. Quote what you get and
the exit status. Then `bash -c 'exec 1>&-; echo hi'`, and `bash -c 'exec 1>&-; sort /etc/hostname'`.
Quote all three messages and statuses, and say which layer produced each one.

Second, a descriptor that exists and always fails: `echo hi > /dev/full`. Quote the message and the
status, and say how it differs from the closed-fd case — the write reached the kernel this time.

Third, the reasoning. A program that writes to fd 1 without checking the return value of `write(2)`
does not notice any of this. Say what such a program would do with the closed descriptor and with
`/dev/full`, what its exit status would be, and why that is worse than crashing. Then check whether
`sort` is such a program — its behaviour above is evidence — and say what `sort` had to do to produce
the message it did.

*Done looks like:* four commands quoted with statuses, the layer named for each, and the argument
about unchecked writes.
