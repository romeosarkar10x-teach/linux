# 00/02 — Exercises

All of these run **in the VM** (or in the VirtualBox GUI on your host). No container yet.

Keep answers in `~/00-02-answers.md` inside the VM.

---

## Warmup

**1.** Boot the VM and prove Guest Additions are working: resize the VirtualBox window and confirm
the desktop resolution follows it, then copy a line of text from your host into the VM's terminal.

*Done looks like:* a note in your answers file saying both worked. If either doesn't, fix it now —
you'll be copying commands all course.

**2.** In the VM, run `hostname`, `whoami`, and `df -h /`. Write down all three outputs.

*Done looks like:* three outputs recorded. Keep them; in 00/04 you'll run the same three commands
inside the container and compare.

---

## Core

**3.** Take a snapshot named `clean-install` **with a description** saying what's installed. Then
take a deliberate risk: create a file `~/canary.txt` containing today's date, restore the snapshot,
and check whether the file survived.

*Done looks like:* you can state from direct observation whether the file is there, and explain
why.

**4.** Confirm your disk is dynamically allocated and find out how much of it is actually consumed
on the host right now. Compare that number to what `df -h /` reports inside the VM.

*Done looks like:* two numbers — the host-side `.vdi` file size and the VM's used space — and one
sentence on why they aren't the same.

**5.** Write down the exact recovery procedure you'd follow if, in Chapter 10, you locked yourself
out of `sudo` in the VM. Be specific enough that you could follow it while annoyed.

*Done looks like:* numbered steps naming the snapshot you'd restore and what you'd lose.

---

## Experiment

**6.** **Predict in writing first.** You have `clean-install` (before Guest Additions) and you're
about to install them. If you install Guest Additions, take snapshot `docker-ready`, then restore
`clean-install` — what happens to Guest Additions? And if you then restore `docker-ready` again,
what happens?

Write both predictions, including what you expect the VirtualBox snapshot tree to look like. Then
do it and observe.

*Done looks like:* prediction, observation, and — if they differ — a sentence on what you believed
about how snapshots relate to each other that turned out to be wrong.

---

## Dig

**7.** VirtualBox ships a command-line tool, `VBoxManage`, on the **host**. Find how to list your
VMs and how to list a VM's snapshots from the command line, without touching the GUI.

*Done looks like:* the two commands and their output. Say where you found each — `VBoxManage
--help` and the VirtualBox user manual both count; a random blog does not.

> Technique, not answer: `VBoxManage` with no arguments prints a very long usage list. Pipe it into
> `less` and search with `/`. You'll learn what that pipe is doing in Chapter 8.
