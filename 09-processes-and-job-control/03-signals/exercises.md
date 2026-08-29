# 09/03 — Exercises: Signals

```
cd /labs/09-processes-and-job-control/03-signals
ls -F
```

Chapters 1–9 tools. Wrecked the lab? `kestrel reset 09/03`.

Several of these need two terminals, or a backgrounded command and a second prompt. Where an
exercise says "in another shell", `cmd &` and then working at the same prompt is fine.

---

## Warmup — the table

**1.** `cat notes/signals.txt`. Write down the three dispositions in your own words. Which one
requires the process to contain code, and which two do not?

**2.** `kill -l`. How many signals does this system have? Write down the number.

**3.** `kill -l 15`, `kill -l 9`, `kill -l 2`. Names from numbers. Now the other direction:
`kill -l TERM`, `kill -l KILL`, `kill -l INT`.

**4.** `kill -l 137`. It answers, and the answer is not signal 137. What did it do, and why is that
exactly the arithmetic you will need later in this lesson?

**5.** From `notes/signals.txt`: name the two signals that cannot be caught, blocked or ignored, and
say why each one exists.

**6.** Which signal is the default for a bare `kill PID`? Prove it from `man kill` rather than from
memory.

**7.** `kill -0 $$; echo "rc=$?"`. Signal 0 sends nothing. What is it for, and what did rc tell you?

**8.** `kill -0 99999; echo "rc=$?"`. Read the error text exactly. Two different failures could
produce a non-zero rc here — name both.

## Default behaviour

**9.** `bin/plain 30 &`, note the pid, then `kill $!`. What happened, and which signal did you send?

**10.** Same again, but this time watch the reported status. Run `bin/plain 30 & p=$!; kill $p; wait
$p; echo "rc=$?"`. Write down the number.

**11.** 143. Subtract 128. Which signal is that? Now do the same run with `kill -9` and predict the
number before you look.

**12.** And with `kill -INT`. Predict, then check. You have now seen three numbers you met in
Chapter 8 without an explanation.

**13.** `bin/signal-report bin/plain 3`. Let it finish on its own. What does it report, and what is
the rc of a process that was never signalled?

**14.** In one shell: `bin/signal-report bin/plain 30 &`. In another: `pkill -f 'bin/plain'`. Read
the report. Which pid did you actually kill — the reporter or the plain?

**15.** Not every non-zero status above 128 is a signal death. A script that ends with `exit 143` is
indistinguishable from one killed by TERM. What does that tell you about how much weight an exit
status can carry?

## Handlers

**16.** `cat bin/catcher`. Three `trap` lines. Say in one sentence what `trap 'CODE' SIG` installs.

**17.** `bin/catcher 60 &`, then `kill $!`. It does not die. Read what it printed.

**18.** `kill $!` twice more. Does the handler run every time, or is it consumed?

**19.** Now `kill -HUP $!`. Different message, same refusal. Then `kill -QUIT $!`. QUIT has no
handler in this script — and nothing happens either. Do not guess why yet; exercise 23 is about to
explain it.

**20.** Restart it and try `kill -9`. Predict first. Then say, in one sentence, what the handler
would have had to do to survive that.

**21.** `trap` with no arguments in your own shell lists the traps that shell has installed. Run it.
Now `trap 'echo ouch' USR1`, then `kill -USR1 $$`. Explain what just happened to your own shell.

**22.** `trap - USR1` removes it. Prove it: `kill -USR1 $$` again. What is the default disposition of
USR1, and what did that just do to your shell? (Do this in a throwaway `bash` you can afford to
lose.)

**23.** `bin/catcher 60 &` and then `kill -INT $!`. The INT handler does *not* fire. Try the same
thing in an interactive shell: `bash -ic 'bin/catcher 20 & sleep 1; kill -INT $!; sleep 2'`. Now it
does. This is not a bug in the script.

**23a.** Prove it rather than believing it. `bin/catcher 60 & grep -E 'SigIgn|SigCgt' /proc/$!/status`.
Two hexadecimal bitmasks, one bit per signal, bit 0 = signal 1. Decode `SigIgn: …0006`: which two
signals is this process ignoring, and did the script ask for that?

**23b.** Decode `SigCgt: …14001` the same way. Which three signals did the script actually manage to
catch? Compare with the three `trap` lines in `bin/catcher` and name the one that did not take.

**24.** The rule, in two halves. A command started in the background by a **non-interactive** shell
gets SIGINT and SIGQUIT set to *ignored*. And a shell will not install a trap for a signal it
inherited as ignored — it accepts the `trap` line silently and does nothing. Prove the second half:
`( trap '' INT; bash -c 'trap "echo fired" INT; trap -p INT; sleep 3' )`. Read the `trap -p` output.

**24a.** Why does the first half of that rule exist — what is it protecting you from when you press
Ctrl-C at a script that has backgrounded something?

**25.** Given exercise 23: if you are writing a script that must be interruptible, which signal
should your caller use, and which one must your handler not rely on?

## What 9 costs

**26.** `bin/tidy 60 &`, note the pid, `ls scratch/`. There is a work file. Now `kill $!` and
`ls scratch/` again.

**27.** Same, but `kill -9`. `ls scratch/`. Compare. Write the one-sentence version of the difference
that you would say to somebody about to type `-9`.

**28.** `bin/tidy 60 & p=$!; kill $p; wait $p; echo rc=$?` versus the same with `-9`. Two statuses.
Which one says "cleaned up and left properly"?

