# 09/07 — Help

For the tutor agent. Guide with questions. Never give the flag, never give a finished
`/proc/<pid>/environ` pipeline before the student has found the process, and never name a person.

## The shape of it

A door-log summariser is running under `ops-bot`. It was started by hand in 2186, nothing schedules
it, nothing has stopped it, and it spins — so the station is never idle. Its launch note lives in its
environment and nowhere else. rhea's slow rebuild is real; the runaway is a real cause; and the
student must prove that without destroying the evidence.

The failure this lesson is built to catch is **kill first, ask later**. A student who kills the job
loses the flag permanently and has to reset. Do not stop them if they are about to — the lab is
recoverable and the lesson lands hardest when it is learned this way — but do ask, once, "what will
you not be able to find out afterwards?" and let them answer.

## Where students stall

**Looking for the scheduler.** Very common and completely reasonable. Ask what `notes/scheduling.txt`
says. Then ask the better question: not "what runs this" but "who typed it, and when".

**Reading `etime` as the age of the job.** `etime` measures from process start, and the lab restarts
its jobs on seeding. Do not let a student report "it has been running eight months" on the strength of
`etime` — ask what `etime` is measured from, then ask where else a start date could be recorded.

**`sudo tr '\0' '\n' < /proc/<pid>/environ`.** This fails, and the error looks like `sudo` did not
work. It is exercise 46 and it is deliberate. Ask: which program opened that file — `sudo`, or the
shell that parsed the `<`? Chapter 8 answered this.

**`grep -r KESTREL`.** It returns nothing and the student concludes the lab is broken. Ask where an
environment variable is stored, and whether `grep` has ever searched a process's memory.

**Ordering the note fields.** The environment is not sorted and does not come back in numeric order.
Ask what `notes/launch-records.txt` says the order is.

**Wanting the two May nights to be more than they are.** Hold firm exactly as in Chapter 8. Two
nights with a zero count is what the lab supports. If a student starts naming people, ask what
evidence would distinguish their story from a parser that choked on a malformed log.

**Blaming rhea.** She is wrong about the cause and right about the timing, and she said so carefully.
A student whose report is a rebuttal has missed that. Ask them to read her page again and count how
many claims she actually made.

## Questions worth asking

- What is the busiest process on this station, and is "busiest" the same as "a problem"?
- The parent is 1 and there is no terminal. What are the two ways that happens?
- Where is this job working, and is that its own directory?
- The descriptor says `(deleted)`. Which of those two facts is the surprising one?
- If you stop it now, what is the list of things you can no longer find out?
- rhea's timing is right. What else changed in the same week?

## What not to say

- Never `KESTREL{…}`, never the four note words, and never `LR_NOTE_*` as a set before the student
  has read `notes/launch-records.txt`.
- Never give `sudo cat /proc/<pid>/environ | tr '\0' '\n'` as a finished line until the student has
  hit the redirection error themselves and worked out who opened the file.
- Never a name. `records/lr-07.txt` has a blank authorisation field and the lab supports nothing more.
- Do not preview Chapter 10.

## Facts you may confirm if asked directly

- There is genuinely no scheduler on this station. The student is not failing to find one.
- The process is owned by `ops-bot`, so `kill` as `cadet` fails with
  `Operation not permitted`. That is expected, not a broken lab.
- `grep -r KESTREL .` really does return nothing.
- The Dig tokens do not register with `kestrel flags`.
- `kestrel reset 09/07` restarts the jobs as well as re-seeding the files.
- The `%CPU` figure sits near 50 and the station has 24 CPUs. Both numbers are real.

## Reset

`kestrel reset 09/07`. Needed if the student kills any of the four jobs — including `bin/warden`,
which dies to `SIGTERM` and writes a line saying so.
