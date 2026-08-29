# 09/07 — Exercises: Incident, nobody stopped it

```
cd /labs/09-processes-and-job-control/07-incident-09
ls -F
```

Chapters 1–9 tools. Wrecked the lab? `kestrel reset 09/07` — it re-seeds the files **and restarts the
jobs**. Read the rule in `readme.md` before you send a signal to anything.

---

## Warmup — read before you touch anything

**1.** `cat notes/page.txt`. rhea makes three separate statements: an observation, a correlation, and
an instruction. Write each one down in her words. Which of the three is she asking you to test?

**2.** She says "you started, it got slow". Is that claim false? Answer precisely: say what it
asserts and what it does not assert.

**3.** `cat logs/rebuild-times.txt`. Where does the number change, and by how much? Give the date of
the first slow night.

**4.** `cat logs/deck-05-shift.txt`. Compare the dates. Does the shift log support rhea's timing?

**5.** So the correlation is real. Write the one sentence that says why a real correlation is still
not a cause, without being rude about it.

**6.** `cat notes/scheduling.txt`. Before you go looking for the thing that starts jobs on this
station: what does this note say you will find?

**7.** `cat notes/load.txt`, then `uptime`. Read the load average out loud as a sentence that does not
contain the word "percent".

**8.** `nproc`. Given that number and the load average you just read, what fraction of this station is
actually busy? Is that a lot?

## What is awake

**9.** `ps -e | wc -l`. How many processes exist. Is that number useful on its own?

**10.** Sort by CPU: `ps -eo pid,user,ni,pcpu,etime,args --sort=-pcpu | head -8`. One line is not like
the others. Write down its PID, its user, and its `%CPU`.

**11.** `top -b -n1 | head -12`. Same process at the top. Which column in `top` corresponds to `pcpu`
in your `ps`, and which one is the *cumulative* time it has used?

**12.** The `%CPU` is around 50. From `notes/load.txt` and `nproc`: is this process saturating the
station, and if not, why is rhea's job slower?

**13.** Give the honest answer to "is the machine overloaded?" and the honest answer to "is the
machine ever idle?". They are different answers and only one of them is the finding.

**14.** `ps -o pid,ppid,stat,tty,args -p <PID>`. Read all four. What is the parent, what is the
terminal, and what does the `STAT` letter say about what it is doing right now?

**15.** A parent of `1` and a terminal of `?`. From lesson 05: name the two ways a process ends up
looking like that, and say which of them you cannot rule out yet.

**16.** `ps -o lstart,etime -p <PID>`. Note the elapsed time. Now read this carefully: **the station's
clock and this lab's clock are not the same clock.** Elapsed time is measured from when this process
started, and the lab restarts its jobs when it is seeded. What is `etime` good for here, and what is
it not good for?

**17.** So you cannot date this job from `etime`. Where else, then? List every place a start date
could be recorded, from what you know of Chapter 9. You have not read any of them yet.

**18.** `pgrep -c -u ops-bot` and then `pgrep -a -u ops-bot`. How many jobs run under that account,
and what is the difference between what the two commands told you?

## Whose job is this

**19.** From the `args` column: what is the command line, in full? Which part of it is the
interpreter, which part is the script, and which parts are arguments the script was given?

**20.** `cat /proc/<PID>/cmdline | tr '\0' '\n'`. Same information, different separator. Why does the
plain `cat` look like one run-on word?

**21.** The command line carries `--tag lr-07`. `ls records/`. Which file does that name?

**22.** `cat records/lr-07.txt`. Read every field, including the blank one. What does the blank field
tell you, and what does it not tell you?

**23.** `ls -l records/lr-0*.txt`. Three launch records, three mtimes. Which job is the oldest, and
does the record's mtime agree with the `started` field inside it?

**24.** `cat notes/launch-records.txt`. State the convention in one sentence: where does a launch
note live, and how long does it live for?

**25.** Given that convention, answer exercise 17 properly: which of the places you listed actually
holds this job's note?

