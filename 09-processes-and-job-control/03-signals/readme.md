# 09/03 — Signals

> `kill -9` is not the strong version of `kill`. It is the version that skips the part where the
> program is allowed to finish what it was doing.

A signal is the smallest message the kernel can deliver: a number, no payload, no reply. You cannot
attach data to one and you cannot get an answer back. Everything a signal is able to say is in the
choice of which one you send — which is why knowing the table matters, and why the tool is called
`kill` even though most of the signals in it do not kill anything.

For each signal, a process is in one of three states. **Default**: the kernel's built-in action, which
for most signals is "terminate", for a few is "stop", and for some is "do nothing at all". **Ignored**:
delivered and thrown away. **Handled**: the process installed a handler, and runs its own code
instead. `bin/catcher` in this lab handles TERM, INT and HUP, and prints a line each time instead of
dying.

Two signals cannot be handled or ignored by anybody, ever. **KILL (9)** and **STOP (19)** are acted on
by the kernel without consulting the process. That is their entire purpose, and it is also their
entire cost: a process killed with 9 runs no code. It does not flush its buffers, close its files,
remove its lock, or finish the half-written record it was in the middle of. `bin/tidy` in this lab
removes its state file when it catches TERM, and leaves the file behind forever when it gets KILL. Run
both. That difference is the lesson.

So the order is: TERM, wait, TERM again, and only then KILL — and if you found yourself needing KILL,
that is a thing to write down, not a thing to be pleased about.

Then the reporting. A process killed by signal N exits with status **128+N**: TERM gives 143, INT
gives 130, KILL gives 137, QUIT gives 131. You met 130 and 143 in Chapter 8 without being told where
they came from.

And then the two facts about families that everybody learns the hard way. **A signal goes to the
process you named and to nothing else.** Kill a parent and its children keep running, re-parented to
pid 1, doing exactly what they were doing with nobody watching. And **a dead process does not leave
immediately**: the kernel keeps its exit status until the parent asks for it, and until then it sits
in the table as `Z`, `<defunct>` — a zombie, which cannot be killed because it is already dead.

On this station, zombies accumulate and never leave, and `notes/family.txt` explains why honestly:
our pid 1 is `sleep infinity`, a placeholder that keeps the container alive and never calls `wait()`.
Orphans that exit here stay in the table until the container restarts. That is not a lab bug — it is
the normal behaviour of every container whose pid 1 was chosen for convenience, and it is why you
will meet machines with thousands of zombies and a perfectly healthy load average.

## What you will be able to do

- [ ] Say what a signal is and what it cannot carry
- [ ] Name the three dispositions, and which two signals allow none of them
- [ ] Read `kill -l`, and convert between names and numbers in both directions
- [ ] Choose between TERM, INT, HUP, QUIT, KILL, STOP and CONT for a given situation
- [ ] Explain what a program loses when it is killed with 9, in concrete terms
- [ ] Install a handler with `trap`, and say what a handler cannot do
- [ ] Compute a signal death from an exit status, and recognise 130, 137, 141 and 143
- [ ] Freeze and resume a process, and describe what it holds while stopped
- [ ] Predict what happens to a process's children when you signal the process
- [ ] Explain what a zombie is, why it cannot be killed, and what clears one
- [ ] State why this container accumulates zombies, and when that would matter

## Files

```
bin/plain SECS      no traps. The default behaviour, for comparison
bin/catcher SECS    catches TERM, INT and HUP and refuses to die
bin/tidy SECS       catches TERM, cleans up its state file, exits 0
bin/plain, bin/tidy the pair you compare under KILL
bin/orphan-demo N   starts a child, exits immediately. Watch the child's ppid
bin/signal-report … runs a command and decodes how it ended
notes/signals.txt   the table, the dispositions, 128+N, and the order to try
notes/family.txt    children, re-parenting, zombies, and this station's pid 1
notes/page.txt      rhea, who has been told five things by five people
scratch/            yours; bin/tidy writes its state file here
```
