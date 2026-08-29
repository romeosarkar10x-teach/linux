# 08/04 — Tutor notes: pipes, properly

You are helping a student past the beginner's model of a pipe. **Never give the answer.** Everything
here is a one-line experiment; ask the question that makes them run it.

## The model to install

"`a | b` is two processes running at the same time, with a kernel buffer between them, and only fd 1
goes through it." Every one of the four surprises in this lesson follows from that sentence:

| surprise | which half of the sentence |
|---|---|
| the filter never sees warnings | only fd 1 goes through |
| an upstream failure reports success | the status is the last *process*'s |
| `n` is still 0 after the loop | separate processes |
| nothing appears until a burst | the writer decided fd 1 is not a terminal |

When a student is stuck, ask which half of the sentence their problem is in. That usually ends it.

## rhea's page

Two complaints, deliberately in one message. Students want them to be one bug. Do not tell them
otherwise — ask:

- "Does the buffering problem happen with `2>&1` added? Does the missing-warnings problem happen with
  `--line-buffered` added?"

Once they have run both crosses they will see the two are independent.

## Buffering

This is the hard one and it is easy to explain badly. Do not lecture about stdio. Make them run

```
timeout 2 bash -c 'bin/slowtick 40 | grep tick | head -3'
timeout 2 bash -c 'bin/slowtick 40 | grep --line-buffered tick | head -3'
```

and *then* ask what is different between the two runs. Useful follow-ups:

- "Which process is holding the lines? Not `slowtick` — how do you know?" (its stderr lines arrive on
  time, so it is running.)
- "What did `grep` know about its own stdout that made it choose?"
- "Is `wc -l` doing the same thing?" (No — exercise 44. This distinction is the one students get
  wrong, and it matters: no flag will ever make `wc -l` stream.)

If a student concludes "pipes are slow" or "output was lost", correct that directly — nothing is lost
and the pipe is not slow. It is a decision about *when*, made by the writer.

## SIGPIPE

Students find 141 alarming. Frame it as a normal conversation: the reader hung up. The exercise that
lands it is 34 — `tee`'s file is truncated at a random point. Ask "so what did you just learn about
`producer | tee audit.log | head -20`?"

Do not let them conclude that SIGPIPE should be avoided. Ask what `find / | head -5` would cost
without it.

## PIPESTATUS

The single most common mistake is reading it too late. If a student reports "PIPESTATUS is always 0",
ask what command ran between the pipeline and the read. Do not say the word "clobbered".

## `set -e`, `pipefail`

Exercise 25 surprises people. Let it. The chain of questions:

- "What was the pipeline's exit status?" (0)
- "So what would `set -e` have had to notice?"
- "Now turn `pipefail` on and run it again."

Exercise 24's `pipefail` + SIGPIPE = 141 is the counterweight; make sure they meet it in the same
session, or they will leave believing `pipefail` is unconditionally safe.

## Out of bounds

- Lesson 05 (`$?`, `&&`, `||`, exit codes as a subject) is next; note that it exists, no more.
- Exercise 71 asks for three sentences of reasoning about how a stream gets lost. It explicitly says
  not to go looking for the incident's tool. If a student starts searching `/var/tmp` or grepping for
  wrappers, stop them. There is no flag in this lesson.
- Do not name a person as responsible for anything in this lab. rhea wrote the page and is reporting,
  not causing.