**26.** Read `notes/scheduling.txt` again next to `records/lr-07.txt`. Somebody typed this command in
a shell on 2186-10-06 and walked away. Write the sentence that explains why nothing has stopped it
since — it should be about the station, not about a person.

## What it is doing

**27.** `sudo ls -l /proc/<PID>/cwd` — or `sudo readlink /proc/<PID>/cwd`. Where is this process
working? Is that its own directory?

**28.** Why did that need `sudo` when `ps` did not? Answer in terms of who owns the process.

**29.** `sudo ls -l /proc/<PID>/fd`. Five descriptors. Say what each of 0, 1, 2 and 255 is, from
lesson 06.

**30.** Descriptor 9 is the interesting one. Read the target exactly, including what comes after the
path in parentheses. What does that mean?

**31.** `ls -l spool/door/`. The file named on fd 9 is not there. Both of these are true at once —
explain how, in the terms lesson 06 used.

**32.** Read it: `sudo cat /proc/<PID>/fd/9 | head -30`. This is eight months of output that exists
in no filename. What is it a summary of?

**33.** Two of the nights in that summary are not like the others. Which two, and what does the file
itself say happened on them?

**34.** Chapter 8 pointed at two nights in May 2187. Are they the same two nights? Write the sentence
you can support and stop there. Do not add a third sentence.

**35.** `sudo cp /proc/<PID>/fd/9 scratch/recovered.txt`. Now you have a copy with a name. What
exactly did you just do — and what would have happened to those bytes if you had killed the process
instead?

**36.** `sudo lsof -p <PID>` (or `sudo lsof -a -p <PID> -d 9`). Find the deleted file in the output.
Which column tells you it is deleted?

**37.** `df -h /labs` before and after you kill something is not the experiment to run here. Say why
not — what is the actual size of this file, and would the space matter?

**38.** `sudo ls /proc/<PID>/task` and `pstree -p <PID>`. Does this job have children? What is the
short-lived one, and where in `bin/door-summariser`'s loop does it come from?

## Do not kill it

**39.** Try, deliberately, and read the error: `kill <PID>`. Write down the exact message. Why did it
fail, and what would it have taken to succeed?

**40.** So the only way you can stop this job is `sudo`. Is that a safety feature or an accident?
Answer honestly.

**41.** State the constraint in your own words: what, specifically, would be destroyed by
`sudo kill <PID>` that is not recoverable from any file, any log, or a reset?

**42.** rhea's page says she would rather be slow than ignorant. Rewrite that as an operational rule
in one line, suitable for a shift board.

**43.** Suppose you had killed it before reading anything. List what you would still be able to say
about it afterwards, from `records/`, `logs/` and `spool/` alone. Is that enough to answer rhea?

**44.** There is one signal in this lab that is safe to send, and it is not to this process. You will
meet it in the Dig. Before then: name the two signals that would end this job and say which one it
could not refuse.

## The note

**45.** `cat /proc/<PID>/environ` as yourself. Read the error. Then read `ls -l /proc/<PID>/environ`
and explain the mode.

**46.** Now: `sudo tr '\0' '\n' < /proc/<PID>/environ`. This *also* fails. Look at the error and say
who tried to open the file — `sudo`, or your shell. Which chapter told you that?

**47.** Fix it: `sudo cat /proc/<PID>/environ | tr '\0' '\n'`. Read the whole environment. Which
variables were put there by whoever started the job, and which are just what any process gets?

**48.** `sudo cat /proc/<PID>/environ | tr '\0' '\n' | grep '^LR_' | sort`. Read `LR_STARTED`. There
is your date. Does it agree with `records/lr-07.txt`?

**49.** Apply the convention from `notes/launch-records.txt` to the numbered note fields. Read them in
numeric order, not the order the environment happens to store them in. Four words.

**50.** Assemble and submit:
`kestrel flags submit 'KESTREL{...}'`.

**51.** `grep -r KESTREL . ; echo "rc=$?"` and `grep -rw nobody . ; echo "rc=$?"`. Both find nothing.
Write the one-sentence explanation, and make it about where an environment lives.

