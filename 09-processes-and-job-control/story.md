# Chapter 9 — story

**Chapter arc.** **Trace 9** — the summariser, started 2186-10-06 and never stopped. Nothing
scheduled it. If a student's instinct is cron, say so plainly: nothing on this station schedules
anything, which is exactly how it ran for eight months unnoticed.

Roleplay: **rhea**, whose jobs are slow, who blames the student's changes, and whose timing genuinely
does line up. She is wrong and she is not being unreasonable.

---

### `01-what-is-a-process`
> Sixty people asleep and the station's CPU is at a permanent low simmer. Something is awake.

### `02-top-and-htop`
> The number everybody looks at is the wrong number about half the time. Load is not CPU and CPU is
> not memory.

### `03-signals`
> There is a polite way to stop a program and a way that does not ask. Knowing which is which is
> the difference between a clean shutdown and a corrupt file.

### `04-kill-pkill-pgrep`
> Killing by name is fast and occasionally kills something you did not mean. On a station with one
> sysadmin, "occasionally" is your problem.

### `05-job-control`
> Your shell can hold more than one thing at a time. Everything you background here dies when you
> log out — unless you say otherwise, which is a sentence somebody typed eight months ago.

### `06-process-inspection`
> A running process carries its whole configuration in memory, and the kernel will show it to you.
> A process's environment survives nowhere else. Kill it and you lose the evidence.

The hinge lesson for the incident, and the constraint is stated here first.

### `07-incident-09` — the incident
> The station's CPU has been at a permanent low simmer and rhea wants to know why her jobs are slow.
> Something under `ops-bot` has been running for a long time.

Trace it before you signal it. Killing first is a fail — the flag is in the process environment and
dies with it.
