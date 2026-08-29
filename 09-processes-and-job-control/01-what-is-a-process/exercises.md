# 09/01 — Exercises: what a process is

```
cd /labs/09-processes-and-job-control/01-what-is-a-process
ls -F
```

Chapters 1–8 tools. Wrecked the lab? `kestrel reset 09/01`. Everything you start here dies on its
own; if something outlives you, `pkill -f` it and move on — you get that tool properly in 09/04.

---

## Warmup — you are a process

**1.** `cat notes/page.txt`. What is rhea asking for, and what is she explicitly *not* asking for?

**2.** `echo $$`. That is your shell's pid. Write it down.

**3.** `echo $PPID`. Whose number is that? Run `ps -p $PPID -o pid,comm=` and say what started your
shell.

**4.** `bin/whoami-really`. Compare the `pid` it prints with your `$$`. Are they the same? Should
they be?

**5.** Run `bin/whoami-really` three more times. Which of the five printed fields changed each time,
and which stayed fixed? Explain each.

**6.** The `ppid` it prints — what number is that, and why?

**7.** `type cd` and `type ls`. One is a builtin and one is a file. Given the fork/exec model in
`notes/process.txt`, say why `cd` *has* to be a builtin.

**8.** `type type`, `type echo`, `type grep`, `type kill`. Sort them into builtins and files. Now run
`type -a echo` and `type -a kill`. Several of them are both — which one does the shell actually run,
and what would you have to write to get the other?

## Looking: ps, the short way

**9.** `ps`. How many processes? Now `ps -e | wc -l`. Bigger. Explain in one sentence what plain
`ps` filtered out.

**10.** `tty`. If it prints a `/dev/pts/...` path you have a terminal; that is what plain `ps` is
selecting on. Say what plain `ps` would show in a script run with no terminal at all.

**11.** `ps -ef | head -3`. Name every column in the header, in order.

**12.** `ps aux | head -3`. Same. Which columns exist here that `-ef` did not give you, and which
one did `-ef` give you that this does not?

**13.** State the rule you will use from now on: which of the two styles do you reach for when the
question is "who started this", and which when the question is "what is eating the machine"?

**14.** `ps -p 1 -o pid,ppid,user,comm`. What is pid 1 on this station, and what is its ppid?

**15.** Why can pid 1 have that ppid when every other process has a real one? Answer from
`notes/process.txt`.

**16.** `ps -e --no-headers | wc -l`. That is the whole station. Compare with a machine you have used
that had a desktop on it. What does the number tell you about what a container is?

## Looking: ps, your way

**17.** `ps -eo pid,ppid,user,comm`. Now add `--sort=pid`. Which is easier to read as a tree, and why
is neither one actually a tree?

**18.** Build a `ps -eo` line that answers exactly this and nothing else: *what is the pid and
elapsed run time of every process owned by cadet?* Use `etime`.

**19.** `ps -eo pid,etime,comm --sort=-etime | head -3`. Which process has been running longest?
Does that surprise you?

**20.** `ps -eo pid,comm` versus `ps -eo pid,args`. Run both. Describe the difference precisely — not
"one is longer".

**21.** `ps -eo pid,comm=` (note the trailing `=`). What did the `=` do? Why is that useful in a
pipeline?

**22.** Count the processes per program name: `ps -eo comm= | sort | uniq -c | sort -rn`. What is the
most common program running right now, and how many times?

**23.** That last answer is one program and several processes. Write the sentence that makes the
distinction, using the actual name and count you got.

## fork and exec, watched live

**24.** `bin/sleeper 30 alpha &`. It prints its pid and ppid to standard error. Write both down.

**25.** While it runs: `ps -eo pid,ppid,args | grep -v grep | grep -E 'sleeper|sleep 30'`. You get
**two** lines. Why two, when you started one command?

**26.** Which of those two is the parent of the other? Prove it from the columns, not from the order
they printed.

**27.** `pstree -p $$`. Find your sleeper family in the drawing. Write out the chain from your shell
down to `sleep`.

**28.** Why does `bin/sleeper` still exist as a process while `sleep` runs? Read the script. What one
word would you add to make the sleeper process disappear and leave only `sleep` behind?

**29.** Kill it: `pkill -f 'bin/sleeper'`. Now `ps -eo pid,args | grep sleep`. Is the child gone too?
Note what you see; you will explain it properly in 09/03.