**52.** Check the other two ops-bot jobs the same way: `sudo cat /proc/<pid>/environ | tr '\0' '\n' |
grep '^LR_'`. Do they carry note fields? What does their absence tell you about lr-07?

## Reporting

**53.** Write the three-sentence finding for rhea. Sentence one: what is running. Sentence two: how
you know it is the cause of her slow rebuild — or why you cannot say that as strongly as she would
like. Sentence three: what you propose to do and what will be lost when you do it.

**54.** She was wrong about you and right about the timing. Write the one line you send her that
concedes the timing without conceding the cause, and without being smug about it.

**55.** Your report will be read by somebody who wants a name. `records/lr-07.txt` has a blank
`authorised` field. Write the sentence you put in the report about that blank, which says what the
evidence supports and stops.

**56.** Recommend the fix. It is two parts: what to do with this job tonight, and what to change so
that a job started by hand in 2186 cannot be running in 2187 unnoticed. Cost each part.

**57.** Before anyone stops it: write the four commands you would run first, in order, to preserve
everything that dies with the process. You have run three of them.

## Experiment

**58.** In `scratch/`, start your own long-runner with a note in its environment:
`NOTE_1=my NOTE_2=note setsid bash -c 'while :; do sleep 5; done'`. Find it with `pgrep`, read its
environment, then kill it and try again. Time how long the evidence lasts after `kill`.

**59.** Start the same job, then `export NOTE_1=changed` in your shell. Read the running job's
environment again. Did it change? Explain (lesson 06 measured this).

**60.** Reproduce the deleted-but-open trick yourself: a script that opens a file on fd 9, deletes it,
and keeps writing. Read it back through `/proc`. Now `sudo` is not needed — why?

**61.** Run two spinners at once and watch `%CPU` for each in `top`. With 24 CPUs, do they slow each
other down? Work out — do not run it — how many spinners it would take before any of them lost time
to another, and say what that means for rhea's eleven minutes: is one runaway enough to explain them
on its own?

**62.** `renice 19 -p <your spinner>` and watch. Then try `renice 0 -p` the same process. Which
direction is allowed, and what was the error?

## Stretch

**63.** Write `whose-job PID`: prints user, parent, start time, command line, cwd, and every `LR_*`
variable, in one screen, and exits non-zero if the process does not exist. Use it on all four jobs.

**64.** Write `hand-started`: lists every process whose parent is 1 and which is not part of the
system's own startup. Say honestly which part of that is a judgement call and how your script makes
it.

**65.** The station has no scheduler. Design the smallest thing that would have caught this — not a
scheduler, a *check*. What does it run, what does it compare against, and what does it do when the
answer is "a job nobody has a record of"?

**66.** `sudo cat /proc/<PID>/fd/9` gave you the whole file even though the process is still appending
to it. Where does your read start, and what happens if you run it twice? Explain using the file
offset, not the process.

## Dig

Four stages. Tokens are `STAGE{...}` and do not register with `kestrel flags`.

**67.** Stage 1. You already have it if you did exercise 22. The runaway names its own launch record
on its command line; the record holds the first token and tells you what to do next.

**68.** Stage 2 is a signal. `bin/warden` is running under your own account and answers exactly one
signal — not either of the two that stop it. Send the right one and read `records/warden.log`. If you
send `SIGTERM`, the log will tell you what you did and you will need `kestrel reset 09/07`. Say which
signal you chose and why it was safe.

**69.** Stage 3. The warden points you at the file with no name. You read it in exercise 32; the token
is in it.

**70.** Stage 4. Three jobs run under `ops-bot`. Two share a priority and one does not:
`ps -eo pid,ni,args -u ops-bot`. That nice value is a line number in `records/index-d.txt`. If the
line tells you to read it again, you took the priority of the wrong job.

**71.** The four stages used four skills: a command line, a signal, a descriptor, a priority. Name the
one thing you were never allowed to do at any stage, and say what it would have cost at each of them.
