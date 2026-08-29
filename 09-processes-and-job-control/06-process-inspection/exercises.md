# 09/06 — Exercises: Process inspection

```
cd /labs/09-processes-and-job-control/06-process-inspection
ls -F
```

Chapters 1–9 tools. Wrecked the lab? `kestrel reset 09/06`.

Most of these need a process to look at, so most of them start by backgrounding one. Keep track of
your pids — `$!` after each `&` is the habit — and clean up with `jobs` before you leave.

---

## Warmup — /proc is not a directory

**1.** `cat notes/proc.txt`. Then `ls /proc | head -20`. What are the numeric entries, and what are
the non-numeric ones?

**2.** `bin/tagged 300 &`, note `$!`. Now `ls /proc/$!`. How many entries, roughly? Is any of it a
file in the sense Chapter 3 taught you?

**3.** `ls -l /proc/$!/ | head -20`. Look at the size column. What is every regular file's size, and
what does that tell you about where the contents come from?

**4.** `stat /proc/$!/status`. What filesystem is it on? (`stat -f` will tell you.) Have you seen that
filesystem type before?

**5.** `wc -c /proc/$!/status` and then `cat` it. The size said 0 and the content is not empty.
Explain, in one sentence, without using the word "file".

## cmdline and environ

**6.** `cat /proc/<pid>/cmdline` for your tagged process. The output is wrong-looking. What is between
the arguments?

**7.** `cat /proc/<pid>/cmdline | od -c | head -2`. Now you can see it. Which byte is the separator?

**8.** Read it properly: `tr '\0' '\n' < /proc/<pid>/cmdline`. How many arguments, and what is
argument 0? Is it what you typed?

**9.** Compare with `ps -o args= -p <pid>`. Which of the two would you trust for a command whose
arguments contain spaces, and why?

**10.** Kill that one and start a new one with an environment:
`PANEL_RUN=deck05 STATION_TEST=abc bin/tagged 300 &`.

**11.** `tr '\0' '\n' < /proc/$!/environ | sort`. How many variables? Find your two.

**12.** `grep -E 'PANEL_RUN|STATION_TEST' /proc/<pid>/environ` — with `grep`, not `tr`. Does it work?
What does `grep` do with NUL-separated input, and what does that mean for `grep -c` here?

**13.** `ls -l /proc/<pid>/environ`. Read the mode. Who can read this, and who cannot?

**14.** Prove it: `sudo cat /proc/<pid>/environ | tr '\0' '\n' | head -3` works, and (if you can find
a process owned by another account) reading it as yourself does not. What is the error?

**15.** Change the variable in *your* shell: `export PANEL_RUN=other`. Now re-read the running
process's environ. Did it change? What does `environ` actually record — the environment now, or the
environment it was given?

**16.** So where else on this station is that process's environment written down? Answer carefully;
this is the sentence at the top of `readme.md` and the whole of the next lesson.

## exe, cwd, root

**17.** `readlink /proc/<pid>/exe` for your tagged process. Is that the path you typed?

**18.** `sleep 300 &` and `readlink /proc/$!/exe`. That is not a file called `sleep`. Look at the
path. What kind of binary is that, and what does it mean for identifying a process by its executable?

**19.** `readlink /proc/<pid>/cwd`. Where is it? Should it be?

**20.** `bin/wanderer 60 &`. Now run `readlink /proc/$!/cwd` three times, five seconds apart. Write
down the three answers.

**21.** State what you have just proved about `cwd`, and name one investigation where "where it
started" and "where it is now" would give you different answers.

**22.** `readlink /proc/<pid>/root`. What is it, and when would it not be `/`?

**23.** `cd /proc/<pid>` and then `pwd -P`. Does the shell let you treat this as a real directory?
What happens when the process exits while you are standing in it?

## Open files

**24.** `ls -l /proc/<pid>/fd` for your tagged process. Which descriptors exist, and what are 0, 1 and
2 pointing at?

**25.** Start one with a redirect: `bin/tagged 300 > scratch/out.txt 2>&1 &`, then list its fds again.
Which link changed, and does the `l-wx`/`lr-x` mode tell you the direction?

**26.** `bin/holdopen 120 &`. Wait three seconds, then `ls -l /proc/$!/fd/9`. Read the target
carefully, including the last word.

**27.** `ls scratch/`. The file is not there. `find . -name vanishing.log`. Also nothing. Where are
the bytes?

**28.** `tail -3 /proc/<pid>/fd/9`. You are reading a file that has no name. Wait five seconds and
`tail` again. Explain what you are actually opening when you do this.

**29.** `cp /proc/<pid>/fd/9 scratch/recovered.log`. Does it work? Check the result. Write the
one-sentence rule about deleted-but-open files that this demonstrates.

**30.** Kill the holdopen process, then `ls -l /proc/<pid>/fd/9`. Now what? State when the space was
actually freed.

**31.** `lsof -p <pid>` for a running `bin/tagged`. Read the FD column: what are `cwd`, `rtd`, `txt`
and `mem`, and which of them are not numbered descriptors?

**32.** `bin/reader-of data/panel-readings.csv 120 &`, then `lsof data/panel-readings.csv`. How many
processes hold it open, and why is one of them `sleep`?

