# Chapter 11 — story

**Chapter arc.** **Trace 11** — a line in dorn's startup files that hides one directory from his own
shell. Camouflage, not attack. By `CHALLENGE_DESIGN.md` §4 the arc is **undeniable** from here on.

What it hides is the Chapter 2 directory. A student who connects those is doing capstone work nine
chapters early and gets no acknowledgement — by design.

Roleplay: **cass**, certain the machine is broken because two people running the same command in the
same directory see different things.

---

### `01-env-vars`
> A variable your shell knows and a variable your programs know are two different things, and the
> gap between them explains most "it works when I type it" complaints.

### `02-path`
> When you type a command, something decides which file that means. It is a list, it is in order,
> and anybody who can edit it can decide what `ls` means to you.

### `03-startup-files`
> Four files, three kinds of shell, and a set of rules nobody remembers correctly. You are going to
> prove which runs when rather than trusting anyone's summary, including this one's.

The incident is unsolvable without this lesson landing properly. It gets the experiments.

### `04-aliases-and-functions`
> An alias is a nickname. A function is a replacement. One of those can lie to you convincingly and
> it is not the one people worry about.

### `05-prompt-and-options`
> Your prompt can tell you which machine, which directory and whether the last thing worked. Yours
> currently tells you almost nothing.

### `06-incident-10` — the incident
> dorn's shell configuration does something yours does not. Two people run the same command in the
> same directory and see different things.

Repair it without deleting the file *or* the line — the validator diffs. A deleted line explains
nothing, and explaining it is the exercise.