**29.** The work file is named after the pid. Kill three tidies with `-9` in a row and look at
`scratch/`. Describe the state of a system where this has been happening nightly for a year.

**30.** Clean up your mess with the tools from Chapter 4. Then say what would have cleaned it up
automatically, and what it would have cost.

**31.** Name three specific things a program might not do if it is killed with 9. Be concrete — not
"cleanup", but what kind of cleanup.

**32.** Write down the escalation order you would use on a process that will not exit, and say how
long you would wait between steps and why.

## Stopping and continuing

**33.** `bin/plain 120 &`, note the pid, `kill -STOP $!`. Now `ps -o pid,stat,comm -p $!`. What is the
state letter?

**34.** While it is stopped, does its `TIME+` in `top` advance? Does it hold its memory? Does it hold
its open files? Answer each and say how you checked.

**35.** `kill -CONT $!`, then `ps -o pid,stat,comm -p $!` again. Which state did it return to?

**36.** Send `kill -TERM` to a **stopped** process. Does it die? Now send `CONT`. Explain the order
of events you just observed.

**37.** STOP cannot be caught. TSTP (20) can. Which one does Ctrl-Z send, and why is that the right
choice for a key on a keyboard?

**38.** Is a stopped process consuming CPU? Is it consuming memory? Which of those two is the reason
"just suspend it" is not always a fix.

## Families

**39.** `cat notes/family.txt`. State the rule about which processes a signal reaches.

**40.** `bin/orphan-demo 20`. It prints its own pid and its child's, then exits. In another shell,
`ps -o pid,ppid,stat,args -p <child>`. What is the child's ppid now?

**41.** Wait for the child's twenty seconds to pass, then look at it again. It is not gone. What
state is it in, and what is the word for that?

**42.** `kill -9 <the zombie>; echo rc=$?`. rc is 0. `ps` again. Explain both halves of that result.

**43.** `ps -e --no-headers -o stat | grep -c '^Z'`. How many zombies does this station have? Run it
a few more times as you work through this section.

**44.** `ps -p 1 -o pid,comm,args`. What is pid 1 here? Read `notes/family.txt` on what that means
for the zombies you have been making.

**45.** On a normal machine pid 1 reaps orphans within milliseconds. State what actually clears a
zombie — it is not `kill`, and it is not time.

**46.** So: is a large zombie count a CPU problem, a memory problem, or a bookkeeping problem? What
is the resource that eventually runs out?

**47.** `bin/nest 3` from lesson 01 built a chain by `exec`, so it is one process. Build a real chain
instead: `bash -c 'bin/plain 60 & bin/plain 60 & sleep 60' &`. Kill the outer bash with TERM and then
find the two `plain` processes. Whose children are they now?

## Reporting

**48.** cass asks "did the job get killed or did it fail?" You have the exit status 137. Write the
two-sentence answer, including what you cannot tell her from the status alone.

**49.** rhea's `notes/page.txt` has five people telling her five things about `kill -9`. Read it.
Which of the five statements are true, which are false, and which are true-but-dangerous?

**50.** Write the sentence you would put in a runbook next to a `kill -9` line, explaining under what
condition an operator is allowed to reach that line.

## Experiment

**51.** Write a script in `scratch/` that traps TERM, sleeps thirty seconds inside the handler, and
then exits. Send it TERM. Then send it TERM again *while the handler is running*. What happens to the
second signal — queued, dropped, or does it re-enter the handler?

**52.** Trap `EXIT` instead of TERM. Does it fire on a normal exit? On TERM? On KILL? Test all three
and write down which of the three it cannot cover.

**53.** `sleep 100 & kill -TERM $!` — instant. Now `bin/catcher 100 &` and time how long a TERM takes
to *not* work. Why is a signal delivered to a process blocked in `sleep` handled immediately, and
what is `wait $!` doing in `bin/catcher` that makes that possible?

**54.** `kill -TERM 1; echo rc=$?`. rc is 0, the send succeeded — and pid 1 is still there. The
kernel refuses to deliver a signal to pid 1 unless pid 1 installed a handler for it, because killing
pid 1 tears down everything under it. Which of the two uncatchable signals does that protection also
cover, and why does it have to?

**55.** `kill -TERM $$` from an interactive shell. What happens, and why is the answer different from
what you would get in a script? Do this in a `bash` you can afford to lose.

## Stretch

**56.** Write `gently PID` in `scratch/`: sends TERM, waits up to five seconds checking with
`kill -0`, sends TERM again, waits five more, then sends KILL and says so loudly. Test it against
`bin/plain`, `bin/tidy` and `bin/catcher`. Which of the three makes it reach the last line?

**57.** `timeout` exists and does part of this. `timeout 3 bin/catcher 60; echo rc=$?` and then
`timeout -s KILL 3 bin/catcher 60; echo rc=$?`. Two statuses. Read `man timeout` on 124 and on
`-k`, and say when you would still write `gently` yourself.

**58.** A handler that calls `exit` inside a trap loses the fact that it was signalled — the process
exits 0, not 143. Rewrite `bin/tidy`'s handler so it cleans up *and* reports the signal death
honestly. (`trap - TERM; kill -TERM $$` is the idiom. Explain why it works.)

**59.** Can you write a program that survives `kill -9`? State plainly why not, and then say what
people who claim they have one have actually done.

**60.** The chapter's incident involves a process that has been running since 2186. Given only what
you know now: name three things you would want to record about it *before* signalling it, and say
which of the three cannot be recovered afterwards.