**33.** `fuser data/panel-readings.csv` and then `fuser -v` on the same path. Which output would you
paste into a report, and what does the `f` in the ACCESS column mean? (`man fuser`.)

**34.** `lsof -u $USER | wc -l` and `lsof -c bash | head`. Say what each selects, in the language of
lesson 04's `-u` versus `-U` distinction.

**35.** `lsof +D data/` — it walks the tree. Compare its runtime with `lsof data/panel-readings.csv`.
When is `+D` the right tool and when is it a mistake?

**36.** A filesystem will not unmount, or a directory will not delete, because something is "busy".
Write the two commands you would run, in order, and say what each one gives you that the other does
not.

## status and stat

**37.** `head -20 /proc/<pid>/status`. Find State, Pid, PPid, Uid and Gid. Why does `Uid:` have four
numbers?

**38.** `grep -E 'SigIgn|SigCgt' /proc/<pid>/status` on a background job. You decoded these in lesson
03 — do it again here without looking it up.

**39.** `grep Groups /proc/<pid>/status`. Compare with `id -G`. Same list?

**40.** `cat /proc/<pid>/stat`. One line, unlabelled. Using `notes/proc.txt`, pull out the state
letter, the ppid and the start time with `awk`.

**41.** Field 2 is the command in parentheses. What happens to that field if a command's name contains
a space or a bracket, and why does that make `stat` awkward to parse in general?

**42.** `cat /proc/<pid>/limits | head`. Pick one limit and say what would happen to the process if it
hit it.

## nice and renice

**43.** `ps -o pid,ni,pri,args -p <pid>` on anything. What is the default nice value?

**44.** `nice -n 10 bin/spin 5 &`, then `ps -o pid,ni,args --no-headers -p $!`. Confirm the value.

**45.** `nice -n -5 true; echo "rc=$?"`. Read the error and read the status. They disagree. Explain
what `nice` did, and write the rule about checking `$?` after `nice`.

**46.** `bin/tagged 120 &`, then `renice 5 -p $!`. Read the output line: it names old and new.

**47.** Now `renice 0 -p <pid>` — put it back. Read the error, exactly. State the ratchet rule in one
sentence.

**48.** So what would you have to be to undo it? Try `sudo renice 0 -p <pid>` and confirm.

**49.** `renice 5 -u $USER`. What did that just do, and how would you check the blast radius *before*
running it rather than after?

**50.** Two `bin/spin 5` at once, one at nice 0 and one at nice 19. Compare the iteration counts they
print. The difference is nothing at all. Run `nproc`, and then explain the result — niceness decides
who yields *when there is contention*, and you have not created any.

**51.** A colleague reports a job is slow and asks you to renice it. Before you do: what one thing
would you check first, and what would tell you that renicing will not help at all?

## Reporting

**52.** `cat notes/page.txt`. rhea asks what a process "thinks it is doing". List the five `/proc`
reads that answer her, in the order you would run them.

**53.** Write the four-sentence note back. It must say what you would collect, why the order matters,
and why the process must stay running while you collect it.

**54.** Write the one-line command that captures everything worth having about a pid into a file, so
that killing the process afterwards costs nothing. Test it.

**55.** What in your capture would you have to redact before putting it in a report that other people
read? (Look at what is in a real `environ`.)

## Experiment

**56.** Copy `bin/tagged` to `/tmp`, run the copy, and delete it while it runs. Does it keep going?
`readlink /proc/<pid>/exe` is unchanged and unhelpful — say why. Then look at
`ls -l /proc/<pid>/fd/255`, which is where bash keeps the script it is reading. What does the last
word on that line tell you, and what does the whole thing tell you about how the kernel holds a
running program?

**57.** Two processes, one pipe: `bin/tagged 60 | cat &`. Look at the fd links of both. Find the pipe
inode number in both listings and say what the matching numbers prove.

**58.** Write `whatis-pid`, a function taking a pid and printing: command line, cwd, exe, open file
count, nice value, state and ppid — labelled, one per line, and gracefully when the process has
already exited.

**59.** Run your function on pid 1. Which fields are odd, and does the oddness match what lesson 03
told you about this station's pid 1?

**60.** Find every process on the station whose `cwd` is under `/labs`. What do you have to be able to
read to answer that, and which processes will you silently miss?

## Stretch

**61.** `/proc/<pid>/fd` for a process is the only handle to a deleted file. Write the procedure for
recovering a 2 GB log that a running monitor deleted an hour ago — and say at which step the
procedure fails if somebody restarts the monitor "to fix it".

**62.** Compare `ps -o lstart` with field 22 of `/proc/<pid>/stat`. Convert the raw value to a real
time using `/proc/uptime` and the clock tick (`getconf CLK_TCK`). Why would you ever do this the hard
way?

**63.** `environ` shows the environment a process was *given*. A process can change its own
environment after it starts. Design an experiment that shows whether `/proc/<pid>/environ` follows
those changes, and say what your result means for trusting it as evidence.

**64.** Niceness is CPU only. Name the two other kinds of contention a slow job might be losing, and
the tool for each. One of them is in `notes/priority.txt`.

**65.** You have a pid, an account that is not a person, and a start time eight months ago. List
everything you can establish about it without stopping it, and mark the ones that stop being
answerable the moment it dies.
