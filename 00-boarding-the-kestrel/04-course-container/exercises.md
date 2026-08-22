# 00/04 — Exercises

Build first, then work through these. `kestrel` commands run **in the VM**; everything else runs
**inside the container**.

Keep answers in `~/00-04-answers.md` **inside the container** — you'll want them on hand.

---

## Warmup

**1.** Build the image, start the container, and enter it. Then run `hostname` and `whoami`.

*Done looks like:* a `cadet@kestrel` prompt, and both outputs recorded.

**2.** Seed this lesson's lab and jump to it with the `lab` helper. List what's in it.

*Done looks like:* you're standing in this lesson's lab directory and can list its contents.

---

## Core

**3.** Compare the three places files live. Try to create a file in each of `/course`, `/labs`, and
`/home/cadet`. Record what happens in each case.

*Done looks like:* three attempts, three outcomes, and one sentence explaining the one that failed.

**4.** Find the other user accounts on this station. List them, and say which groups each belongs
to. Then say which of them could log in and which could not.

*Done looks like:* a list of the non-system accounts with their groups, plus your reasoning on
login ability. You have not been taught the file that holds this yet — that's Chapter 10 — so find
it however you can, and say how you found it.

**5.** Prove the volume works. Create a file in this lesson's lab directory, then from the VM stop
the container and start it again. Go back in and check the file.

Then do the same for a file in `/home/cadet`.

*Done looks like:* both files present after a stop/start, and a written statement of which one
would survive the container being **deleted and recreated**, and why.

**6.** Verify the deliberately-missing tools really are missing. Pick two from the notes and
confirm they aren't installed. **Do not install them.**

*Done looks like:* the command you used and its output for each. One sentence on how you can tell
"not installed" from "installed but not on PATH" — you'll meet the real answer in 11/02.

---

## Experiment

**7.** **Predict in writing first.** You're about to reset this lesson's lab. Before running
anything, write down what you expect to happen to each of:

- a file you created in this lesson's lab directory
- a file you created in `/home/cadet`
- a file you created in *another* lesson's lab directory
- the flag, once you've already submitted it

Then create all three files, seed a second lab (`kestrel seed 00/01` won't do — pick a real one,
try `kestrel seed 01/01`), run `kestrel reset 00/04`, and check all four.

*Done looks like:* four predictions, four observations, and a sentence on anything you got wrong.
This is the exercise that stops you losing a chapter of work in Chapter 9.

---

## Stretch

**8.** In 00/03 you compared `hostname`, `whoami`, and `df -h /` between the VM and a throwaway
Ubuntu container. Do it again for the Kestrel container, and add `df -h /labs`.

What is different about `/labs`, and why? Compare it to `/` and to what you saw in the throwaway
container.

*Done looks like:* the outputs and an explanation naming what makes `/labs` different from the rest
of the container's filesystem.

---

## Dig

**9.** `kestrel enter` runs a `docker exec` under the hood. Find out how to run a **single command**
inside a running container from the VM, without opening an interactive shell — and then use it to
print the container's uptime from the VM.

*Done looks like:* the command, its output, and where you found the syntax.

> Technique: `docker exec --help`, and remember `docker help <subcommand>` exists.

---

## Flag

**10.** There is a `KESTREL{...}` flag in this lesson's lab directory. Find it and submit it:

```bash
kestrel flags submit 'KESTREL{...}'
```

Then run `kestrel flags` and confirm it shows as captured.

*Done looks like:* `kestrel flags` reports `00/04  captured`.

This one is easy on purpose. The point is to prove the whole chain works — container, lab seeding,
your eyes, the helper — before Chapter 1, where the flags start biting.
