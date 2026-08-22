# Chapter 8 — story

**Chapter arc.** **Trace 8** — the summariser has been complaining every time it clamps a value,
for fourteen months, to a path that gets recycled. This is dorn's route into the whole thing
(2187-05-13). The student takes the same route without knowing it.

Roleplay: **ops-bot**, which reports that the tool exited zero and will not volunteer that it also
wrote forty thousand lines to stderr.

---

### `01-stdout-stderr`
> A program has two mouths. Almost every tool on this station uses both, and almost every script
> here was written by somebody who forgot the second one existed.

### `02-redirection`
> `2>&1 >file` and `>file 2>&1` differ, and the difference is fourteen months of nobody reading an
> error message. Order matters and this is why.

### `03-heredocs`
> Feeding a block of text to a command without putting it in a file first. Every setup script on
> this station does this; half of them do it wrong.

### `04-pipes-deep`
> A pipe is not a file and does not wait for one. When `head` walks away mid-stream, something has
> to happen to the program still talking — and something does.

### `05-exit-codes-and-chaining`
> Every command tells you whether it worked and almost nobody listens. A program can fail
> completely and exit zero, honestly, if nobody ever taught it otherwise.

The lesson that makes the incident possible. It is not a lie that the tool exits zero.

### `06-incident-08` — the incident
> A diagnostic tool prints a clean report and exits zero. Run it and it looks healthy. Somebody has
> arranged for it to look healthy.

One invocation, both streams, no byte of stdout lost. The flag is in the complaint text and exists
in no file — the student has to run the tool to see it.
