# 09/05 — Exercises: Job control

```
cd /labs/09-processes-and-job-control/05-job-control
ls -F
```

Chapters 1–9 tools. Wrecked the lab? `kestrel reset 09/05`.

**These exercises need an interactive shell.** Job control is *off* in scripts, which is itself
exercise 52. If you put these in a file and run it, most of them will fail with `no job control` and
you will have learned the wrong thing. Type them.

Clean up as you go: `jobs` before you leave, and `kill %n` anything still running. A lesson about
processes that survive is a lesson that will leave processes running if you let it.

---

## Warmup — one shell, two things

**1.** `cat notes/jobs.txt`. Read it once now. Two sentences in it will not make sense until exercise
20; come back to them.

**2.** `bin/quiet-work 30`. Wait for it. That is the foreground model: one command, and you have no
shell until it is done.

**3.** Run it again and this time press `Ctrl-C`. What killed it, what signal was that, and what does
`echo $?` say? (Lesson 03 gave you the number.)

**4.** `bin/quiet-work 60 &`. Write down the two numbers the shell prints. Which is the job number and
which is the pid?

**5.** `echo $!`. What is it, and which of the two numbers from exercise 4 does it match?

**6.** `jobs`. Then `jobs -l`. Name the four columns in the `-l` output.

**7.** `jobs -p`. What would you use that for that `jobs -l` makes awkward?

**8.** Start a second one: `bin/quiet-work 60 &`. Run `jobs`. Which job carries `+` and which carries
`-`? State the rule in your own words.

**9.** `ps -o pid,ppid,pgid,stat,args -p $(jobs -p)`. Do the two jobs share a process group? Why does
that matter, given what lesson 04 taught you about `kill -TERM -<pgid>`?

**10.** `kill %1`. What signal did that send? Prove it — do not assume. (`bin/hupper` and lesson 03's
exit statuses are both fair ways to find out.)

**11.** `jobs` again. What does job 1 say now? Run `jobs` a second time. Where did the line go?

## Stopping and resuming

**12.** `bin/talker 60 deck` in the *foreground*. Watch it for a few seconds, then `Ctrl-Z`.

**13.** `jobs`. What state? `ps -o pid,stat,args -p $(jobs -p)` — what is the process state letter,
and which lesson-03 signal produces it?

**14.** Which signal does `Ctrl-Z` send? Name it and its number. It is not the same one `Ctrl-C`
sends.

**15.** `fg`. It comes back to the foreground and carries on. `Ctrl-Z` it again.

**16.** `bg`. Now what does `jobs` say, and where is the output going?

**17.** While it is running in the background, start typing a command — do not press Enter yet. What
happens to your line? Who owns the terminal, and what does that tell you about backgrounding a
chatty program?

**18.** `bin/talker 60 loud > scratch/loud.out 2>&1 &`. Same program, quiet prompt. Explain in one
sentence why redirection is the standard partner of `&`.

**19.** Kill both talkers. Use a job spec, not a pid.

**20.** `bin/reader &`. Wait two seconds, then `jobs`. It stopped itself without you doing anything.
Read the state text carefully and say which signal did it and why.

**21.** Get it running: `fg`, type a line, press Enter. What did it print? Now say what would have
happened if you had run `kill %1` instead — and why that is the wrong reflex.

## Job specs

**22.** `bin/quiet-work 90 &` and `bin/counter 90 scratch/c.log &`. Now try `jobs %quiet`. It fails.
Read the error and say why.

**23.** Try `jobs %bin`. A different error. Why is *this* one ambiguous when exercise 22's was "no
such job"?

**24.** `jobs %?count`. Does that work? What is the difference between `%prefix` and `%?substring`?

**25.** `jobs %%` and `jobs %+` and `jobs %-`. Which job does each name right now?

**26.** Stop the counter with `Ctrl-Z`-equivalent — you cannot press Ctrl-Z on a background job, so
use `kill -TSTP %2`. Now run `jobs %%` again. Did the current job change? What changed it?

**27.** `jobs -r` and `jobs -s`. One job each. What are those flags for?

**28.** `jobs -n`. Run it twice in a row. What is it reporting, and why is the second run empty?

**29.** `bg %2` to get the counter going again, then `tail -3 scratch/c.log`, wait five seconds,
`tail -3` again. What does the file prove that `jobs` alone does not?

**30.** `wait %1`; time it. What was the shell doing while it waited, and what is `$?` afterwards?

**31.** Start `bin/quiet-work 5 &` and `bin/quiet-work 40 &`, then run `wait`. How long does it block?
Now do the same with `wait -n`. State the difference in one sentence.

**32.** Start `bin/quiet-work 30 &`, then `kill %1`, then `wait %1`. What status does `wait` return,
and does it match the rule from lesson 03?

## What survives — the rules

**33.** `shopt huponexit`. Write down the answer. `help shopt` if you want to know what class of thing
you just read.

**34.** `cat notes/survival.txt`, the numbered rules. Restate rule 2 in one sentence with both of its
conditions.

**35.** The experiment. In your shell:
`bash -ic 'cd $PWD; bin/hupper 30 scratch/a.log >/dev/null & sleep 1; exit'`, then wait three seconds
and `cat scratch/a.log`. Did it get HUP? Was that shell interactive? Was it a login shell?