**30.** `bin/nest 4`. It prints four lines. Look only at the pids.

**31.** All four levels report the same pid. Explain that with `exec`, in one sentence, using the
words "same process" and "different program".

**32.** Run `bin/nest 4 &`, wait a second, then `ps -eo pid,args | grep -v grep | grep nest`. What
argument does the surviving process show, and why is it not `4`?

**33.** Read `bin/nest`. Remove the word `exec` from a copy in `scratch/` and run that instead. How
many pids do you get now, and what is the parent chain? Draw it with `pstree -p`.

**34.** State the general rule you just proved: `exec` does not create a process, it ______.

**35.** `bin/forker 3 &`. It prints its own pid and three child pids. Confirm all four exist with one
`ps` command.

**36.** Every child has the same ppid. Whose? What made those children — fork, exec, or both?

**37.** `pstree -p` the forker. How is this shape different from the `nest` shape, and what in the
source causes the difference?

**38.** Let `forker` finish (its children sleep 40s). Try `ps -p <one of the child pids>`. What is the
exit status of `ps` when the pid does not exist, and what does that let you do in a script?

## The CMD column is a claim

**39.** `ps -eo pid,comm,args` for your own shell. `comm` and `args` disagree in shape. Which of the
two comes from the file on disk, and which from whoever started the process?

**40.** In `scratch/`: `cp /opt/kestrel/bin/sleep ./nap` and then `./nap 2`. It fails, and the error
message is the whole lesson. Read it. What did the program decide about itself, and from what?

**41.** `bash -c 'sleep 25' &`, then `ps -eo pid,comm,args` for it. You typed `bash`. What does
`comm` say, and what does that tell you happened inside that `bash`?

**42.** Write one sentence you would put in an incident report about how much weight the `CMD` column
can carry. Chapter 12 will hold you to it.

**43.** `readlink -f /opt/kestrel/bin/sleep`. Where does it actually point? Does that change what
`comm` says?

**44.** `ls -l /proc/$$/exe`. That is the kernel's answer to "which file is this process running".
Compare it with `comm` and `args` and say which of the three you would trust in an argument.

## Reporting

**45.** rhea's page says load never drops to zero. From this lesson only, write the two `ps` commands
you would run first, and say what each one would rule in or out.

**46.** Write the sentence you would send back to rhea tonight. It should promise a method, not a
result, and it should not name anything you have not looked at.

**47.** A colleague reports "the summariser is running". List three different things that sentence
could mean, and the one `ps` command that tells them apart.

## Experiment

**48.** Start `bin/sleeper 60 a &`, `bin/sleeper 60 b &`, `bin/sleeper 60 c &`. Now find all three
with one `ps -eo pid,args | grep` and count the total processes that produced. Explain the count.

**49.** Same three running: `ps -eo pid,ppid,args --sort=ppid`. What does sorting by ppid group
together, and when would that be the fastest way to see something?

**50.** `pstree` with no arguments. Compare with `pstree -p $$`. When is the whole-station view worse
than the subtree view?

**51.** Start `bin/spin 20 &` and immediately run `ps -eo pid,stat,comm | head`. Find its `STAT`.
Look up `R` and `S` in `man ps`, section "PROCESS STATE CODES". Which one is spin and which one is
sleeper, and why?

**52.** Run `bin/spin 5` in the foreground and time it with `time`. Is the real time exactly 5
seconds? Read the comment at the top of `bin/spin` and explain the discrepancy.

## Stretch

**53.** Write a function `ancestors PID` that walks up the ppid chain and prints each pid and command
until it reaches pid 1. `ps -o ppid= -p N` is your step. Test it on `$$`.

**54.** Write `kids PID` — every process whose ppid is the given pid, one per line. Test it on your
shell while three sleepers run.

**55.** Combine them: `family PID` prints the ancestors, the process, and the children. What does
your version do when the pid does not exist, and what *should* it do?

**56.** `ps -e -o pid,etime,comm --sort=-etime` on this station gives one process that is much older
than everything else. Argue, from what you know about containers, whether that is normal or
suspicious — and write the check that would settle it.

**57.** Pids are reused. Write down the exact sequence of events by which a script that stores a pid
and acts on it later can end up acting on the wrong process. You will meet a real version of this in
09/04.
