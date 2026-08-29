# 09/05 — Validation

For the validator agent. No script grades this lesson; you do. Ask, listen, and check the reasoning,
not the wording. There is no flag in this lesson.

## Pass requires all of these

1. **Job is not process.** They can say that one job may be several processes, and back it with the
   pipeline in exercise 61 — three names, one job number, and `jobs -l` showing the leader's pid.
2. **The mechanics, demonstrated live.** Background a job, stop it, `bg` it, `fg` it, kill it by job
   spec. Watch them do it. Fluency here is the point, not recall.
3. **Job specs.** They can predict `no such job` for `%quiet` and `ambiguous job spec` for `%bin`,
   and explain that the spec matches the command as typed.
4. **SIGTTIN.** Shown `Stopped (tty input)`, they say the job tried to read the terminal and the fix
   is `fg`.
5. **The three survival rules, with their own evidence.** Specifically: `huponexit` is off here; with
   it *on* in a non-login interactive shell the job still survives; with it on in a login shell the
   job gets HUP. If they only recite rule 2 without the login-shell condition, that is a fail on this
   item — it is the exact thing the lesson exists to correct.
6. **`nohup`'s two behaviours.** HUP ignored, and `nohup.out` created *only* when stdout is a
   terminal. They should be able to name the two different stderr messages.
7. **`disown` versus `disown -h`.** One removes the job from the shell's table (`kill %1` then fails);
   the other keeps it listed and exempts it from HUP.
8. **`setsid`.** New session, ppid 1, `?` for TT, no owning shell, invisible to `jobs` anywhere.
9. **Job control in scripts.** Off by default; `set -m` turns it on; they can say why a script does
   not normally need it.

## Good answers to listen for

- On rhea's second question (56): the honest answer is that **nothing** records who started a
  surviving process. `ps -o user` gives the account, not the person; `lstart` gives when; `/proc`
  gives the environment it was given. A student who says "the process itself is the only record" has
  the idea the next two lessons need.
- On 51: `setsid` changes the most — it changes what the process *is*, not just what happens to it on
  HUP.
- On 66: two reasons. It does not fix rule 1 (the terminal dying), and it does not touch anything
  already `disown`ed, `nohup`ed or `setsid`ed — which is exactly the class of thing that gets left
  behind.

## Answers to push back on

- "Background jobs die on logout." Ask for the command that proves it, on this station.
- "`nohup` runs it in the background." It does not; `&` does. `nohup cmd` alone blocks.
- "`disown` protects it from being killed." It removes it from *this shell's* table. `kill <pid>`
  still works and they should say so.
- "`jobs` shows the machine's jobs." Ask what a second shell sees.
- Exercise 64 answered as "the trap fires". It does not: `nohup` sets HUP ignored, and bash will not
  install a handler for a signal inherited as ignored, so `SigCgt` never gains the HUP bit and the
  signal does nothing at all. If they claim otherwise, ask for `/proc/<pid>/status`.

## Cross-checks

- Lesson 03: they should reuse `SigIgn`/`SigCgt` decoding without being prompted, and know that a
  signal sent to a stopped process is pending until CONT (exercise 62).
- Lesson 04: they should reach for `pgrep -af` to find the jobs their shell has forgotten, and should
  connect per-job process groups here with the process-group kill from 04/37b.
- Forward: exercise 63's `holdover` function is most of lesson 07's method. If they wrote it, keep it.