**36.** Repeat with `shopt -s huponexit;` added at the start of the `-ic` string, logging to
`scratch/b.log`. The option is on and the job *still* survives. What does that prove about rule 2?

**37.** Now `bash -lic '...'` with the option set, logging to `scratch/c.log`. Read the log. Which of
the two conditions were you missing in exercise 36?

**38.** `pgrep -af bin/hupper` and clean up whatever is still running from 35 and 36. Note that you
are killing processes whose shell no longer exists.

**39.** Write the one-sentence answer to rhea's first question in `notes/page.txt`, using the evidence
from 35–37. It should not contain the word "usually".

## nohup, disown, setsid

**40.** `nohup bin/quiet-work 30 &`. Read the message on stderr *exactly*. Then `ls -l nohup.out` —
what is its size, and what are its permissions?

**41.** `grep -E 'SigIgn' /proc/$!/status`. Decode the mask the way you did in lesson 03. Which signal
did `nohup` add to the ignored set?

**42.** Now compare with a plain background job: `bin/quiet-work 30 &` then the same `grep`. Two
different masks. Which bit differs, and which bit is set in *both* — and why (lesson 03, exercise 23)?

**43.** `rm nohup.out`, then `nohup bin/quiet-work 30 > scratch/n.out &`. Read the stderr message: it
is a *different* message. Is there a `nohup.out` this time? State the rule `nohup` is actually
following.

**44.** So: does `nohup` mean "run in the background"? Answer with what you have just seen, and say
what `nohup cmd` with no `&` does.

**45.** `bin/counter 60 scratch/d.log &`, then `disown %1`, then `jobs`. Where did it go? Now
`pgrep -af 'bin/counter'` and `tail -1 scratch/d.log`. Did it stop?

**46.** Try `kill %1` now. Read the error. What have you given up by disowning, and what have you not?

**47.** Repeat with `disown -h` instead. What does `jobs` say this time? State the difference between
`disown` and `disown -h` in one sentence about the shell's table.

**48.** `setsid bin/counter 60 scratch/e.log`, no `&`. It returns immediately. Explain why you got
your prompt back without typing `&`.

**49.** `ps -o pid,ppid,pgid,sid,tty,stat,args -p $(pgrep -f 'scratch/e.log')`. Read all six fields.
What is its ppid, what is in the TT column, and what does the `s` in the STAT column mean?

**50.** `jobs`. The setsid'd process is nowhere. Which shell owns it? Is there an answer to that
question at all?

**51.** Rank `nohup`, `disown` and `setsid` by how much they change about the process, and say which
of the three leaves no record of the shell that started it.

## Scripts

**52.** Put `sleep 5 &` and `jobs` in a file and run it with `bash`. Then add `bg %1` and run it
again. Read the error. Why is job control off by default in a non-interactive shell?

**53.** Add `set -m` as the first line and run it again. What works now that did not? Check the pgid
of the job with `ps -o pid,pgid`.

**54.** Given lesson 04's process-group exercise — where `kill -TERM -<pgid>` in a script killed the
script itself — say what `set -m` would have changed about it.

**55.** Write the two-line guidance for a station script that must start a long job and not wait for
it. Say which of `&`, `nohup`, `disown` and `setsid` you would use, and what you would do about its
output.

## Reporting

**56.** `cat notes/page.txt`. Answer rhea's *second* question — how would anybody know who started a
surviving process — in three sentences, based on what you can actually read from `ps` and `/proc`.
Do not tell her it does not matter.

**57.** A process is running with ppid 1 and `?` in the TT column. List everything that fact does and
does not tell you about how it was started.

**58.** Write the check a person on shift could run at end of shift to find jobs they are about to
abandon. One command, and say what it misses.

## Experiment

**59.** How many jobs can one shell hold? Start twenty with a loop and run `jobs`. Then find out what
happens to the numbering when the middle ones finish.

**60.** Start a job, note the pid, `exec bash` (replacing your shell). Is the job still running? Does
the new shell know about it? Explain using what `exec` does.

**61.** Background a pipeline: `bin/talker 30 p | grep -c tick &`. How many processes, how many jobs?
Prove it with `ps` and with `jobs -l`, and say which pid `jobs -l` chose to show you.

**62.** Stop a job, then `kill -HUP %1` by hand. Does the trap in `bin/hupper` fire while the process
is stopped? When does it fire? (Lesson 03 answered this for TERM.)

## Stretch

**63.** Write `holdover`, a function that lists every process owned by you whose ppid is 1, with its
start time, sorted oldest first. That function is most of lesson 07.

**64.** `nohup` sets HUP to ignored, and lesson 03 proved a shell will not install a trap for a signal
it inherited as ignored. So can a program started under `nohup` handle HUP at all? Predict, then test
with `bin/hupper`, then explain the result.

**65.** Rebuild `disown` from parts: given a running job, what would you have to do to get the same
effect without the builtin? Say why the answer involves the shell's own bookkeeping and not the
kernel's.

**66.** A colleague suggests putting `shopt -s huponexit` in the station's `bashrc` so nothing is ever
left behind. Give the two reasons that is not a fix, using your results from 35–37 and 45–50.
